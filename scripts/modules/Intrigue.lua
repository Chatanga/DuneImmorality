local Module = require("utils.Module")
local Helper = require("utils.Helper")
local AcquireCard = require("utils.AcquireCard")

local Deck = Module.lazyRequire("Deck")
local Playboard = Module.lazyRequire("Playboard")
local Utils = Module.lazyRequire("Utils")

local Intrigue = {}

---
function Intrigue.onLoad(state)
    Helper.append(Intrigue, Helper.resolveGUIDs(true, {
        deckZone = 'a377d8',
        discardZone = '80642b'
    }))

    AcquireCard.new(Intrigue.deckZone, "Intrigue", Intrigue.acquireIntrigueCard)
    AcquireCard.new(Intrigue.discardZone, "Intrigue", nil)
end

---
function Intrigue.setUp(ix, immortality)
    Deck.generateIntrigueDeck(Intrigue.deckZone, ix, immortality).doAfter(function (deck)
        deck.shuffle()
    end)
end

---
function Intrigue.acquireIntrigueCard(acquireCard, color)
    Intrigue.drawIntrigue(color, 1)
end

---
function Intrigue.drawIntrigue(color, amount)
    Utils.assertIsPositiveInteger(amount)
    -- Add an offset to put the card on the left side of the player's hand.
    local position = Player[color].getHandTransform().position + Vector(-7.5, 0, 0)
    Wait.time(function()
        Helper.moveCardFromZone(Intrigue.deckZone, position, nil, false, true)
    end, 0.25, amount)
end

---
function Intrigue.stealIntrigue(color, otherColor, amount)
    Utils.assertIsPositiveInteger(amount)

    local intrigues = Playboard.getIntrigues(otherColor)
    local realAmount = math.min(amount, #intrigues)

    Helper.shuffle(intrigues)

    -- Add an offset to put the card on the left side of the player's hand.
    local position = Player[color].getHandTransform().position + Vector(-7.5, 0, 0)
    Wait.time(function() -- Why?
        Helper.moveObject(table.remove(intrigues, 1), position, nil, false, false)
    end, 0.25, realAmount)
end

return Intrigue
