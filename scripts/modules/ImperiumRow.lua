local Module = require("utils.Module")
local Helper = require("utils.Helper")
local AcquireCard = require("utils.AcquireCard")

local Deck = Module.lazyRequire("Deck")
local Playboard = Module.lazyRequire("Playboard")
local Action = Module.lazyRequire("Action")
local Utils = Module.lazyRequire("Utils")

local ImperiumRow = {}

---
function ImperiumRow.onLoad(state)
    Helper.append(ImperiumRow, Helper.resolveGUIDs(true, {
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
        ImperiumRow._staticSetUp()
    end
end

---
function ImperiumRow.setUp(settings)
    Deck.generateImperiumDeck(ImperiumRow.deckZone, settings.riseOfIx, settings.immortality).doAfter(function (deck)
        deck.shuffle()
        for _, zone in ipairs(ImperiumRow.slotZones) do
            Helper.moveCardFromZone(ImperiumRow.deckZone, zone.getPosition(), Vector(0, 180, 0), false, false)
        end
    end)
    ImperiumRow._staticSetUp()
end

---
function ImperiumRow._staticSetUp()
    AcquireCard.new(ImperiumRow.reservationSlotZone, "Imperium", nil)
    for i, zone in ipairs(ImperiumRow.slotZones) do
        AcquireCard.new(zone, "Imperium", function (_, color)
            Action.acquireImperiumCard(color, i)
        end)
    end
end

---
function ImperiumRow.acquireReservedImperiumCard(color)
    local card = Helper.getCard(ImperiumRow.reservationSlotZone)
    if card then
        Playboard.giveCard(color, card, false)
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
        Playboard.giveCard(color, card, false)
        ImperiumRow._replenish(indexInRow)
        return true
    else
        return false
    end
end

---
function ImperiumRow.nuke(color)
    local secondaryTable = getObjectFromGUID("662ced")
    if secondaryTable.getVar("sound_active") then
        MusicPlayer.setCurrentAudioclip({
            url = "http://cloud-3.steamusercontent.com/ugc/2002447125408335433/56A15AA85A1C45DE92FA3FD2372F0ECE6ABA0495/",
            title = "Explosion"
        })
    end

    for i, zone in ipairs(ImperiumRow.slotZones) do
        local card = Helper.getCard(zone)
        if card then
            Utils.trash(card)
            ImperiumRow._replenish(i)
        end
    end
end

---
function ImperiumRow._replenish(indexInRow)
    local position = ImperiumRow.slotZones[indexInRow].getPosition()
    Helper.moveCardFromZone(ImperiumRow.deckZone, position, Vector(0, 180, 0), false, false)
end

return ImperiumRow
