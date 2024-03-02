local Module = require("utils.Module")
local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

local Action = Module.lazyRequire("Action")
local Hagal = Module.lazyRequire("Hagal")
local MainBoard = Module.lazyRequire("MainBoard")
local PlayBoard = Module.lazyRequire("PlayBoard")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")
local ShippingTrack = Module.lazyRequire("ShippingTrack")
local TechMarket = Module.lazyRequire("TechMarket")
local Intrigue = Module.lazyRequire("Intrigue")
local HagalCard = Module.lazyRequire("HagalCard")

local Rival = Helper.createClass(Action)

---
function Rival.newRival(name)
    local RivalClass = Rival[name]
    assert(RivalClass, "Unknown rival leader: " .. tostring(name))
    RivalClass.name = name
    return Helper.createClassInstance(RivalClass)
end

---
function Rival.triggerHagalReaction(color)
    local continuation = Helper.createContinuation("Rival.triggerHagalReaction")

    local coroutineHolder = {}
    coroutineHolder.coroutine = Helper.registerGlobalCallback(function ()
        assert(coroutineHolder.coroutine)
        Helper.unregisterGlobalCallback(coroutineHolder.coroutine)

        Helper.sleep(1)

        local rival = PlayBoard.getLeader(color)

        if rival.recallableSpies and #rival.recallableSpies == 2 then
            for _, otherObservationPostName in ipairs(rival.recallableSpies) do
                MainBoard.recallSpy(color, otherObservationPostName)
            end
            rival.recallableSpies = {}
            rival.scheme(color)
            Helper.sleep(2)
        end

        local hasSwordmaster = PlayBoard.hasSwordmaster(color)

        if not hasSwordmaster and Action.resources(color, "solari", -rival.swordmasterCost) then
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

---
function Rival._buyVictoryPoints(color)
    -- Do not use Rival.resources inside this function!

    local rival = PlayBoard.getLeader(color)

    if Helper.isElementOf(rival.name, { "glossuRabban", "amberMetulli" }) then
        return
    end

    while true do
        local intrigues = PlayBoard.getIntrigues(color)
        if #intrigues >= 3 then
            for i = 1, 3 do
                -- Not smooth to avoid being recaptured by the hand zone.
                intrigues[i].setPosition(Intrigue.discardZone.getPosition() + Vector(0, i, 0))
            end
            Rival.gainVictoryPoint(color, "intrigue")
            goto continue
        end

        if Hagal.riseOfIx then
            local tech = PlayBoard.getTech(color, "spySatellites")
            if tech and Action.resources(color, "spice", -3) then
                MainBoard.trash(tech)
                Rival.gainVictoryPoint(color, "spySatellites")
                goto continue
            end
        else
            if Action.resources(color, "spice", -7) then
                Rival.gainVictoryPoint(color, "spice")
                goto continue
            end
        end

        if Action.resources(color, "water", -3) then
            Rival.gainVictoryPoint(color, "water")
            goto continue
        end

        if Action.resources(color, "solari", -7) then
            Rival.gainVictoryPoint(color, "solari")
            goto continue
        end

        break
        ::continue::
        Helper.sleep(1.5)
    end
end

---
function Rival.prepare(color, settings)
    if Hagal.getRivalCount() == 2 then
        Action.resources(color, "water", 1)
        if settings.difficulty ~= "novice" then
            Action.troops(color, "supply", "garrison", 3)
            Action.drawIntrigues(color, 1)
        end
    else
        Action.resources(color, "water", 1)
        Action.troops(color, "supply", "garrison", 3)
    end
end

---
function Rival.influence(color, faction, amount)
    local finalFaction = faction
    local rival = PlayBoard.getLeader(color)
    if not finalFaction then
        finalFaction = rival.factionPriorities[1]
    elseif type(finalFaction) == "number" then
        finalFaction = rival.factionPriorities[faction]
    end
    return Action.influence(color, finalFaction, amount)
end

---
function Rival.shipments(color, amount)
    Helper.repeatChainedAction(amount, function ()
        local level = ShippingTrack.getFreighterLevel(color)
        if level < 2 then
            Rival.advanceFreighter(color, 1)
        else
            Rival.recallFreighter(color)
            Rival.influence(color, nil, 1)
            if PlayBoard.hasTech(color, "troopTransports") then
                Action.troops(color, "supply", "combat", 3)
            else
                Action.troops(color, "supply", "garrison", 2)
            end
            Rival.resources(color, "solari", 5)
            for _, otherColor in ipairs(PlayBoard.getActivePlayBoardColors()) do
                if otherColor ~= color then
                    local otherLeader = PlayBoard.getLeader(otherColor)
                    otherLeader.resources(otherColor, "solari", 1)
                end
            end
        end
        -- FIXME
        return Helper.onceTimeElapsed(0.5)
    end)
    return true
end

---
function Rival.acquireTech(color, stackIndex, discount)

    local finalStackIndex  = stackIndex
    if not finalStackIndex then
        local spiceBudget = PlayBoard.getResource(color, "spice"):get()

        local bestTechIndex
        local bestTech
        for otherStackIndex = 1, 3 do
            local tech = TechMarket.getTopCardDetails(otherStackIndex)
            if tech.hagal and tech.cost <= spiceBudget + discount and (not bestTech or bestTech.cost < tech.cost) then
                bestTechIndex = otherStackIndex
                bestTech = tech
            end
        end

        if bestTech then
            Rival.resources(color, "spice", -bestTech.cost)
            finalStackIndex = bestTechIndex
        else
            return false
        end
    end

    local tech = TechMarket.getTopCardDetails(finalStackIndex)
    if Action.acquireTech(color, finalStackIndex, discount) then
        if tech.name == "trainingDrones" then
            if PlayBoard.useTech(color, "trainingDrones") then
                Action.troops(color, "supply", "garrison", 1)
            end
        end
        return true
    else
        return false
    end
end

---
function Rival.pickContract(color, stackIndex)
    local rival = PlayBoard.getLeader(color)
    rival.resources(color, "solari", 2)
    return true
end

---
function Rival.choose(color, topic)

    local function pickTwoBestFactions()
        local factions = { "emperor", "spacingGuild", "beneGesserit", "fremen" }
        for _ = 1, 2 do
            Helper.shuffle(factions)
            table.sort(factions, function (f1, f2)
                local i1 = InfluenceTrack.getInfluence(f1, color)
                local i2 = InfluenceTrack.getInfluence(f2, color)
                return i1 > i2
            end)
            local faction = factions[1]
            table.remove(factions, 1)

            return Rival.influence(color, faction, 1)
        end
    end

    if Helper.isElementOf(topic, { "shuttleFleet", "machinations", "propaganda" }) then
        pickTwoBestFactions()
    end
end

---
function Action.decide(color, topic)
    return true
end

---
function Rival.resources(color, nature, amount)
    local rival = PlayBoard.getLeader(color)
    local hasSwordmaster = PlayBoard.hasSwordmaster(color)

    if amount > 0 and hasSwordmaster and Helper.isElementOf(rival, { Rival.glossuRabban, Rival.amberMetulli }) then
        return false
    else
        return Action.resources(color, nature, amount)
    end
end

---
function Rival.sendSpy(color, observationPostName)
    local rival = PlayBoard.getLeader(color)
    local finalObservationPostName = observationPostName
    if not finalObservationPostName then
        for _, faction in ipairs(rival.factionPriorities) do
            -- Observation posts in faction spaces have the same name as the faction.
            if not MainBoard.observationPostIsOccupied(faction) then
                finalObservationPostName = faction
                break
            end
        end
    end
    if finalObservationPostName then
        local recallableSpies = MainBoard.findRecallableSpies(color)
        if Action.sendSpy(color, finalObservationPostName) then
            rival.recallableSpies = recallableSpies
            return true
        end
    else
        log("No free observation post!")
    end
    return false
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
        local rival = PlayBoard.getLeader(color)
        for _, faction in ipairs(rival.factionPriorities) do
            local cost = InfluenceTrack.getAllianceCost(color, faction)
            if cost == 1 or cost == 2 then
                Rival.influence(color, faction, 2)
                break
            end
        end
    end,

    gainVictoryPoint = function (color, name)
        if Helper.endsWith(name, "Alliance") then
            return Action.gainVictoryPoint(color, name)
        else
            return false
        end
    end,

    --[[
    gainObjective = function (color, objective)
        return false
    end,
    ]]
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

    gainVictoryPoint = function (color, name)
        return false
    end,

    --[[
    gainObjective = function (color, objective)
        return false
    end,
    ]]
})

Rival.gurneyHalleck = Helper.createClass(Rival, {

    swordmasterCost = 6,

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
        local rival = PlayBoard.getLeader(color)
        local bestFaction = nil
        local bestRank = nil
        for _, faction in ipairs(rival.factionPriorities) do
            local rank = InfluenceTrack.getInfluence(faction, color)
            if not bestRank or bestRank < rank then
                bestFaction = faction
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
        local rival = PlayBoard.getLeader(color)
        for _, faction in ipairs(rival.factionPriorities) do
            local cost = InfluenceTrack.getAllianceCost(color, faction)
            if cost == 1 then
                Rival.influence(color, faction, 1)
                break
            end
        end
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

return Rival
