local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")

local Resource = Module.lazyRequire("Resource")
local Utils = Module.lazyRequire("Utils")
local PlayBoard = Module.lazyRequire("PlayBoard")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")
local TechMarket = Module.lazyRequire("TechMarket")
local Combat = Module.lazyRequire("Combat")
local Hagal = Module.lazyRequire("Hagal")
local DynamicBonus = Module.lazyRequire("DynamicBonus")

local MainBoard = {}

---
function MainBoard.onLoad(state)
    Helper.append(MainBoard, Helper.resolveGUIDs(true, {
        board = "483a1a", -- Inner state: "21cc52"
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
        spaces = {
            -- Factions
            conspire = { zone = "cd9386" },
            wealth = { zone = "b2c461" },
            heighliner = { zone = "8b0515" },
            foldspace = { zone = "9a9eb5" },
            selectiveBreeding = { zone = "7dc6e5" },
            secrets = { zone = "1f7c08" },
            hardyWarriors = { zone = "a2fd8e" },
            stillsuits = { zone = "556f43" },
            -- Landsraad
            highCouncil = { zone = "8a6315" },
            mentat = { zone = "30cff9" },
            swordmaster = { zone = '6cc2f8' },
            rallyTroops = { zone = '6932df' },
            hallOfOratory = { zone = '3e7409' },
            -- CHOAM
            secureContract = { zone = "db4022" },
            sellMelange = { zone = "7539a3" },
            sellMelange_1 = { zone = "107a42" },
            sellMelange_2 = { zone = "43cb14" },
            sellMelange_3 = { zone = "b00ba5" },
            sellMelange_4 = { zone = "debf5e" },
            -- Dune
            arrakeen = { zone = "17b646" },
            carthag = { zone = "b1c938" },
            researchStation = { zone = "af11aa" },
            sietchTabr = { zone = "5bc970" },
            -- Desert
            imperialBasin = { zone = "2c77c1" },
            haggaBasin = { zone = "622708" },
            theGreatFlat = { zone = "69f925" },
        },
        ixSpaces = {
            -- Landsraad
            highCouncil = { zone = "dbdd82" },
            mentat = { zone = "d6c7dd" },
            swordmaster = { zone = "035975" },
            rallyTroops = Helper.ERASE,
            hallOfOratory = Helper.ERASE,
            -- CHOAM
            secureContract = Helper.ERASE,
            sellMelange = Helper.ERASE,
            sellMelange_1 = Helper.ERASE,
            sellMelange_2 = Helper.ERASE,
            sellMelange_3 = Helper.ERASE,
            sellMelange_4 = Helper.ERASE,
            smuggling = { zone = "82589e" },
            interstellarShipping = { zone = "487ad9" },
            -- Ix
            techNegotiation = { zone = "04f512" },
            techNegotiation_1 = { zone = "a7cdf8" },
            techNegotiation_2 = { zone = "479378" },
            dreadnought = { zone = "83ea90" },
        },
        immortalitySpaces = {
            researchStation = Helper.ERASE,
            researchStationImmortality = { zone = "af11aa" },
        },
        banners = {
            arrakeenBannerZone = "f1f53d",
            carthagBannerZone = "9fc2e1",
            imperialBasinBannerZone = "3fe117",
        },
        spiceBonusTokens = {
            imperialBasin = "3cdb2d",
            haggaBasin = "394db2",
            theGreatFlat = "116807"
        },
        mentat = "c2a908",
        mentatZones = {
            base = "a11936",
            ix = "0b21df"
        },
        highCouncilZones = {
            base = "e51f6e",
            ix = "a719db"
        },
        firstPlayerMarker = "1f5576",
        phaseMarker = "fb41e2",
    }))

    Helper.noPhysicsNorPlay(MainBoard.board)

    local p = Helper.getHardcodedPositionFromGUID('fb41e2', -4.08299875, 0.721966565, -12.0102692)
    local offset = Vector(0, 0, -0.64)
    MainBoard.phaseMarkerPositions = {
        roundStart = p + offset * 0,
        playerTurns = p + offset * 1,
        combat = p + offset * 2,
        makers = p + offset * 3,
        recall = p + offset * 4
    }

    MainBoard.spiceBonuses = {}
    for name, token in pairs(MainBoard.spiceBonusTokens) do
        local value = state.MainBoard and state.MainBoard.spiceBonuses[name] or 0
        MainBoard.spiceBonuses[name] = Resource.new(token, nil, "spice", value)
    end

    if state.settings then
        MainBoard.highCouncilZone = getObjectFromGUID(state.MainBoard.highCouncilZoneGUID)
        MainBoard.mentatZone = getObjectFromGUID(state.MainBoard.mentatZoneGUID)
        MainBoard.spaces = Helper.map(state.MainBoard.spaceGUIDs, function (_, guid)
            return { zone = getObjectFromGUID(guid) }
        end)
        MainBoard._staticSetUp(state.MainBoard.settings)
    end
end

---
function MainBoard.onSave(state)
    if state.settings then
        state.MainBoard = {
            spiceBonuses = Helper.map(MainBoard.spiceBonuses, function (name, resource)
                return resource:get()
            end),
            highCouncilZoneGUID = MainBoard.highCouncilZone.getGUID(),
            mentatZoneGUID = MainBoard.mentatZone.getGUID(),
            spaceGUIDs = Helper.map(MainBoard.spaces, function (_, space)
                return space.zone.getGUID()
            end)
        }
    end
end

---
function MainBoard.setUp(settings)
    if settings.riseOfIx then
        MainBoard.highCouncilZones.base.destruct()
        MainBoard.highCouncilZone = MainBoard.highCouncilZones.ix
        MainBoard.mentatZones.base.destruct()
        MainBoard.mentatZone = MainBoard.mentatZones.ix
        --MainBoard.board.setState(1)
    else
        MainBoard.highCouncilZones.ix.destruct()
        MainBoard.highCouncilZone = MainBoard.highCouncilZones.base
        MainBoard.mentatZones.ix.destruct()
        MainBoard.mentatZone = MainBoard.mentatZones.base
        MainBoard.board.setState(2)
    end

    local enabledExtensions = {
        ix = settings.riseOfIx,
        immortality = settings.immortality
    }

    for _, extension in ipairs({ "ix", "immortality" }) do
        for spaceName, extSpace in pairs(MainBoard[extension .. "Spaces"]) do
            if enabledExtensions[extension] then
                local baseSpace = MainBoard.spaces[spaceName]
                -- Immortality reuses the research station zone, so we skip its destruction.
                if baseSpace and spaceName ~= "researchStation" then
                    baseSpace.zone.destruct()
                end
                MainBoard.spaces[spaceName] = (extSpace ~= Helper.ERASE and extSpace or nil)
            else
                if extSpace == Helper.ERASE then
                    extSpace.zone.destruct()
                end
            end
        end
        MainBoard[extension .. "Spaces"] = nil
    end

    MainBoard._staticSetUp(settings)
end

---
function MainBoard._staticSetUp(settings)
    MainBoard.highCouncilPark = MainBoard:_createHighCouncilPark(MainBoard.highCouncilZone)

    for name, space in pairs(MainBoard.spaces) do
        space.name = name

        local p = space.zone.getPosition()
        -- FIXME Hardcoded height, use an existing parent anchor.
        local slots = {
            Vector(p.x - 0.36, 0.68, p.z - 0.3),
            Vector(p.x + 0.36, 0.68, p.z + 0.3),
            Vector(p.x - 0.36, 0.68, p.z + 0.3),
            Vector(p.x + 0.36, 0.68, p.z - 0.3)
        }

        MainBoard._createSpaceButton(space, p, slots)
    end

    Helper.registerEventListener("phaseStart", function (phase)
        if phase == "roundStart" then
            MainBoard.phaseMarker.setPosition(MainBoard.phaseMarkerPositions.roundStart)
        elseif phase == "playerTurns" then
            MainBoard.phaseMarker.setPosition(MainBoard.phaseMarkerPositions.playerTurns)
        elseif phase == "combat" then
            MainBoard.phaseMarker.setPosition(MainBoard.phaseMarkerPositions.combat)
        elseif phase == "makers" then
            MainBoard.phaseMarker.setPosition(MainBoard.phaseMarkerPositions.makers)

            for _, desert in ipairs({ "imperialBasin", "haggaBasin", "theGreatFlat" }) do
                local space = MainBoard.spaces[desert]
                local spiceBonus = MainBoard.spiceBonuses[desert]
                if Park.isEmpty(space.park) then
                    spiceBonus:change(1)
                end
            end
        elseif phase == "recall" then
            MainBoard.phaseMarker.setPosition(MainBoard.phaseMarkerPositions.recall)

            -- Recalling Mentat.
            if MainBoard.mentat.getLock() then
                MainBoard.mentat.setLock(false)
            else
                for _, color in ipairs(PlayBoard.getPlayBoardColors()) do
                    MainBoard.mentat.removeTag(color)
                end
                MainBoard.mentat.setPosition(MainBoard.mentatZone.getPosition())
            end

            -- Recalling agents.
            for _, space in pairs(MainBoard.spaces) do
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
    end)
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
            if Utils.isControlMarker(object, otherColor) then
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
function MainBoard._createSpaceButton(space, position, slots)
    local zone = space.zone -- Park.createBoundingZone(0, Vector(1, 3, 0.5), slots)
    local tags = { "Agent" }
    space.park = Park.createPark("AgentPark", slots, Vector(0, 0, 0), zone, tags, nil, false, true)

    Helper.createTransientAnchor("AgentPark", position - Vector(0, 0.5, 0)).doAfter(function (anchor)
        local snapPoints = {}
        for _, slot in ipairs(slots) do
            table.insert(snapPoints, Helper.createRelativeSnapPoint(anchor, slot, false, tags))
        end
        anchor.setSnapPoints(snapPoints)

        local tooltip = "Send agent to " .. space.name
        Helper.createAreaButton(space.zone, anchor, 0.7, tooltip, function (_, color, _)
            if PlayBoard.getLeader(color) then
                PlayBoard.getLeader(color).sendAgent(color, space.name)
            end
        end)
    end)
end

---
function MainBoard.sendAgent(color, spaceName)
    local space = MainBoard.spaces[spaceName]

    local parentSpace = space
    local underscoreIndex = string.find(spaceName, "_")
    if underscoreIndex then
        local parentSpaceName = string.sub(spaceName, 1, underscoreIndex - 1)
        parentSpace = MainBoard.spaces[parentSpaceName]
        assert(parentSpace, "No parent space name named: " .. parentSpaceName)
    end

    local asyncActionName = Helper.toCamelCase("_asyncGo", space.name)
    local actionName = Helper.toCamelCase("_go", space.name)

    local asyncAction = MainBoard[asyncActionName]
    local action = MainBoard[actionName]
    local leader = PlayBoard.getLeader(color)
    if not Park.isEmpty(PlayBoard.getAgentPark(color)) then
        local agentPark = PlayBoard.getAgentPark(color)
        if asyncAction then
            Helper.emitEvent("agentSent", color, spaceName)
            asyncAction(color, leader).doAfter(function (success)
                if success then
                    MainBoard.collectExtraBonuses(color, leader, spaceName)
                    Park.transfert(1, agentPark, parentSpace.park)
                end
            end)
        elseif action then
            Helper.emitEvent("agentSent", color, spaceName)
            if action(color, leader) then
                MainBoard.collectExtraBonuses(color, leader, spaceName)
                Park.transfert(1, agentPark, parentSpace.park)
            end
        else
            error("Unknow space action: " .. actionName)
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
            if Utils.isDreadnought(object, color) then
                assert(not controllingPlayer, "Too many dreadnoughts")
                controllingPlayer = color
            end
        end
    end

    -- Check player flags otherwise.
    if not controllingPlayer then
        for _, object in ipairs(bannerZone.getObjects()) do
            for _, color in ipairs(PlayBoard.getPlayBoardColors()) do
                if Utils.isControlMarker(object, color) then
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
            if Utils.isDreadnought(object, color) then
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
        local leader = leader
        leader.takeMentat(color)
        leader.drawImperiumCards(color, 1)
        return true
    else
        return false
    end
end

---
function MainBoard.getMentat()
    if Vector.distance(MainBoard.mentat.getPosition(), MainBoard.mentatZone.getPosition()) < 1 then
        return MainBoard.mentat
    else
        return nil
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
    local continuation = Helper.createContinuation()
    local options = {
        "2 -> 4",
        "3 -> 8",
        "4 -> 10",
        "5 -> 12",
    }
    Player[color].showOptionsDialog("Select spice amount to be converted into solari.", options, 1, function (_, index, _)
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
    local continuation = Helper.createContinuation()
    local options = {
        "Send a negotiator",
        "Buy tech. with -1 discount"
    }
    Player[color].showOptionsDialog("Select option.", options, 1, function (_, index, _)
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
    leader.troops(color, "supply", "negotiation", 1)
    leader.resources(color, "persuasion", 1)
    return true
end

function MainBoard._goTechNegotiation_2(color, leader)
    leader.resources(color, "persuasion", 1)
    TechMarket.registerAcquireTechOption(color, "tech_negotiation", "spice", 1)
    return true
end

---
function MainBoard._goDreadnought(color, leader)
    if leader.resources(color, "solari", -3) then
        TechMarket.registerAcquireTechOption(color, "dreadnought", "spice", 0)
        Park.transfert(1, PlayBoard.getDreadnoughtPark(color), Combat.getDreadnoughtPark(color))
        return true
    else
        return false
    end
end

--- The color could be nil (the same way it could be nil with Utils.isAgent)
function MainBoard.hasAgentInSpace(spaceName, color)
    local space = MainBoard.spaces[spaceName]
    -- Avoid since it depends on the active extensions.
    --assert(space, "Unknow space: " .. spaceName)
    if space then
        for _, object in ipairs(space.zone.getObjects()) do
            if Utils.isAgent(object, color) then
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
        return #Helper.filter(space.zone.getObjects(), Utils.isVoiceToken) > 0
    end
    return false
end

---
function MainBoard.isEmperorSpace(spaceName)
    return Helper.isElementOf(spaceName, MainBoard.getEmperorSpaces())
end

---
function MainBoard.getEmperorSpaces()
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
    return {
        "hardyWarriors",
        "stillsuits" }
end

---
function MainBoard.isFactionSpace(spaceName)
    return MainBoard.isEmperorSpace(spaceName)
        or MainBoard.isSpacingGuildSpace(spaceName)
        or MainBoard.isBeneGesseritSpace(spaceName)
        or MainBoard.isFremenSpace(spaceName)
end

---
function MainBoard.isLandsraadSpace(spaceName)
    return Helper.isElementOf(spaceName, MainBoard.getLandsraadSpaces())
end

---
function MainBoard.getLandsraadSpaces()
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
function MainBoard.getBannerZones()
    return {
        MainBoard.banners.imperialBasinBannerZone,
        MainBoard.banners.arrakeenBannerZone,
        MainBoard.banners.carthagBannerZone,
    }
end

---
function MainBoard.onObjectEnterScriptingZone(zone, object)
    if zone == MainBoard.mentatZone then
        if Utils.isMentat(object) then
            for _, color in ipairs(PlayBoard.getPlayBoardColors()) do
                object.removeTag(color)
            end
            -- FIXME One case of whitewashing too many?
            object.setColorTint(Color.fromString("White"))
        end
    end
end

---
function MainBoard.addSpaceBonus(spaceName, bonuses)
    local space = MainBoard.spaces[spaceName]
    assert(space, "Unknow space: " .. spaceName)
    if not space.extraBonuses then
        space.extraBonuses = {}
    end
    DynamicBonus.createSpaceBonus(space.zone.getPosition() + Vector(1.2, 0, 0.75), bonuses, space.extraBonuses)
end

---
function MainBoard.collectExtraBonuses(color, leader, spaceName)
    local space = MainBoard.spaces[spaceName]
    if space.extraBonuses then
        DynamicBonus.collectExtraBonuses(color, leader, space.extraBonuses)
    end
end

return MainBoard
