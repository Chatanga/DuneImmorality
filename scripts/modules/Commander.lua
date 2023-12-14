local Module = require("utils.Module")
local Helper = require("utils.Helper")

local Action = Module.lazyRequire("Action")

local Commander = Helper.createClass(Action, {
    activatedAllies = {}
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
        return { "Red", "Blue" }
    elseif color == "Teal" then
        return { "Green", "Yellow" }
    else
        return nil
    end
end

---
function Commander.isTeamEmperor(color)
    return color == "Red" or color == "Red" or color == "Brown"
end

---
function Commander.isTeamMuabDib(color)
    return color == "Green" or color == "Yellow" or color == "Teal"
end

---
function Commander.newCommander(color, leader)
    assert(Commander.isCommander(color))
    local commander = Helper.createClassInstance(Commander, {
        leader = leader
    })
    return commander
end

---
function Commander.setActivatedAlly(color, allyColor)
    assert(Commander.isCommander(color))
    assert(Commander.isAlly(allyColor))
    Commander.activatedAllies[color] = allyColor
end

---
function Commander.getActivatedAlly(color)
    return Commander.activatedAllies[color]
end

---
function Action.prepare(color, settings)
    Action.resources(color, "water", 1)
    if settings.epicMode then
        Action.drawIntrigues(color, 1)
    end
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
    --Helper.dumpFunction("Commander.influence", color, faction, amount)
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
    --Helper.dumpFunction("Commander.troops", color, from, to, amount)
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
