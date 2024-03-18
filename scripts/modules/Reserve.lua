local Module = require("utils.Module")
local Helper = require("utils.Helper")
local AcquireCard = require("utils.AcquireCard")

local Deck = Module.lazyRequire("Deck")
local PlayBoard = Module.lazyRequire("PlayBoard")

local Reserve = {}

---
function Reserve.onLoad(state)
    Helper.append(Reserve, Helper.resolveGUIDs(true, {
        foldspaceSlotZone = "6b62e0",
        arrakisLiaisonSlotZone = "cbcd9a",
        theSpiceMustFlowSlotZone = "c087d2"
    }))

    if state.settings then
        Reserve._transientSetUp()
    end
end

---
function Reserve.setUp()
    Deck.generateSpecialDeck(Reserve.foldspaceSlotZone, "base", "foldspace")
    Deck.generateSpecialDeck(Reserve.arrakisLiaisonSlotZone, "base", "arrakisLiaison")
    Deck.generateSpecialDeck(Reserve.theSpiceMustFlowSlotZone, "base", "theSpiceMustFlow")
    Reserve._transientSetUp()
end

---
function Reserve._transientSetUp()
    Reserve.foldspace = AcquireCard.new(Reserve.foldspaceSlotZone, "Imperium", PlayBoard.withLeader(function (_, color)
        local leader = PlayBoard.getLeader(color)
        leader.acquireFoldspace(color)
    end))
    Reserve.arrakisLiaison = AcquireCard.new(Reserve.arrakisLiaisonSlotZone, "Imperium", PlayBoard.withLeader(function (_, color)
        local leader = PlayBoard.getLeader(color)
        leader.acquireArrakisLiaison(color)
    end), Deck.getAcquireCardDecalUrl("generic"))
    Reserve.theSpiceMustFlow = AcquireCard.new(Reserve.theSpiceMustFlowSlotZone, "Imperium", PlayBoard.withLeader(function (_, color)
        local leader = PlayBoard.getLeader(color)
        leader.acquireTheSpiceMustFlow(color)
    end), Deck.getAcquireCardDecalUrl("generic"))
end

---
function Reserve.acquireFoldspace(color)
    PlayBoard.giveCardFromZone(color, Reserve.foldspace.zone, false)
end

---
function Reserve.acquireArrakisLiaison(color)
    PlayBoard.giveCardFromZone(color, Reserve.arrakisLiaison.zone, false)
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
