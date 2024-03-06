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
    assert(I18N.locales[newLocale], ("The locale %q is unknown"):format(newLocale))
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
    assert(key)
    assert(type(key) == "string", type(string))
    local currentLocale = I18N.getLocale()
    if not currentLocale then
        currentLocale = "en"
    end
    local locale = I18N.locales[currentLocale]
    if not locale then
        error("Missing locale: " .. currentLocale)
    end

    local content = locale[key]
    assert(not content or type(content) == "string", key)
    return content and I18N._parse(content, args) or "{" .. key .. "}"
end

function I18N._parse(content, args)
    assert(content)
    assert(type(content) == "string", type(string))
    local text = ""
    local s = 1
    repeat
        local done = true
        local i = content:find("{", s, true)
        if i then
            local e = content:find("}", i, true)
            if e then
                local expression = content:sub(i + 1, e - 1)
                local v = I18N._evaluate(expression, args)
                text = text .. content:sub(s, i - 1) .. tostring(v or ("{" .. expression .. "}"))
                s = e + 1
                done = false
            end
        end
    until done
    text = text .. content:sub(s)
    return text
end

function I18N._evaluate(expression, args)
    return args[expression]
end

setmetatable(I18N, { __call = function (_, ...) return I18N.translate(...) end })

return I18N
