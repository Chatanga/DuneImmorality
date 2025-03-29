local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")
local I18N = require("utils.I18N")

local PlayBoard = Module.lazyRequire("PlayBoard")
local Commander = Module.lazyRequire("Commander")
local Action = Module.lazyRequire("Action")
local Deck = Module.lazyRequire("Deck")
local Types = Module.lazyRequire("Types")
local TurnControl = Module.lazyRequire("TurnControl")
local MainBoard = Module.lazyRequire("MainBoard")
local Music = Module.lazyRequire("Music")
local ConflictCard = Module.lazyRequire("ConflictCard")
local Board = Module.lazyRequire("Board")

---@class Combat
---@field rewardTokenZone Zone
---@field combatCenterZone Zone
---@field victoryPointTokenBag Bag
---@field protoSandworm Object
---@field objectiveTokenBags Bag[]
local Combat = {
    -- Temporary structure (set to nil *after* loading).
    unresolvedContent = {
        victoryPointTokenBag = "86dc4e",
        protoSandworm = "14b25e",
        objectiveTokenBags = {
            muadDib = "a17bcb",
            ornithopter = "bd4b71",
            crysknife = "85f9b6",
            joker = "99ecfe",
        },
    },
    noCombatForcePositions = Vector(0, 0, 0),
    combatForcePositions = {},
    dreadnoughtStrengths = {},
    ranking = {}
}

---@param state table
function Combat.onLoad(state)
    Helper.append(Combat, Helper.resolveGUIDs(false, Combat.unresolvedContent))

    Helper.noPhysicsNorPlay(Combat.protoSandworm)
    for _, objectiveTokenBag in pairs(Combat.objectiveTokenBags) do
        Helper.noPhysics(objectiveTokenBag)
    end

    if state.settings and state.Combat then
        Combat._transientSetUp(state.settings)
        Combat.dreadnoughtStrengths = state.Combat.dreadnoughtStrengths
        Combat.ranking = state.Combat.ranking
    end
end

---@param state table
function Combat.onSave(state)
    state.Combat = {
        dreadnoughtStrengths = Combat.dreadnoughtStrengths,
        ranking = Combat.ranking,
    }
end

---@param settings Settings
function Combat.setUp(settings)
    Combat._transientSetUp(settings)
    assert(Combat.conflictDeckZone)
    return Deck.generateConflictDeck(Combat.conflictDeckZone, settings)
end

---@param settings Settings
function Combat._transientSetUp(settings)
    Combat.formalCombatPhase = settings.formalCombatPhase

    Combat._processSnapPoints(settings)

    Helper.registerEventListener("strengthValueChanged", function ()
        Combat._updateCombatForces(Combat._calculateCombatForces())
    end)

    Helper.registerEventListener("selectAlly", function ()
        Combat._updateCombatForces(Combat._calculateCombatForces())
    end)

    Helper.registerEventListener("phaseStart", function (phase)
        if phase == "roundStart" then
            Combat._setUpConflict()
        elseif phase == "combat" then
            Action.setContext("combat", Combat.getCurrentConflictName())
            -- A small delay to avoid being erased by the player turn sound.
            Helper.onceTimeElapsed(1).doAfter(function ()
                Music.play("battle")
            end, 1)
        elseif phase == "combatEnd" then
            local forces = Combat._calculateCombatForces()
            Combat.ranking = Combat._calculateRanking(forces)
            local turnSequence = Combat._calculateOutcomeTurnSequence(Combat.ranking)
            TurnControl.overridePhaseTurnSequence(turnSequence)
            Combat.showRanking(turnSequence, Combat.ranking)
        elseif phase == "recall" then
            for _, object in ipairs(Combat.rewardTokenZone.getObjects()) do
                if Types.isVictoryPointToken(object) or Types.isObjectiveToken(object) then
                    MainBoard.trash(object)
                end
            end
            -- Recalling units in the combat (not in a controlable space).
            for _, object in ipairs(Combat.combatCenterZone.getObjects()) do
                for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
                    if Types.isTroop(object, color) then
                        Park.putObject(object, PlayBoard.getSupplyPark(color))
                    elseif Types.isDreadnought(object, color) then
                        Park.putObject(object, Combat.dreadnoughtParks[color])
                    elseif Types.isSandworm(object, color) then
                        object.destruct()
                    elseif Types.isSardaukarCommander(object, color) then
                        if PlayBoard.isRival(color) then
                            PlayBoard.getPlayBoard(color):trash(object)
                        else
                            Park.putObject(object, PlayBoard.getSardaukarCommanderPark(color))
                        end
                    elseif Types.isAgentUnit(object, color) then
                        Park.putObject(object, PlayBoard.getAgentPark(color))
                    end
                end
            end
        end
    end)

    Helper.registerEventListener("phaseEnd", function (phase)
        if phase == "combat" then
            if Combat.isFormalCombatPhaseEnabled() then
                Music.play("turn")
            end
        elseif phase == "combatEnd" then
            for _, bannerZone in ipairs(MainBoard.getBannerZones()) do
                local dreadnought = MainBoard.getControllingDreadnought(bannerZone)
                -- Only recall locked controlling dreadnoughts.
                if dreadnought and dreadnought.getLock() then
                    dreadnought.setLock(false)
                    for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
                        if dreadnought.hasTag(color) then
                            Park.putObject(dreadnought, Combat.dreadnoughtParks[color])
                        end
                    end
                end
            end
            Action.unsetContext("combat")
        elseif phase == "recall" then
            Helper.shuffle(Combat.battlegroundPark.slots)
        end
    end)
end

---@param settings Settings
function Combat._processSnapPoints(settings)
    Combat.garrisonParks = {}
    Combat.dreadnoughtParks = {}
    Combat.makerHookPositions = {}

    local createZone = function (position, scale)
        local zone = Helper.markAsTransient(spawnObject({
            type = 'ScriptingTrigger',
            position = position,
            scale = scale,
        }))
        ---@cast zone Zone
        return zone
    end

    MainBoard.collectSnapPointsOnAllBoards(settings, {

        conflictDeck = function (_, position)
            Combat.conflictDeckZone = createZone(position, Vector(2, 1, 3))
        end,

        conflictDiscard = function (_, position)
            Combat.conflictDiscardZone = createZone(position, Vector(2, 1, 3))
        end,

        garrison = function (name, position)
            local color = name:gsub("^%l", string.upper)
            Combat.garrisonParks[color] = Combat._createGarrisonPark(color, position)
            if settings.ix then
                Combat.dreadnoughtParks[color] = Combat._createDreadnoughtPark(color, position)
            end
        end,

        makerHook = function (name, position)
            local color = name:gsub("^%l", string.upper)
            Combat.makerHookPositions[color] = position
            Helper.createTransientAnchor(color .. "MakerHook", position - Vector(0, 0.5, 0)).doAfter(function (anchor)
                local tags = { "MakerHook" }
                local snapPoints = { Helper.createRelativeSnapPoint(anchor, position, false, tags) }
                anchor.setSnapPoints(snapPoints)
            end)
        end,

        battlefield = function (name, position)
            -- Skipping player battlegrounds.
            if name == "" then
                Combat.battlegroundPark = Combat._createBattlegroundPark(position)
            end
        end,

        swormasterBonusToken = function (name, position)
            local color = name:gsub("^%l", string.upper)
            -- TODO
        end,

        victoryTokenRoom = function (name, position)
            Combat.rewardTokenZone = createZone(position, Vector(7, 2, 1))
        end,

        combatMarkerRoom = function (name, position)
            Combat.noCombatForcePositions = Vector(position.x, Board.onMainBoard(0), position.z)
            Combat.combatForcePositions = {}
            for i = 0, 19 do
                Combat.combatForcePositions[i + 1] = Vector(
                    position.x + 1.6 + (i % 10) * 0.98,
                    Board.onMainBoard(0),
                    position.z + 0.64 - math.floor(i / 10) * 1.03
                )
            end
        end,
    })
end

---@return boolean
function Combat.isFormalCombatPhaseEnabled()
    return Combat.formalCombatPhase
end

function Combat._setUpConflict()
    if Helper.getCardCount(Helper.getDeckOrCard(Combat.conflictDeckZone)) == 0 then
        return
    end

    Helper.moveCardFromZone(Combat.conflictDeckZone, Combat.conflictDiscardZone.getPosition() + Vector(0, 1, 0), nil, true, true).doAfter(function (card)
        assert(card)
        local cardName = Helper.getID(card)

        local i = 0
        local tokens = Combat.victoryPointTokenBag.getObjects()
        for _, token in ipairs(tokens) do
            assert(token)
            if cardName == Helper.getID(token) then
                local origin = Combat.rewardTokenZone.getPosition()
                local position = origin + Vector(0.5 - (i % 2), 0.5 + math.floor(i / 2), 0)
                i = i + 1
                Combat.victoryPointTokenBag.takeObject({
                    position = position,
                    rotation = Vector(0, 180, 0),
                    smooth = true,
                    guid = token.guid,
                })
            end
        end

        local objective = ConflictCard.getObjective(cardName)
        if objective then
            local bag = Combat.objectiveTokenBags[objective]
            assert(bag, objective)
            local origin = Combat.rewardTokenZone.getPosition()
            local position = origin + Vector(0.5 - 3, 0.5, 0)
            bag.takeObject({
                position = position,
                rotation = Vector(0, 180, 0),
                smooth = true,
                callback_function = function (token)
                    token.setGMNotes(cardName)
                    token.setName(I18N(cardName))
                end
            })
        end

        local controlableSpace = Combat.findControlableSpaceFromConflictName(cardName)
        if controlableSpace then
            local color = MainBoard.getControllingPlayer(controlableSpace)
            if color then
                Park.transfer(1, PlayBoard.getSupplyPark(color), Combat.getBattlegroundPark())
            end
        end

        broadcastToAll(I18N("announceCombat", { combat = I18N(Helper.getID(card)) }), "Orange")
    end)
end

---@param conflictName string
---@return Zone?
function Combat.findControlableSpaceFromConflictName(conflictName)
    assert(conflictName)
    for _, controlableSpaceName in ipairs({ "imperialBasin", "arrakeen", "spiceRefinery" }) do
        if conflictName:find(controlableSpaceName:gsub("^%l", string.upper)) then
            return MainBoard.findControlableSpace(controlableSpaceName)
        end
    end
    return nil
end

---@param zone Zone
---@param object Object
function Combat.onObjectEnterZone(zone, object)
    if Helper.isNil(zone) or Helper.isNil(object) then
        return
    end
    if zone == Combat.combatCenterZone and Types.isUnit(object) then
        Combat._updateCombatForces(Combat._calculateCombatForces())
    end
end

---@param zone Zone
---@param object Object
function Combat.onObjectLeaveZone(zone, object)
    if Helper.isNil(zone) or Helper.isNil(object) then
        return
    end
    if zone == Combat.combatCenterZone and Types.isUnit(object) then
        Combat._updateCombatForces(Combat._calculateCombatForces())
    end
end

---@param color PlayerColor
---@param position Vector
---@return Park
function Combat._createGarrisonPark(color, position)
    local slots = {}
    for i = 1, 4 do
        for j = 3, 1, -1 do
            local x = (PlayBoard.isLeft(color) and (2.5 - i) or (i - 2.5)) * 0.45
            local z = (j - 2) * 0.45
            local slot = position + Vector(x, 0, z)
            slot:setAt('y', Board.onMainBoard(0))
            table.insert(slots, slot)
        end
    end

    local zone = Helper.markAsTransient(spawnObject({
        type = 'ScriptingTrigger',
        position = position,
        scale = Vector(2.3, 1, 2.3),
    }))

    local park = Park.createPark(
        color .. "Garrison",
        slots,
        Vector(0, 0, 0),
        { zone },
        { "Troop", color },
        nil,
        false,
        true)
    park.avoidStacking = true

    Helper.createTransientAnchor("Garrison anchor", position - Vector(0, 0.5, 0)).doAfter(function (anchor)
        park.anchor = anchor
        Combat._createButton(color, park)
    end)

    return park
end

---@param color PlayerColor
---@param origin Vector
---@return Park
function Combat._createDreadnoughtPark(color, origin)
    local dir = PlayBoard.isLeft(color) and -1 or 1
    -- Moved in Uprising to make room to the sandworm hook.
    local slots = {
        origin + Vector(0.3 * dir, 0.2, -1.0),
        origin + Vector(0.9 * dir, 0.2, -1.0),
    }

    local zone = Park.createTransientBoundingZone(0, Vector(0.5, 2, 0.5), slots)

    local park = Park.createPark(
        color .. "DreadnoughtGarrison",
        slots,
        Vector(0, 0, 0),
        { zone },
        { "Dreadnought", color },
        nil,
        false,
        true)

    return park
end

---@param position Vector
---@return Park
function Combat._createBattlegroundPark(position)
    local slots = {}
    for j = 1, 8 do
        for i = 1, 8 do
            local x = (i - 4.5) * 0.5
            local z = (j - 4.5) * 0.5
            local slot = position + Vector(x, 0, z)
            table.insert(slots, slot)
        end
    end
    Helper.shuffle(slots)

    local zone = Helper.markAsTransient(spawnObject({
        type = 'ScriptingTrigger',
        position = position,
        scale = Vector(6.6, 3, 5), -- The height at 3 is to avoid oscillationg scores with the jumping sandworms.
    }))
    ---@cast zone Zone
    Combat.combatCenterZone = zone

    local park = Park.createPark(
        "Battleground",
        slots,
        nil,
        { Combat.combatCenterZone },
        { "Troop", "Dreadnought", "Sandworm", "SardaukarCommander" },
        nil,
        false,
        true)
    park.tagUnion = true
    park.avoidStacking = true

    return park
end

---@param color PlayerColor
---@param park Park
function Combat._createButton(color, park)
    local position = park.anchor.getPosition()
    local areaColor = Color.fromString(color)
    areaColor:setAt('a', 0.3)
    Helper.createAbsoluteButtonWithRoundness(park.anchor, 7, {
        click_function = Helper.registerGlobalCallback(function (_, playerColor, altClick)
            if playerColor == color then
                if altClick then
                    Action.troops(color, "garrison", "supply", 1)
                else
                    Action.troops(color, "supply", "garrison", 1)
                end
            end
        end),
        position = Vector(position.x, Board.onMainBoard(0.05), position.z),
        width = 1200,
        height = 1200,
        color = areaColor,
        tooltip = I18N("troopEdit")
    })
end

---@param color PlayerColor
---@return Park
function Combat.getGarrisonPark(color)
    return Combat.garrisonParks[color]
end

---@param color PlayerColor
---@return Park
function Combat.getDreadnoughtPark(color)
    return Combat.dreadnoughtParks[color]
end

---@return Park
function Combat.getBattlegroundPark()
    return Combat.battlegroundPark
end

---@param color PlayerColor
---@param strength integer
function Combat.setDreadnoughtStrength(color, strength)
    Combat.dreadnoughtStrengths[color] = strength
end

---@param color PlayerColor
---@return boolean
function Combat.isInCombat(color)
    for _, object in ipairs(Combat.combatCenterZone.getObjects()) do
        if Types.isUnit(object, color) then
            return true
        end
    end
    return false
end

---@param ranking table<PlayerColor, { value: integer, exAequo: boolean }>
---@return PlayerColor[]
function Combat._calculateOutcomeTurnSequence(ranking)
    local distinctRanking = {}
    for i, color in ipairs(TurnControl.getPhaseTurnSequence()) do
        local rank = ranking[color]
        if rank then
            distinctRanking[color] = rank.value + i * 0.1
        end
    end

    local combatEndTurnSequence = Helper.getKeys(ranking)
    table.sort(combatEndTurnSequence, function (c1, c2)
        return distinctRanking[c1] < distinctRanking[c2]
    end)

    return combatEndTurnSequence
end

---@param color PlayerColor
---@return { value: integer, exAequo: boolean }
function Combat.getRank(color)
    return Combat.ranking[color]
end

---@param forces table<PlayerColor, integer>
---@return table<PlayerColor, { value: integer, exAequo: boolean }>
function Combat._calculateRanking(forces)
    return Combat.__calculateRanking(forces, PlayBoard.getActivePlayBoardColors())
end

---@param forces table<PlayerColor, integer>
---@param activeColors PlayerColor[]
---@return table<PlayerColor, { value: integer, exAequo: boolean }>
function Combat.__calculateRanking(forces, activeColors)
    local ranking = {}

    local remainingForces = Helper.shallowCopy(forces)
    local potentialWinnerCount = #Helper.getKeys(activeColors) - 1

    local rank = 1
    while potentialWinnerCount > 0 do
        local rankWinners = {}
        local maxForce = 1
        for _, color in ipairs(activeColors) do
            if remainingForces[color] then
                if remainingForces[color] > maxForce then
                    rankWinners = { color }
                    maxForce = remainingForces[color]
                elseif remainingForces[color] == maxForce then
                    table.insert(rankWinners, color)
                end
            end
        end

        if #rankWinners == 0 then
            break;
        elseif #rankWinners > 1 then
            rank = rank + 1
        end

        if rank < 4 then
            for _, color in ipairs(rankWinners) do
                ranking[color] = { value = rank, exAequo = #rankWinners }
                potentialWinnerCount = potentialWinnerCount - 1
                remainingForces[color] = nil
            end
            rank = rank + 1
        else
            break
        end
    end

    return ranking
end

---@param filter? fun(object: Object): boolean
---@return table<PlayerColor, integer>
function Combat.getUnitCounts(filter)
    local unitCounts = {}
    for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
        unitCounts[color] = 0
        for _, object in ipairs(Combat.combatCenterZone.getObjects()) do
            if Types.isUnit(object, color) and (not filter or filter(object)) then
                unitCounts[color] = unitCounts[color] + 1
            end
        end
    end
    return unitCounts
end

---@return table<PlayerColor, integer>
function Combat._calculateCombatForces()
    local forces = {}
    for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
        forces[color] = Combat.calculateCombatForce(color)
    end
    return forces
end

---@param color PlayerColor
---@return integer
function Combat.calculateCombatForce(color)
    local force = 0
    for _, object in ipairs(Combat.combatCenterZone.getObjects()) do
        if Types.isUnit(object, color) then
            if Types.isTroop(object, color) then
                force = force + 2
            elseif Types.isDreadnought(object, color) then
                force = force + (Combat.dreadnoughtStrengths[color] or 3)
            elseif Types.isSandworm(object, color) then
                force = force + 3
            elseif Types.isSardaukarCommander(object, color) then
                force = force + (PlayBoard.isRival(color) and 4 or 2)
            elseif Types.isAgentUnit(object, color) then
                force = force + (PlayBoard.hasSwordmaster(color) and 3 or 2)
            else
                error("Unknown unit type: " .. object.getGUID())
            end
        end
    end

    if force > 0 then
        force = force + PlayBoard.getResource(color, "strength"):get()
        if TurnControl.getPlayerCount() == 6 and Commander.isAlly(color) then
            local commander = Commander.getCommander(color)
            if commander and color == Commander.getActivatedAlly(commander) then
                force = force + PlayBoard.getResource(commander, "strength"):get()
            end
        end
    end

    return force
end

---@param forces table<PlayerColor, integer>
function Combat._updateCombatForces(forces)
    local occupations = {}

    for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
        if not Commander.isCommander(color) then
            local force = forces[color]

            local minorForce = force > 0 and (force - 1) % 20 + 1 or 0
            local majorForce = force > 0 and math.floor((force - 1) / 20) or 0

            occupations[minorForce] = (occupations[minorForce] or 0) + 1
            local heightOffset = Vector(
                0,
                (occupations[minorForce] - 1) * 0.30
                    + math.min(1, majorForce) * 0.30, -- Last part is here because the rotation center for the tokens is not the barycenter.
                0)

            local forceMarker = PlayBoard.getContent(color).forceMarker
            assert(Combat.combatForcePositions, color)
            if force > 0 then
                forceMarker.setPositionSmooth(Combat.combatForcePositions[minorForce] + heightOffset, false, false)
                forceMarker.setRotationSmooth(Vector(0, 180 + 90 * math.floor(majorForce / 2), 180 * math.min(1, majorForce)))

                forces[color] = force
            else
                forceMarker.setPositionSmooth(Combat.noCombatForcePositions + heightOffset, false, false)
                forceMarker.setRotationSmooth(Vector(0, 180, 0))
            end
        end
    end

    Helper.emitEvent("combatUpdate", forces)
end

---@param color PlayerColor
---@return integer
function Combat.getNumberOfDreadnoughtsInConflict(color)
    return #Combat.getDreadnoughtsInConflict(color)
end

---@param color PlayerColor
---@return Object[]
function Combat.getDreadnoughtsInConflict(color)
    local dreadnoughts = {}
    for _, object in ipairs(Combat.combatCenterZone.getObjects()) do
        if Types.isDreadnought(object, color) then
            table.insert(dreadnoughts, object)
        end
    end
    return dreadnoughts
end

---@return string
function Combat.getCurrentConflictName()
    local deckOrCard = Helper.getDeckOrCard(Combat.conflictDiscardZone)
    assert(deckOrCard)
    if deckOrCard.type == "Deck" then
        local objects = deckOrCard.getObjects()
        return Helper.getID(objects[#objects])
    else
        return Helper.getID(deckOrCard)
    end
end

---@return boolean
function Combat.isCurrentConflictBehindTheWall()
    local conflictName = Combat.getCurrentConflictName()
    return ConflictCard.isBehindTheWall(conflictName)
end

---@return integer
function Combat.getCurrentConflictLevel()
    return ConflictCard.getLevel(Combat.getCurrentConflictName())
end

---@param color PlayerColor
---@param name string
---@param count integer
---@return boolean
function Combat.gainVictoryPoint(color, name, count)

    -- We memoize the tokens granted in fast succession to avoid returning the same twice or more.
    if not Combat.grantedTokens then
        Combat.grantedTokens = {}
        Helper.onceTimeElapsed(0.25).doAfter(function ()
            Combat.grantedTokens = nil
        end)
    end

    local remaining = count or 1
    for _, object in ipairs(Combat.rewardTokenZone.getObjects()) do
        if Types.isVictoryPointToken(object) and Helper.getID(object) == name and not Combat.grantedTokens[object] then
            Combat.grantedTokens[object] = true
            PlayBoard.grantScoreToken(color, object)
            remaining = remaining - 1
            if remaining == 0 then
                return true
            end
        end
    end

    return false
end

---@param color PlayerColor
---@param initialObjective string
---@param ignoreExisting? boolean
---@return Continuation
function Combat.gainObjective(color, initialObjective, ignoreExisting)
    local objective = initialObjective
    if Helper.isElementOf(initialObjective, { "muadDib", "crysknife" }) and PlayBoard.hasTech(color, "ornithopterFleet") then
        objective = "ornithopter"
    end

    local continuation = Helper.createContinuation("Combat.gainObjective")
    local position = PlayBoard.getObjectiveStackPosition(color, objective)
    local tag = Helper.toPascalCase(initialObjective, "ObjectiveToken")

    if not ignoreExisting then
        for _, object in ipairs(Combat.rewardTokenZone.getObjects()) do
            if object.hasTag(tag) then
                if initialObjective == objective then
                    object.setPositionSmooth(position + Vector(0, 1, 0))
                    Helper.onceMotionless(object).doAfter(continuation.run)
                    return continuation
                else
                    object.destruct()
                    break
                end
            end
        end
    end

    local bag = Combat.objectiveTokenBags[objective]
    assert(bag, objective)
    bag.takeObject({
        position = position + Vector(0, 1, 0),
        rotation = Vector(0, 180, 0),
        smooth = true,
        callback_function = function (token)
            Helper.onceMotionless(token).doAfter(continuation.run)
        end
    })

    return continuation
end

---@param turnSequence PlayerColor[]
---@param ranking table<PlayerColor, { value: integer, exAequo: boolean } >
function Combat.showRanking(turnSequence, ranking)
    local rankNames = { "first", "second", "third", "fourth" }
    for _, color in ipairs(turnSequence) do
        local rank = ranking[color]
        local key = rankNames[rank.value] .. (rank.exAequo > 1 and "ExAequo" or "") .. "InCombat"
        printToAll(I18N(key, { leader = PlayBoard.getLeaderName(color) }), color)
    end
end

---@param color PlayerColor
---@return Vector
function Combat.getMakerHookPosition(color)
    return Combat.makerHookPositions[color]
end

---@param color PlayerColor
---@param count integer
function Combat.callSandworm(color, count)
    local battlegroundPark = Combat.getBattlegroundPark()
    if count < 0 then
        local remaining = -count
        for _, object in ipairs(Park.getObjects(battlegroundPark)) do
            if Types.isSandworm(object, color) then
                object.destruct()
                remaining = remaining - 1
                if remaining == 0 then
                    break
                end
            end
        end
    else
        for _ = 1, count do
            local sandworm = Combat.protoSandworm.clone({
                position = Park.getPosition(battlegroundPark) - Vector(0, 20, 0)
            })
            sandworm.addTag("Sandworm")
            sandworm.addTag(color)
            sandworm.setRotation(Vector(0, math.random(360), 0))
            sandworm.setScale(sandworm.getScale():copy():scale(1/1.5))
            sandworm.setColorTint(color)
            Park.putObject(sandworm, battlegroundPark)
        end
    end
end

---@param color PlayerColor
---@return boolean
function Combat.hasAnySandworm(color)
    local battlegroundPark = Combat.getBattlegroundPark()
    for _, object in ipairs(Park.getObjects(battlegroundPark)) do
        if Types.isSandworm(object, color) then
            return true
        end
    end
    return false
end

---@param color PlayerColor
---@return boolean
function Combat.hasAnySardaukarCommander(color)
    local battlegroundPark = Combat.getBattlegroundPark()
    for _, object in ipairs(Park.getObjects(battlegroundPark)) do
        if Types.isSardaukarCommander(object, color) then
            return true
        end
    end
    return false
end

---@return Zone
function Combat.getCombatCenterZone()
    return Combat.combatCenterZone
end

return Combat
