local Module = require("utils.Module")
local Helper = require("utils.Helper")
local AcquireCard = require("utils.AcquireCard")

local Deck = Module.lazyRequire("Deck")
local Playboard = Module.lazyRequire("Playboard")
local TleilaxuResearch = Module.lazyRequire("TleilaxuResearch")
local Action = Module.lazyRequire("Action")
local ImperiumCard = Module.lazyRequire("ImperiumCard")

local TleilaxuRow = {}

---
function TleilaxuRow.onLoad(state)
    Helper.append(TleilaxuRow, Helper.resolveGUIDs(true, {
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
        TleilaxuRow._staticSetUp()
    else
        TleilaxuRow._tearDown()
    end
end

---
function TleilaxuRow._staticSetUp()
    Deck.generateTleilaxuDeck(TleilaxuRow.deckZone).doAfter(function (deck)
        deck.shuffle()
        for i = 1, 2 do
            local zone = TleilaxuRow.slotZones[i]
            Helper.moveCardFromZone(TleilaxuRow.deckZone, zone.getPosition(), Vector(0, 180, 0), false, false)
        end
    end)
    Deck.generateSpecialDeck("reclaimedForces", TleilaxuRow.slotZones[3])

    TleilaxuRow.acquireCards = {}
    for i, zone in ipairs(TleilaxuRow.slotZones) do
        local acquireCard = AcquireCard.new(zone, "Imperium", function (_, color)
            Action.acquireTleilaxuCard(color, i)
        end)
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
    local price = ImperiumCard.getTleilaxuCardCost(card)
    local cardName = card.getDescription()
    assert(price, "Unknown tleilaxu card: " .. cardName)
    assert((cardName == "reclaimedForces") == (indexInRow == 3))

    if card and TleilaxuResearch.getSpecimenCount(color) >= price then
        local leader = Playboard.getLeader(color)
        if cardName == "reclaimedForces" then
            local options = {
                "Troops",
                "Beetle"
            }
            Player[color].showOptionsDialog("Reclaimed forces", options, 1, function (_, index, _)
                if index == 1 then
                    leader.troops(color, "tanks", "supply", price)
                    leader.troops(color, "supply", "garrison", 2)
                elseif index == 2 then
                    leader.troops(color, "tanks", "supply", price)
                    leader.beetle(color, 1)
                end
            end)
            return true
        else
            leader.troops(color, "tanks", "supply", price)

            Playboard.giveCard(color, card, false)

            -- Replenish the slot in the row.
            Helper.moveCardFromZone(TleilaxuRow.deckZone, acquireCard.zone.getPosition(), Vector(0, 180, 0), false, false)
            return true
        end
    else
        return false
    end
end

return TleilaxuRow
