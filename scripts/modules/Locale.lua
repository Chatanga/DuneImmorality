local I18N = require("utils.I18N")

local Locale = {}

---
function Locale.onLoad()
    I18N.locales.en = require("en.Locale")
    I18N.locales.fr = require("fr.Locale")
end

return Locale
