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
local Types = Module.lazyRequire("Types")
local Leader = Module.lazyRequire("Leader")

local Rival = Helper.createClass(Action, {
    rivals = {}
})

function Rival.newRival(color, leaderName, riseOfIx)
    local rival = Helper.createClassInstance(Rival, {
        leader = leaderName and Leader.newLeader(leaderName) or Hagal,
    })
    rival.name = rival.leader.name
    if Hagal.getRivalCount() == 1 then
        assert(leaderName == nil)
        Hagal.relocateDeckZone(PlayBoard.getContent(color).leaderZone)
        rival.recruitSwordmaster(color)
    else
        assert(leaderName)
    end
    Rival.rivals[color] = rival
    return rival
end

function Rival.triggerHagalReaction(color)
    Helper.dumpFunction("Rival.triggerHagalReaction", color)
    local continuation = Helper.createContinuation("Rival.triggerHagalReaction")

    local coroutineHolder = {}
    coroutineHolder.coroutine = Helper.registerGlobalCallback(function ()
        assert(coroutineHolder.coroutine)
        Helper.unregisterGlobalCallback(coroutineHolder.coroutine)

        Helper.sleep(1)

        local rival = PlayBoard.getLeader(color)

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

        if hasSwordmaster then
            Rival._buyVictoryPoints(color)
        end

        continuation.run()

        return 1
    end)
    startLuaCoroutine(Global, coroutineHolder.coroutine)

    return continuation
end

function Rival._buyVictoryPoints(color)
    -- Do not use Rival.resources inside this function!

    local rival = PlayBoard.getLeader(color)

    if Hagal.getRivalCount() == 1 then
        return
    end

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

        if Hagal.riseOfIx then
            local tech = PlayBoard.getTech(color, "spySatellites")
            if tech and Action.resources(color, "spice", -3) then
                MainBoard.trash(tech)
                Rival.gainVictoryPoint(color, "spySatellites", 1)
                goto continue
            end
        else
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

function Rival.prepare(color, settings)
    Rival.riseOfIx = settings.riseOfIx
    -- Note: Rabban as a rival has no additional resources (https://boardgamegeek.com/thread/2570879/article/36734124#36734124).
    local rivalCount = Hagal.getRivalCount()
    if rivalCount == 1 then
        Action.resources(color, "water", 1)
        Action.troops(color, "supply", "garrison", 3)
    else
        assert(rivalCount == 2)
        Action.resources(color, "water", 1)
        if settings.difficulty ~= "novice" then
            Action.troops(color, "supply", "garrison", 3)
            -- Not in Uprising:
            Action.drawIntrigues(color, 1)
        end
    end
end

function Rival._removeBestFaction(color, factions)
    Helper.shuffle(factions)
    table.sort(factions, function (f1, f2)
        local i1 = InfluenceTrack.getInfluence(f1, color)
        local i2 = InfluenceTrack.getInfluence(f2, color)
        return i1 < i2
    end)
    local bestFaction = factions[1]
    table.remove(factions, 1)
    return bestFaction
end

function Rival.influence(color, factionOrFactions, amount)
    local finalFaction
    if not factionOrFactions or type(factionOrFactions) == "table" then
        local factions = factionOrFactions
        if not factions then
            factions = { "emperor", "spacingGuild", "beneGesserit", "fremen" }
        end
        finalFaction = Rival._removeBestFaction(color, factions)
    else
        finalFaction = factionOrFactions
    end
    return Action.influence(color, finalFaction, amount)
end

function Rival.unused__gainAllianceIfAble(color, amount)
    local factions = {}
    for _, faction in ipairs({ "emperor", "spacingGuild", "beneGesserit", "fremen" }) do
        local cost = InfluenceTrack.getAllianceCost(color, faction)
        if cost <= amount then
            table.insert(factions, faction)
        end
    end
    Rival.influence(color, #factions > 0 and factions or nil, amount)
end

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

function Rival.acquireTech(color, stackIndex)

    local finalStackIndex = stackIndex
    if not finalStackIndex then
        local discount = TechMarket.getRivalSpiceDiscount()
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
            finalStackIndex = bestTechIndex
        else
            return false
        end
    end

    local techDetails = TechMarket.getTopCardDetails(finalStackIndex)
    if Action.acquireTech(color, finalStackIndex) then
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

function Rival.choose(color, topic)
    if Helper.isElementOf(topic, { "shuttleFleet", "machinations" }) then
        local factions = { "emperor", "spacingGuild", "beneGesserit", "fremen" }
        Helper.repeatChainedAction(2, function ()
            return Rival.influence(color, factions, 1)
        end)
        return true
    elseif Helper.isElementOf(topic, { "geneLockedVault" }) then
        return Rival.drawIntrigues(color, 1)
    else
        return false
    end
end

function Rival.decide(color, topic)
    return true
end

function Rival.resources(color, nature, amount)
    if nature ~= "strength" and Hagal.getRivalCount() == 1 then
        return false
    else
        return Action.resources(color, nature, amount)
    end
end

function Rival.troops(color, from, to, baseCount)
    local finalCount = baseCount
    if from == "garrison" and to == "combat" then
        local garrison = Action.getTroopPark(color, "garrison")
        local sardaukarCommanders = Park.getObjects(garrison, function (object, tags)
            return Types.isSardaukarCommander(object, color)
        end)
        local count = #sardaukarCommanders
        if count > 0 then
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

function Rival.beetle(color, jump)
    assert(Types.isPlayerColor(color))
    if Hagal.getRivalCount() == 2 then
        return Action.beetle(color, jump)
    else
        return false
    end
end

function Rival.drawIntrigues(color, amount)
    if Action.drawIntrigues(color, amount) then
        Helper.onceTimeElapsed(1).doAfter(function ()
            local intrigues = PlayBoard.getIntrigues(color)
            if #intrigues >= 3 then
                for i = 1, 3 do
                    Intrigue.discard(intrigues[i])
                end
                Rival.gainVictoryPoint(color, "intrigue", 1)
            end
        end)
        return true
    else
        return false
    end
end

function Rival.gainVictoryPoint(color, name, count)
    -- We make an exception for alliance token to make it clear that the Hagal House owns it.
    if Hagal.getRivalCount() == 2 or Helper.endsWith(name, "Alliance") then
        return Action.gainVictoryPoint(color, name, count)
    else
        return false
    end
end

function Rival.signetRing(color)
    local leader = Rival.rivals[color].leader
    return leader.signetRing(color)
end

return Rival
