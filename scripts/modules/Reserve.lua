local Module = require("utils.Module")
local Helper = require("utils.Helper")
local AcquireCard = require("utils.AcquireCard")

local Deck = Module.lazyRequire("Deck")
local PlayBoard = Module.lazyRequire("PlayBoard")
local Action = Module.lazyRequire("Action")

local Reserve = {}

---
function Reserve.onLoad(state)
    Helper.append(Reserve, Helper.resolveGUIDs(true, {
        foldspaceSlotZone = "6b62e0",
        arrakisLiaisonSlotZone = "cbcd9a",
        theSpiceMustFlowSlotZone = "c087d2"
    }))

    if state.settings then
        Reserve._staticSetUp()
    end
end

---
function Reserve.setUp()
    Deck.generateSpecialDeck("foldspace", Reserve.foldspaceSlotZone)
    Deck.generateSpecialDeck("arrakisLiaison", Reserve.arrakisLiaisonSlotZone)
    Deck.generateSpecialDeck("theSpiceMustFlow", Reserve.theSpiceMustFlowSlotZone)
    Reserve._staticSetUp()
end

---
function Reserve._staticSetUp()
    Reserve.foldspace = AcquireCard.new(Reserve.foldspaceSlotZone, "Imperium", Action.acquireFoldspace)
    Reserve.arrakisLiaison = AcquireCard.new(Reserve.arrakisLiaisonSlotZone, "Imperium", Action.acquireArrakisLiaison)
    Reserve.theSpiceMustFlow = AcquireCard.new(Reserve.theSpiceMustFlowSlotZone, "Imperium", Action.acquireTheSpiceMustFlow)
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
    local leader = PlayBoard.getLeader(color)
    leader.gainVictoryPoint(color, "theSpiceMustFlow")
end

return Reserve
