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
local Types = Module.lazyRequire("Types")
local Leader = Module.lazyRequire("Leader")

local Rival = Helper.createClass(Action, {
    rivals = {}
})

---
function Rival.newRival(color, leaderName)
    --Helper.dumpFunction("Rival.newRival", color, leaderName)
    local rival = Helper.createClassInstance(Rival, {
        leader = leaderName and Leader.newLeader(leaderName) or Hagal,
    })
    rival.name = rival.leader.name
    if Hagal.getRivalCount() == 1 then
        assert(leaderName == nil)
        rival.recruitSwordmaster(color)
    else
        assert(leaderName)
    end
    Rival.rivals[color] = rival
    return rival
end

---
function Rival.prepare(color, settings)
    if Hagal.numberOfPlayers == 1 then
        Action.resources(color, "water", 1)
        if settings.difficulty ~= "novice" then
            Action.troops(color, "supply", "garrison", 3)
            Action.drawIntrigues(color, 1)
        end
    -- https://boardgamegeek.com/thread/2570879/article/36734124#36734124
    elseif Hagal.numberOfPlayers == 2 then
        Action.resources(color, "water", 1)
        Action.troops(color, "supply", "garrison", 3)
    end
end

---
function Rival.influence(color, faction, amount)
    local finalFaction = faction
    if not finalFaction then
        local factions = { "emperor", "spacingGuild", "beneGesserit", "fremen" }
        Helper.shuffle(factions)
        table.sort(factions, function (f1, f2)
            local i1 = InfluenceTrack.getInfluence(f1, color)
            local i2 = InfluenceTrack.getInfluence(f2, color)
            return i1 < i2
        end)
        finalFaction = factions[1]
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

    local techDetails = TechMarket.getTopCardDetails(finalStackIndex)
    if Action.acquireTech(color, finalStackIndex, discount) then
        if techDetails.name == "trainingDrones" then
            if PlayBoard.useTech(color, "trainingDrones") then
                Rival.troops(color, "supply", "garrison", 1)
            end
        end
        return true
    else
        return false
    end
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
        return true
    elseif topic == "machinations" then
        pickTwoBestFactions()
        return true
    else
        return false
    end
end

---
function Rival.resources(color, nature, amount)
    if Hagal.getRivalCount() == 2 then
        if Action.resources(color, nature, amount) then
            local resource = PlayBoard.getResource(color, nature)
            if nature == "spice" then
                if Hagal.riseOfIx then
                    local tech = PlayBoard.getTech(color, "spySatellites")
                    if tech and nature == "spice" and resource:get() >= 3 then
                        MainBoard.trash(tech)
                        Rival.gainVictoryPoint(color, "spySatellites")
                    end
                else
                    if resource:get() >= 7 then
                        resource:change(-7)
                        Rival.gainVictoryPoint(color, "spice")
                    end
                end
            elseif nature == "water" then
                if resource:get() >= 3 then
                    resource:change(-3)
                    Rival.gainVictoryPoint(color, "water")
                end
            elseif nature == "solari" then
                if resource:get() >= 7 then
                    resource:change(-7)
                    Rival.gainVictoryPoint(color, "solari")
                end
            end
            return true
        end
    elseif Hagal.getRivalCount() == 1 and nature == "strength"  then
        return Action.resources(color, nature, amount)
    end
    return false
end

---
function Rival.beetle(color, jump)
    Types.assertIsPlayerColor(color)
    Types.assertIsInteger(jump)
    if Hagal.getRivalCount() == 2 then
        return Action.beetle(color, jump)
    else
        return false
    end
end

---
function Rival.drawIntrigues(color, amount)
    if Action.drawIntrigues(color, amount) then
        Helper.onceTimeElapsed(1).doAfter(function ()
            local intrigues = PlayBoard.getIntrigues(color)
            if #intrigues >= 3 then
                for i = 1, 3 do
                    -- Not smooth to avoid being recaptured by the hand zone.
                    intrigues[i].setPosition(Intrigue.discardZone.getPosition() + Vector(0, 1, 0))
                end
                Rival.gainVictoryPoint(color, "intrigue")
            end
        end)
        return true
    else
        return false
    end
end

---
function Rival.troops(color, from, to, amount)
    local finalTo = to
    if to == "garrison" and (Action.checkContext({ troopTransports = true }) or Action.checkContext({ hagalCard = HagalCard.isCombatCard })) then
        finalTo = "combat"
    end
    return Action.troops(color, from, finalTo, amount)
end

---
function Rival.gainVictoryPoint(color, name)
    -- We make an exception for alliance token to make it clear that the rival owns it.
    if Hagal.getRivalCount() == 2 or Helper.endsWith(name, "Alliance") then
        return Action.gainVictoryPoint(color, name)
    else
        return false
    end
end

---
function Rival.signetRing(color)
    -- FIXME Fix Park instead!
    Helper.onceTimeElapsed(0.25).doAfter(function ()
        -- We don't redispatch to the leader in other cases, because rivals ignore their passive abilities.
        local leader = Rival.rivals[color].leader
        return leader.signetRing(color)
    end)
end

return Rival
