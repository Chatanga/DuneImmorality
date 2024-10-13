local Module = require("utils.Module")
local Helper = require("utils.Helper")

local Action = Module.lazyRequire("Action")
local PlayBoard = Module.lazyRequire("PlayBoard")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")

local Commander = Helper.createClass(Action, {
    leaders = {},
    activatedAllies = {},
})

---
function Commander.onLoad()
    -- Need to be called to be marked as such in Module, but we don't want
    -- Action.onLoad to be called instead. Hence this empty overload.
end

---
function Commander.setUp(settings)
    -- NOP
end

---
function Commander.isCommander(color)
    return color == "Purple" or color == "White"
end

---
function Commander.isAlly(color)
    return not Commander.isCommander(color)
end

---
function Commander.getAllies(color)
    if color == "Purple" then
        return { "Blue", "Red" }
    elseif color == "White" then
        return { "Yellow", "Green" }
    else
        return nil
    end
end

---
function Commander.getLeftSeatedAlly(color)
    if color == "Purple" then
        return "Blue"
    elseif color == "White" then
        return "Green"
    else
        return nil
    end
end

---
function Commander.getRightSeatedAlly(color)
    if color == "Purple" then
        return "Red"
    elseif color == "White" then
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
        return "Purple"
    elseif Helper.isElementOf(color, { "Yellow", "Green" }) then
        return "White"
    else
        return nil
    end
end

---
function Commander.isShaddam(color)
    return color == "Purple"
end

---
function Commander.isTeamShaddam(color)
    return color == "Red" or color == "Blue" or color == "Purple"
end

---
function Commander.getShaddamTeam()
    return { "Purple", "Red", "Blue" }
end

---
function Commander.isMuadDib(color)
    return color == "White"
end

---
function Commander.isTeamMuadDib(color)
    return color == "Green" or color == "Yellow" or color == "White"
end

---
function Commander.getMuadDibTeam()
    return { "White", "Green", "Yellow" }
end

---
function Commander.inSameTeam(...)
    assert(#{...} > 1)
    local shaddamTeamMemberCount = #Helper.filter({...}, Commander.isTeamShaddam)
    local muadDibTeamMemberCount = #Helper.filter({...}, Commander.isTeamMuadDib)
    return shaddamTeamMemberCount == 0 or muadDibTeamMemberCount == 0
end

---
function Commander.newCommander(color, leader)
    assert(Commander.isCommander(color))
    local commander = Helper.createClassInstance(Commander, {})
    Commander.leaders[color] = leader
    commander.name = leader.name
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
function Commander.doSetUp(color, settings)
    Helper.dumpFunction("Commander.doSetUp", color)
    local leader = Commander.leaders[color]
    assert(leader)
    leader.doSetUp(color, settings, true)
end

---
function Commander.prepare(color, settings)
    local leader = Commander.leaders[color]
    assert(leader)
    leader.prepare(color, settings, true)
end

---
function Commander.callSandworm(color, count)
    return Commander._forwardToActivatedAlly(color, "callSandworm", count)
end

---
function Commander.influence(color, faction, amount)
    if InfluenceTrack.hasAccess(color, faction) then
        return Action.influence(color, faction, amount)
    else
        return Commander._forwardToActivatedAlly(color, "influence", faction, amount)
    end
end

---
function Commander.troops(color, from, to, amount)
    return Commander._forwardToActivatedAlly(color, "troops", from, to, amount)
end

---
function Commander.advanceFreighter(color, positiveAmount)
    return Commander._forwardToActivatedAlly(color, "advanceFreighter", positiveAmount)
end

---
function Commander.recallFreighter(color)
    return Commander._forwardToActivatedAlly(color, "recallFreighter")
end

---
function Commander.shipments(color, amount)
    return Commander._forwardToActivatedAlly(color, "shipments", amount)
end

---
function Commander.dreadnought(color, from, to, amount)
    return Commander._forwardToActivatedAlly(color, "dreadnought", from, to, amount)
end

---
function Commander.research(color, jump)
    return Commander._forwardToActivatedAlly(color, "dreadnought", jump)
end

---
function Commander.beetle(color, jump)
    return Commander._forwardToActivatedAlly(color, "beetle", jump)
end

---
function Commander._forwardToActivatedAlly(color, functionName, ...)
    local ally = Commander.getActivatedAlly(color)
    local leader = PlayBoard.getLeader(ally)
    return leader[functionName](ally, ...)
end

return Commander
