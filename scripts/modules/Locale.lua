local I18N = require("utils.I18N")

local Locale = {}

---
function Locale.onLoad(state)
    I18N.locales.en = require("en.Locale")
    I18N.locales.fr = require("fr.Locale")
    if state.settings then
        I18N.setLocale(state.settings.language)
    end
end

---
function Locale.setUp(settings)
    I18N.setLocale(settings.language)
end

return Locale
