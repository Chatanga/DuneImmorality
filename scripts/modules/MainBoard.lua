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

local MainBoard = {
    spaceDetails = {
        sardaukar = { group = "emperor", posts = { "emperor" } },
        vastWealth = { group = "emperor", posts = { "emperor" } },
        dutifulService = { group = "emperor", posts = { "emperor" } },

        militarySupport = { group = "greatHouses", posts = { "greatHouse" } },
        economicSupport = { group = "greatHouses", posts = { "greatHouse" } },

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
    }
}

---
function MainBoard.onLoad(state)
    Helper.append(MainBoard, Helper.resolveGUIDs(false, {
        board4P = "483a1a",
        board6P = "21cc52",
        emperorBoard = "4cb9ba",
        fremenBoard = "01c575",
        immortalityPatch = "6cf62a",
        spiceBonusTokens = {
            deepDesert = "116807",
            haggaBasin = "c24705",
            imperialBasin = "3cdb2d",
            habbanyaErg = "394db2",
        },
        firstPlayerMarker = "1f5576",
        shieldWallToken = "31d6b0",
    }))
    MainBoard.spiceBonuses = {}

    MainBoard.board = MainBoard.board4P or MainBoard.board6P

    Helper.noPhysicsNorPlay(MainBoard.board)
    Helper.forEachValue(MainBoard.spiceBonusTokens, Helper.noPhysicsNorPlay)

    if state.settings then
        for name, token in pairs(MainBoard.spiceBonusTokens) do
            if token then
                local value = state.MainBoard and state.MainBoard.spiceBonuses[name] or 0
                MainBoard.spiceBonuses[name] = Resource.new(token, nil, "spice", value, name)
            end
        end

        MainBoard._transientSetUp(state.settings)
    end
end

---
function MainBoard.onSave(state)
    state.MainBoard = {
        spiceBonuses = Helper.map(MainBoard.spiceBonuses, function (_, resource)
            return resource:get()
        end),
    }
end

---
function MainBoard.setUp(settings)
    local continuation = Helper.createContinuation("MainBoard.setUp")
    if settings.numberOfPlayers == 6 then
        MainBoard.board.setState(2)
        Helper.onceTimeElapsed(2).doAfter(function ()
            -- Why do I have to reload it now to get the snap points?
            MainBoard.board = getObjectFromGUID("21cc52")
            continuation.run()
        end)
        if settings.immortality then
            local position = MainBoard.immortalityPatch.getPosition()
            MainBoard.immortalityPatch.setPosition(position + Vector(1.6, 0, -1.9))
        end
    else
        MainBoard.emperorBoard.destruct()
        MainBoard.emperorBoard = nil
        MainBoard.fremenBoard.destruct()
        MainBoard.fremenBoard = nil
        MainBoard.spiceBonusTokens.habbanyaErg.destruct()
        MainBoard.spiceBonusTokens.habbanyaErg = nil
        --MainBoard.board.setState(1)
        continuation.run()
    end

    if settings.immortality then
    else
        MainBoard.immortalityPatch.destruct()
        MainBoard.immortalityPatch = nil
    end

    local nextContinuation = Helper.createContinuation("MainBoard.setUp.next")
    continuation.doAfter(function ()
        if settings.language == "fr" then
            MainBoard._mutateMainBoards()
        end
        MainBoard._transientSetUp(settings)
        nextContinuation.run()
    end)

    return nextContinuation
end

---
function MainBoard._mutateMainBoards()
    local boards = {
        board4P = { name = "board", guid = "483a1a", url = "http://cloud-3.steamusercontent.com/ugc/2488878371133395673/8DBDCE4796B52A64AE78D5F95A1CD0B87A87F66D/" },
        board6P = { name = "board", guid = "21cc52", url = "http://cloud-3.steamusercontent.com/ugc/2488878371133398124/5674BB27C821E484B2B85671604BBB1263D024A3/" },
        emperorBoard = { name = "emperorBoard", guid = "4cb9ba", url = "http://cloud-3.steamusercontent.com/ugc/2488878371133395345/C43A9E3E725E49800D2C1952117537CD15F5E058/" },
        fremenBoard = { name = "fremenBoard", guid = "01c575", url = "http://cloud-3.steamusercontent.com/ugc/2488878371133397612/0829FF264AB7DA8B456AB07C4F7522203CB969F3/" },
    }

    for _, boardInfo in pairs(boards) do
        local board = getObjectFromGUID(boardInfo.guid)
        if board then
            local parameters = board.getCustomObject()
            parameters.image = boardInfo.url
            board.setCustomObject(parameters)
            MainBoard[boardInfo.name] = board.reload()
        end
    end
end

---
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
        if phase == "makers" then
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
    local primaryTable = getObjectFromGUID("2b4b92")

    Helper.createAbsoluteButtonWithRoundness(primaryTable, 1, {
        click_function = Helper.registerGlobalCallback(),
        label = I18N("roundNumber"),
        position = primaryTable.getPosition() + Vector(-5, 1.8, -16.5),
        width = 1000,
        height = 200,
        font_size = 140,
        color = { 0, 0, 0, 0 },
        font_color = { 1, 1, 1, 80 },
    })

    Helper.createAbsoluteButtonWithRoundness(primaryTable, 1, {
        click_function = Helper.registerGlobalCallback(),
        position = primaryTable.getPosition() + Vector(-5, 1.8, -17.5),
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

---
function MainBoard._processSnapPoints(settings)
    local highCouncilSeats = {}
    MainBoard.spaces = {}
    MainBoard.observationPosts = {}
    MainBoard.banners = {}

    MainBoard.collectSnapPointsOnAllBoards(settings, {

        seat = function (name, position)
            local str = name:sub(12)
            local index = tonumber(str)
            assert(index, "Not a number: " .. str)
            highCouncilSeats[index] = position
        end,

        space = function (name, position)
            if settings.riseOfIx then
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

        post = function (name, position)
            if settings.riseOfIx then
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
            MainBoard.observationPosts[name] = { name = name, position = position }
        end,

        spice = function (name, position)
            local token = MainBoard.spiceBonusTokens[name]
            token.setPosition(position + Vector(0, -0.05, 0))
            Helper.noPhysics(token)
            if not MainBoard.spiceBonuses[name] then
                MainBoard.spiceBonuses[name] = Resource.new(token, nil, "spice", 0, name)
            end
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

    assert(#highCouncilSeats > 0)
    MainBoard.highCouncilPark = Park.createPark(
        "HighCouncil",
        highCouncilSeats,
        Vector(0, 0, 0),
        { Park.createTransientBoundingZone(0, Vector(0.5, 1, 0.5), highCouncilSeats) },
        { "HighCouncilSeatToken" },
        nil,
        true,
        true)

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
end

---
function MainBoard._getAllBoards(settings)
    assert(MainBoard.board)
    local boards = {
        MainBoard.board
    }
    if settings.numberOfPlayers == 6 then
        assert(MainBoard.emperorBoard)
        table.insert(boards, MainBoard.emperorBoard)
        assert(MainBoard.fremenBoard)
        table.insert(boards, MainBoard.fremenBoard)
    end
    if settings.riseOfIx then
        table.insert(boards, ShippingTrack.getBoard())
        table.insert(boards, TechMarket.getBoard())
    end
    return boards
end

---
function MainBoard.collectSnapPointsOnAllBoards(settings, net)
    for _, board in ipairs(MainBoard._getAllBoards(settings)) do
        Helper.collectSnapPoints(board, net)
    end
end

---
function MainBoard.getHighCouncilSeatPark()
    return MainBoard.highCouncilPark
end

---
function MainBoard.occupy(controlableSpace, color)
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

    local p = controlableSpace.getPosition()
    PlayBoard.getControlMarkerBag(color).takeObject({
        -- Position is adjusted so as to insert the token below any dreadnought.
        position = Vector(p.x, 1.79, p.z),
        rotation = Vector(0, 180, 0),
        smooth = false,
        callback_function = function (controlMarker)
            controlMarker.setLock(true)
        end
    })
end

---
function MainBoard._createSpaceButton(space)
    Helper.createTransientAnchor("AgentPark", space.position - Vector(0, 0.5, 0)).doAfter(function (anchor)
        if MainBoard._findParentSpace(space) == space then

            local p = space.position
            -- FIXME Hardcoded height, use an existing parent anchor.
            local slots = {
                Vector(p.x - 0.36, 1.68, p.z - 0.3),
                Vector(p.x + 0.36, 1.68, p.z + 0.3),
                Vector(p.x - 0.36, 1.68, p.z + 0.3),
                Vector(p.x + 0.36, 1.68, p.z - 0.3)
            }

            space.zone = Park.createTransientBoundingZone(0, Vector(1, 3, 0.7), slots)
            local tags = { "Agent" }
            space.park = Park.createPark("AgentPark", slots, nil, { space.zone }, tags, nil, false, true)
            local snapPoints = {}
            for _, slot in ipairs(slots) do
                table.insert(snapPoints, Helper.createRelativeSnapPoint(anchor, slot, false, tags))
            end
            anchor.setSnapPoints(snapPoints)
        else
            space.zone = Park.createTransientBoundingZone(0, Vector(0.75, 1, 0.75), { space.position })
        end

        local tooltip = I18N("sendAgentTo", { space = I18N(space.name) })
        Helper.createAreaButton(space.zone, anchor, 1.75, tooltip, PlayBoard.withLeader(function (leader, color, altClick)
            if TurnControl.getCurrentPlayer() == color then
                leader.sendAgent(color, space.name, altClick)
            else
                Dialog.broadcastToColor(I18N('notYourTurn'), color, "Purple")
            end
        end))
    end)
end

---
function MainBoard._createObservationPostButton(observationPost)
    local slots = {}
    for i = 1, 4 do
        table.insert(slots, observationPost.position + Vector(0, (i - 1) * 0.5, 0))
    end
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

---
function MainBoard._createBannerSpace(bannerZone)
    Helper.createTransientAnchor("BannerPark", bannerZone.getPosition() - Vector(0, 0.5, 0)).doAfter(function (anchor)
        anchor.setSnapPoints({{
            position = anchor.positionToLocal(bannerZone.getPosition()),
            tags = { "Flag", "Dreadnought" },
            rotation_snap = true,
        }})
    end)
end

function MainBoard._findParentSpace(space)
    return MainBoard.spaces[MainBoard.findParentSpaceName(space.name)]
end

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

---
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

        goSpace(color, leader, innerContinuation)
        innerContinuation.doAfter(function (action)
            -- The innerContinuation never cancels (but returns nil) to allow us to cancel the root continuation.
            if action then
                MainBoard._manageIntelligenceAndInfiltrate(color, parentSpaceName, recallSpy).doAfter(function (goAhead, spy, otherSpy, recallMode)
                    if goAhead then
                        local innerInnerContinuation = Helper.createContinuation("MainBoard." .. spaceName .. ".goAhead")
                        Helper.emitEvent("agentSent", color, parentSpaceName)
                        Action.setContext("agentSent", { space = parentSpaceName, cards = Helper.mapValues(PlayBoard.getCardsPlayedThisTurn(color), Helper.getID) })
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
                                Action.unsetContext("agentSent")
                            end)
                            continuation.run()
                        end)
                    else
                        continuation.cancel()
                    end
                end)
            else
                continuation.cancel()
            end
        end)
    end

    return continuation
end

---
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
    if #candidates == 0 then
        return nil
    elseif #candidates > 1 then
        for i, agent in ipairs(candidates) do
            if agent.hasTag("Swordmaster") then
                table.remove(candidates, i)
                break
            end
        end
    end
    return candidates[1]
end

---
function MainBoard.sendSpy(color, observationPostName)
    local observationPost = MainBoard.observationPosts[observationPostName]
    assert(observationPost, observationPostName)

    local spyPark = PlayBoard.getSpyPark(color)
    if not Park.isEmpty(spyPark) then
        Helper.emitEvent("spySent", color, observationPostName)
        Park.transfert(1, spyPark, observationPost.park)
        return true
    else
        return false
    end
end

---
function MainBoard.recallSpy(color, observationPostName)
    local observationPost = MainBoard.observationPosts[observationPostName]
    assert(observationPost, observationPostName)

    local spyPark = PlayBoard.getSpyPark(color)
    return Park.transfert(1, observationPost.park, spyPark) > 0
end

---
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

---@param recallSpy boolean? Explicitly require the action and fail if it cannot be executed.
---In the case of the "infiltrate + gather intelligence" combo , only applies to the first.
function MainBoard._manageIntelligenceAndInfiltrate(color, spaceName, recallSpy)
    local continuation = Helper.createContinuation("MainBoard._manageIntelligenceAndInfiltrate")

    local recallableSpies = MainBoard.getRecallableSpies(color, spaceName)

    local hasCardsToDraw = PlayBoard.getDrawDeck(color) or PlayBoard.getDiscard(color)

    local details = MainBoard.spaceDetails[spaceName]
    assert(details, spaceName)
    -- TODO Take care of special cases such as Ariana Thorvald ability?

    -- We have already verified that there is no agent of the same color,
    -- so any remaining agent must be an enemy.
    local enemyAgentPresent = MainBoard.hasAgentInSpace(spaceName)

    if not enemyAgentPresent then
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

---
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

---
function MainBoard.sendRivalAgent(color, spaceName)
    local space = MainBoard.spaces[spaceName]
    if not Park.isEmpty(PlayBoard.getAgentPark(color)) then
        local agentPark = PlayBoard.getAgentPark(color)
        Helper.emitEvent("agentSent", color, spaceName)
        Action.setContext("agentSent", { space = spaceName })
        Park.transfert(1, agentPark, space.park)
        return true
    else
        return false
    end
end

---
function MainBoard._hasResource(leader, color, resourceName, amount)
    local realAmount = leader.bargain(color, resourceName, amount)
    return PlayBoard.getResource(color, resourceName):get() >= realAmount
end

---
function MainBoard._checkGenericAccess(color, leader, requirements)
    if PlayBoard.isRival(color) then
        return true
    end

    for requirement, value in pairs(requirements) do
        if Helper.isElementOf(requirement, { "spice", "water", "solari" }) then
            if not MainBoard._hasResource(leader, color, requirement, value) then
                Dialog.broadcastToColor(I18N("noResource", { resource = I18N(requirement .. "Amount") }), color, "Purple")
                return false
            end
        elseif requirement == "friendship" then
            local infiltrationCards = {
                "kwisatzHaderach",
                "guildAccord",
                "choamDelegate",
                "bountyHunter",
                "embeddedAgent",
                "tleilaxuInfiltrator",
                "undercoverAsset",
            }
            for _, cardName in ipairs(infiltrationCards) do
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

---
function MainBoard._goFremkit(color, leader, continuation)
    continuation.run(function ()
        leader.drawImperiumCards(color, 1)
        leader.influence(color, "fremen", 1)
    end)
end

---
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

---
function MainBoard._goSecrets(color, leader, continuation)
    continuation.run(function ()
        leader.drawIntrigues(color, 1)
        for _, otherColor in ipairs(PlayBoard.getActivePlayBoardColors()) do
            if otherColor ~= color then
                if #PlayBoard.getIntrigues(otherColor) > 3 then
                    leader.stealIntrigue(color, otherColor, 1)
                end
            end
        end
        leader.influence(color, "beneGesserit", 1)
    end)
end

---
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

---
function MainBoard._goDeliverSupplies(color, leader, continuation)
    continuation.run(function ()
        leader.resources(color, "water", 1)
        leader.influence(color, "spacingGuild", 1)
    end)
end

---
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

---
function MainBoard._goDutifulService(color, leader, continuation)
    assert(TurnControl.getPlayerCount() < 6)
    continuation.run(function ()
        leader.pickContract(color)
        leader.influence(color, "emperor", 1)
    end)
end

---
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

---
function MainBoard.getSardaukarCost()
    return TurnControl.getPlayerCount() == 6 and 3 or 4
end

---
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

---
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

---
function MainBoard._goEconomicSupport(color, leader, continuation)
    assert(TurnControl.getPlayerCount() == 6)
    continuation.run(function ()
        leader.resources(color, "spice", 1)
        leader.influence(color, "greatHouses", 1)
    end)
end

---
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

---
function MainBoard._goExpedition(color, leader, continuation)
    assert(TurnControl.getPlayerCount() == 6)
    continuation.run(function ()
        leader.influence(color, "fringeWorlds", 1)
    end)
end

---
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

---
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

---
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

---
function MainBoard._goSwordmaster(color, leader, continuation)
    if PlayBoard.hasSwordmaster(color) then
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

---
function MainBoard._getSwordmasterCost()
    local firstAccess = #Helper.filter(PlayBoard.getActivePlayBoardColors(), PlayBoard.hasSwordmaster) == 0
    return firstAccess and 8 or 6
end

---
function MainBoard._goAssemblyHall(color, leader, continuation)
    continuation.run(function ()
        leader.drawIntrigues(color, 1)
        leader.resources(color, "persuasion", 1)
    end)
end

---
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

---
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

---
function MainBoard._goGatherSupport_NoWater(color, leader, continuation)
    continuation.run(function ()
        leader.troops(color, "supply", "garrison", 2)
    end)
end

---
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

---
function MainBoard._goAcceptContract(color, leader, continuation)
    continuation.run(function ()
        leader.pickContract(color)
        leader.drawImperiumCards(color, 1)
    end)
end

---
function MainBoard._goCarthag(color, leader, continuation)
    continuation.run(function ()
        leader.drawIntrigues(color, 1)
        leader.troops(color, "supply", "garrison", 1)
    end)
end

---
function MainBoard._goSietchTabr(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { friendship = "fremen" }) then
        local options = {
            I18N("hookTroopWaterOption"),
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

---
function MainBoard._goSietchTabr_HookTroopWater(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { friendship = "fremen" }) then
        continuation.run(function ()
            leader.takeMakerHook(color)
            leader.troops(color, "supply", "garrison", 1)
            leader.resources(color, "water", 1)
        end)
    else
        continuation.run()
    end
end

---
function MainBoard._goSietchTabr_WaterShieldWall(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { friendship = "fremen" }) then
        continuation.run(function ()
            leader.resources(color, "water", 1)
            MainBoard.blowUpShieldWall(color, true)
        end)
    else
        continuation.run()
    end
end

---
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

---
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

---
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

---
function MainBoard._goSpiceRefinery_NoSpice(color, leader, continuation)
    continuation.run(function ()
        leader.resources(color, "solari", 2)
        MainBoard._applyControlOfAnySpace(MainBoard.banners.spiceRefineryBannerZone, "solari")
    end)
end

---
function MainBoard._goArrakeen(color, leader, continuation)
    continuation.run(function ()
        leader.troops(color, "supply", "garrison", 1)
        leader.drawImperiumCards(color, 1)
        MainBoard._applyControlOfAnySpace(MainBoard.banners.arrakeenBannerZone, "solari")
    end)
end

---
function MainBoard._goDeepDesert(color, leader, continuation)
    if PlayBoard.hasMakerHook(color) then
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

---
function MainBoard._goDeepDesert_Spice(color, leader, continuation)
    MainBoard._anySpiceSpace(color, leader, 3, 4, MainBoard.spiceBonuses.deepDesert, continuation)
end

---
function MainBoard._goDeepDesert_WormsIfHook(color, leader, continuation)
    if not PlayBoard.hasMakerHook(color) then
        Dialog.broadcastToColor(I18N("noMakerHook"), color, "Purple")
        continuation.run()
    elseif MainBoard.shieldWallIsStanding() and Combat.isCurrentConflictBehindTheWall() then
        Dialog.broadcastToColor(I18N("shieldWallIsStanding"), color, "Purple")
        continuation.run()
    else
        MainBoard._anySpiceSpace(color, leader, 3, 0, MainBoard.spiceBonuses.deepDesert, continuation, function ()
            leader.callSandworm(color, 2)
        end)
    end
end

---
function MainBoard._goHabbanyaErg(color, leader, continuation)
    assert(TurnControl.getPlayerCount() == 6)
    MainBoard._anySpiceSpace(color, leader, 1, 2, MainBoard.spiceBonuses.habbanyaErg, continuation, function ()
        leader.drawImperiumCards(color, 1)
    end)
end

---
function MainBoard._goHaggaBasin(color, leader, continuation)
    if PlayBoard.hasMakerHook(color) then
        local options = {
            I18N("twoSpicesOption"),
            I18N("onWormOption"),
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

---
function MainBoard._goHaggaBasin_Spice(color, leader, continuation)
    return MainBoard._anySpiceSpace(color, leader, 1, 2, MainBoard.spiceBonuses.haggaBasin, continuation)
end

---
function MainBoard._goHaggaBasin_WormIfHook(color, leader, continuation)
    if not PlayBoard.hasMakerHook(color) then
        Dialog.broadcastToColor(I18N("noMakerHook"), color, "Purple")
        continuation.run()
    elseif MainBoard.shieldWallIsStanding() and Combat.isCurrentConflictBehindTheWall() then
        Dialog.broadcastToColor(I18N("shieldWallIsStanding"), color, "Purple")
        continuation.run()
    else
        MainBoard._anySpiceSpace(color, leader, 1, 0, MainBoard.spiceBonuses.haggaBasin, continuation, function ()
            leader.callSandworm(color, 1)
        end)
    end
end

---
function MainBoard._goImperialBasin(color, leader, continuation)
    MainBoard._anySpiceSpace(color, leader, 0, 1, MainBoard.spiceBonuses.imperialBasin, continuation, function ()
        MainBoard._applyControlOfAnySpace(MainBoard.banners.imperialBasinBannerZone, "spice")
    end)
end

---
function MainBoard._anySpiceSpace(color, leader, waterCost, spiceBaseAmount, spiceBonus, continuation, additionalAction)
    if MainBoard._checkGenericAccess(color, leader, { water = waterCost }) then
        continuation.run(function ()
            local harvestedSpiceAmount = MainBoard._harvestSpice(spiceBaseAmount, spiceBonus)
            leader.resources(color, "water", -waterCost)
            leader.resources(color, "spice", harvestedSpiceAmount)
            if additionalAction then
                additionalAction()
            end
        end)
    else
        continuation.run()
    end
end

---
function MainBoard.getSpiceBonus(desertSpaceName)
    assert(MainBoard.isDesertSpace(desertSpaceName))
    return MainBoard.spiceBonuses[desertSpaceName]
end

---
function MainBoard._harvestSpice(baseAmount, spiceBonus)
    assert(spiceBonus)
    local spiceAmount = baseAmount + spiceBonus:get()
    spiceBonus:set(0)
    return spiceAmount
end

---
function MainBoard._applyControlOfAnySpace(bannerZone, resourceName)
    local controllingPlayer = MainBoard.getControllingPlayer(bannerZone)
    if controllingPlayer then
        PlayBoard.getLeader(controllingPlayer).resources(controllingPlayer, resourceName, 1)
    end
    return true
end

---
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
        return MainBoard._applyControlOfAnySpace(bannerZone, resourceName)
    else
        return false
    end
end

---
function MainBoard.findControlableSpace(name)
    for bannerZoneName, zone in pairs(MainBoard.banners) do
        if Helper.startsWith(bannerZoneName, name) then
            return zone
        end
    end
    return nil
end

---
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

---
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

---
function MainBoard._goSmuggling(color, leader, continuation)
    continuation.run(function ()
        leader.resources(color, "solari", 1)
        leader.shipments(color, 1)
    end)
end

---
function MainBoard._goInterstellarShipping(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { friendship = "spacingGuild" }) then
        continuation.run(function ()
            leader.shipments(color, 2)
        end)
    else
        continuation.run()
    end
end

function MainBoard._goTechNegotiation(color, leader, continuation)
    local options = {
        I18N("sendNegotiatorOption"),
        I18N("buyTechWithDiscont1Option"),
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
    return continuation
end

function MainBoard._goTechNegotiation_Buy(color, leader, continuation)
    continuation.run(function ()
        leader.resources(color, "persuasion", 1)
        TechMarket.registerAcquireTechOption(color, "techNegotiationTechBuyOption", "spice", 1)
    end)
end

function MainBoard._goTechNegotiation_Negotiate(color, leader, continuation)
    continuation.run(function ()
        leader.resources(color, "persuasion", 1)
        leader.troops(color, "supply", "negotiation", 1)
    end)
end

---
function MainBoard._goDreadnought(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { solari = 3 }) then
        continuation.run(function ()
            leader.resources(color, "solari", -3)
            TechMarket.registerAcquireTechOption(color, "dreadnoughtTechBuyOption", "spice", 0)
            Park.transfert(1, PlayBoard.getDreadnoughtPark(color), Combat.getDreadnoughtPark(color))
        end)
    else
        continuation.run()
    end
end

---
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

---
function MainBoard.shieldWallIsStanding()
    return MainBoard.shieldWallToken ~= nil
end

--- The color could be nil (the same way it could be nil with Types.isAgent)
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

---
function MainBoard.hasEnemyAgentInSpace(spaceName, color)
    for _, otherColor in ipairs(PlayBoard.getActivePlayBoardColors()) do
        if otherColor ~= color and MainBoard.hasAgentInSpace(spaceName, otherColor) then
            return true
        end
    end
    return false
end

---
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

---
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

---
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

--
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

---
function MainBoard.hasVoiceToken(spaceName)
    local space = MainBoard.spaces[spaceName]
    if space then
        return #Helper.filter(space.zone.getObjects(), Types.isVoiceToken) > 0
    end
    return false
end

---
function MainBoard.isEmperorSpace(spaceName)
    return MainBoard.spaceDetails[spaceName].group == "emperor"
end

---
function MainBoard.isSpacingGuildSpace(spaceName)
    return MainBoard.spaceDetails[spaceName].group == "spacingGuild"
end

---
function MainBoard.isBeneGesseritSpace(spaceName)
    return MainBoard.spaceDetails[spaceName].group == "beneGesserit"
end

---
function MainBoard.isFremenSpace(spaceName)
    return MainBoard.spaceDetails[spaceName].group == "fremen"
end

---
function MainBoard.isGreatHouses(spaceName)
    return MainBoard.spaceDetails[spaceName].group == "greatHouses"
end

---
function MainBoard.isFringeWorlds(spaceName)
    return MainBoard.spaceDetails[spaceName].group == "fringeWorlds"
end

---
function MainBoard.isFactionSpace(spaceName)
    return MainBoard.isEmperorSpace(spaceName)
        or MainBoard.isSpacingGuildSpace(spaceName)
        or MainBoard.isBeneGesseritSpace(spaceName)
        or MainBoard.isFremenSpace(spaceName)
        or MainBoard.isGreatHouses(spaceName)
        or MainBoard.isFringeWorlds(spaceName)
end

---
function MainBoard.isCitySpace(spaceName)
    return MainBoard.spaceDetails[spaceName].group == "city"
end

--- aka Maker space
function MainBoard.isDesertSpace(spaceName)
    return MainBoard.spaceDetails[spaceName].group == "desert"
end

---
function MainBoard.isSpiceTradeSpace(spaceName)
    return MainBoard.isDesertSpace(spaceName)
        or MainBoard.isCHOAMSpace(spaceName)
end

---
function MainBoard.isCombatSpace(spaceName)
    return MainBoard.spaceDetails[spaceName].combat
end

---
function MainBoard.getBannerZones()
    return {
        MainBoard.banners.imperialBasinBannerZone,
        MainBoard.banners.arrakeenBannerZone,
        MainBoard.banners.spiceRefineryBannerZone,
    }
end

---
function MainBoard.addSpaceBonus(spaceName, bonuses)
    local space = MainBoard.spaces[spaceName]
    assert(space, "Unknown space: " .. tostring(spaceName))
end

---
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

---
function MainBoard.getFirstPlayerMarker()
    return MainBoard.firstPlayerMarker
end

---
function MainBoard.trash(object)
    MainBoard.trashQueue = MainBoard.trashQueue or Helper.createSpaceQueue()
    MainBoard.trashQueue.submit(function (height)
        object.interactable = true
        object.setLock(false)
        object.setPosition(getObjectFromGUID('ef8614').getPosition() + Vector(0, 1 + height * 0.5, 0))
    end)
end

---
function MainBoard.isInside(object)
    local position = object.getPosition()
    local center = MainBoard.board.getPosition()
    local offset = position - center
    return math.abs(offset.x) < 11 and math.abs(offset.z) < 11
end

return MainBoard
