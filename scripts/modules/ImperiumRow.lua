local Module = require("utils.Module")
local Helper = require("utils.Helper")
local AcquireCard = require("utils.AcquireCard")
local I18N = require("utils.I18N")

local Deck = Module.lazyRequire("Deck")
local PlayBoard = Module.lazyRequire("PlayBoard")
local Music = Module.lazyRequire("Music")
local MainBoard = Module.lazyRequire("MainBoard")
local Board = Module.lazyRequire("Board")

local ImperiumRow = {}

---@param state table
function ImperiumRow.onLoad(state)
    Helper.append(ImperiumRow, Helper.resolveGUIDs(false, {
        deckZone = "8bd982",
        reservationSlotZone = "473cf7",
        slotZones = {
            '3de1d0',
            '356e2c',
            '7edbb3',
            '641974',
            'c6dbed'
        }
    }))

    if state.settings then
        ImperiumRow._transientSetUp()
    end
end

---@param settings Settings
---@return Continuation
function ImperiumRow.setUp(settings)
    local continuation = Helper.createContinuation("ImperiumRow.setUp")

    local position = ImperiumRow.deckZone.getPosition() - Vector(0, 1.5, 0)
    Helper.createTransientAnchor("ImperiumRowDeck", position).doAfter(function (anchor)
        local snapPoint = Helper.createRelativeSnapPointFromZone(anchor, ImperiumRow.deckZone, true, { "Imperium" })
        anchor.setSnapPoints({ snapPoint })

        Deck.generateImperiumDeck(ImperiumRow.deckZone, settings)
        .doAfter(function (deck)
            assert(deck, "No Imperium deck!")
            Helper.shuffleDeck(deck)
            for _, zone in ipairs(ImperiumRow.slotZones) do
                Helper.moveCardFromZone(ImperiumRow.deckZone, zone.getPosition(), Vector(0, 180, 0))
            end
            ImperiumRow._transientSetUp()
            continuation.run()
        end)
    end)

    return continuation
end

function ImperiumRow._transientSetUp()
    for i, zone in ipairs(ImperiumRow.slotZones) do
        AcquireCard.new(zone, Board.onTable(0), "Imperium", PlayBoard.withLeader(function (leader, color)
            leader.acquireImperiumCard(color, i)
        end), Deck.getAcquireCardDecalUrl("generic"))
    end

    AcquireCard.new(ImperiumRow.reservationSlotZone, Board.onTable(0), "Imperium", PlayBoard.withLeader(function (leader, color)
        leader.acquireReservedImperiumCard(color)
    end), Deck.getAcquireCardDecalUrl("generic"))

    Helper.registerEventListener("phaseStart", function (phase)
        if phase == "recall" then
            local cardOrDeck = Helper.getDeckOrCard(ImperiumRow.reservationSlotZone)
            if cardOrDeck then
                MainBoard.trash(cardOrDeck)
            end
        end
    end)
end

---@param color PlayerColor
---@return boolean
function ImperiumRow.acquireReservedImperiumCard(color)
    local cardOrDeck = Helper.getDeckOrCard(ImperiumRow.reservationSlotZone)
    if cardOrDeck then
        PlayBoard.giveCardFromZone(color, ImperiumRow.reservationSlotZone, false)
        return true
    else
        return false
    end
end

---@param indexInRow integer
---@return boolean
function ImperiumRow.reserveImperiumCard(indexInRow)
    local zone = ImperiumRow.slotZones[indexInRow]
    return Helper.withAnyCard(zone, function (card)
        card.setPosition(ImperiumRow.reservationSlotZone.getPosition())
        ImperiumRow._replenish(indexInRow)
    end)
end

---@param indexInRow integer
---@param color PlayerColor
---@return boolean
function ImperiumRow.acquireImperiumCard(indexInRow, color)
    local zone = ImperiumRow.slotZones[indexInRow]
    return Helper.withAnyCard(zone, function (card)
        PlayBoard.giveCard(color, card, false)
        ImperiumRow._replenish(indexInRow)
    end)
end

function ImperiumRow.nuke()
    Music.play("atomics")
    Helper.onceTimeElapsed(3).doAfter(function ()
        for i, zone in ipairs(ImperiumRow.slotZones) do
            Helper.withAnyCard(zone, function (card)
                MainBoard.trash(card)
                ImperiumRow._replenish(i)
            end)
        end
    end)
end

function ImperiumRow.churn()
    local firstCardIndex = math.random(6)
    local secondCardIndex = math.random(6)
    local count = 0
    for i, zone in ipairs(ImperiumRow.slotZones) do
        if i == firstCardIndex or i == secondCardIndex then
            Helper.withAnyCard(zone, function (card)
                MainBoard.trash(card)
                ImperiumRow._replenish(i)
                count = count + 1
            end)
        end
    end
    printToAll(I18N("churnImperiumRow", { count = count, card = I18N.agree(count, "card") }), "Pink")
end

---@param indexInRow integer
function ImperiumRow._replenish(indexInRow)
    local position = ImperiumRow.slotZones[indexInRow].getPosition()
    Helper.moveCardFromZone(ImperiumRow.deckZone, position, Vector(0, 180, 0))
end

return ImperiumRow
