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
---@class CardEffect
local CardEffect = {}

---@alias Contributions {
--- strength: integer,
--- persuasion: integer }

---@class CardInfo {
---@field factions Faction[]

---@class Context
---@field player Player
---@field color PlayerColor
---@field card Card
---@field cardName string
---@field playedCards? CardInfo[]
---@field revealedCards? CardInfo[]
---@field oldContributions Contributions
---@field depth integer
---@field persuasion integer
---@field strength integer

--[[
-- Function aliasing for a more readable code.
local todo = CardEffect.todo
local persuasion = CardEffect.persuasion
local sword = CardEffect.sword
local spice = CardEffect.spice
local water = CardEffect.water
local solari = CardEffect.solari
local deploy = CardEffect.deploy
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
local voice = CardEffect.voice
local perDreadnoughtInConflict = CardEffect.perDreadnoughtInConflict
local perSwordCard = CardEffect.perSwordCard
local perFremen = CardEffect.perFremen
local choice = CardEffect.choice
local optional = CardEffect.optional
local seat = CardEffect.seat
local fremenBond = CardEffect.fremenBond
local agentInEmperorSpace = CardEffect.agentInEmperorSpace
local agentInGreenSpace = CardEffect.agentInGreenSpace
local emperorAlliance = CardEffect.emperorAlliance
local spacingGuildAlliance = CardEffect.spacingGuildAlliance
local beneGesseritAlliance = CardEffect.beneGesseritAlliance
local fremenAlliance = CardEffect.fremenAlliance
local emperorSuperFriendship = CardEffect.emperorSuperFriendship
local fremenFriendship = CardEffect.fremenFriendship
local anyAlliance = CardEffect.anyAlliance
local oneHelix = CardEffect.oneHelix
local twoHelices = CardEffect.twoHelices
local swordmaster = CardEffect.swordmaster
local hasSardaukarCommanderInConflict = CardEffect.hasSardaukarCommanderInConflict
local command = CardEffect.command
local garrisonQuad = CardEffect.garrisonQuad
local twoTechs = CardEffect.twoTechs
local multiply = CardEffect.multiply
]]

---@generic X
---@alias XFunction<X> fun(context: Context): X

---@generic Y
---@alias XExpression<Y> Y | fun(context: Context): Y

---@generic Z
---@param context Context
---@param expression? XExpression<Z>
---@return Z
function CardEffect.evaluate(context, expression)
    if expression ~= nil and type(expression) == 'function' then
        return expression(context)
    else
        return expression
    end
end

---@generic T
---@param selector string
---@param expression XExpression<T>
---@return XFunction<boolean>
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

        if selector == "deploy" then
            return call("troops", color, "supply", "combat", value)
        elseif selector == "troop" then
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
            return call("influence", color, selector ~= "?" and selector or nil, value)
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
            assert(not value, tostring(value))
            if call("takeMentat", color) then
                MainBoard.getMentat(true).addTag("notToBeRecalled")
                return true
            else
                return false
            end
        elseif selector == "voice" then
            assert(not value, tostring(value))
            return call("pickVoice", color)
        else
            error("Unknown selector: " .. tostring(selector))
        end
    end
end

-- Effectors

---@param comment string
---@return XFunction<boolean>
function CardEffect.todo(comment)
    return function (_)
        return false
    end
end

---@param expression XExpression<integer>
---@return XFunction<boolean>
function CardEffect.persuasion(expression)
    return CardEffect._dispatch('persuasion', expression)
end

---@param expression XExpression<integer>
---@return XFunction<boolean>
function CardEffect.sword(expression)
    return CardEffect._dispatch('strength', expression)
end

---@param expression XExpression<integer>
---@return XFunction<boolean>
function CardEffect.spice(expression)
    return CardEffect._dispatch('spice', expression)
end

---@param expression XExpression<integer>
---@return XFunction<boolean>
function CardEffect.water(expression)
    return CardEffect._dispatch('water', expression)
end

---@param expression XExpression<integer>
---@return XFunction<boolean>
function CardEffect.solari(expression)
    return CardEffect._dispatch('solari', expression)
end

---@param expression XExpression<integer>
---@return XFunction<boolean>
function CardEffect.deploy(expression)
    return CardEffect._dispatch('deploy', expression)
end

---@param expression XExpression<integer>
---@return XFunction<boolean>
function CardEffect.troop(expression)
    return CardEffect._dispatch('troop', expression)
end

---@param expression XExpression<integer>
---@return XFunction<boolean>
function CardEffect.dreadnought(expression)
    return CardEffect._dispatch('dreadnought', expression)
end

---@param expression XExpression<integer>
---@return XFunction<boolean>
function CardEffect.negotiator(expression)
    return CardEffect._dispatch('negotiator', expression)
end

---@param expression XExpression<integer>
---@return XFunction<boolean>
function CardEffect.specimen(expression)
    return CardEffect._dispatch('specimen', expression)
end

---@param expression XExpression<integer>
---@return XFunction<boolean>
function CardEffect.intrigue(expression)
    return CardEffect._dispatch('intrigue', expression)
end

---@param expression XExpression<integer>
---@return XFunction<boolean>
function CardEffect.trash(expression)
    return CardEffect._dispatch('trash', expression)
end

---@param expression XExpression<integer>
---@return XFunction<boolean>
function CardEffect.research(expression)
    return CardEffect._dispatch('research', expression)
end

---@param expression XExpression<integer>
---@return XFunction<boolean>
function CardEffect.beetle(expression)
    return CardEffect._dispatch('beetle', expression)
end

---@param expression XExpression<integer>
---@return XFunction<boolean>
function CardEffect.influence(expression, faction)
    return CardEffect._dispatch(faction or "?", expression)
end

---@param expression XExpression<integer>
---@return XFunction<boolean>
function CardEffect.vp(expression)
    return CardEffect._dispatch('vp', expression)
end

---@param expression XExpression<integer>
---@return XFunction<boolean>
function CardEffect.draw(expression)
    return CardEffect._dispatch('draw', expression)
end

---@param expression XExpression<integer>
---@return XFunction<boolean>
function CardEffect.shipment(expression)
    return CardEffect._dispatch('shipment', expression)
end

---@return XFunction<boolean>
function CardEffect.mentat()
    return CardEffect._dispatch('mentat', nil)
end

---@param expression XExpression<string>
---@return XFunction<boolean>
function CardEffect.control(expression)
    return CardEffect._dispatch('control', expression)
end

---@return XFunction<boolean>
function CardEffect.voice()
    return CardEffect._dispatch('voice', 0)
end

-- Functors

---@param expression XExpression<integer>
---@return XFunction<integer>
function CardEffect.perDreadnoughtInConflict(expression)
    return function (context)
        return CardEffect.evaluate(context, expression) * Combat.getNumberOfDreadnoughtsInConflict(context.color)
    end
end

---@param expression XExpression<integer>
---@return XFunction<integer>
function CardEffect.perSwordCard(expression, cardExcluded)
    return function (context)
        local swordCount = 0
        if context.oldContributions then
            swordCount = context.oldContributions.strength or 0
        else
            -- Special case here of a recursive call.
            CardEffect._reapply(context, cardExcluded, function (output)
                if output.strength and output.strength > 0 then
                    swordCount = swordCount + 1
                end
            end)
        end
        return CardEffect.evaluate(context, expression) * swordCount
    end
end

---@param expression XExpression<integer>
---@return XFunction<integer>
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

---@param expression XExpression<integer>
---@return XFunction<integer>
function CardEffect.perEmperor(expression)
    return function (context)
        local count = 0
        for _, card in ipairs(Helper.concatTables(context.revealedCards)) do
            if card.factions and Helper.isElementOf("emperor", card.factions) then
                count = count + 1
            end
        end
        return CardEffect.evaluate(context, expression) * count
    end
end

-- Special functors

---@param n integer
---@param options XFunction<boolean>[]
---@return XFunction<boolean>
function CardEffect.choice(n, options)
    return function (context)
        if PlayBoard.getLeader(context.color).randomlyChoose(context.color, context.cardName) then
            local shuffledOptions = Helper.shallowCopy(options)
            Helper.shuffle(shuffledOptions)
            local i = 0
            for  _, option in ipairs(options) do
                if i > n then
                    break
                end
                if option(context) then
                    i = i + 1
                end
            end
            return true
        end
        return false
    end
end

---@param options XFunction<boolean>[]
---@return XFunction<boolean>
function CardEffect.optional(options)
    return function (context)
        if PlayBoard.getLeader(context.color).decide(context.color, context.cardName) then
            for  _, option in ipairs(options) do
                if not option(context) then
                    return false
                end
            end
            return true
        end
        return false
    end
end

-- Filter

---@param expression XExpression<integer>
---@param predicate XFunction<boolean>
---@return XFunction<integer>
function CardEffect._filter(expression, predicate)
    return function (context)
        if predicate(context) then
            return CardEffect.evaluate(context, expression)
        else
            return 0
        end
    end
end

---@param expression XExpression<integer>
---@return XFunction<integer>
function CardEffect.seat(expression)
    return CardEffect._filter(expression, function (context)
        return PlayBoard.hasHighCouncilSeat(context.color)
    end)
end

---@param expression XExpression<integer>
---@return XFunction<integer>
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

---@param expression XExpression<integer>
---@return XFunction<integer>
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

---@param expression XExpression<integer>
---@return XFunction<integer>
function CardEffect.agentInGreenSpace(expression)
    return CardEffect._filter(expression, function (context)
        for _, space in ipairs(MainBoard.getGreenSpaces()) do
            if MainBoard.hasAgentInSpace(space, context.color) then
                return true
            end
        end
        return false
    end)
end

---@param expression XExpression<integer>
---@return XFunction<integer>
function CardEffect._alliance(faction, expression)
    return CardEffect._filter(expression, function (context)
        return InfluenceTrack.hasAlliance(context.color, faction)
    end)
end

---@param expression XExpression<integer>
---@return XFunction<integer>
function CardEffect.emperorAlliance(expression)
    return CardEffect._alliance("emperor", expression)
end

---@param expression XExpression<integer>
---@return XFunction<integer>
function CardEffect.spacingGuildAlliance(expression)
    return CardEffect._alliance("spacingGuild", expression)
end

---@param expression XExpression<integer>
---@return XFunction<integer>
function CardEffect.beneGesseritAlliance(expression)
    return CardEffect._alliance("beneGesserit", expression)
end

---@param expression XExpression<integer>
---@return XFunction<integer>
function CardEffect.fremenAlliance(expression)
    return CardEffect._alliance("fremen", expression)
end

---@param expression XExpression<integer>
---@return XFunction<integer>
function CardEffect._superFriendShip(faction, expression)
    return CardEffect._filter(expression, function (context)
        return InfluenceTrack.hasSuperFriendship(context.color, faction)
    end)
end

---@param expression XExpression<integer>
---@return XFunction<integer>
function CardEffect.emperorSuperFriendship(expression)
    return CardEffect._superFriendShip("emperor", expression)
end

---@param expression XExpression<integer>
---@return XFunction<integer>
function CardEffect._friendShip(faction, expression)
    return CardEffect._filter(expression, function (context)
        return InfluenceTrack.hasFriendship(context.color, faction)
    end)
end

---@param expression XExpression<integer>
---@return XFunction<integer>
function CardEffect.fremenFriendship(expression)
    return CardEffect._friendShip("fremen", expression)
end

---@param expression XExpression<integer>
---@return XFunction<integer>
function CardEffect.anyAlliance(expression)
    return CardEffect.emperorAlliance(expression)
        or CardEffect.spacingGuildAlliance(expression)
        or CardEffect.beneGesseritAlliance(expression)
        or CardEffect.fremenAlliance(expression)
end

---@param expression XExpression<integer>
---@return XFunction<integer>
function CardEffect.oneHelix(expression)
    return CardEffect._filter(expression, function (context)
        return TleilaxuResearch.hasReachedOneHelix(context.color)
    end)
end

---@param expression XExpression<integer>
---@return XFunction<integer>
function CardEffect.twoHelices(expression)
    return CardEffect._filter(expression, function (context)
        return TleilaxuResearch.hasReachedTwoHelices(context.color)
    end)
end

---@param expression XExpression<integer>
---@return XFunction<integer>
function CardEffect.swordmaster(expression)
    return CardEffect._filter(expression, function (context)
        return PlayBoard.hasSwordmaster(context.color)
    end)
end

---@param expression XExpression<integer>
---@return XFunction<integer>
function CardEffect.hasSardaukarCommanderInConflict(expression)
    return CardEffect._filter(expression, function (context)
        return Combat.hasAnySardaukarCommander(context.color)
    end)
end

---@param expression XExpression<integer>
---@return XFunction<integer>
function CardEffect.command(expression)
    return CardEffect._filter(expression, function (context)
        local persuasion = 0
        if context.oldContributions then
            persuasion = context.oldContributions.persuasion or 0
        else
            -- Special case here of a recursive call.
            CardEffect._reapply(context, true, function (output)
                persuasion = persuasion + (output.persuasion or 0)
            end)
        end
        return persuasion >= 6
    end)
end

---@param expression XExpression<integer>
---@return XFunction<integer>
function CardEffect.garrisonQuad(expression)
    return CardEffect._filter(expression, function (context)
        return (Combat.getUnitCounts()[context.color] or 0) >= 4
    end)
end

---@param expression XExpression<integer>
---@return XFunction<integer>
function CardEffect.twoTechs(expression)
    return CardEffect._filter(expression, function (context)
        return #PlayBoard.getAllTechs(context.color) >= 2
    end)
end

---@param ... XExpression<integer>
---@return XFunction<integer>
function CardEffect.multiply(...)
    local expressions = {...}
    return function (context)
        local result = 1
        for _, expression in ipairs(expressions) do
            result = result * CardEffect.evaluate(context, expression)
        end
        return result
    end
end

--- Internal

---@param context Context
---@param cardExcluded boolean
---@param processor fun(context: Context)
---@return boolean
function CardEffect._reapply(context, cardExcluded, processor)
    if not context.depth or context.depth > 1 then
        return false
    end
    local allCards = Set.newFromList(Helper.concatTables(context.playedCards, context.revealedCards))
    for _, card in ipairs(context.revealedCards) do
        ---@cast card ImperiumCardInfo
        if card.reveal and (not cardExcluded or card ~= context.card) then
            local fakePlayedCards = (allCards - Set.newFromItems(card)):toList()
            local output = ImperiumCard.evaluateRevealDirectly(context.depth + 1, context.color, fakePlayedCards, { card })
            processor(output)
        end
    end
    return true
end

return CardEffect
