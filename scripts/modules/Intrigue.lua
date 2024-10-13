local Module = require("utils.Module")
local Helper = require("utils.Helper")
local AcquireCard = require("utils.AcquireCard")
local I18N = require("utils.I18N")

local Deck = Module.lazyRequire("Deck")
local PlayBoard = Module.lazyRequire("PlayBoard")
local Types = Module.lazyRequire("Types")
local Action = Module.lazyRequire("Action")

local Intrigue = {}

---
function Intrigue.onLoad(state)
    Helper.append(Intrigue, Helper.resolveGUIDs(false, {
        deckZone = 'a377d8',
        discardZone = '80642b'
    }))

    if state.settings then
        Intrigue._transientSetUp(state.settings)
    end
end

---
function Intrigue.setUp(settings)
    local continuation = Helper.createContinuation("Intrigue.setUp")
    Deck.generateIntrigueDeck(Intrigue.deckZone, settings.useContracts, settings.riseOfIx, settings.immortality, settings.legacy, settings.merakon).doAfter(function (deck)
        Helper.shuffleDeck(deck)
        Intrigue._transientSetUp(settings)
        continuation.run()
    end)
    return continuation
end

---
function Intrigue._transientSetUp(settings)
    AcquireCard.new(Intrigue.deckZone, "Intrigue", PlayBoard.withLeader(Intrigue._acquireIntrigueCard), Deck.getAcquireCardDecalUrl("generic"))
    AcquireCard.new(Intrigue.discardZone, "Intrigue", nil, Deck.getAcquireCardDecalUrl("generic"))
end

---
function Intrigue._acquireIntrigueCard(acquireCard, color)
    local leader = PlayBoard.getLeader(color)
    leader.drawIntrigues(color, 1)
end

---
function Intrigue.drawIntrigues(color, amount)
    Types.assertIsPositiveInteger(amount)
    local orientedPosition = PlayBoard.getHandOrientedPosition(color)
    Helper.onceTimeElapsed(0.25, amount).doAfter(function ()
        Helper.moveCardFromZone(Intrigue.deckZone, orientedPosition.position, orientedPosition.rotation, false, true)
    end)
end

---
function Intrigue.stealIntrigues(color, otherColor, amount)
    Types.assertIsPositiveInteger(amount)
    local victimName = PlayBoard.getLeaderName(otherColor)

    local intrigues = PlayBoard.getIntrigues(otherColor)
    local realAmount = math.min(amount, #intrigues)

    Helper.shuffle(intrigues)

    local orientedPosition = PlayBoard.getHandOrientedPosition(color)
    Helper.onceTimeElapsed(0.25, realAmount).doAfter(function () -- Why?
        local card = table.remove(intrigues, 1)
        card.setPosition(orientedPosition.position)
        card.setRotation(orientedPosition.rotation)
        local cardName = I18N(Helper.getID(card))
        Action.secretLog(I18N("stealIntrigues", { victim = victimName, card = cardName }), color)
    end)
end

---
function Intrigue.moveIntrigues(positions)
    for i = 1, #positions do
        Helper.moveCardFromZone(Intrigue.deckZone, positions[i])
    end
end

---
function Intrigue.discard(card)
    Intrigue.discardQueue = Intrigue.discardQueue or Helper.createSpaceQueue()
    Intrigue.discardQueue.submit(function (height)
        -- Not smooth to avoid being recaptured by the hand zone.
        card.setPosition(Intrigue.discardZone.getPosition() + Vector(0, 1 + height * 0.5, 0))
    end)
end

---
function Intrigue.getDiscardedIntrigues()
    local deckOrCard = Helper.getDeckOrCard(Intrigue.discardZone)
    return Helper.getCards(deckOrCard)
end

return Intrigue
