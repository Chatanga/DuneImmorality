local Module = require("utils.Module")
local Helper = require("utils.Helper")
local AcquireCard = require("utils.AcquireCard")
local I18N = require("utils.I18N")

local Deck = Module.lazyRequire("Deck")
local PlayBoard = Module.lazyRequire("PlayBoard")
local Music = Module.lazyRequire("Music")
local MainBoard = Module.lazyRequire("MainBoard")

local ImperiumRow = {}

---
function ImperiumRow.onLoad(state)
    Helper.append(ImperiumRow, Helper.resolveGUIDs(false, {
        deckZone = "8bd982",
        -- FIXME Confusing "reserve" wording.
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

---
function ImperiumRow.setUp(settings)
    local continuation = Helper.createContinuation("ImperiumRow.setUp")
    Deck.generateImperiumDeck(ImperiumRow.deckZone, settings.riseOfIx, settings.immortality).doAfter(function (deck)
        Helper.shuffleDeck(deck)
        for _, zone in ipairs(ImperiumRow.slotZones) do
            Helper.moveCardFromZone(ImperiumRow.deckZone, zone.getPosition(), Vector(0, 180, 0))
        end
        ImperiumRow._transientSetUp()
        continuation.run()
    end)
    return continuation
end

---
function ImperiumRow._transientSetUp()
    for i, zone in ipairs(ImperiumRow.slotZones) do
        AcquireCard.new(zone, "Imperium", PlayBoard.withLeader(function (_, color)
            local leader = PlayBoard.getLeader(color)
            leader.acquireImperiumCard(color, i)
        end), Deck.getAcquireCardDecalUrl("generic"))
    end

    AcquireCard.new(ImperiumRow.reservationSlotZone, "Imperium", PlayBoard.withLeader(function (_, color)
        local leader = PlayBoard.getLeader(color)
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

---
function ImperiumRow.acquireReservedImperiumCard(color)
    local cardOrDeck = Helper.getDeckOrCard(ImperiumRow.reservationSlotZone)
    if cardOrDeck then
        PlayBoard.giveCardFromZone(color, ImperiumRow.reservationSlotZone, false)
        return true
    else
        return false
    end
end

---
function ImperiumRow.reserveImperiumCard(indexInRow)
    local zone = ImperiumRow.slotZones[indexInRow]
    local card = Helper.getCard(zone)
    if card then
        if false then
            local oldCard = Helper.getCard(ImperiumRow.reservationSlotZone)
            if oldCard  then
                MainBoard.trash(oldCard)
            end
        end
        card.setPosition(ImperiumRow.reservationSlotZone.getPosition())
        ImperiumRow._replenish(indexInRow)
        return true
    else
        return false
    end
end

---
function ImperiumRow.acquireImperiumCard(indexInRow, color)
    local zone = ImperiumRow.slotZones[indexInRow]
    local card = Helper.getCard(zone)
    if card then
        PlayBoard.giveCard(color, card, false)
        ImperiumRow._replenish(indexInRow)
        return true
    else
        return false
    end
end

---
function ImperiumRow.nuke(color)
    Music.play("atomics")
    Helper.onceTimeElapsed(3).doAfter(function ()
        for i, zone in ipairs(ImperiumRow.slotZones) do
            local card = Helper.getCard(zone)
            if card then
                MainBoard.trash(card)
                ImperiumRow._replenish(i)
            end
        end
    end)
end

---
function ImperiumRow.churn()
    local firstCardIndex = math.random(6)
    local secondCardIndex = math.random(6)
    local count = 0
    for i, zone in ipairs(ImperiumRow.slotZones) do
        if i == firstCardIndex or i == secondCardIndex then
            local card = Helper.getCard(zone)
            MainBoard.trash(card)
            ImperiumRow._replenish(i)
            count = count + 1
        end
    end
    printToAll(I18N("churnImperiumRow", { count = count, card = I18N.agree(count, "card") }), "Pink")
end

---
function ImperiumRow._replenish(indexInRow)
    local position = ImperiumRow.slotZones[indexInRow].getPosition()
    Helper.moveCardFromZone(ImperiumRow.deckZone, position, Vector(0, 180, 0))
end

return ImperiumRow
