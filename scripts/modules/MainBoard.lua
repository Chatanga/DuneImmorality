local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")
local I18N = require("utils.I18N")
local Dialog = require("utils.Dialog")

local Types = Module.lazyRequire("Types")
local PlayBoard = Module.lazyRequire("PlayBoard")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")
local ShippingTrack = Module.lazyRequire("ShippingTrack")
local TechMarket = Module.lazyRequire("TechMarket")
local Combat = Module.lazyRequire("Combat")
local Resource = Module.lazyRequire("Resource")
local Action = Module.lazyRequire("Action")
local TurnControl = Module.lazyRequire("TurnControl")
local Hagal = Module.lazyRequire("Hagal")
local DynamicBonus = Module.lazyRequire("DynamicBonus")
local Board = Module.lazyRequire("Board")

local MainBoard = {
    spaceDetails = {
        conspire = { group = "emperor" },
        wealth = { group = "emperor" },

        heighliner = { group = "spacingGuild" },
        foldspace = { group = "spacingGuild" },

        selectiveBreeding = { group = "beneGesserit" },
        secrets = { group = "beneGesserit" },

        hardyWarriors = { group = "fremen", combat = true },
        stillsuits = { group = "fremen", combat = true },

        highCouncil = { group = "landsraad" },
        mentat = { group = "landsraad" },
        swordmaster = { group = "landsraad" },
        hallOfOratory = { group = "landsraad" },
        rallyTroops = { group = "landsraad" },

        techNegotiation = { group = "landsraad" },
        dreadnought = { group = "landsraad" },

        secureContract = { group = "choam" },
        sellMelange = { group = "choam" },

        smuggling = { group = "choam" },
        interstellarShipping = { group = "choam" },

        sietchTabr = { group = "city", combat = true },
        arrakeen = { group = "city", combat = true },
        carthag = { group = "city", combat = true },
        researchStation = { group = "city", combat = true },

        theGreatFlat = { group = "desert", combat = true },
        haggaBasin = { group = "desert", combat = true },
        imperialBasin = { group = "desert", combat = true },

        tuekSietch = { group = "desert", combat = true },
    }
}

---@alias Space {
--- name: string,
--- position: Vector,
--- zone: Zone,
--- park: Park }

---@param state table
function MainBoard.onLoad(state)
    Helper.append(MainBoard, Helper.resolveGUIDs(false, {
        immortalityPatch = "efcd46",
        spiceBonusTokens = {
            theGreatFlat = "fff18c",
            haggaBasin = "e7dac1",
            imperialBasin = "be19c0",
            tuekSietch = "e54fa3",
        },
        firstPlayerMarker = "1f5576",
        mentat = "c2a908",
    }))
    MainBoard.spiceBonuses = {}

    Helper.forEachValue(MainBoard.spiceBonusTokens, Helper.noPhysicsNorPlay)

    if state.settings and state.MainBoard then
        MainBoard.mainBoard = Board.getBoard("mainBoard")
        MainBoard.topRightBoard = Board.getBoard("defaultBoard") or Board.getBoard("shippingBoard")
        MainBoard.tuekSietchBoard = Board.getBoard("tuekSietchBoard")

        MainBoard._transientSetUp(state.settings)

        for name, resource in pairs(MainBoard.spiceBonuses) do
            local value = state.MainBoard.spiceBonuses[name]
            resource:set(value)
        end
    end
end

---@param state table
function MainBoard.onSave(state)
    state.MainBoard = {
        spiceBonuses = Helper.mapValues(MainBoard.spiceBonuses, function (resource)
            return resource:get()
        end),
    }
end

---@param settings Settings
function MainBoard.setUp(settings)
    MainBoard.mainBoard = Board.selectBoard("mainBoard", I18N.getLocale(), false)

    if settings.riseOfIx then
        MainBoard.topRightBoard = Board.selectBoard("shippingBoard", I18N.getLocale(), false)
    else
        MainBoard.topRightBoard = Board.selectBoard("defaultBoard", I18N.getLocale(), false)
    end

    if settings.immortality then
    else
        MainBoard.immortalityPatch.destruct()
        MainBoard.immortalityPatch = nil
    end

    MainBoard.tuekSietchBoard = Board.selectBoard("tuekSietchBoard", I18N.getLocale(), false)
    MainBoard.tuekSietchBoard.createButton({
        click_function = Helper.registerGlobalCallback(),
        label = I18N("tuekBoardRelocationMessage"),
        position = Vector(0, 0, 1.5),
        width = 0,
        height = 0,
        font_size = 100,
        font_color = "White"
    })
    -- Some part of the code locks the board right after its selection and I can't find where...
    Helper.onceTimeElapsed(1).doAfter(function ()
        Helper.physicsAndPlay(MainBoard.tuekSietchBoard)
    end)

    MainBoard._transientSetUp(settings)
end

---@param settings Settings
function MainBoard._transientSetUp(settings)
    MainBoard._processSnapPoints(settings)

    MainBoard._createRoundIndicator()

    Helper.registerEventListener("phaseStart", function (phase)
        if phase == "gameStart" then
            if MainBoard.tuekSietchBoard and MainBoard.tuekSietchBoard.interactable then
                MainBoard.tuekSietchBoard.destruct()
                MainBoard.tuekSietchBoard = nil
                Hagal.removeTuekSietch()
            end
        elseif phase == "makers" then
            for desert, _ in pairs(MainBoard.spiceBonusTokens) do
                local space = MainBoard.spaces[desert]
                if space then
                    local spiceBonus = MainBoard.spiceBonuses[desert]
                    if Park.isEmpty(space.park) then
                        spiceBonus:change(1)
                    end
                end
            end
        elseif phase == "recall" then
            -- Recalling mentat.
            if MainBoard.mentat.hasTag("notToBeRecalled") then
                MainBoard.mentat.removeTag("notToBeRecalled")
            else
                for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
                    MainBoard.mentat.removeTag(color)
                end
                MainBoard.mentat.setPosition(MainBoard.mentatZone.getPosition())
            end

            -- Recalling dreadnoughts in controlable spaces.
            for _, bannerZone in pairs(MainBoard.banners) do
                for _, dreadnought in ipairs(Helper.filter(bannerZone.getObjects(), Types.isDreadnought)) do
                    for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
                        if dreadnought.hasTag(color) then
                            if dreadnought.hasTag("toBeRecalled") then
                                dreadnought.removeTag("toBeRecalled")
                                Park.putObject(dreadnought, Combat.getDreadnoughtPark(color))
                            else
                                dreadnought.addTag("toBeRecalled")
                            end
                        end
                    end
                end
            end

            -- Recalling agents.
            for _, space in pairs(MainBoard.spaces) do
                if space.park then
                    for _, object in ipairs(Park.getObjects(space.park)) do
                        if object.hasTag("Agent") and not object.hasTag("Mentat") then
                            for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
                                if object.hasTag(color) then
                                    Park.putObject(object, PlayBoard.getAgentPark(color))
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

function MainBoard._createRoundIndicator()
    local primaryTable = getObjectFromGUID(GameTableGUIDs.primary)
    local origin = primaryTable.getPosition() + Vector(-5, 1.8, -16)

    Helper.createAbsoluteButtonWithRoundness(primaryTable, 1, {
        click_function = Helper.registerGlobalCallback(),
        label = I18N("roundNumber"),
        position = origin,
        width = 1000,
        height = 200,
        font_size = 140,
        color = { 0, 0, 0, 0 },
        font_color = { 1, 1, 1, 80 },
    })

    Helper.createAbsoluteButtonWithRoundness(primaryTable, 1, {
        click_function = Helper.registerGlobalCallback(),
        position = origin + Vector(0, 0, -1),
        width = 1000,
        height = 1000,
        font_size = 700,
        color = { 0, 0, 0, 0 },
        font_color = { 1, 1, 1, 80 },
    })

    local function updateContent()
        primaryTable.editButton({ index = 1, label = tostring(TurnControl.getCurrentRound()) })
    end

    Helper.registerEventListener("phaseStart", function (phase)
        if phase == "roundStart" then
            updateContent()
        end
    end)

    Helper.onceTimeElapsed(1).doAfter(updateContent)
end

---@param settings Settings
function MainBoard._processSnapPoints(settings)
    MainBoard.spaces = {}
    MainBoard.banners = {}

    local highCouncilSeats = MainBoard._doProcessSnapPoints(
        Helper.partialApply(MainBoard.collectSnapPointsOnAllBoards, settings))

    if #highCouncilSeats > 0 then
        MainBoard.highCouncilPark = Park.createPark(
            "HighCouncil",
            highCouncilSeats,
            Vector(0, 0, 0),
            { Park.createTransientBoundingZone(0, Vector(0.5, 1, 0.5), highCouncilSeats) },
            { "HighCouncilSeatToken" },
            nil,
            true,
            true)
    end
end

---@param settings Settings
function MainBoard.processTuekSnapPoints(settings)
    Helper.noPhysicsNorPlay(MainBoard.tuekSietchBoard)
    MainBoard.tuekSietchBoard.clearButtons()
    MainBoard._doProcessSnapPoints(MainBoard._collectSnapPointsOnTuekBoard)
end

---@param collect fun(net: CollectNet)
---@return table<integer, Vector>
function MainBoard._doProcessSnapPoints(collect)
    local highCouncilSeats = {}

    collect({

        seat = function (name, position)
            local str = name:sub(12)
            local index = tonumber(str)
            assert(index, "Not a number: " .. str)
            highCouncilSeats[index] = position
        end,

        space = function (name, position)
            MainBoard.spaces[name] = { name = name, position = position }
        end,

        spice = function (name, position)
            local token = MainBoard.spiceBonusTokens[name]
            assert(token, name)
            token.setPosition(position)
            token.setInvisibleTo({})
            Helper.noPhysics(token)
            MainBoard.spiceBonuses[name] = Resource.new(token, nil, "spice", 0, name)
        end,

        flag = function (name, position)
            local zone = spawnObject({
                type = 'ScriptingTrigger',
                position = position,
                scale = { 0.8, 1, 0.8 },
            })
            Helper.markAsTransient(zone)
            MainBoard.banners[name .. "BannerZone"] = zone
        end,

        slotMentat = function (_, position)
            MainBoard.mentatZone = spawnObject({
                type = 'ScriptingTrigger',
                position = position,
                scale = { 1, 3, 1.5 },
            })
            Helper.markAsTransient(MainBoard.mentatZone)
        end
    })

    -- A trick to ensure that parent space are created before
    -- their child spaces (which always have a longer name).
    local orderedSpaces = Helper.getValues(MainBoard.spaces)
    table.sort(orderedSpaces, function (s1, s2)
        return s1.name:len() < s2.name:len()
    end)
    for _, space in ipairs(orderedSpaces) do
        MainBoard._createSpaceButton(space)
    end

    for _, bannerZone in pairs(MainBoard.banners) do
        MainBoard._createBannerSpace(bannerZone)
    end

    return highCouncilSeats
end

---@param settings Settings
---@param net CollectNet
function MainBoard.collectSnapPointsOnAllBoards(settings, net)
    for _, board in ipairs(MainBoard._getAllBoards(settings)) do
        Helper.collectSnapPoints(board, net)
    end
end

---@param settings Settings
---@return Object[]
function MainBoard._getAllBoards(settings)
    local boards = { MainBoard.mainBoard, MainBoard.topRightBoard }

    if settings.riseOfIx then
        table.insert(boards, ShippingTrack.getBoard())
        table.insert(boards, TechMarket.getBoard())
    end

    -- The TeckMarket board with only the Ix ambassy contains no useful spaces here.

    return boards
end

---@param net CollectNet
function MainBoard._collectSnapPointsOnTuekBoard(net)
    Helper.collectSnapPoints(MainBoard.tuekSietchBoard, net)
end

---@return Park
function MainBoard.getHighCouncilSeatPark()
    return MainBoard.highCouncilPark
end

---@param controlableSpace Zone
---@param color PlayerColor
---@param onlyCleanUp? boolean
function MainBoard.occupy(controlableSpace, color, onlyCleanUp)
    for _, object in ipairs(controlableSpace.getObjects()) do
        for _, otherColor in ipairs(PlayBoard.getActivePlayBoardColors()) do
            if Types.isControlMarker(object, otherColor) then
                if otherColor ~= color then
                    local p = PlayBoard.getControlMarkerBag(otherColor).getPosition() + Vector(0, 1, 0)
                    object.setLock(false)
                    object.setPosition(p)
                else
                    return
                end
            end
        end
    end

    if not onlyCleanUp then
        local p = controlableSpace.getPosition()
        PlayBoard.getControlMarkerBag(color).takeObject({
            -- Position is adjusted so as to insert the token below any dreadnought.
            position = Vector(p.x, Board.onMainBoard(0.11), p.z),
            rotation = Vector(0, 180, 0),
            smooth = false,
            callback_function = function (controlMarker)
                controlMarker.setLock(true)
            end
        })
    end
end

---@param space Space
function MainBoard._createSpaceButton(space)
    local p = space.position
    Helper.createTransientAnchor("AgentPark", p - Vector(0, 0.5, 0)).doAfter(function (anchor)

        if MainBoard._findParentSpace(space) == space then

            local slots = {
                Vector(p.x - 0.36, Board.onMainBoard(0), p.z - 0.3),
                Vector(p.x + 0.36, Board.onMainBoard(0), p.z + 0.3),
                Vector(p.x - 0.36, Board.onMainBoard(0), p.z + 0.3),
                Vector(p.x + 0.36, Board.onMainBoard(0), p.z - 0.3)
            }
            space.zone = Park.createTransientBoundingZone(0, Vector(1, 3, 0.7), slots)

            local zone = space.zone
            local tags = { "Agent" }
            space.park = Park.createCommonPark(tags, slots, nil, nil, true, { zone }, "Space")
        else
            space.zone = Park.createTransientBoundingZone(0, Vector(0.75, 1, 0.75), { p })
        end

        local lastActivation = 0

        local tooltip = I18N("sendAgentTo", { space = I18N(space.name) })
        Helper.createAreaButton(space.zone, anchor, Board.onMainBoard(0.1), tooltip, PlayBoard.withLeader(function (leader, color, _)
            if TurnControl.getCurrentPlayer() == color then
                local cooldown = os.time() - lastActivation
                if cooldown > 2 then
                    lastActivation = os.time()
                    leader.sendAgent(color, space.name)
                end
            else
                Dialog.broadcastToColor(I18N('notYourTurn'), color, "Purple")
            end
        end))
    end)
end

---@param bannerZone Zone
function MainBoard._createBannerSpace(bannerZone)
    Helper.createTransientAnchor("BannerPark", bannerZone.getPosition() - Vector(0, 0.5, 0)).doAfter(function (anchor)
        anchor.setSnapPoints({{
            position = anchor.positionToLocal(bannerZone.getPosition()),
            tags = { "Flag", "Dreadnought" },
            rotation_snap = true,
        }})
    end)
end

-- TODO parent -> root
---@param space Space
---@return Space
function MainBoard._findParentSpace(space)
    return MainBoard.spaces[MainBoard.findParentSpaceName(space.name)]
end

---@param spaceName string
---@return string
function MainBoard.findParentSpaceName(spaceName)
    assert(MainBoard.spaces[spaceName], "No space named: " .. spaceName)
    local parentSpaceName = spaceName
    local underscoreIndex = spaceName:find("_")
    if underscoreIndex then
        parentSpaceName = spaceName:sub(1, underscoreIndex - 1)
        assert(MainBoard.spaces[parentSpaceName], "No parent space named: " .. parentSpaceName)
    end
    return parentSpaceName
end

---@param color PlayerColor
---@param spaceName string
---@return Continuation
function MainBoard.sendAgent(color, spaceName)
    local continuation = Helper.createContinuation("MainBoard.sendAgent")

    local agent = MainBoard._findProperAgent(color)

    local space = MainBoard.spaces[spaceName]
    local functionSpaceName = Helper.toCamelCase("_go", space.name)
    local goSpace = MainBoard[functionSpaceName]
    assert(goSpace, "Unknow go space function: " .. functionSpaceName)

    local parentSpace = MainBoard._findParentSpace(space)
    local parentSpaceName = parentSpace.name

    if not agent then
        Dialog.broadcastToColor(I18N("noAgent"), color, "Purple")
        continuation.cancel()
    elseif MainBoard.hasAgentInSpace(parentSpaceName, color) then
        Dialog.broadcastToColor(I18N("agentAlreadyPresent"), color, "Purple")
        continuation.cancel()
    else
        local leader = PlayBoard.getLeader(color)
        local innerContinuation = Helper.createContinuation("MainBoard." .. parentSpaceName)

        Action.setContext("agentDestination", { space = parentSpaceName, cards = Helper.mapValues(PlayBoard.getCardsPlayedThisTurn(color), Helper.getID) })
        goSpace(color, leader, innerContinuation)
        innerContinuation.doAfter(function (action)
            -- The innerContinuation never cancels (but returns nil) to allow us to cancel the root continuation.
            if action then
                Helper.emitEvent("agentSent", color, parentSpaceName)
                Action.setContext("agentSent", { space = parentSpaceName, cards = Helper.mapValues(PlayBoard.getCardsPlayedThisTurn(color), Helper.getID) })
                Park.putObject(agent, parentSpace.park)
                action()
                MainBoard.collectExtraBonuses(color, leader, spaceName)
                -- FIXME We are cheating here...
                Helper.onceTimeElapsed(2).doAfter(function ()
                    Action.log(nil, color)
                    Action.unsetContext("agentDestination")
                end)
                continuation.run()
            else
                Action.unsetContext("agentDestination")
                continuation.cancel()
            end
        end)
    end

    return continuation
end

---@param color PlayerColor
---@return Object
function MainBoard._findProperAgent(color)
    local agentPark = PlayBoard.getAgentPark(color)
    return Park.getObjects(agentPark)[1]
end

---@param color PlayerColor
---@param spaceName string
---@return boolean
function MainBoard.sendRivalAgent(color, spaceName)
    local space = MainBoard.spaces[spaceName]
    if not Park.isEmpty(PlayBoard.getAgentPark(color)) then
        local agentPark = PlayBoard.getAgentPark(color)
        Helper.emitEvent("agentSent", color, spaceName)
        Action.setContext("agentDestination", { space = spaceName })
        Park.transfer(1, agentPark, space.park)
	    -- TODO Why is it specific to SF?
        MainBoard.applyControlOfAnySpace(spaceName)
        return true
    else
        return false
    end
end

---@param name string
function MainBoard.applyControlOfAnySpace(name)
    if name == "imperialBasin" then
        MainBoard._applyControlOfAnySpace(MainBoard.banners.imperialBasinBannerZone, "spice")
    elseif name == "arrakeen" then
        MainBoard._applyControlOfAnySpace(MainBoard.banners.arrakeenBannerZone, "solari")
    elseif name == "carthag" then
        MainBoard._applyControlOfAnySpace(MainBoard.banners.carthagBannerZone, "solari")
    end
end

---@param leader Leader
---@param color PlayerColor
---@param resourceName ResourceName
---@param amount integer
---@return boolean
function MainBoard._hasResource(leader, color, resourceName, amount)
    local realAmount = leader.bargain(color, resourceName, amount)
    return PlayBoard.getResource(color, resourceName):get() >= realAmount
end

---@param color PlayerColor
---@param leader Leader
---@param requirements table<string, any>
---@return boolean
function MainBoard._checkGenericAccess(color, leader, requirements)
    if PlayBoard.isRival(color) then
        Helper.dump(color .. "player is a rival?!")
        return true
    end

    for requirement, value in pairs(requirements) do
        if Helper.isElementOf(requirement, { "spice", "water", "solari" }) then
            if not MainBoard._hasResource(leader, color, requirement, value) then
                Dialog.broadcastToColor(I18N("noResource", { resource = I18N(requirement .. "Amount") }), color, "Purple")
                return false
            end
        elseif requirement == "friendship" then
            if not InfluenceTrack.hasFriendship(color, value) then
                Dialog.broadcastToColor(I18N("noFriendship", { withFaction = I18N(Helper.toCamelCase("with", value)) }), color, "Purple")
                return false
            end
        end
    end

    return true
end

-- Emperor spaces

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goConspire(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { spice = 4 }) then
        continuation.run(function ()
            leader.resources(color, "spice", -4)
            leader.resources(color, "solari", 5)
            leader.troops(color, "supply", "garrison", 2)
            leader.drawIntrigues(color, 1)
            leader.influence(color, "emperor", 1)
        end)
    else
        continuation.run()
    end
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goWealth(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, {}) then
        continuation.run(function ()
            leader.resources(color, "solari", 2)
            leader.influence(color, "emperor", 1)
        end)
    else
        continuation.run()
    end
end

-- Spacing guild spaces

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goHeighliner(color, leader, continuation)
    local spiceCost = PlayBoard.hasPlayedThisTurn(color, "guildAccord") and 4 or 6
    if MainBoard._checkGenericAccess(color, leader, { spice = spiceCost }) then
        continuation.run(function ()
            leader.resources(color, "spice", -spiceCost)
            leader.resources(color, "water", 2)
            leader.troops(color, "supply", "garrison", 5)
            leader.influence(color, "spacingGuild", 1)
        end)
    else
        continuation.run()
    end
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goFoldspace(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, {}) then
        continuation.run(function ()
            leader.acquireFoldspace(color)
            leader.influence(color, "spacingGuild", 1)
        end)
    else
        continuation.run()
    end
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goSelectiveBreeding(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { spice = 2 }) then
        continuation.run(function ()
            leader.resources(color, "spice", -2)
            leader.influence(color, "beneGesserit", 1)
        end)
    else
        continuation.run()
    end
end

-- Bene Gesserit spaces

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goSecrets(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, {}) then
        continuation.run(function ()
            leader.drawIntrigues(color, 1)
            for _, otherColor in ipairs(PlayBoard.getActivePlayBoardColors()) do
                if otherColor ~= color then
                    if #PlayBoard.getIntrigues(otherColor) > 3 then
                        leader.stealIntrigues(color, otherColor, 1)
                    end
                end
            end
            leader.influence(color, "beneGesserit", 1)
        end)
    else
        continuation.run()
    end
end

-- Fremen spaces

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goHardyWarriors(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { water = 1 }) then
        continuation.run(function ()
            leader.resources(color, "water", -1)
            leader.troops(color, "supply", "garrison", 2)
            leader.influence(color, "fremen", 1)
        end)
    else
        continuation.run()
    end
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goStillsuits(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, {}) then
        continuation.run(function ()
            leader.resources(color, "water", 1)
            leader.influence(color, "fremen", 1)
        end)
    else
        continuation.run()
    end
end

-- Landsraad spaces

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goSwordmaster(color, leader, continuation)
    if not Hagal.isSwordmasterAvailable() then
        Dialog.broadcastToColor(I18N("unavailableSwordmaster"), color, "Purple")
        continuation.run()
    elseif PlayBoard.hasSwordmaster(color) then
        Dialog.broadcastToColor(I18N("alreadyHaveSwordmaster"), color, "Purple")
        continuation.run()
    elseif MainBoard._checkGenericAccess(color, leader, { solari = 8 }) then
        continuation.run(function ()
            leader.resources(color, "solari", -8)
            -- Wait for the first agent sent to be marked as moving (not resting),
            -- then move the swordmaster. Otherwise, the target agent park will
            -- grab the first agent back to the park when tidying it up.
            Helper.onceFramesPassed(1).doAfter(function ()
                leader.recruitSwordmaster(color)
            end)
        end)
    else
        continuation.run()
    end
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goMentat(color, leader, continuation)
    local mentatCost = Hagal.getMentatSpaceCost()
    if MainBoard._checkGenericAccess(color, leader, { solari = mentatCost }) then
        continuation.run(function ()
            leader.resources(color, "solari", -mentatCost)
            leader.drawImperiumCards(color, 1)
            -- Wait for the first agent sent to be marked as moving (not resting),
            -- then move the swordmaster. Otherwise, the target agent park will
            -- grab the first agent back to the park when tidying it up.
            Helper.onceFramesPassed(1).doAfter(function ()
                leader.takeMentat(color)
            end)
        end)
    else
        continuation.run()
    end
end

---@param anywhere? boolean
function MainBoard.getMentat(anywhere)
    if anywhere or Vector.distance(MainBoard.mentat.getPosition(), MainBoard.mentatZone.getPosition()) < 1 then
        return MainBoard.mentat
    else
        return nil
    end
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goHighCouncil(color, leader, continuation)
    if PlayBoard.hasHighCouncilSeat(color) then
        Dialog.broadcastToColor(I18N("alreadyHaveHighCouncilSeat"), color, "Purple")
        continuation.run()
    elseif MainBoard._checkGenericAccess(color, leader, { solari = 5 }) then
        continuation.run(function ()
            leader.resources(color, "solari", -5)
            leader.takeHighCouncilSeat(color)
        end)
    else
        continuation.run()
    end
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goRallyTroops(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { solari = 4 }) then
        continuation.run(function ()
            leader.resources(color, "solari", -4)
            leader.troops(color, "supply", "garrison", 4)
        end)
    else
        continuation.run()
    end
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goHallOfOratory(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, {}) then
        continuation.run(function ()
            leader.troops(color, "supply", "garrison", 1)
            PlayBoard.getResource(color, "persuasion"):setBaseValueContribution("hallOfOratory", 1)
        end)
    else
        continuation.run()
    end
end

-- CHOAM spaces

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goSecureContract(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, {}) then
        continuation.run(function ()
            leader.resources(color, "solari", 3)
        end)
    else
        continuation.run()
    end
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goSellMelange(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { spice = 2 }) then
        local hasEnoughSpice = function (index, _)
            local spiceCost = index + 1
            return MainBoard._hasResource(leader, color, "spice", spiceCost)
        end
        local options = Helper.takeWhile(hasEnoughSpice, {
            "2 -> 4",
            "3 -> 8",
            "4 -> 10",
            "5 -> 12",
        })
        Dialog.showOptionsAndCancelDialog(color, I18N("goSellMelange"), options, continuation, function (index)
            if index > 0 then
                MainBoard._sellMelange(color, leader, continuation, index)
            else
                continuation.run()
            end
        end)
    else
        continuation.run()
    end
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goSellMelange_1(color, leader, continuation)
    return MainBoard._sellMelange(color, leader, continuation, 1)
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goSellMelange_2(color, leader, continuation)
    return MainBoard._sellMelange(color, leader, continuation, 2)
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goSellMelange_3(color, leader, continuation)
    return MainBoard._sellMelange(color, leader, continuation, 3)
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goSellMelange_4(color, leader, continuation)
    return MainBoard._sellMelange(color, leader, continuation, 4)
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._sellMelange(color, leader, continuation, index)
    local spiceCost = index + 1
    if MainBoard._checkGenericAccess(color, leader, { spice = spiceCost }) then
        continuation.run(function ()
            leader.resources(color, "spice", -spiceCost)
            local solariBenefit = (index + 1) * 2 + 2
            leader.resources(color, "solari", solariBenefit)
        end)
    else
        continuation.run()
    end
end

-- City spaces

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goSietchTabr(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { friendship = "fremen" }) then
        continuation.run(function ()
            leader.troops(color, "supply", "garrison", 1)
            leader.resources(color, "water", 1)
        end)
    else
        continuation.run()
    end
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goResearchStation(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { water = 2 }) then
        continuation.run(function ()
            leader.resources(color, "water", -2)
            if MainBoard.immortalityPatch then
                leader.drawImperiumCards(color, 2)
                leader.research(color)
            else
                leader.drawImperiumCards(color, 3)
            end
        end)
    else
        continuation.run()
    end
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goCarthag(color, leader, continuation)
    continuation.run(function ()
        leader.drawIntrigues(color, 1)
        leader.troops(color, "supply", "garrison", 1)
        MainBoard._applyControlOfAnySpace(MainBoard.banners.carthagBannerZone, "solari")
    end)
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goArrakeen(color, leader, continuation)
    continuation.run(function ()
        leader.troops(color, "supply", "garrison", 1)
        leader.drawImperiumCards(color, 1)
        MainBoard._applyControlOfAnySpace(MainBoard.banners.arrakeenBannerZone, "solari")
    end)
end

-- Desert spaces

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goImperialBasin(color, leader, continuation)
    local innerContinuation = Helper.createContinuation("MainBoard._goImperialBasin")
    MainBoard._anySpiceSpace(color, leader, innerContinuation, 0, 1, MainBoard.spiceBonuses.imperialBasin)
    innerContinuation.doAfter(function (action)
        continuation.run(function ()
            action()
            MainBoard._applyControlOfAnySpace(MainBoard.banners.imperialBasinBannerZone, "spice")
        end)
    end)
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goHaggaBasin(color, leader, continuation)
    MainBoard._anySpiceSpace(color, leader, continuation, 1, 2, MainBoard.spiceBonuses.haggaBasin)
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goTheGreatFlat(color, leader, continuation)
    MainBoard._anySpiceSpace(color, leader, continuation, 2, 3, MainBoard.spiceBonuses.theGreatFlat)
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goTuekSietch(color, leader, continuation)
    local options = {
        I18N("withSpiceOption"),
        I18N("withDrawOption"),
    }
    Dialog.showOptionsAndCancelDialog(color, I18N("goTuekSietch"), options, continuation, function (index)
        if index == 1 then
            MainBoard._goTuekSietch_WithSpice(color, leader, continuation)
        elseif index == 2 then
            MainBoard._goTuekSietch_WithDraw(color, leader, continuation)
        else
            assert(index == 0)
            continuation.run()
        end
    end)
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goTuekSietch_WithSpice(color, leader, continuation)
    leader.resources(color, "spice", 1)
    MainBoard._anySpiceSpace(color, leader, continuation, 0, 0, MainBoard.spiceBonuses.tuekSietch)
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goTuekSietch_WithDraw(color, leader, continuation)
    leader.drawImperiumCards(color, 1)
    MainBoard._anySpiceSpace(color, leader, continuation, 0, 0, MainBoard.spiceBonuses.tuekSietch)
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
---@param waterCost integer
---@param spiceBaseAmount integer
---@param spiceBonus Resource
function MainBoard._anySpiceSpace(color, leader, continuation, waterCost, spiceBaseAmount, spiceBonus)
    if MainBoard._checkGenericAccess(color, leader, { water = waterCost }) then
        continuation.run(function ()
            leader.resources(color, "water", -waterCost)
            local harvestedSpiceAmount = MainBoard._harvestSpice(spiceBaseAmount, spiceBonus)
            leader.resources(color, "spice", harvestedSpiceAmount)
        end)
    else
        continuation.run()
    end
end

---@param desertSpaceName string
---@return Resource
function MainBoard.getSpiceBonus(desertSpaceName)
    assert(MainBoard.isDesertSpace(desertSpaceName))
    return MainBoard.spiceBonuses[desertSpaceName]
end

---@param baseAmount integer
---@param spiceBonus Resource
---@return integer
function MainBoard._harvestSpice(baseAmount, spiceBonus)
    assert(spiceBonus)
    local spiceAmount = baseAmount + spiceBonus:get()
    spiceBonus:set(0)
    return spiceAmount
end

---@param bannerZone Zone
---@param resourceName string
function MainBoard._applyControlOfAnySpace(bannerZone, resourceName)
    local controllingPlayer = MainBoard.getControllingPlayer(bannerZone)
    if controllingPlayer then
        PlayBoard.getLeader(controllingPlayer).resources(controllingPlayer, resourceName, 1)
    end
end

---@param conflictName string
---@return Zone?
function MainBoard.findControlableSpaceFromConflictName(conflictName)
    assert(conflictName)
    if conflictName == "secureImperialBasin" or conflictName == "battleForImperialBasin" then
        return MainBoard.banners.imperialBasinBannerZone
    elseif conflictName == "siegeOfArrakeen" or conflictName == "battleForArrakeen" then
        return MainBoard.banners.arrakeenBannerZone
    elseif conflictName == "siegeOfCarthag" or conflictName == "battleForCarthag" then
        return MainBoard.banners.carthagBannerZone
    else
        return nil
    end
end

---@param name string
---@return Zone?
function MainBoard.unused_findControlableSpace(name)
    for bannerZoneName, zone in pairs(MainBoard.banners) do
        if Helper.startsWith(bannerZoneName, name) then
            return zone
        end
    end
    return nil
end

---@param bannerZone Zone
---@return PlayerColor?
function MainBoard.getControllingPlayer(bannerZone)
    local controllingPlayer = nil

    -- Check player dreadnoughts first since they supersede flags.
    for _, object in ipairs(bannerZone.getObjects()) do
        for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
            if Types.isDreadnought(object, color) then
                assert(not controllingPlayer, "Too many dreadnoughts")
                controllingPlayer = color
            end
        end
    end

    -- Check player flags otherwise.
    if not controllingPlayer then
        for _, object in ipairs(bannerZone.getObjects()) do
            for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
                if Types.isControlMarker(object, color) then
                    assert(not controllingPlayer, "Too many flags around")
                    controllingPlayer = color
                end
            end
        end
    end

    return controllingPlayer
end

---@param bannerZone Zone
---@return Object?
function MainBoard.getControllingDreadnought(bannerZone)
    for _, object in ipairs(bannerZone.getObjects()) do
        for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
            if Types.isDreadnought(object, color) then
                return object
            end
        end
    end
    return nil
end

-- Ix spaces (CHOAM)

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goSmuggling(color, leader, continuation)
    continuation.run(function ()
        leader.resources(color, "solari", 1)
        leader.shipments(color, 1)
    end)
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goInterstellarShipping(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { friendship = "spacingGuild" }) then
        continuation.run(function ()
            leader.shipments(color, 2)
        end)
    else
        continuation.run()
    end
end

-- Ix spaces

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goTechNegotiation(color, leader, continuation)
    local options = {
        I18N("sendNegotiatorOption"),
        I18N("buyTechWithDiscount1Option"),
    }
    Dialog.showOptionsAndCancelDialog(color, I18N("goTechNegotiation"), options, continuation, function (index)
        if index == 1 then
            MainBoard._goTechNegotiation_Negotiate(color, leader, continuation)
        elseif index == 2 then
            MainBoard._goTechNegotiation_Buy(color, leader, continuation)
        else
            assert(index == 0)
            continuation.run()
        end
    end)
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goTechNegotiation_Negotiate(color, leader, continuation)
    continuation.run(function ()
        PlayBoard.getResource(color, "persuasion"):setBaseValueContribution("techNegotiation", 1)
        leader.troops(color, "supply", "negotiation", 1)
    end)
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goTechNegotiation_Buy(color, leader, continuation)
    continuation.run(function ()
        PlayBoard.getResource(color, "persuasion"):setBaseValueContribution("techNegotiation", 1)
        TechMarket.registerAcquireTechOption(color, "techNegotiationTechBuyOption", "spice", 1)
    end)
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goDreadnought(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { solari = 3 }) then
        continuation.run(function ()
            leader.resources(color, "solari", -3)
            TechMarket.registerAcquireTechOption(color, "dreadnoughtTechBuyOption", "spice", 0)
            Park.transfer(1, PlayBoard.getDreadnoughtPark(color), Combat.getDreadnoughtPark(color))
        end)
    else
        continuation.run()
    end
end

--- The color could be nil (the same way it could be nil with Types.isAgent)
---@param spaceName string
---@param color PlayerColor
---@return boolean
function MainBoard.hasAgentInSpace(spaceName, color)
    local space = MainBoard.spaces[spaceName]
    -- Avoid since it depends on the active extensions.
    --assert(space, "Unknow space: " .. spaceName)
    if space then
        for _, object in ipairs(space.zone.getObjects()) do
            if Types.isAgent(object, color) then
                return true
            end
        end
    end
    return false
end

---@param spaceName string
---@param color PlayerColor
---@return boolean
function MainBoard.hasEnemyAgentInSpace(spaceName, color)
    for _, otherColor in ipairs(PlayBoard.getActivePlayBoardColors()) do
        if otherColor ~= color and MainBoard.hasAgentInSpace(spaceName, otherColor) then
            return true
        end
    end
    return false
end

---@param spaceName string
---@return boolean
function MainBoard.hasVoiceToken(spaceName)
    local space = MainBoard.spaces[spaceName]
    if space then
        return #Helper.filter(space.zone.getObjects(), Types.isVoiceToken) > 0
    end
    return false
end

---@param spaceName string
---@return boolean
function MainBoard.isEmperorSpace(spaceName)
    return MainBoard.spaceDetails[spaceName].group == "emperor"
end

---@param spaceName string
---@return boolean
function MainBoard.isSpacingGuildSpace(spaceName)
    return MainBoard.spaceDetails[spaceName].group == "spacingGuild"
end

---@param spaceName string
---@return boolean
function MainBoard.isBeneGesseritSpace(spaceName)
    return MainBoard.spaceDetails[spaceName].group == "beneGesserit"
end

---@param spaceName string
---@return boolean
function MainBoard.isFremenSpace(spaceName)
    return MainBoard.spaceDetails[spaceName].group == "fremen"
end

---@param spaceName string
---@return boolean
function MainBoard.unused_isFactionSpace(spaceName)
    return MainBoard.isEmperorSpace(spaceName)
        or MainBoard.isSpacingGuildSpace(spaceName)
        or MainBoard.isBeneGesseritSpace(spaceName)
        or MainBoard.isFremenSpace(spaceName)
end

---@param spaceName string
---@return boolean
function MainBoard.isLandsraadSpace(spaceName)
    return MainBoard.spaceDetails[spaceName].group == "landsraad"
end

---@param spaceName string
---@return boolean
function MainBoard.isGreenSpace(spaceName)
    return Helper.isElementOf(MainBoard.spaceDetails[spaceName].group, { "landsraad", "ix" })
end

---@param spaceName string
---@return boolean
function MainBoard.unused_isBlueSpace(spaceName)
    return MainBoard.spaceDetails[spaceName].group == "city"
end

---@param spaceName string
---@return boolean
function MainBoard.unused_isYellowSpace(spaceName)
    return Helper.isElementOf(MainBoard.spaceDetails[spaceName].group, { "desert", "choam" })
end

--- aka Maker space
---@param spaceName string
---@return boolean
function MainBoard.isDesertSpace(spaceName)
    return MainBoard.spaceDetails[spaceName].group == "desert"
end

---@param spaceName string
---@return boolean
function MainBoard.unused_isCombatSpace(spaceName)
    return MainBoard.spaceDetails[spaceName].combat
end

---@return Space[]
function MainBoard.getEmperorSpaces()
    local emperorSpaces = {}
    for space, details in pairs(MainBoard.spaceDetails) do
        if Helper.isElementOf(details.group, { "emperor", "greatHouses" }) then
            table.insert(emperorSpaces, space)
        end
    end
    return emperorSpaces
end

---@return Space[]
function MainBoard.getGreenSpaces()
    return Helper.filter(Helper.getKeys(MainBoard.spaceDetails), MainBoard.isGreenSpace)
end

---@return Zone[]
function MainBoard.getBannerZones()
    return {
        MainBoard.banners.imperialBasinBannerZone,
        MainBoard.banners.arrakeenBannerZone,
        MainBoard.banners.carthagBannerZone,
    }
end

---@param zone Zone
---@param object Object
function MainBoard.onObjectEnterZone(zone, object)
    if Helper.isNil(zone) or Helper.isNil(object) then
        return
    end
    if zone == MainBoard.mentatZone then
        if Types.isMentat(object) then
            -- Wait 1 second to see if the Mentat is still around and wasn't simply moving across the board.
            Helper.onceTimeElapsed(1).doAfter(function ()
                if Helper.contains(zone, object) then
                    for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
                        object.removeTag(color)
                    end
                    object.setColorTint(Color.fromString("White"))
                end
            end)
        end
    end
end

---@param spaceName string
---@param bonuses table<TARGET, table<CATEGORY, any>>
function MainBoard.addSpaceBonus(spaceName, bonuses)
    local space = MainBoard.spaces[spaceName]
    assert(space, "Unknow space: " .. spaceName)
    if not space.extraBonuses then
        space.extraBonuses = {}
    end
    DynamicBonus.createSpaceBonus(space.zone.getPosition() + Vector(1.2, 0, 0.75), bonuses, space.extraBonuses)
end

---@param color PlayerColor
---@param leader Leader
---@param spaceName string
function MainBoard.collectExtraBonuses(color, leader, spaceName)
    local space = MainBoard.spaces[spaceName]
    if space.extraBonuses then
        DynamicBonus.collectExtraBonuses(color, leader, space.extraBonuses)
    end
end

---@param faction Faction
---@return Vector[]
function MainBoard.getSnooperTrackPosition(faction)

    local getAveragePosition = function (spaceNames)
        local p = Vector(0, 0, 0)
        local count = 0
        for _, spaceName in ipairs(spaceNames) do
            local space = MainBoard.spaces[spaceName]
            assert(space, spaceName)
            p = p + space.zone.getPosition()
            count = count + 1
        end
        return p * (1 / count)
    end

    local positions = {
        emperor = getAveragePosition({ "conspire", "wealth" }),
        spacingGuild = getAveragePosition({ "heighliner", "foldspace" }),
        beneGesserit = getAveragePosition({ "selectiveBreeding", "secrets" }),
        fremen = getAveragePosition({ "hardyWarriors", "stillsuits" }),
    }

    return positions[faction]
end

---@return Object
function MainBoard.getFirstPlayerMarker()
    return MainBoard.firstPlayerMarker
end

---@param object Object
function MainBoard.trash(object)
    MainBoard.trashQueue = MainBoard.trashQueue or Helper.createSpaceQueue()
    MainBoard.trashQueue.submit(function (height)
        object.interactable = true
        object.setLock(false)
        object.setPosition(getObjectFromGUID('ef8614').getPosition() + Vector(0, 1 + height * 0.5, 0))
    end)
end

---@param object Object
---@return boolean
function MainBoard.isInside(object)
    local position = object.getPosition()
    local center = MainBoard.mainBoard.getPosition()
    local offset = position - center
    return math.abs(offset.x) < 11 and math.abs(offset.z) < 11
end

return MainBoard
