local Module = require("utils.Module")
local Helper = require("utils.Helper")
local I18N = require("utils.I18N")
local Park = require("utils.Park")

local Action = Module.lazyRequire("Action")
local Hagal = Module.lazyRequire("Hagal")
local MainBoard = Module.lazyRequire("MainBoard")
local PlayBoard = Module.lazyRequire("PlayBoard")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")
local ShippingTrack = Module.lazyRequire("ShippingTrack")
local TechMarket = Module.lazyRequire("TechMarket")
local Intrigue = Module.lazyRequire("Intrigue")
local HagalCard = Module.lazyRequire("HagalCard")
local Types = Module.lazyRequire("Types")
local Combat = Module.lazyRequire("Combat")

---@class Rival: Leader
---@field swordmasterCost integer
---@field factionPriorities Faction[]
---@field recallableSpies Object[]
local Rival = Helper.createClass(Action)

---@return Rival
function Rival.newRival(name)
    local RivalClass = Rival[name]
    assert(RivalClass, "Unknown rival leader: " .. tostring(name))
    RivalClass.name = name
    return Helper.createClassInstance(RivalClass)
end

---@param color PlayerColor
function Rival.getRival(color)
    local leader = PlayBoard.getLeader(color)
    ---@cast leader Rival
    return leader
end

---@param color PlayerColor
---@return Continuation
function Rival.triggerHagalReaction(color)
    local continuation = Helper.createContinuation("Rival.triggerHagalReaction")

    local coroutineHolder = {}
    coroutineHolder.coroutine = Helper.registerGlobalCallback(function ()
        assert(coroutineHolder.coroutine)
        Helper.unregisterGlobalCallback(coroutineHolder.coroutine)

        -- Enough time for any intrigue card to reach a rival hand.
        Helper.sleep(2)

        local rival = Rival.getRival(color)

        if rival.recallableSpies and #rival.recallableSpies == 2 then
            for _, otherObservationPostName in ipairs(rival.recallableSpies) do
                MainBoard.recallSpy(color, otherObservationPostName)
            end
            rival.recallableSpies = {}
            -- Doesn't work well as a scheme.
            --Action.setContext("schemeTriggered", {})
            Action.log(I18N("triggeringScheme", { leader = PlayBoard.getLeaderName(color) }), color)
            rival.scheme(color)
            Helper.sleep(2)
            --Action.unsetContext("schemeTriggered")
        end

        local hasSwordmaster = PlayBoard.hasSwordmaster(color)

        local allResources = {
            intrigues = PlayBoard.getIntrigues(color),
            solari = PlayBoard.getResource(color, "solari"),
            spice = PlayBoard.getResource(color, "spice"),
            water = PlayBoard.getResource(color, "water"),
        }

        local reduceGenericResource = function (name, amount)
            local realAmount
            if name == "intrigues" then
                realAmount = math.min(amount, #allResources.intrigues)
                for i = 1, realAmount do
                    -- Not smooth to avoid being recaptured by the hand zone.
                    Intrigue.discard(allResources.intrigues[i])
                end
            else
                realAmount = math.min(amount, allResources[name]:get())
                Action.resources(color, name, -realAmount)
            end
            return realAmount
        end

        local capital =
            #allResources.intrigues +
            allResources.solari:get() +
            allResources.spice:get() +
            allResources.water:get()

        if not hasSwordmaster and capital >= rival.swordmasterCost then
            local remainder = rival.swordmasterCost
            for _, name in ipairs({ "solari", "spice", "intrigues", "water" }) do
                if remainder == 0 then
                    break
                end
                remainder = remainder - reduceGenericResource(name, remainder)
            end
            rival.recruitSwordmaster(color)
            hasSwordmaster = true
            Helper.sleep(1)
        end

        if hasSwordmaster then
            Rival._buyVictoryPoints(color)
        end

        continuation.run()

        return 1
    end)
    startLuaCoroutine(Global, coroutineHolder.coroutine)

    return continuation
end

---@param color PlayerColor
function Rival._buyVictoryPoints(color)
    -- Do not use Rival.resources inside this function!

    local rival = Rival.getRival(color)

    if rival.isStreamlined() then
        return
    end

    local level3Conflict = Combat.getCurrentConflictLevel() == 3
    local techAvailable = Hagal.isIxAvailable()

    while true do
        local intrigues = PlayBoard.getIntrigues(color)
        if #intrigues >= 3 then
            for i = 1, 3 do
                -- Not smooth to avoid being recaptured by the hand zone.
                Intrigue.discard(intrigues[i])
            end
            Rival.gainVictoryPoint(color, "intrigue", 1)
            goto continue
        end

        if techAvailable then
            local tech = PlayBoard.getTech(color, "spySatellites")
            if tech and Action.resources(color, "spice", -3) then
                MainBoard.trash(tech)
                Rival.gainVictoryPoint(color, "spySatellites", 1)
                goto continue
            end
        end

        if not techAvailable or level3Conflict then
            if Action.resources(color, "spice", -7) then
                Rival.gainVictoryPoint(color, "spice", 1)
                goto continue
            end
        end

        if Action.resources(color, "water", -3) then
            Rival.gainVictoryPoint(color, "water", 1)
            goto continue
        end

        if Action.resources(color, "solari", -7) then
            Rival.gainVictoryPoint(color, "solari", 1)
            goto continue
        end

        break
        ::continue::
        Helper.sleep(1.5)
    end
end

---@param color PlayerColor
---@param settings Settings
function Rival.prepare(color, settings)
    local rivalCount = Hagal.getRivalCount()
    if rivalCount == 1 then
        Action.resources(color, "water", 1)
        Action.troops(color, "supply", "garrison", 3)
    else
        assert(rivalCount == 2)
        Action.resources(color, "water", 1)
        if settings.difficulty ~= "novice" then
            Action.troops(color, "supply", "garrison", 3)
        end
    end
end

---@param color PlayerColor
---@param factions Faction[]
---@return Faction
function Rival:_removeBestFaction(color, factions)
    local function indexOf(faction)
        for i, f in pairs(self.factionPriorities) do
            if f == faction then
                return i
            end
        end
        assert(false)
    end
    table.sort(factions, function (f1, f2)
        local i1 = InfluenceTrack.getInfluence(f1, color) * 10 + indexOf(f1)
        local i2 = InfluenceTrack.getInfluence(f2, color) * 10 + indexOf(f2)
        return i1 < i2
    end)
    local bestFaction = factions[1]
    table.remove(factions, 1)
    return bestFaction
end

---@param color PlayerColor
---@param indexOrfactionOrFactions nil|integer|Faction|Faction[]
---@param amount integer
---@return Continuation
function Rival.influence(color, indexOrfactionOrFactions, amount)
    local finalFaction
    local rival = Rival.getRival(color)
    if not indexOrfactionOrFactions or type(indexOrfactionOrFactions) == "table" then
        local factions = indexOrfactionOrFactions
        if not factions then
            factions = { "emperor", "spacingGuild", "beneGesserit", "fremen" }
        end
        finalFaction = rival:_removeBestFaction(color, factions)
    elseif type(indexOrfactionOrFactions) == "number" then
        local index = indexOrfactionOrFactions
        finalFaction = rival.factionPriorities[index]
    else
        finalFaction = indexOrfactionOrFactions
    end
    ---@cast finalFaction Faction
    return Action.influence(color, finalFaction, amount)
end

---@param color PlayerColor
---@param amount integer
function Rival.gainAllianceIfAble(color, amount)
    local factions = {}
    for _, faction in ipairs({ "emperor", "spacingGuild", "beneGesserit", "fremen" }) do
        local cost = InfluenceTrack.getAllianceCost(color, faction)
        if cost <= amount then
            table.insert(factions, faction)
        end
    end
    Rival.influence(color, #factions > 0 and factions or nil, amount)
end

---@param color PlayerColor
---@param amount integer
---@return boolean
function Rival.shipments(color, amount)
    Helper.repeatChainedAction(amount, function ()
        local level = ShippingTrack.getFreighterLevel(color)
        if level < 2 then
            Rival.advanceFreighter(color, 1)
        else
            Rival.recallFreighter(color)
            Rival.influence(color, nil, 1)
            if PlayBoard.hasTech(color, "troopTransports") then
                Rival.troops(color, "supply", "combat", 3)
            else
                Rival.troops(color, "supply", "garrison", 2)
            end
            Rival.resources(color, "solari", 5)
            for _, otherColor in ipairs(PlayBoard.getActivePlayBoardColors()) do
                if otherColor ~= color then
                    local otherLeader = PlayBoard.getLeader(otherColor)
                    otherLeader.resources(otherColor, "solari", 1)
                end
            end
        end
        return Helper.onceTimeElapsed(0.5)
    end)
    return true
end

---@param color PlayerColor
---@param stackIndex? integer
---@return boolean
function Rival.acquireTech(color, stackIndex)
    local finalStackIndex = stackIndex
    if not finalStackIndex then
        local negotiation = TechMarket.getNegotiationPark(color)
        local negotiatorCount = negotiation and #Park.getObjects(negotiation) or 0
        local discount = TechMarket.getRivalSpiceDiscount()
        local spiceBudget = PlayBoard.getResource(color, "spice"):get()
        local budget = spiceBudget + discount + negotiatorCount

        local bestTechIndex = nil
        local bestTech = nil
        for otherStackIndex = 1, 3 do
            local tech = TechMarket.getTopCardDetails(otherStackIndex)
            --Helper.dump("tech:", tech, ", cost:", tech and tech.cost, ", spiceBudget:", spiceBudget, ", discount:", discount, "negotiatorCount:", negotiatorCount)
            if tech and tech.hagal and tech.cost <= budget and (not bestTech or bestTech.cost < tech.cost) then
                bestTechIndex = otherStackIndex
                bestTech = tech
            end
        end

        if bestTechIndex then
            finalStackIndex = bestTechIndex
        else
            return false
        end
    end

    local techDetails = TechMarket.getTopCardDetails(finalStackIndex)
    if techDetails and Action.acquireTech(color, finalStackIndex) then
        if techDetails.name == "trainingDrones" then
            if PlayBoard.useTech(color, "trainingDrones") then
                Rival.troops(color, "supply", "garrison", 1)
            end
        elseif techDetails.name == "spyDrones" then
            if PlayBoard.useTech(color, "spyDrones") then
                Rival.resources(color, "solari", 1)
            end
        end
        return true
    else
        return false
    end
end

---@param color PlayerColor
---@param stackIndex integer
---@return boolean
function Rival.pickContract(color, stackIndex)
    local rival = Rival.getRival(color)
    rival.resources(color, "solari", 2)
    return true
end

---@param color PlayerColor
---@param topic string
---@return boolean
function Rival.randomlyChoose(color, topic)
    if Helper.isElementOf(topic, { "shuttleFleet", "machinations", "propaganda" }) then
        local factions = { "emperor", "spacingGuild", "beneGesserit", "fremen" }
        Helper.repeatChainedAction(2, function ()
            return Rival.influence(color, factions, 1)
        end)
        return false
    elseif Helper.isElementOf(topic, { "geneLockedVault" }) then
        Rival.drawIntrigues(color, 1)
        return false
    else
        return true
    end
end

---@param color PlayerColor
---@param topic string
---@return boolean
function Rival.decide(color, topic)
    return true
end

---@param color PlayerColor
---@param nature ResourceName
---@param amount integer
---@return boolean
function Rival.resources(color, nature, amount)
    local rival = Rival.getRival(color)
    local hasSwordmaster = PlayBoard.hasSwordmaster(color)
    if nature ~= "strength" and amount > 0 and hasSwordmaster and rival.isStreamlined() then
        return false
    else
        return Action.resources(color, nature, amount)
    end
end

---@param color PlayerColor
---@param from TroopLocation
---@param to TroopLocation
---@param baseCount integer
---@return integer
function Rival.troops(color, from, to, baseCount)
    local finalCount = baseCount
    if from == "garrison" and to == "combat" then
        local garrison = Action.getTroopPark(color, "garrison")
        local allSardaukarCommanders = Park.getObjects(garrison, function (object, tags)
            return Types.isSardaukarCommander(object, color)
        end)
        if #allSardaukarCommanders > 0 then
            local sardaukarCommanders = {}
            for i, sardaukarCommander in ipairs(allSardaukarCommanders) do
                if i > baseCount then
                    break
                end
                table.insert(sardaukarCommanders, sardaukarCommander)
            end
            local count = #sardaukarCommanders
            Action.log(I18N("transfer", {
                count = count,
                what = I18N.agree(count, "sardaukarCommander"),
                from = I18N("garrisonPark"),
                to = I18N("combatPark"),
            }), color)
            local combat = Action.getTroopPark(color, "combat")
            Park.putObjects(sardaukarCommanders, combat)
            finalCount = baseCount - count
        end
    end
    return Action.troops(color, from, to, finalCount)
end

---@param color PlayerColor
---@param observationPostName? string
---@param deepCover? boolean
---@return boolean
function Rival.sendSpy(color, observationPostName, deepCover)
    local rival = Rival.getRival(color)
    ---@cast rival Rival
    local finalObservationPostName = observationPostName
    if not finalObservationPostName then
        for _, faction in ipairs(rival.factionPriorities) do
            -- Observation posts in faction spaces have the same name as the faction.
            if not MainBoard.observationPostIsOccupied(faction, deepCover and color or nil) then
                finalObservationPostName = faction
                break
            end
        end
    end
    if finalObservationPostName then
        local recallableSpies = MainBoard.findRecallableSpies(color)
        if Action.sendSpy(color, finalObservationPostName, deepCover) then
            rival.recallableSpies = recallableSpies
            return true
        end
    else
        Helper.dump("No free observation post!")
    end
    return false
end

---@return boolean
function Rival.isStreamlined()
    return false
end

---@param color PlayerColor
function Rival.scheme(color)
    -- NOP
end

Rival.vladimirHarkonnen = Helper.createClass(Rival, {

    swordmasterCost = 6,

    factionPriorities = {
        "spacingGuild",
        "emperor",
        "beneGesserit",
        "fremen",
    },

    signetRing = function (color)
        Rival.drawIntrigues(color, 1)
    end,

    scheme = function (color)
        Rival.resources(color, "solari", 2)
        HagalCard.acquireTroops(color, 2)
    end,
})

Rival.glossuRabban = Helper.createClass(Rival, {

    swordmasterCost = 7,

    factionPriorities = {
        "emperor",
        "spacingGuild",
        "beneGesserit",
        "fremen",
    },

    signetRing = function (color)
        HagalCard.acquireTroops(color, InfluenceTrack.hasAnyAlliance(color) and 2 or 1)
    end,

    scheme = function (color)
        Rival.gainAllianceIfAble(color, 2)
    end,

    gainVictoryPoint = function (color, name, count)
        if Helper.endsWith(name, "Alliance") then
            assert(count == 1)
            return Action.gainVictoryPoint(color, name, count)
        else
            return false
        end
    end,

    isStreamlined = function ()
        return true
    end,
})

Rival.stabanTuek = Helper.createClass(Rival, {

    swordmasterCost = 9,

    factionPriorities = {
        "spacingGuild",
        "fremen",
        "beneGesserit",
        "emperor",
    },

    signetRing = function (color)
        Rival.resources(color, "spice", 1)
    end,

    scheme = function (color)
        HagalCard.acquireTroops(color, 2)
    end,
})

Rival.amberMetulli = Helper.createClass(Rival, {

    swordmasterCost = 9,

    factionPriorities = {
        "fremen",
        "emperor",
        "spacingGuild",
        "beneGesserit",
    },

    signetRing = function (color)
        HagalCard.acquireTroops(color, 1)
    end,

    scheme = function (color)
        HagalCard.acquireTroops(color, 3)
    end,

    gainVictoryPoint = function (color, name, count)
        if Helper.endsWith(name, "Alliance") then
            assert(count == 1)
            return Action.gainVictoryPoint(color, name, count)
        else
            return false
        end
    end,

    isStreamlined = function ()
        return true
    end,
})

Rival.gurneyHalleck = Helper.createClass(Rival, {

    swordmasterCost = 8,

    factionPriorities = {
        "fremen",
        "spacingGuild",
        "emperor",
        "beneGesserit",
    },

    signetRing = function (color)
        HagalCard.acquireTroops(color, 1)
    end,

    scheme = function (color)
        local rival = Rival.getRival(color)
        local bestFaction = nil
        local bestRank = nil
        for _, faction in ipairs(rival.factionPriorities) do
            local rank = InfluenceTrack.getInfluence(faction, color)
            if not bestRank or bestRank < rank then
                bestFaction = faction
                bestRank = rank
            end
        end
        Rival.influence(color, bestFaction, 1)
    end,
})

Rival.margotFenring = Helper.createClass(Rival, {

    swordmasterCost = 8,

    factionPriorities = {
        "beneGesserit",
        "emperor",
        "fremen",
        "spacingGuild",
    },

    signetRing = function (color)
        Rival.resources(color, "solari", 1)
    end,

    scheme = function (color)
        Rival.influence(color, "beneGesserit", 1)
    end,
})

Rival.irulanCorrino = Helper.createClass(Rival, {

    swordmasterCost = 7,

    factionPriorities = {
        "emperor",
        "beneGesserit",
        "fremen",
        "spacingGuild",
    },

    signetRing = function (color)
        Rival.sendSpy(color)
    end,

    scheme = function (color)
        Rival.influence(color, nil, 1)
        HagalCard.acquireTroops(color, 1)
    end,
})

Rival.jessica = Helper.createClass(Rival, {

    swordmasterCost = 6,

    factionPriorities = {
        "beneGesserit",
        "fremen",
        "spacingGuild",
        "emperor",
    },

    signetRing = function (color)
        Rival.gainAllianceIfAble(color, 1)
    end,

    scheme = function (color)
        Rival.resources(color, "water", 2)
    end,
})

Rival.feydRauthaHarkonnen = Helper.createClass(Rival, {

    swordmasterCost = 4,

    factionPriorities = {
        "emperor",
        "beneGesserit",
        "spacingGuild",
        "fremen",
    },

    signetRing = function (color)
        HagalCard.acquireTroops(color, 2)
    end,

    scheme = function (color)
        Rival.influence(color, nil, 1)
    end,
})

Rival.muadDib = Helper.createClass(Rival, {

    swordmasterCost = 4,

    factionPriorities = {
        "fremen",
        "beneGesserit",
        "spacingGuild",
        "emperor",
    },

    signetRing = function (color)
        Rival.influence(color, "fremen", 1)
    end,

    scheme = function (color)
        Rival.takeMakerHook(color)
        MainBoard.blowUpShieldWall(color, true)
        Rival.drawIntrigues(color, 1)
    end,
})

Rival.duncanIdaho = Helper.createClass(Rival, {

    swordmasterCost = 8,

    factionPriorities = {
        "fremen",
        "beneGesserit",
        "spacingGuild",
        "emperor",
    },

    signetRing = function (color)
        Rival.troops(color, "supply", "garrison", 1)
        if PlayBoard.hasSwordmaster(color) then
            Rival.resources(color, "spice", 1)
        end
    end,

    scheme = function (color)
        Rival.influence(color, "fremen", 1)
    end,
})

Rival.piterDeVries = Helper.createClass(Rival, {

    swordmasterCost = 7,

    factionPriorities = {
        "spacingGuild",
        "emperor",
        "beneGesserit",
        "fremen",
    },

    signetRing = function (color)
        Rival.resources(color, "solari", 1)
        if InfluenceTrack.hasAnyAlliance(color) then
            Rival.drawIntrigues(color, 1)
        end
    end,

    scheme = function (color)
        Rival.influence(color, nil, 1)
        Rival.resources(color, "solari", 1)
    end,
})

Rival.chani = Helper.createClass(Rival, {

    swordmasterCost = 6,

    factionPriorities = {
        "fremen",
        "spacingGuild",
        "beneGesserit",
        "emperor",
    },

    signetRing = function (color)
        Rival.resources(color, "water", 1)
    end,

    scheme = function (color)
        local collectedSpiceAmount = 0
        for _, otherColor in ipairs(PlayBoard.getActivePlayBoardColors()) do
            if color ~= otherColor then
                if PlayBoard.getLeader(otherColor).resources(otherColor, "spice", -1) then
                    collectedSpiceAmount = collectedSpiceAmount + 1
                end
            end
        end
        Rival.resources(color, "spice", collectedSpiceAmount)
    end,
})

Rival.hasimirFenring = Helper.createClass(Rival, {

    swordmasterCost = 5,

    factionPriorities = {
        "emperor",
        "beneGesserit",
        "spacingGuild",
        "fremen",
    },

    prepare = function (color, settings)
        Rival.prepare(color, settings)
        Rival.influence(color, "emperor", 1)
    end,

    signetRing = function (color)
        Rival.resources(color, "solari", 1)
        Rival.troops(color, "supply", "garrison", 1)
    end,

    scheme = function (color)
        Rival.drawIntrigues(color, 1)
        Rival.resources(color, "solari", 3)
    end,
})

Rival.gaiusHelenMohiam = Helper.createClass(Rival, {

    swordmasterCost = 4,

    factionPriorities = {
        "beneGesserit",
        "emperor",
        "fremen",
        "spacingGuild",
    },

    signetRing = function (color)
        Helper.dumpFunction("Rival.gaiusHelenMohiam.signetRing")
        Rival.sendSpy(color)
        Rival.troops(color, "supply", "garrison", 1)
    end,

    scheme = function (color)
        Rival.drawIntrigues(color, 1)
        Rival.gainAllianceIfAble(color, 1)
    end,
})

Rival.kotaOdax = Helper.createClass(Rival, {

    swordmasterCost = 7,

    factionPriorities = {
        "spacingGuild",
        "beneGesserit",
        "fremen",
        "emperor",
    },

    signetRing = function (color)
        Rival.resources(color, "spice", 1)
        TechMarket.registerAcquireTechOption(color, "kotaOdaxSignetRingTechBuyOption", "spice", 1)
        Rival.acquireTech(color, nil)
    end,

    scheme = function (color)
        Rival.influence(color, nil, 1)
        Rival.resources(color, "spice", 2)
    end,
})

return Rival
