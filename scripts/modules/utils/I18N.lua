local Helper = require("utils.Helper")

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
    Helper.emitEvent("locale", newLocale)
end

---
function I18N.agree(quantity, noun)
    if math.abs(quantity) > 1 then
        return I18N(noun .. "s")
    else
        return I18N(noun)
    end
end

---
function I18N.translate(key, args)
    local currentLocale = I18N.getLocale()
    -- FIXME Temporary
    if not currentLocale then
        currentLocale = "fr"
    end
    local locale = I18N.locales[currentLocale]
    if not locale then
        error("Missing locale: " .. currentLocale)
    end

    local value = locale[key]
    local text
    if value then
        text = ""
        local s = 1
        repeat
            local done = true
            local i = string.find(value, "{", s, true)
            if i then
                local e = string.find(value, "}", i, true)
                if e then
                    local argName = string.sub(value, i + 1, e - 1)
                    text = text .. string.sub(value, s, i - 1) .. tostring(args[argName] or ("{" .. argName .. "}"))
                    s = e + 1
                    done = false
                end
            end
        until done
        text = text .. string.sub(value, s)
    else
        text = "{" .. key .. "}"
    end
    return text
end

setmetatable(I18N, { __call = function(_, ...) return I18N.translate(...) end })

return I18N
