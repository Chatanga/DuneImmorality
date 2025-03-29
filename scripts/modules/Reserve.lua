local Module = require("utils.Module")
local Helper = require("utils.Helper")
local AcquireCard = require("utils.AcquireCard")

local Deck = Module.lazyRequire("Deck")
local PlayBoard = Module.lazyRequire("PlayBoard")
local Board = Module.lazyRequire("Board")

local Reserve = {}

---@param state table
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

function Reserve.setUp()
    Deck.generateSpecialDeck(Reserve.foldspaceSlotZone, "base", "foldspace")
    Deck.generateSpecialDeck(Reserve.arrakisLiaisonSlotZone, "base", "arrakisLiaison")
    Deck.generateSpecialDeck(Reserve.theSpiceMustFlowSlotZone, "base", "theSpiceMustFlow")
    Reserve._transientSetUp()
end

function Reserve._transientSetUp()
    Reserve.foldspace = AcquireCard.new(Reserve.foldspaceSlotZone, Board.onTable(0), "Imperium", PlayBoard.withLeader(function (leader, color)
        leader.acquireFoldspace(color)
    end))
    Reserve.arrakisLiaison = AcquireCard.new(Reserve.arrakisLiaisonSlotZone, Board.onTable(0), "Imperium", PlayBoard.withLeader(function (leader, color)
        leader.acquireArrakisLiaison(color)
    end), Deck.getAcquireCardDecalUrl("generic"))
    Reserve.theSpiceMustFlow = AcquireCard.new(Reserve.theSpiceMustFlowSlotZone, Board.onTable(0), "Imperium", PlayBoard.withLeader(function (leader, color)
        leader.acquireTheSpiceMustFlow(color)
    end), Deck.getAcquireCardDecalUrl("generic"))
end

---@param color PlayerColor
function Reserve.acquireFoldspace(color)
    PlayBoard.giveCardFromZone(color, Reserve.foldspace.zone, false)
end

---@param color PlayerColor
function Reserve.acquireArrakisLiaison(color)
    PlayBoard.giveCardFromZone(color, Reserve.arrakisLiaison.zone, false)
end

---@param color PlayerColor
---@param toItsHand? boolean
function Reserve.acquireTheSpiceMustFlow(color, toItsHand)
    if toItsHand then
        local position = Player[color].getHandTransform().position
        Helper.moveCardFromZone(Reserve.theSpiceMustFlow.zone, position, nil, false, true)
    else
        PlayBoard.giveCardFromZone(color, Reserve.theSpiceMustFlow.zone, false)
    end
end

---@param card Card
function Reserve.recycleFoldspaceCard(card)
    card.setPosition(Reserve.foldspaceSlotZone.getPosition())
end

--- Move a card out of a trash and back into the reserve if necessary.
---@param trashBag Bag
---@param card DeadObject
function Reserve.redirectUntrashableCards(trashBag, card)
    -- The ID is stored in the 'GM Notes' property (the description and/or name
    -- properties stores an unpredictable I18N content).
    local cardName = Helper.getID(card)
    local acquireCard = Reserve[cardName]
    if acquireCard then
        trashBag.takeObject({
            guid = card.guid,
            position = acquireCard.zone.getPosition() + Vector(0, 1, 0),
            rotation = Vector(0, 180, 0),
            smooth = false,
        })
    end
end

return Reserve
