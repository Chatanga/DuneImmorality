require("utils.Core")

local Utils = {}

---
function Utils.isUnit(color, object)
    return isTroop(color, object) or isDreadnought(color, object)
end

---
function Utils.isTroop(color, object)
    return object.getName() == color
end

---
function Utils.isDreadnought(color, object)
    return object.getName() == color .. " Dreadnought" or object.getName() == color .. " dreadnought"
end

---
function Utils.isFlag(color, object)
    return object.getName() == color .. " Flag"
end

---
function Utils.isAgent(color, object)
    assert(object.getDescription() == "Agent" == object.hasTag("Agent"))
    local name = object.getName()
    return
        name == "" .. color .. " Agent" or
        name == "" .. color .. " Swordmaster" or
        name == "Mentat" -- TODO Check the Mentat ownership.
end

---
function Utils.isMentat(object)
    return object.getName() == "Mentat"
end

--[[
function MainBoard.createUpDownButton(factionPrefix, label, position)
    local parameters = {
        function_owner = self,
        scale = {0.15, 0.100000001490116, 0.100000001490116},
        width = 300,
        height = 450,
        font_size = 350,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1},
        tooltip = I18N("toolTipDecreaseRep")
    }

    parameters.click_function = factionPrefix .. "Down"
    parameters.label = "↓"
    parameters.tooltip = I18N("toolTipDecreaseRep")
    parameters.position = Utils.toVector(position) + Vector(0, 0, 0.05)
    self.createButton(parameters)

    parameters.click_function = factionPrefix .. "Up"
    parameters.label = "↑"
    parameters.tooltip = I18N("toolTipIncreaseRep")
    parameters.position = Utils.toVector(position) - Vector(0, 0, 0.05)
    self.createButton(parameters)
end
]]--

---
function Utils.assertIsPlayerColor(color)
    assert(color == "Green"
        or color == "Yellow"
        or color == "Blue"
        or color == "Red",
        "Not a player color: " .. tostring(color), "Not an integer: " .. tostring(n))
end

---
function Utils.assertIsFaction(faction)
    assert(faction == "emperor"
        or faction == "spacingGuild"
        or faction == "beneGesserit"
        or faction == "fremen",
        "No a faction: " .. tostring(faction))
end

---
function Utils.assertIsTroopLocation(location)
    assert(location == "supply" -- when lost or recalled
        or location == "garrison" -- when recruited
        or location == "combat" -- when deployed
        or location == "negotiation" -- when sent as negotiator
        or location == "tanks", -- when sent as specimen
        "No a troop location: " .. tostring(location))
end

---
function Utils.assertIsDreadnoughtLocation(location)
    assert(location == "supply" -- when lost or recalled
        or location == "garrison" -- when recruited
        or location == "combat" -- when deployed
        or location == "carthag" -- when occupying the place
        or location == "arrkeen" -- when occupying the place
        or location == "imperialBassin", -- when occupying the place
        "No a dreadnought location: " .. tostring(location))
end

---
function Utils.assertIsResourceName(resourceName)
    assert(resourceName == "spice"
        or resourceName == "water"
        or resourceName == "solari",
        "No a resource name: " .. tostring(resourceName))
end

---
function Utils.assertIsString(str)
    assert(type(str) == "string", "Not a string: " .. tostring(str))
end

---
function Utils.assertIsBoolean(b)
    assert(type(b) == "boolean", "Not a boolean: " .. tostring(b))
end

---
function Utils.isInteger(n)
    return type(n) == "number" and math.floor(n) == n
end

---
function Utils.assertIsInteger(n)
    assert(Utils.isInteger(n), "Not an integer: " .. tostring(n))
end

---
function Utils.assertIsPositiveInteger(n)
    assert(Utils.isInteger(n) and n >= 0, "Not a positive integer: " .. tostring(n))
end

---
function Utils.assertIsStrictlyPositive(n)
    assert(Utils.isInteger(n) and n > 0, "Not a strictly positive integer: " .. tostring(n))
end

return Utils
