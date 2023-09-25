local I18N = {
    locales = {}
}

---
function I18N.getLocale()
    return Global.getVar("Locale")
end

---
function I18N.setLocale(newLocale)
    assert(I18N.locales[newLocale], ("The locale '%q' is unknown"):format(newLocale))
    Global.setVar("Locale", newLocale)
end

---
function I18N.translateCountable(count, singular, plural)
    if count == 1 then
        return I18N(singular)
    else
        return I18N(plural)
    end
end

---
function I18N.translate(id)
    local currentLocale = I18N.getLocale()
    -- TODO Temporary
    if not currentLocale then
        currentLocale = "fr"
    end
    local result = I18N.locales[currentLocale][id]
    -- assert(result, ("The id %q was not found in the current locale (%q)"):format(id, currentLocale))
    if not result then
        result = "{" .. id .. "}"
    end
    return result
end

setmetatable(I18N, { __call = function(_, ...) return I18N.translate(...) end })

return I18N
