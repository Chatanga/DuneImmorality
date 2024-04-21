local Module = require("utils.Module")
local Helper = require("utils.Helper")
local I18N = require("utils.I18N")
local Dialog = require("utils.Dialog")

local PlayBoard = Module.lazyRequire("PlayBoard")
local Types = Module.lazyRequire("Types")

local Resource = Helper.createClass(nil, {
    MIN_VALUE = 0,
    MAX_VALUE = 99,
    resources = {}
})

---
function Resource.new(token, color, resourceName, value, location)
    assert(token)
    Types.assertIsResourceName(resourceName)
    Types.assertIsPositiveInteger(value)

    token.interactable = false

    local resource = Helper.createClassInstance(Resource, {
        token = token,
        color = color,
        resourceName = resourceName,
        value = value,
        laggingValue = value,
        location = location,
    })
    Resource.resources[token.getGUID()] = resource

    local fontColors = {
        spice = { 0.9, 0.9, 0.9, 100 },
        water = { 0.2, 0.2, 0.5, 100 },
        solari = { 0.2, 0.2, 0.2, 100 },
        persuasion = { 0.9, 0.9, 0.9, 100 },
        strength = { 0.9, 0.6, 0.3, 100 },
    }

    local scales = {
        spice = Vector(1.8, 1, 1.8) * Helper.toVector(token.getScale()),
        water = Vector(1.8, 1, 1.8) * Helper.toVector(token.getScale()),
        solari = Vector(1.8, 1, 1.8) * Helper.toVector(token.getScale()),
        persuasion = Vector(0.9, 1, 0.9),
        strength = Vector(0.9, 1, 0.9),
    }

    local offset = Vector(
        0,
        0.1 * token.getScale().y,
        resourceName == "water" and -0.25 or -0.0)

    Helper.createAbsoluteButtonWithRoundness(token, 1, {
        label = tostring(resource.value),
        click_function = Helper.registerGlobalCallback(function (_, otherColor, altClick)
            if resource.color or resource.location then
                resource:_changeValue(otherColor, altClick)
            else
                resource:_setValue(otherColor, altClick)
            end
        end),
        tooltip = resource:_getTooltip(),
        position = token.getPosition() + offset,
        height = (color or location) and 800,
        width = (color or location) and 800,
        scale = scales[resourceName],
        alignment = 3,
        font_size = 600,
        font_color = fontColors[resourceName],
        color = { 0, 0, 0, 0 }
    })

    Helper.registerEventListener("locale", function ()
        resource:_updateButton()
    end)

    resource:_updateButton()

    return resource
end

---
function Resource:_updateState()
    if self.value == self.laggingValue then
        Helper.emitEvent(self.resourceName .. "ValueChanged", self.color, self.value)
    end
end

---
function Resource:_getTooltip()
    return I18N(self.resourceName .. "Amount", self.value)
end

---
function Resource:_updateButton()
    self.token.editButton({
        index = 0,
        label = tostring(self.value),
        tooltip = self:_getTooltip()
    })
end

---
function Resource.findResourceFromToken(token)
    for _, resource in pairs(Resource.resources) do
        if resource.token == token then
            return resource
        end
    end
    return nil
end

---
function Resource:_setValue(_, altClick)
    local change = altClick and -1 or 1
    local newValue = math.min(math.max(self.value + change, self.MIN_VALUE), self.MAX_VALUE)
    if self.value ~= newValue then
        self.value = newValue
        self.laggingValue = self.value
        self:_updateButton()
        self:_updateState()
    end
end

---
function Resource:_changeValue(color, altClick)
    if self.color and color ~= self.color then
        Dialog.broadcastToColor(I18N("noTouch"), color, color)
        return
    end

    local change = altClick and -1 or 1
    local newValue = math.min(math.max(self.value + change, self.MIN_VALUE), self.MAX_VALUE)
    if self.value ~= newValue then
        self.value = newValue
        self:_updateButton()
        self:_updateState()

        if self.laggingUpdate then
            Wait.stop(self.laggingUpdate)
        end

        self.laggingUpdate = Wait.time(function ()
            local delta = self.value - self.laggingValue

            if self.color then
                local leaderName = PlayBoard.getLeaderName(self.color)
                if delta < 0 then
                    local text = I18N("spendManually", { leader = leaderName, amount = -delta, resource = I18N.agree(delta, self.resourceName) })
                    broadcastToAll(text, color)
                elseif delta > 0 then
                    local text = I18N("receiveManually", { leader = leaderName, amount = delta, resource = I18N.agree(delta, self.resourceName) })
                    broadcastToAll(text, color)
                end
            else
                local text = I18N("fixManually", { location = I18N(self.location), amount = delta, resource = I18N.agree(delta, self.resourceName) })
                broadcastToAll(text, color)
            end

            self.laggingValue = self.value
            self:_updateState()
        end, 1)
    end
end

---
function Resource:change(change)
    local newValue = math.min(math.max(self.value + change, self.MIN_VALUE), self.MAX_VALUE)
    self.value = newValue
    self.laggingValue = self.value
    self:_updateButton()
    self:_updateState()
end

---
function Resource:set(value)
    local newValue = math.min(math.max(value, self.MIN_VALUE), self.MAX_VALUE)
    self.value = newValue
    self.laggingValue = value
    self:_updateButton()
    self:_updateState()
end

---
function Resource:get()
    return self.value
end

return Resource
