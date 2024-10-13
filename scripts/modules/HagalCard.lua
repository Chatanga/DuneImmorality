local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")

local MainBoard = Module.lazyRequire("MainBoard")
local PlayBoard = Module.lazyRequire("PlayBoard")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")
local TleilaxuRow = Module.lazyRequire("TleilaxuRow")
local Types = Module.lazyRequire("Types")
local Combat = Module.lazyRequire("Combat")
local TurnControl = Module.lazyRequire("TurnControl")
local Hagal = Module.lazyRequire("Hagal")
local TechMarket = Module.lazyRequire("TechMarket")
local Action = Module.lazyRequire("Action")

local HagalCard = {
    cardStrengths = {
        placeSpyYellow = 2,
        placeSpyBlue = 2,
        placeSpyGreen = 2,
        sardaukar = 4,
        dutifulService = 2,
        heighliner = 5,
        deliverSuppliesAndHeighliner = 1,
        espionage = 2,
        secrets = 1,
        desertTactics = 3,
        fremkit = 1,
        assemblyHall = 0,
        gatherSupport1 = 0,
        gatherSupport2 = 2,
        acceptContractAndShipping1 = 2,
        acceptContractAndShipping2 = 2,
        researchStation = 2,
        spiceRefinery = 1,
        arrakeen = 1,
        sietchTabr = 3,
        haggaBasinAndImperialBasin = 2,
        deepDesert = 2,
        interstellarShipping = 3,
        deliverSuppliesAndInterstellarShipping = 0,
        smugglingAndInterstellarShipping = 2,
        techNegotiation = 0,
        dreadnought1p = 3,
        dreadnought2p = 3,
        researchStationImmortality = 0,
        tleilaxuBonus1 = 0,
        tleilaxuBonus2 = 0,
        tleilaxuBonus3 = 0,
    }
}

function HagalCard.setStrength(color, card)
    Types.assertIsPlayerColor(color)
    assert(card)
    local rival = PlayBoard.getLeader(color)
    local strength = HagalCard.cardStrengths[Helper.getID(card)]
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
    local actionName = Helper.toCamelCase("_activate", cardName)
    assert(HagalCard[actionName], actionName)
    local final = HagalCard[actionName](color, rival, riseOfIx)
    return final
end

function HagalCard.flushTurnActions(color)
    HagalCard.acquiredTroopCount = HagalCard.acquiredTroopCount or 0
    local rival = PlayBoard.getLeader(color)
    assert(rival, color)

    if HagalCard.inCombat then
        local deploymentLimit = Hagal.getExpertDeploymentLimit(color)

        local garrisonedTroopCount = #Park.getObjects(Combat.getGarrisonPark(color))
        local inSupplyTroopCount = #Park.getObjects(PlayBoard.getSupplyPark(color))

        local fromGarrison = math.min(2, garrisonedTroopCount)
        local fromSupply = HagalCard.acquiredTroopCount

        if HagalCard.riseOfIx then
            -- Dreadnoughts are free and implicit.
            local count = rival.dreadnought(color, "garrison", "combat", 2)
            fromGarrison = math.max(0, fromGarrison - count)

            -- Flagship tech.
            if  PlayBoard.hasTech(color, "flagship") and
                deploymentLimit - fromGarrison - fromSupply > 0 and
                inSupplyTroopCount - fromSupply >= 3 and
                rival.resources(color, "solari", -4)
            then
                fromSupply = fromSupply + 3
            end
        end

        local realFromSupply = math.min(fromSupply, deploymentLimit)
        deploymentLimit = deploymentLimit - realFromSupply
        local continuation = Helper.createContinuation("HagalCard.flushTurnActions")
        if realFromSupply > 0 then
            rival.troops(color, "supply", "combat", realFromSupply)
            Park.onceStabilized(Action.getTroopPark(color, "combat")).doAfter(continuation.run)
        else
            continuation.run()
        end
        if fromSupply > realFromSupply then
            continuation.doAfter(function ()
                rival.troops(color, "supply", "garrison", fromSupply - realFromSupply)
            end)
        end

        local realFromGarrison = math.min(fromGarrison, deploymentLimit)
        if realFromGarrison > 0 then
            rival.troops(color, "garrison", "combat", realFromGarrison)
        end

        HagalCard.inCombat = false
    else
        rival.troops(color, "supply", "garrison", HagalCard.acquiredTroopCount)
    end
    HagalCard.acquiredTroopCount = nil
end

function HagalCard.acquireTroops(color, n, inCombat)
    if TurnControl.getCurrentPhase() == "playerTurns" then
        HagalCard.inCombat = HagalCard.inCombat or inCombat
        HagalCard.acquiredTroopCount = (HagalCard.acquiredTroopCount or 0) + n
    else
        local rival = PlayBoard.getLeader(color)
        rival.troops(color, "supply", "garrison", n)
    end
end

function HagalCard._activatePlaceSpyYellow(color, rival, riseOfIx)
    -- Order matters: CHOAM, then from right to left.
    local possiblePosts = {
        riseOfIx and "ixChoam" or "choam",
        "imperialBasin",
        "haggaBasin",
        "deepDesert",
    }
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
        riseOfIx and "ix" or "landsraadCouncil2",
        "landsraadCouncil1",
    }
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
    if HagalCard._spaceIsFree(color, "dutifulService") and Hagal.isSmartPolitics(color, "emperor") then
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
    if Combat.getCurrentConflictLevel() < 3 then
        if HagalCard._spaceIsFree(color, "deliverSupplies") and Hagal.isSmartPolitics(color, "spacingGuild") then
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
        Helper.negate(MainBoard.observationPostIsOccupied))
    if HagalCard._spaceIsFree(color, "espionage") then
        HagalCard._sendRivalAgent(color, rival, "espionage")
        rival.influence(color, "beneGesserit", 1)
        if not Helper.isEmpty(freeFactionObservationPosts) then
            rival.sendSpy(color)
        end
        return true
    else
        return false
    end
end

function HagalCard._activateSecrets(color, rival)
    if HagalCard._spaceIsFree(color, "secrets") and Hagal.isSmartPolitics(color, "beneGesserit") then
        HagalCard._sendRivalAgent(color, rival, "secrets")
        rival.influence(color, "beneGesserit", 1)
        for _, otherColor in ipairs(PlayBoard.getActivePlayBoardColors()) do
            if otherColor ~= color then
                if #PlayBoard.getIntrigues(otherColor) > 3 then
                    rival.stealIntrigues(color, otherColor, 1)
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
        if PlayBoard.hasMakerHook(color) then
            MainBoard.blowUpShieldWall(color, true)
        end
        return true
    else
        return false
    end
end

function HagalCard._activateFremkit(color, rival)
    if HagalCard._spaceIsFree(color, "fremkit") and Hagal.isSmartPolitics(color, "fremen") then
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
            rival.influence(color, 1, 1)
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
            rival.influence(color, 2, 1)
        end
        return true
    else
        return false
    end
end

function HagalCard._activateAcceptContractAndShipping1(color, rival)
    if InfluenceTrack.hasFriendship(color, "spacingGuild") then
        if HagalCard._spaceIsFree(color, "shipping") then
            HagalCard._sendRivalAgent(color, rival, "shipping")
            rival.resources(color, "solari", 2)
            rival.influence(color, 3, 1)
            return true
        else
            return false
        end
    else
        if HagalCard._spaceIsFree(color, "acceptContract") then
            HagalCard._sendRivalAgent(color, rival, "acceptContract")
            rival.resources(color, "solari", 2)
            return true
        else
            return false
        end
    end
end

function HagalCard._activateAcceptContractAndShipping2(color, rival)
    if InfluenceTrack.hasFriendship(color, "spacingGuild") then
        if HagalCard._spaceIsFree(color, "shipping") then
            HagalCard._sendRivalAgent(color, rival, "shipping")
            rival.resources(color, "solari", 2)
            rival.influence(color, 1, 1)
            return true
        else
            return false
        end
    else
        if HagalCard._spaceIsFree(color, "acceptContract") then
            HagalCard._sendRivalAgent(color, rival, "acceptContract")
            rival.resources(color, "solari", 2)
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
        MainBoard.applyControlOfAnySpace("spiceRefinery")
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
        MainBoard.applyControlOfAnySpace("arrakeen")
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
        if PlayBoard.hasMakerHook(color) then
            MainBoard.blowUpShieldWall(color, true)
        end
        HagalCard.acquireTroops(color, 0, true)
        if bestDesertSpace == "haggaBasin" and PlayBoard.hasMakerHook(color) then
            rival.resources(color, "spice", bestSpiceBonus)
            rival.callSandworm(color, 1)
        elseif bestDesertSpace == "imperialBasin" then
            rival.resources(color, "spice", bestTotalSpice)
            MainBoard.applyControlOfAnySpace(bestDesertSpace)
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
        if not MainBoard.shieldWallIsStanding() and PlayBoard.hasMakerHook(color) then
            rival.resources(color, "spice", spiceBonus)
            rival.callSandworm(color, 2)
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
        TechMarket.registerAcquireTechOption(color, "techNegotiationTechBuyOption", "spice", 1)
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
        TechMarket.registerAcquireTechOption(color, "dreadnoughtTechBuyOption", "spice", 0)
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
        HagalCard.acquireTroops(color, 0, true)
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
