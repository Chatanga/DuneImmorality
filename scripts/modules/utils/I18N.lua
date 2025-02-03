local Helper = require("utils.Helper")

---@class I18N
local I18N = {
    locales = {}
}

---@return string
function I18N.getLocale()
    return Global.getVar("Locale")
end

---@param newLocale string
function I18N.setLocale(newLocale)
    assert(I18N.locales[newLocale], ("The locale %q is unknown"):format(newLocale))
    Global.setVar("Locale", newLocale)
    Helper.emitEvent("locale", newLocale)
end

---@param quantity number
---@param noun string
---@return string
function I18N.agree(quantity, noun)
    if math.abs(quantity) > 1 then
        return I18N(noun .. "s")
    else
        return I18N(noun)
    end
end

---@param key string
---@param args table<string, any>
---@return string
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

---@param content string
---@param args table<string, any>
---@return string
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

---@param expression string
---@param args table<string, any>
---@return any
function I18N._evaluate(expression, args)
    return args[expression]
end

setmetatable(I18N, { __call = function (_, ...) return I18N.translate(...) end })

---@overload fun(key: string, parameters?: table<string, any>): string

return I18N
