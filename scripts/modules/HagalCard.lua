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
local Hagal = Module.lazyRequire("Hagal")
local TurnControl = Module.lazyRequire("TurnControl")
local Combat = Module.lazyRequire("Combat")
local SardaukarCommander = Module.lazyRequire("SardaukarCommander")
local TechCard = Module.lazyRequire("TechCard")

local HagalCard = {
    cardStrengths = {
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
        arrakeen1p = 1,
        arrakeen2p = 1,
        harvestSpice = 2,
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
        acquireTech = 1,
        tuekSietch = 2,
    },
    combatCards = {
        "heighliner",
        "hardyWarriors",
        "stillsuits",
        "carthag",
        "harvestSpice",
        "arrakeen1p",
        "arrakeen2p",
        "researchStation",
        "carthag1",
        "carthag2",
        "carthag3",
    }
}

function HagalCard.setStrength(color, card)
    assert(Types.isPlayerColor(color))
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
    assert(Types.isPlayerColor(color))
    assert(card)
    local cardName = Helper.getID(card)
    Action.setContext("hagalCard",  cardName)
    HagalCard.riseOfIx = riseOfIx
    local rival = PlayBoard.getLeader(color)
    local actionName = Helper.toCamelCase("_activate", cardName)
    assert(HagalCard[actionName], actionName)
    return HagalCard[actionName](color, rival, riseOfIx)
end

function HagalCard.flushTurnActions(color)
    HagalCard.acquiredTroopCount = HagalCard.acquiredTroopCount or 0
    local rival = PlayBoard.getLeader(color)
    assert(rival, color)

    -- Rapid Dropships
    HagalCard.inCombat = HagalCard.inCombat or PlayBoard.useTech(color, "rapidDropships")

    if HagalCard.inCombat then
        local deploymentLimit = Hagal.getExpertDeploymentLimit(color)

        local garrisonedTroopCount = #Park.getObjects(Combat.getGarrisonPark(color)) -- Sardaukars included.
        Helper.dump("garrisonedTroopCount:", garrisonedTroopCount)
        local inSupplyTroopCount = #Park.getObjects(PlayBoard.getSupplyPark(color))

        local fromGarrison = math.min(2, garrisonedTroopCount)
        local fromSupply = HagalCard.acquiredTroopCount

        if HagalCard.riseOfIx then
            -- Dreadnoughts are free and implicit.
            local count = rival.dreadnought(color, "garrison", "combat", 2)
            fromGarrison = math.max(0, fromGarrison - count)
        end

        -- Flagship tech.
        if  PlayBoard.hasTech(color, "flagship") and
            deploymentLimit - fromGarrison - fromSupply > 0 and
            inSupplyTroopCount - fromSupply >= 3 and
            rival.resources(color, "solari", -4)
        then
            fromSupply = fromSupply + 3
        end

        local realFromSupply = math.min(fromSupply, deploymentLimit)
        deploymentLimit = deploymentLimit - realFromSupply
        if realFromSupply > 0 then
            rival.troops(color, "supply", "combat", realFromSupply)
            Action.getTroopPark(color, "combat")
        end
        if fromSupply > realFromSupply then
            rival.troops(color, "supply", "garrison", fromSupply - realFromSupply)
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

    -- Immediate pseudo reveal after the final agent has been sent.
    local playBoard = PlayBoard.getPlayBoard(color)
    assert(playBoard, color)
    if not playBoard:stillHavePlayableAgents() then
        local techCardContributions = TechCard.evaluatePostReveal(color, { persuasion = 6 })
        Helper.dump("techCardContributions:", techCardContributions)
    end
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

-- Emperor spaces

function HagalCard._activateConspire(color, rival)
    if HagalCard._spaceIsFree(color, "conspire") then
        HagalCard._sendRivalAgent(color, rival, "conspire")
        rival.influence(color, "emperor", 1)
        HagalCard.acquireTroops(color, 2, false)
        HagalCard._tryRecruitingSardaukarCommander(color, rival, "conspire")
        return true
    else
        return false
    end
end

function HagalCard._activateWealth(color, rival)
    if HagalCard._spaceIsFree(color, "wealth") then
        HagalCard._sendRivalAgent(color, rival, "wealth")
        rival.influence(color, "emperor", 1)
        HagalCard._tryRecruitingSardaukarCommander(color, rival, "wealth")
        return true
    else
        return false
    end
end

-- Spacing Guild spaces

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

function HagalCard._activateFoldspace(color, rival)
    if HagalCard._spaceIsFree(color, "foldspace") then
        HagalCard._sendRivalAgent(color, rival, "foldspace")
        rival.influence(color, "spacingGuild", 1)
        HagalCard._tryRecruitingSardaukarCommander(color, rival, "foldspace")
        return true
    else
        return false
    end
end

-- Bene Gesserit spaces

function HagalCard._activateSelectiveBreeding(color, rival)
    if HagalCard._spaceIsFree(color, "selectiveBreeding") then
        HagalCard._sendRivalAgent(color, rival, "selectiveBreeding")
        rival.influence(color, "beneGesserit", 1)
        return true
    else
        return false
    end
end

function HagalCard._activateSecrets(color, rival)
    if HagalCard._spaceIsFree(color, "secrets") then
        HagalCard._sendRivalAgent(color, rival, "secrets")
        rival.influence(color, "beneGesserit", 1)
        return true
    else
        return false
    end
end

-- Fremen spaces

function HagalCard._activateHardyWarriors(color, rival)
    if HagalCard._spaceIsFree(color, "hardyWarriors") then
        HagalCard._sendRivalAgent(color, rival, "hardyWarriors")
        rival.influence(color, "fremen", 1)
        HagalCard.acquireTroops(color, 2, true)
        return true
    else
        return false
    end
end

function HagalCard._activateStillsuits(color, rival)
    if HagalCard._spaceIsFree(color, "stillsuits") then
        HagalCard._sendRivalAgent(color, rival, "stillsuits")
        rival.influence(color, "fremen", 1)
        HagalCard.acquireTroops(color, 0, true)
        return true
    else
        return false
    end
end

-- Landsraad spaces

function HagalCard._activateRallyTroops(color, rival)
    if HagalCard._spaceIsFree(color, "rallyTroops") then
        HagalCard._sendRivalAgent(color, rival, "rallyTroops")
        HagalCard.acquireTroops(color, 4, false)
        HagalCard._tryRecruitingSardaukarCommander(color, rival, "rallyTroops")
        return true
    else
        return false
    end
end

function HagalCard._activateHallOfOratory(color, rival)
    if HagalCard._spaceIsFree(color, "hallOfOratory") then
        HagalCard._sendRivalAgent(color, rival, "hallOfOratory")
        HagalCard.acquireTroops(color, 1, false)
        HagalCard._tryRecruitingSardaukarCommander(color, rival, "hallOfOratory")
        return true
    else
        return false
    end
end

-- CHOAM spaces

-- City spaces

function HagalCard._activateCarthag(color, rival)
    if HagalCard._spaceIsFree(color, "carthag") then
        HagalCard._sendRivalAgent(color, rival, "carthag")
        HagalCard.acquireTroops(color, 1, true)
        return true
    else
        return false
    end
end

function HagalCard._activateArrakeen1p(color, rival)
    if HagalCard._spaceIsFree(color, "arrakeen") then
        HagalCard._sendRivalAgent(color, rival, "arrakeen")
        HagalCard.acquireTroops(color, 1, true)
        rival.signetRing(color)
        return true
    else
        return false
    end
end

function HagalCard._activateArrakeen2p(color, rival)
    if HagalCard._spaceIsFree(color, "arrakeen") then
        HagalCard._sendRivalAgent(color, rival, "arrakeen")
        HagalCard.acquireTroops(color, 1, true)
        return true
    else
        return false
    end
end

-- Desert spaces

function HagalCard._activateHarvestSpice(color, rival)
    local best = HagalCard.findHarvestableSpace(true)

    if best.desertSpace then
        HagalCard._sendRivalAgent(color, rival, best.desertSpace)
        rival.resources(color, "spice", best.totalSpice)
        MainBoard.getSpiceBonus(best.desertSpace):set(0)
        HagalCard.acquireTroops(color, 0, true)
        return true
    else
        return false
    end
end

function HagalCard.findHarvestableSpace(ignoreIfNotFree)
    local desertSpaces = {
        imperialBasin = 1,
        haggaBasin = 2,
        theGreatFlat = 3,
    }

    local best = {
        desertSpace = nil,
        spiceBonus = 0.5,
        totalSpice = 0,
    }

    for desertSpace, baseSpice in pairs(desertSpaces) do
        if not ignoreIfNotFree or HagalCard._spaceIsFree(desertSpace) then
            local spiceBonus = MainBoard.getSpiceBonus(desertSpace):get()
            local totalSpice = baseSpice + spiceBonus
            if spiceBonus > best.spiceBonus or (spiceBonus == best.spiceBonus and totalSpice > best.totalSpice) then
                best.desertSpace = desertSpace
                best.spiceBonus = spiceBonus
                best.totalSpice = totalSpice
            end
        end
    end

    return best
end

-- Ix spaces (CHOAM)

function HagalCard._activateInterstellarShipping(color, rival)
    if HagalCard._spaceIsFree(color, "interstellarShipping") and InfluenceTrack.hasFriendship(color, "spacingGuild") then
        HagalCard._sendRivalAgent(color, rival, "interstellarShipping")
        rival.shipments(color, 2)
        return true
    else
        return false
    end
end

function HagalCard._activateFoldspaceAndInterstellarShipping(color, rival)
    if InfluenceTrack.hasFriendship(color, "spacingGuild") then
        if HagalCard._spaceIsFree(color, "interstellarShipping") then
            HagalCard._sendRivalAgent(color, rival, "interstellarShipping")
            rival.shipments(color, 2)
            return true
        else
            return false
        end
    else
        if HagalCard._spaceIsFree(color, "foldspace") then
            HagalCard._sendRivalAgent(color, rival, "foldspace")
            rival.influence(color, "spacingGuild", 1)
            HagalCard._tryRecruitingSardaukarCommander(color, rival, "foldspace")
            return true
        else
            return false
        end
    end
end

function HagalCard._activateSmugglingAndInterstellarShipping(color, rival)
    if InfluenceTrack.hasFriendship(color, "spacingGuild") then
        if HagalCard._spaceIsFree(color, "interstellarShipping") then
            HagalCard._sendRivalAgent(color, rival, "interstellarShipping")
            rival.shipments(color, 2)
            return true
        else
            return false
        end
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

-- Ix spaces

function HagalCard._activateTechNegotiation(color, rival)
    if HagalCard._spaceIsFree(color, "techNegotiation") then
        HagalCard._sendRivalAgent(color, rival, "techNegotiation")
        TechMarket.registerAcquireTechOption(color, "techNegotiationTechBuyOption", "spice", 1)
        if not rival.acquireTech(color, nil, 1) then
            rival.troops(color, "supply", "negotiation", 1)
        end
        HagalCard._tryRecruitingSardaukarCommander(color, rival, "techNegotiation")
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
        HagalCard._tryRecruitingSardaukarCommander(color, rival, "dreadnought")
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
        HagalCard._tryRecruitingSardaukarCommander(color, rival, "dreadnought")
        return true
    else
        return false
    end
end

-- Immortality changes

function HagalCard._activateResearchStation(color, rival)
    if HagalCard._spaceIsFree(color, "researchStation") then
        HagalCard._sendRivalAgent(color, rival, "researchStation")
        HagalCard.acquireTroops(color, 0, true)
        rival.beetle(color, 2)
        return true
    else
        return false
    end
end

function HagalCard._activateCarthag1(color, rival)
    if HagalCard._spaceIsFree(color, "carthag") then
        HagalCard._sendRivalAgent(color, rival, "carthag")
        HagalCard.acquireTroops(color, 1, true)
        rival.beetle(color, 1)
        TleilaxuRow.trash(1)
        return true
    else
        return false
    end
end

function HagalCard._activateCarthag2(color, rival)
    if HagalCard._spaceIsFree(color, "carthag") then
        HagalCard._sendRivalAgent(color, rival, "carthag")
        HagalCard.acquireTroops(color, 1, true)
        rival.beetle(color, 1)
        TleilaxuRow.trash(2)
        return true
    else
        return false
    end
end

function HagalCard._activateCarthag3(color, rival)
    if HagalCard._spaceIsFree(color, "carthag") then
        HagalCard._sendRivalAgent(color, rival, "carthag")
        HagalCard.acquireTroops(color, 1, true)
        rival.beetle(color, 1)
        return true
    else
        return false
    end
end

-- Bloodlines changes

function HagalCard._activateAcquireTech(color, rival)
    if PlayBoard.hasSwordmaster(color) then
        TechMarket.registerAcquireTechOption(color, "activateAcquireTechBuyOption", "spice", 1)
        rival.acquireTech(color, nil, 1)
    end
    return false
end

function HagalCard._activateTuekSietch(color, rival)
    local spiceBonusResource = MainBoard.getSpiceBonus("tuekSietch")
    if spiceBonusResource then
        local spiceBonus = spiceBonusResource:get()
        if HagalCard._spaceIsFree(color, "tuekSietch") and spiceBonus > 0 then
            HagalCard._sendRivalAgent(color, rival, "tuekSietch")
            spiceBonusResource:set(0)
            rival.resources(color, "spice", 1 + spiceBonus)
            return true
        else
            return false
        end
    else
        Helper.dump("Thit Hagal card should have been automatically removed during the setup!")
        return false
    end
end

function HagalCard._sendRivalAgent(color, rival, spaceName)
    if MainBoard.sendRivalAgent(color, spaceName) then
        if PlayBoard.useTech(color, "trainingDrones") then
            HagalCard.acquireTroops(color, 1)
        elseif PlayBoard.useTech(color, "spyDrones") then
            rival.resources(color, "solari", 1)
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

-- This simple test doesn't work in Uprising where the same card could lead to different places.
-- Maybe we should go for the more general approach?
function HagalCard.unused_isCombatCard(card)
    return Helper.isElementOf(card, HagalCard.combatCards)
end

function HagalCard._tryRecruitingSardaukarCommander(color, rival, spaceName)
    Helper.dumpFunction("HagalCard._tryRecruitingSardaukarCommander", color, rival.name, spaceName)
    if PlayBoard.hasSwordmaster(color) and SardaukarCommander.isAvailable(spaceName) then
        if Hagal.getRivalCount() == 1 then
            SardaukarCommander.discardSardaukarCommander(color, spaceName)
            return true
        elseif rival.resources(color, "solari", PlayBoard.hasTech(color, "sardaukarHighCommand") and -1 or -2) then
            Action.recruitSardaukarCommander(color, spaceName)
            return true
        end
    end
    return false
end

return HagalCard
