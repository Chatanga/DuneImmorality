local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")
local I18N = require("utils.I18N")

local PlayBoard = Module.lazyRequire("PlayBoard")
local Action = Module.lazyRequire("Action")
local Deck = Module.lazyRequire("Deck")
local Types = Module.lazyRequire("Types")
local TurnControl = Module.lazyRequire("TurnControl")
local MainBoard = Module.lazyRequire("MainBoard")
local Music = Module.lazyRequire("Music")
local ConflictCard = Module.lazyRequire("ConflictCard")

local Combat = {
    -- Temporary structure (set to nil *after* loading).
    unresolvedContent = {
        conflictDeckZone = "07e239",
        conflictDiscardZone = "43f00f",
        combatCenterZone = "6d632e",
        combatTokenZone = "1d4424",
        rewardTokenZone = "25b541",
        victoryPointTokenBag = "86dc4e"
    },
    origins = {
        Green = Vector(8.15, 0.85, -7.65),
        Yellow = Vector(8.15, 0.85, -10.35),
        Blue = Vector(1.55, 0.85, -10.35),
        Red = Vector(1.55, 0.85, -7.65),
    },
    victoryPointTokenPositions = {},
    dreadnoughtStrengths = {},
    ranking = {}
}

function Combat.onLoad(state)
    Helper.append(Combat, Helper.resolveGUIDs(false, Combat.unresolvedContent))

    local origin = Combat.combatTokenZone.getPosition()
    Combat.noCombatForcePositions = Vector(origin.x, 0.66, origin.z)
    Combat.combatForcePositions = {}
    for i = 0, 19 do
        Combat.combatForcePositions[i + 1] = Vector(
            origin.x - 0.4 + (i % 10) * 0.9,
            0.66,
            origin.z - 0.93 - math.floor(i / 10) * 1.03
        )
    end

    if state.settings and state.Combat then
        Combat._transientSetUp(state.settings)
        Combat.dreadnoughtStrengths = state.Combat.dreadnoughtStrengths
        Combat.ranking = state.Combat.ranking
    end
end

---
function Combat.onSave(state)
    state.Combat = {
        dreadnoughtStrengths = Combat.dreadnoughtStrengths,
        ranking = Combat.ranking,
    }
end

---
function Combat.setUp(settings)
    Combat._transientSetUp(settings)
    assert(Combat.conflictDeckZone)
    return Deck.generateConflictDeck(Combat.conflictDeckZone, settings.riseOfIx, settings.epicMode, settings.numberOfPlayers)
end

---
function Combat._transientSetUp(settings)
    Combat.formalCombatPhase = settings.formalCombatPhase

    Combat.garrisonParks = {}
    for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
        Combat.garrisonParks[color] = Combat._createGarrisonPark(color)
    end

    if settings.riseOfIx then
        Combat.dreadnoughtParks = {}
        for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
            Combat.dreadnoughtParks[color] = Combat._createDreadnoughtPark(color)
        end
    end

    Combat.battlegroundPark = Combat._createBattlegroundPark()

    Helper.registerEventListener("strengthValueChanged", function ()
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
                if Types.isVictoryPointToken(object) then
                    MainBoard.trash(object)
                end
            end
            -- Recalling units (troops and dreadnoughts) in the combat (not in a controlable space).
            for _, object in ipairs(Combat.combatCenterZone.getObjects()) do
                for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
                    if Types.isTroop(object, color) then
                        Park.putObject(object, PlayBoard.getSupplyPark(color))
                    elseif Types.isDreadnought(object, color) then
                        Park.putObject(object, Combat.dreadnoughtParks[color])
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
        end
    end)
end

---
function Combat.isFormalCombatPhaseEnabled()
    return Combat.formalCombatPhase
end

---
function Combat._setUpConflict()
    if Helper.getCardCount(Helper.getDeckOrCard(Combat.conflictDeckZone)) == 0 then
        return
    end

    Helper.moveCardFromZone(Combat.conflictDeckZone, Combat.conflictDiscardZone.getPosition() + Vector(0, 1, 0), nil, true, true).doAfter(function (card)
        assert(card)
        local cardName = Helper.getID(card)

        local i = 0
        local tokens = Combat.victoryPointTokenBag.getObjects()
        for _, token in pairs(tokens) do
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

        local controlableSpace = MainBoard.findControlableSpaceFromConflictName(cardName)
        if controlableSpace then
            local color = MainBoard.getControllingPlayer(controlableSpace)
            if color then
                Park.transfert(1, PlayBoard.getSupplyPark(color), Combat.getBattlegroundPark())
            end
        end

        broadcastToAll(I18N("announceCombat", { combat = I18N(Helper.getID(card)) }), "Orange")
    end)
end

---
function Combat.onObjectEnterZone(zone, object)
    if zone == Combat.combatCenterZone and Types.isUnit(object) then
        Combat._updateCombatForces(Combat._calculateCombatForces())
    end
end

---
function Combat.onObjectLeaveZone(zone, object)
    if zone == Combat.combatCenterZone and Types.isUnit(object) then
        Combat._updateCombatForces(Combat._calculateCombatForces())
    end
end

---
function Combat._createGarrisonPark(color)
    local position = Combat.origins[color]
    local slots = {}
    for j = 3, 1, -1 do
        for i = 1, 4 do
            local x = (i - 2.5) * 0.45
            local z = (j - 2) * 0.45
            local slot = position + Vector(x, 0, z)
            table.insert(slots, slot)
        end
    end

    local zone = Park.createTransientBoundingZone(0, Vector(0.35, 0.35, 0.35), slots)

    local park = Park.createPark(
        color .. "Garrison",
        slots,
        Vector(0, 0, 0),
        { zone },
        { "Troop", color },
        nil,
        false,
        true)

    -- FIXME Hardcoded height, use an existing parent anchor.
    Helper.createTransientAnchor("Garrison anchor", Vector(position.x, 0.65, position.z)).doAfter(function (anchor)
        park.anchor = anchor
        Combat._createButton(color, park)
    end)

    return park
end

---
function Combat._createDreadnoughtPark(color)
    local origin = Combat.origins[color]
    local center = Helper.getCenter(Helper.getValues(Combat.origins))
    local dir = PlayBoard.isLeft(color) and -1 or 1
    local slots = {
        origin + Vector(1.3 * dir, 0, 0.9),
        origin + Vector(1.3 * dir, 0, -0.9),
    }

    local zone = Park.createTransientBoundingZone(0, Vector(0.5, 3, 0.5), slots)

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

---
function Combat._createBattlegroundPark()
    local slots = {}
    for j = 1, 8 do
        for i = 1, 8 do
            local x = (i - 4.5) * 0.5
            local z = (j - 4.5) * 0.5
            local slot = Combat.combatCenterZone.getPosition() + Vector(x, 0, z)
            table.insert(slots, slot)
        end
    end
    Helper.shuffle(slots)

    local zone = Combat.combatCenterZone

    local park = Park.createPark(
        "Battleground",
        slots,
        nil,
        { Combat.combatCenterZone },
        { "Troop", "Dreadnought" },
        nil,
        false,
        true)
    park.tagUnion = true

    return park
end

---
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
        position = Vector(position.x, 0.7, position.z),
        width = 1200,
        height = 1200,
        color = areaColor,
        tooltip = I18N("troopEdit")
    })
end

---
function Combat.getGarrisonPark(color)
    return Combat.garrisonParks[color]
end

---
function Combat.getDreadnoughtPark(color)
    return Combat.dreadnoughtParks[color]
end

---
function Combat.getBattlegroundPark()
    return Combat.battlegroundPark
end

---
function Combat.setDreadnoughtStrength(color, strength)
    Combat.dreadnoughtStrengths[color] = strength
end

---
function Combat.isInCombat(color)
    for _, object in ipairs(Combat.combatCenterZone.getObjects()) do
        if Types.isUnit(object, color) then
            return true
        end
    end
    return false
end

---
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

---
function Combat.getRank(color)
    return Combat.ranking[color]
end

---
function Combat._calculateRanking(forces)
    return Combat.__calculateRanking(forces, PlayBoard.getActivePlayBoardColors())
end

---
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

---
function Combat.getUnitCounts()
    local unitCounts = {}
    for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
        unitCounts[color] = 0
        for _, object in ipairs(Combat.combatCenterZone.getObjects()) do
            if Types.isUnit(object, color) then
                unitCounts[color] = unitCounts[color] + 1
            end
        end
    end
    return unitCounts
end

---
function Combat._calculateCombatForces()
    local forces = {}
    for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
        forces[color] = Combat.calculateCombatForce(color)
    end
    return forces
end

---
function Combat.calculateCombatForce(color)
    local force = 0
    for _, object in ipairs(Combat.combatCenterZone.getObjects()) do
        if Types.isUnit(object, color) then
            if Types.isTroop(object, color) then
                force = force + 2
            elseif Types.isDreadnought(object, color) then
                force = force + (Combat.dreadnoughtStrengths[color] or 3)
            else
                error("Unknown unit type: " .. object.getGUID())
            end
        end
    end

    if force > 0 then
        force = force + PlayBoard.getResource(color, "strength"):get()
    end

    return force
end

---
function Combat._updateCombatForces(forces)
    local occupations = {}

    -- TODO Better having a zone with filtering tags.
    for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
        local force = forces[color]

        local minorForce = force > 0 and (force - 1) % 20 + 1 or 0
        local majorForce = force > 0 and math.floor((force - 1) / 20) or 0

        occupations[minorForce] = (occupations[minorForce] or 0) + 1
        local heightOffset = Vector(
            0,
            (occupations[minorForce] - 1) * 0.35
                + math.min(1, majorForce) * 0.30, -- Last part is here because the rotation center for the tokent is not the barycenter.
            0)

        local forceMarker = PlayBoard.getContent(color).forceMarker
        if force > 0 then
            forceMarker.setPositionSmooth(Combat.combatForcePositions[minorForce] + heightOffset, false, false)
            forceMarker.setRotationSmooth(Vector(0, 180 + 90 * math.floor(majorForce / 2), 180 * math.min(1, majorForce)))

            forces[color] = force
        else
            forceMarker.setPositionSmooth(Combat.noCombatForcePositions + heightOffset, false, false)
            forceMarker.setRotationSmooth(Vector(0, 180, 0))
        end
    end

    Helper.emitEvent("combatUpdate", forces)
end

---
function Combat.getNumberOfDreadnoughtsInConflict(color)
    return #Combat.getDreadnoughtsInConflict(color)
end

---
function Combat.getDreadnoughtsInConflict(color)
    local dreadnoughts = {}
    for _, object in ipairs(Combat.combatCenterZone.getObjects()) do
        if Types.isDreadnought(object, color) then
            table.insert(dreadnoughts, object)
        end
    end
    return dreadnoughts
end

---
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

---
function Combat.getCurrentConflictLevel()
    return ConflictCard.getLevel(Combat.getCurrentConflictName())
end

---
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

---
function Combat.showRanking(turnSequence, ranking)
    local rankNames = { "first", "second", "third", "fourth" }
    for _, color in ipairs(turnSequence) do
        local rank = ranking[color]
        local key = rankNames[rank.value] .. (rank.exAequo > 1 and "ExAequo" or "") .. "InCombat"
        printToAll(I18N(key, { leader = PlayBoard.getLeaderName(color) }), color)
    end
end

---
function Combat.getCombatCenterZone()
    return Combat.combatCenterZone
end

return Combat
