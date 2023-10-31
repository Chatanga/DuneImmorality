i18n = require("i18n")
require("locales")

constants = require("Constants")

helperModule = require("HelperModule")

-- Using the zones would be simpler but there are not properly centered.
slotPositions = {
    Vector(-7.61, 1, 20.5),
    Vector(-5.05, 1, 20.5),
    Vector(-2.49, 1, 20.5)
}

slotZoneGUIDs = {
    "323acb",
    "e96c10",
    "93de6d"
}

_ = require("Core").registerLoadablePart(function()
    self.interactable = false
    activateButtons()
end)

function onLocaleChange()
    self.clearButtons()
    activateButtons()
end

function activateButtons()
    local positions = {
        Vector(-0.75, 0.1, 1),
        Vector(0.65, 0.1, 1),
        Vector(2.05, 0.1, 1)
    }

    for i, position in ipairs(positions) do
        self.createButton({
            click_function = "buyOnBlackMarket" .. tostring(i),
            function_owner = self,
            label = i18n("acquireButton"),
            position = position,
            scale = {0.23, 0.5, 0.3},
            width = 1500,
            height = 400,
            font_size = 400,
            color = {0.25, 0.25, 0.25, 1},
            font_color = {1, 1, 1, 1}})
    end
end

function buyOnBlackMarket1(_, color)
    buyOnBlackMarket(1, color)
end

function buyOnBlackMarket2(_, color)
    buyOnBlackMarket(2, color)
end

function buyOnBlackMarket3(_, color)
    buyOnBlackMarket(3, color)
end

function buyOnBlackMarket(slotIndex, color)
    if color ~= "Red" and color ~= "Blue" and color ~= "Green" and color ~= "Yellow" then
        broadcastToColor(i18n("noTouch"), color, "Pink")
        return
    end

    local slotPosition = slotPositions[slotIndex]

    -- Give the card to the current player.
    local card = helperModule.GetDeckOrCardFromGUID(slotZoneGUIDs[slotIndex])
    if card then
        card.setPosition(constants.players[color].pos_discard)
        card.setRotation({0, 180, 0})
    end

    -- Inhibit all buttons.
    self.clearButtons()
    Wait.time(activateButtons, 1)

    -- Populate the slot with a new card.
    local imperiumDeck = helperModule.GetDeckOrCardFromGUID(constants.zone_deck_imperium)
    assert(imperiumDeck and imperiumDeck.type == "Deck")
    imperiumDeck.takeObject({
        position = slotPosition,
        rotation = {0, 180, 0},
        smooth = true,
    })
end

function initBlackMarket()
    -- The zones are at the right places, but the board starts hidden.
    self.setPosition(Vector(-6.2, 0.52, 20.5))
    self.setRotation(Vector(0, 180, 0))

    local imperiumDeck = helperModule.GetDeckOrCardFromGUID(constants.zone_deck_imperium)
    for i, slotPosition in ipairs(slotPositions) do
        Wait.time(function()
            imperiumDeck.takeObject({
                position = slotPosition,
                rotation = Vector(0, 180, 0)
            })
        end, (5 + i) * 0.35)
    end
end

function isInitialised()
    for _, object in pairs(getObjectFromGUID(slotZoneGUIDs[1]).getObjects()) do
        if object == self then
            return true
        end
    end
    return false
end

function updateBlackMarket()
    if not isInitialised() then
        return
    end

    local t = 0
    for _, zoneGUID in ipairs(slotZoneGUIDs) do
        Wait.time(function()
            local card = helperModule.GetDeckOrCardFromGUID(zoneGUID)
            if card then
                card.setPositionSmooth(constants.pos_trash_lower, false, false)
            end
        end, t)
        t = t + 0.25
    end

    for _, slotPosition in ipairs(slotPositions) do
        Wait.time(function()
            local imperiumDeck = helperModule.GetDeckOrCardFromGUID(constants.zone_deck_imperium)
            imperiumDeck.takeObject({
                position = slotPosition,
                rotation = {0, 180, 0},
                smooth = true
            })
        end, t)
        t = t + 0.25
    end
end
