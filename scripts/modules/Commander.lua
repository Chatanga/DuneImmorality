local Module = require("utils.Module")
local Helper = require("utils.Helper")

local Action = Module.lazyRequire("Action")

local Commander = Helper.createClass(Action, {
    leaders = {},
    activatedAllies = {},
})

---
function Commander.isCommander(color)
    return color == "Brown" or color == "Teal"
end

---
function Commander.isAlly(color)
    return not Commander.isCommander(color)
end

---
function Commander.getAllies(color)
    if color == "Brown" then
        return { "Blue", "Red" }
    elseif color == "Teal" then
        return { "Yellow", "Green" }
    else
        return nil
    end
end

---
function Commander.getLeftSeatedAlly(color)
    if color == "Brown" then
        return "Blue"
    elseif color == "Teal" then
        return "Green"
    else
        return nil
    end
end

---
function Commander.getRightSeatedAlly(color)
    if color == "Brown" then
        return "Red"
    elseif color == "Teal" then
        return "Yellow"
    else
        return nil
    end
end

---
function Commander.getOtherAlly(color)
    if color == "Blue" then
        return "Red"
    elseif color == "Red" then
        return "Blue"
    elseif color == "Yellow" then
        return "Green"
    elseif color == "Green" then
        return "Yellow"
    else
        return nil
    end
end

---
function Commander.getCommander(color)
    if Helper.isElementOf(color, { "Blue", "Red" }) then
        return "Brown"
    elseif Helper.isElementOf(color, { "Yellow", "Green" }) then
        return "Teal"
    else
        return nil
    end
end

---
function Commander.isShaddam(color)
    return color == "Brown"
end

---
function Commander.isTeamShaddam(color)
    return color == "Red" or color == "Blue" or color == "Brown"
end

---
function Commander.getShaddamTeam()
    return { "Brown", "Red", "Blue" }
end

---
function Commander.isMuadDib(color)
    return color == "Teal"
end

---
function Commander.isTeamMuabDib(color)
    return color == "Green" or color == "Yellow" or color == "Teal"
end

---
function Commander.getMuadDibTeam()
    return { "Teal", "Green", "Yellow" }
end

---
function Commander.newCommander(color, leader)
    assert(Commander.isCommander(color))
    local commander = Helper.createClassInstance(Commander, {})
    Commander.leaders[color] = leader
    return commander
end

---
function Commander.setActivatedAlly(color, allyColor)
    assert(Commander.isCommander(color))
    assert(not allyColor or Commander.isAlly(allyColor))
    Commander.activatedAllies[color] = allyColor
    Helper.emitEvent("selectAlly", color, allyColor)
end

---
function Commander.getActivatedAlly(color)
    return Commander.activatedAllies[color]
end

---
function Commander.prepare(color, settings)
    Commander.leaders[color].prepare(color, settings, true)
end

---
function Commander.takeMakerHook(color)
    return false
end

---
function Commander.callSandworm(color, count)
    return Action.callSandworm(Commander.getActivatedAlly(color), count)
end

---
function Commander.influence(color, faction, amount, forced)
    Helper.dumpFunction("Commander.influence", color, faction, amount)
    if Helper.isElementOf(faction, { "greatHouses", "spacingGuild", "beneGesserit", "fringeWorlds" }) then
        return Action.influence(Commander.getActivatedAlly(color), faction, amount)
    elseif forced then
        return Action.influence(color, faction, amount)
    else
        -- To be chosen...
        local continuation = Helper.createContinuation("Commander.influence")
        continuation.cancel()
        return continuation
    end
end

---
function Commander.troops(color, from, to, amount)
    return Action.troops(Commander.getActivatedAlly(color), from, to, amount)
end

---
function Commander.advanceFreighter(color, positiveAmount)
    return Action.advanceFreighter(Commander.getActivatedAlly(color), positiveAmount)
end

---
function Commander.recallFreighter(color)
    return Action.recallFreighter(Commander.getActivatedAlly(color))
end

---
function Commander.shipments(color, amount)
    return Action.shipments(Commander.getActivatedAlly(color), amount)
end

---
function Commander.dreadnought(color, from, to, amount)
    return Action.dreadnought(Commander.getActivatedAlly(color), from, to, amount)
end

---
function Commander.research(color, jump)
    return Action.dreadnought(Commander.getActivatedAlly(color), jump)
end

---
function Commander.beetle(color, jump)
    return Action.beetle(Commander.getActivatedAlly(color), jump)
end

return Commander
