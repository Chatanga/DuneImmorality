local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")
local I18N = require("utils.I18N")

local Types = Module.lazyRequire("Types")
local PlayBoard = Module.lazyRequire("PlayBoard")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")
local TechMarket = Module.lazyRequire("TechMarket")
local Combat = Module.lazyRequire("Combat")
local Hagal = Module.lazyRequire("Hagal")
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

        techNegotiation = { group = "ix", posts = {} },
        dreadnought = { group = "ix", posts = {} },

        shipping = { group = "choam", posts = { "choam" } },
        acceptContract = { group = "choam", posts = { "choam" } },

        smuggling = { group = "choam", posts = {} },
        interstellarShipping = { group = "choam", posts = {} },

        sietchTabr = { group = "city", combat = true, posts = { "sietchTabrResearchStation" } },
        researchStation = { group = "city", combat = true, posts = { "sietchTabrResearchStation", "researchStationSpiceRefinery" } },
        researchStationImmortality = { group = "city", combat = true, posts = {} },
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
function MainBoard.rebuild()
    --local destination = getObjectFromGUID("483a1a") -- 4P
    local destination = getObjectFromGUID("21cc52") -- 6P
    --local destination = getObjectFromGUID("4cb9ba") -- Emperor
    --local destination = getObjectFromGUID("01c575") -- Fremen
    --local destination = getObjectFromGUID("d75455") -- Ix
    assert(destination)

    local snapPoints = {}

    for _, snapPoint in ipairs(destination.getSnapPoints()) do
        Helper.dump("Snap:", snapPoint.tags)
        table.insert(snapPoints, snapPoint)
    end

    local rejectedCount = 0
    for _, snapPoint in ipairs(Global.getSnapPoints()) do
        if #snapPoint.tags > 0 then
            if #snapPoint.tags > 1 then
                Helper.dump("Not a unique tag:", snapPoint.tags)
            end
            Helper.dump("Snap:", snapPoint.tags)
            table.insert(snapPoints, {
                position = destination.positionToLocal(snapPoint.position),
                tags = snapPoint.tags,
                rotation_snap = snapPoint.rotation_snap,
            })
        else
            rejectedCount = rejectedCount + 1
        end
    end
    Helper.dump("Rejected:", rejectedCount, "/", #Global.getSnapPoints())

    destination.setSnapPoints(snapPoints)
    Global.setSnapPoints({})
end

---
function MainBoard.rebuildAlt()
    local destination = getObjectFromGUID("483a1a") -- 4P
    --local destination = getObjectFromGUID("21cc52") -- 6P

    local snapPoints = {}

    for _, snapPoint in ipairs(destination.getSnapPoints()) do
        Helper.dump("Snap:", snapPoint.tags)

        local position = snapPoint.position
        position:scale(5.945034 / 11.2)
        --position:setAt("y", position.y + 0.5)
        --position:setAt("z", position.z - 1.88)

        table.insert(snapPoints, snapPoint)
    end

    destination.setSnapPoints(snapPoints)
    Global.setSnapPoints({})
end

---
function MainBoard.onLoad(state)
    --Helper.dumpFunction("MainBoard.onLoad(...)")

    Helper.append(MainBoard, Helper.resolveGUIDs(false, {
        board = "21cc52", -- 4P: "483a1a", 6P: "21cc52"
        emperorBoard = "4cb9ba",
        fremenBoard = "01c575",
        factions = {
            emperor = {
                alliance = "13e990",
                twoInfluencesBag = "6a4186",
                Green = "d7c9ba",
                Yellow = "489871",
                Blue = "426a23",
                Red = "acfcef"
            },
            spacingGuild = {
                alliance = "ad1aae",
                twoInfluencesBag = "400d45",
                Green = "89da7d",
                Yellow = "9d0075",
                Blue = "4069d8",
                Red = "be464e"
            },
            beneGesserit = {
                alliance = "33452e",
                twoInfluencesBag = "e763f6",
                Green = "2dc980",
                Yellow = "a3729e",
                Blue = "2a88a6",
                Red = "713eae"
            },
            fremen = {
                alliance = "4c2bcc",
                twoInfluencesBag = "8bcfe7",
                Green = "d390dc",
                Yellow = "77d7c8",
                Blue = "0e6e41",
                Red = "088f51"
            }
        },
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

    Helper.noPhysicsNorPlay(MainBoard.board)
    Helper.forEachValue(MainBoard.spiceBonusTokens, Helper.noPhysicsNorPlay)

    if state.settings then
        for name, token in pairs(MainBoard.spiceBonusTokens) do
            if token then
                local value = state.MainBoard and state.MainBoard.spiceBonuses[name] or 0
                MainBoard.spiceBonuses[name] = Resource.new(token, nil, "spice", value, name)
            end
        end

        MainBoard._staticSetUp(state.settings)
    end
end

---
function MainBoard.onSave(state)
    --Helper.dumpFunction("MainBoard.onSave")
    state.MainBoard = {
        spiceBonuses = Helper.map(MainBoard.spiceBonuses, function (_, resource)
            return resource:get()
        end),
    }
end

---
function MainBoard.setUp(settings)
    if settings.numberOfPlayers == 6 then
        --MainBoard.board.setState(2)
    else
        MainBoard.board.setState(1)
        MainBoard.emperorBoard.destruct()
        MainBoard.emperorBoard = nil
        MainBoard.fremenBoard.destruct()
        MainBoard.fremenBoard = nil
        MainBoard.spiceBonusTokens.habbanyaErg.destruct()
        MainBoard.spiceBonusTokens.habbanyaErg = nil
    end

    if settings.language == "fr" then
        MainBoard._mutateMainBoards()
    end

    Helper.createAbsoluteButtonWithRoundness(MainBoard.shieldWallToken, 7, false, {
        click_function = Helper.registerGlobalCallback(function (_, color, _)
            MainBoard.blowUpShieldWall(color)
        end),
        position = MainBoard.shieldWallToken.getPosition() + Vector(0.2, 0.1, 0.2),
        width = 800,
        height = 800,
        color = {0, 0, 0, 0},
        tooltip = I18N("explosion")
    })

    MainBoard._staticSetUp(settings)
end

---
function MainBoard._mutateMainBoards()
    local boards = {
        board4P = { guid = "483a1a", url = "http://cloud-3.steamusercontent.com/ugc/2305342013587677822/8DBDCE4796B52A64AE78D5F95A1CD0B87A87F66D/" },
        board6P = { guid = "21cc52", url = "http://cloud-3.steamusercontent.com/ugc/2306470076750286375/5674BB27C821E484B2B85671604BBB1263D024A3/" },
        emperorBoard = { guid = "4cb9ba", url = "http://cloud-3.steamusercontent.com/ugc/2306470076750293188/C43A9E3E725E49800D2C1952117537CD15F5E058/" },
        fremenBoard = { guid = "01c575", url = "http://cloud-3.steamusercontent.com/ugc/2306470076750293361/0829FF264AB7DA8B456AB07C4F7522203CB969F3/" },
    }

    for name, boardInfo in pairs(boards) do
        local board = getObjectFromGUID(boardInfo.guid)
        if board then
            --Helper.dump("Mutating board " .. name)
            local parameters = board.getCustomObject()
            parameters.image = boardInfo.url
            board.setCustomObject(parameters)
            board.reload()
        end
    end
end

---
function MainBoard._staticSetUp(settings)
    MainBoard._processSnapPoints(settings)

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
                                        --Helper.dump("Recalling a", color, "agent ->", PlayBoard.getAgentPark(color).name)
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

---
function MainBoard._processSnapPoints(settings)
    local highCouncilSeats = {}
    MainBoard.spaces = {}
    MainBoard.observationPosts = {}
    MainBoard.banners = {}

    local net = {
        seat = function (name, position)
            local str = name:sub(12)
            local index = tonumber(str)
            assert(index, "Not a number: " .. str)
            highCouncilSeats[index] = position
        end,
        space = function (name, position)
            MainBoard.spaces[name] = { name = name, position = position }
        end,
        post = function (name, position)
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
    }

    MainBoard.collectSnapPointsEverywhere(settings, net)

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
function MainBoard.collectSnapPointsEverywhere(settings, net)
    if settings.numberOfPlayers == 6 then
        Helper.collectSnapPoints(net, getObjectFromGUID("21cc52"))
        Helper.collectSnapPoints(net, getObjectFromGUID("4cb9ba"))
        Helper.collectSnapPoints(net, getObjectFromGUID("01c575"))
    else
        Helper.collectSnapPoints(net, getObjectFromGUID("483a1a"))
    end
    if settings.riseOfIx then
        Helper.collectSnapPoints(TechMarket.board)
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
        position = Vector(p.x, 0.78, p.z),
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
                Vector(p.x - 0.36, 0.68, p.z - 0.3),
                Vector(p.x + 0.36, 0.68, p.z + 0.3),
                Vector(p.x - 0.36, 0.68, p.z + 0.3),
                Vector(p.x + 0.36, 0.68, p.z - 0.3)
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

        local tooltip = I18N("sendAgentTo", { space = I18N(space.name)})
        Helper.createAreaButton(space.zone, anchor, 0.75, tooltip, PlayBoard.withLeader(function (leader, color, altClick)
            if TurnControl.getCurrentPlayer() == color then
                leader.sendAgent(color, space.name, altClick)
            else
                broadcastToColor(I18N('noYourTurn'), color, "Purple")
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
        Helper.createAreaButton(observationPost.zone, anchor, 0.75, tooltip, PlayBoard.withLeader(function (leader, color, altClick)
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

---
function MainBoard._findParentSpace(space)
    local parentSpace = space
    local underscoreIndex = space.name:find("_")
    if underscoreIndex then
        local parentSpaceName = space.name:sub(1, underscoreIndex - 1)
        parentSpace = MainBoard.spaces[parentSpaceName]
        assert(parentSpace, "No parent space name named: " .. parentSpaceName)
    end
    return parentSpace
end

---
function MainBoard.sendAgent(color, spaceName, recallSpy)
    local continuation = Helper.createContinuation("MainBoard.sendAgent")

    local space = MainBoard.spaces[spaceName]
    local parentSpace = MainBoard._findParentSpace(space)

    local asyncActionName = Helper.toCamelCase("_asyncGo", space.name)
    local actionName = Helper.toCamelCase("_go", space.name)

    local asyncAction = MainBoard[asyncActionName]
    local action = MainBoard[actionName]
    local leader = PlayBoard.getLeader(color)

    local agent = MainBoard.findProperAgent(color)

    if agent then
        if recallSpy then
            MainBoard._recallSpy(color, leader, spaceName)
        end
        if asyncAction then
            Helper.emitEvent("agentSent", color, spaceName)
            Action.setContext("agentSent", spaceName)
            asyncAction(color, leader).doAfter(function (success)
                Action.setContext("agentSent", nil)
                if success then
                    Park.putObject(agent, parentSpace.park)
                    continuation.run(true)
                else
                    continuation.run(false)
                end
            end)
        elseif action then
            Helper.emitEvent("agentSent", color, spaceName)
            Action.setContext("agentSent", spaceName)
            if action(color, leader) then
                Action.setContext("agentSent", nil)
                Park.putObject(agent, parentSpace.park)
                continuation.run(true)
            else
                continuation.run(false)
            end
        else
            error("Unknow space action: " .. actionName)
        end
    else
        continuation.run(false)
    end

    return continuation
end

---
function MainBoard.findProperAgent(color)
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
    local continuation = Helper.createContinuation("MainBoard.sendSpy")

    local observationPost = MainBoard.observationPosts[observationPostName]

    if not Park.isEmpty(PlayBoard.getSpyPark(color)) then
        local spyPark = PlayBoard.getSpyPark(color)
        Helper.emitEvent("spySent", color, observationPostName)
        --log("Park.transfert(1, agentPark, parentSpace.park)")
        Park.transfert(1, spyPark, observationPost.park)
        continuation.run(true)
    else
        continuation.run(false)
    end

    return continuation
end

---
function MainBoard._recallSpy(color, leader, spaceName)
    Helper.dumpFunction("MainBoard._recallSpy", color, leader, spaceName)
    local details = MainBoard.spaceDetails[spaceName]
    assert(details, spaceName)

    if PlayBoard.getDrawDeck(color) then
        local recallableSpies = {}

        for _, postName in ipairs(details.posts) do
            local observationPost = MainBoard.observationPosts[postName]
            assert(observationPost, postName)
            for _, spy in ipairs(Park.getObjects(observationPost.park)) do
                if spy.hasTag(color) then
                    table.insert(recallableSpies, spy)
                    break
                end
            end
        end

        local continuation = Helper.createContinuation("MainBoard._recallSpy")
        if #recallableSpies >= 1 then
            if #recallableSpies > 1 then
                log("Selecting an arbitrary spy at the research station.")
            end
            local spyPark = PlayBoard.getSpyPark(color)
            Park.putObject(recallableSpies[1], spyPark)
            leader.drawImperiumCards(color, 1)
        else
            continuation.cancel()
        end
    end
end

---
function MainBoard.sendRivalAgent(color, spaceName)
    local space = MainBoard.spaces[spaceName]
    if not Park.isEmpty(PlayBoard.getAgentPark(color)) then
        local agentPark = PlayBoard.getAgentPark(color)
        Helper.emitEvent("agentSent", color, spaceName)
        Park.transfert(1, agentPark, space.park)
        return true
    else
        return false
    end
end

---
function MainBoard._goFremkit(color, leader)
    leader.drawImperiumCards(color, 1)
    leader.influence(color, "fremen", 1, true)
    return true
end

---
function MainBoard._goDesertTactics(color, leader)
    if leader.resources(color, "water", -1) then
        leader.troops(color, "supply", "garrison", 1)
        leader.influence(color, "fremen", 1, true)
        return true
    else
        return false
    end
end

---
function MainBoard._goSecrets(color, leader)
    leader.drawIntrigues(color, 1)
    for _, otherColor in ipairs(PlayBoard.getActivePlayBoardColors()) do
        if otherColor ~= color then
            if #PlayBoard.getIntrigues(otherColor) > 3 then
                leader.stealIntrigue(color, otherColor, 1)
            end
        end
    end
    leader.influence(color, "beneGesserit", 1)
    return true
end

---
function MainBoard._goEspionage(color, leader)
    if leader.resources(color, "spice", -1) then
        leader.drawImperiumCards(color, 1)
        leader.influence(color, "beneGesserit", 1)
        return true
    else
        return false
    end
end

---
function MainBoard._goDeliverSupplies(color, leader)
    leader.resources(color, "water", 1)
    leader.influence(color, "spacingGuild", 1)
    return true
end

---
function MainBoard._goHeighliner(color, leader)
    if leader.resources(color, "spice", -5) then
        leader.troops(color, "supply", "garrison", 5)
        leader.influence(color, "spacingGuild", 1)
        return true
    else
        return false
    end
end

---
function MainBoard._goDutifulService(color, leader)
    leader.influence(color, "emperor", 1, true)
    return true
end

---
function MainBoard._goSardaukar(color, leader)
    if TurnControl.getPlayerCount() < 6 or Commander.isShaddam(color) then
        local cost = Commander.isShaddam(leader) and 4 or 3
        if leader.resources(color, "spice", -cost) then
            --leader.troops(color, "supply", "garrison", 4)
            leader.drawIntrigues(color, 1)
            leader.influence(color, "emperor", 1, true)
            return true
        else
            return false
        end
    end
end

---
function MainBoard._goVastWealth(color, leader)
    if TurnControl.getPlayerCount() < 6 or Commander.isShaddam(color) then
        leader.resources(color, "solari", 3)
        leader.influence(color, "emperor", 1, true)
        return true
    else
        return false
    end
end

---
function MainBoard._goMilitarySupport(color, leader)
    if leader.resources(color, "spice", -2) then
        leader.influence(color, "greatHouses", 1)
        return true
    else
        return false
    end
end

---
function MainBoard._goEconomicSupport(color, leader)
    leader.resources(color, "spice", 1)
    leader.influence(color, "greatHouses", 1)
    return true
end

---
function MainBoard._goControversialTechnology(color, leader)
    if leader.resources(color, "spice", -2) then
        leader.drawImperiumCards(color, 1)
        leader.drawIntrigues(color, 1)
        leader.influence(color, "fringeWorlds", 1)
        return true
    else
        return false
    end
end

---
function MainBoard._goExpedition(color, leader)
    leader.influence(color, "fringeWorlds", 1)
    return true
end

---
function MainBoard._goHardyWarriors(color, leader)
    if TurnControl.getPlayerCount() < 6 or Commander.isMuadDib(color) then
        if leader.resources(color, "water", -1) then
            leader.troops(color, "supply", "garrison", 2)
            leader.influence(color, "fremen", 1, true)
            return true
        else
            return false
        end
    else
        return false
    end
end

---
function MainBoard._goDesertMastery(color, leader)
    if TurnControl.getPlayerCount() < 6 or Commander.isMuadDib(color) then
        leader.drawImperiumCards(color, 1)
        leader.resources(color, "spice", 1)
        leader.influence(color, "fremen", 1, true)
        return true
    else
        return false
    end
end

---
function MainBoard._goHighCouncil(color, leader)
    if leader.resources(color, "solari", -5) then
        if PlayBoard.hasHighCouncilSeat(color) then
            leader.resources(color, "spice", 2)
            leader.drawIntrigues(color, 1)
            leader.troops(color, "supply", "garrison", 3)
            return true
        else
            return leader.takeHighCouncilSeat(color)
        end
    else
        return false
    end
end

---
function MainBoard._goImperialPrivilege(color, leader)
    if InfluenceTrack.hasFriendship(color, "emperor") and leader.resources(color, "solari", -3) then
        leader.drawImperiumCards(color, 1)
        return true
    else
        return false
    end
end

---
function MainBoard._goSwordmaster(color, leader)
    local firstAccess = #Helper.filter(PlayBoard.getActivePlayBoardColors(), PlayBoard.hasSwordmaster) == 0
    if not PlayBoard.hasSwordmaster(color) and leader.resources(color, "solari", firstAccess and -8 or -6) then
        leader.recruitSwordmaster(color)
        return true
    else
        return false
    end
end

---
function MainBoard._goAssemblyHall(color, leader)
    leader.drawIntrigues(color, 1)
    leader.resources(color, "persuasion", 1)
    return true
end

---
function MainBoard._asyncGoGatherSupport(color, leader)
    local continuation = Helper.createContinuation("MainBoard._asyncGoGatherSupport")
    if PlayBoard.getResource(color, "solari"):get() >= 2 then
        local options = {
            I18N("noWaterOption"),
            I18N("withWaterOption"),
        }
        -- FIXME Pending continuation if the dialog is canceled.
        Player[color].showOptionsDialog(I18N("goGatherSupport"), options, 1, function (_, index, _)
            continuation.run(MainBoard._gatherSupport(color, leader, index == 2))
        end)
        return continuation
    else
        continuation.run(MainBoard._gatherSupport(color, leader, false))
    end
    return continuation
end

---
function MainBoard._goGatherSupport_NoWater(color, leader)
    return MainBoard._gatherSupport(color, leader, false)
end

---
function MainBoard._goGatherSupport_WithWater(color, leader)
    return MainBoard._gatherSupport(color, leader, true)
end

---
function MainBoard._gatherSupport(color, leader, withWater)
    if not withWater or leader.resources(color, "solari", -2) then
        leader.troops(color, "supply", "garrison", 2)
        if withWater then
            leader.resources(color, "water", 1)
        end
        return true
    else
        return false
    end
end

---
function MainBoard._goShipping(color, leader)
    if InfluenceTrack.hasFriendship(color, "spacingGuild") and leader.resources(color, "spice", -3) then
        leader.resources(color, "solari", 5)
        return true
    else
        return false
    end
end

---
function MainBoard._goAcceptContract(color, leader)
    return leader.drawImperiumCards(color, 1)
end


---
function MainBoard._goCarthag(color, leader)
    leader.drawIntrigues(color, 1)
    leader.troops(color, "supply", "garrison", 1)
    return true
end

---
function MainBoard._asyncGoSietchTabr(color, leader)
    local continuation = Helper.createContinuation("MainBoard._asyncGoSietchTabr")
    local options = {
        I18N("hookTroopWaterOption"),
        I18N("waterShieldWallOption"),
    }
    if InfluenceTrack.hasFriendship(color, "fremen") then
        -- FIXME Pending continuation if the dialog is canceled.
        Player[color].showOptionsDialog(I18N("goSietchTabr"), options, 1, function (_, index, _)
            if index == 1 then
                continuation.run(MainBoard._goSietchTabr_HookTroopWater(color, leader))
            elseif index == 2 then
                continuation.run(MainBoard._goSietchTabr_WaterShieldWall(color, leader))
            else
                continuation.run(false)
            end
        end)
    else
        continuation.run(false)
    end
    return continuation
end

---
function MainBoard._goSietchTabr_HookTroopWater(color, leader)
    if InfluenceTrack.hasFriendship(color, "fremen") then
        leader.takeMakerHook(color)
        leader.troops(color, "supply", "garrison", 1)
        leader.resources(color, "water", 1)
        return true
    else
        return false
    end
end

---
function MainBoard._goSietchTabr_WaterShieldWall(color, leader)
    if InfluenceTrack.hasFriendship(color, "fremen") then
        leader.resources(color, "water", 1)
        MainBoard.blowUpShieldWall(color)
        return true
    else
        return false
    end
end

---
function MainBoard._goResearchStation(color, leader)
    if leader.resources(color, "water", -2) then
        leader.troops(color, "supply", "garrison", 2)
        leader.drawImperiumCards(color, 2)
        return true
    else
        return false
    end
end

---
function MainBoard._asyncGoSpiceRefinery(color, leader)
    local continuation = Helper.createContinuation("MainBoard._asyncGoSpiceRefinery")
    if PlayBoard.getResource(color, "spice"):get() == 0 then
        continuation.run(MainBoard._goSpiceRefinery(color, leader, 0))
    else
        local options = {
            I18N("zeroSpiceOption"),
            I18N("oneSpiceOption"),
        }
        -- FIXME Pending continuation if the dialog is canceled.
        Player[color].showOptionsDialog(I18N("goSpiceRefinery"), options, 1, function (_, index, _)
            continuation.run(MainBoard._goSpiceRefinery(color, leader, index - 1))
        end)
    end
    return continuation
end

---
function MainBoard._goSpiceRefinery_0(color, leader)
    return MainBoard._goSpiceRefinery(color, leader, 0)
end

---
function MainBoard._goSpiceRefinery_1(color, leader)
    return MainBoard._goSpiceRefinery(color, leader, 1)
end

---
function MainBoard._goSpiceRefinery(color, leader, amount)
    if amount == 0 or leader.resources(color, "spice", -amount) then
        MainBoard._applyControlOfAnySpace(MainBoard.banners.spiceRefineryBannerZone, "solari")
        leader.resources(color, "solari", (amount + 1) * 2)
        return true
    else
        return false
    end
end

---
function MainBoard._goArrakeen(color, leader)
    MainBoard._applyControlOfAnySpace(MainBoard.banners.arrakeenBannerZone, "solari")
    leader.troops(color, "supply", "garrison", 1)
    leader.drawImperiumCards(color, 1)
    return true
end

---
function MainBoard._asyncGoDeepDesert(color, leader)
    local continuation = Helper.createContinuation("MainBoard._asyncGoDeepDesert")
    if not PlayBoard.hasMakerHook(color) then
        continuation.run(MainBoard._goDeepDesert_Spice(color, leader))
    else
        local options = {
            I18N("fourSpicesOption"),
            I18N("twoWormsOption"),
        }
        -- FIXME Pending continuation if the dialog is canceled.
        Player[color].showOptionsDialog(I18N("goDeepDesert"), options, 1, function (_, index, _)
            if index == 1 then
                continuation.run(MainBoard._goDeepDesert_Spice(color, leader))
            elseif index == 2 then
                continuation.run(MainBoard._goDeepDesert_WormsIfHook(color, leader))
            else
                continuation.run(false)
            end
        end)
    end
    return continuation
end

---
function MainBoard._goDeepDesert_Spice(color, leader)
    return MainBoard._anySpiceSpace(color, leader, 3, 4, MainBoard.spiceBonuses.deepDesert)
end

---
function MainBoard._goDeepDesert_WormsIfHook(color, leader)
    if MainBoard._anySpiceSpace(color, leader, 3, 0, MainBoard.spiceBonuses.deepDesert) then
        leader.callSandworm(color, 2)
        return true
    else
        return false
    end
end

---
function MainBoard._goHabbanyaErg(color, leader)
    if MainBoard._anySpiceSpace(color, leader, 1, 2, MainBoard.spiceBonuses.habbanyaErg) then
        leader.drawImperiumCards(color, 1)
        return true
    else
        return false
    end
end

---
function MainBoard._asyncGoHaggaBasin(color, leader)
    local continuation = Helper.createContinuation("MainBoard._asyncGoHaggaBasin")
    if not PlayBoard.hasMakerHook(color) then
        continuation.run(MainBoard._goHaggaBasin_Spice(color, leader))
    else
        local options = {
            I18N("twoSpicesOption"),
            I18N("onWormOption"),
        }
        -- FIXME Pending continuation if the dialog is canceled.
        Player[color].showOptionsDialog(I18N("goHaggaBasin"), options, 1, function (_, index, _)
            if index == 1 then
                continuation.run(MainBoard._goHaggaBasin_Spice(color, leader))
            elseif index == 2 then
                continuation.run(MainBoard._goHaggaBasin_WormIfHook(color, leader))
            else
                continuation.run(false)
            end
        end)
    end
    return continuation
end

---
function MainBoard._goHaggaBasin_Spice(color, leader)
    return MainBoard._anySpiceSpace(color, leader, 1, 2, MainBoard.spiceBonuses.haggaBasin)
end

---
function MainBoard._goHaggaBasin_WormIfHook(color, leader)
    if MainBoard._anySpiceSpace(color, leader, 1, 0, MainBoard.spiceBonuses.haggaBasin) then
        leader.callSandworm(color, 1)
        return true
    else
        return false
    end
end

---
function MainBoard._goImperialBasin(color, leader)
    if MainBoard._anySpiceSpace(color, leader, 0, 1, MainBoard.spiceBonuses.imperialBasin) then
        MainBoard._applyControlOfAnySpace(MainBoard.banners.imperialBasinBannerZone, "spice")
        return true
    else
        return false
    end
end

---
function MainBoard._anySpiceSpace(color, leader, waterCost, spiceBaseAmount, spiceBonus)
    if leader.resources(color, "water", -waterCost) then
        local harvestedSpiceAmount = MainBoard._harvestSpice(spiceBaseAmount, spiceBonus)
        leader.resources(color, "spice", harvestedSpiceAmount)
        return true
    else
        return false
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

-- *** --

--[[ Immortality stuff

---
function MainBoard._goResearchStationImmortality(color, leader)
    if leader.resources(color, "water", -2) then
        leader.drawImperiumCards(color, 2)
        --leader.research(color, ...)
        return true
    else
        return false
    end
end
]]

--[[ Ix stuff

---
function MainBoard._goSmuggling(color, leader)
    leader.resources(color, "solari", 1)
    leader.shipments(color, 1)
    return true
end

---
function MainBoard._goInterstellarShipping(color, leader)
    if (InfluenceTrack.hasFriendship(color, "spacingGuild")) then
        leader.shipments(color, 2)
        return true
    else
        return false
    end
end

function MainBoard._asyncGoTechNegotiation(color, leader)
    local continuation = Helper.createContinuation("MainBoard._asyncGoTechNegotiation")
    local options = {
        I18N("sendNegotiatorOption"),
        I18N("buyTechWithDiscont1Option"),
    }
    -- FIXME Pending continuation if the dialog is canceled.
    Player[color].showOptionsDialog(I18N("goTechNegotiation"), options, 1, function (_, index, _)
        local success = true
        if index == 1 then
            MainBoard._goTechNegotiation_1(color, leader)
        elseif index == 2 then
            MainBoard._goTechNegotiation_2(color, leader)
        else
            success = false
        end
        continuation.run(success)
    end)
    return continuation
end

function MainBoard._goTechNegotiation_1(color, leader)
    leader.resources(color, "persuasion", 1)
    leader.troops(color, "supply", "negotiation", 1)
    return true
end

function MainBoard._goTechNegotiation_2(color, leader)
    leader.resources(color, "persuasion", 1)
    TechMarket.registerAcquireTechOption(color, "techNegotiationTechBuyOption", "spice", 1)
    return true
end

---
function MainBoard._goDreadnought(color, leader)
    if leader.resources(color, "solari", -3) then
        TechMarket.registerAcquireTechOption(color, "dreadnoughtTechBuyOption", "spice", 0)
        Park.transfert(1, PlayBoard.getDreadnoughtPark(color), Combat.getDreadnoughtPark(color))
        return true
    else
        return false
    end
end

]]

---
function MainBoard.blowUpShieldWall(color)
    Player[color].showConfirmDialog(
        I18N("confirmShieldWallDestruction"),
        function(_)
            Music.play("atomics")
            broadcastToAll(I18N('blowUpShieldWall', { leader = PlayBoard.getLeaderName(color) }), color, "Purple")
            Helper.onceTimeElapsed(3).doAfter(function ()
                MainBoard.trash(MainBoard.shieldWallToken)
            end)
        end)
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

function MainBoard.hasEnemyAgentInSpace(spaceName, color)
    for _, otherColor in ipairs(PlayBoard.getActivePlayBoardColors()) do
        if otherColor ~= color and MainBoard.hasAgentInSpace(spaceName, otherColor) then
            return true
        end
    end
    return false
end

---
function MainBoard.getDeployedSpyCount(color, onlyInMakerSpace)
    local count = 0
    for name, observationPost in pairs(MainBoard.observationPosts) do
        if not onlyInMakerSpace or MainBoard.isDesertSpace(name) then
            for _, spy in ipairs(Park.getObjects(observationPost.park)) do
                if spy.hasTag(color) then
                    count = count + 1
                end
            end
        end
    end
    return count
end

--
function MainBoard.isSpying(spaceName, color)
    --Helper.dumpFunction("MainBoard.isSpying", spaceName, color)
    for name, observationPost in pairs(MainBoard.observationPosts) do
        if name == spaceName then
            for _, spy in ipairs(Park.getObjects(observationPost.park)) do
                if spy.hasTag(color) then
                    return true
                end
            end
        end
    end
    return false
end

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
    --Helper.dump("MainBoard.isDesertSpace", spaceName)
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
    assert(space, "Unknow space: " .. spaceName)
end

---
function MainBoard.getSnooperTrackPosition(faction)

    local getAveragePosition = function (spaceNames)
        local p = Vector(0, 0, 0)
        local count = 0
        for _, spaceName in ipairs(spaceNames) do
            p = p + MainBoard.spaces[spaceName].zone.getPosition()
            count = count + 1
        end
        return p * (1 / count)
    end

    error("TODO")
    local positions = {
        emperor = getAveragePosition({ "conspire", "wealth" }),
        spacingGuild = getAveragePosition({ "heighliner", "foldspace" }),
        beneGesserit = getAveragePosition({ "selectiveBreeding", "secrets" }),
        fremen = getAveragePosition({ "hardyWarriors", "stillsuits" }),
    }

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

return MainBoard
