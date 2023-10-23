local Module = require("utils.Module")
local Helper = require("utils.Helper")

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
local shipments = CardEffect.shipments
local research = CardEffect.research
local beetle = CardEffect.beetle
local influence = CardEffect.influence
local vp = CardEffect.vp
local draw = CardEffect.draw
local shipment = CardEffect.shipment
local mentat = CardEffect.mentat
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
                leader[method](...)
            else
                return false
            end
        end

        if selector == "troop" then
            return call("troops", color, "supply", "garrison", value)
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
            for _ = 1, value do
                call("gainVictoryPoint", color, context.cardName)
            end
            return true
        elseif selector == "draw" then
            return call("drawImperiumCards", color, value)
        elseif selector == "shipment" then
            return call("shipments", color, value)
        elseif selector == "mentat" then
            if call("takeMentat", color) then
                -- FIXME Do it elsewhere.
                MainBoard.getMentat().addTag("notToBeRecalled")
                return true
            else
                return false
            end
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

function CardEffect.shipments(expression)
    return CardEffect._dispatch('shipments', expression)
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
    return function (expression)
        error("TODO")
    end
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
        local count = 0
        for _, card in ipairs(context.revealedCards) do
            if card.reveal and (not cardExcluded or card ~= context.card) then

                if false then
                    local pseudoContext = {
                        fake = true,
                        color = context.color,
                        playedCards = {},
                        revealedCards = { card },
                    }
                    pseudoContext.resources = function (_, selector, n)
                        pseudoContext[selector] = (pseudoContext[selector] or 0) + n
                    end

                    ImperiumCard.evaluateCardRevealEffects(card, pseudoContext)
                end

                -- Special case here of a recursive call.
                local output = ImperiumCard.evaluateReveal(context.color, {}, { card }, false)
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

-- Special functors

function CardEffect.choice(n, options)
    return function (context)
        if not PlayBoard.getLeader(context.color).choose(context.color) then
            local shuffledOptions = Helper.shallowCopy(options)
            Helper.shuffle(shuffledOptions)
            for i = 1, n do
                shuffledOptions[i](context)
            end
        end
        return true
    end
end

function CardEffect.optional(options)
    return function (context)
        if not PlayBoard.getLeader(context.color).decide(context.color) then
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

function CardEffect.seat(expression)
    return function (context)
        return PlayBoard.hasHighCouncilSeat(context.color) and expression or 0
    end
end

function CardEffect.fremenBond(expression)
    return function (context)
        for _, card in ipairs(Helper.concatTables(context.playedCards, context.revealedCards)) do
            if card ~= context.card and card.factions and Helper.isElementOf("fremen", card.factions) then
                return CardEffect.evaluate(context, expression)
            end
        end
        return 0
    end
end

function CardEffect.agentInEmperorSpace(expression)
    return function (context)
        for _, spaceName in ipairs(MainBoard.getEmperorSpaces()) do
            if MainBoard.hasAgentInSpace(spaceName, context.color) then
                return CardEffect.evaluate(context, expression)
            end
        end
        return 0
    end
end

function CardEffect._alliance(faction, expression)
    return function (context)
        if InfluenceTrack.hasAlliance(context.color, faction) then
            return CardEffect.evaluate(context, expression)
        else
            return 0
        end
    end
end

function CardEffect._friendShip(faction, expression)
    return function (context)
        if InfluenceTrack.hasFriendship(context.color, faction) then
            return CardEffect.evaluate(context, expression)
        else
            return 0
        end
    end
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
    return function (context)
        if TleilaxuResearch.hasReachedOneHelix(context.color) then
            return CardEffect.evaluate(context, expression)
        else
            return 0
        end
    end
end

function CardEffect.twoHelices(expression)
    return function (context)
        if TleilaxuResearch.hasReachedTwoHelices(context.color) then
            return CardEffect.evaluate(context, expression)
        else
            return 0
        end
    end
end

function CardEffect.winner(expression)
    return function ()
        error("TODO")
    end
end

return CardEffect
