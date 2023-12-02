local Module = require("utils.Module")
local Helper = require("utils.Helper")
local AcquireCard = require("utils.AcquireCard")

local Deck = Module.lazyRequire("Deck")
local PlayBoard = Module.lazyRequire("PlayBoard")
local Types = Module.lazyRequire("Types")

local Intrigue = {}

---
function Intrigue.onLoad(state)
    --Helper.dumpFunction("Intrigue.onLoad(...)")

    Helper.append(Intrigue, Helper.resolveGUIDs(false, {
        deckZone = 'a377d8',
        discardZone = '80642b'
    }))

    if state.settings then
        Intrigue._staticSetUp(state.settings)
    end
end

---
function Intrigue.setUp(settings)
    Intrigue._staticSetUp(settings)

    Deck.generateIntrigueDeck(Intrigue.deckZone, settings.useContracts, settings.riseOfIx, settings.immortality).doAfter(function (deck)
        Helper.shuffleDeck(deck)
    end)
end

---
function Intrigue._staticSetUp(settings)
    AcquireCard.new(Intrigue.deckZone, "Intrigue", PlayBoard.withLeader(Intrigue._acquireIntrigueCard))
    AcquireCard.new(Intrigue.discardZone, "Intrigue", nil)
end

---
function Intrigue._acquireIntrigueCard(acquireCard, color)
    local leader = PlayBoard.getLeader(color)
    leader.drawIntrigues(color, 1)
end

---
function Intrigue.drawIntrigue(color, amount)
    Types.assertIsPositiveInteger(amount)
    -- Add an offset to put the card on the left side of the player's hand.
    local handTransform = Player[color].getHandTransform()
    local position = handTransform.position + Vector(0, 0, -5)
    local rotation = handTransform.rotation + Vector(0, 180, 0)
    Helper.onceTimeElapsed(0.25, amount).doAfter(function()
        Helper.moveCardFromZone(Intrigue.deckZone, position, rotation, false, true)
    end)
end

---
function Intrigue.stealIntrigue(color, otherColor, amount)
    Types.assertIsPositiveInteger(amount)

    local intrigues = PlayBoard.getIntrigues(otherColor)
    local realAmount = math.min(amount, #intrigues)

    Helper.shuffle(intrigues)

    -- Add an offset to put the card on the left side of the player's hand.
    local handTransform = Player[color].getHandTransform()
    local position = handTransform.position + Vector(0, 0, -5)
    local rotation = handTransform.rotation + Vector(0, 180, 0)
    Helper.onceTimeElapsed(0.25, realAmount).doAfter(function() -- Why?
        local card = table.remove(intrigues, 1)
        card.setPosition(position)
        card.setRotation(rotation)
    end)
end

---
function Intrigue.getDiscardedIntrigues()
    local deckOrCard = Helper.getDeckOrCard(Intrigue.discardZone)
    return Helper.getCards(deckOrCard)
end

return Intrigue
