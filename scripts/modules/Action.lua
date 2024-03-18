local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")
local I18N = require("utils.I18N")

local Types = Module.lazyRequire("Types")
local PlayBoard = Module.lazyRequire("PlayBoard")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")
local Combat = Module.lazyRequire("Combat")
local TleilaxuResearch = Module.lazyRequire("TleilaxuResearch")
local Intrigue = Module.lazyRequire("Intrigue")
local Reserve = Module.lazyRequire("Reserve")
local MainBoard = Module.lazyRequire("MainBoard")
local TechMarket = Module.lazyRequire("TechMarket")
local ImperiumRow = Module.lazyRequire("ImperiumRow")
local ShippingTrack = Module.lazyRequire("ShippingTrack")
local TleilaxuRow = Module.lazyRequire("TleilaxuRow")
local ScoreBoard = Module.lazyRequire("ScoreBoard")

local Action = Helper.createClass(nil, {
    context = {}
})

---
function Action.onLoad(state)
    Helper.registerEventListener("phaseStart", function (phase, _)
        Action.context = {
            phase = phase
        }
    end)

    Helper.registerEventListener("playerTurn", function (phase, color)
        Action.context = {
            phase = phase,
            color = color
        }
        Action.log(I18N("playerTurn", { leader = PlayBoard.getLeaderName(color) }), color)
    end)

    if state.settings then
        assert(state.Action)
        Action.context = state.Action.context
    end
end

---
function Action.onSave(state)
    state.Action = {
        context = Action.context
    }
end

--[[
    space(name)
    imperium_card(name) (< signet)
    intrigue_card(name)
    leader_ability
    influence_track_bonus(faction, level)
    commercial_track_bonus(level)
    research_track_bonus
    tleilaxu_track_bonus
    imperium_card_bonus(card)
    tech_tile_bonus(tech)
    tech_tile_effect(tech)
    conflict_reward(conflict, position)
    flag_control(space)
]]
---
function Action.checkContext(attributes)
    for name, expectedValue in pairs(attributes) do
        local value = Action.context and Action.context[name] or nil
        --Helper.dump("Checking", name, "with value", value or "nil")
        local valid
        if type(expectedValue) == "function" then
            valid = expectedValue(value)
        else
            valid = value == expectedValue
        end
        if not valid then
            return false
        end
    end
    return true
end

---
function Action.setUp(color, settings)
    -- NOP
end

---
function Action.instruct(phase, isActivePlayer)
    local availablePhaseInstructions = {
        leaderSelection = true,
        playerTurns = true,
        combat = true,
        combatEnd = true,
        endgame = true,
    }

    if availablePhaseInstructions[phase] then
        if isActivePlayer then
            return I18N(phase .. "ActiveInstruction")
        else
            return I18N(phase .. "InactiveInstruction")
        end
    else
        return nil
    end
end

function Action.prepare(color, settings)
    Action.resources(color, "water", 1)
    if settings.epicMode then
        Action.drawIntrigues(color, 1)
    end
    Action.troops(color, "supply", "garrison", settings.epicMode and 5 or 3)
end

---
function Action.tearDown()
end

---
function Action.setContext(key, value)
    if key == "agentSent" and Action.troopTransferCoalescentQueue then
        Action.flushTroopTransfer()
    end
    Action.context[key] = value
end

---
function Action.flushTroopTransfer()
    Action.troopTransferCoalescentQueue.flush()
end

---
function Action.log(message, color, isSecret)
    -- Order matters here.
    local logContextPrinters = {
        { name = "schemeTriggered", print = function (_)
            return I18N("triggeringScheme")
        end },
        { name = "agentSent", print = function (value)
            local cards = ""
            for i, card in pairs(value.cards or {}) do
                if i > 1 then
                    cards = cards .. ", "
                end
                cards = cards .. I18N(card)
            end
            return I18N("sendingAgent", { space = I18N(value.space), cards = cards })
        end },
    }
    local prefix = ""
    for _, namedPrinter in ipairs(logContextPrinters) do
        local value = Action.context[namedPrinter.name]
        if value then
            if Action.lastContext ~= namedPrinter.name then
                Action.lastContext = namedPrinter.name
                printToAll(namedPrinter.print(value), color)
            end
            prefix = " └─ "
            break
        end
    end
    if isSecret then
        printToColor(prefix .. message, color, "Grey")
    else
        printToAll(prefix .. message, color)
    end
end

---
function Action.secretLog(message, color)
    Action.log(message, color, true)
end

---
function Action.unsetContext(key)
    Action.context[key] = nil
end

---
function Action.sendAgent(color, spaceName)
    Action.context.space = spaceName
    return MainBoard.sendAgent(color, spaceName)
end

---
function Action.takeMentat(color)
    local mentat = MainBoard.getMentat()
    if mentat then
        Action.log(I18N("takeMentat"), color)
        return Park.putObject(mentat, PlayBoard.getAgentPark(color))
    else
        return false
    end
end

---
function Action.recruitSwordmaster(color)
    if PlayBoard.recruitSwordmaster(color) then
        Action.log(I18N("recruitSwordmaster"), color)
        return true
    else
        return false
    end
end

---
function Action.takeHighCouncilSeat(color)
    if PlayBoard.takeHighCouncilSeat(color) then
        Action.log(I18N("takeHighCouncilSeat"), color)
        return true
    else
        return false
    end
end

---@param color PlayerColor
---@param resourceName ResourceName
---@param amount integer
---@return boolean
function Action.resources(color, resourceName, amount)
    Types.assertIsPlayerColor(color)
    Types.assertIsResourceName(resourceName)
    Types.assertIsInteger(amount)

    local resource = PlayBoard.getResource(color, resourceName)
    if resource:get() >= -amount then
        if amount ~= 0 then
            resource:change(amount)
            Action.log(I18N(amount > 0 and "credit" or "debit", {
                what = I18N.agree(math.abs(amount), resourceName),
                amount = math.abs(amount),
            }), color)
        end
        return true
    else
        return false
    end
end

---@param color PlayerColor
---@param resourceName ResourceName
---@param amount integer
---@return integer
function Action.bargain(color, resourceName, amount)
    Types.assertIsPlayerColor(color)
    Types.assertIsResourceName(resourceName)
    Types.assertIsInteger(amount)

    return amount
end

---
function Action.drawImperiumCards(color, amount, forced)
    Types.assertIsPlayerColor(color)
    local playBoard = PlayBoard.getPlayBoard(color)
    local continuation
    if forced then
        continuation = playBoard:drawCards(amount)
    else
        continuation = playBoard:tryToDrawCards(amount)
    end
    continuation.doAfter(function (dealCardCount)
        if dealCardCount > 0 then
            Action.log(I18N("drawObjects", { amount = dealCardCount, object = I18N.agree(dealCardCount, "imperiumCard") }), color)
        end
    end)
    return continuation
end

---@param color PlayerColor
---@param faction Faction
---@param amount integer
---@return Continuation
function Action.influence(color, faction, amount)
    Types.assertIsPlayerColor(color)
    Types.assertIsInteger(amount)
    local continuation = Helper.createContinuation("Action.influence")
    if faction then
        InfluenceTrack.change(color, faction, amount).doAfter(function (realAmount)
            Action.log(I18N(amount > 0 and "gainInfluence" or "loseInfluence", {
                withFaction = I18N(Helper.toCamelCase("with", faction)),
                amount = math.abs(amount),
            }), color)
            continuation.run(realAmount)
        end)
    else
        continuation.run(0)
    end
    return continuation
end

---@param color PlayerColor
---@param from TroopLocation
---@param to TroopLocation
---@param baseCount integer
---@return integer
function Action.troops(color, from, to, baseCount)
    Types.assertIsPlayerColor(color)
    Types.assertIsTroopLocation(from)
    Types.assertIsTroopLocation(to)
    Types.assertIsInteger(baseCount)
    local count = Park.transfert(baseCount, Action._getTroopPark(color, from), Action._getTroopPark(color, to))

    if not Action.troopTransferCoalescentQueue then

        local function coalesce(t1, t2)
            if t1.color == t2.color then
                local t
                if t1.from == t2.from and t1.to == t2.to then
                    t1.count = t1.count + t2.count
                    t = t1
                elseif t1.from == t2.to and t1.to == t2.from then
                    t1.count = t1.count - t2.count
                    t = t1
                end
                if t then
                    if t1.count < 0 then
                        t1.count = -t1.count
                        local tmp = t1.to
                        t1.to = t1.from
                        t1.from = tmp
                    end
                    return t
                end
            end
            return nil
        end

        local function handle(t)
            if t.count ~= 0 then
                Action.log(I18N("transfer", {
                    count = t.count,
                    what = I18N.agree(t.count, "troop"),
                    from = I18N(t.from .. "Park"),
                    to = I18N(t.to .. "Park"),
                }), t.color)
            end
        end

        Action.troopTransferCoalescentQueue = Helper.createCoalescentQueue(1, coalesce, handle)
    end

    Action.troopTransferCoalescentQueue.submit({
        color = color,
        count = count,
        from = from,
        to = to,
    })

    return count
end

---
function Action._getTroopPark(color, parkName)
    if parkName == "supply" then
        return PlayBoard.getSupplyPark(color)
    elseif parkName == "garrison" then
        return Combat.getGarrisonPark(color)
    elseif parkName == "combat" then
        return Combat.getBattlegroundPark()
    elseif parkName == "negotiation" then
        return TechMarket.getNegotiationPark(color)
    elseif parkName == "tanks" then
        return TleilaxuResearch.getTankPark(color)
    else
        error("Unknow park name: " .. tostring(parkName))
    end
end

---
function Action.reserveImperiumCard(color, indexInRow)
    Types.assertIsPlayerColor(color)
    Types.assertIsInRange(1, 5, indexInRow)
    return ImperiumRow.reserveImperiumCard(indexInRow, color)
end

---
function Action.acquireReservedImperiumCard(color)
    Types.assertIsPlayerColor(color)
    return false
end

---
function Action.acquireImperiumCard(color, indexInRow)
    Types.assertIsPlayerColor(color)
    Types.assertIsInRange(1, 5, indexInRow)
    return ImperiumRow.acquireImperiumCard(indexInRow, color)
end

---
function Action.acquireFoldspace(color)
    Types.assertIsPlayerColor(color)
    return Reserve.acquireFoldspace(color)
end

---
function Action.acquireArrakisLiaison(color, toItsHand)
    Types.assertIsPlayerColor(color)
    return Reserve.acquireArrakisLiaison(color, toItsHand)
end

---
function Action.acquireTheSpiceMustFlow(color)
    Types.assertIsPlayerColor(color)
    return Reserve.acquireTheSpiceMustFlow(color)
end

---
function Action.advanceFreighter(color, positiveAmount)
    Types.assertIsPlayerColor(color)
    Types.assertIsPositiveInteger(positiveAmount)
    for _ = 1, positiveAmount do
        if not ShippingTrack.freighterUp(color) then
            return false
        else
            Action.log(I18N("advanceFreighter"), color)
        end
    end
    return true
end

---
function Action.recallFreighter(color)
    Types.assertIsPlayerColor(color)
    if ShippingTrack.freighterReset(color) then
        Action.log(I18N("recallFreighter"), color)
        return true
    else
        return false
    end
end

---
function Action.shipments(color, amount)
    Types.assertIsPlayerColor(color)
    return false
end

---
function Action.dreadnought(color, from, to, amount)
    Types.assertIsPlayerColor(color)
    Types.assertIsDreadnoughtLocation(from)
    Types.assertIsDreadnoughtLocation(to)
    Types.assertIsInteger(amount)

    local count = Park.transfert(amount, Action._getDreadnoughtPark(color, from), Action._getDreadnoughtPark(color, to))

    if count > 0 then
        Action.log(I18N("transfer", {
            count = count,
            what = I18N.agree(count, "dreadnought"),
            from = I18N(from .. "Park"),
            to = I18N(to .. "Park"),
        }), color)
    end

    return count
end

---
function Action._getDreadnoughtPark(color, parkName)
    if parkName == "supply" then
        return PlayBoard.getDreadnoughtPark(color)
    elseif parkName == "garrison" then
        return Combat.getDreadnoughtPark(color)
    elseif parkName == "combat" then
        return Combat.getBattlegroundPark()
    elseif parkName == "carthag" then
        return nil
    elseif parkName == "arrakeen" then
        return nil
    elseif parkName == "imperialBassin" then
        return nil
    else
        error("Unknow park name: " .. tostring(parkName))
    end
end

---
function Action.acquireTleilaxuCard(color, indexInRow)
    Types.assertIsPlayerColor(color)
    Types.assertIsInRange(1, 3, indexInRow)
    return TleilaxuRow.acquireTleilaxuCard(indexInRow, color)
end

---
function Action.research(color, jump)
    Types.assertIsPlayerColor(color)
    if jump then
        TleilaxuResearch.advanceResearch(color, jump).doAfter(function (finalJump)
            if finalJump.x > 0 then
                Action.log(I18N("researchAdvance", { count = jump }), color)
            elseif finalJump.x < 0 then
                Action.log(I18N("researchRollback"), color)
            end
        end)
        return true
    else
        return false
    end
end

---
function Action.beetle(color, jump)
    Types.assertIsPlayerColor(color)
    Types.assertIsInteger(jump)
    TleilaxuResearch.advanceTleilax(color, jump).doAfter(function (finalJump)
        if finalJump > 0 then
            Action.log(I18N("beetleAdvance", { count = jump }), color)
        elseif finalJump < 0 then
            Action.log(I18N("beetleRollback", { count = math.abs(jump) }), color)
        end
    end)
    return true
end

---
function Action.atomics(color)
    Types.assertIsPlayerColor(color)
    ImperiumRow.nuke(color)
    Action.log(I18N("atomics"), color)
    return true
end

---
function Action.drawIntrigues(color, amount)
    Types.assertIsPlayerColor(color)
    Types.assertIsInteger(amount)
    Intrigue.drawIntrigue(color, amount)
    Action.log(I18N("drawObjects", { amount = amount, object = I18N.agree(amount, "intrigueCard") }), color)
    return true
end

---
function Action.stealIntrigue(color, otherColor, amount)
    Types.assertIsPlayerColor(color)
    Types.assertIsPlayerColor(otherColor)
    Types.assertIsInteger(amount)
    Intrigue.stealIntrigue(color, otherColor, amount)
    return true
end

---
function Action.signetRing(color)
    Types.assertIsPlayerColor(color)
    return false
end

---
function Action.gainVictoryPoint(color, name, count)
    Types.assertIsPlayerColor(color)
    if ScoreBoard.gainVictoryPoint(color, name, count) then
        for _ = 1, (count or 1) do
            Action.log(I18N("gainVictoryPoint", { name = I18N(name) }), color)
        end
        return true
    else
        return false
    end
end

---
function Action.acquireTech(color, stackIndex, discount)
    Types.assertIsPlayerColor(color)
    if stackIndex then
        TechMarket.acquireTech(stackIndex, color)
        return true
    else
        return false
    end
end

---
function Action.pickVoice(color)
    Types.assertIsPlayerColor(color)
    local voiceToken = ScoreBoard.getFreeVoiceToken()
    if voiceToken then
        return PlayBoard.acquireVoice(color, voiceToken)
    else
        return false
    end
end

---
function Action.choose(color, topic)
    return false
end

---
function Action.decide(color, topic)
    -- Any reason to disable this for human players,
    -- since optional rewards are always desirable VPs?
    return false
end

return Action
