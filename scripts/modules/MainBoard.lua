local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")

local Resource = Module.lazyRequire("Resource")
local Utils = Module.lazyRequire("Utils")
local Playboard = Module.lazyRequire("Playboard")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")
local TleilaxuResearch = Module.lazyRequire("TleilaxuResearch")
local TechMarket = Module.lazyRequire("TechMarket")
local Combat = Module.lazyRequire("Combat")

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
            conspire = { zone = "cd9386", anchor = nil },
            wealth = { zone = "b2c461", anchor = nil },
            heighliner = { zone = "8b0515", anchor = nil },
            foldspace = { zone = "9a9eb5", anchor = nil },
            selectiveBreeding = { zone = "7dc6e5", anchor = nil },
            secrets = { zone = "1f7c08", anchor = nil },
            hardyWarriors = { zone = "a2fd8e", anchor = nil },
            stillsuits = { zone = "556f43", anchor = nil },
            -- Landsraad
            highCouncil = { zone = "8a6315", anchor = nil },
            mentat = { zone = "30cff9", anchor = nil },
            swordmaster = { zone = '6cc2f8', anchor = nil },
            rallyTroops = { zone = '6932df', anchor = nil },
            hallOfOratory = { zone = '3e7409', anchor = nil },
            -- CHOAM
            secureContract = { zone = "db4022", anchor = nil },
            sellMelange = { zone = "7539a3", anchor = nil },
            -- Dune
            arrakeen = { zone = "17b646", anchor = nil },
            carthag = { zone = "b1c938", anchor = nil },
            researchStation = { zone = "af11aa", anchor = nil },
            sietchTabr = { zone = "5bc970", anchor = nil },
            -- Desert
            imperialBasin = { zone = "2c77c1", anchor = nil },
            haggaBasin = { zone = "622708", anchor = nil },
            theGreatFlat = { zone = "69f925", anchor = nil },
        },
        ixSpaces = {
            -- Landsraad
            highCouncil = { zone = "dbdd82", anchor = nil },
            mentat = { zone = "d6c7dd", anchor = nil },
            swordmaster = { zone = "035975", anchor = nil },
            rallyTroops = Helper.erase,
            hallOfOratory = Helper.erase,
            -- CHOAM
            secureContract = Helper.erase,
            sellMelange = Helper.erase,
            smuggling = { zone = "82589e", anchor = nil },
            interstellarShipping = { zone = "487ad9", anchor = nil },
            -- Ix
            techNegotiation = { zone = "04f512", anchor = nil },
            dreadnought = { zone = "83ea90", anchor = nil },
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
        phaseMarker = "fb41e2"
    }))

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
        MainBoard.spiceBonuses[name] = Resource.new(token, nil, "spice", 0, state)
    end
end

---
function MainBoard.setUp(riseOfIx)
    if riseOfIx then
        MainBoard.highCouncilZones.base.destruct()
        MainBoard.highCouncilZone = MainBoard.highCouncilZones.ix
        MainBoard.mentatZones.base.destruct()
        MainBoard.mentatZone = MainBoard.mentatZones.ix
        Helper.append(MainBoard.spaces, MainBoard.ixSpaces)
    else
        MainBoard.highCouncilZones.ix.destruct()
        MainBoard.highCouncilZone = MainBoard.highCouncilZones.base
        MainBoard.mentatZones.ix.destruct()
        MainBoard.mentatZone = MainBoard.mentatZones.base
        MainBoard.board.setState(2)
    end
    MainBoard.highCouncilPark = MainBoard:createHighCouncilPark(MainBoard.highCouncilZone)

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

        MainBoard.createSpaceButton(space, p, slots)
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
            MainBoard.mentat.getPosition(MainBoard.mentatZone.getPosition())

            -- Recalling agents.
            for _, space in pairs(MainBoard.spaces) do
                for _, agent in ipairs(Park.getObjects(space.park)) do
                    assert(agent.hasTag("Agent"))
                    for color, _ in pairs(Playboard.getPlayboards()) do
                        if agent.hasTag(color) then
                            Park.putObject(agent, Playboard.getAgentPark(color))
                        end
                    end
                end
            end
        end
    end)
end

---
function MainBoard:createHighCouncilPark(zone)
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
        true)
end

---
function MainBoard.getHighCouncilSeatPark()
    return MainBoard.highCouncilPark
end

---
function MainBoard.createSpaceButton(space, position, slots)
    local zone = space.zone -- Park.createBoundingZone(0, Vector(1, 3, 0.5), slots)
    local tags = { "Agent" }
    space.park = Park.createPark("AgentPark", slots, Vector(0, 0, 0), zone, tags, nil, false)

    Helper.createTransientAnchor("AgentPark", position - Vector(0, 0.4, 0)).doAfter(function (anchor)
        anchor.interactable = false
        local snapPoints = {}
        for _, slot in ipairs(slots) do
            table.insert(snapPoints, Helper.createRelativeSnapPoint(anchor, slot, false, tags))
        end
        anchor.setSnapPoints(snapPoints)

        Helper.createAbsoluteButtonWithRoundness(anchor, 10, false, {
            click_function = Helper.createGlobalCallback(function (_, color, _)
                Playboard.getLeader(color).sendAgent(color, space.name)
            end),
            position = Vector(position.x, 0.7, position.z),
            width = space.zone.getScale().x * 500,
            height = space.zone.getScale().z * 500,
            color = { 0, 0, 0, 0 },
            tooltip = "Send agent to " .. space.name
        })

    end)
end

---
function MainBoard.sendAgent(color, spaceName)
    local space = MainBoard.spaces[spaceName]

    local asyncActionName = Helper.toCamelCase("asyncGo", space.name)
    local actionName = Helper.toCamelCase("go", space.name)

    local asyncAction = MainBoard[asyncActionName]
    local action = MainBoard[actionName]
    if not Park.isEmpty(Playboard.getAgentPark(color)) then
        local agentPark = Playboard.getAgentPark(color)
        if asyncAction then
            asyncAction(color).doAfter(function (success)
                if success then
                    Park.transfert(1, agentPark, space.park)
                end
            end)
        elseif action then
            if action(color) then
                Park.transfert(1, agentPark, space.park)
            end
        else
            log("Unknow space action: " .. actionName)
        end
    end
end

---
function MainBoard.goConspire(color)
    if MainBoard.payResource(color, "spice", 4) then
        MainBoard.gainResource(color, "solari", 5)
        Playboard.getLeader(color).troops(color, "supply", "garrison", 2)
        Playboard.getLeader(color).drawIntrigues(color, 1)
        MainBoard.gainInfluence(color, "emperor")
        return true
    else
        return false
    end
end

---
function MainBoard.goWealth(color)
    MainBoard.gainResource(color, "solari", 2)
    MainBoard.gainInfluence(color, "emperor")
end

---
function MainBoard.goHeighliner(color)
    if MainBoard.payResource(color, "spice", 6) then
        MainBoard.gainResource(color, "water", 2)
        Playboard.getLeader(color).troops(color, "supply", "garrison", 5)
        MainBoard.gainInfluence(color, "spacingGuild")
        return true
    else
        return false
    end
end

---
function MainBoard.goFoldspace(color)
    Playboard.getLeader(color).acquireFoldspaceCard(color)
    MainBoard.gainInfluence(color, "spacingGuild")
    return true
end

---
function MainBoard.goSelectiveBreeding(color)
    if MainBoard.payResource(color, "spice", 2) then
        MainBoard.gainInfluence(color, "beneGesserit")
        return true
    else
        return false
    end
end

---
function MainBoard.goSecrets(color)
    Playboard.getLeader(color).drawIntrigues(color, 1)
    for otherColor, _ in pairs(Playboard.getPlayboards()) do
        if otherColor ~= color then
            if #Playboard.getIntrigues(otherColor) > 3 then
                Playboard.getLeader(color).stealIntrigue(color, otherColor, 1)
            end
        end
    end
    MainBoard.gainInfluence(color, "beneGesserit")
    return true
end

---
function MainBoard.goHardyWarriors(color)
    if MainBoard.payResource(color, "water", 1) then
        Playboard.getLeader(color).troops(color, "supply", "garrison", 2)
        MainBoard.gainInfluence(color, "fremen")
        return true
    else
        return false
    end
end

---
function MainBoard.goStillsuits(color)
    MainBoard.gainResource(color, "water", 1)
    MainBoard.gainInfluence(color, "fremen")
    return true
end

---
function MainBoard.goImperialBasin(color)
    if MainBoard.anySpiceSpace(color, 0, 1, MainBoard.spiceBonuses.imperialBasin) then
        MainBoard.applyControlOfAnySpace(MainBoard.spaces.imperialBasin, "spice")
        return true
    else
        return false
    end
end

---
function MainBoard.goHaggaBasin(color)
    return MainBoard.anySpiceSpace(color, 1, 2, MainBoard.spiceBonuses.haggaBasin)
end

---
function MainBoard.goTheGreatFlat(color)
    return MainBoard.anySpiceSpace(color, 2, 3, MainBoard.spiceBonuses.theGreatFlat)
end

---
function MainBoard.anySpiceSpace(color, waterCost, spiceBaseAmount, spiceBonus)
    if MainBoard.payResource(color, "water", waterCost) then
        local harvestedSpiceAmount = MainBoard.harvestSpice(spiceBaseAmount, spiceBonus)
        MainBoard.gainResource(color, "spice", harvestedSpiceAmount)
        return true
    else
        return false
    end
end

---
function MainBoard.harvestSpice(baseAmount, spiceBonus)
    assert(spiceBonus)
    local spiceAmount = baseAmount + spiceBonus:get()
    spiceBonus:set(0)
    return spiceAmount
end

---
function MainBoard.goSietchTabr(color)
    if (InfluenceTrack.hasFriendship(color, "fremen")) then
        MainBoard.gainResource(color, "water", 1)
        Playboard.getLeader(color).troops(color, "supply", "garrison", 1)
        return true
    else
        return false
    end
end

---
function MainBoard.goResearchStation(color)
    if MainBoard.payResource(color, "water", 2) then
        if true then
            MainBoard.drawImperiumCards(color, 3)
        else
            MainBoard.drawImperiumCards(color, 2)
            Playboard.getLeader(color).research()
        end
        return true
    else
        return false
    end
end

---
function MainBoard.goCarthag(color)
    Playboard.getLeader(color).drawIntrigues(color, 1)
    Playboard.getLeader(color).troops(color, "supply", "garrison", 1)
    MainBoard.applyControlOfAnySpace(MainBoard.spaces.carthag, "solari")
    return true
end

---
function MainBoard.goArrakeen(color)
    MainBoard.drawImperiumCards(color, 1)
    MainBoard.applyControlOfAnySpace(MainBoard.spaces.arrakeen, "solari")
    return true
end

---
function MainBoard.applyControlOfAnySpace(space, resourceName)
    local controllingPlayer = MainBoard.getControllingPlayer(space)
    if controllingPlayer then
        MainBoard.gainResource(controllingPlayer, resourceName, 1)
    end
    return true
end

---
function MainBoard.getControllingPlayer(space)
    local controllingPlayer = nil

    -- Check player dreadnoughts first since they supersede flags.
    for _, object in ipairs(space.zone.getObjects()) do
        for color, _ in pairs(Playboard.getPlayboards()) do
            if Utils.isDreadnought(color, object) then
                assert(not controllingPlayer, "Too many dreadnoughts")
                controllingPlayer = color
            end
        end
    end

    -- Check player flags otherwise.
    if not controllingPlayer then
        for _, object in ipairs(space.zone.getObjects()) do
            for color, _ in pairs(Playboard.getPlayboards()) do
                if Utils.isFlag(color, object) then
                    assert(not controllingPlayer, "Too many flags around")
                    controllingPlayer = color
                end
            end
        end
    end

    return controllingPlayer
end

---
function MainBoard.goSwordmaster(color)
    if not Playboard.hasSwordmaster(color) and MainBoard.payResource(color, "solari", 8) then
        Playboard.getLeader(color).recruitSwordmaster(color)
        return true
    else
        return false
    end
end

---
function MainBoard.goMentat(color)
    if MainBoard.payResource(color, "solari", 2) then
        Playboard.getLeader(color).takeMentat(color)
        return true
    else
        return false
    end
end

---
function MainBoard.getMentat()
    return MainBoard.mentat
end

---
function MainBoard.goHighCouncil(color)
    -- FIXME Interleaved conditions...
    if not Playboard.hasACouncilSeat(color) and MainBoard.payResource(color, "solari", 5) then
        return Playboard.getLeader(color).takeHighCouncilSeat(color)
    else
        return false
    end
end

---
function MainBoard.goSecureContract(color)
    MainBoard.gainResource(color, "solari", 3)
    return true
end

---
function MainBoard.asyncGoSellMelange(color)
    local continuation = Helper.createContinuation()
    local options = {
        "2 -> 4",
        "3 -> 8",
        "4 -> 10",
        "5 -> 12",
    }
    Player[color].showOptionsDialog("Select spice amount to be converted into solari.", options, 1, function (_, index, _)
        local spiceCost = index + 1
        local solariBenefit = (index + 1) * 2 + 2
        local success
        if MainBoard.payResource(color, "spice", spiceCost) then
            MainBoard.gainResource(color, "solari", solariBenefit)
            success = true
        else
            success = false
        end
        continuation.run(success)
    end)
    return continuation
end

---
function MainBoard.goRallyTroops(color)
    if MainBoard.payResource(color, "solari", 4) then
        Playboard.getLeader(color).troops(color, "supply", "garrison", 4)
        return true
    else
        return false
    end
end

---
function MainBoard.goHallOfOratory(color)
    Playboard.getLeader(color).troops(color, "supply", "garrison", 1)
    Playboard.getLeader(color).gainPersuasion(color, 1)
    return true
end

---
function MainBoard.goSmuggling(color)
    MainBoard.gainResource(color, "solari", 1)
    Playboard.getLeader(color).moveFreighter(color, 1)
    return true
end

---
function MainBoard.goInterstellarShipping(color)
    if (InfluenceTrack.hasFriendship(color, "spacingGuild")) then
        Playboard.getLeader(color).moveFreighter(color, 2)
        return true
    else
        return false
    end
end

---
function MainBoard.goTechNegotiation(color)
    if not Playboard.getLeader(color).troops(color, "supply", "negotiation", 1) then
        TechMarket.registerTechDiscount(color, "tech_negotiation", 1)
    end
    return true
end

---
function MainBoard.goDreadnought(color)
    if MainBoard.payResource(color, "solari", 3) then
        TechMarket.registerTechDiscount(color, "dreadnought", 0)
        Park.transfert(1, Playboard.getDreadnoughtPark(color), Combat.getDreadnoughtPark(color))
        return true
    else
        return false
    end
end

-- Implied: when sending an agent on a board space.
---
function MainBoard.gainResource(color, resourceName, amount)
    Utils.assertIsPlayerColor(color)
    Utils.assertIsResourceName(resourceName)
    Utils.assertIsInteger(amount)
    Playboard.getLeader(color).resource(color, resourceName, amount)
end

-- Implied: when sending an agent on a board space.
---
function MainBoard.payResource(color, resourceName, amount)
    return Playboard.getLeader(color).resource(color, resourceName, -amount)
end

-- Implied: when sending an agent on a board space.
---
function MainBoard.gainInfluence(color, faction)
    Utils.assertIsPlayerColor(color)
    Utils.assertIsFaction(faction)
    Playboard.getLeader(color).influence(color, faction, 1)
end

-- Implied: when sending an agent on a board space.
---
function MainBoard.drawImperiumCards(color, amount)
    local realAmount = amount
    if TleilaxuResearch.hasReachedTwoHelices(color) then
        realAmount = amount + 1
    end
    Playboard.getLeader(color).drawImperiumCards(color, realAmount)
end

---
function MainBoard.isEmperorSpace(spaceName)
    return Helper.isElementOf(spaceName, {
        "conspire",
        "wealth" })
end

---
function MainBoard.isSpacingGuildSpace(spaceName)
    return Helper.isElementOf(spaceName, {
        "heighliner",
        "foldspace" })
end

---
function MainBoard.isBeneGesseritSpace(spaceName)
    return Helper.isElementOf(spaceName, {
        "selectiveBreeding",
        "secrets" })
end

---
function MainBoard.isFremenSpace(spaceName)
    return Helper.isElementOf(spaceName, {
        "hardyWarriors",
        "stillsuits" })
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
    return Helper.isElementOf(spaceName, {
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
        "dreadnought" })
end

---
function MainBoard.isCHOAMSpace(spaceName)
    return Helper.isElementOf(spaceName, {
        "secureContract",
        "sellMelange",
        "secureContract",
        "sellMelange",
        "smuggling",
        "interstellarShipping" })
end

---
function MainBoard.isCitySpace(spaceName)
    return Helper.isElementOf(spaceName, {
        "arrakeen",
        "carthag",
        "researchStation",
        "sietchTabr" })
end

---
function MainBoard.isDesertSpace(spaceName)
    return Helper.isElementOf(spaceName, {
        "imperialBasin",
        "haggaBasin",
        "theGreatFlat" })
end

---
function MainBoard.isSpiceTradeSpace(spaceName)
    return MainBoard.isDesertSpace(spaceName)
        or MainBoard.isCHOAMSpace(spaceName)
end

---
function MainBoard.onObjectEnterScriptingZone(zone, object)
    if zone == MainBoard.mentatZone then
        if Utils.isMentat(object) then
            for color, _ in pairs(Playboard.getPlayboards()) do
                object.removeTag(color)
            end
            -- FIXME One case of whitewashing too many?
            object.setColorTint(Color.fromString("White"))
        end
    end
end

return MainBoard
