---@alias PlayerColor
---| 'Green'
---| 'Purple'
---| 'Yellow'
---| 'Blue'
---| 'White'
---| 'Red'

---@alias Faction
---| 'greatHouses'
---| 'emperor'
---| 'spacingGuild'
---| 'beneGesserit'
---| 'fremen'
---| 'fringeWorlds'

---@alias TroopLocation
---| 'supply'
---| 'garrison'
---| 'combat'
---| 'negotiation'
---| 'tanks'
---| 'memory'

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
function Types.isSandworm(object, color)
    return object.hasTag("Sandworm") and (not color or object.hasTag(color))
end

---
function Types.isSardaukarCommander(object, color)
    return object.hasTag("SardaukarCommander") and (not color or object.hasTag(color))
end

---
function Types.isAgentUnit(object, color)
    return object.hasTag("Agent") and object.hasTag("Unit") and (not color or object.hasTag(color))
end

---
function Types.isUnit(object, color)
    return Types.isTroop(object, color)
        or Types.isDreadnought(object, color)
        or Types.isSandworm(object, color)
        or Types.isSardaukarCommander(object, color)
        or Types.isAgentUnit(object, color)
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
function Types.isSpy(object, color)
    return object.hasTag("Spy") and (not color or object.hasTag(color))
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
function Types.isObjectiveToken(object)
    for _, prefix in ipairs({ "MuadDib", "Ornithopter", "Crysknife", "Joker" }) do
        if object.hasTag(prefix .. "ObjectiveToken") then
            return true
        end
    end
    return false
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
function Types.isContract(object)
    return object.hasTag("Contract")
end

---
function Types.isSardaukarCommanderSkillCard(object)
    return object.hasTag("SardaukarCommanderSkill")
end

---
function Types.isNavigationCard(object)
    return object.hasTag("Navigation")
end

---
function Types.assertIsPlayerColor(color)
    assert(color == "Green"
        or color == "Purple"
        or color == "Yellow"
        or color == "Blue"
        or color == "White"
        or color == "Red",
        "Not a player color: " .. tostring(color))
end

---
function Types.assertIsFaction(faction)
    assert(faction == "greatHouses"
        or faction == "emperor"
        or faction == "spacingGuild"
        or faction == "beneGesserit"
        or faction == "fremen"
        or faction == "fringeWorlds",
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
    assert(type(str) == "string", "Not a string: " .. tostring(str))
end

---
function Types.assertIsBoolean(b)
    assert(type(b) == "boolean", "Not a boolean: " .. tostring(b))
end

---
function Types.isInteger(n)
    return type(n) == "number" and math.floor(n) == n
end

---
function Types.assertIsInteger(n)
    assert(Types.isInteger(n), "Not an integer: " .. tostring(n))
end

---
function Types.assertIsPositiveInteger(n)
    assert(Types.isInteger(n) and n >= 0, "Not a positive integer: " .. tostring(n))
end

---
function Types.assertIsStrictlyPositive(n)
    assert(Types.isInteger(n) and n > 0, "Not a strictly positive integer: " .. tostring(n))
end

---
function Types.assertIsInRange(min, max, n)
    assert(Types.isInteger(min))
    assert(Types.isInteger(max))
    assert(Types.isInteger(n), "Not an integer: " .. tostring(n))
    assert(min <= n and n <= max, "Not in range [" .. tostring(min) .. ", " .. tostring(max) .. "]: " .. tostring(n))
end

return Types
