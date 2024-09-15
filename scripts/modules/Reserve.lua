local Module = require("utils.Module")
local Helper = require("utils.Helper")
local AcquireCard = require("utils.AcquireCard")

local Deck = Module.lazyRequire("Deck")
local PlayBoard = Module.lazyRequire("PlayBoard")

local Reserve = {}

---
function Reserve.onLoad(state)
    Helper.append(Reserve, Helper.resolveGUIDs(false, {
        foldspaceSlotZone = "6b62e0",
        prepareTheWaySlotZone = "cbcd9a",
        theSpiceMustFlowSlotZone = "c087d2"
    }))

    if state.settings then
        Reserve._transientSetUp()
    end
end

---
function Reserve.setUp()
    -- TODO Detect Ilesa Ecaz?
    if false then
        Deck.generateSpecialDeck(Reserve.foldspaceSlotZone, "base", "foldspace")
    else
        Reserve.foldspaceSlotZone.destruct()
    end
    Deck.generateSpecialDeck(Reserve.prepareTheWaySlotZone, "uprising", "prepareTheWay")
    Deck.generateSpecialDeck(Reserve.theSpiceMustFlowSlotZone, "uprising", "theSpiceMustFlow")
    Reserve._transientSetUp()
end

---
function Reserve._transientSetUp()
    -- TODO Detect Ilesa Ecaz?
    if false then
        Reserve.foldspace = AcquireCard.new(Reserve.foldspaceSlotZone, "Imperium", PlayBoard.withLeader(function (_, color)
            local leader = PlayBoard.getLeader(color)
            leader.acquireFoldspace(color)
        end), Deck.getAcquireCardDecalUrl("generic"))
    end
    Reserve.prepareTheWay = AcquireCard.new(Reserve.prepareTheWaySlotZone, "Imperium", PlayBoard.withLeader(function (_, color)
        local leader = PlayBoard.getLeader(color)
        leader.acquirePrepareTheWay(color)
    end), Deck.getAcquireCardDecalUrl("generic"))
    Reserve.theSpiceMustFlow = AcquireCard.new(Reserve.theSpiceMustFlowSlotZone, "Imperium", PlayBoard.withLeader(function (_, color)
        local leader = PlayBoard.getLeader(color)
        leader.acquireTheSpiceMustFlow(color)
    end), Deck.getAcquireCardDecalUrl("generic"))
end

---
function Reserve.acquireFoldspace(color)
    if Reserve.foldspace then
        PlayBoard.giveCardFromZone(color, Reserve.foldspace.zone, false)
        return true
    else
        return false
    end
end

---
function Reserve.acquirePrepareTheWay(color)
    PlayBoard.giveCardFromZone(color, Reserve.prepareTheWay.zone, false)
    return true
end

---
function Reserve.acquireTheSpiceMustFlow(color, toItsHand)
    if toItsHand then
        local position = Player[color].getHandTransform().position
        Helper.moveCardFromZone(Reserve.theSpiceMustFlow.zone, position, nil, false, true)
    else
        PlayBoard.giveCardFromZone(color, Reserve.theSpiceMustFlow.zone, false, toItsHand)
    end
    return true
end

return Reserve
