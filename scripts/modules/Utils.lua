local Utils = {}

---
function Utils.isTroop(object, color)
    return object.hasTag("Troop") and (not color or object.hasTag(color))
end

---
function Utils.isDreadnought(object, color)
    return object.hasTag("Dreadnought") and (not color or object.hasTag(color))
end

---
function Utils.isUnit(object, color)
    return Utils.isTroop(object, color) or Utils.isDreadnought(object, color)
end

---
function Utils.isFlag(object, color)
    return object.hasTag("Flag") and (not color or object.hasTag(color))
end

---
function Utils.isAgent(object, color)
    return object.hasTag("Agent") and (not color or object.hasTag(color))
end

---
function Utils.isMentat(object, color)
    return object.hasTag("Mentat") and (not color or object.hasTag(color))
end

---
function Utils.isVictoryPointToken(object)
    return object.hasTag("VictoryPointToken")
end

---
function Utils.isLeader(object)
    return object.hasTag("Leader")
end

---
function Utils.isImperiumCard(object)
    return object.hasTag("Imperium")
end

---
function Utils.isIntrigueCard(object)
    return object.hasTag("Intrigue")
end

---
function Utils.assertIsPlayerColor(color)
    assert(color == "Green"
        or color == "Yellow"
        or color == "Blue"
        or color == "Red",
        "Not a player color: " .. tostring(color))
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
        or location == "arrakeen" -- when occupying the place
        or location == "imperialBassin", -- when occupying the place
        "No a dreadnought location: " .. tostring(location))
end

---
function Utils.assertIsResourceName(resourceName)
    assert(resourceName == "spice"
        or resourceName == "water"
        or resourceName == "solari"
        or resourceName == "persuasion"
        or resourceName == "strength",
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
