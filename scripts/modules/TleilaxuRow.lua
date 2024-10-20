local Module = require("utils.Module")
local Helper = require("utils.Helper")
local AcquireCard = require("utils.AcquireCard")
local I18N = require("utils.I18N")
local Dialog = require("utils.Dialog")

local Deck = Module.lazyRequire("Deck")
local PlayBoard = Module.lazyRequire("PlayBoard")
local TleilaxuResearch = Module.lazyRequire("TleilaxuResearch")
local MainBoard = Module.lazyRequire("MainBoard")
local ImperiumCard = Module.lazyRequire("ImperiumCard")
local Commander = Module.lazyRequire("Commander")

local TleilaxuRow = {}

---
function TleilaxuRow.onLoad(state)
    Helper.append(TleilaxuRow, Helper.resolveGUIDs(false, {
        deckZone = "14b2ca",
        slotZones = {
            'e5ba35',
            '1e5a32',
            '965fea',
        }
    }))

    if state.settings and state.settings.immortality then
        TleilaxuRow._transientSetUp()
    end
end

---
function TleilaxuRow.setUp(settings)
    local continuation = Helper.createContinuation("TleilaxuRow.setUp")
    if settings.immortality then
        Deck.generateSpecialDeck(TleilaxuRow.slotZones[3], "immortality", "reclaimedForces")
        Deck.generateTleilaxuDeck(TleilaxuRow.deckZone).doAfter(function (deck)
            assert(deck, "No Tleilaxu deck!")
            Helper.shuffleDeck(deck)
            Helper.onceShuffled(deck).doAfter(function ()
                for i = 1, 2 do
                    local zone = TleilaxuRow.slotZones[i]
                    Helper.moveCardFromZone(TleilaxuRow.deckZone, zone.getPosition(), Vector(0, 180, 0))
                end
            end)
            TleilaxuRow._transientSetUp()
            continuation.run()
        end)
    else
        TleilaxuRow._tearDown()
        continuation.run()
    end
    return continuation
end

---
function TleilaxuRow._transientSetUp()
    TleilaxuRow.acquireCards = {}
    for i, zone in ipairs(TleilaxuRow.slotZones) do
        local acquireCard = AcquireCard.new(zone, "Imperium", PlayBoard.withLeader(function (_, color)
            PlayBoard.getLeader(color).acquireTleilaxuCard(color, i)
        end), Deck.getAcquireCardDecalUrl("generic"))
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
    assert(price, "Unknown tleilaxu card: " .. tostring(cardName))
    assert((cardName == "reclaimedForces") == (indexInRow == 3))

    local specimenSupplierColor = color
    if Commander.isCommander(color) then
        specimenSupplierColor = Commander.getActivatedAlly(color)
    end

    if TleilaxuResearch.getSpecimenCount(specimenSupplierColor) >= price then
        local leader = PlayBoard.getLeader(color)
        if cardName == "reclaimedForces" then
            local options = {
                I18N("troops"),
                I18N("beetle"),
            }
            Dialog.showOptionsDialog(color, I18N("reclaimedForces"), options, nil, function (index)
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
        Dialog.broadcastToColor(I18N("noEnoughSpecimen"), color, "Purple")
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
    assert(price, "Unknown tleilaxu card: " .. tostring(cardName))
    assert((cardName == "reclaimedForces") == (indexInRow == 3))

    MainBoard.trash(card)

    -- Replenish the slot in the row.
    Helper.moveCardFromZone(TleilaxuRow.deckZone, acquireCard.zone.getPosition(), Vector(0, 180, 0))
end

return TleilaxuRow
