i18n = require("i18n")
require("locales")

helperModule = require("HelperModule")

_ = require("Core").registerLoadablePart(function()
    activateButton()
end)

function onLocaleChange()
    self.clearButtons()
    activateButton()
end

function activateButton()
    self.createButton({
        click_function = 'drawCard',
        function_owner = self,
        label = i18n("drawIntrigueButton"),
        position = helperModule.correctAnchorPosition({0, 120, -0.5}, {1.62645662, 0.006505827, 2.27703953}),
        rotation = {0, 180, 0},
        width = 400,
        height = 10,
        color = {0.25, 0.25, 0.25},
        font_color = {1.00, 1.00, 1.00},
        font_size = 80
    })
end

function drawCard(_,color)
    local intrigueDeck = helperModule.GetDeckOrCardFromGUID("a377d8")
    assert(intrigueDeck, 'Where is the Intrigue Deck ???')

    self.clearButtons()
    Wait.time(function() activateButton() end, 1)
    local handZone = Player[color].getHandTransform()
    local deckRot = intrigueDeck.getRotation()
    if intrigueDeck.type == "Deck" then
        local my_card = intrigueDeck.takeObject({
            position = {handZone.position.x-7.5, handZone.position.y, handZone.position.z},
            flip = false,
            smooth = false})
        Wait.time(function()
            my_card.flip()
        end,0.2)
    else
        intrigueDeck.setPosition({handZone.position.x-7.5, handZone.position.y, handZone.position.z}, false, true)
        intrigueDeck.setRotation({deckRot.x, deckRot.y, deckRot.z+180})
    end
    broadcastToAll(helperModule.getLeaderName(color) ..i18n("drawIntrigue"), color)
end
