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

    local content = locale[key]
    --Helper.dump(key, "->", content)
    return content and I18N._parse(content, args) or "{" .. key .. "}"
end

function I18N._parse(content, args)
    local text = ""
    local s = 1
    repeat
        local done = true
        local i = string.find(content, "{", s, true)
        if i then
            local e = string.find(content, "}", i, true)
            if e then
                local expression = string.sub(content, i + 1, e - 1)
                local v = I18N._evaluate(expression, args)
                text = text .. string.sub(content, s, i - 1) .. tostring(v or ("{" .. expression .. "}"))
                s = e + 1
                done = false
            end
        end
    until done
    text = text .. string.sub(content, s)
    return text
end

function I18N._evaluate(expression, args)
    return args[expression]
end

setmetatable(I18N, { __call = function(_, ...) return I18N.translate(...) end })

return I18N
