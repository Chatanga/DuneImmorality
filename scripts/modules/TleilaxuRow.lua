local Module = require("utils.Module")
local Helper = require("utils.Helper")
local AcquireCard = require("utils.AcquireCard")
local I18N = require("utils.I18N")

local Deck = Module.lazyRequire("Deck")
local PlayBoard = Module.lazyRequire("PlayBoard")
local TleilaxuResearch = Module.lazyRequire("TleilaxuResearch")
local MainBoard = Module.lazyRequire("MainBoard")

local TleilaxuRow = {}

---
function TleilaxuRow.onLoad(state)
    --Helper.dumpFunction("TleilaxuRow.onLoad(...)")

    Helper.append(TleilaxuRow, Helper.resolveGUIDs(false, {
        deckZone = "14b2ca",
        slotZones = {
            'e5ba35',
            '1e5a32',
            '965fea'
        }
    }))

    if state.settings and state.settings.immortality then
        TleilaxuRow._staticSetUp()
    end
end

---
function TleilaxuRow.setUp(settings)
    if settings.immortality then
        Deck.generateTleilaxuDeck(TleilaxuRow.deckZone).doAfter(function (deck)
            Helper.shuffleDeck(deck)
            Helper.onceShuffled(deck).doAfter(function ()
                for i = 1, 2 do
                    local zone = TleilaxuRow.slotZones[i]
                    Helper.moveCardFromZone(TleilaxuRow.deckZone, zone.getPosition(), Vector(0, 180, 0))
                end
            end)
        end)
        Deck.generateSpecialDeck("immortality", "reclaimedForces", TleilaxuRow.slotZones[3])

        TleilaxuRow._staticSetUp()
    else
        TleilaxuRow._tearDown()
    end
end

---
function TleilaxuRow._staticSetUp()
    TleilaxuRow.acquireCards = {}
    for i, zone in ipairs(TleilaxuRow.slotZones) do
        local acquireCard = AcquireCard.new(zone, "Imperium", PlayBoard.withLeader(function (_, color)
            PlayBoard.getLeader(color).acquireTleilaxuCard(color, i)
        end))
        table.insert(TleilaxuRow.acquireCards, acquireCard)
    end
end

---
function TleilaxuRow._tearDown()
    TleilaxuRow.deckZone.destruct()
    for _, slotZone in ipairs(TleilaxuRow.slotZones) do
        slotZone.destruct()
    end
end

---
function TleilaxuRow.acquireTleilaxuCard(indexInRow, color)
    local acquireCard = TleilaxuRow.acquireCards[indexInRow]
    local card = Helper.getCard(acquireCard.zone)
    assert(card)
    local price = ImperiumCard.getTleilaxuCardCost(card)
    local cardName = Helper.getID(card)
    assert(price, "Unknown tleilaxu card: " .. cardName)
    assert((cardName == "reclaimedForces") == (indexInRow == 3))

    if card and TleilaxuResearch.getSpecimenCount(color) >= price then
        local leader = PlayBoard.getLeader(color)
        if cardName == "reclaimedForces" then
            local options = {
                I18N("troops"),
                I18N("beetle"),
            }
            Player[color].showOptionsDialog(I18N("reclaimedForces"), options, 1, function (_, index, _)
                if index == 1 then
                    leader.troops(color, "tanks", "supply", price)
                    leader.troops(color, "supply", "garrison", 2)
                elseif index == 2 then
                    leader.troops(color, "tanks", "supply", price)
                    leader.beetle(color, 1)
                end
            end)
        else
            leader.troops(color, "tanks", "supply", price)

            PlayBoard.giveCard(color, card, true)

            -- Replenish the slot in the row.
            Helper.moveCardFromZone(TleilaxuRow.deckZone, acquireCard.zone.getPosition(), Vector(0, 180, 0))
        end

        return true
    else
        return false
    end
end

---
function TleilaxuRow.trash(indexInRow)
    local acquireCard = TleilaxuRow.acquireCards[indexInRow]
    local card = Helper.getCard(acquireCard.zone)
    assert(card)
    local price = ImperiumCard.getTleilaxuCardCost(card)
    local cardName = Helper.getID(card)
    assert(price, "Unknown tleilaxu card: " .. cardName)
    assert((cardName == "reclaimedForces") == (indexInRow == 3))

    MainBoard.trash(card)

    -- Replenish the slot in the row.
    Helper.moveCardFromZone(TleilaxuRow.deckZone, acquireCard.zone.getPosition(), Vector(0, 180, 0))
end

return TleilaxuRow
