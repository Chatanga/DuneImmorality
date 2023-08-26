local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")

local Utils = Module.lazyRequire("Utils")
local Playboard = Module.lazyRequire("Playboard")
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
            Helper.dump("Bad context key:", name, "->", value)
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
function Action.setUp(color, settings)
    Action.resource(color, "water", 1)
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
function Action.sendAgent(color, spaceName)
    Action.context.space = spaceName
    MainBoard.sendAgent(color, spaceName)
end

---
function Action.takeMentat(color)
    local mentat = MainBoard.getMentat()
    if mentat then
        return Park.putObject(mentat, Playboard.getAgentPark(color))
    else
        return false
    end
end

---
function Action.recruitSwordmaster(color)
    return Playboard.recruitSwordmaster(color)
end

---
function Action.takeHighCouncilSeat(color)
    return Playboard.takeHighCouncilSeat(color)
end

---
function Action.resource(color, resourceName, amount)
    Utils.assertIsPlayerColor(color)
    Utils.assertIsResourceName(resourceName)
    Utils.assertIsInteger(amount)

    local resource = Playboard.getResource(color, resourceName)
    if resource:get() >= -amount then
        resource:change(amount)
        return true
    else
        return false
    end
end

---
function Action.drawImperiumCards(color, amount)
    Utils.assertIsPlayerColor(color)
    Playboard.getPlayboard(color):drawCards(amount)
    return true
end

---
function Action.influence(color, faction, amount)
    assert(faction, "Generic action are not supported.")
    return InfluenceTrack.change(color, faction, amount)
end

---
function Action.troops(color, from, to, amount)
    Utils.assertIsPlayerColor(color)
    Utils.assertIsTroopLocation(from)
    Utils.assertIsTroopLocation(to)
    Utils.assertIsInteger(amount)
    return Park.transfert(amount, Action._getTroopPark(color, from), Action._getTroopPark(color, to))
end

---
function Action._getTroopPark(color, parkName)
    if parkName == "supply" then
        return Playboard.getSupplyPark(color)
    elseif parkName == "garrison" then
        return Combat.getGarrisonPark(color)
    elseif parkName == "combat" then
        return nil
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
    return false
end

---
function Action.acquireImperiumCard(color, indexInRow)
    Utils.assertIsPlayerColor(color)
    Utils.assertIsInRange(1, 5, indexInRow)
    return ImperiumRow.acquireImperiumCard(indexInRow, color)
end

---
function Action.acquireFoldspaceCard(color)
    Utils.assertIsPlayerColor(color)
    Reserve.acquireFoldspace(Reserve.foldspace, color)
end

---
function Action.advanceFreighter(color, positiveAmount)
    Utils.assertIsPlayerColor(color)
    Utils.assertIsPositiveInteger(positiveAmount)
    for _ = 1, positiveAmount do
        CommercialTrack.freighterUp(color)
    end
end

---
function Action.recallFreighter(color)
    Utils.assertIsPlayerColor(color)
    return CommercialTrack.freighterReset(color)
end

---
function Action.moveFreighter(color)
    Utils.assertIsPlayerColor(color)
    return CommercialTrack.freighterUp(color)
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
        return Playboard.getDreadnoughtSupplyPark(color)
    elseif parkName == "garrison" then
        return Combat.getDreadnoughtGarrisonPark(color)
    elseif parkName == "combat" then
        return nil
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
    Utils.assertIsInteger(jump)
    TleilaxuResearch.advanceResearch(color, jump)
    return true
end

---
function Action.beetle(color, jump)
    Utils.assertIsPlayerColor(color)
    Utils.assertIsInteger(jump)
    TleilaxuResearch.advanceTleilax(color, jump)
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
    return Intrigue.drawIntrigue(color, amount)
end

---
function Action.stealIntrigue(color, otherColor, amount)
    Utils.assertIsPlayerColor(color)
    Utils.assertIsPlayerColor(otherColor)
    Utils.assertIsInteger(amount)
    return Intrigue.stealIntrigue(color, otherColor, amount)
end

--[[
---
function Action.voiceForbid(color, space)
end

---
function Action.signetRing(color)
end

---
function Action.flagControl(color, space)
end

---
function Action.dreadnoughtControl(color, space)
end

---
function Action.acquireTech(color, name)
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

function Action._positive(message)
    return true
end

function Action._negative(message)
    return false
end

return Action
