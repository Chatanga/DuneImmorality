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
local Hagal = Module.lazyRequire("Hagal")
local TurnControl = Module.lazyRequire("TurnControl")
local SardaukarCommander = Module.lazyRequire("SardaukarCommander")

---@class Action
local Action = Helper.createClass(nil, {
    context = {}
})

---@param state table
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

    if state.settings and state.Action then
        Action.context = state.Action.context
    end
end

function Action.setUp()
    -- NOP
end

---@param state table
function Action.onSave(state)
    state.Action = {
        context = Action.context
    }
end

---@param attributes table<string, any|function>
---@return boolean
function Action.checkContext(attributes)
    for name, expectedValue in pairs(attributes) do
        local value = Action.context and Action.context[name] or nil
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

---@param color PlayerColor
---@param settings Settings
function Action.doSetUp(color, settings)
    -- NOP
end

---@param phase string
---@param isActivePlayer boolean
---@return string?
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

---@param color PlayerColor
---@param settings Settings
function Action.prepare(color, settings)
    -- In the base game, but not in Uprising.
    if Hagal.getRivalCount() == 2 and settings.difficulty == "novice" then
        Action.resources(color, "solari", 1)
        Action.resources(color, "spice", 1)
    end

    Action.resources(color, "water", 1)
    if settings.epicMode then
        Action.drawIntrigues(color, 1)
    end
    Action.troops(color, "supply", "garrison", settings.epicMode and 5 or 3)
end

function Action.tearDown()
end

---@param key string
---@param value any
function Action.setContext(key, value)
    if key == "agentDestination" and Action.troopTransferCoalescentQueue then
        Action.flushTroopTransfer()
    end
    Action.context[key] = value
end

function Action.flushTroopTransfer()
    if Action.troopTransferCoalescentQueue then
        Action.troopTransferCoalescentQueue.flush()
    end
end

---@param message? string
---@param color PlayerColor
---@param isSecret? boolean
function Action.log(message, color, isSecret)
    -- Order matters here.
    -- (But there is only one option with this mod.)
    local logContextPrinters = {
        { name = "agentDestination", print = function (value)
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
            local turnColor = TurnControl.getCurrentPlayer() or "White"
            if Action.lastContext ~= turnColor .. namedPrinter.name then
                Action.lastContext = turnColor .. namedPrinter.name
                printToAll(namedPrinter.print(value), turnColor)
            end
            prefix = " └─ "
            break
        end
    end
    if message then
        if isSecret then
            local player = Helper.findPlayerByColor(color)
            if player and player.seated then
                printToColor(prefix .. message, color, "Grey")
            end
        else
            printToAll(prefix .. message, color)
        end
    end
end

---@param message string
---@param color PlayerColor
function Action.secretLog(message, color)
    Action.log(message, color, true)
end

---@param key string
function Action.unsetContext(key)
    Action.context[key] = nil
end

---@param color PlayerColor
---@param spaceName string
---@return Continuation
function Action.sendAgent(color, spaceName)
    Action.context.space = spaceName
    return MainBoard.sendAgent(color, spaceName)
end

---@param color PlayerColor
---@param anywhere? boolean
---@return boolean
function Action.takeMentat(color, anywhere)
    local mentat = MainBoard.getMentat(anywhere)
    if mentat then
        return Park.putObject(mentat, PlayBoard.getAgentPark(color))
    else
        return false
    end
end

---@param color PlayerColor
---@return boolean
function Action.recruitSwordmaster(color)
    if PlayBoard.recruitSwordmaster(color) then
        Action.log(I18N("recruitSwordmaster"), color)
        return true
    else
        return false
    end
end

---@param color PlayerColor
---@return boolean
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
---@param initialAmount integer
---@return boolean
function Action.resources(color, resourceName, initialAmount)
    assert(Types.isPlayerColor(color))
    assert(Types.isResourceName(resourceName))

    local amount = -Action.bargain(color, resourceName, -initialAmount)

    local resource = PlayBoard.getResource(color, resourceName)
    if resource:get() >= -amount then
        if amount ~= 0 then
            resource:change(amount)
            Action.log(I18N(amount > 0 and "credit" or "debit", {
                what = I18N.agree(amount, resourceName),
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
    assert(Types.isPlayerColor(color))
    assert(Types.isResourceName(resourceName))

    local finalAmount = amount
    if Helper.isElementOf(resourceName, {"spice", "solari"})
        and PlayBoard.hasTech(color, "navigationChamber")
        and amount > 0
        and Action.checkContext({ phase = "playerTurns", color = color, agentDestination = Helper.isNotNil }) then
        finalAmount = amount - 1
    end
    return finalAmount
end

---@param color PlayerColor
---@param amount integer
---@param forced? boolean
---@return Continuation
function Action.drawImperiumCards(color, amount, forced)
    assert(Types.isPlayerColor(color))
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
---@param faction? Faction
---@param amount integer
---@return Continuation
function Action.influence(color, faction, amount)
    assert(Types.isPlayerColor(color))
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
    assert(Types.isPlayerColor(color))
    assert(Types.isTroopLocation(from))
    assert(Types.isTroopLocation(to))
    local count = Park.transfer(baseCount, Action.getTroopPark(color, from), Action.getTroopPark(color, to))
    assert(count)
    assert(type(count) == "number")

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

        Action.troopTransferCoalescentQueue = Helper.createCoalescentQueue("troop", 1, coalesce, handle)
    end

    Action.troopTransferCoalescentQueue.submit({
        color = color,
        count = count,
        from = from,
        to = to,
    })

    return count
end

---@param color PlayerColor
---@param parkName string
---@return Park
function Action.getTroopPark(color, parkName)
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

---@param color PlayerColor
---@param indexInRow integer
---@return boolean
function Action.reserveImperiumCard(color, indexInRow)
    assert(Types.isPlayerColor(color))
    assert(Helper.isInRange(1, 5, indexInRow))
    return ImperiumRow.reserveImperiumCard(indexInRow)
end

---@param color PlayerColor
---@return boolean
function Action.acquireReservedImperiumCard(color)
    assert(Types.isPlayerColor(color))
    return false
end

---@param color PlayerColor
---@param indexInRow integer
---@return boolean
function Action.acquireImperiumCard(color, indexInRow)
    assert(Types.isPlayerColor(color))
    assert(Helper.isInRange(1, 5, indexInRow))
    return ImperiumRow.acquireImperiumCard(indexInRow, color)
end

---@param color PlayerColor
---@return boolean
function Action.acquireFoldspace(color)
    assert(Types.isPlayerColor(color))
    Reserve.acquireFoldspace(color)
    return true
end

---@param color PlayerColor
---@return boolean
function Action.acquireArrakisLiaison(color)
    assert(Types.isPlayerColor(color))
    Reserve.acquireArrakisLiaison(color)
    return true
end

---@param color PlayerColor
---@return boolean
function Action.acquireTheSpiceMustFlow(color)
    assert(Types.isPlayerColor(color))
    Reserve.acquireTheSpiceMustFlow(color)
    return true
end

---@param color PlayerColor
---@param indexInRow integer
---@return boolean
function Action.acquireSardaukarCommanderSkillCard(color, indexInRow)
    assert(Types.isPlayerColor(color))
    assert(Helper.isInRange(1, 4, indexInRow))
    if SardaukarCommander.acquireSardaukarCommanderSkillCard(indexInRow, color) then
        Action.log(I18N("acquireSardaukarCommanderSkillCard"), color)
        return true
    else
        return false
    end
end

---@param color PlayerColor
---@param origin string
---@return boolean
function Action.discardSardaukarCommander(color, origin)
    assert(Types.isPlayerColor(color))
    return SardaukarCommander.discardSardaukarCommander(color, origin)
end

---@param color PlayerColor
---@param origin? string
---@return boolean
function Action.recruitSardaukarCommander(color, origin)
    assert(Types.isPlayerColor(color))
    if origin then
        if SardaukarCommander.recruitSardaukarCommander(color, origin) then
            Action.log(I18N("recruitNewSardaukarCommander"), color)
            return true
        end
    else
        if PlayBoard.recruitSardaukarCommander(color) then
            Action.log(I18N("recruitOwnSardaukarCommander"), color)
            return true
        end
    end
    return false
end

---@param color PlayerColor
---@param positiveAmount integer
---@return boolean
function Action.advanceFreighter(color, positiveAmount)
    assert(Types.isPlayerColor(color))
    assert(positiveAmount > 0)
    for _ = 1, positiveAmount do
        if not ShippingTrack.freighterUp(color) then
            return false
        else
            Action.log(I18N("advanceFreighter"), color)
        end
    end
    return true
end

---@param color PlayerColor
---@return boolean
function Action.recallFreighter(color)
    assert(Types.isPlayerColor(color))
    if ShippingTrack.freighterReset(color) then
        Action.log(I18N("recallFreighter"), color)
        return true
    else
        return false
    end
end

---@param color PlayerColor
---@param amount integer
---@return boolean
function Action.shipments(color, amount)
    assert(Types.isPlayerColor(color))
    return false
end

---@param color PlayerColor
---@param from string 
---@param to string
---@param amount integer
---@return integer
function Action.dreadnought(color, from, to, amount)
    assert(Types.isPlayerColor(color))
    assert(Types.isDreadnoughtLocation(from))
    assert(Types.isDreadnoughtLocation(to))

    local count = Park.transfer(amount, Action.getDreadnoughtPark(color, from), Action.getDreadnoughtPark(color, to))

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

---@param color PlayerColor
---@param parkName string
---@return Park?
function Action.getDreadnoughtPark(color, parkName)
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
    elseif parkName == "imperialBasin" then
        return nil
    else
        error("Unknow park name: " .. tostring(parkName))
    end
end

---@param color PlayerColor
---@param indexInRow integer
function Action.acquireTleilaxuCard(color, indexInRow)
    assert(Types.isPlayerColor(color))
    assert(Helper.isInRange(1, 3, indexInRow))
    TleilaxuRow.acquireTleilaxuCard(indexInRow, color)
    return true
end

---@param color PlayerColor
---@param jump? Vector
---@return boolean
function Action.research(color, jump)
    assert(Types.isPlayerColor(color))
    TleilaxuResearch.advanceResearch(color, jump).doAfter(function (finalJump)
        if finalJump.x > 0 then
            Action.log(I18N("researchAdvance", { count = jump }), color)
        elseif finalJump.x < 0 then
            Action.log(I18N("researchRollback"), color)
        end
    end)
    return true
end

---@param color PlayerColor
---@param jump integer
---@return boolean
function Action.beetle(color, jump)
    assert(Types.isPlayerColor(color))
    TleilaxuResearch.advanceTleilax(color, jump).doAfter(function (finalJump)
        if finalJump > 0 then
            Action.log(I18N("beetleAdvance", { count = jump }), color)
        elseif finalJump < 0 then
            Action.log(I18N("beetleRollback", { count = math.abs(jump) }), color)
        end
    end)
    return true
end

---@param color PlayerColor
---@return boolean
function Action.atomics(color)
    assert(Types.isPlayerColor(color))
    ImperiumRow.nuke()
    Action.log(I18N("atomics"), color)
    return true
end

---@param color PlayerColor
---@param amount integer
---@return boolean
function Action.drawIntrigues(color, amount)
    assert(Types.isPlayerColor(color))
    Intrigue.drawIntrigues(color, amount)
    Action.log(I18N("drawObjects", { amount = amount, object = I18N.agree(amount, "intrigueCard") }), color)
    return true
end

---@param color PlayerColor
---@param otherColor PlayerColor
---@param amount integer
---@return boolean
function Action.stealIntrigues(color, otherColor, amount)
    assert(Types.isPlayerColor(color))
    assert(Types.isPlayerColor(otherColor))
    Intrigue.stealIntrigues(color, otherColor, amount)
    return true
end

---@param color PlayerColor
---@return boolean
function Action.signetRing(color)
    assert(Types.isPlayerColor(color))
    return false
end

---@param color PlayerColor
---@param name string
---@param count integer
---@return boolean
function Action.gainVictoryPoint(color, name, count)
    assert(Types.isPlayerColor(color))
    if ScoreBoard.gainVictoryPoint(color, name, count) then
        for _ = 1, (count or 1) do
            Action.log(I18N("gainVictoryPoint", { name = I18N(name) }), color)
        end
        return true
    else
        return false
    end
end

---@param color PlayerColor
---@param spaceName string
function Action.control(color, spaceName)
    local controlableSpace = MainBoard.findControlableSpace(spaceName)
    if controlableSpace then
        MainBoard.occupy(controlableSpace, color)
        return true
    else
        return false
    end
end

---@param color PlayerColor
---@param stackIndex? integer
---@param discount? integer
---@return boolean
function Action.acquireTech(color, stackIndex, discount)
    assert(Types.isPlayerColor(color))
    if stackIndex then
        TechMarket.acquireTech(stackIndex, color)
        return true
    else
        return false
    end
end

---@param color PlayerColor
---@return boolean
function Action.pickVoice(color)
    assert(Types.isPlayerColor(color))
    local voiceToken = ScoreBoard.getFreeVoiceToken()
    if voiceToken then
        return PlayBoard.acquireVoice(color, voiceToken)
    else
        return false
    end
end

---@param color PlayerColor
---@param topic string
---@return boolean
function Action.randomlyChoose(color, topic)
    return false
end

---@param color PlayerColor
---@param topic string
---@return boolean
function Action.decide(color, topic)
    -- Any reason to disable this for human players,
    -- since optional rewards are always desirable VPs?
    return false
end

return Action
