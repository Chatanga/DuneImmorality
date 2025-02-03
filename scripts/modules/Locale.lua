local I18N = require("utils.I18N")

local Locale = {}

---@param state table
function Locale.onLoad(state)
    I18N.locales.en = require("en.Locale")
    I18N.locales.fr = require("fr.Locale")
    if state.settings then
        I18N.setLocale(state.settings.language)
    end
end

---@param settings Settings
function Locale.setUp(settings)
    I18N.setLocale(settings.language)
end

---@return table<string, string>
function Locale.getAllLocales()
    return {
        "en",
        "fr"
    }
end

return Locale
