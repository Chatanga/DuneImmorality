local Module = require("utils.Module")
local Helper = require("utils.Helper")
local AcquireCard = require("utils.AcquireCard")

local Deck = Module.lazyRequire("Deck")
local PlayBoard = Module.lazyRequire("PlayBoard")
local Board = Module.lazyRequire("Board")

local Reserve = {}

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
    Reserve.foldspace = AcquireCard.new(Reserve.foldspaceSlotZone, Board.onTable(0), "Imperium", PlayBoard.withLeader(function (_, color)
        local leader = PlayBoard.getLeader(color)
        leader.acquireFoldspace(color)
    end))
    Reserve.arrakisLiaison = AcquireCard.new(Reserve.arrakisLiaisonSlotZone, Board.onTable(0), "Imperium", PlayBoard.withLeader(function (_, color)
        local leader = PlayBoard.getLeader(color)
        leader.acquireArrakisLiaison(color)
    end), Deck.getAcquireCardDecalUrl("generic"))
    Reserve.theSpiceMustFlow = AcquireCard.new(Reserve.theSpiceMustFlowSlotZone, Board.onTable(0), "Imperium", PlayBoard.withLeader(function (_, color)
        local leader = PlayBoard.getLeader(color)
        leader.acquireTheSpiceMustFlow(color)
    end), Deck.getAcquireCardDecalUrl("generic"))
end

function Reserve.acquireFoldspace(color)
    PlayBoard.giveCardFromZone(color, Reserve.foldspace.zone, false)
end

function Reserve.acquireArrakisLiaison(color)
    PlayBoard.giveCardFromZone(color, Reserve.arrakisLiaison.zone, false)
end

function Reserve.acquireTheSpiceMustFlow(color, toItsHand)
    if toItsHand then
        local position = Player[color].getHandTransform().position
        Helper.moveCardFromZone(Reserve.theSpiceMustFlow.zone, position, nil, false, true)
    else
        PlayBoard.giveCardFromZone(color, Reserve.theSpiceMustFlow.zone, false, toItsHand)
    end
    return true
end

function Reserve.recycleFoldspaceCard(card)
    card.setPosition(Reserve.foldspaceSlotZone.getPosition())
end

--- Move a card out of a trash and back into the reserve if necessary.
function Reserve.unused_redirectUntrashableCards(trashBag, card)
    -- The ID is stored in the 'GM Notes' property (the description and/or name
    -- properties store an unpredictable I18N content).
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
