local Core = require("utils.Core")
local Helper = require("utils.Helper")
local AcquireCard = require("utils.AcquireCard")

local Deck = Helper.lazyRequire("Deck")
local Playboard = Helper.lazyRequire("Playboard")

local ImperiumRow = {}

---
function ImperiumRow.onLoad(state)
    Helper.append(ImperiumRow, Core.resolveGUIDs(true, {
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

    AcquireCard.new(ImperiumRow.reservationSlotZone, "Imperium", ImperiumRow.acquireReservedImperiumCard)
    for _, zone in ipairs(ImperiumRow.slotZones) do
        AcquireCard.new(zone, "Imperium", ImperiumRow.acquireImperiumCard)
    end
end

---
function ImperiumRow.setUp(ix, immortality)
    Deck.generateImperiumDeck(ImperiumRow.deckZone, ix, immortality).doAfter(function (deck)
        deck.shuffle()
        for _, zone in ipairs(ImperiumRow.slotZones) do
            Helper.moveCardFromZone(ImperiumRow.deckZone, zone.getPosition(), Vector(0, 180, 0), false, false)
        end
    end)
end

---
function ImperiumRow.acquireReservedImperiumCard(acquireCard, color)
    if Playboard.is(color, "helenaRichese") then
        local card = Helper.getCard(acquireCard.zone)
        Playboard.giveCard(color, card, false)
    end
end

---
function ImperiumRow.acquireImperiumCard(acquireCard, color)
    local card = Helper.getCard(acquireCard.zone)
    if card then
        if Playboard.is(color, "helenaRichese") and not Playboard.hasRevealed(color) then
            -- Simply reserve the card.
            card.setPosition(ImperiumRow.reservationSlotZone.getPosition())
        else
            Playboard.giveCard(color, card, false)
        end

        -- Replenish the slot in the row.
        Helper.moveCardFromZone(ImperiumRow.deckZone, acquireCard.zone.getPosition(), Vector(0, 180, 0), false, false)
    end
end

---
function ImperiumRow.nuke(_, color)
    local t = 0
    self.clearButtons()

    local secondaryTable = getObjectFromGUID("662ced")
    if secondaryTable.getVar("sound_active") then
        t = 2
        MusicPlayer.setCurrentAudioclip({
            url = "http://cloud-3.steamusercontent.com/ugc/2002447125408335433/56A15AA85A1C45DE92FA3FD2372F0ECE6ABA0495/",
            title = "Explosion"
        })
    end

    Wait.time(function()
        for i = 1, 5, 1 do
            local slot = constants.structure.imperium.imperiumRowSlots[i]
            helper.moveCardFromZoneGUID(slot.zoneGuid, constants.lowerTrashPosition, Vector(0, 180, 0), false)
            helper.moveCardFromZoneGUID(constants.imperiumDeckZone, slot.pos, Vector(0, 180, 0), true)
        end

        self.destruct()

        local leaderName = helper.getLeaderName(color)
        broadcastToAll(leaderName .. i18n("atomicsUsed"), color)
    end, t)
end

return ImperiumRow
