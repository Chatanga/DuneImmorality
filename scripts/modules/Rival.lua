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
local Combat = Module.lazyRequire("Combat")

---@class Rival: Leader
---@field rivals table<PlayerColor, Rival>
---@field leader Leader
local Rival = Helper.createClass(Action, {
    rivals = {}
})

---@param color PlayerColor
---@param leaderName? string
---@return Rival
function Rival.newRival(color, leaderName)
    assert((leaderName ~= nil) == (Hagal.getRivalCount() == 2))
    local rival = Helper.createClassInstance(Rival, {
        leader = leaderName and Leader.newLeader(leaderName) or Hagal
    })
    rival.name = rival.leader.name -- That's the translated name.
    if Hagal.getRivalCount() == 1 then
        Hagal.relocateDeckZone(PlayBoard.getContent(color).leaderZone)
        rival.recruitSwordmaster(color)
    end
    Rival.rivals[color] = rival
    return rival
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

        if Hagal.getRivalCount() == 2 then
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

    local level3Conflict = Combat.getCurrentConflictLevel() == 3
    local techAvailable = Hagal.ix or Hagal.ixAmbassy

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
    Rival.ix = settings.ix
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

---@param color PlayerColor
---@param factions Faction[]
---@return Faction
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

---@param color PlayerColor
---@param factionOrFactions nil|Faction|Faction[]
---@param amount integer
---@return Continuation
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
        end
        return true
    else
        return false
    end
end

---@param color PlayerColor
---@param topic string
---@return boolean
function Rival.randomlyChoose(color, topic)
    if Helper.isElementOf(topic, { "shuttleFleet", "machinations" }) then
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
    if nature ~= "strength" and Hagal.getRivalCount() == 1 then
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
---@param jump integer
---@return boolean
function Rival.beetle(color, jump)
    assert(Types.isPlayerColor(color))
    if Hagal.getRivalCount() == 2 then
        return Action.beetle(color, jump)
    else
        return false
    end
end

--[[
---@param color PlayerColor
---@param amount integer
---@return boolean
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
]]

---@param color PlayerColor
---@param name string
---@param count integer
---@return boolean
function Rival.gainVictoryPoint(color, name, count)
    -- We make an exception for alliance token to make it clear that the Hagal House owns it.
    if Hagal.getRivalCount() == 2 or Helper.endsWith(name, "Alliance") then
        return Action.gainVictoryPoint(color, name, count)
    else
        return false
    end
end

---@param color PlayerColor
---@return boolean
function Rival.signetRing(color)
    local leader = Rival.rivals[color].leader
    return leader.signetRing(color)
end

return Rival
