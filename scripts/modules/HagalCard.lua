local Module = require("utils.Module")
local Helper = require("utils.Helper")

local MainBoard = Module.lazyRequire("MainBoard")
local PlayBoard = Module.lazyRequire("PlayBoard")

local HagalCard = {}

function HagalCard.activateCard(color, card)
    local rival = PlayBoard.getLeader(color)
    local actionName = Helper.toCamelCase("_activate", card.getDescription())
    log(actionName)
    if HagalCard[actionName] then
        return HagalCard[actionName](color, rival)
    else
        return false
    end
end

function HagalCard._activateChurn(color, rival)
    return false
end

function HagalCard._activateConspire(color, rival)
    if not MainBoard.hasAgentInSpace("conspire") then
        MainBoard.sendRivalAgent(color, "conspire")
        rival.influence(color, "emperor", 1)
        rival.troops(color, "supply", "garrison", 2)
        rival.resource(color, "strength", 4)
        return true
    else
        return false
    end
end

function HagalCard._activateWealth(color, rival)
    if not MainBoard.hasAgentInSpace("wealth") then
        MainBoard.sendRivalAgent(color, "wealth")
        rival.influence(color, "emperor", 1)
        rival.resource(color, "strength", 3)
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
        rival.resource(color, "strength", 6)
        return true
    else
        return false
    end
end

function HagalCard._activateFoldspace(color, rival)
    if not MainBoard.hasAgentInSpace("foldspace") then
        MainBoard.sendRivalAgent(color, "foldspace")
        rival.influence(color, "spacingGuild", 1)
        rival.resource(color, "strength", 1)
        return true
    else
        return false
    end
end

function HagalCard._activateSelectiveBreeding(color, rival)
    if not MainBoard.hasAgentInSpace("selectiveBreeding") then
        MainBoard.sendRivalAgent(color, "selectiveBreeding")
        rival.influence(color, "beneGesserit", 1)
        rival.resource(color, "strength", 2)
        return true
    else
        return false
    end
end

function HagalCard._activateSecrets(color, rival)
    if not MainBoard.hasAgentInSpace("secrets") then
        MainBoard.sendRivalAgent(color, "secrets")
        rival.influence(color, "beneGesserit", 1)
        rival.resource(color, "strength", 1)
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
        rival.resource(color, "strength", 5)
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
        rival.resource(color, "strength", 4)
        return true
    else
        return false
    end
end

function HagalCard._activateRallyTroops(color, rival)
    if not MainBoard.hasAgentInSpace("rallyTroops") then
        MainBoard.sendRivalAgent(color, "rallyTroops")
        rival.troops(color, "supply", "garrison", 4)
        rival.resource(color, "strength", 3)
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
        rival.resource(color, "strength", 2)
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
        rival.resource(color, "strength", 1)
        return true
    else
        return false
    end
end

function HagalCard._activateReshuffle(color, rival)
    return false
end

function HagalCard._activateArrakeen2p(color, rival)
    if not MainBoard.hasAgentInSpace("arrakeen") then
        MainBoard.sendRivalAgent(color, "arrakeen")
        rival.troops(color, "supply", "battleground", 1)
        rival.troops(color, "garrison", "battleground", 2)
        rival.resource(color, "strength", 1)
        return true
    else
        return false
    end
end

--[[
ix = {
    interstellarShipping = {turn = {shipping(spacingGuildFriendship(2))}, combat = {sword(3)}}, -- TODO
    foldspaceAndInterstellarShipping = {turn = {influence('spacingGuild', 1), shipping(spacingGuildFriendship(2))}, combat = {sword(2)}},
    smugglingAndInterstellarShipping = {turn = {shipping(1), shipping(spacingGuildFriendship(1))}, combat = {sword(2)}},
    techNegotiation = {turn = {tech(-1, 1), negotiator(1)}, combat = {}}, -- TODO
    dreadnought1p = {turn = {dreadnought(1), tech(1)}, combat = {sword(3)}}, -- TODO
    dreadnought2p = {turn = {dreadnought(1), troop(1)}, combat = {sword(3)}}, -- TODO
},
immortality = {
    researchStation = {turn = {beetle(2)}, combat = {}},
    carthag1 = {turn = {troop(1), beetle(1), trashTleilax(left)}, combat = {}},
    carthag2 = {turn = {troop(1), beetle(1)}},
    carthag3 = {turn = {troop(1), beetle(1), trashTleilax(right)}, combat = {}},
}
]]--

return HagalCard
