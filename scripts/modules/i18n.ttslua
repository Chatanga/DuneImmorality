local i18n = {
    locales = {}
}

_ = require("Core").registerLoadablePart(function()
end)

function i18n.getLocale()
    return Global.getVar("locale")
end

function i18n.setLocale(newLocale)
    assert(i18n.locales[newLocale], ("The locale '%q' is unknown"):format(newLocale))
    Global.setVar("locale", newLocale)
end

local function translate(id)
    local currentLocale = i18n.getLocale()
    local result = i18n.locales[currentLocale][id]
    assert(result, ("The id %q was not found in the current locale (%q)"):format(id, currentLocale))
    return result
end

i18n.translate = translate

setmetatable(i18n, {__call = function(_, ...) return i18n.translate(...) end})

return i18n
