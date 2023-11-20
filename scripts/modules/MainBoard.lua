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

local MainBoard = {}

---
function MainBoard.rebuild()
    --local destination = getObjectFromGUID("21cc52")
    local destination = getObjectFromGUID("483a1a")
    --local destination = getObjectFromGUID("d75455")
    assert(destination)

    local snapPoints = {}

    for _, snapPoint in ipairs(destination.getSnapPoints()) do
        assert(#snapPoint.tags == 1)
        local tag = snapPoint.tags[1]
        for _, prefix in ipairs({ "space", "post", "flag" }) do
            if Helper.startsWith(tag, prefix .. "_") then
                local newTag = prefix .. tag:sub(prefix:len() + 2)
                Helper.dump(tag, "->", newTag)
                snapPoint.tags = { newTag }
                break
            end
        end
        table.insert(snapPoints, snapPoint)
    end

    local rejectedCount = 0
    for _, snapPoint in ipairs(Global.getSnapPoints()) do
        if #snapPoint.tags > 0 then
            assert(#snapPoint.tags == 1)
            table.insert(snapPoints, {
                position = destination.positionToLocal(snapPoint.position),
                tags = snapPoint.tags,
            })
        else
            rejectedCount = rejectedCount + 1
        end
    end
    log("Rejected: " .. tostring(rejectedCount) .. "/" .. tostring(#Global.getSnapPoints()))

    destination.setSnapPoints(snapPoints)
    Global.setSnapPoints({})

    for _, snapPoint in ipairs(destination.getSnapPoints()) do
        log(snapPoint.tags[1])
    end
end

---
function MainBoard.onLoad(state)
    Helper.append(MainBoard, Helper.resolveGUIDs(true, {
        board = "21cc52", -- 4P: "483a1a", 6P: "21cc52"
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
        firstPlayerMarker = "1f5576",
    }))

    Helper.noPhysicsNorPlay(MainBoard.board)

    MainBoard.spiceBonuses = {}
    --[[
    for name, token in pairs(MainBoard.spiceBonusTokens) do
        local value = state.MainBoard and state.MainBoard.spiceBonuses[name] or 0
        MainBoard.spiceBonuses[name] = Resource.new(token, nil, "spice", value)
    end
    ]]

    if state.settings then
        MainBoard._staticSetUp(state.MainBoard.settings)
        -- TODO Restore spice bonuses
    end
end

---
function MainBoard.onSave(state)
    if state.settings then
        state.MainBoard = {
            spiceBonuses = Helper.mapValue(MainBoard.spiceBonuses, function (resource)
                return resource:get()
            end),
        }
    end
end

---
function MainBoard.setUp(settings)
    if settings.numberOfPlayers == 6 then
        --MainBoard.board.setState(2)
    else
        MainBoard.board.setState(1)

    end

    MainBoard._staticSetUp(settings)
end

---
function MainBoard._staticSetUp(settings)
    -- TODO Reactivate
    --MainBoard.highCouncilPark = MainBoard:_createHighCouncilPark(MainBoard.highCouncilZone)

    MainBoard._processSnapPoints(settings)

    Helper.registerEventListener("phaseStart", function (phase)
        if phase == "makers" then
            for _, desert in ipairs({ "imperialBasin", "haggaBasin", "theGreatFlat" }) do
                local space = MainBoard.spaces[desert]
                local spiceBonus = MainBoard.spiceBonuses[desert]
                if Park.isEmpty(space.park) then
                    spiceBonus:change(1)
                end
            end
        elseif phase == "recall" then

            -- Recalling dreadnoughts in controlable spaces.
            for _, bannerZone in pairs(MainBoard.banners) do
                for _, dreadnought in ipairs(Helper.filter(bannerZone.getObjects(), Types.isDreadnought)) do
                    for _, color in ipairs(PlayBoard.getPlayBoardColors()) do
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
                            for _, color in ipairs(PlayBoard.getPlayBoardColors()) do
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

---
function MainBoard._processSnapPoints(settings)

    MainBoard.spaces = {}
    MainBoard.observationPosts = {}

    -- Having change the state is not enough.
    if settings.numberOfPlayers == 6 then
        MainBoard._collectSnapPoints(getObjectFromGUID("21cc52"))
        -- TODO Consider commander's boards.
    else
        MainBoard._collectSnapPoints(getObjectFromGUID("483a1a"))
    end
    if settings.riseOfIx then
        -- FIXME Direct access
        MainBoard._collectSnapPoints(TechMarket.board)
    end

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
        local p = observationPost.position
        MainBoard._createObservationPostButton(observationPost)
    end
end

---
function MainBoard._collectSnapPoints(object)
    local snapPoints = object.getSnapPoints()
    for _, snapPoint in ipairs(snapPoints) do
        assert(snapPoint.tags and #snapPoint.tags == 1)
        for _, tag in ipairs(snapPoint.tags) do
            if Helper.startsWith(tag, "space") then
                local spaceName = tag:sub(6):gsub("^%u", string.lower)
                local position = object.positionToWorld(snapPoint.position)
                MainBoard.spaces[spaceName] = { name = spaceName, position = position }
            elseif Helper.startsWith(tag, "post") then
                local observationPostName = tag:sub(5):gsub("^%u", string.lower)
                local position = object.positionToWorld(snapPoint.position)
                MainBoard.observationPosts[observationPostName] = { name = observationPostName, position = position }
            end
        end
    end
end

---
function MainBoard:_createHighCouncilPark(zone)
    local seats = {}
    for i = 1, 4 do
        local x = (i - 2.5) * zone.getScale().x / 4
        local seat = Vector(x, 0, 0) + zone.getPosition()
        table.insert(seats, seat)
    end

    return Park.createPark(
        "HighCouncil",
        seats,
        Vector(0, 0, 0),
        zone,
        { "HighCouncilSeatToken" },
        nil,
        true,
        true)
end

---
function MainBoard.getHighCouncilSeatPark()
    return MainBoard.highCouncilPark
end

---
function MainBoard.findControlableSpace(victoryPointToken)
    assert(victoryPointToken)
    local description = Helper.getID(victoryPointToken)
    if description == "secureImperialBasin" or description == "battleForImperialBasin" then
        return MainBoard.banners.imperialBasinBannerZone
    elseif description == "siegeOfArrakeen" or description == "battleForArrakeen" then
        return MainBoard.banners.arrakeenBannerZone
    elseif description == "siegeOfCarthag" or description == "battleForCarthag" then
        return MainBoard.banners.carthagBannerZone
    else
        return nil
    end
end

---
function MainBoard.occupy(controlableSpace, color)
    for _, object in ipairs(controlableSpace.getObjects()) do
        for _, otherColor in ipairs(PlayBoard.getPlayBoardColors()) do
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
            space.park = Park.createPark("AgentPark", slots, nil, space.zone, tags, nil, false, true)
            local snapPoints = {}
            for _, slot in ipairs(slots) do
                table.insert(snapPoints, Helper.createRelativeSnapPoint(anchor, slot, false, tags))
            end
            anchor.setSnapPoints(snapPoints)
        else
            space.zone = Park.createTransientBoundingZone(0, Vector(0.75, 1, 0.75), { space.position })
        end

        local tooltip = I18N("sendAgentTo", { space = I18N(space.name)})
        Helper.createAreaButton(space.zone, anchor, 0.7, tooltip, PlayBoard.withLeader(function (leader, color, _)
            leader.sendAgent(color, space.name)
        end))
    end)
end

---
function MainBoard._createObservationPostButton(observationPost)
    local slots = { observationPost.position }
    Helper.createTransientAnchor("AgentPark", observationPost.position - Vector(0, 0.5, 0)).doAfter(function (anchor)
        observationPost.zone = Park.createTransientBoundingZone(0, Vector(0.75, 1, 0.75), slots)

        local tags = { "Spy" }
        observationPost.park = Park.createPark("SpyPark", slots, nil, observationPost.zone, tags, nil, false, true)

        local snapPoints = {}
        for _, slot in ipairs(slots) do
            table.insert(snapPoints, Helper.createRelativeSnapPoint(anchor, slot, false, tags))
        end
        anchor.setSnapPoints(snapPoints)

        local tooltip = I18N("sendSpyTo", { observationPost = I18N(observationPost.name)})
        Helper.createAreaButton(observationPost.zone, anchor, 0.7, tooltip, PlayBoard.withLeader(function (leader, color, _)
            leader.sendSpy(color, observationPost.name)
        end))
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
function MainBoard.sendAgent(color, spaceName)
    local continuation = Helper.createContinuation("MainBoard.sendAgent")

    local space = MainBoard.spaces[spaceName]
    local parentSpace = MainBoard._findParentSpace(space)

    local asyncActionName = Helper.toCamelCase("_asyncGo", space.name)
    local actionName = Helper.toCamelCase("_go", space.name)

    local asyncAction = MainBoard[asyncActionName]
    local action = MainBoard[actionName]
    local leader = PlayBoard.getLeader(color)
    if not Park.isEmpty(PlayBoard.getAgentPark(color)) then
        local agentPark = PlayBoard.getAgentPark(color)
        if asyncAction then
            Helper.emitEvent("agentSent", color, spaceName)
            log("BEGIN asyncAction: " .. asyncActionName)
            asyncAction(color, leader).doAfter(function (success)
                log("END asyncAction: " .. asyncActionName)
                if success then
                    Park.transfert(1, agentPark, parentSpace.park)
                    continuation.run(true)
                else
                    continuation.run(false)
                end
            end)
        elseif action then
            Helper.emitEvent("agentSent", color, spaceName)
            log("BEGIN action: " .. actionName)
            if action(color, leader) then
                log("END action: " .. actionName)
                --log("Park.transfert(1, agentPark, parentSpace.park)")
                Park.transfert(1, agentPark, parentSpace.park)
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
function MainBoard._goFremkit(color, spaceName)
    return true
end

---
function MainBoard._goSecrets(color, spaceName)
    return true
end

---
function MainBoard._goSardaukar(color, spaceName)
    return true
end

---
function MainBoard._goShipping(color, spaceName)
    return true
end

---
function MainBoard._goEspionage(color, spaceName)
    return true
end

---
function MainBoard._goHeighliner(color, spaceName)
    return true
end

---
function MainBoard._goDeepDesert(color, spaceName)
    return true
end

---
function MainBoard._goSietchTabr(color, spaceName)
    return true
end

---
function MainBoard._goHaggaBasin(color, spaceName)
    return true
end

---
function MainBoard._goSwordmaster(color, spaceName)
    return true
end

---
function MainBoard._goAssemblyHall(color, spaceName)
    return true
end

---
function MainBoard._goSpiceRefinery(color, spaceName)
    return true
end

---
function MainBoard._goGatherSupport(color, spaceName)
    return true
end

---
function MainBoard._goDesertTactics(color, spaceName)
    return true
end

---
function MainBoard._goDutifulService(color, spaceName)
    return true
end

---
function MainBoard._goAcceptContract(color, spaceName)
    return true
end

---
function MainBoard._goImperialBasin(color, spaceName)
    return true
end

---
function MainBoard._goSpiceRefinery_0(color, spaceName)
    return true
end

---
function MainBoard._goDeliverSupplies(color, spaceName)
    return true
end

---
function MainBoard._goResearchStation(color, spaceName)
    return true
end

---
function MainBoard._goHaggaBasin_Spice(color, spaceName)
    return true
end

---
function MainBoard._goSpiceRefinery_1(color, spaceName)
    return true
end

---
function MainBoard._goDeepDesert_Spice(color, spaceName)
    return true
end

---
function MainBoard._goHaggaBasin_WormIfHook(color, spaceName)
    return true
end

---
function MainBoard._goDeepDesert_WormsIfHook(color, spaceName)
    return true
end

---
function MainBoard._goImperialPrivilege(color, spaceName)
    return true
end

---
function MainBoard._goFremen(color, spaceName)
    return true
end

---
function MainBoard._goSietchTabr_WaterShieldWall(color, spaceName)
    return true
end

---
function MainBoard._goSietchTabr_HookTroopWater(color, spaceName)
    return true
end

---
function MainBoard._goSpacingGuild(color, spaceName)
    return true
end

---
function MainBoard._goEmperor(color, spaceName)
    return true
end

---
function MainBoard._goBeneGesserit(color, spaceName)
    return true
end

---
function MainBoard._goLandsraadCouncil1(color, spaceName)
    return true
end

---
function MainBoard._goLandsraadCouncil2(color, spaceName)
    return true
end

---
function MainBoard._goSpiceRefineryArrakeen(color, spaceName)
    return true
end

---
function MainBoard._goResearchStationSpiceRefinery(color, spaceName)
    return true
end

---
function MainBoard._goSietchTabrResearchStation(color, spaceName)
    return true
end

---
function MainBoard._goArrakeen(color, spaceName)
    return true
end

---
function MainBoard._goHighCouncil(color, spaceName)
    return true
end

---
function MainBoard._goCarthag(color, spaceName)
    return true
end

---
function MainBoard._goContract(color, spaceName)
    return true
end

---
function MainBoard._goExpedition(color, spaceName)
    return true
end

---
function MainBoard._goHabbanyaErg(color, spaceName)
    return true
end

---
function MainBoard._goImperialBassin(color, spaceName)
    return true
end

---
function MainBoard._goControversialTechnology(color, spaceName)
    return true
end

---
function MainBoard._goFringeWorlds(color, spaceName)
    return true
end

---
function MainBoard._goGreatHouse(color, spaceName)
    return true
end

---
function MainBoard._goChoam(color, spaceName)
    return true
end

---
function MainBoard._goEconomicSupport(color, spaceName)
    return true
end

---
function MainBoard._goMilitarySupport(color, spaceName)
    return true
end

--[[
---
function MainBoard._goConspire(color, leader)
    if leader.resources(color, "spice", -4) then
        leader.resources(color, "solari", 5)
        leader.troops(color, "supply", "garrison", 2)
        leader.drawIntrigues(color, 1)
        leader.influence(color, "emperor", 1)
        return true
    else
        return false
    end
end

---
function MainBoard._goWealth(color, leader)
    leader.resources(color, "solari", 2)
    leader.influence(color, "emperor", 1)
    return true
end

---
function MainBoard._goHeighliner(color, leader)
    if leader.resources(color, "spice", -6) then
        leader.resources(color, "water", 2)
        leader.troops(color, "supply", "garrison", 5)
        leader.influence(color, "spacingGuild", 1)
        return true
    else
        return false
    end
end

---
function MainBoard._goFoldspace(color, leader)
    leader.acquireFoldspace(color)
    leader.influence(color, "spacingGuild", 1)
    return true
end

---
function MainBoard._goSelectiveBreeding(color, leader)
    if leader.resources(color, "spice", -2) then
        leader.influence(color, "beneGesserit", 1)
        return true
    else
        return false
    end
end

---
function MainBoard._goSecrets(color, leader)
    leader.drawIntrigues(color, 1)
    for _, otherColor in ipairs(PlayBoard.getPlayBoardColors()) do
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
function MainBoard._goHardyWarriors(color, leader)
    if leader.resources(color, "water", -1) then
        leader.troops(color, "supply", "garrison", 2)
        leader.influence(color, "fremen", 1)
        return true
    else
        return false
    end
end

---
function MainBoard._goStillsuits(color, leader)
    leader.resources(color, "water", 1)
    leader.influence(color, "fremen", 1)
    return true
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
function MainBoard._goHaggaBasin(color, leader)
    return MainBoard._anySpiceSpace(color, leader, 1, 2, MainBoard.spiceBonuses.haggaBasin)
end

---
function MainBoard._goTheGreatFlat(color, leader)
    return MainBoard._anySpiceSpace(color, leader, 2, 3, MainBoard.spiceBonuses.theGreatFlat)
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
function MainBoard._goSietchTabr(color, leader)
    if (InfluenceTrack.hasFriendship(color, "fremen")) then
        leader.troops(color, "supply", "garrison", 1)
        leader.resources(color, "water", 1)
        return true
    else
        return false
    end
end

---
function MainBoard._goResearchStation(color, leader)
    if leader.resources(color, "water", -2) then
        leader.drawImperiumCards(color, 3)
        return true
    else
        return false
    end
end

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

---
function MainBoard._goCarthag(color, leader)
    leader.drawIntrigues(color, 1)
    leader.troops(color, "supply", "garrison", 1)
    MainBoard._applyControlOfAnySpace(MainBoard.banners.carthagBannerZone, "solari")
    return true
end

---
function MainBoard._goArrakeen(color, leader)
    leader.troops(color, "supply", "garrison", 1)
    leader.drawImperiumCards(color, 1)
    MainBoard._applyControlOfAnySpace(MainBoard.banners.arrakeenBannerZone, "solari")
    return true
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
function MainBoard.getControllingPlayer(bannerZone)
    local controllingPlayer = nil

    -- Check player dreadnoughts first since they supersede flags.
    for _, object in ipairs(bannerZone.getObjects()) do
        for _, color in ipairs(PlayBoard.getPlayBoardColors()) do
            if Types.isDreadnought(object, color) then
                assert(not controllingPlayer, "Too many dreadnoughts")
                controllingPlayer = color
            end
        end
    end

    -- Check player flags otherwise.
    if not controllingPlayer then
        for _, object in ipairs(bannerZone.getObjects()) do
            for _, color in ipairs(PlayBoard.getPlayBoardColors()) do
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
        for _, color in ipairs(PlayBoard.getPlayBoardColors()) do
            if Types.isDreadnought(object, color) then
                return object
            end
        end
    end
    return nil
end

---
function MainBoard._goSwordmaster(color, leader)
    if not PlayBoard.hasSwordmaster(color) and leader.resources(color, "solari", -8) then
        leader.recruitSwordmaster(color)
        return true
    else
        return false
    end
end

---
function MainBoard._goMentat(color, leader)
    if leader.resources(color, "solari", -Hagal.getMentatSpaceCost()) then
        leader.drawImperiumCards(color, 1)
        return true
    else
        return false
    end
end

---
function MainBoard._goHighCouncil(color, leader)
    -- FIXME Interleaved conditions...
    if not PlayBoard.hasHighCouncilSeat(color) and leader.resources(color, "solari", -5) then
        return leader.takeHighCouncilSeat(color)
    else
        return false
    end
end

---
function MainBoard._goSecureContract(color, leader)
    leader.resources(color, "solari", 3)
    return true
end

function MainBoard._asyncGoSellMelange(color, leader)
    local continuation = Helper.createContinuation("MainBoard._asyncGoSellMelange")
    local options = {
        "2 -> 4",
        "3 -> 8",
        "4 -> 10",
        "5 -> 12",
    }
    -- FIXME Pending continuation if the dialog is canceled.
    Player[color].showOptionsDialog(I18N("goSellMelange"), options, 1, function (_, index, _)
        continuation.run(MainBoard._sellMelange(color, leader, index))
    end)
    return continuation
end

function MainBoard._goSellMelange_1(color, leader)
    return MainBoard._sellMelange(color, leader, 1)
end

function MainBoard._goSellMelange_2(color, leader)
    return MainBoard._sellMelange(color, leader, 2)
end

function MainBoard._goSellMelange_3(color, leader)
    return MainBoard._sellMelange(color, leader, 3)
end

function MainBoard._goSellMelange_4(color, leader)
    return MainBoard._sellMelange(color, leader, 4)
end

function MainBoard._sellMelange(color, leader, index)
    local spiceCost = index + 1
    local solariBenefit = (index + 1) * 2 + 2
    if leader.resources(color, "spice", -spiceCost) then
        leader.resources(color, "solari", solariBenefit)
        return true
    else
        return false
    end
end

---
function MainBoard._goRallyTroops(color, leader)
    if leader.resources(color, "solari", -4) then
        leader.troops(color, "supply", "garrison", 4)
        return true
    else
        return false
    end
end

---
function MainBoard._goHallOfOratory(color, leader)
    leader.troops(color, "supply", "garrison", 1)
    leader.resources(color, "persuasion", 1)
    return true
end

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
    for _, otherColor in ipairs(PlayBoard.getPlayBoardColors()) do
        if otherColor ~= color and MainBoard.hasAgentInSpace(spaceName, otherColor) then
            return true
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
    return Helper.isElementOf(spaceName, MainBoard.getEmperorSpaces())
end

---
function MainBoard.getEmperorSpaces()
    error("TODO")
    return {
        "conspire",
        "wealth" }
end

---
function MainBoard.isSpacingGuildSpace(spaceName)
    return Helper.isElementOf(spaceName, MainBoard.getSpacingGuildSpace())
end

---
function MainBoard.getSpacingGuildSpace()
    error("TODO")
    return {
        "heighliner",
        "foldspace" }
end

---
function MainBoard.isBeneGesseritSpace(spaceName)
    return Helper.isElementOf(spaceName, MainBoard.getBeneGesseritSpaces())
end

---
function MainBoard.getBeneGesseritSpaces()
    error("TODO")
    return {
        "selectiveBreeding",
        "secrets" }
end

---
function MainBoard.isFremenSpace(spaceName)
    return Helper.isElementOf(spaceName, MainBoard.getFremenSpaces())
end

---
function MainBoard.getFremenSpaces()
    error("TODO")
    return {
        "hardyWarriors",
        "stillsuits" }
end

---
function MainBoard.isFactionSpace(spaceName)
    error("TODO")
    return MainBoard.isEmperorSpace(spaceName)
        or MainBoard.isSpacingGuildSpace(spaceName)
        or MainBoard.isBeneGesseritSpace(spaceName)
        or MainBoard.isFremenSpace(spaceName)
end

---
function MainBoard.isLandsraadSpace(spaceName)
    error("TODO")
    return Helper.isElementOf(spaceName, MainBoard.getLandsraadSpaces())
end

---
function MainBoard.getLandsraadSpaces()
    error("TODO")
    return {
        "highCouncil",
        "mentat",
        "swordmaster",
        "rallyTroops",
        "hallOfOratory",
        "highCouncil",
        "mentat",
        "swordmaster",
        "rallyTroops",
        "hallOfOratory",
        "techNegotiation",
        "dreadnought" }
end

---
function MainBoard.isCHOAMSpace(spaceName)
    return Helper.isElementOf(spaceName, MainBoard.getCHOAMSpaces())
end

---
function MainBoard.getCHOAMSpaces()
    error("TODO")
    return {
        "secureContract",
        "sellMelange",
        "secureContract",
        "sellMelange",
        "smuggling",
        "interstellarShipping" }
end

---
function MainBoard.isCitySpace(spaceName)
    return Helper.isElementOf(spaceName, MainBoard.getCitySpaces())
end

---
function MainBoard.getCitySpaces()
    error("TODO")
    return {
        "arrakeen",
        "carthag",
        "researchStation",
        "researchStationImmortality",
        "sietchTabr" }
end

---
function MainBoard.isDesertSpace(spaceName)
    return Helper.isElementOf(spaceName, MainBoard.getDesertSpaces())
end

---
function MainBoard.getDesertSpaces()
    error("TODO")
    return {
        "imperialBasin",
        "haggaBasin",
        "theGreatFlat" }
end

---
function MainBoard.isSpiceTradeSpace(spaceName)
    return MainBoard.isDesertSpace(spaceName)
        or MainBoard.isCHOAMSpace(spaceName)
end

---
function MainBoard.getCombatSpaces()
    error("TODO")
    return {
        "heighliner",
        "hardyWarriors",
        "stillsuits",
        "arrakeen",
        "carthag",
        "researchStation",
        "researchStationImmortality",
        "sietchTabr",
        "imperialBasin",
        "haggaBasin",
        "theGreatFlat" }
end

---
function MainBoard.isCombatSpace(spaceName)
    local result = Helper.isElementOf(spaceName, MainBoard.getCombatSpaces())
    --Helper.dump(spaceName, "is a combat space ->", result)
    return result
end

---
function MainBoard.getBannerZones()
    return {
        MainBoard.banners.imperialBasinBannerZone,
        MainBoard.banners.arrakeenBannerZone,
        MainBoard.banners.carthagBannerZone,
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
