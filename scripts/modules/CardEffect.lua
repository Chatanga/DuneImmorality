local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Set = require("utils.Set")

local InfluenceTrack = Module.lazyRequire("InfluenceTrack")
local Combat = Module.lazyRequire("Combat")
local MainBoard = Module.lazyRequire("MainBoard")
local TleilaxuResearch = Module.lazyRequire("TleilaxuResearch")
local PlayBoard = Module.lazyRequire("PlayBoard")
local ImperiumCard = Module.lazyRequire("ImperiumCard")

--[[
    Save some helping functions such as "perSwordCard", the intent of this
    module is to allow a compact, terse writing style for card effects.
]]
local CardEffect = {}

---@class Context
---@field player any
---@field color table
---@field card any
---@field cardName string
---@field playedCards any[]?
---@field revealedCards any[]?

--[[
-- Function aliasing for a more readable code.
local persuasion = CardEffect.persuasion
local sword = CardEffect.sword
local spice = CardEffect.spice
local water = CardEffect.water
local solari = CardEffect.solari
local troop = CardEffect.troop
local dreadnought = CardEffect.dreadnought
local negotiator = CardEffect.negotiator
local specimen = CardEffect.specimen
local intrigue = CardEffect.intrigue
local trash = CardEffect.trash
local research = CardEffect.research
local beetle = CardEffect.beetle
local influence = CardEffect.influence
local vp = CardEffect.vp
local draw = CardEffect.draw
local shipment = CardEffect.shipment
local mentat = CardEffect.mentat
local control = CardEffect.control
local spy = CardEffect.spy
local contract = CardEffect.contract
local voice = CardEffect.voice
local perDreadnoughtInConflict = CardEffect.perDreadnoughtInConflict
local perSwordCard = CardEffect.perSwordCard
local perFremen = CardEffect.perFremen
local choice = CardEffect.choice
local optional = CardEffect.optional
local seat = CardEffect.seat
local fremenBond = CardEffect.fremenBond
local agentInEmperorSpace = CardEffect.agentInEmperorSpace
local emperorAlliance = CardEffect.emperorAlliance
local spacingGuildAlliance = CardEffect.spacingGuildAlliance
local beneGesseritAlliance = CardEffect.beneGesseritAlliance
local fremenAlliance = CardEffect.fremenAlliance
local fremenFriendship = CardEffect.fremenFriendship
local anyAlliance = CardEffect.anyAlliance
local oneHelix = CardEffect.oneHelix
local twoHelices = CardEffect.twoHelices
local winner = CardEffect.winner
local twoSpies = CardEffect.twoSpies
local spyMakerSpace = CardEffect.spyMakerSpace
local swordmaster = CardEffect.swordmaster
]]

---@param context Context
---@param expression any
---@return boolean
function CardEffect.evaluate(context, expression)
    if type(expression) == 'function' then
        return expression(context)
    else
        return expression
    end
end

function CardEffect._dispatch(selector, expression)
    return function (context)
        local color = context.color
        local value = CardEffect.evaluate(context, expression)
        local leader = context.player
        local call = function (method, ...)
            if leader[method] then
                return leader[method](...)
            else
                return false
            end
        end

        if selector == "troop" then
            return call("troops", color, "supply", "garrison", value)
        elseif selector == "negotiator" then
            return call("troops", color, "supply", "negotiation", value)
        elseif selector == "specimen" then
            return call("troops", color, "supply", "tanks", value)
        elseif selector == "dreadnought" then
            return call("dreadnought", color, "supply", "garrison", value)
        elseif Helper.isElementOf(selector, { "spice", "water", "solari" }) then
            return call("resources", color, selector, value)
        elseif Helper.isElementOf(selector, { "persuasion", "strength" }) then
            return call("resources", color, selector, value)
        elseif selector == "intrigue" then
            return call("drawIntrigues", color, value)
        elseif selector == "trash" then
            return false
        elseif Helper.isElementOf(selector, { "emperor", "spacingGuild", "beneGesserit", "fremen", "?" }) then
            local faction = selector
            if selector == "?" then
                faction = nil
            end
            return call("influence", color, faction, value)
        elseif selector == "vp" then
            call("gainVictoryPoint", color, context.cardName, value)
            return true
        elseif selector == "control" then
            return call("control", color, expression)
        elseif selector == "draw" then
            return call("drawImperiumCards", color, value)
        elseif selector == "shipment" then
            return call("shipments", color, value)
        elseif selector == "research" then
            --return call("research", color, value)
            return false
        elseif selector == "beetle" then
            return call("beetle", color, value)
        elseif selector == "mentat" then
            if call("takeMentat", color) then
                -- FIXME Do it elsewhere.
                MainBoard.getMentat().addTag("notToBeRecalled")
                return true
            else
                return false
            end
        elseif selector == "spy" then
            assert(type(value) == "number")
            if value >= 0 then
                for _ = 1, value do
                    call("sendSpy", color)
                end
                return true
            else
                local recallableSpies = MainBoard.findRecallableSpies(color)
                if #recallableSpies >= -value then
                    for _, otherObservationPostName in ipairs(recallableSpies) do
                        MainBoard.recallSpy(color, otherObservationPostName)
                    end
                    return true
                else
                    return false
                end
            end
        elseif selector == "contract" then
            assert(not value or value == 1, tostring(value))
            return call("pickContract", color)
        elseif selector == "voice" then
            assert(not value, tostring(value))
            return call("pickVoice", color)
        else
            error("Unknown selector: " .. tostring(selector))
        end
    end
end

-- Effectors

function CardEffect.persuasion(expression)
    return CardEffect._dispatch('persuasion', expression)
end

function CardEffect.sword(expression)
    return CardEffect._dispatch('strength', expression)
end

function CardEffect.spice(expression)
    return CardEffect._dispatch('spice', expression)
end

function CardEffect.water(expression)
    return CardEffect._dispatch('water', expression)
end

function CardEffect.solari(expression)
    return CardEffect._dispatch('solari', expression)
end

function CardEffect.troop(expression)
    return CardEffect._dispatch('troop', expression)
end

function CardEffect.dreadnought(expression)
    return CardEffect._dispatch('dreadnought', expression)
end

function CardEffect.negotiator(expression)
    return CardEffect._dispatch('negotiator', expression)
end

function CardEffect.specimen(expression)
    return CardEffect._dispatch('specimen', expression)
end

function CardEffect.intrigue(expression)
    return CardEffect._dispatch('intrigue', expression)
end

function CardEffect.trash(expression)
    return CardEffect._dispatch('trash', expression)
end

function CardEffect.research(expression)
    return CardEffect._dispatch('research', expression)
end

function CardEffect.beetle(expression)
    return CardEffect._dispatch('beetle', expression)
end

function CardEffect.influence(expression, faction)
    return CardEffect._dispatch(faction or "?", expression)
end

function CardEffect.vp(expression)
    return CardEffect._dispatch('vp', expression)
end

function CardEffect.draw(expression)
    return CardEffect._dispatch('draw', expression)
end

function CardEffect.shipment(expression)
    return CardEffect._dispatch('shipment', expression)
end

function CardEffect.mentat()
    return function (expression)
        return CardEffect._dispatch('mentat', expression)
    end
end

function CardEffect.control(space)
    return CardEffect._dispatch('control', space)
end

function CardEffect.spy(expression)
    return CardEffect._dispatch('spy', expression)
end

function CardEffect.contract(expression)
    return CardEffect._dispatch('contract', expression)
end

function CardEffect.voice(expression)
    return CardEffect._dispatch('voice', expression)
end

-- Functors

function CardEffect.perDreadnoughtInConflict(expression)
    return function (context)
        return CardEffect.evaluate(context, expression) * Combat.getNumberOfDreadnoughtsInConflict(context.color)
    end
end

function CardEffect.perSwordCard(expression, cardExcluded)
    return function (context)
        if context.fake then
            return 0
        end
        local allCards = Set.newFromList(Helper.concatTables(context.playedCards, context.revealedCards))
        local count = 0
        for _, card in ipairs(context.revealedCards) do
            if card.reveal and (not cardExcluded or card ~= context.card) then
                -- Special case here of a recursive call.
                local fakePlayedCards = (allCards - Set.newFromItems(card)):toList()
                local output = ImperiumCard.evaluateReveal2(context.color, fakePlayedCards, { card }, false)
                if output.strength and output.strength > 0 then
                    count = count + 1
                end
            end
        end
        return CardEffect.evaluate(context, expression) * count
    end
end

function CardEffect.perFremen(expression)
    return function (context)
        local count = 0
        for _, card in ipairs(Helper.concatTables(context.playedCards, context.revealedCards)) do
            if card.factions and Helper.isElementOf("fremen", card.factions) then
                count = count + 1
            end
        end
        return CardEffect.evaluate(context, expression) * count
    end
end

function CardEffect.perEmperor(expression)
    return function (context)
        local count = 0
        for _, card in ipairs(Helper.concatTables(context.playedCards, context.revealedCards)) do
            if card.factions and Helper.isElementOf("emperor", card.factions) then
                count = count + 1
            end
        end
        return CardEffect.evaluate(context, expression) * count
    end
end

function CardEffect.perFulfilledContract(expression)
    return function (context)
        local count = PlayBoard.getCompletedContractCount(context.color)
        return CardEffect.evaluate(context, expression) * count
    end
end

-- Special functors

function CardEffect.choice(n, options)
    return function (context)
        PlayBoard.getLeader(context.color).choose(context.color, context.cardName)
        return true
    end
end

function CardEffect.optional(options)
    return function (context)
        if PlayBoard.getLeader(context.color).decide(context.color, context.cardName) then
            for  _, option in ipairs(options) do
                if not option(context) then
                    return false
                end
            end
            return true
        else
            return false
        end
    end
end

-- Filter

function CardEffect._filter(expression, predicate)
    return function (context)
        return predicate(context) and CardEffect.evaluate(context, expression) or 0
    end
end

function CardEffect.seat(expression)
    return CardEffect._filter(expression, function (context)
        return PlayBoard.hasHighCouncilSeat(context.color)
    end)
end

function CardEffect.fremenBond(expression)
    return CardEffect._filter(expression, function (context)
        for _, card in ipairs(Helper.concatTables(context.playedCards, context.revealedCards)) do
            if card ~= context.card and card.factions and Helper.isElementOf("fremen", card.factions) then
                return true
            end
        end
        return false
    end)
end

function CardEffect.agentInEmperorSpace(expression)
    return CardEffect._filter(expression, function (context)
        for _, space in ipairs(MainBoard.getEmperorSpaces()) do
            if MainBoard.hasAgentInSpace(space, context.color) then
                return true
            end
        end
        return false
    end)
end

function CardEffect._alliance(faction, expression)
    return CardEffect._filter(expression, function (context)
        return InfluenceTrack.hasAlliance(context.color, faction)
    end)
end

function CardEffect.emperorAlliance(expression)
    return CardEffect._alliance("emperor", expression)
end

function CardEffect.spacingGuildAlliance(expression)
    return CardEffect._alliance("spacingGuild", expression)
end

function CardEffect.beneGesseritAlliance(expression)
    return CardEffect._alliance("beneGesserit", expression)
end

function CardEffect.fremenAlliance(expression)
    return CardEffect._alliance("fremen", expression)
end

function CardEffect._friendShip(faction, expression)
    return CardEffect._filter(expression, function (context)
        return InfluenceTrack.hasFriendship(context.color, faction)
    end)
end

function CardEffect.fremenFriendship(expression)
    return CardEffect._friendShip("fremen", expression)
end

function CardEffect.anyAlliance(expression)
    return CardEffect.emperorAlliance(expression)
        or CardEffect.spacingGuildAlliance(expression)
        or CardEffect.beneGesseritAlliance(expression)
        or CardEffect.fremenAlliance(expression)
end

function CardEffect.oneHelix(expression)
    return CardEffect._filter(expression, function (context)
        return TleilaxuResearch.hasReachedOneHelix(context.color)
    end)
end

function CardEffect.twoHelices(expression)
    return CardEffect._filter(expression, function (context)
        return TleilaxuResearch.hasReachedTwoHelices(context.color)
    end)
end

function CardEffect.winner(expression)
    return function ()
        error("TODO")
    end
end

function CardEffect.twoSpies(expression)
    return CardEffect._filter(expression, function (context)
        return MainBoard.getDeployedSpyCount(context.color) >= 2
    end)
end

function CardEffect.spyMakerSpace(expression)
    return CardEffect._filter(expression, function (context)
        return MainBoard.getDeployedSpyCount(context.color, true) > 0
    end)
end

function CardEffect.swordmaster(expression)
    return CardEffect._filter(expression, function (context)
        return PlayBoard.hasSwordmaster(context.color)
    end)
end

return CardEffect
