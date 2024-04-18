local Helper = require("utils.Helper")

---@alias PlayerColor
---| 'Green'
---| 'Yellow'
---| 'Blue'
---| 'Red'

---@alias Faction
---| 'emperor'
---| 'spacingGuild'
---| 'beneGesserit'
---| 'fremen'

---@alias TroopLocation
---| 'supply'
---| 'garrison'
---| 'combat'
---| 'negotiation'
---| 'tanks'

---@alias DreadnoughtLocation
---| 'supply'
---| 'garrison'
---| 'combat'
---| 'carthag'
---| 'arrakeen'
---| 'imperialBassin'

---@alias ResourceName
---| 'spice'
---| 'water'
---| 'solari'
---| 'persuasion'
---| 'strength'

local Types = {}

---
function Types.isTroop(object, color)
    return object.hasTag("Troop") and (not color or object.hasTag(color))
end

---
function Types.isDreadnought(object, color)
    return object.hasTag("Dreadnought") and (not color or object.hasTag(color))
end

---
function Types.isUnit(object, color)
    return Types.isTroop(object, color) or Types.isDreadnought(object, color)
end

---
function Types.isControlMarker(object, color)
    return object.hasTag("Flag") and (not color or object.hasTag(color))
end

---
function Types.isAgent(object, color)
    return object.hasTag("Agent") and (not color or object.hasTag(color))
end

---
function Types.isMentat(object, color)
    return object.hasTag("Mentat") and (not color or object.hasTag(color))
end

---
function Types.isVoiceToken(object)
    return object.hasTag("VoiceToken")
end

---
function Types.isVictoryPointToken(object)
    return object.hasTag("VictoryPointToken")
end

---
function Types.isLeader(object)
    return object.hasTag("Leader")
end

---
function Types.isImperiumCard(object)
    return object.hasTag("Imperium")
end

---
function Types.isIntrigueCard(object)
    return object.hasTag("Intrigue")
end

---
function Types.isTech(object)
    return object.hasTag("Tech")
end

---
function Types.assertIsPlayerColor(color)
    assert(color == "Green"
        or color == "Yellow"
        or color == "Blue"
        or color == "Red",
        "Not a player color: " .. tostring(color))
end

---
function Types.assertIsFaction(faction)
    assert(faction == "emperor"
        or faction == "spacingGuild"
        or faction == "beneGesserit"
        or faction == "fremen",
        "Not a faction: " .. tostring(faction))
end

---
function Types.assertIsTroopLocation(location)
    assert(location == "supply" -- when lost or recalled
        or location == "garrison" -- when recruited
        or location == "combat" -- when deployed
        or location == "negotiation" -- when sent as negotiator
        or location == "tanks", -- when sent as specimen
        "No a troop location: " .. tostring(location))
end

---
function Types.assertIsDreadnoughtLocation(location)
    assert(location == "supply" -- when lost or recalled
        or location == "garrison" -- when recruited
        or location == "combat" -- when deployed
        or location == "carthag" -- when occupying the place
        or location == "arrakeen" -- when occupying the place
        or location == "imperialBassin", -- when occupying the place
        "No a dreadnought location: " .. tostring(location))
end

---
function Types.assertIsResourceName(resourceName)
    assert(resourceName == "spice"
        or resourceName == "water"
        or resourceName == "solari"
        or resourceName == "persuasion"
        or resourceName == "strength",
        "No a resource name: " .. tostring(resourceName))
end

---
function Types.assertIsString(str)
    -- Disabled since it doesn't help at all without a proper stacktrace.
    --assert(type(str) == "string", "Not a string: " .. tostring(str))
end

---
function Types.assertIsBoolean(b)
    -- Disabled since it doesn't help at all without a proper stacktrace.
    --assert(type(b) == "boolean", "Not a boolean: " .. tostring(b))
end

---
function Types.isInteger(n)
    return type(n) == "number" and math.floor(n) == n
end

---
function Types.assertIsInteger(n)
    -- Disabled since it doesn't help at all without a proper stacktrace.
    --assert(Types.isInteger(n), "Not an integer: " .. tostring(n))
end

---
function Types.assertIsPositiveInteger(n)
    -- Disabled since it doesn't help at all without a proper stacktrace.
    --assert(Types.isInteger(n) and n >= 0, "Not a positive integer: " .. tostring(n))
end

---
function Types.assertIsStrictlyPositive(n)
    -- Disabled since it doesn't help at all without a proper stacktrace.
    --assert(Types.isInteger(n) and n > 0, "Not a strictly positive integer: " .. tostring(n))
end

---
function Types.assertIsInRange(min, max, n)
    assert(Types.isInteger(min))
    assert(Types.isInteger(max))
    assert(Types.isInteger(n), "Not an integer: " .. tostring(n))
    assert(min <= n and n <= max, "Not in range [" .. tostring(min) .. ", " .. tostring(max) .. "]: " .. tostring(n))
end

return Types
