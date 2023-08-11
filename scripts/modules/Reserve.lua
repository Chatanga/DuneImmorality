local Module = require("utils.Module")
local Helper = require("utils.Helper")
local AcquireCard = require("utils.AcquireCard")

local Deck = Module.lazyRequire("Deck")
local Playboard = Module.lazyRequire("Playboard")

local Reserve = {}

---
function Reserve.onLoad(_)
    Helper.append(Reserve, Helper.resolveGUIDs(true, {
        foldspaceSlotZone = "6b62e0",
        arrakisLiaisonSlotZone = "cbcd9a",
        theSpiceMustFlowSlotZone = "c087d2"
    }))

    Reserve.foldspace = AcquireCard.new(Reserve.foldspaceSlotZone, "Imperium", Reserve.acquireFoldspace)
    Reserve.arrakisLiaison = AcquireCard.new(Reserve.arrakisLiaisonSlotZone, "Imperium", Reserve.acquireArrakisLiaison)
    Reserve.theSpiceMustFlow = AcquireCard.new(Reserve.theSpiceMustFlowSlotZone, "Imperium", Reserve.acquireTheSpiceMustFlow)
end

---
function Reserve.setUp()
    Deck.generateSpecialDeck("foldspace", Reserve.foldspaceSlotZone)
    Deck.generateSpecialDeck("arrakisLiaison", Reserve.arrakisLiaisonSlotZone)
    Deck.generateSpecialDeck("theSpiceMustFlow", Reserve.theSpiceMustFlowSlotZone)
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
    Playboard.giveCardFromZone(color, acquireCard.zone, false)
    local theSpiceMustFlowZoneVictoryTokenBag = getObjectFromGUID("43c7b5")
    Playboard.grantScoreTokenFromBag(color, theSpiceMustFlowZoneVictoryTokenBag)
end

return Reserve
