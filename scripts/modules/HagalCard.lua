local Module = require("utils.Module")
local Helper = require("utils.Helper")

local MainBoard = Module.lazyRequire("MainBoard")
local PlayBoard = Module.lazyRequire("PlayBoard")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")
local TleilaxuRow = Module.lazyRequire("TleilaxuRow")

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
    local strength = HagalCard.strengths[card.getDescription()]
    if strength then
        rival.resources(color, "strength", strength)
        return true
    else
        return false
    end
end

function HagalCard.activate(color, card)
    local rival = PlayBoard.getLeader(color)
    local actionName = Helper.toCamelCase("_activate", card.getDescription())
    if HagalCard[actionName] then
        return HagalCard[actionName](color, rival)
    else
        return false
    end
end

function HagalCard._activateConspire(color, rival)
    if HagalCard.spaceIsFree("conspire") then
        MainBoard.sendRivalAgent(color, "conspire")
        rival.influence(color, "emperor", 1)
        rival.troops(color, "supply", "garrison", 2)
        return true
    else
        return false
    end
end

function HagalCard._activateWealth(color, rival)
    if HagalCard.spaceIsFree("wealth") then
        MainBoard.sendRivalAgent(color, "wealth")
        rival.influence(color, "emperor", 1)
        return true
    else
        return false
    end
end

function HagalCard._activateHeighliner(color, rival)
    if HagalCard.spaceIsFree("heighliner") then
        MainBoard.sendRivalAgent(color, "heighliner")
        rival.influence(color, "spacingGuild", 1)
        rival.troops(color, "supply", "combat", 3)
        HagalCard.sendUpToTwoUnits(color, rival)
        return true
    else
        return false
    end
end

function HagalCard._activateFoldspace(color, rival)
    if HagalCard.spaceIsFree("foldspace") then
        MainBoard.sendRivalAgent(color, "foldspace")
        rival.influence(color, "spacingGuild", 1)
        return true
    else
        return false
    end
end

function HagalCard._activateSelectiveBreeding(color, rival)
    if HagalCard.spaceIsFree("selectiveBreeding") then
        MainBoard.sendRivalAgent(color, "selectiveBreeding")
        rival.influence(color, "beneGesserit", 1)
        return true
    else
        return false
    end
end

function HagalCard._activateSecrets(color, rival)
    if HagalCard.spaceIsFree("secrets") then
        MainBoard.sendRivalAgent(color, "secrets")
        rival.influence(color, "beneGesserit", 1)
        return true
    else
        return false
    end
end

function HagalCard._activateHardyWarriors(color, rival)
    if HagalCard.spaceIsFree("hardyWarriors") then
        MainBoard.sendRivalAgent(color, "hardyWarriors")
        rival.influence(color, "fremen", 1)
        rival.troops(color, "supply", "combat", 2)
        HagalCard.sendUpToTwoUnits(color, rival)
        return true
    else
        return false
    end
end

function HagalCard._activateStillsuits(color, rival)
    if HagalCard.spaceIsFree("stillsuits") then
        MainBoard.sendRivalAgent(color, "stillsuits")
        rival.influence(color, "fremen", 1)
        HagalCard.sendUpToTwoUnits(color, rival)
        return true
    else
        return false
    end
end

function HagalCard._activateRallyTroops(color, rival)
    if HagalCard.spaceIsFree("rallyTroops") then
        MainBoard.sendRivalAgent(color, "rallyTroops")
        rival.troops(color, "supply", "garrison", 4)
        return true
    else
        return false
    end
end

function HagalCard._activateHallOfOratory(color, rival)
    if HagalCard.spaceIsFree("hallOfOratory") then
        MainBoard.sendRivalAgent(color, "hallOfOratory")
        rival.troops(color, "supply", "garrison", 1)
        return true
    else
        return false
    end
end

function HagalCard._activateCarthag(color, rival)
    if HagalCard.spaceIsFree("carthag") then
        MainBoard.sendRivalAgent(color, "carthag")
        rival.troops(color, "supply", "combat", 1)
        HagalCard.sendUpToTwoUnits(color, rival)
        rival.beetle(color, 1)
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
        MainBoard.sendRivalAgent(color, bestDesertSpace)
        MainBoard.getSpiceBonus(bestDesertSpace):set(0)
        HagalCard.sendUpToTwoUnits(color, rival)
        return true
    else
        return false
    end
end

function HagalCard._activateArrakeen1p(color, rival)
    if HagalCard.spaceIsFree("arrakeen") then
        MainBoard.sendRivalAgent(color, "arrakeen")
        rival.troops(color, "supply", "combat", 1)
        HagalCard.sendUpToTwoUnits(color, rival)
        rival.signetRing(color)
        return true
    else
        return false
    end
end

function HagalCard._activateArrakeen2p(color, rival)
    if HagalCard.spaceIsFree("arrakeen") then
        MainBoard.sendRivalAgent(color, "arrakeen")
        rival.troops(color, "supply", "combat", 1)
        HagalCard.sendUpToTwoUnits(color, rival)
        return true
    else
        return false
    end
end

function HagalCard._activateInterstellarShipping(color, rival)
    if HagalCard.spaceIsFree("interstellarShipping") and InfluenceTrack.hasFriendship(color, "spacingGuild") then
        MainBoard.sendRivalAgent(color, "interstellarShipping")
        rival.shipments(color, 2)
    return true
    else
        return false
    end
end

function HagalCard._activateFoldspaceAndInterstellarShipping(color, rival)
    if InfluenceTrack.hasFriendship(color, "spacingGuild") then
        if HagalCard.spaceIsFree("interstellarShipping") then
            MainBoard.sendRivalAgent(color, "interstellarShipping")
            rival.shipments(color, 2)
            return true
        else
            return false
        end
    else
        if HagalCard.spaceIsFree("foldspace") then
            MainBoard.sendRivalAgent(color, "foldspace")
            rival.influence(color, "spacingGuild", 1)
            return true
        else
            return false
        end
    end
end

function HagalCard._activateSmugglingAndInterstellarShipping(color, rival)
    if InfluenceTrack.hasFriendship(color, "spacingGuild") then
        if HagalCard.spaceIsFree("interstellarShipping") then
            MainBoard.sendRivalAgent(color, "interstellarShipping")
            rival.shipments(color, 2)
            return true
        else
            return false
        end
    else
        if HagalCard.spaceIsFree("smuggling") then
            MainBoard.sendRivalAgent(color, "smuggling")
            rival.shipments(color, 1)
            return true
        else
            return false
        end
    end
end

function HagalCard._activateTechNegotiation(color, rival)
    if HagalCard.spaceIsFree("techNegotiation") then
        MainBoard.sendRivalAgent(color, "techNegotiation")
        if not rival.acquireTech(color, nil, 1) then
            rival.troops(color, "supply", "negotiation", 1)
        end
        return true
    else
        return false
    end
end

function HagalCard._activateDreadnought1p(color, rival)
    if HagalCard.spaceIsFree("dreadnought") and PlayBoard.getAquiredDreadnoughtCount(color) < 2 then
        MainBoard.sendRivalAgent(color, "dreadnought")
        rival.dreadnought(color, "supply", "garrison", 1)
        rival.acquireTech(color, nil, 0)
        return true
    else
        return false
    end
end

function HagalCard._activateDreadnought2p(color, rival)
    if HagalCard.spaceIsFree("dreadnought") and PlayBoard.getAquiredDreadnoughtCount(color) < 2 then
        MainBoard.sendRivalAgent(color, "dreadnought")
        rival.dreadnought(color, "supply", "garrison", 1)
        rival.troops(color, "supply", "garrison", 2)
        return true
    else
        return false
    end
end

function HagalCard._activateResearchStation(color, rival)
    if HagalCard.spaceIsFree("researchStation") then
        MainBoard.sendRivalAgent(color, "researchStation")
        rival.beetle(color, 2)
    return true
    else
        return false
    end
end

function HagalCard._activateCarthag1(color, rival)
    if HagalCard.spaceIsFree("carthag") then
        MainBoard.sendRivalAgent(color, "carthag")
        rival.troops(color, "supply", "garrison", 1)
        rival.beetle(color, 1)
        TleilaxuRow.trash(1)
        return true
    else
        return false
    end
end

function HagalCard._activateCarthag2(color, rival)
    if HagalCard.spaceIsFree("carthag") then
        MainBoard.sendRivalAgent(color, "carthag")
        rival.troops(color, "supply", "garrison", 1)
        rival.beetle(color, 1)
        return true
    else
        return false
    end
end

function HagalCard._activateCarthag3(color, rival)
    if HagalCard.spaceIsFree("carthag") then
        MainBoard.sendRivalAgent(color, "carthag")
        rival.troops(color, "supply", "garrison", 1)
        rival.beetle(color, 1)
        TleilaxuRow.trash(2)
        return true
    else
        return false
    end
end

function HagalCard.sendUpToTwoUnits(color, rival)
    local count = rival.dreadnought(color, "garrison", "combat", 2)
    if count < 2 then
        rival.troops(color, "garrison", "combat", 2 - count)
    end
end

function HagalCard.spaceIsFree(spaceName)
    return not MainBoard.hasAgentInSpace(spaceName)
        and not MainBoard.hasVoiceToken(spaceName)
end

return HagalCard
