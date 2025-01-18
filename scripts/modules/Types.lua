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

function Types.isTroop(object, color)
    return object.hasTag("Troop") and (not color or object.hasTag(color))
end

function Types.isDreadnought(object, color)
    return object.hasTag("Dreadnought") and (not color or object.hasTag(color))
end

function Types.isSardaukarCommander(object, color)
    return object.hasTag("SardaukarCommander") and (not color or object.hasTag(color))
end

function Types.isAgentUnit(object, color)
    return object.hasTag("Agent") and object.hasTag("Unit") and (not color or object.hasTag(color))
end

function Types.isUnit(object, color)
    return Types.isTroop(object, color)
        or Types.isDreadnought(object, color)
        or Types.isSardaukarCommander(object, color)
        or Types.isAgentUnit(object, color)
end

function Types.isControlMarker(object, color)
    return object.hasTag("Flag") and (not color or object.hasTag(color))
end

function Types.isAgent(object, color)
    return object.hasTag("Agent") and (not color or object.hasTag(color))
end

function Types.isMentat(object, color)
    return object.hasTag("Mentat") and (not color or object.hasTag(color))
end

function Types.isVoiceToken(object)
    return object.hasTag("VoiceToken")
end

function Types.isVictoryPointToken(object)
    return object.hasTag("VictoryPointToken")
end

function Types.isLeader(object)
    return object.hasTag("Leader")
end

function Types.isImperiumCard(object)
    return object.hasTag("Imperium")
end

function Types.isIntrigueCard(object)
    return object.hasTag("Intrigue")
end

function Types.isTech(object)
    return object.hasTag("Tech")
end

function Types.isSardaukarCommanderSkillCard(object)
    return object.hasTag("SardaukarCommanderSkill")
end

function Types.isNavigationCard(object)
    return object.hasTag("Navigation")
end

function Types.isPlayerColor(color)
    return color == "Green"
        or color == "Yellow"
        or color == "Blue"
        or color == "Red"
end

function Types.isFaction(faction)
    return faction == "emperor"
        or faction == "spacingGuild"
        or faction == "beneGesserit"
        or faction == "fremen"
end

function Types.isTroopLocation(location)
    return location == "supply" -- when lost or recalled
        or location == "garrison" -- when recruited
        or location == "combat" -- when deployed
        or location == "negotiation" -- when sent as negotiator
        or location == "tanks" -- when sent as specimen
end

function Types.isDreadnoughtLocation(location)
    return location == "supply" -- when lost or recalled
        or location == "garrison" -- when recruited
        or location == "combat" -- when deployed
        or location == "carthag" -- when occupying the place
        or location == "arrakeen" -- when occupying the place
        or location == "imperialBassin" -- when occupying the place
end

function Types.isResourceName(resourceName)
    return resourceName == "spice"
        or resourceName == "water"
        or resourceName == "solari"
        or resourceName == "persuasion"
        or resourceName == "strength"
end

return Types
