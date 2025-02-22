local Module = require("utils.Module")
local Helper = require("utils.Helper")
local AcquireCard = require("utils.AcquireCard")
local I18N = require("utils.I18N")

local Deck = Module.lazyRequire("Deck")
local PlayBoard = Module.lazyRequire("PlayBoard")
local Action = Module.lazyRequire("Action")
local Board = Module.lazyRequire("Board")

local Intrigue = {}

---@param state table
function Intrigue.onLoad(state)
    Helper.append(Intrigue, Helper.resolveGUIDs(false, {
        deckZone = 'a377d8',
        discardZone = '80642b'
    }))

    if state.settings then
        Intrigue._transientSetUp()
    end
end

---@param settings Settings
---@return Continuation
function Intrigue.setUp(settings)
    local continuation = Helper.createContinuation("Intrigue.setUp")
    Deck.generateIntrigueDeck(Intrigue.deckZone, settings).doAfter(function (deck)
        assert(deck, "No intrigue deck!")
        Helper.shuffleDeck(deck)
        Intrigue._transientSetUp()
        continuation.run()
    end)
    return continuation
end

function Intrigue._transientSetUp()
    AcquireCard.new(Intrigue.deckZone, Board.onTable(0), "Intrigue", PlayBoard.withLeader(Intrigue._acquireIntrigueCard), Deck.getAcquireCardDecalUrl("generic"))
    AcquireCard.new(Intrigue.discardZone, Board.onTable(0), "Intrigue", nil, Deck.getAcquireCardDecalUrl("generic"))
end

---@param color PlayerColor
function Intrigue._acquireIntrigueCard(leader, color, _)
    leader.drawIntrigues(color, 1)
end

---@param color PlayerColor
---@param amount integer
function Intrigue.drawIntrigues(color, amount)
    assert(amount > 0)
    local orientedPosition = PlayBoard.getHandOrientedPosition(color)
    Helper.onceTimeElapsed(0.25, amount).doAfter(function ()
        Helper.moveCardFromZone(Intrigue.deckZone, orientedPosition.position, orientedPosition.rotation, false, true)
        Intrigue.onIntrigueTaken(color)
    end)
end

---@param color PlayerColor
---@param otherColor PlayerColor
---@param amount integer
function Intrigue.stealIntrigues(color, otherColor, amount)
    assert(amount > 0)

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
        Intrigue.onIntrigueTaken(color)
    end)
end

---@param color PlayerColor
function Intrigue.onIntrigueTaken(color)
    local leader = PlayBoard.getLeader(color)
    if PlayBoard.hasTech(color, "suspensorSuits") then
        if leader.troops(color, "supply", "combat", 1) == 0 then
            Helper.dump("Failed to deploy a troop in accordance to the suspensor suits.")
        end
    end
end

---@param positions Vector[]
function Intrigue.moveIntrigues(positions)
    for i = 1, #positions do
        Helper.moveCardFromZone(Intrigue.deckZone, positions[i])
    end
end

---@param card Card
function Intrigue.discard(card)
    Intrigue.discardQueue = Intrigue.discardQueue or Helper.createSpaceQueue()
    Intrigue.discardQueue.submit(function (height)
        -- Not smooth to avoid being recaptured by the hand zone.
        card.setPosition(Intrigue.discardZone.getPosition() + Vector(0, 1 + height * 0.5, 0))
    end)
end

---@return (Card|DeadObject)[]
function Intrigue.getDiscardedIntrigues()
    local deckOrCard = Helper.getDeckOrCard(Intrigue.discardZone)
    return Helper.getCards(deckOrCard)
end

return Intrigue
