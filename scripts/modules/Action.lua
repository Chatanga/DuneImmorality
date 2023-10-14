local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")
local I18N = require("utils.I18N")

local Utils = Module.lazyRequire("Utils")
local PlayBoard = Module.lazyRequire("PlayBoard")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")
local Combat = Module.lazyRequire("Combat")
local TleilaxuResearch = Module.lazyRequire("TleilaxuResearch")
local Intrigue = Module.lazyRequire("Intrigue")
local Reserve = Module.lazyRequire("Reserve")
local MainBoard = Module.lazyRequire("MainBoard")
local TechMarket = Module.lazyRequire("TechMarket")
local ImperiumRow = Module.lazyRequire("ImperiumRow")
local CommercialTrack = Module.lazyRequire("CommercialTrack")
local TleilaxuRow = Module.lazyRequire("TleilaxuRow")
local ScoreBoard = Module.lazyRequire("ScoreBoard")

local Action = Helper.createClass(nil, {
    context = {}
})

---
function Action.onLoad()
    Helper.registerEventListener("phaseStart", function (phase, _)
        Action.context = {
            phase = phase
        }
    end)
    Helper.registerEventListener("playerTurns", function (phase, color)
        Action.context = {
            phase = phase,
            color = color
        }
    end)
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
]]--
---
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

---
function Action.instruct(phase, isActivePlayer)
    local instructions = {
        leaderSelection = {
            "Select a leader\non the upper board",
            "Wait for your opponent\nto select their leaders."
        },
        playerTurns = {
            "Send an agent\nor reveal your hand,\nthen press End of Turn.",
            "Wait for your opponent\nto play their\nagent / reveal turn."
        },
        combat = {
            "Play an intrigue and\npress End of Turn or simply\npress End of Turn to pass.",
            "Wait for your opponent\nin combat to play an\nintrigue or pass their turn."
        },
        combatEnd = {
            "Take your reward and play\nintrigue cards if you may,\nthen press End of Turn.",
            "Wait for your opponent\nto collect their reward\nand play any intrigue."
        },
        endgame = {
            "Play any Endgame card and\nTech tile you possess\nto gain final victory points.",
            "Wait for your oppenent\nto play any Endgame card\nor Tech tiles they possess."
        },
    }

    local instruction = instructions[phase]
    if instruction then
        if isActivePlayer then
            return instruction[1]
        else
            return instruction[2]
        end
    else
        return nil
    end
end

---
function Action.prepare(color, settings)

    Action.resources(color, "solari", 0)
    Action.resources(color, "spice", 0)

    Action.resources(color, "water", 1)
    if settings.epicMode then
        Action.troops(color, "supply", "garrison", 5)
        Action.drawIntrigues(color, 1)
    else
        Action.troops(color, "supply", "garrison", 3)
    end
end

---
function Action.tearDown()
end

---
function Action.setContext(key, value)
    Action.context[key] = value or true
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
        return Park.putObject(mentat, PlayBoard.getAgentPark(color))
    else
        return false
    end
end

---
function Action.recruitSwordmaster(color)
    return PlayBoard.recruitSwordmaster(color)
end

---
function Action.takeHighCouncilSeat(color)
    return PlayBoard.takeHighCouncilSeat(color)
end

---
function Action.resources(color, resourceName, amount)
    Utils.assertIsPlayerColor(color)
    Utils.assertIsResourceName(resourceName)
    Utils.assertIsInteger(amount)

    local resource = PlayBoard.getResource(color, resourceName)
    if resource:get() >= -amount then
        resource:change(amount)
        if amount > 0 then
            printToAll(I18N("credit", {
                what = I18N.agree(amount, resourceName),
                amount = amount,
            }), color)
        elseif amount < 0 then
            printToAll(I18N("debit", {
                what = I18N.agree(-amount, resourceName),
                amount = -amount,
            }), color)
        end
        return true
    else
        return false
    end
end

---
function Action.drawImperiumCards(color, amount)
    Utils.assertIsPlayerColor(color)
    PlayBoard.getPlayBoard(color):tryToDrawCards(amount)
    return true
end

---
function Action.influence(color, faction, amount)
    Utils.assertIsPlayerColor(color)
    Utils.assertIsInteger(amount)
    if faction then
        return InfluenceTrack.change(color, faction, amount)
    else
        return Helper.createTermination()
    end
end

---
function Action.troops(color, from, to, baseCount)
    Utils.assertIsPlayerColor(color)
    Utils.assertIsTroopLocation(from)
    Utils.assertIsTroopLocation(to)
    Utils.assertIsInteger(baseCount)
    local count = Park.transfert(baseCount, Action._getTroopPark(color, from), Action._getTroopPark(color, to))

    if not Action.transfetCoalescentQueue then

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
                printToAll(I18N("transfer", {
                    count = t.count,
                    what = I18N.agree(t.count, "troop"),
                    from = I18N(t.from .. "Park"),
                    to = I18N(t.to .. "Park"),
                }), t.color)
            end
        end

        Action.transfetCoalescentQueue = Helper.createCoalescentQueue(1, coalesce, handle)
    end

    Action.transfetCoalescentQueue.submit({
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
    Utils.assertIsPlayerColor(color)
    Utils.assertIsInRange(1, 5, indexInRow)
    return ImperiumRow.reserveImperiumCard(indexInRow, color)
end

---
function Action.acquireReservedImperiumCard(color)
    Utils.assertIsPlayerColor(color)
    return false
end

---
function Action.acquireImperiumCard(color, indexInRow)
    Utils.assertIsPlayerColor(color)
    Utils.assertIsInRange(1, 5, indexInRow)
    return ImperiumRow.acquireImperiumCard(indexInRow, color)
end

---
function Action.acquireFoldspace(color)
    Utils.assertIsPlayerColor(color)
    return Reserve.acquireFoldspace(color)
end

---
function Action.acquireArrakisLiaison(color, toItsHand)
    Utils.assertIsPlayerColor(color)
    return Reserve.acquireArrakisLiaison(color, toItsHand)
end

---
function Action.acquireTheSpiceMustFlow(color)
    Utils.assertIsPlayerColor(color)
    return Reserve.acquireTheSpiceMustFlow(color)
end

---
function Action.advanceFreighter(color, positiveAmount)
    Utils.assertIsPlayerColor(color)
    Utils.assertIsPositiveInteger(positiveAmount)
    for _ = 1, positiveAmount do
        if not CommercialTrack.freighterUp(color) then
            return false
        else
            printToAll(I18N("advanceFreighter"), color)
        end
    end
    return true
end

---
function Action.recallFreighter(color)
    Utils.assertIsPlayerColor(color)
    if CommercialTrack.freighterReset(color) then
        printToAll(I18N("recallFreighter"), color)
        return true
    else
        return false
    end
end

---
function Action.shipments(color, amount)
    Utils.assertIsPlayerColor(color)
    return false
end

---
function Action.dreadnought(color, from, to, amount)
    Utils.assertIsPlayerColor(color)
    Utils.assertIsDreadnoughtLocation(from)
    Utils.assertIsDreadnoughtLocation(to)
    Utils.assertIsInteger(amount)
    return Park.transfert(amount, Action._getDreadnoughtPark(color, from), Action._getDreadnoughtPark(color, to))
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
    Utils.assertIsPlayerColor(color)
    Utils.assertIsInRange(1, 3, indexInRow)
    return TleilaxuRow.acquireTleilaxuCard(indexInRow, color)
end

---
function Action.research(color, jump)
    Utils.assertIsPlayerColor(color)
    TleilaxuResearch.advanceResearch(color, jump).doAfter(function ()
        if jump.x > 0 then
            printToAll(I18N("researchAdvance"), color)
        elseif jump.x < 0 then
            printToAll(I18N("researchRollback"), color)
        end
    end)
    return true
end

---
function Action.beetle(color, jump)
    Utils.assertIsPlayerColor(color)
    Utils.assertIsInteger(jump)
    TleilaxuResearch.advanceTleilax(color, jump).doAfter(function ()
        if jump > 0 then
            printToAll(I18N("beetleAdvance", { jump = jump }), color)
        elseif jump < 0 then
            printToAll(I18N("beetleRollback", { jump = jump }), color)
        end
    end)
    return true
end

---
function Action.atomics(color)
    Utils.assertIsPlayerColor(color)
    ImperiumRow.nuke(color)
    return true
end

---
function Action.drawIntrigues(color, amount)
    Utils.assertIsPlayerColor(color)
    Utils.assertIsInteger(amount)
    Intrigue.drawIntrigue(color, amount)
    printToAll(I18N("drawObjects", { amount = amount, object = I18N.agree(amount, "intrigueCard") }), color)
    return true
end

---
function Action.stealIntrigue(color, otherColor, amount)
    Utils.assertIsPlayerColor(color)
    Utils.assertIsPlayerColor(otherColor)
    Utils.assertIsInteger(amount)
    Intrigue.stealIntrigue(color, otherColor, amount)
    return true
end

---
function Action.signetRing(color)
    Utils.assertIsPlayerColor(color)
    return false
end

---
function Action.gainVictoryPoint(color, name)
    Utils.assertIsPlayerColor(color)
    return ScoreBoard.gainVictoryPoint(color, name)
end

---
function Action.acquireTech(color, stackIndex, discount)
    Utils.assertIsPlayerColor(color)
    if stackIndex then
        TechMarket.acquireTech(stackIndex, color)
        return true
    else
        return false
    end
end

---
function Action.choose(color, topic)
    return false
end

--[[
---
function Action.voiceForbid(color, space)
end

---
function Action.dreadnoughtControl(color, space)
end

---
function Action.acquireTechWithSolari(color, name)
end

---
function Action.destroyTech(color, name)
end

---
function Action.techEffect(color, name)
end

---
function Action.recallSnooper(color, faction)
end

---
function Action.trashImperiumCard(name)
end

---
function Action.reveal(color)
end

---
function Action.discardImperiumCard(name)
end

---
function Action.discardIntrigueCard(name)
end
]]--

return Action
