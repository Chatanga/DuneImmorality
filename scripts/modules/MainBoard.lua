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
local Commander = Module.lazyRequire("Commander")
local Music = Module.lazyRequire("Music")
local Hagal = Module.lazyRequire("Hagal")
local Board = Module.lazyRequire("Board")

local MainBoard = {
    spaceDetails = {
        sardaukar = { group = "emperor", posts = { "emperor" } },
        vastWealth = { group = "emperor", posts = { "emperor" } },
        dutifulService = { group = "emperor", posts = { "emperor" } },

        militarySupport = { group = "greatHouses", posts = { "greatHouses" } },
        economicSupport = { group = "greatHouses", posts = { "greatHouses" } },

        heighliner = { group = "spacingGuild", combat = true, posts = { "spacingGuild" } },
        deliverSupplies = { group = "spacingGuild", posts = { "spacingGuild" } },

        espionage = { group = "beneGesserit", posts = { "beneGesserit" } },
        secrets = { group = "beneGesserit", posts = { "beneGesserit" } },

        controversialTechnology = { group = "fringeWorlds", posts = { "fringeWorlds" } },
        expedition = { group = "fringeWorlds", posts = { "fringeWorlds" } },

        desertTactics = { group = "fremen", combat = true, posts = { "fremen" } },
        fremkit = { group = "fremen", combat = true, posts = { "fremen" } },
        hardyWarriors = { group = "fremen", combat = true, posts = { "fremen" } },
        desertMastery = { group = "fremen", combat = true, posts = { "fremen" } },

        highCouncil = { group = "landsraad", posts = { "landsraadCouncil1" } },
        imperialPrivilege = { group = "landsraad", posts = { "landsraadCouncil1" } },
        swordmaster = { group = "landsraad", posts = { "landsraadCouncil1" } },
        assemblyHall = { group = "landsraad", posts = { "landsraadCouncil2" } },
        gatherSupport = { group = "landsraad", posts = { "landsraadCouncil2" } },

        techNegotiation = { group = "ix", posts = { "ix" } },
        dreadnought = { group = "ix", posts = { "ix" } },

        shipping = { group = "choam", posts = { "choam" } },
        acceptContract = { group = "choam", posts = { "choam" } },

        smuggling = { group = "choam", posts = { "ixChoam" } },
        interstellarShipping = { group = "choam", posts = { "ixChoam" } },

        sietchTabr = { group = "city", combat = true, posts = { "sietchTabrResearchStation" } },
        researchStation = { group = "city", combat = true, posts = { "sietchTabrResearchStation", "researchStationSpiceRefinery" } },
        spiceRefinery = { group = "city", combat = true, posts = { "researchStationSpiceRefinery", "spiceRefineryArrakeen" } },
        arrakeen = { group = "city", combat = true, posts = { "spiceRefineryArrakeen" } },
        carthag = { group = "city", combat = true, posts = { "carthag" } },

        deepDesert = { group = "desert", combat = true, posts = { "deepDesert" } },
        haggaBasin = { group = "desert", combat = true, posts = { "haggaBasin" } },
        habbanyaErg = { group = "desert", combat = true, posts = { "habbanyaErg" } },
        imperialBasin = { group = "desert", combat = true, posts = { "imperialBasin" } },

        tuekSietch = { group = "desert", combat = true, posts = {} },
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
        immortalityPatch = "6cf62a",
        spiceBonusTokens = {
            deepDesert = "116807",
            haggaBasin = "c24705",
            imperialBasin = "3cdb2d",
            habbanyaErg = "394db2",
            tuekSietch = "be19c0",
        },
        firstPlayerMarker = "1f5576",
        shieldWallToken = "31d6b0",
    }))
    MainBoard.spiceBonuses = {}

    Helper.forEachValue(MainBoard.spiceBonusTokens, Helper.noPhysicsNorPlay)

    if state.settings and state.MainBoard then
        MainBoard.mainBoard = Board.getBoard("mainBoard4P") or Board.getBoard("mainBoard6P")
        MainBoard.emperorBoard = Board.getBoard("emperorBoard")
        MainBoard.fremenBoard = Board.getBoard("fremenBoard")
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
    if settings.numberOfPlayers == 6 then
        MainBoard.mainBoard = Board.selectBoard("mainBoard6P", settings.language)
        MainBoard.emperorBoard = Board.selectBoard("emperorBoard", settings.language)
        MainBoard.fremenBoard = Board.selectBoard("fremenBoard", settings.language)
    else
        MainBoard.mainBoard = Board.selectBoard("mainBoard4P", settings.language)
        Board.destructBoard("emperorBoard")
        MainBoard.emperorBoard = nil
        Board.destructBoard("fremenBoard")
        MainBoard.fremenBoard = nil
        MainBoard.spiceBonusTokens.habbanyaErg.destruct()
        MainBoard.spiceBonusTokens.habbanyaErg = nil
    end

    if settings.immortality then
        if settings.numberOfPlayers == 6 then
            local position = MainBoard.immortalityPatch.getPosition()
            MainBoard.immortalityPatch.setPosition(position + Vector(1.6, 0, -1.9))
        end
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

    if MainBoard.shieldWallToken then
        MainBoard.shieldWallToken.clearButtons()
        Helper.createAbsoluteButtonWithRoundness(MainBoard.shieldWallToken, 7, {
            click_function = Helper.registerGlobalCallback(function (_, color, _)
                MainBoard.blowUpShieldWall(color)
            end),
            position = MainBoard.shieldWallToken.getPosition() + Vector(0.2, 0.1, 0.2),
            width = 800,
            height = 800,
            color = {0, 0, 0, 0},
            tooltip = I18N("explosion")
        })
    end

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
                        if object.hasTag("Agent") then
                            for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
                                if object.hasTag(color) then
                                    if settings.numberOfPlayers == 6 and object.hasTag("Swordmaster") then
                                        PlayBoard.destroySwordmaster(color)
                                    else
                                        Park.putObject(object, PlayBoard.getAgentPark(color))
                                    end
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
    local origin = primaryTable.getPosition() + Vector(-3.7, 1.8, -16.5)

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
    MainBoard.observationPosts = {}
    MainBoard.banners = {}

    local highCouncilSeats = MainBoard._doProcessSnapPoints(settings,
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
    MainBoard._doProcessSnapPoints(settings, MainBoard._collectSnapPointsOnTuekBoard)
end

---@param settings Settings
---@param collect fun(net: CollectNet)
---@return table<integer, Vector>
function MainBoard._doProcessSnapPoints(settings, collect)
    local highCouncilSeats = {}

    collect({

        seat = function (name, position)
            local str = name:sub(12)
            local index = tonumber(str)
            assert(index, "Not a number: " .. str)
            highCouncilSeats[index] = position
        end,

        space = function (name, position)
            -- Spice Flow use two exclusive boards, one for Ix and another without it, whereas Rakis Rising
            -- uses only a "patching" board for Ix, forcing us to ignore the snap points under it. The later
            -- approach is probably the better.
            if settings.ix then
                local ignoredSpaceNames = {
                    "assemblyHall",
                    "gatherSupport",
                    "shipping",
                    "acceptContract",
                }
                for _, ignoredSpaceName in ipairs(ignoredSpaceNames) do
                    if Helper.startsWith(name, ignoredSpaceName) then
                        return
                    end
                end
            end
            MainBoard.spaces[name] = { name = name, position = position }
        end,

        post = function (name, position, snapPoint)
            if settings.ix then
                local ignoredSpaceNames = {
                    "choam",
                    "landsraadCouncil2"
                }
                for _, ignoredSpaceName in ipairs(ignoredSpaceNames) do
                    if Helper.startsWith(name, ignoredSpaceName) then
                        return
                    end
                end
            end
            MainBoard.observationPosts[name] = { name = name, position = position, snapPoint = snapPoint }
        end,

        spice = function (name, position)
            Helper.dump(name, "->", position)
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

    for _, observationPost in pairs(MainBoard.observationPosts) do
        MainBoard._createObservationPostButton(observationPost)
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
        --Helper.dump("Collecting snap points on board", Helper.getID(board))
        Helper.collectSnapPoints(board, net)
    end
end

---@param settings Settings
---@return Object[]
function MainBoard._getAllBoards(settings)
    local boards = { MainBoard.mainBoard }

    if settings.numberOfPlayers == 6 then
        assert(MainBoard.emperorBoard)
        table.insert(boards, MainBoard.emperorBoard)
        assert(MainBoard.fremenBoard)
        table.insert(boards, MainBoard.fremenBoard)
    end

    if settings.ix then
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
                Vector(p.x - 0.36, Board.onMainBoard(0), p.z + 0.3),
                Vector(p.x + 0.36, Board.onMainBoard(0), p.z - 0.3),
                Vector(p.x + 0.36, Board.onMainBoard(0), p.z + 0.3),
                Vector(p.x - 0.36, Board.onMainBoard(0), p.z - 0.3),
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
        Helper.createAreaButton(space.zone, anchor, Board.onMainBoard(0.1), tooltip, PlayBoard.withLeader(function (leader, color, altClick)
            if TurnControl.getCurrentPlayer() == color then
                local cooldown = os.time() - lastActivation
                if cooldown > 2 then
                    lastActivation = os.time()
                    leader.sendAgent(color, space.name, altClick)
                end
            else
                Dialog.broadcastToColor(I18N('notYourTurn'), color, "Purple")
            end
        end))
    end)
end

---@param observationPost Space
function MainBoard._createObservationPostButton(observationPost)
    local slots = { observationPost.position }
    Helper.createTransientAnchor("AgentPark", observationPost.position - Vector(0, 0.5, 0)).doAfter(function (anchor)
        observationPost.zone = Park.createTransientBoundingZone(0, Vector(0.75, 1, 0.75), slots)

        local tags = { "Spy" }
        observationPost.park = Park.createPark("SpyPark", slots, nil, { observationPost.zone }, tags, nil, false, true)

        local snapPoints = {}
        for _, slot in ipairs(slots) do
            table.insert(snapPoints, Helper.createRelativeSnapPoint(anchor, slot, false, tags))
        end
        anchor.setSnapPoints(snapPoints)

        local tooltip = I18N("sendSpyTo", { observationPost = I18N(observationPost.name)})
        Helper.createAreaButton(observationPost.zone, anchor, 1.75, tooltip, PlayBoard.withLeader(function (leader, color)
            leader.sendSpy(color, observationPost.name)
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
---@param recallSpy? boolean
---@return Continuation
function MainBoard.sendAgent(color, spaceName, recallSpy)
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
                MainBoard._manageIntelligenceAndInfiltrate(color, parentSpaceName, recallSpy).doAfter(function (goAhead, spy, otherSpy, recallMode)
                    if goAhead then
                        local innerInnerContinuation = Helper.createContinuation("MainBoard." .. spaceName .. ".goAhead")
                        Helper.emitEvent("agentSent", color, parentSpaceName)
                        Park.putObject(agent, parentSpace.park)
                        if spy then
                            Park.putObject(spy, PlayBoard.getSpyPark(color))
                            if recallMode == "infiltrateAndIntelligence" then
                                Park.putObject(otherSpy, PlayBoard.getSpyPark(color))
                                Action.log(I18N("infiltrateWithSpy"), color)
                                Action.log(I18N("gatherIntelligenceWithSpy"), color)
                                leader.drawImperiumCards(color, 1, true).doAfter(innerInnerContinuation.run)
                            elseif recallMode == "infiltrate" then
                                Action.log(I18N("infiltrateWithSpy"), color)
                                innerInnerContinuation.run()
                            elseif recallMode == "intelligence" then
                                Action.log(I18N("gatherIntelligenceWithSpy"), color)
                                leader.drawImperiumCards(color, 1, true).doAfter(innerInnerContinuation.run)
                            else
                                error("Unexpected mode: " .. tostring(recallMode))
                                innerInnerContinuation.run()
                            end
                        else
                            innerInnerContinuation.run()
                        end
                        innerInnerContinuation.doAfter(function ()
                            action()
                            -- FIXME We are cheating here...
                            Helper.onceTimeElapsed(2).doAfter(function ()
                                Action.log(nil, color)
                                Action.unsetContext("agentDestination")
                            end)
                            continuation.run()
                        end)
                    else
                        Action.unsetContext("agentDestination")
                        continuation.cancel()
                    end
                end)
            else
                Action.unsetContext("agentDestination")
                continuation.cancel()
            end
        end)
    end

    return continuation
end

---@param color PlayerColor
---@return Object?
function MainBoard._findProperAgent(color)
    local leftAlly = Commander.getLeftSeatedAlly(color)
    local rightAlly = Commander.getRightSeatedAlly(color)
    local agentPark = PlayBoard.getAgentPark(color)
    local candidates = {}
    if Commander.isCommander(color) then
        local allyColor = Commander.getActivatedAlly(color)
        if allyColor then
            for _, agent in ipairs(Park.getObjects(agentPark)) do
                if (leftAlly == allyColor and agent.hasTag("Left"))
                or (rightAlly == allyColor and agent.hasTag("Right")) then
                    table.insert(candidates, agent)
                end
            end
        end
    else
        for _, agent in ipairs(Park.getObjects(agentPark)) do
            table.insert(candidates, agent)
        end
    end
    if #candidates > 1 then
        for i, agent in ipairs(candidates) do
            if agent.hasTag("Swordmaster") then
                table.remove(candidates, i)
                break
            end
        end
    end
    return #candidates > 0 and candidates[1] or nil
end

---@param color PlayerColor
---@param observationPostName string
---@param deepCover? boolean
---@return boolean
function MainBoard.sendSpy(color, observationPostName, deepCover)
    local observationPost = MainBoard.observationPosts[observationPostName]
    assert(observationPost, observationPostName)

    local spyPark = PlayBoard.getSpyPark(color)
    if deepCover or not Park.isEmpty(spyPark) then
        Helper.emitEvent("spySent", color, observationPostName, deepCover)
        Park.transfer(1, spyPark, observationPost.park)
        return true
    else
        return false
    end
end

---@param color PlayerColor
---@param observationPostName Space
---@return boolean
function MainBoard.recallSpy(color, observationPostName)
    local observationPost = MainBoard.observationPosts[observationPostName]
    assert(observationPost, observationPostName)

    local spyPark = PlayBoard.getSpyPark(color)
    return Park.transfer(1, observationPost.park, spyPark) > 0
end

---@param color PlayerColor
---@return Object[]
function MainBoard.findRecallableSpies(color)
    local recallableSpies = {}
    for observationPostName, observationPost in pairs(MainBoard.observationPosts) do
        for _, spy in ipairs(Park.getObjects(observationPost.park)) do
            if spy.hasTag(color) then
                table.insert(recallableSpies, observationPostName)
            end
        end
    end
    return recallableSpies
end

---In the case of the "infiltrate + gather intelligence" combo , only applies to the first.
---@param color PlayerColor
---@param spaceName string
---@param recallSpy boolean? Explicitly require the action and fail if it cannot be executed.
---@return Continuation
function MainBoard._manageIntelligenceAndInfiltrate(color, spaceName, recallSpy)
    local continuation = Helper.createContinuation("MainBoard._manageIntelligenceAndInfiltrate")

    local recallableSpies = MainBoard.getRecallableSpies(color, spaceName)

    local hasCardsToDraw = PlayBoard.getDrawDeck(color) or PlayBoard.getDiscard(color)

    -- We have already verified that there is no agent of the same color,
    -- so any remaining agent must be an enemy.
    local enemyAgentPresent = MainBoard.hasAgentInSpace(spaceName)

    if not enemyAgentPresent or MainBoard._couldInfiltrateByOtherMeans(color, spaceName) then
        if #recallableSpies == 0 or not hasCardsToDraw then
            if recallSpy then
                Dialog.broadcastToColor(I18N('noSpyToRecallOrCardToDraw'), color, "Purple")
                continuation.run(false)
            else
                continuation.run(true)
            end
        elseif recallSpy then
            MainBoard._recallSpy(color, recallableSpies, continuation, "intelligence")
        else
            Dialog.showYesOrNoDialog(color, I18N("confirmSpyRecall"), continuation, function (confirmed)
                if confirmed then
                    MainBoard._recallSpy(color, recallableSpies, continuation, "intelligence")
                else
                    continuation.run(true)
                end
            end)
        end
    else
        if #recallableSpies == 0 then
            Dialog.broadcastToColor(I18N("noSpyToInfiltrate"), color, "Purple")
            continuation.run(false)
        elseif #recallableSpies > 1 and hasCardsToDraw then
            Dialog.showYesOrNoDialog(color, I18N("confirmSpyRecall"), continuation, function (confirmed)
                if confirmed then
                    MainBoard._recallSpy(color, recallableSpies, continuation, "infiltrateAndIntelligence")
                else
                    MainBoard._recallSpy(color, recallableSpies, continuation, "infiltrate")
                end
            end)
        else
            MainBoard._recallSpy(color, recallableSpies, continuation, "infiltrate")
        end
    end

    return continuation
end

---@param color PlayerColor
---@param spaceName string
---@return boolean
function MainBoard._couldInfiltrateByOtherMeans(color, spaceName)
    local details = MainBoard.spaceDetails[spaceName]
    assert(details, spaceName)

    -- Should be equivalent to the (unused) function 'ImperiumCard._resolveCard(card).factions'.
    local infiltrationCards = {
        kwisatzHaderach = {},
        courtIntrigue = { "emperor", "greatHouses" },
        guildAccord = { "spacingGuild" },
        webOfPower = { "beneGesserit" },
        jamis = { "fremen", "fringeWorlds" },
        choamDelegate = { "desert", "choam" },
        bountyHunter = { "city" },
        embeddedAgent = { "landsraad", "ix" },
        tleilaxuInfiltrator = {},
    }

    -- TODO Introduce IoD.
    local leader = PlayBoard.getLeader(color)
    if leader.name == "helenaRichese" and Helper.isElementOf(details.group, { "landsraad", "ix" }) then
        return true
    end

    for cardName, groups in pairs(infiltrationCards) do
        local groupMatchs = Helper.isEmpty(groups) or Helper.isElementOf(details.group, groups)
        if groupMatchs and PlayBoard.hasPlayedThisTurn(color, cardName) then
            return true
        end
    end
    return false
end

---@alias RecallableSpy {
--- toSpaceName: string,
--- spy: Object }

---@param color PlayerColor
---@param recallableSpies RecallableSpy[]
---@param continuation Continuation
---@param recallMode string
function MainBoard._recallSpy(color, recallableSpies, continuation, recallMode)
    if recallMode == "infiltrateAndIntelligence" then
        -- Choosing 2 spies among 3 or more, or choosing twice in a row,
        -- is inconvenient. Good thing it can't happen.
        assert(#recallableSpies == 2)
        continuation.run(true, recallableSpies[1].spy, recallableSpies[2].spy, recallMode)
    elseif #recallableSpies == 1 then
        continuation.run(true, recallableSpies[1].spy, nil, recallMode)
    else
        local options = Helper.mapValues(recallableSpies, function (recallableSpy)
            return I18N(recallableSpy.toSpaceName)
        end)
        Dialog.showOptionsAndCancelDialog(color, I18N("selectSpyToRecall"), options, continuation, function (index)
            if index > 0 then
                continuation.run(true, recallableSpies[index].spy, nil, recallMode)
            else
                continuation.run(false)
            end
        end)
    end
end

---@param color PlayerColor
---@param spaceName string
---@return RecallableSpy[]
function MainBoard.getRecallableSpies(color, spaceName)
    local details = MainBoard.spaceDetails[spaceName]
    assert(details, spaceName)

    local findConnectedSpaceName = function (postName)
        for otherSpaceName, otherDetails in pairs(MainBoard.spaceDetails) do
            if otherSpaceName ~= spaceName and Helper.isElementOf(postName, otherDetails.posts) then
                return otherSpaceName
            end
        end
        return nil
    end

    local recallableSpies = {}
    for _, postName in ipairs(details.posts) do
        local observationPost = MainBoard.observationPosts[postName]
        if observationPost then
            for _, spy in ipairs(Park.getObjects(observationPost.park)) do
                if spy.hasTag(color) then
                    table.insert(recallableSpies, {
                        toSpaceName = findConnectedSpaceName(postName),
                        spy = spy,
                    })
                    break
                end
            end
        end
    end
    return recallableSpies
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
        MainBoard.applyControlOfAnySpace(spaceName)
        return true
    else
        return false
    end
end

---@param name string
---@return boolean
function MainBoard.applyControlOfAnySpace(name)
    local bannerZone = MainBoard.findControlableSpace(name)
    if bannerZone then
        local resourceName
        if name == "arrakeen" or name == "spiceRefinery" then
            resourceName = "solari"
        elseif name == "imperialBasin" then
            resourceName = "spice"
        else
            error(name)
        end
        MainBoard._applyControlOfAnySpace(bannerZone, resourceName)
        return true
    else
        return false
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
            local exemptionCards = {
                "undercoverAsset",
            }
            for _, cardName in ipairs(exemptionCards) do
                if PlayBoard.hasPlayedThisTurn(color, cardName) then
                    return true
                end
            end
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
function MainBoard._goDutifulService(color, leader, continuation)
    assert(TurnControl.getPlayerCount() < 6)
    continuation.run(function ()
        leader.pickContract(color)
        leader.influence(color, "emperor", 1)
    end)
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goSardaukar(color, leader, continuation)
    -- Used in both 4P and 6P modes.
    if TurnControl.getPlayerCount() < 6 or Commander.isShaddam(color) then
        if MainBoard._checkGenericAccess(color, leader, { spice = MainBoard.getSardaukarCost() }) then
            continuation.run(function ()
                leader.resources(color, "spice", -MainBoard.getSardaukarCost())
                leader.troops(color, "supply", "garrison", 4)
                leader.drawIntrigues(color, 1)
                leader.influence(color, "emperor", 1)
            end)
        else
            continuation.run()
        end
    else
        Dialog.broadcastToColor(I18N("forbiddenAccess"), color, "Purple")
        continuation.run()
    end
end

---@return integer
function MainBoard.getSardaukarCost()
    return TurnControl.getPlayerCount() == 6 and 3 or 4
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goVastWealth(color, leader, continuation)
    assert(TurnControl.getPlayerCount() == 6)
    if Commander.isShaddam(color) then
        continuation.run(function ()
            leader.resources(color, "solari", 3)
            leader.influence(color, "emperor", 1)
        end)
    else
        Dialog.broadcastToColor(I18N("forbiddenAccess"), color, "Purple")
        continuation.run()
    end
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goMilitarySupport(color, leader, continuation)
    assert(TurnControl.getPlayerCount() == 6)
    if MainBoard._checkGenericAccess(color, leader, { spice = 2 }) then
        continuation.run(function ()
            leader.resources(color, "spice", -2)
            leader.influence(color, "greatHouses", 1)
        end)
    else
        continuation.run()
    end
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goEconomicSupport(color, leader, continuation)
    assert(TurnControl.getPlayerCount() == 6)
    continuation.run(function ()
        leader.resources(color, "spice", 1)
        leader.influence(color, "greatHouses", 1)
    end)
end

-- Spacing guild spaces

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goDeliverSupplies(color, leader, continuation)
    continuation.run(function ()
        leader.resources(color, "water", 1)
        leader.influence(color, "spacingGuild", 1)
    end)
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goHeighliner(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { spice = 5 }) then
        continuation.run(function ()
            leader.resources(color, "spice", -5)
            leader.troops(color, "supply", "garrison", 5)
            leader.influence(color, "spacingGuild", 1)
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
                    local limit = PlayBoard.hasTech(otherColor, "geneLockedVault") and 4 or 3
                    if #PlayBoard.getIntrigues(otherColor) > limit then
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

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goEspionage(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { spice = 1 }) then
        continuation.run(function ()
            leader.resources(color, "spice", -1)
            leader.drawImperiumCards(color, 1)
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
function MainBoard._goDesertTactics(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { water = 1 }) then
        continuation.run(function ()
            leader.resources(color, "water", -1)
            leader.troops(color, "supply", "garrison", 1)
            leader.influence(color, "fremen", 1)
        end)
    else
        continuation.run()
    end
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goExpedition(color, leader, continuation)
    assert(TurnControl.getPlayerCount() == 6)
    continuation.run(function ()
        leader.influence(color, "fringeWorlds", 1)
    end)
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goHardyWarriors(color, leader, continuation)
    assert(TurnControl.getPlayerCount() == 6)
    if not Commander.isMuadDib(color) then
        Dialog.broadcastToColor(I18N("forbiddenAccess"), color, "Purple")
        continuation.run()
    elseif MainBoard._checkGenericAccess(color, leader, { water = 1 }) then
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
function MainBoard._goDesertMastery(color, leader, continuation)
    assert(TurnControl.getPlayerCount() == 6)
    if Commander.isMuadDib(color) then
        continuation.run(function ()
            leader.drawImperiumCards(color, 1)
            leader.resources(color, "spice", 1)
            leader.influence(color, "fremen", 1)
        end)
    else
        Dialog.broadcastToColor(I18N("forbiddenAccess"), color, "Purple")
        continuation.run()
    end
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goControversialTechnology(color, leader, continuation)
    assert(TurnControl.getPlayerCount() == 6)
    if MainBoard._checkGenericAccess(color, leader, { spice = 2 }) then
        continuation.run(function ()
            leader.resources(color, "spice", -2)
            leader.drawImperiumCards(color, 1)
            leader.drawIntrigues(color, 1)
            leader.influence(color, "fringeWorlds", 1)
        end)
    else
        continuation.run()
    end
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goFremkit(color, leader, continuation)
    continuation.run(function ()
        leader.drawImperiumCards(color, 1)
        leader.influence(color, "fremen", 1)
    end)
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goHighCouncil(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { solari = 5 }) then
        continuation.run(function ()
            leader.resources(color, "solari", -5)
            if PlayBoard.hasHighCouncilSeat(color) then
                leader.resources(color, "spice", 2)
                leader.drawIntrigues(color, 1)
                leader.troops(color, "supply", "garrison", 3)
            else
                leader.takeHighCouncilSeat(color)
            end
        end)
    else
        continuation.run()
    end
end

-- Landsraad spaces

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goImperialPrivilege(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { solari = 3, friendship = "emperor" }) then
        continuation.run(function ()
            leader.resources(color, "solari", -3)
            leader.drawImperiumCards(color, 1)
        end)
    else
        continuation.run()
    end
end

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
    elseif MainBoard._checkGenericAccess(color, leader, { solari = MainBoard._getSwordmasterCost() }) then
        continuation.run(function ()
            leader.resources(color, "solari", -MainBoard._getSwordmasterCost())
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

---@return integer
function MainBoard._getSwordmasterCost()
    local firstAccess = #Helper.filter(PlayBoard.getActivePlayBoardColors(), PlayBoard.hasSwordmaster) == 0
    return firstAccess and 8 or 6
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goAssemblyHall(color, leader, continuation)
    continuation.run(function ()
        leader.drawIntrigues(color, 1)
        PlayBoard.getResource(color, "persuasion"):setBaseValueContribution("assemblyHall", 1)
    end)
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goGatherSupport(color, leader, continuation)
    if MainBoard._hasResource(leader, color, "solari", 2) then
        local options = {
            I18N("noWaterOption"),
            I18N("withWaterOption"),
        }
        Dialog.showOptionsAndCancelDialog(color, I18N("goGatherSupport"), options, continuation, function (index)
            if index == 1 then
                MainBoard._goGatherSupport_NoWater(color, leader, continuation)
            elseif index == 2 then
                MainBoard._goGatherSupport_WithWater(color, leader, continuation)
            else
                assert(index == 0)
                continuation.run()
            end
        end)
    else
        MainBoard._goGatherSupport_NoWater(color, leader, continuation)
    end
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goGatherSupport_WithWater(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { solari = 2 }) then
        continuation.run(function ()
            leader.resources(color, "solari", -2)
            leader.troops(color, "supply", "garrison", 2)
            leader.resources(color, "water", 1)
        end)
    else
        continuation.run()
    end
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goGatherSupport_NoWater(color, leader, continuation)
    continuation.run(function ()
        leader.troops(color, "supply", "garrison", 2)
    end)
end

-- CHOAM spaces

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goShipping(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { spice = 3, friendship = "spacingGuild" }) then
        continuation.run(function ()
            leader.resources(color, "spice", -3)
            leader.resources(color, "solari", 5)
        end)
    else
        continuation.run()
    end
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goAcceptContract(color, leader, continuation)
    continuation.run(function ()
        leader.pickContract(color)
        leader.drawImperiumCards(color, 1)
    end)
end

-- City spaces

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goCarthag(color, leader, continuation)
    continuation.run(function ()
        leader.drawIntrigues(color, 1)
        leader.troops(color, "supply", "garrison", 1)
    end)
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goSietchTabr(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, leader.name == "lietKynes" and {} or { friendship = "fremen" }) then
        local options = {
            PlayBoard.canTakeMakerHook(color) and I18N("hookTroopWaterOption") or I18N("troopWaterOption"),
            I18N("waterShieldWallOption"),
        }
        Dialog.showOptionsAndCancelDialog(color, I18N("goSietchTabr"), options, continuation, function (index)
            if index == 1 then
                MainBoard._goSietchTabr_HookTroopWater(color, leader, continuation)
            elseif index == 2 then
                MainBoard._goSietchTabr_WaterShieldWall(color, leader, continuation)
            else
                assert(index == 0)
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
function MainBoard._goSietchTabr_HookTroopWater(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, leader.name == "lietKynes" and {} or { friendship = "fremen" }) then
        continuation.run(function ()
            leader.takeMakerHook(color)
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
function MainBoard._goSietchTabr_WaterShieldWall(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, leader.name == "lietKynes" and {} or { friendship = "fremen" }) then
        continuation.run(function ()
            leader.resources(color, "water", 1)
            MainBoard.blowUpShieldWall(color, true)
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
            leader.drawImperiumCards(color, 2)
            if MainBoard.immortalityPatch then
                leader.research(color, nil)
            else
                leader.troops(color, "supply", "garrison", 2)
            end
        end)
    else
        continuation.run()
    end
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goSpiceRefinery(color, leader, continuation)
    if MainBoard._hasResource(leader, color, "spice", 1) then
        local options = {
            I18N("noSpiceOption"),
            I18N("withSpiceOption"),
        }
        Dialog.showOptionsAndCancelDialog(color, I18N("goSpiceRefinery"), options, continuation, function (index)
            if index == 1 then
                MainBoard._goSpiceRefinery_NoSpice(color, leader, continuation)
            elseif index == 2 then
                MainBoard._goSpiceRefinery_WithSpice(color, leader, continuation)
            else
                assert(index == 0)
                continuation.run()
            end
        end)
    else
        MainBoard._goSpiceRefinery_NoSpice(color, leader, continuation)
    end
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goSpiceRefinery_WithSpice(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { spice = 1 }) then
        continuation.run(function ()
            leader.resources(color, "spice", -1)
            leader.resources(color, "solari", 4)
            MainBoard._applyControlOfAnySpace(MainBoard.banners.spiceRefineryBannerZone, "solari")
        end)
    else
        continuation.run()
    end
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goSpiceRefinery_NoSpice(color, leader, continuation)
    continuation.run(function ()
        leader.resources(color, "solari", 2)
        MainBoard._applyControlOfAnySpace(MainBoard.banners.spiceRefineryBannerZone, "solari")
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
function MainBoard._goDeepDesert(color, leader, continuation)
    if PlayBoard.hasMakerHook(color) and (not MainBoard.shieldWallIsStanding() or not Combat.isCurrentConflictBehindTheWall()) then
        local options = {
            I18N("fourSpicesOption"),
            I18N("twoWormsOption"),
        }
        Dialog.showOptionsAndCancelDialog(color, I18N("goDeepDesert"), options, continuation, function (index)
            if index == 1 then
                MainBoard._goDeepDesert_Spice(color, leader, continuation)
            elseif index == 2 then
                MainBoard._goDeepDesert_WormsIfHook(color, leader, continuation)
            else
                assert(index == 0)
                continuation.run()
            end
        end)
    else
        MainBoard._goDeepDesert_Spice(color, leader, continuation)
    end
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goDeepDesert_Spice(color, leader, continuation)
    MainBoard._anySpiceSpace(color, leader, continuation, 3, 4, MainBoard.spiceBonuses.deepDesert)
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goDeepDesert_WormsIfHook(color, leader, continuation)
    if not PlayBoard.hasMakerHook(color) then
        Dialog.broadcastToColor(I18N("noMakerHook"), color, "Purple")
        continuation.run()
    elseif MainBoard.shieldWallIsStanding() and Combat.isCurrentConflictBehindTheWall() then
        Dialog.broadcastToColor(I18N("shieldWallIsStanding"), color, "Purple")
        continuation.run()
    else
        MainBoard._anySpiceSpace(color, leader, continuation, 3, 0, MainBoard.spiceBonuses.deepDesert, function ()
            leader.callSandworm(color, 2)
        end)
    end
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goHabbanyaErg(color, leader, continuation)
    assert(TurnControl.getPlayerCount() == 6)
    MainBoard._anySpiceSpace(color, leader, continuation, 1, 2, MainBoard.spiceBonuses.habbanyaErg, function ()
        leader.drawImperiumCards(color, 1)
    end)
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goHaggaBasin(color, leader, continuation)
    if PlayBoard.hasMakerHook(color) and (not MainBoard.shieldWallIsStanding() or not Combat.isCurrentConflictBehindTheWall()) then
        local options = {
            I18N("twoSpicesOption"),
            I18N("oneWormOption"),
        }
        Dialog.showOptionsAndCancelDialog(color, I18N("goHaggaBasin"), options, continuation, function (index)
            if index == 1 then
                MainBoard._goHaggaBasin_Spice(color, leader, continuation)
            elseif index == 2 then
                MainBoard._goHaggaBasin_WormIfHook(color, leader, continuation)
            else
                assert(index == 0)
                continuation.run()
            end
        end)
    else
        MainBoard._goHaggaBasin_Spice(color, leader, continuation)
    end
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goHaggaBasin_Spice(color, leader, continuation)
    return MainBoard._anySpiceSpace(color, leader, continuation, 1, 2, MainBoard.spiceBonuses.haggaBasin)
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goHaggaBasin_WormIfHook(color, leader, continuation)
    if not PlayBoard.hasMakerHook(color) then
        Dialog.broadcastToColor(I18N("noMakerHook"), color, "Purple")
        continuation.run()
    elseif MainBoard.shieldWallIsStanding() and Combat.isCurrentConflictBehindTheWall() then
        Dialog.broadcastToColor(I18N("shieldWallIsStanding"), color, "Purple")
        continuation.run()
    else
        MainBoard._anySpiceSpace(color, leader, continuation, 1, 0, MainBoard.spiceBonuses.haggaBasin, function ()
            leader.callSandworm(color, 1)
        end)
    end
end

---@param color PlayerColor
---@param leader Leader
---@param continuation Continuation
function MainBoard._goImperialBasin(color, leader, continuation)
    MainBoard._anySpiceSpace(color, leader, continuation, 0, 1, MainBoard.spiceBonuses.imperialBasin, function ()
        MainBoard._applyControlOfAnySpace(MainBoard.banners.imperialBasinBannerZone, "spice")
    end)
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
---@param additionalAction? fun()
function MainBoard._anySpiceSpace(color, leader, continuation, waterCost, spiceBaseAmount, spiceBonus, additionalAction)
    if MainBoard._checkGenericAccess(color, leader, { water = waterCost }) then
        continuation.run(function ()
            leader.resources(color, "water", -waterCost)
            local harvestedSpiceAmount = MainBoard._harvestSpice(spiceBaseAmount, spiceBonus)
            leader.resources(color, "spice", harvestedSpiceAmount)
            if additionalAction then
                additionalAction()
            end
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
    for _, controlableSpaceName in ipairs({ "imperialBasin", "arrakeen", "spiceRefinery" }) do
        if conflictName:find(controlableSpaceName:gsub("^%l", string.upper)) then
            local controlableSpace = MainBoard.findControlableSpace(controlableSpaceName)
            assert(controlableSpace)
            return controlableSpace
        end
    end
    return nil
end

---@param name string
---@return Zone?
function MainBoard.findControlableSpace(name)
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

---@param color PlayerColor
---@param skipConfirmation? boolean
function MainBoard.blowUpShieldWall(color, skipConfirmation)
    if MainBoard.shieldWallToken then
        local kaBoom = function (_)
            Music.play("atomics")
            broadcastToAll(I18N('blowUpShieldWall', { leader = PlayBoard.getLeaderName(color) }), color, "Purple")
            Helper.onceTimeElapsed(3).doAfter(function ()
                MainBoard.trash(MainBoard.shieldWallToken)
                MainBoard.shieldWallToken = nil
            end)
        end

        if skipConfirmation then
            kaBoom()
        else
            Dialog.showConfirmDialog(color, I18N("confirmShieldWallDestruction"), kaBoom)
        end
    end
end

---@return boolean
function MainBoard.shieldWallIsStanding()
    return MainBoard.shieldWallToken ~= nil
end

--- The color could be nil (the same way it could be nil with Types.isAgent)
---@param spaceName string
---@param color? PlayerColor
---@return boolean
function MainBoard.hasAgentInSpace(spaceName, color)
    local space = MainBoard.spaces[spaceName]
    -- A space could be unknown depending on the active extensions.
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
---@param color? PlayerColor
---@return boolean
function MainBoard.hasEnemyAgentInSpace(spaceName, color)
    for _, otherColor in ipairs(PlayBoard.getActivePlayBoardColors()) do
        if otherColor ~= color and MainBoard.hasAgentInSpace(spaceName, otherColor) then
            return true
        end
    end
    return false
end

---@param observationPostName string
---@param color? PlayerColor
---@return boolean
function MainBoard.observationPostIsOccupied(observationPostName, color)
    local observationPost = MainBoard.observationPosts[observationPostName]
    assert(observationPost, observationPostName)
    for _, spy in ipairs(Park.getObjects(observationPost.park)) do
        if not color or spy.hasTag(color) then
            return true
        end
    end
    return false
end

---@param color PlayerColor
---@param onlyInMakerSpace? boolean
---@return integer
function MainBoard.getDeployedSpyCount(color, onlyInMakerSpace)
    local count = 0
    for observationPostName, observationPost in pairs(MainBoard.observationPosts) do
        local ok = true;
        if onlyInMakerSpace then
            ok = false;
            local spaceNames = MainBoard._getConnectedSpaceNames(observationPostName)
            for _, spaceName in ipairs(spaceNames) do
                if MainBoard.isDesertSpace(spaceName) then
                    ok = true;
                    break;
                end
            end
        end
        if ok then
            for _, spy in ipairs(Park.getObjects(observationPost.park)) do
                if spy.hasTag(color) then
                    count = count + 1
                end
            end
        end
    end
    return count
end

---@param observationPostName string
---@return string[]
function MainBoard._getConnectedSpaceNames(observationPostName)
    local connectedSpaceNames = {}
    for spaceName, spaceDetail in pairs(MainBoard.spaceDetails) do
        for _, otherObservationPostName in ipairs(spaceDetail.posts) do
            if otherObservationPostName == observationPostName then
                table.insert(connectedSpaceNames, spaceName)
            end
        end
    end
    return connectedSpaceNames
end

---@param spaceName string
---@param color PlayerColor
---@return boolean
function MainBoard.isSpying(spaceName, color)
    local spaceDetail = MainBoard.spaceDetails[spaceName]
    for _, observationPostName in ipairs(spaceDetail.posts) do
        local observationPost = MainBoard.observationPosts[observationPostName]
        for _, spy in ipairs(Park.getObjects(observationPost.park)) do
            if spy.hasTag(color) then
                return true
            end
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
function MainBoard.isGreatHouses(spaceName)
    return MainBoard.spaceDetails[spaceName].group == "greatHouses"
end

---@param spaceName string
---@return boolean
function MainBoard.isFringeWorlds(spaceName)
    return MainBoard.spaceDetails[spaceName].group == "fringeWorlds"
end

---@param spaceName string
---@return boolean
function MainBoard.isFactionSpace(spaceName)
    return MainBoard.isEmperorSpace(spaceName)
        or MainBoard.isSpacingGuildSpace(spaceName)
        or MainBoard.isBeneGesseritSpace(spaceName)
        or MainBoard.isFremenSpace(spaceName)
        or MainBoard.isGreatHouses(spaceName)
        or MainBoard.isFringeWorlds(spaceName)
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
function MainBoard.isBlueSpace(spaceName)
    return MainBoard.spaceDetails[spaceName].group == "city"
end

---@param spaceName string
---@return boolean
function MainBoard.isYellowSpace(spaceName)
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
function MainBoard.isCombatSpace(spaceName)
    return MainBoard.spaceDetails[spaceName].combat
end

---@return string[]
function MainBoard.getEmperorSpaces()
    local emperorSpaces = {}
    for space, details in pairs(MainBoard.spaceDetails) do
        if Helper.isElementOf(details.group, { "emperor", "greatHouses" }) then
            table.insert(emperorSpaces, space)
        end
    end
    return emperorSpaces
end

---@return string[]
function MainBoard.getGreenSpaces()
    return Helper.filter(Helper.getKeys(MainBoard.spaceDetails), MainBoard.isGreenSpace)
end

---@return Zone[]
function MainBoard.getBannerZones()
    return {
        MainBoard.banners.imperialBasinBannerZone,
        MainBoard.banners.arrakeenBannerZone,
        MainBoard.banners.spiceRefineryBannerZone,
    }
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

    local positions
    if TurnControl.getPlayerCount() == 6 then
        positions = {
            emperor = getAveragePosition({ "militarySupport", "economicSupport" }),
            spacingGuild = getAveragePosition({ "heighliner", "deliverSupplies" }),
            beneGesserit = getAveragePosition({ "espionage", "secrets" }),
            fremen = getAveragePosition({ "controversialTechnology", "expedition" }),
        }
    else
        positions = {
            emperor = getAveragePosition({ "sardaukar", "dutifulService" }),
            spacingGuild = getAveragePosition({ "heighliner", "deliverSupplies" }),
            beneGesserit = getAveragePosition({ "espionage", "secrets" }),
            fremen = getAveragePosition({ "desertTactics", "fremkit" }),
        }
    end

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

---@return Object
function MainBoard.getMainBoard()
    return MainBoard.mainBoard
end

---@param color PlayerColor
---@return Park
function MainBoard.createOtherMemoriesPark(color)

    local origin = MainBoard.spaces.espionage.position + Vector(-0.4, 0, 1.5)
    origin:setAt('y', 1.86) -- ground level
    local slots = {}
    for j = 1, 2 do
        for i = 1, 6 do
            local x = (i - 1.5) * 0.4
            local z = (1.5 - j) * 0.4
            local slot = origin + Vector(x, 0, z)
            table.insert(slots, slot)
        end
    end

    local zone = Park.createTransientBoundingZone(0, Vector(0.25, 0.25, 0.25), slots)

    return Park.createPark(
        "OtherMemories",
        slots,
        Vector(0, 0, 0),
        { zone },
        { "Troop", color },
        nil,
        false,
        true)
end

return MainBoard
