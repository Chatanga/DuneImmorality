local Module = require("utils.Module")
local Helper = require("utils.Helper")
local AcquireCard = require("utils.AcquireCard")

local Deck = Module.lazyRequire("Deck")
local PlayBoard = Module.lazyRequire("PlayBoard")
local Utils = Module.lazyRequire("Utils")

local Intrigue = {}

---
function Intrigue.onLoad(state)
    Helper.append(Intrigue, Helper.resolveGUIDs(true, {
        deckZone = 'a377d8',
        discardZone = '80642b'
    }))

    AcquireCard.new(Intrigue.deckZone, "Intrigue", Intrigue._acquireIntrigueCard)
    AcquireCard.new(Intrigue.discardZone, "Intrigue", nil)

    if state.settings then
        Intrigue._staticSetUp(state.settings)
    end
end

---
function Intrigue.setUp(settings)
    Intrigue._staticSetUp(settings)
end

---
function Intrigue._staticSetUp(settings)
    Deck.generateIntrigueDeck(Intrigue.deckZone, settings.riseOfx, settings.immortality).doAfter(function (deck)
        Helper.shuffleDeck(deck)
    end)
end

---
function Intrigue._acquireIntrigueCard(acquireCard, color)
    local leader = PlayBoard.getLeader(color)
    leader.drawIntrigues(color, 1)
end

---
function Intrigue.drawIntrigue(color, amount)
    Utils.assertIsPositiveInteger(amount)
    -- Add an offset to put the card on the left side of the player's hand.
    local position = Player[color].getHandTransform().position + Vector(-7.5, 0, 0)
    Helper.onceTimeElapsed(0.25, amount).doAfter(function()
        Helper.moveCardFromZone(Intrigue.deckZone, position, nil, false, true)
    end)
end

---
function Intrigue.stealIntrigue(color, otherColor, amount)
    Utils.assertIsPositiveInteger(amount)

    local intrigues = PlayBoard.getIntrigues(otherColor)
    local realAmount = math.min(amount, #intrigues)

    Helper.shuffle(intrigues)

    -- Add an offset to put the card on the left side of the player's hand.
    local position = Player[color].getHandTransform().position + Vector(-7.5, 0, 0)
    Helper.onceTimeElapsed(0.25, realAmount).doAfter(function() -- Why?
        table.remove(intrigues, 1).setPosition(position)
    end)
end

---
function Intrigue.getDiscardedIntrigues()
    local deckOrCard = Helper.getDeckOrCard(Intrigue.discardZone)
    return Helper.getCards(deckOrCard)
end

return Intrigue
