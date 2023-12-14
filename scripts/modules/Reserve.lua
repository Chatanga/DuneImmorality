local Module = require("utils.Module")
local Helper = require("utils.Helper")
local AcquireCard = require("utils.AcquireCard")

local Deck = Module.lazyRequire("Deck")
local PlayBoard = Module.lazyRequire("PlayBoard")

local Reserve = {}

---
function Reserve.onLoad(state)
    --Helper.dumpFunction("Reserve.onLoad(...)")

    Helper.append(Reserve, Helper.resolveGUIDs(false, {
        foldspaceSlotZone = "6b62e0",
        prepareTheWaySlotZone = "cbcd9a",
        theSpiceMustFlowSlotZone = "c087d2"
    }))

    if state.settings then
        Reserve._staticSetUp()
    end
end

---
function Reserve.setUp()
    if false then
        Deck.generateSpecialDeck(Reserve.foldspaceSlotZone, "base", "foldspace")
    else
        Reserve.foldspaceSlotZone.destruct()
    end
    Deck.generateSpecialDeck(Reserve.prepareTheWaySlotZone, "uprising", "prepareTheWay")
    Deck.generateSpecialDeck(Reserve.theSpiceMustFlowSlotZone, "uprising", "theSpiceMustFlowNew")
    Reserve._staticSetUp()
end

---
function Reserve._staticSetUp()
    if false then
        Reserve.foldspace = AcquireCard.new(Reserve.foldspaceSlotZone, "Imperium", PlayBoard.withLeader(function (_, color)
            local leader = PlayBoard.getLeader(color)
            leader.acquireFoldspace(color)
        end))
    end
    Reserve.prepareTheWay = AcquireCard.new(Reserve.prepareTheWaySlotZone, "Imperium", PlayBoard.withLeader(function (_, color)
        local leader = PlayBoard.getLeader(color)
        leader.acquirePrepareTheWay(color)
    end))
    Reserve.theSpiceMustFlow = AcquireCard.new(Reserve.theSpiceMustFlowSlotZone, "Imperium", PlayBoard.withLeader(function (_, color)
        local leader = PlayBoard.getLeader(color)
        leader.acquireTheSpiceMustFlow(color)
    end))
end

---
function Reserve.acquireFoldspace(color)
    if false then
        PlayBoard.giveCardFromZone(color, Reserve.foldspace.zone, false)
    else
        error("TODO")
    end
end

---
function Reserve.acquirePrepareTheWay(color)
    PlayBoard.giveCardFromZone(color, Reserve.prepareTheWay.zone, false)
end

---
function Reserve.acquireTheSpiceMustFlow(color, toItsHand)
    if toItsHand then
        local position = Player[color].getHandTransform().position
        Helper.moveCardFromZone(Reserve.theSpiceMustFlow.zone, position, nil, false, true)
    else
        PlayBoard.giveCardFromZone(color, Reserve.theSpiceMustFlow.zone, false, toItsHand)
    end
end

return Reserve
