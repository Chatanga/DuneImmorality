local I18N = require("utils.I18N")

local Locale = {}

---
function Locale.onLoad(state)
    I18N.locales.en = require("en.Locale")
    I18N.locales.fr = require("fr.Locale")
    I18N.locales.jp = require("jp.Locale")
end

return Locale
