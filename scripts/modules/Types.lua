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

---@alias AgentIcon
---| 'emperor'
---| 'spacingGuild'
---| 'beneGesserit'
---| 'fremen'
---| 'blue'
---| 'green'
---| 'yellow'


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

---@param object Object
---@param color? PlayerColor
---@return boolean
function Types.isTroop(object, color)
    return object.hasTag("Troop") and (not color or object.hasTag(color))
end

---@param object Object
---@param color? PlayerColor
---@return boolean
function Types.isDreadnought(object, color)
    return object.hasTag("Dreadnought") and (not color or object.hasTag(color))
end

---@param object Object
---@param color? PlayerColor
---@return boolean
function Types.isSandworm(object, color)
    return object.hasTag("sandworm") and (not color or object.hasTag(color))
end

---@param object Object
---@param color? PlayerColor
---@return boolean
function Types.isSardaukarCommander(object, color)
    return object.hasTag("SardaukarCommander") and (not color or object.hasTag(color))
end

---@param object Object
---@param color? PlayerColor
---@return boolean
function Types.isAgentUnit(object, color)
    return object.hasTag("Agent") and object.hasTag("Unit") and (not color or object.hasTag(color))
end

---@param object Object
---@param color? PlayerColor
---@return boolean
function Types.isUnit(object, color)
    return Types.isTroop(object, color)
        or Types.isDreadnought(object, color)
        or Types.isSandworm(object, color)
        or Types.isSardaukarCommander(object, color)
        or Types.isAgentUnit(object, color)
end

---@param object Object
---@param color? PlayerColor
---@return boolean
function Types.isControlMarker(object, color)
    return object.hasTag("Flag") and (not color or object.hasTag(color))
end

---@param object Object
---@param color? PlayerColor
---@return boolean
function Types.isAgent(object, color)
    return object.hasTag("Agent") and (not color or object.hasTag(color))
end

---@param object Object
---@param color? PlayerColor
---@return boolean
function Types.isSpy(object, color)
    return object.hasTag("Spy") and (not color or object.hasTag(color))
end

---@param object Object
---@return boolean
function Types.isVoiceToken(object)
    return object.hasTag("VoiceToken")
end

---@param object Object
---@return boolean
function Types.isVictoryPointToken(object)
    return object.hasTag("VictoryPointToken")
end

---@param object Object
---@return boolean
function Types.isObjectiveToken(object)
    for _, prefix in ipairs({ "MuadDib", "Ornithopter", "Crysknife", "Joker" }) do
        if object.hasTag(prefix .. "ObjectiveToken") then
            return true
        end
    end
    return false
end

---@param object Object
---@return boolean
function Types.isImperiumCard(object)
    return object.hasTag("Imperium")
end

---@param object Object
---@return boolean
function Types.isIntrigueCard(object)
    return object.hasTag("Intrigue")
end

---@param object Object
---@return boolean
function Types.isTech(object)
    return object.hasTag("Tech")
end

---@param object Object
---@return boolean
function Types.isContract(object)
    return object.hasTag("Contract")
end

---@param object Object
---@return boolean
function Types.isSardaukarCommanderSkillCard(object)
    return object.hasTag("SardaukarCommanderSkill")
end

---@param object Object
---@return boolean
function Types.isNavigationCard(object)
    return object.hasTag("Navigation")
end

---@param color string
---@return boolean
function Types.isPlayerColor(color)
    return color == "Green"
        or color == "Purple"
        or color == "Yellow"
        or color == "Blue"
        or color == "White"
        or color == "Red"
end


---@param faction string
---@return boolean
function Types.isFaction(faction)
    return faction == "greatHouses"
        or faction == "emperor"
        or faction == "spacingGuild"
        or faction == "beneGesserit"
        or faction == "fremen"
        or faction == "fringeWorlds"
end

---@param location string
---@return boolean
function Types.isTroopLocation(location)
    return location == "supply" -- when lost or recalled
        or location == "garrison" -- when recruited
        or location == "combat" -- when deployed
        or location == "negotiation" -- when sent as negotiator
        or location == "tanks" -- when sent as specimen
end

---@param location string
---@return boolean
function Types.isDreadnoughtLocation(location)
    return location == "supply" -- when lost or recalled
        or location == "garrison" -- when recruited
        or location == "combat" -- when deployed
        or location == "carthag" -- when occupying the place
        or location == "arrakeen" -- when occupying the place
        or location == "imperialBassin" -- when occupying the place
end

---@param resourceName string
---@return boolean
function Types.isResourceName(resourceName)
    return resourceName == "spice"
        or resourceName == "water"
        or resourceName == "solari"
        or resourceName == "persuasion"
        or resourceName == "strength"
end

return Types
