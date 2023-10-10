local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")

local MainBoard = Module.lazyRequire("MainBoard")
local PlayBoard = Module.lazyRequire("PlayBoard")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")
local TleilaxuRow = Module.lazyRequire("TleilaxuRow")
local Hagal = Module.lazyRequire("Hagal")

local HagalCard = {
    strengths = {
        conspire = 4,
        wealth = 3,
        heighliner = 6,
        foldspace = 1,
        selectiveBreeding = 2,
        secrets = 1,
        hardyWarriors = 5,
        stillsuits = 4,
        rallyTroops = 3,
        hallOfOratory = 0,
        carthag = 0,
        harvestSpice = 2,
        arrakeen1p = 1,
        arrakeen2p = 1,
        interstellarShipping = 3,
        foldspaceAndInterstellarShipping = 2,
        smugglingAndInterstellarShipping = 2,
        techNegotiation = 0,
        dreadnought1p = 3,
        dreadnought2p = 3,
        researchStation = 0,
        carthag1 = 0,
        carthag2 = 0,
        carthag3 = 0,
    }
}

function HagalCard.setStrength(color, card)
    local rival = PlayBoard.getLeader(color)
    local strength = HagalCard.strengths[Helper.getID(card)]
    if strength then
        rival.resources(color, "strength", strength)
        return true
    else
        return false
    end
end

function HagalCard.activate(color, card)
    local rival = PlayBoard.getLeader(color)
    local actionName = Helper.toCamelCase("_activate", Helper.getID(card))
    if HagalCard[actionName] then
        return HagalCard[actionName](color, rival)
    else
        return false
    end
end

function HagalCard._activateConspire(color, rival)
    if HagalCard.spaceIsFree(color, "conspire") then
        HagalCard.sendRivalAgent(color, rival, "conspire")
        rival.influence(color, "emperor", 1)
        rival.troops(color, "supply", "garrison", 2)
        return true
    else
        return false
    end
end

function HagalCard._activateWealth(color, rival)
    if HagalCard.spaceIsFree(color, "wealth") then
        HagalCard.sendRivalAgent(color, rival, "wealth")
        rival.influence(color, "emperor", 1)
        return true
    else
        return false
    end
end

function HagalCard._activateHeighliner(color, rival)
    if HagalCard.spaceIsFree(color, "heighliner") then
        HagalCard.sendRivalAgent(color, rival, "heighliner")
        rival.influence(color, "spacingGuild", 1)
        rival.troops(color, "supply", "combat", 3)
        HagalCard.sendUpToTwoUnits(color, rival)
        return true
    else
        return false
    end
end

function HagalCard._activateFoldspace(color, rival)
    if HagalCard.spaceIsFree(color, "foldspace") then
        HagalCard.sendRivalAgent(color, rival, "foldspace")
        rival.influence(color, "spacingGuild", 1)
        return true
    else
        return false
    end
end

function HagalCard._activateSelectiveBreeding(color, rival)
    if HagalCard.spaceIsFree(color, "selectiveBreeding") then
        HagalCard.sendRivalAgent(color, rival, "selectiveBreeding")
        rival.influence(color, "beneGesserit", 1)
        return true
    else
        return false
    end
end

function HagalCard._activateSecrets(color, rival)
    if HagalCard.spaceIsFree(color, "secrets") then
        HagalCard.sendRivalAgent(color, rival, "secrets")
        rival.influence(color, "beneGesserit", 1)
        return true
    else
        return false
    end
end

function HagalCard._activateHardyWarriors(color, rival)
    if HagalCard.spaceIsFree(color, "hardyWarriors") then
        HagalCard.sendRivalAgent(color, rival, "hardyWarriors")
        rival.influence(color, "fremen", 1)
        rival.troops(color, "supply", "combat", 2)
        HagalCard.sendUpToTwoUnits(color, rival)
        return true
    else
        return false
    end
end

function HagalCard._activateStillsuits(color, rival)
    if HagalCard.spaceIsFree(color, "stillsuits") then
        HagalCard.sendRivalAgent(color, rival, "stillsuits")
        rival.influence(color, "fremen", 1)
        HagalCard.sendUpToTwoUnits(color, rival)
        return true
    else
        return false
    end
end

function HagalCard._activateRallyTroops(color, rival)
    if HagalCard.spaceIsFree(color, "rallyTroops") then
        HagalCard.sendRivalAgent(color, rival, "rallyTroops")
        rival.troops(color, "supply", "garrison", 4)
        return true
    else
        return false
    end
end

function HagalCard._activateHallOfOratory(color, rival)
    if HagalCard.spaceIsFree(color, "hallOfOratory") then
        HagalCard.sendRivalAgent(color, rival, "hallOfOratory")
        rival.troops(color, "supply", "garrison", 1)
        return true
    else
        return false
    end
end

function HagalCard._activateCarthag(color, rival)
    if HagalCard.spaceIsFree(color, "carthag") then
        HagalCard.sendRivalAgent(color, rival, "carthag")
        rival.troops(color, "supply", "combat", 1)
        HagalCard.sendUpToTwoUnits(color, rival)
        return true
    else
        return false
    end
end

function HagalCard._activateHarvestSpice(color, rival)
    local desertSpaces = {
        imperialBasin = 1,
        haggaBasin = 2,
        theGreatFlat = 3,
    }

    local bestDesertSpace
    local bestSpiceBonus = 0.5
    local bestTotalSpice = 0
    for desertSpace, baseSpice  in pairs(desertSpaces) do
        if HagalCard.spaceIsFree(desertSpace) then
            local spiceBonus = MainBoard.getSpiceBonus(desertSpace):get()
            local totalSpice = baseSpice + spiceBonus
            if spiceBonus > bestSpiceBonus or (spiceBonus == bestSpiceBonus and totalSpice > bestTotalSpice) then
                bestDesertSpace = desertSpace
                bestSpiceBonus = spiceBonus
                bestTotalSpice = totalSpice
            end
        end
    end

    if bestDesertSpace then
        rival.resources(color, "spice", bestTotalSpice)
        HagalCard.sendRivalAgent(color, rival, bestDesertSpace)
        MainBoard.getSpiceBonus(bestDesertSpace):set(0)
        HagalCard.sendUpToTwoUnits(color, rival)
        return true
    else
        return false
    end
end

function HagalCard._activateArrakeen1p(color, rival)
    if HagalCard.spaceIsFree(color, "arrakeen") then
        HagalCard.sendRivalAgent(color, rival, "arrakeen")
        rival.troops(color, "supply", "combat", 1)
        HagalCard.sendUpToTwoUnits(color, rival)
        rival.signetRing(color)
        return true
    else
        return false
    end
end

function HagalCard._activateArrakeen2p(color, rival)
    if HagalCard.spaceIsFree(color, "arrakeen") then
        HagalCard.sendRivalAgent(color, rival, "arrakeen")
        rival.troops(color, "supply", "combat", 1)
        HagalCard.sendUpToTwoUnits(color, rival)
        return true
    else
        return false
    end
end

function HagalCard._activateInterstellarShipping(color, rival)
    if HagalCard.spaceIsFree(color, "interstellarShipping") and InfluenceTrack.hasFriendship(color, "spacingGuild") then
        HagalCard.sendRivalAgent(color, rival, "interstellarShipping")
        rival.shipments(color, 2)
    return true
    else
        return false
    end
end

function HagalCard._activateFoldspaceAndInterstellarShipping(color, rival)
    if InfluenceTrack.hasFriendship(color, "spacingGuild") then
        if HagalCard.spaceIsFree(color, "interstellarShipping") then
            HagalCard.sendRivalAgent(color, rival, "interstellarShipping")
            rival.shipments(color, 2)
            return true
        else
            return false
        end
    else
        if HagalCard.spaceIsFree(color, "foldspace") then
            HagalCard.sendRivalAgent(color, rival, "foldspace")
            rival.influence(color, "spacingGuild", 1)
            return true
        else
            return false
        end
    end
end

function HagalCard._activateSmugglingAndInterstellarShipping(color, rival)
    if InfluenceTrack.hasFriendship(color, "spacingGuild") then
        if HagalCard.spaceIsFree(color, "interstellarShipping") then
            HagalCard.sendRivalAgent(color, rival, "interstellarShipping")
            rival.shipments(color, 2)
            return true
        else
            return false
        end
    else
        if HagalCard.spaceIsFree(color, "smuggling") then
            HagalCard.sendRivalAgent(color, rival, "smuggling")
            rival.shipments(color, 1)
            return true
        else
            return false
        end
    end
end

function HagalCard._activateTechNegotiation(color, rival)
    if HagalCard.spaceIsFree(color, "techNegotiation") then
        HagalCard.sendRivalAgent(color, rival, "techNegotiation")
        if not rival.acquireTech(color, nil, 1) then
            rival.troops(color, "supply", "negotiation", 1)
        end
        return true
    else
        return false
    end
end

function HagalCard._activateDreadnought1p(color, rival)
    if HagalCard.spaceIsFree(color, "dreadnought") and PlayBoard.getAquiredDreadnoughtCount(color) < 2 then
        HagalCard.sendRivalAgent(color, rival, "dreadnought")
        rival.dreadnought(color, "supply", "garrison", 1)
        rival.acquireTech(color, nil, 0)
        return true
    else
        return false
    end
end

function HagalCard._activateDreadnought2p(color, rival)
    if HagalCard.spaceIsFree(color, "dreadnought") and PlayBoard.getAquiredDreadnoughtCount(color) < 2 then
        HagalCard.sendRivalAgent(color, rival, "dreadnought")
        rival.dreadnought(color, "supply", "garrison", 1)
        rival.troops(color, "supply", "garrison", 2)
        return true
    else
        return false
    end
end

function HagalCard._activateResearchStation(color, rival)
    if HagalCard.spaceIsFree(color, "researchStationImmortality") then
        HagalCard.sendRivalAgent(color, rival, "researchStationImmortality")
        rival.beetle(color, 2)
        return true
    else
        return false
    end
end

function HagalCard._activateCarthag1(color, rival)
    if HagalCard.spaceIsFree(color, "carthag") then
        HagalCard.sendRivalAgent(color, rival, "carthag")
        rival.troops(color, "supply", "garrison", 1)
        rival.beetle(color, 1)
        TleilaxuRow.trash(1)
        HagalCard.sendUpToTwoUnits(color, rival)
        return true
    else
        return false
    end
end

function HagalCard._activateCarthag2(color, rival)
    if HagalCard.spaceIsFree(color, "carthag") then
        HagalCard.sendRivalAgent(color, rival, "carthag")
        rival.troops(color, "supply", "garrison", 1)
        rival.beetle(color, 1)
        HagalCard.sendUpToTwoUnits(color, rival)
        return true
    else
        return false
    end
end

function HagalCard._activateCarthag3(color, rival)
    if HagalCard.spaceIsFree(color, "carthag") then
        HagalCard.sendRivalAgent(color, rival, "carthag")
        rival.troops(color, "supply", "garrison", 1)
        rival.beetle(color, 1)
        TleilaxuRow.trash(2)
        HagalCard.sendUpToTwoUnits(color, rival)
        return true
    else
        return false
    end
end

function HagalCard.sendRivalAgent(color, rival, spaceName)
    if MainBoard.sendRivalAgent(color, spaceName) then
        if PlayBoard.useTech(color, "trainingDrones") then
            rival.troops(color, "supply", "garrison", 1)
        end
        return true
    else
        return false
    end
end

function HagalCard.sendUpToTwoUnits(color, rival)
    if Hagal.riseOfIx then
        local count = rival.dreadnought(color, "garrison", "combat", 2)
        if count < 2 then
            rival.troops(color, "garrison", "combat", 2 - count)
        end

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
    end
end

function HagalCard.spaceIsFree(color, spaceName)
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
