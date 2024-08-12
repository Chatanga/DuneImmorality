local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")

local MainBoard = Module.lazyRequire("MainBoard")
local PlayBoard = Module.lazyRequire("PlayBoard")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")
local TleilaxuRow = Module.lazyRequire("TleilaxuRow")
local Action = Module.lazyRequire("Action")
local Types = Module.lazyRequire("Types")
local TechMarket = Module.lazyRequire("TechMarket")

local HagalCard = {
    cards = {
        conspire = { strength = 4 },
        wealth = { strength = 3 },
        heighliner = { combat = true, strength = 6 },
        foldspace = { strength = 1 },
        selectiveBreeding = { strength = 2 },
        secrets = { strength = 1 },
        hardyWarriors = { combat = true, strength = 5 },
        stillsuits = { combat = true, strength = 4 },
        rallyTroops = { strength = 3 },
        hallOfOratory = { strength = 0 },
        carthag = { combat = true, strength = 0 },
        harvestSpice = { combat = true, strength = 2 },
        arrakeen1p = { combat = true, strength = 1 },
        arrakeen2p = { combat = true, strength = 1 },
        interstellarShipping = { strength = 3 },
        foldspaceAndInterstellarShipping = { strength = 2 },
        smugglingAndInterstellarShipping = { strength = 2 },
        techNegotiation = { strength = 0 },
        dreadnought1p = { strength = 3 },
        dreadnought2p = { strength = 3 },
        researchStation = { combat = true, strength = 0 },
        carthag1 = { combat = true, strength = 0 },
        carthag2 = { combat = true, strength = 0 },
        carthag3 = { combat = true, strength = 0 },
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
    Action.setContext("hagalCard",  cardName)
    HagalCard.riseOfIx = riseOfIx
    local rival = PlayBoard.getLeader(color)
    local actionName = Helper.toCamelCase("_activate", cardName)
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
        HagalCard.sendRivalAgent(color, rival, bestDesertSpace)
        rival.resources(color, "spice", bestTotalSpice)
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
        rival.signetRing(color)
        HagalCard.sendUpToTwoUnits(color, rival)
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
        TechMarket.registerAcquireTechOption(color, "techNegotiationTechBuyOption", "spice", 1)
        if not rival.acquireTech(color, nil) then
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
        TechMarket.registerAcquireTechOption(color, "dreadnoughtTechBuyOption", "spice", 0)
        rival.acquireTech(color, nil)
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
        HagalCard.sendUpToTwoUnits(color, rival)
        return true
    else
        return false
    end
end

function HagalCard._activateCarthag1(color, rival)
    if HagalCard.spaceIsFree(color, "carthag") then
        HagalCard.sendRivalAgent(color, rival, "carthag")
        rival.troops(color, "supply", "combat", 1)
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
        rival.troops(color, "supply", "combat", 1)
        rival.beetle(color, 1)
        TleilaxuRow.trash(2)
        HagalCard.sendUpToTwoUnits(color, rival)
        return true
    else
        return false
    end
end

function HagalCard._activateCarthag3(color, rival)
    if HagalCard.spaceIsFree(color, "carthag") then
        HagalCard.sendRivalAgent(color, rival, "carthag")
        rival.troops(color, "supply", "combat", 1)
        rival.beetle(color, 1)
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
    if HagalCard.riseOfIx then
        local count = rival.dreadnought(color, "garrison", "combat", 2)
        if count < 2 then
            rival.troops(color, "garrison", "combat", 2 - count)
        end

        if PlayBoard.hasTech(color, "flagship") then
            local supply = PlayBoard.getSupplyPark(color)
            local leader = PlayBoard.getLeader(color)

            if PlayBoard.hasTech(color, "flagship") and #Park.getObjects(supply) >= 3 and leader.resources(color, "solari", -4) then
                rival.troops(color, "supply", "combat", 3)
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

function HagalCard.isCombatCard(card)
    local cardData = card and HagalCard.cards[card]
    return cardData and cardData.combat
end

return HagalCard
