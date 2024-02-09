local Module = require("utils.Module")
local Helper = require("utils.Helper")

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
function Rival.prepare(color, settings)
    if Hagal.numberOfPlayers == 1 then
        Action.resources(color, "water", 1)
        if settings.difficulty ~= "novice" then
            Action.troops(color, "supply", "garrison", 3)
            Action.drawIntrigues(color, 1)
        end
    elseif Hagal.numberOfPlayers == 2 then
        Action.resources(color, "water", 1)
        Action.troops(color, "supply", "garrison", 3)
    end
end

---
function Rival.influence(color, faction, amount)
    Helper.dumpFunction("Rival.influence", color, faction, amount)
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
    --Helper.dumpFunction("Rival.choose", color, topic)

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

    if topic == "shuttleFleet" then
        pickTwoBestFactions()
    elseif topic == "machinations" then
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
    end

    if Action.resources(color, nature, amount) then
        if amount > 0 then
            if nature == "solari" and not hasSwordmaster and Action.resources(color, "solari", -rival.swordmasterCost) then
                rival.recruitSwordmaster(color)
                hasSwordmaster = true
            end
            if hasSwordmaster then
                Rival._buyVictoryPoints(color)
            end
        end
        return true
    end

    return false
end

---
function Rival.drawIntrigues(color, amount)
    if Action.drawIntrigues(color, amount) then
        if PlayBoard.hasSwordmaster(color) then
            Helper.onceTimeElapsed(1).doAfter(function ()
                Rival._buyVictoryPoints(color)
            end)
        end
        return true
    else
        return false
    end
end

---
function Rival._buyVictoryPoints(color)
    -- Do not use Rival.resources inside this function!

    Helper.dumpFunction("Rival._buyVictoryPoints", color)
    local rival = PlayBoard.getLeader(color)

    if Helper.isElementOf(rival.name, { "glossuRabban", "amberMetulli" }) then
        return
    end

    local intrigues = PlayBoard.getIntrigues(color)
    local done
    repeat
        done = true

        if #intrigues >= 3 then
            for i = 1, 3 do
                -- Not smooth to avoid being recaptured by the hand zone.
                intrigues[i].setPosition(Intrigue.discardZone.getPosition() + Vector(0, 1, 0))
            end
            Rival.gainVictoryPoint(color, "intrigue")
        end

        if Hagal.riseOfIx then
            local tech = PlayBoard.getTech(color, "spySatellites")
            if tech and Action.resources(color, "spice", -3) then
                MainBoard.trash(tech)
                Rival.gainVictoryPoint(color, "spySatellites")
                done = false
            end
        else
            if Action.resources(color, "spice", -7) then
                Rival.gainVictoryPoint(color, "spice")
                done = false
            end
        end

        if Action.resources(color, "water", -3) then
            Rival.gainVictoryPoint(color, "water")
            done = false
        end

        if Action.resources(color, "solari", -7) then
            Rival.gainVictoryPoint(color, "solari")
            done = false
        end

    until done
end

---
function Rival.sendSpy(color, observationPostName)
    local rival = PlayBoard.getLeader(color)
    local finalObservationPostName = observationPostName
    if not observationPostName then
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
        if Action.sendSpy(color, observationPostName) then
            if #recallableSpies == 2 then
                for _, otherObservationPostName in ipairs(recallableSpies) do
                    MainBoard.recallSpy(color, otherObservationPostName)
                end
            end
            Helper.dump("Triggering scheme for", color)
            rival.scheme(color)
        end
    end
    return false
end

Rival.vladimirHarkonnen = Helper.createClass(Rival, {

    swordmasterCost = 6,

    factionPriorities = {
        emperor = 2,
        spacingGuild = 1,
        beneGesserit = 3,
        fremen = 4,
    },

    scheme = function (color)
        Rival.drawIntrigues(color, 1)
    end,

    signetRing = function (color)
        Rival.resources(color, "solari", 2)
        HagalCard.acquireTroops(color, 2)
    end
})

Rival.glossuRabban = Helper.createClass(Rival, {

    swordmasterCost = 7,

    factionPriorities = {
        emperor = 1,
        spacingGuild = 2,
        beneGesserit = 3,
        fremen = 4,
    },

    scheme = function (color)
        HagalCard.acquireTroops(color, InfluenceTrack.hasAnyAlliance(color) and 2 or 1)
    end,

    signetRing = function (color)
        local rival = PlayBoard.getLeader(color)
        for _, faction in ipairs(rival.factionPriorities) do
            local cost = InfluenceTrack.getAllianceCost(color)
            if cost == 1 or cost == 2 then
                Rival.influence(color, faction, 2)
            end
        end
    end,

    gainVictoryPoint = function (color, name)
        return false
    end,

    gainObjective = function (color, objective)
        return false
    end
})

Rival.stabanTuek = Helper.createClass(Rival, {

    swordmasterCost = 9,

    factionPriorities = {
        emperor = 4,
        spacingGuild = 1,
        beneGesserit = 3,
        fremen = 2,
    },

    scheme = function (color)
        Rival.resources(color, "spice", 1)
    end,

    signetRing = function (color)
        HagalCard.acquireTroops(color, 2)
    end
})

Rival.amberMetulli = Helper.createClass(Rival, {

    swordmasterCost = 9,

    factionPriorities = {
        emperor = 2,
        spacingGuild = 3,
        beneGesserit = 4,
        fremen = 1,
    },

    scheme = function (color)
        HagalCard.acquireTroops(color, 1)
    end,

    signetRing = function (color)
        HagalCard.acquireTroops(color, 3)
    end,

    gainVictoryPoint = function (color, name)
        return false
    end,

    gainObjective = function (color, objective)
        return false
    end
})

Rival.gurneyHalleck = Helper.createClass(Rival, {

    swordmasterCost = 6,

    factionPriorities = {
        emperor = 3,
        spacingGuild = 2,
        beneGesserit = 4,
        fremen = 1,
    },

    scheme = function (color)
        HagalCard.acquireTroops(color, 1)
    end,

    signetRing = function (color)
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
    end
})

Rival.margotFenring = Helper.createClass(Rival, {

    swordmasterCost = 8,

    factionPriorities = {
        emperor = 2,
        spacingGuild = 4,
        beneGesserit = 1,
        fremen = 3,
    },

    scheme = function (color)
        Rival.resources(color, "solari", 1)
    end,

    signetRing = function (color)
        Rival.influence(color, "beneGesserit", 1)
    end
})

Rival.irulanCorrino = Helper.createClass(Rival, {

    swordmasterCost = 7,

    factionPriorities = {
        emperor = 1,
        spacingGuild = 4,
        beneGesserit = 2,
        fremen = 3,
    },

    scheme = function (color)
        Rival.sendSpy(color)
    end,

    signetRing = function (color)
        Rival.influence(color, nil, 1)
        HagalCard.acquireTroops(color, 1)
    end
})

Rival.jessica = Helper.createClass(Rival, {

    swordmasterCost = 6,

    factionPriorities = {
        emperor = 4,
        spacingGuild = 3,
        beneGesserit = 1,
        fremen = 2,
    },

    scheme = function (color)
        local rival = PlayBoard.getLeader(color)
        for _, faction in ipairs(rival.factionPriorities) do
            local cost = InfluenceTrack.getAllianceCost(color)
            if cost == 1 then
                Rival.influence(color, faction, 1)
            end
        end
    end,

    signetRing = function (color)
        Rival.resources(color, "water", 2)
    end
})

Rival.feydRauthaHarkonnen = Helper.createClass(Rival, {

    swordmasterCost = 4,

    factionPriorities = {
        emperor = 1,
        spacingGuild = 3,
        beneGesserit = 2,
        fremen = 4,
    },

    scheme = function (color)
        HagalCard.acquireTroops(color, 2)
    end,

    signetRing = function (color)
        Rival.influence(color, nil, 1)
    end
})

Rival.muadDib = Helper.createClass(Rival, {

    swordmasterCost = 4,

    factionPriorities = {
        emperor = 4,
        spacingGuild = 3,
        beneGesserit = 2,
        fremen = 1,
    },

    scheme = function (color)
        Rival.influence(color, "fremen", 1)
    end,

    signetRing = function (color)
        Rival.takeMakerHook(color)
        MainBoard.blowUpShieldWall(color, true)
        Rival.drawIntrigues(color, 1)
    end
})

return Rival
