i18n = require("i18n")
require("locales")

buyModule = require("BuyModule")

constants = require("Constants")

helperModule = require("HelperModule")

_ = require("Core").registerLoadablePart(function()
    self.interactable = false

    imperiumColumn = constants.imperiumRow[3]
    Zone = getObjectFromGUID(imperiumColumn.zoneGuid)
    pos = imperiumColumn.pos
    activateButton()
end)

function onLocaleChange()
    self.clearButtons()
    activateButton()
end

function activateButton()
    self.createButton({
        label = i18n("acquireButton"),
        click_function = "Buy",
        function_owner = self,
        position = helperModule.correctAnchorPosition({0, 3, 1.4}, {1.37866032, 0.165157527, 1.34989369}),
        scale = {0.3, 0.3, 0.4},
        color = {0.25, 0.25, 0.25, 1},
        font_color = {1, 1, 1, 1},
        height = 400,
        width = 1600,
        font_size = 400,
        rotation = {0, 0, 0}
    })
end

function Buy(object, pColor) buyModule.Buy(Zone, pColor, pos, activateButton) end