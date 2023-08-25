local Module = require("utils.Module")
local Helper = require("utils.Helper")
local AcquireCard = require("utils.AcquireCard")

local Deck = Module.lazyRequire("Deck")
local Playboard = Module.lazyRequire("Playboard")
local ScoreBoard = Module.lazyRequire("ScoreBoard")

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
    Reserve.foldspace = AcquireCard.new(Reserve.foldspaceSlotZone, "Imperium", Reserve.acquireFoldspace)
    Reserve.arrakisLiaison = AcquireCard.new(Reserve.arrakisLiaisonSlotZone, "Imperium", Reserve.acquireArrakisLiaison)
    Reserve.theSpiceMustFlow = AcquireCard.new(Reserve.theSpiceMustFlowSlotZone, "Imperium", Reserve.acquireTheSpiceMustFlow)
end

---
function Reserve.acquireFoldspace(acquireCard, color)
    Playboard.giveCardFromZone(color, acquireCard.zone, false)
end

---
function Reserve.acquireArrakisLiaison(acquireCard, color)
    Playboard.giveCardFromZone(color, acquireCard.zone, false)
end

---
function Reserve.acquireTheSpiceMustFlow(acquireCard, color)
    ScoreBoard.gainVictoryPoint(color, "theSpiceMustFlow")
end

return Reserve
