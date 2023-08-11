local Module = require("utils.Module")
local Helper = require("utils.Helper")
local I18N = require("utils.I18N")
local AcquireCard = require("utils.AcquireCard")

local Deck = Module.lazyRequire("Deck")
local Playboard = Module.lazyRequire("Playboard")
local TleilaxuResearch = Module.lazyRequire("TleilaxuResearch")

local TleilaxuRow = {}

---
function TleilaxuRow.onLoad(_)
    Helper.append(TleilaxuRow, Helper.resolveGUIDs(true, {
        deckZone = "14b2ca",
        slotZones = {
            'e5ba35',
            '1e5a32',
            '965fea'
        }
    }))

    for _, zone in ipairs(TleilaxuRow.slotZones) do
        AcquireCard.new(zone, "Imperium", TleilaxuRow.acquireTleilaxuImperiumCard)
    end
end

---
function TleilaxuRow.setUp()
    Deck.generateTleilaxuDeck(TleilaxuRow.deckZone).doAfter(function (deck)
        deck.shuffle()
        for i = 1, 2 do
            local zone = TleilaxuRow.slotZones[i]
            Helper.moveCardFromZone(TleilaxuRow.deckZone, zone.getPosition(), Vector(0, 180, 0), false, false)
        end
    end)
    Deck.generateSpecialDeck("reclaimedForces", TleilaxuRow.slotZones[3])
end

---
function TleilaxuRow.tearDown()
    -- NOP
end

---
function TleilaxuRow.acquireTleilaxuImperiumCard(acquireCard, color)
    local card = Helper.getCard(acquireCard.zone)
    if TleilaxuRow.paySpecimenPrice(color, card) then
        Playboard.giveCard(color, card, true)

        -- Replenish the slot in the row.
        Helper.moveCardFromZone(TleilaxuRow.deckZone, acquireCard.zone.getPosition(), Vector(0, 180, 0), false)
    end
end

---
function TleilaxuRow.paySpecimenPrice(color, card)
    local setup = getObjectFromGUID("4a3e76")
    local price = setup.call("getTleilaxuCardPrice", card)

    local specimenCount = TleilaxuResearch.getSpecimenCount(color)

    if price > specimenCount then
        broadcastToColor(I18N("notEnoughSpecimen"), color, "Red")
        return false
    end

    Wait.time(
        function()
            getObjectFromGUID("d5c2db").Call("RemoveSpecimenCall", {color = color, silent = true})
        end,
        0.3, price)

    local specimen = I18N("specimens")
    if price == 1 then
        specimen = I18N("specimen")
    end

    local leaderName = Helper.getLeaderName(color)
    broadcastToAll(I18N("acquiredTleilaxu"):format(leaderName, price, specimen), color)

    return true
end

return TleilaxuRow
