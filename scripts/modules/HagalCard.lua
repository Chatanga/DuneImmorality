local Module = require("utils.Module")
local Helper = require("utils.Helper")

local MainBoard = Module.lazyRequire("MainBoard")
local PlayBoard = Module.lazyRequire("PlayBoard")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")
local CommercialTrack = Module.lazyRequire("CommercialTrack")

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
        rival.resource(color, "strength", strength)
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
    if not MainBoard.hasAgentInSpace("conspire") then
        MainBoard.sendRivalAgent(color, "conspire")
        rival.influence(color, "emperor", 1)
        rival.troops(color, "supply", "garrison", 2)
        return true
    else
        return false
    end
end

function HagalCard._activateWealth(color, rival)
    if not MainBoard.hasAgentInSpace("wealth") then
        MainBoard.sendRivalAgent(color, "wealth")
        rival.influence(color, "emperor", 1)
        return true
    else
        return false
    end
end

function HagalCard._activateHeighliner(color, rival)
    if not MainBoard.hasAgentInSpace("heighliner") then
        MainBoard.sendRivalAgent(color, "heighliner")
        rival.influence(color, "spacingGuild", 1)
        rival.troops(color, "supply", "battleground", 3)
        rival.troops(color, "garrison", "battleground", 2)
        return true
    else
        return false
    end
end

function HagalCard._activateFoldspace(color, rival)
    if not MainBoard.hasAgentInSpace("foldspace") then
        MainBoard.sendRivalAgent(color, "foldspace")
        rival.influence(color, "spacingGuild", 1)
        return true
    else
        return false
    end
end

function HagalCard._activateSelectiveBreeding(color, rival)
    if not MainBoard.hasAgentInSpace("selectiveBreeding") then
        MainBoard.sendRivalAgent(color, "selectiveBreeding")
        rival.influence(color, "beneGesserit", 1)
        return true
    else
        return false
    end
end

function HagalCard._activateSecrets(color, rival)
    if not MainBoard.hasAgentInSpace("secrets") then
        MainBoard.sendRivalAgent(color, "secrets")
        rival.influence(color, "beneGesserit", 1)
        return true
    else
        return false
    end
end

function HagalCard._activateHardyWarriors(color, rival)
    if not MainBoard.hasAgentInSpace("hardyWarriors") then
        MainBoard.sendRivalAgent(color, "hardyWarriors")
        rival.influence(color, "fremen", 1)
        rival.troops(color, "supply", "battleground", 2)
        rival.troops(color, "garrison", "battleground", 2)
        return true
    else
        return false
    end
end

function HagalCard._activateStillsuits(color, rival)
    if not MainBoard.hasAgentInSpace("stillsuits") then
        MainBoard.sendRivalAgent(color, "stillsuits")
        rival.influence(color, "fremen", 1)
        rival.troops(color, "garrison", "battleground", 2)
        return true
    else
        return false
    end
end

function HagalCard._activateRallyTroops(color, rival)
    if not MainBoard.hasAgentInSpace("rallyTroops") then
        MainBoard.sendRivalAgent(color, "rallyTroops")
        rival.troops(color, "supply", "garrison", 4)
        return true
    else
        return false
    end
end

function HagalCard._activateHallOfOratory(color, rival)
    if not MainBoard.hasAgentInSpace("hallOfOratory") then
        MainBoard.sendRivalAgent(color, "hallOfOratory")
        rival.troops(color, "supply", "garrison", 1)
        return true
    else
        return false
    end
end

function HagalCard._activateCarthag(color, rival)
    if not MainBoard.hasAgentInSpace("carthag") then
        MainBoard.sendRivalAgent(color, "carthag")
        rival.troops(color, "supply", "battleground", 1)
        rival.troops(color, "garrison", "battleground", 2)
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
    local bestSpiceBonus = 0
    local bestTotalSpice = 0
    for desertSpace, baseSpice  in pairs(desertSpaces) do
        if not MainBoard.hasAgentInSpace(desertSpace) then
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
        MainBoard.sendRivalAgent(color, bestDesertSpace)
        MainBoard.getSpiceBonus(bestDesertSpace):set(0)
        rival.troops(color, "garrison", "battleground", 2)
        return true
    else
        return false
    end
end

function HagalCard._activateArrakeen1p(color, rival)
    if not MainBoard.hasAgentInSpace("arrakeen") then
        MainBoard.sendRivalAgent(color, "arrakeen")
        rival.troops(color, "supply", "battleground", 1)
        rival.troops(color, "garrison", "battleground", 2)
        rival.signetRing(color)
        return true
    else
        return false
    end
end

function HagalCard._activateArrakeen2p(color, rival)
    if not MainBoard.hasAgentInSpace("arrakeen") then
        MainBoard.sendRivalAgent(color, "arrakeen")
        rival.troops(color, "supply", "battleground", 1)
        rival.troops(color, "garrison", "battleground", 2)
        return true
    else
        return false
    end
end

function HagalCard._activateInterstellarShipping(color, rival)
    if not MainBoard.hasAgentInSpace("interstellarShipping") and InfluenceTrack.hasFriendship(color, "spacingGuild") then
        MainBoard.sendRivalAgent(color, "interstellarShipping")
        HagalCard._moveFreighter(color, rival)
        HagalCard._moveFreighter(color, rival)
    return true
    else
        return false
    end
end

function HagalCard._activateFoldspaceAndInterstellarShipping(color, rival)
    if InfluenceTrack.hasFriendship(color, "spacingGuild") then
        if not MainBoard.hasAgentInSpace("interstellarShipping") then
            MainBoard.sendRivalAgent(color, "interstellarShipping")
            HagalCard._moveFreighter(color, rival)
            HagalCard._moveFreighter(color, rival)
            return true
        else
            return false
        end
    else
        if not MainBoard.hasAgentInSpace("foldspace") then
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
        if not MainBoard.hasAgentInSpace("interstellarShipping") then
            MainBoard.sendRivalAgent(color, "interstellarShipping")
            HagalCard._moveFreighter(color, rival)
            HagalCard._moveFreighter(color, rival)
            return true
        else
            return false
        end
    else
        if not MainBoard.hasAgentInSpace("smuggling") then
            MainBoard.sendRivalAgent(color, "smuggling")
            HagalCard._moveFreighter(color, rival)
            return true
        else
            return false
        end
    end
end

function HagalCard._moveFreighter(color, rival)
    local level = CommercialTrack.getFreighterLevel(color)
    if level < 2 then
        rival.advanceFreighter(color, 1)
    else
        rival.recallFreighter(color)
        rival.influence(HagalCard._selectBestFaction(color), 1)
        if PlayBoard.hasTech(color, "troopTransports") then
            rival.troops(color, "supply", "battleground", 3)
        else
            rival.troops(color, "supply", "garrison", 2)
        end
        rival.resource(color, "solari", 5)
    end
end

function HagalCard._selectBestFaction(color)
    local factions = { "emperor", "spacingGuild", "beneGesserit", "fremen" }
    Helper.shuffle(factions)
    table.sort(factions, function (f1, f2)
        local i1 = InfluenceTrack.getInfluence(f1, color)
        local i2 = InfluenceTrack.getInfluence(f2, color)
        return i1 > i2
    end)
    return factions[1]
end

function HagalCard._activateTechNegotiation(color, rival)
    if not MainBoard.hasAgentInSpace("techNegotiation") then
        MainBoard.sendRivalAgent(color, "techNegotiation")
        if not HagalCard._acquireTech(1) then
            rival.troops(color, "supply", "negotiation", 1)
        end
        return true
    else
        return false
    end
end

function HagalCard._activateDreadnought1p(color, rival)
    if not MainBoard.hasAgentInSpace("dreadnought") and PlayBoard.getAquiredDreadnoughtCount(color) < 2 then
        MainBoard.sendRivalAgent(color, "dreadnought")
        rival.dreadnought(color, "supply", "garrison", 1)
        HagalCard._acquireTech(0)
        return true
    else
        return false
    end
end

function HagalCard._acquireTech(discount)
    -- TODO
    return false
end

function HagalCard._activateDreadnought2p(color, rival)
    if not MainBoard.hasAgentInSpace("dreadnought") and PlayBoard.getAquiredDreadnoughtCount(color) < 2 then
        MainBoard.sendRivalAgent(color, "dreadnought")
        rival.dreadnought(color, "supply", "garrison", 1)
        rival.troops(color, "supply", "garrison", 2)
        return true
    else
        return false
    end
end

function HagalCard._activateResearchStation(color, rival)
    if not MainBoard.hasAgentInSpace("researchStation") then
        MainBoard.sendRivalAgent(color, "researchStation")
        -- = {turn = {beetle(2)}, combat = {}},
    return true
    else
        return false
    end
end

function HagalCard._activateCarthag1(color, rival)
    if not MainBoard.hasAgentInSpace("carthag") then
        MainBoard.sendRivalAgent(color, "carthag")
        -- = {turn = {troop(1), beetle(1), trashTleilax(left)}, combat = {}},
        return true
    else
        return false
    end
end

function HagalCard._activateCarthag2(color, rival)
    if not MainBoard.hasAgentInSpace("carthag") then
        MainBoard.sendRivalAgent(color, "carthag")
        -- = {turn = {troop(1), beetle(1)}},
        return true
    else
        return false
    end
end

function HagalCard._activateCarthag3(color, rival)
    if not MainBoard.hasAgentInSpace("carthag") then
        MainBoard.sendRivalAgent(color, "carthag")
        -- = {turn = {troop(1), beetle(1), trashTleilax(right)}, combat = {}},
        return true
    else
        return false
    end
end


return HagalCard
