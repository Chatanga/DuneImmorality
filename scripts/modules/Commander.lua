local Module = require("utils.Module")
local Helper = require("utils.Helper")

local Action = Module.lazyRequire("Action")
local PlayBoard = Module.lazyRequire("PlayBoard")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")

---@class Commander: Leader
---@field leaders Leader[]
---@field activatedAllies table<PlayerColor, PlayerColor>
local Commander = Helper.createClass(Action, {
    leaders = {},
    activatedAllies = {},
})

function Commander.onLoad()
    -- Need to be called to be marked as such in Module, but we don't want
    -- Action.onLoad to be called instead. Hence this empty overload.
end

---@param settings Settings
function Commander.setUp(settings)
    -- NOP
end

---@param color PlayerColor
---@return boolean
function Commander.isCommander(color)
    return color == "Purple" or color == "White"
end

---@param color PlayerColor
---@return boolean
function Commander.isAlly(color)
    return not Commander.isCommander(color)
end

---@param color PlayerColor
---@return PlayerColor[]
function Commander.getAllies(color)
    if color == "Purple" then
        return { "Blue", "Red" }
    elseif color == "White" then
        return { "Yellow", "Green" }
    else
        return {}
    end
end

---@param color PlayerColor
---@return PlayerColor?
function Commander.getLeftSeatedAlly(color)
    if color == "Purple" then
        return "Blue"
    elseif color == "White" then
        return "Green"
    else
        return nil
    end
end

---@param color PlayerColor
---@return PlayerColor?
function Commander.getRightSeatedAlly(color)
    if color == "Purple" then
        return "Red"
    elseif color == "White" then
        return "Yellow"
    else
        return nil
    end
end

---@param color PlayerColor
---@return PlayerColor?
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

---@param color PlayerColor
---@return PlayerColor?
function Commander.getCommander(color)
    if Helper.isElementOf(color, { "Blue", "Red" }) then
        return "Purple"
    elseif Helper.isElementOf(color, { "Yellow", "Green" }) then
        return "White"
    else
        return nil
    end
end

---@param color PlayerColor
---@return boolean
function Commander.isShaddam(color)
    return color == "Purple"
end

---@param color PlayerColor
---@return boolean
function Commander.isTeamShaddam(color)
    return color == "Red" or color == "Blue" or color == "Purple"
end

---@return PlayerColor[]
function Commander.getShaddamTeam()
    return { "Purple", "Red", "Blue" }
end

---@param color PlayerColor
---@return boolean
function Commander.isMuadDib(color)
    return color == "White"
end

---@param color PlayerColor
---@return boolean
function Commander.isTeamMuadDib(color)
    return color == "Green" or color == "Yellow" or color == "White"
end

---@return PlayerColor[]
function Commander.getMuadDibTeam()
    return { "White", "Green", "Yellow" }
end

---@param ... PlayerColor
---@return boolean
function Commander.inSameTeam(...)
    assert(#{...} > 1)
    local shaddamTeamMemberCount = #Helper.filter({...}, Commander.isTeamShaddam)
    local muadDibTeamMemberCount = #Helper.filter({...}, Commander.isTeamMuadDib)
    return shaddamTeamMemberCount == 0 or muadDibTeamMemberCount == 0
end

---@param color PlayerColor
---@param leader Leader
---@return Commander
function Commander.newCommander(color, leader)
    assert(Commander.isCommander(color))
    local commander = Helper.createClassInstance(Commander, {})
    Commander.leaders[color] = leader
    commander.name = leader.name
    return commander
end

---@param color PlayerColor
---@param allyColor? PlayerColor
function Commander.setActivatedAlly(color, allyColor)
    assert(Commander.isCommander(color))
    assert(not allyColor or Commander.isAlly(allyColor))
    Commander.activatedAllies[color] = allyColor
    Helper.emitEvent("selectAlly", color, allyColor)
end

---@param color PlayerColor
---@return PlayerColor
function Commander.getActivatedAlly(color)
    return Commander.activatedAllies[color]
end

---@param color PlayerColor
---@param settings Settings
function Commander.doSetUp(color, settings)
    local leader = Commander.leaders[color]
    assert(leader)
    leader.doSetUp(color, settings)
end

---@param color PlayerColor
---@param settings Settings
function Commander.prepare(color, settings)
    local leader = Commander.leaders[color]
    assert(leader)
    leader.prepare(color, settings, true)
end

---@param color PlayerColor
---@param count integer
---@return boolean
function Commander.callSandworm(color, count)
    return Commander._forwardToActivatedAlly(color, "callSandworm", count)
end

---@param color PlayerColor
---@param faction Faction
---@param amount integer
---@return Continuation
function Commander.influence(color, faction, amount)
    if InfluenceTrack.hasAccess(color, faction) then
        return Action.influence(color, faction, amount)
    else
        return Commander._forwardToActivatedAlly(color, "influence", faction, amount)
    end
end

---@param color PlayerColor
---@param from Park
---@param to Park
---@param amount integer
---@return integer
function Commander.troops(color, from, to, amount)
    return Commander._forwardToActivatedAlly(color, "troops", from, to, amount)
end

---@param color PlayerColor
---@param origin string
---@return boolean
function Commander.recruitSardaukarCommander(color, origin)
    return Commander._forwardToActivatedAlly(color, "recruitSardaukarCommander", origin)
end

---@param color PlayerColor
---@param positiveAmount integer
---@return boolean
function Commander.advanceFreighter(color, positiveAmount)
    return Commander._forwardToActivatedAlly(color, "advanceFreighter", positiveAmount)
end

---@param color PlayerColor
---@return boolean
function Commander.recallFreighter(color)
    return Commander._forwardToActivatedAlly(color, "recallFreighter")
end

---@param color PlayerColor
---@param amount integer
---@return boolean
function Commander.shipments(color, amount)
    return Commander._forwardToActivatedAlly(color, "shipments", amount)
end

---@param color PlayerColor
---@param from Park
---@param to Park
---@param amount integer
---@return integer
function Commander.dreadnought(color, from, to, amount)
    return Commander._forwardToActivatedAlly(color, "dreadnought", from, to, amount)
end

---@param color PlayerColor
---@param jump integer
---@return boolean
function Commander.research(color, jump)
    return Commander._forwardToActivatedAlly(color, "research", jump)
end

---@param color PlayerColor
---@param jump integer
---@return boolean
function Commander.beetle(color, jump)
    return Commander._forwardToActivatedAlly(color, "beetle", jump)
end

---@param color PlayerColor
---@param functionName string
---@param ... any
---@return any
function Commander._forwardToActivatedAlly(color, functionName, ...)
    local ally = Commander.getActivatedAlly(color)
    local leader = PlayBoard.getLeader(ally)
    return leader[functionName](ally, ...)
end

return Commander
