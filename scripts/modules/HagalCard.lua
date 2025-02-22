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
        acquireTech = 1,
        tuekSietch = 2,
    }
}

---@param color PlayerColor
---@param card Card
---@return boolean
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

---@param color PlayerColor
---@param card Card
---@param riseOfIx boolean
---@param immortality boolean
---@return boolean
function HagalCard.activate(color, card, riseOfIx, immortality)
    assert(Types.isPlayerColor(color))
    assert(card)
    local cardName = Helper.getID(card)
    Action.setContext("hagalCard",  cardName)
    HagalCard.riseOfIx = riseOfIx
    HagalCard.immortality = immortality
    local rival = PlayBoard.getLeader(color)
    local actionName = Helper.toCamelCase("_activate", cardName)
    assert(HagalCard[actionName], actionName)
    return HagalCard[actionName](color, rival, riseOfIx)
end

---@param color PlayerColor
function HagalCard.flushTurnActions(color)
    HagalCard.acquiredTroopCount = HagalCard.acquiredTroopCount or 0
    local rival = PlayBoard.getLeader(color)
    assert(rival, color)

    -- Rapid Dropships
    HagalCard.inCombat = HagalCard.inCombat or PlayBoard.useTech(color, "rapidDropships")

    if HagalCard.inCombat then
        local deploymentLimit = Hagal.getExpertDeploymentLimit(color)

        local garrisonedTroopCount = #Park.getObjects(Combat.getGarrisonPark(color)) -- Sardaukars included.
        --Helper.dump("garrisonedTroopCount:", garrisonedTroopCount)
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
        --Helper.dump("techCardContributions:", techCardContributions)
    end
end

---@param color PlayerColor
---@param n integer
---@param inCombat? boolean
function HagalCard.acquireTroops(color, n, inCombat)
    if TurnControl.getCurrentPhase() == "playerTurns" then
        HagalCard.inCombat = HagalCard.inCombat or inCombat
        HagalCard.acquiredTroopCount = (HagalCard.acquiredTroopCount or 0) + n
    else
        local rival = PlayBoard.getLeader(color)
        rival.troops(color, "supply", "garrison", n)
    end
end

-- Spy cards

---@param color PlayerColor
---@param rival Rival
---@param riseOfIx boolean
---@return boolean
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

---@param color PlayerColor
---@param rival Rival
---@param riseOfIx boolean
---@return boolean
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

---@param color PlayerColor
---@param rival Rival
---@param riseOfIx boolean
---@return boolean
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

-- Emperor spaces

---@param color PlayerColor
---@param rival Rival
---@return boolean
function HagalCard._activateSardaukar(color, rival)
    if HagalCard._spaceIsFree(color, "sardaukar") then
        HagalCard._sendRivalAgent(color, rival, "sardaukar")
        rival.influence(color, "emperor", 1)
        HagalCard.acquireTroops(color, 2)
        HagalCard._tryRecruitingSardaukarCommander(color, rival, "sardaukar")
        return true
    else
        return false
    end
end

---@param color PlayerColor
---@param rival Rival
---@return boolean
function HagalCard._activateDutifulService(color, rival)
    if HagalCard._spaceIsFree(color, "dutifulService") and Hagal.isSmartPolitics(color, "emperor") then
        HagalCard._sendRivalAgent(color, rival, "dutifulService")
        rival.influence(color, "emperor", 1)
        HagalCard._tryRecruitingSardaukarCommander(color, rival, "dutifulService")
        return true
    else
        return false
    end
end

-- Spacing Guild spaces

---@param color PlayerColor
---@param rival Rival
---@return boolean
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

---@param color PlayerColor
---@param rival Rival
---@return boolean
function HagalCard._activateDeliverSuppliesAndHeighliner(color, rival)
    if Combat.getCurrentConflictLevel() < 3 then
        if HagalCard._spaceIsFree(color, "deliverSupplies") and Hagal.isSmartPolitics(color, "spacingGuild") then
            HagalCard._sendRivalAgent(color, rival, "deliverSupplies")
            rival.influence(color, "spacingGuild", 1)
            HagalCard._tryRecruitingSardaukarCommander(color, rival, "deliverSupplies")
            return true
        else
            return false
        end
    else
        return HagalCard._activateHeighliner(color, rival)
    end
end

-- Bene Gesserit spaces

---@param color PlayerColor
---@param rival Rival
---@return boolean
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

---@param color PlayerColor
---@param rival Rival
---@return boolean
function HagalCard._activateSecrets(color, rival)
    if HagalCard._spaceIsFree(color, "secrets") and Hagal.isSmartPolitics(color, "beneGesserit") then
        HagalCard._sendRivalAgent(color, rival, "secrets")
        rival.influence(color, "beneGesserit", 1)
        -- Rivals weren't able to steal intrigues in the base game.
        for _, otherColor in ipairs(PlayBoard.getActivePlayBoardColors()) do
            if otherColor ~= color then
                local limit = PlayBoard.hasTech(otherColor, "geneLockedVault") and 4 or 3
                if #PlayBoard.getIntrigues(otherColor) > limit then
                    rival.stealIntrigues(color, otherColor, 1)
                end
            end
        end
        return true
    else
        return false
    end
end

-- Fremen spaces

---@param color PlayerColor
---@param rival Rival
---@return boolean
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

---@param color PlayerColor
---@param rival Rival
---@return boolean
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

-- Landsraad spaces

---@param color PlayerColor
---@param rival Rival
---@return boolean
function HagalCard._activateAssemblyHall(color, rival)
    if HagalCard._spaceIsFree(color, "assemblyHall") then
        HagalCard._sendRivalAgent(color, rival, "assemblyHall")
        rival.drawIntrigues(color, 1)
        if InfluenceTrack.hasFriendship(color, "emperor") then
            rival.influence(color, 1, 1)
        end
        HagalCard._tryRecruitingSardaukarCommander(color, rival, "assemblyHall")
        return true
    else
        return false
    end
end

---@param color PlayerColor
---@param rival Rival
---@return boolean
function HagalCard._activateGatherSupport1(color, rival)
    if HagalCard._spaceIsFree(color, "gatherSupport") then
        HagalCard._sendRivalAgent(color, rival, "gatherSupport")
        HagalCard.acquireTroops(color, 1)
        HagalCard._tryRecruitingSardaukarCommander(color, rival, "gatherSupport")
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
        HagalCard._tryRecruitingSardaukarCommander(color, rival, "gatherSupport")
        return true
    else
        return false
    end
end

-- CHOAM spaces

---@param color PlayerColor
---@param rival Rival
---@return boolean
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

---@param color PlayerColor
---@param rival Rival
---@return boolean
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

-- City spaces

---@param color PlayerColor
---@param rival Rival
---@return boolean
function HagalCard._activateResearchStation(color, rival)
    if HagalCard._spaceIsFree(color, "researchStation") then
        HagalCard._sendRivalAgent(color, rival, "researchStation")
        if HagalCard.immortality then
            HagalCard.acquireTroops(color, 0, true)
            rival.beetle(color, 2)
        else
            HagalCard.acquireTroops(color, 2, true)
        end
        return true
    else
        return false
    end
end

---@param color PlayerColor
---@param rival Rival
---@return boolean
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

---@param color PlayerColor
---@param rival Rival
---@return boolean
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

-- Desert spaces

---@param color PlayerColor
---@param rival Rival
---@return boolean
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

-- Desert spaces

function HagalCard._activateHaggaBasinAndImperialBasin(color, rival)
    local best =  HagalCard.findHarvestableSpace(color)

    if best.desertSpace then
        HagalCard._sendRivalAgent(color, rival, best.desertSpace)
        MainBoard.getSpiceBonus(best.desertSpace):set(0)
        HagalCard.acquireTroops(color, 0, true)
        if PlayBoard.hasMakerHook(color) then
            MainBoard.blowUpShieldWall(color, true)
        end
        if best.desertSpace == "haggaBasin" and PlayBoard.hasMakerHook(color) then
            rival.resources(color, "spice", best.spiceBonus)
            rival.callSandworm(color, 1)
        elseif best.desertSpace == "imperialBasin" then
            rival.resources(color, "spice", best.totalSpice)
        else
            rival.resources(color, "spice", best.totalSpice)
        end
        return true
    else
        return false
    end
end

---@param color PlayerColor
---@param rival Rival
---@return boolean
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

--- TODO Adapter
---@param color PlayerColor
---@return { desertSpace: string, spiceBonus: integer, totalSpice: integer }
function HagalCard.findHarvestableSpace(color, ignoreIfNotFree)
    -- Note: order matters for ties.
    local desertSpaces = {
        imperialBasin = 1,
        haggaBasin = 2,
        --deepDesert = 4,
    }

    local best = {
        desertSpace = nil,
        spiceBonus = 0.5,
        totalSpice = 0,
    }

    for desertSpace, baseSpice in pairs(desertSpaces) do
        if not ignoreIfNotFree or HagalCard._spaceIsFree(color, desertSpace) then
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

---@param color PlayerColor
---@param rival Rival
---@return boolean
function HagalCard._activateInterstellarShipping(color, rival)
    if HagalCard._spaceIsFree(color, "interstellarShipping") and InfluenceTrack.hasFriendship(color, "spacingGuild") then
        HagalCard._sendRivalAgent(color, rival, "interstellarShipping")
        rival.shipments(color, 2)
        return true
    else
        return false
    end
end

---@param color PlayerColor
---@param rival Rival
---@return boolean
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

---@param color PlayerColor
---@param rival Rival
---@return boolean
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

-- Ix spaces

---@param color PlayerColor
---@param rival Rival
---@return boolean
function HagalCard._activateTechNegotiation(color, rival)
    if HagalCard._spaceIsFree(color, "techNegotiation") then
        HagalCard._sendRivalAgent(color, rival, "techNegotiation")
        TechMarket.registerAcquireTechOption(color, "techNegotiationTechBuyOption", "spice", 1)
        if not rival.acquireTech(color) then
            rival.troops(color, "supply", "negotiation", 1)
        end
        HagalCard._tryRecruitingSardaukarCommander(color, rival, "techNegotiation")
        return true
    else
        return false
    end
end

---@param color PlayerColor
---@param rival Rival
---@return boolean
function HagalCard._activateDreadnought1p(color, rival)
    if HagalCard._spaceIsFree(color, "dreadnought") and PlayBoard.getAquiredDreadnoughtCount(color) < 2 then
        HagalCard._sendRivalAgent(color, rival, "dreadnought")
        rival.dreadnought(color, "supply", "garrison", 1)
        TechMarket.registerAcquireTechOption(color, "dreadnoughtTechBuyOption", "spice", 0)
        rival.acquireTech(color)
        HagalCard._tryRecruitingSardaukarCommander(color, rival, "dreadnought")
        return true
    else
        return false
    end
end

---@param color PlayerColor
---@param rival Rival
---@return boolean
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

---@param color PlayerColor
---@param rival Rival
---@return boolean
function HagalCard._activateTleilaxuBonus1(color, rival)
    rival.beetle(color, 1)
    TleilaxuRow.trash(1)
    return false
end

---@param color PlayerColor
---@param rival Rival
---@return boolean
function HagalCard._activateTleilaxuBonus2(color, rival)
    rival.beetle(color, 1)
    return false
end

---@param color PlayerColor
---@param rival Rival
---@return boolean
function HagalCard._activateTleilaxuBonus3(color, rival)
    rival.beetle(color, 1)
    TleilaxuRow.trash(2)
    return false
end

-- Bloodlines changes

---@param color PlayerColor
---@param rival Rival
---@return boolean
function HagalCard._activateAcquireTech(color, rival)
    if PlayBoard.hasSwordmaster(color) then
        TechMarket.registerAcquireTechOption(color, "activateAcquireTechBuyOption", "spice", 1)
        rival.acquireTech(color)
    end
    return false
end

---@param color PlayerColor
---@param rival Rival
---@return boolean
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
        --Helper.dump("Thit Hagal card should have been automatically removed during the setup!")
        return false
    end
end

---@param color PlayerColor
---@param rival Rival
---@param spaceName string
---@return boolean
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

---@param color PlayerColor
---@param spaceName string
---@return boolean
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

---@param color PlayerColor
---@param rival Rival
---@param spaceName string
---@return boolean
function HagalCard._tryRecruitingSardaukarCommander(color, rival, spaceName)
    if PlayBoard.hasSwordmaster(color) and SardaukarCommander.isAvailable(spaceName) then
        if rival.isStreamlined() then
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
