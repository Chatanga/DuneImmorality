local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")

local MainBoard = Module.lazyRequire("MainBoard")
local PlayBoard = Module.lazyRequire("PlayBoard")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")
local TleilaxuRow = Module.lazyRequire("TleilaxuRow")
local Types = Module.lazyRequire("Types")
local Combat = Module.lazyRequire("Combat")
local ConflictCard = Module.lazyRequire("ConflictCard")

local HagalCard = {
    cards = {
        placeSpyYellow = { draw = true, strength = 2 },
        placeSpyBlue = { draw = true, strength = 2 },
        placeSpyGreen = { draw = true, strength = 2 },
        sardaukar = { strength = 4 },
        dutifulService = { strength = 2 },
        heighliner = { combat = true, strength = 5 },
        deliverSuppliesAndHeighliner = { combat = true, strength = 1 }, -- combat...
        espionage = { strength = 2 },
        secrets = { strength = 1 },
        desertTactics = { combat = true, strength = 3 },
        fremkit = { combat = true, strength = 1 },
        assemblyHall = { strength = 0 },
        gatherSupport1 = { strength = 0 },
        gatherSupport2 = { strength = 2 },
        acceptContractAndShipping1 = { strength = 2 },
        acceptContractAndShipping2 = { strength = 2 },
        researchStation = { combat = true, strength = 2 },
        spiceRefinery = { combat = true, strength = 1 },
        arrakeen = { combat = true, strength = 1 },
        sietchTabr = { combat = true, strength = 3 },
        haggaBasinAndImperialBasin = { combat = true, strength = 2 },
        deepDesert = { combat = true, strength = 2 },
        interstellarShipping = { strength = 3 },
        deliverSuppliesAndInterstellarShipping = { strength = 0 },
        smugglingAndInterstellarShipping = { strength = 2 },
        techNegotiation = { strength = 0 },
        dreadnought1p = { strength = 3 },
        dreadnought2p = { strength = 3 },
        researchStationImmortality = { combat = true, strength = 0 },
        carthag1 = { draw = true, strength = 0 },
        carthag2 = { draw = true, strength = 0 },
        carthag3 = { draw = true, strength = 0 },
    }
}

function HagalCard.setStrength(color, card)
    Types.assertIsPlayerColor(color)
    assert(card)
    local rival = PlayBoard.getLeader(color)
    local strength = HagalCard.cards[Helper.getID(card)].strength
    if strength then
        rival.resources(color, "strength", strength)
        return true
    else
        return false
    end
end

function HagalCard.activate(color, card, riseOfIx)
    Types.assertIsPlayerColor(color)
    assert(card)
    local cardName = Helper.getID(card)
    HagalCard.riseOfIx = riseOfIx
    local rival = PlayBoard.getLeader(color)
    assert(rival, color)
    local actionName = Helper.toCamelCase("_activate", cardName)
    assert(HagalCard[actionName], actionName)
    local final = HagalCard[actionName](color, rival, riseOfIx)
    Helper.dump("Activating Hagal card:", cardName, "->", final and "yes" or "no")
    return final
end

function HagalCard.flushTurnActions(color)
    --Helper.dumpFunction("HagalCard.flushTurnActions", color)
    HagalCard.acquiredTroopCount = HagalCard.acquiredTroopCount or 0
    local rival = PlayBoard.getLeader(color)
    assert(rival, color)
    if HagalCard.inCombat then
        if HagalCard.riseOfIx then
            local count = rival.dreadnought(color, "garrison", "combat", 2)
            rival.troops(color, "garrison", "combat", 2 - count)
            rival.troops(color, "supply", "combat", HagalCard.acquiredTroopCount)

            if PlayBoard.hasTech(color, "flagship") then
                local solari = PlayBoard.getResource(color, "solari")
                local supply = PlayBoard.getSupplyPark(color)
                local leader = PlayBoard.getLeader(color)

                if PlayBoard.hasTech(color, "flagship") and solari:get() >= 4 and #Park.getObjects(supply) >= 3 then
                    leader.resources(color, "solari", 4)
                    leader.troops(color, "supply", "combat", 3)
                end
            end
        else
            rival.troops(color, "garrison", "combat", 2)
            rival.troops(color, "supply", "combat", HagalCard.acquiredTroopCount)
        end

        HagalCard.inCombat = false
    else
        rival.troops(color, "supply", "garrison", HagalCard.acquiredTroopCount)
    end
    HagalCard.acquiredTroopCount = nil
end

function HagalCard.acquireTroops(color, n, inCombat)
    HagalCard.inCombat = HagalCard.inCombat or inCombat
    HagalCard.acquiredTroopCount = (HagalCard.acquiredTroopCount or 0) + n
end

function HagalCard._activatePlaceSpyYellow(color, rival, riseOfIx)
    -- Order matters: CHOAM, then from right to left.
    local possiblePosts = {
        "imperialBasin",
        "haggaBasin",
        "deepDesert",
    }
    if riseOfIx then
        table.insert(possiblePosts, 1, "ixChoam")
    else
        table.insert(possiblePosts, 1, "choam")
    end
    for _, observationPostName in ipairs(possiblePosts) do
        if not MainBoard.observationPostIsOccupied(observationPostName) then
            rival.sendSpy(color, observationPostName)
            break
        end
    end
    return false
end

function HagalCard._activatePlaceSpyBlue(color, rival, riseOfIx)
    -- Order matters: from right to left.
    local possiblePosts = {
        "spiceRefineryArrakeen",
        "researchStationSpiceRefinery",
        "sietchTabrResearchStation",
    }
    for _, observationPostName in ipairs(possiblePosts) do
        if not MainBoard.observationPostIsOccupied(observationPostName) then
            rival.sendSpy(color, observationPostName)
            break
        end
    end
    return false
end

function HagalCard._activatePlaceSpyGreen(color, rival, riseOfIx)
    -- Order matters: from right to left.
    local possiblePosts = {
        "landsraadCouncil2",
        "landsraadCouncil1",
    }
    if riseOfIx then
        table.insert(possiblePosts, 1, "ix")
    end
    for _, observationPostName in ipairs(possiblePosts) do
        if not MainBoard.observationPostIsOccupied(observationPostName) then
            rival.sendSpy(color, observationPostName)
            break
        end
    end
    return false
end

function HagalCard._activateSardaukar(color, rival)
    if HagalCard._spaceIsFree(color, "sardaukar") then
        HagalCard._sendRivalAgent(color, rival, "sardaukar")
        rival.influence(color, "emperor", 1)
        HagalCard.acquireTroops(color, 2)
        return true
    else
        return false
    end
end

function HagalCard._activateDutifulService(color, rival)
    if HagalCard._spaceIsFree(color, "dutifulService") then
        HagalCard._sendRivalAgent(color, rival, "dutifulService")
        rival.influence(color, "emperor", 1)
        return true
    else
        return false
    end
end

function HagalCard._activateHeighliner(color, rival)
    if HagalCard._spaceIsFree(color, "heighliner") then
        HagalCard._sendRivalAgent(color, rival, "heighliner")
        rival.influence(color, "spacingGuild", 1)
        HagalCard.acquireTroops(color, 3, true)
        return true
    else
        return false
    end
end

function HagalCard._activateDeliverSuppliesAndHeighliner(color, rival)
    local conflictName = Combat.getTurnConflictName()
    assert(conflictName, "No conflict!")
    if ConflictCard.getLevel(conflictName) < 3 then
        if HagalCard._spaceIsFree(color, "deliverSupplies") then
            HagalCard._sendRivalAgent(color, rival, "deliverSupplies")
            rival.influence(color, "spacingGuild", 1)
            return true
        else
            return false
        end
    else
        return HagalCard._activateHeighliner(color, rival)
    end
end

function HagalCard._activateEspionage(color, rival)
    local freeFactionObservationPosts = Helper.filter(
        { "emperor", "spacingGuild", "beneGesserit", "fremen" },
        MainBoard.observationPostIsOccupied)
    if HagalCard._spaceIsFree(color, "espionage") and not Helper.isEmpty(freeFactionObservationPosts) then
        HagalCard._sendRivalAgent(color, rival, "espionage")
        rival.influence(color, "beneGesserit", 1)
        rival.sendSpy(color)
        return true
    else
        return false
    end
end

function HagalCard._activateSecrets(color, rival)
    if HagalCard._spaceIsFree(color, "secrets") then
        HagalCard._sendRivalAgent(color, rival, "secrets")
        rival.influence(color, "beneGesserit", 1)
        for _, otherColor in ipairs(PlayBoard.getActivePlayBoardColors()) do
            if otherColor ~= color then
                if #PlayBoard.getIntrigues(otherColor) > 3 then
                    rival.stealIntrigue(color, otherColor, 1)
                end
            end
        end
        return true
    else
        return false
    end
end

function HagalCard._activateDesertTactics(color, rival)
    if HagalCard._spaceIsFree(color, "desertTactics") then
        HagalCard._sendRivalAgent(color, rival, "desertTactics")
        rival.influence(color, "fremen", 1)
        HagalCard.acquireTroops(color, 1, true)
        MainBoard.blowUpShieldWall(color, true)
        return true
    else
        return false
    end
end

function HagalCard._activateFremkit(color, rival)
    if HagalCard._spaceIsFree(color, "fremkit") then
        HagalCard._sendRivalAgent(color, rival, "fremkit")
        rival.influence(color, "fremen", 1)
        HagalCard.acquireTroops(color, 0, true)
        return true
    else
        return false
    end
end

function HagalCard._activateAssemblyHall(color, rival)
    if HagalCard._spaceIsFree(color, "assemblyHall") then
        HagalCard._sendRivalAgent(color, rival, "assemblyHall")
        rival.drawIntrigues(color, 1)
        if InfluenceTrack.hasFriendship(color, "emperor") then
            rival.influence(color, "emperor", 1)
        end
        return true
    else
        return false
    end
end

function HagalCard._activateGatherSupport1(color, rival)
    if HagalCard._spaceIsFree(color, "gatherSupport") then
        HagalCard._sendRivalAgent(color, rival, "gatherSupport")
        HagalCard.acquireTroops(color, 1)
        return true
    else
        return false
    end
end

function HagalCard._activateGatherSupport2(color, rival)
    if HagalCard._spaceIsFree(color, "gatherSupport") then
        HagalCard._sendRivalAgent(color, rival, "gatherSupport")
        HagalCard.acquireTroops(color, 1)
        if InfluenceTrack.hasFriendship(color, "emperor") then
            rival.influence(color, 1, 2)
        end
        return true
    else
        return false
    end
end

function HagalCard._activateAcceptContractAndShipping1(color, rival)
    if InfluenceTrack.hasFriendship(color, "spacingGuild") then
        if HagalCard._spaceIsFree(color, "interstellarShipping") then
            HagalCard._sendRivalAgent(color, rival, "interstellarShipping")
            rival.resources(color, "solari", 2)
            return true
        else
            return false
        end
    else
        if HagalCard._spaceIsFree(color, "acceptContract") then
            HagalCard._sendRivalAgent(color, rival, "acceptContract")
            rival.resources(color, "solari", 2)
            rival.influence(color, 1, 3)
            return true
        else
            return false
        end
    end
end

function HagalCard._activateAcceptContractAndShipping2(color, rival)
    if InfluenceTrack.hasFriendship(color, "spacingGuild") then
        if HagalCard._spaceIsFree(color, "interstellarShipping") then
            HagalCard._sendRivalAgent(color, rival, "interstellarShipping")
            rival.resources(color, "solari", 2)
            return true
        else
            return false
        end
    else
        if HagalCard._spaceIsFree(color, "acceptContract") then
            HagalCard._sendRivalAgent(color, rival, "acceptContract")
            rival.resources(color, "solari", 2)
            rival.influence(color, 1, 1)
            return true
        else
            return false
        end
    end
end

function HagalCard._activateResearchStation(color, rival)
    if HagalCard._spaceIsFree(color, "researchStation") then
        HagalCard._sendRivalAgent(color, rival, "researchStation")
        HagalCard.acquireTroops(color, 2, true)
        return true
    else
        return false
    end
end

function HagalCard._activateSpiceRefinery(color, rival)
    if HagalCard._spaceIsFree(color, "spiceRefinery") then
        HagalCard._sendRivalAgent(color, rival, "spiceRefinery")
        HagalCard.acquireTroops(color, 0, true)
        rival.signetRing(color)
        return true
    else
        return false
    end
end

function HagalCard._activateArrakeen(color, rival)
    if HagalCard._spaceIsFree(color, "arrakeen") then
        HagalCard._sendRivalAgent(color, rival, "arrakeen")
        rival.signetRing(color)
        HagalCard.acquireTroops(color, 1, true)
        return true
    else
        return false
    end
end

function HagalCard._activateSietchTabr(color, rival)
    if HagalCard._spaceIsFree(color, "sietchTabr") and InfluenceTrack.hasFriendship(color, "fremen") then
        HagalCard._sendRivalAgent(color, rival, "sietchTabr")
        rival.takeMakerHook(color)
        HagalCard.acquireTroops(color, 1, true)
        rival.resources(color, "water", 1)
        return true
    else
        return false
    end
end

function HagalCard._activateHaggaBasinAndImperialBasin(color, rival)
    -- Note: order matters.
    local desertSpaces = {
        haggaBasin = 2,
        imperialBasin = 1,
    }

    local bestDesertSpace
    local bestSpiceBonus = 0.5
    local bestTotalSpice = 0
    for desertSpace, baseSpice in pairs(desertSpaces) do
        if HagalCard._spaceIsFree(desertSpace) then
            local spiceBonus = MainBoard.getSpiceBonus(desertSpace):get()
            local totalSpice = baseSpice + spiceBonus
            if spiceBonus > bestSpiceBonus then
                bestDesertSpace = desertSpace
                bestSpiceBonus = spiceBonus
                bestTotalSpice = totalSpice
            end
        end
    end

    if bestDesertSpace then
        HagalCard._sendRivalAgent(color, rival, bestDesertSpace)
        MainBoard.getSpiceBonus(bestDesertSpace):set(0)
        MainBoard.blowUpShieldWall(color, true)
        HagalCard.acquireTroops(color, 0, true)
        if bestDesertSpace == "haggaBasin" then
            rival.resources(color, "spice", bestSpiceBonus)
            rival.callSandworm(color, 1)
        else
            rival.resources(color, "spice", bestTotalSpice)
        end
        return true
    else
        return false
    end
end

function HagalCard._activateDeepDesert(color, rival)
    local spiceBonus = MainBoard.getSpiceBonus("deepDesert"):get()
    if HagalCard._spaceIsFree(color, "deepDesert") and spiceBonus > 0 then
        HagalCard._sendRivalAgent(color, rival, "deepDesert")
        MainBoard.getSpiceBonus("deepDesert"):set(0)
        HagalCard.acquireTroops(color, 0, true)
        if not MainBoard.shieldWallIsStanding() then
            rival.resources(color, "spice", spiceBonus)
            rival.callSandworm(color, 1)
        else
            rival.resources(color, "spice", 4 + spiceBonus)
        end
        return true
    else
        return false
    end
end

-- ***

function HagalCard._activateInterstellarShipping(color, rival)
    if HagalCard._spaceIsFree(color, "interstellarShipping") and InfluenceTrack.hasFriendship(color, "spacingGuild") then
        HagalCard._sendRivalAgent(color, rival, "interstellarShipping")
        rival.shipments(color, 2)
        return true
    else
        return false
    end
end

function HagalCard._activateDeliverSuppliesAndInterstellarShipping(color, rival)
    if InfluenceTrack.hasFriendship(color, "spacingGuild") then
        return HagalCard._activateInterstellarShipping(color, rival)
    else
        if HagalCard._spaceIsFree(color, "deliverSupplies") then
            HagalCard._sendRivalAgent(color, rival, "deliverSupplies")
            rival.influence(color, "spacingGuild", 1)
            return true
        else
            return false
        end
    end
end

function HagalCard._activateSmugglingAndInterstellarShipping(color, rival)
    if InfluenceTrack.hasFriendship(color, "spacingGuild") then
        return HagalCard._activateInterstellarShipping(color, rival)
    else
        if HagalCard._spaceIsFree(color, "smuggling") then
            HagalCard._sendRivalAgent(color, rival, "smuggling")
            rival.shipments(color, 1)
            return true
        else
            return false
        end
    end
end

function HagalCard._activateTechNegotiation(color, rival)
    if HagalCard._spaceIsFree(color, "techNegotiation") then
        HagalCard._sendRivalAgent(color, rival, "techNegotiation")
        if not rival.acquireTech(color, nil, 1) then
            rival.troops(color, "supply", "negotiation", 1)
        end
        return true
    else
        return false
    end
end

function HagalCard._activateDreadnought1p(color, rival)
    if HagalCard._spaceIsFree(color, "dreadnought") and PlayBoard.getAquiredDreadnoughtCount(color) < 2 then
        HagalCard._sendRivalAgent(color, rival, "dreadnought")
        rival.dreadnought(color, "supply", "garrison", 1)
        rival.acquireTech(color, nil, 0)
        return true
    else
        return false
    end
end

function HagalCard._activateDreadnought2p(color, rival)
    if HagalCard._spaceIsFree(color, "dreadnought") and PlayBoard.getAquiredDreadnoughtCount(color) < 2 then
        HagalCard._sendRivalAgent(color, rival, "dreadnought")
        rival.dreadnought(color, "supply", "garrison", 1)
        HagalCard.acquireTroops(color, 2)
        return true
    else
        return false
    end
end

-- ***

function HagalCard._activateResearchStationImmortality(color, rival)
    if HagalCard._spaceIsFree(color, "researchStation") then
        HagalCard._sendRivalAgent(color, rival, "researchStation")
        rival.beetle(color, 2)
        return true
    else
        return false
    end
end

function HagalCard._activateTleilaxuBonus1(color, rival)
    rival.beetle(color, 1)
    TleilaxuRow.trash(1)
    return false
end

function HagalCard._activateTleilaxuBonus2(color, rival)
    rival.beetle(color, 1)
    return false
end

function HagalCard._activateTleilaxuBonus3(color, rival)
    rival.beetle(color, 1)
    TleilaxuRow.trash(2)
    return false
end

function HagalCard._sendRivalAgent(color, rival, spaceName)
    if MainBoard.sendRivalAgent(color, spaceName) then
        if PlayBoard.useTech(color, "trainingDrones") then
            HagalCard.acquireTroops(color, 0)
        end
        return true
    else
        return false
    end
end

function HagalCard._spaceIsFree(color, spaceName)
    if not MainBoard.hasVoiceToken(spaceName) and not MainBoard.hasAgentInSpace(spaceName, color) then
        if MainBoard.hasEnemyAgentInSpace(spaceName, color) then
            return PlayBoard.useTech(color, "invasionShips")
        else
            return true
        end
    else
        return false
    end
end

return HagalCard
