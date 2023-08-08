local Core = require("utils.Core")
local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

local TurnControl = Helper.lazyRequire("TurnControl")
local Playboard = Helper.lazyRequire("Playboard")

local Resource = {
    MIN_VALUE = 0,
    MAX_VALUE = 99,
    resources = {}
}

---
function Resource.new(token, color, resourceName, value, state)
    --log("Resource.new(_, " .. tostring(color) .. ", " .. tostring(resourceName) .. ", " .. tostring(value) .. ", _)")

    token.interactable = false

    local resource = Helper.newObject(Resource, {
        token = token,
        color = color,
        resourceName = resourceName,
        value = value,
        laggingValue = value,
        state = Helper.createTable(state, resourceName, color)
    })
    Resource.resources[token.getGUID()] = resource

    if #resource.state > 0 then
        resource.value = state.value
        resource.laggingValue = state.laggingValue
    end

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

    local offset = Vector(0, 0.1, -0.05)
    if resourceName == "water" then
        offset = Vector(0, 0.1, -0.25)
    end

    Helper.createAbsoluteButtonWithRoundness(token, 1, false, {
        label = tostring(resource.value),
        click_function = "Resource_" .. ((resource.color ~= nil) and "changeValue" or "setValue"),
        tooltip = resource:getTooltip(),
        position = token.getPosition() + offset,
        height = 800,
        width = 800,
        scale = scales[resourceName],
        alignment = 3,
        font_size = 600,
        font_color = fontColors[resourceName],
        color = { 0, 0, 0, 0 }
    })

    Core.registerEventListener("locale", token.getGUID(), function ()
        resource:updateButton()
    end)

    resource:updateButton()

    return resource
end

---
function Resource:updateState()
    -- Do *not* change self.state reference!
    self.state.value = self.value
    self.state.laggingValue = self.laggingValue
end

---
function Resource:getTooltip()
    return self.value .. " " .. I18N.translateCountable(self.value, self.resourceName, self.resourceName .. "s")
end

---
function Resource:updateButton()
    self.token.editButton({
        index = 0,
        label = tostring(self.value),
        tooltip = self:getTooltip()
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
function Resource_setValue(token, _, altClick)
    local self = Resource.findResourceFromToken(token)
    assert(self)

    local change = altClick and -1 or 1
    local newValue = math.min(math.max(self.value + change, self.MIN_VALUE), self.MAX_VALUE)
    if self.value ~= newValue then
        self.value = newValue
        self.laggingValue = self.value
        self:updateButton()
        self:updateState()
    end
end

---
function Resource_changeValue(token, color, altClick)
    local self = Resource.findResourceFromToken(token)
    assert(self)

    local playerActingStr = ""
    local msgColor = color

    local playerCount = TurnControl.getPlayerCount()

    if color ~= self.color and playerCount < 3 then
        playerActingStr = I18N("playerActing"):format(I18N(color:lower()))
        msgColor = "Pink"
    end

    if color ~= self.color and playerCount > 2 then
        broadcastToColor(I18N("noTouch"), color, color)
        return
    end

    local change = altClick and -1 or 1
    local newValue = math.min(math.max(self.value + change, self.MIN_VALUE), self.MAX_VALUE)
    if self.value ~= newValue then
        self.value = newValue
        self:updateButton()
        self:updateState()

        if self.laggingUpdate then
            Wait.stop(self.laggingUpdate)
        end

        self.laggingUpdate = Wait.time(function()
            local delta = math.abs(self.value - self.laggingValue)
            local label = I18N.translateCountable(delta, self.resourceName, self.resourceName .. "s")

            if self.color then
                local leaderName = Playboard.getLeaderName(self.color)
                if delta < 0 then
                    local text = I18N("spentManually"):format(leaderName, math.abs(delta), label)
                    broadcastToAll(text .. playerActingStr, msgColor)
                elseif delta > 0 then
                    local text = I18N("receiveManually"):format(leaderName, math.abs(delta), label)
                    broadcastToAll(text .. playerActingStr, msgColor)
                end
            end

            self.laggingValue = self.value
            self:updateState()
        end, 1)
    end
end

---
function Resource:change(change)
    local newValue = math.min(math.max(self.value + change, self.MIN_VALUE), self.MAX_VALUE)
    self.value = newValue
    self.laggingValue = self.value
    self:updateButton()
    self:updateState()
end

---
function Resource:set(value)
    local newValue = math.min(math.max(value, self.MIN_VALUE), self.MAX_VALUE)
    self.value = newValue
    self.laggingValue = value
    self:updateButton()
    self:updateState()
end

---
function Resource:get()
    return self.value
end

return Resource
