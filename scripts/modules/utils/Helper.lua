local Core = require("utils.Core")

local Helper = {}

Helper.someHeight = Vector(0, 0.3, 0)

math.randomseed(os.time())

---
function Helper.getLandingPositionFromGUID(anchorGUID)
    local anchor = getObjectFromGUID(anchorGUID)
    if anchor then
        return Helper.getLandingPosition(anchor)
    else
        log("[getLandingPositionFromGUID] Unknown GUID: " .. tostring(anchorGUID))
        return Vector(0, 0, 0)
    end
end

---
function Helper.getLandingPosition(anchor)
    return anchor.getPosition() + Helper.someHeight
end

function Helper.moveCard(card, position, rotation, smooth, flipAtTheEnd)
    assert(card)
    assert(card.type == "Card")
    if smooth then
        card.setPositionSmooth(position)
    else
        card.setPosition(position)
    end
    if rotation then
        if smooth then
            card.setRotationSmooth(rotation)
        else
            card.setRotation(rotation)
        end
    end
    if flipAtTheEnd then
        Wait.time(function() -- Once moved and rotated.
            card.flip()
        end, 0.2)
    end
end

--- Prefer the "deal" method when possible? Would it prevent the card from being
--- grabbed by anther player's hand zone?
function Helper.moveCardFromZone(zone, position, rotation, smooth, flipAtTheEnd)
    local deckOrCard = Helper.getDeckOrCard(zone)
    if deckOrCard then
        if deckOrCard.type == "Deck" then
            local parameters = {
                position = position,
                flip = flipAtTheEnd and true,
                smooth = smooth or false
            }
            if rotation then
                parameters.rotation = rotation
            end
            deckOrCard.takeObject(parameters)
            return true
        elseif deckOrCard.type == "Card" then
            Helper.moveCard(deckOrCard, position, rotation, smooth, flipAtTheEnd)
            return true
        else
            assert(false)
        end
    end
    return false
end

---
function Helper.moveCardFromZoneGUID(zoneGUID, position, rotation, smooth)
    assert(type(zoneGUID) == 'string', tostring(zoneGUID) .. ' is not a GUID')
    local zone = getObjectFromGUID(zoneGUID)
    assert(zone, "Failed to resolve GUID: " .. tostring(zoneGUID))
    return Helper.moveCardFromZone(zone, position, rotation, smooth)
end

---
function Helper.getCardCount(deckOrCard)
    if not deckOrCard then
        return 0
    elseif deckOrCard.type == "Card" then
        return 1
    elseif deckOrCard.type == "Deck" then
        return deckOrCard.getQuantity()
    else
        return 0
    end
end

---
function Helper.getDeckOrCard(zone)
    assert(zone)
    assert(type(zone) ~= 'string', tostring(zone) .. ' is a GUID, not a zone')
    for _, object in ipairs(zone.getObjects()) do
        if object.type == "Card" or object.type == "Deck" then return object end
    end
    --log(zone.getGUID() .. " contains no card nor deck!")
    return nil
end

---
function Helper.getDeck(zone)
    assert(zone)
    assert(type(zone) ~= 'string', tostring(zone) .. ' is a GUID, not a zone')
    for _, object in ipairs(zone.getObjects()) do
        if object.type == "Deck" then return object end
    end
    return nil
end

---
function Helper.getCard(zone)
    assert(zone)
    assert(type(zone) ~= 'string', tostring(zone) .. ' is a GUID, not a zone')
    for _, object in ipairs(zone.getObjects()) do
        if object.type == "Card" then return object end
    end
    return nil
end

---
function Helper.getDeckOrCardFromGUID(zoneGUID)
    assert(type(zoneGUID) == 'string', tostring(zoneGUID) .. ' is not a GUID')
    local zone = getObjectFromGUID(zoneGUID)
    assert(zone, "Failed to resolve GUID: " .. tostring(zoneGUID))
    return Helper.getDeckOrCard(zone)
end

---
function Helper.getDeckFromGUID(zoneGUID)
    assert(type(zoneGUID) == 'string', tostring(zoneGUID) .. ' is not a GUID')
    local zone = getObjectFromGUID(zoneGUID)
    assert(zone, "Failed to resolve GUID: " .. tostring(zoneGUID))
    return Helper.getDeck(zone)
end

---
function Helper.getCardFromGUID(zoneGUID)
    assert(type(zoneGUID) == 'string', tostring(zoneGUID) .. ' is not a GUID')
    local zone = getObjectFromGUID(zoneGUID)
    assert(zone, "Failed to resolve GUID: " .. tostring(zoneGUID))
    return Helper.getCard(zone)
end

--[[
    Create a snapPoint relative to a parent centered on the provided zone but at the
    height of the parent.
]]--
---
function Helper.createRelativeSnapPointFromZone(parent, zone, rotationSnap, tags)
    return Helper.createRelativeSnapPoint(parent, zone.getPosition(), rotationSnap, tags)
end

function Helper.createRelativeSnapPoint(parent, position, rotationSnap, tags)
    local p = Vector(position.x, parent.getPosition().y, position.z)
    local snapPoint = {
        position = parent.positionToLocal(p),
        rotation_snap = rotationSnap,
        tags = tags
    }
    return snapPoint
end

--[[
    Indirect call to createButton adjusting the provided parameters to
    counteract the position, scale and rotation of the parent object.
    TTS does offer a positionToLocal method, but which only accounts for
    the position and (partly to the) scale, not the rotation. The
    convention for the world coordinates is a bit twisted here since the
    X coordinate is inverted.
]]--
---
function Helper.createAbsoluteButton(object, parameters)
    Helper.createAbsoluteButtonWithRoundness(object, 0.25, false, parameters)
end

---
function Helper.createAbsoluteButtonWithRoundness(object, roundness, quirk, parameters)
    object.createButton(Helper.createAbsoluteWidgetWithRoundnessParameters(object, roundness, quirk, parameters))
end

---
function Helper.createAbsoluteInputWithRoundness(object, roundness, quirk, parameters)
    object.createInput(Helper.createAbsoluteWidgetWithRoundnessParameters(object, roundness, quirk, parameters))
end

---
function Helper.createAbsoluteWidgetWithRoundnessParameters(object, roundness, quirk, parameters)
    assert(roundness >= 0, "Zero or negative roundness won't work as intended.")
    assert(roundness <= 10, "Roundness beyond 10 won't work as intended.")
    if parameters.color and parameters.font_color then
        --[[
            The opacity of a button color is applied to its content, including the label.
            Thus, to achieve a transparent button with a visible lablel, the alpha of the
            "font_color" needs to be pushed beyond 1. In fact, in this situation, the
            alpha seems to be interpreted as a percentage (100% being full opaque).
        ]]--
        assert(parameters.color[4] > 0 or parameters.font_color[4] > 1, "Unproper label opacity!")
    end

    --[[
        Scale is a problem here. We change it to artificially adjust the roundness, but
        the final scale could also modify the font height since its end value is capped...
    ]]--

    local scale = object.getScale()
    local invScale = Vector(1 / scale.x, 1 / scale.y, 1 / scale.z)

    -- Only to counteract the absolute roundness of the background.
    local rescale = 1 / roundness

    local p = parameters['position']
    if p then
        p = Helper.toVector(p)
        -- Inverting the X coordinate comes from our global 180° rotation around Y.
        -- TODO Get rid of this quirk.
        if quirk then
            p = Vector(-p.x, p.y, p.z)
        else
            p = Vector(p.x, p.y, p.z)
        end

        p = p - object.getPosition()

        if quirk then
            p = Vector(p.x, p.y, p.z)
        else
            p = Vector(-p.x, p.y, p.z)
        end

        p:scale(invScale)

        -- Proper order?
        local r = object.getRotation()
        p:rotateOver('x', -r.x)
        p:rotateOver('y', -r.y)
        p:rotateOver('z', -r.z)

        parameters['position'] = p
    end

    local s = parameters['scale']
    if not s then
        s = Vector(1, 1, 1)
    else
        s = Helper.toVector(s)
    end
    s = s * invScale * (1 / rescale)
    parameters['scale'] = s

    local w = parameters['width']
    if not w then
        w = 1
    end
    w = w * rescale
    parameters['width'] = w

    local h = parameters['height']
    if not h then
        h = 1
    end
    h = h * rescale
    parameters['height'] = h

    local font_size = parameters['font_size']
    if not font_size then
        font_size = 1
    end
    font_size = font_size * rescale
    parameters['font_size'] = font_size

    return parameters
end

---
function Helper.setSharedTable(tableName, table)
    Global.setTable(tableName, table)
end

---
function Helper.getSharedTable(tableName)
    return Global.getTable(tableName)
end

---
function Helper.toCamelCase(...)
    local arg = {...}
    local chameauString = ""
    for i, str in ipairs(arg) do
        if i > 1 then
            chameauString = chameauString .. str:gsub("^%l", string.upper)
        else
            chameauString = chameauString .. str
        end
    end
    return chameauString
end

---
function Helper.createTable(root, ...)
    local arg = {...}
    local parent = root
    for _, str in ipairs(arg) do
        if not parent[str] then
            parent[str] = {}
        end
        parent = parent[str]
        assert(type(parent) == "table")
    end
    return parent
end

---
function Helper.toVector(data)
    if not data then
        log("nothing to vectorize")
        return Vector(0, 0, 0)
    elseif Core.isSomeKindOfObject(data) then
        return data
    else
        return Vector(data[1], data[2], data[3])
    end
end

---
function Helper.addAll(objects, otherObjects)
    assert(objects)
    assert(otherObjects)
    for _, object in ipairs(otherObjects) do
        table.insert(objects, object)
    end
end

---
function Helper.repeatMovingAction(object, count, action)
    local continuation = Helper.createContinuation()
    if count > 0 then
        action()
        Wait.condition(function()
            Helper.repeatMovingAction(object, count - 1, action).doAfter(function (_)
                continuation.run(object)
            end)
        end, function()
            -- Or resting?
            return not object.isSmoothMoving()
        end)
    else
        Wait.condition(function()
            continuation.run(object)
        end, function()
            -- Or resting?
            return not object.isSmoothMoving()
        end)
    end
    return continuation
end

-- Intended to be used in a coroutine.
---
function Helper.sleep(duration)
    local Time = os.clock() + duration
    while os.clock() < Time do
        coroutine.yield()
    end
end

---
function Helper.createContinuation()
    local continuation = {}

    continuation.actions = {}

    continuation.doAfter = function (action)
        table.insert(continuation.actions, action)
    end

    continuation.run = function (parameters)
        for _, action in ipairs(continuation.actions) do
            action(parameters)
        end
    end

    return continuation
end

---
function Helper.trace(name, data)
    log(name .. ": " .. tostring(data))
    return data
end

---
function Helper.newObject(class, instance)
    assert(class)
    assert(instance)

    class.__index = class
    setmetatable(instance, class)
    return instance
end

---
function Helper.newInheritingObject(superclass, class, instance)
    assert(class)
    assert(instance)

    class.superclass = superclass

    class.__index = function(_, key)
        local item = class[key]
        if not item then
            item = class.superclass[key]
        end
        return item
    end

    setmetatable(instance, class)
    return instance
end

---
function Helper.wrapCallback(keys, f)
    local uniqueName = "callback"
    for _, key in ipairs(keys) do
        uniqueName = uniqueName .. "_" .. tostring(key)
    end
    Global.setVar(uniqueName, function (object, color, altClick)
        f(object, color, altClick)
    end)
    return uniqueName
end

--- The created anchor will be saved but automatically destroyed when reloaded.
function Helper.createTransientAnchor(nickname, position)
    local continuation = Helper.createContinuation()

    local data = {
        Name = "Custom_Model",
        Transform = {
          posX = 0,
          posY = 0,
          posZ = 0,
          rotX = 0.0,
          rotY = 180.0,
          rotZ = 0.0,
          scaleX = 1.0,
          scaleY = 1.0,
          scaleZ = 1.0
        },
        Nickname = nickname,
        Description = "Generated transient anchor.",
        GMNotes = "",
        AltLookAngle = {
          x = 0.0,
          y = 0.0,
          z = 0.0
        },
        ColorDiffuse = {
          r = 1.0,
          g = 0.0,
          b = 1.0
        },
        LayoutGroupSortIndex = 0,
        Value = 0,
        Locked = true,
        Grid = false,
        Snap = false,
        IgnoreFoW = false,
        MeasureMovement = false,
        DragSelectable = true,
        Autoraise = true,
        Sticky = false,
        Tooltip = true,
        GridProjection = false,
        HideWhenFaceDown = false,
        Hands = false,
        CustomMesh = {
          MeshURL = "http://cloud-3.steamusercontent.com/ugc/2042984592862608679/0383C231514AACEB52B88A2E503A90945A4E8143/",
          DiffuseURL = "",
          NormalURL = "",
          ColliderURL = "",
          Convex = true,
          MaterialIndex = 0,
          TypeIndex = 4,
          CustomShader = {
            SpecularColor = {
              r = 0.0,
              g = 0.0,
              b = 0.0
            },
            SpecularIntensity = 0.0,
            SpecularSharpness = 7.0,
            FresnelStrength = 0.4
          },
          CastShadows = false
        },
        LuaScript = "",
        LuaScriptState = "",
        XmlUI = ""
      }

    spawnObjectData({
        data = data,
        position = position,
        callback_function = function (anchor)
            Helper.markAsTransient(anchor)
            continuation.run(anchor)
        end})

    return continuation
end

---
function Helper.markAsTransient(object)
    -- Tagging is not usable on a zone without filtering its content.
    object.setGMNotes("Transient")
end

---
function Helper.isTransient(object)
    return object.getGMNotes() == "Transient"
end

---
function Helper.destroyTransientObjects()
    for _, object in ipairs(Global.getObjects()) do
        if Helper.isTransient(object) then
            --log("Destroy " .. object.getName())
            object.destruct()
        end
    end
end

Helper.erase = "__erase__"

---
function Helper.append(parent, set)
    for name, value in pairs(set) do
        if value == Helper.erase then
            parent[name] = nil
        else
            parent[name] = value
        end
    end
end

---
function Helper.mandatory(message, object)
    assert(object, "Cyclic failure: " .. tostring(message))
    return object
end

---
function Helper.contains(zone, object)
    assert(zone)
    assert(object)
    for _, containedObject in ipairs(zone.getObjects()) do
        if containedObject == object then
            return true
        end
    end
    return false
end

--- Fisher-Yates shuffle, in-place – for each position, pick an element from those not yet picked.
function Helper.shuffle(table)
    assert(table)
    for i = #table, 2, -1 do
        local j = math.random(i)
        table[i], table[j] = table[j], table[i]
    end
end

---
function Helper.lazyRequire(moduleName)
    local lazyModule = {}

    local meta = {
        module = nil
    }
    meta.__index = function(_, key)
        if not meta.module then
            meta.module = Helper.allModules[moduleName]
        end
        if meta.module then
            local item = meta.module[key]
            if type(item) ~= "function" then
                log("Accessing inner field: " .. moduleName .. "." .. key)
            end
            return item
        else
            log("Unresolvable module " .. moduleName)
            return nil
        end
    end

    setmetatable(lazyModule, meta)

    return lazyModule
end

---
function Helper.signum(n)
    if n > 0 then
        return 1
    elseif n < 0 then
        return -1
    else
        return 0
    end
end

---
function Helper.getCenter(positions)
    assert(positions)
    assert(#positions > 0)
    local p = Vector(0, 0, 0)
    for _, position in ipairs(positions) do
        p = p + position
    end
    p:scale(1 / #positions)
    return p
end

---
function Helper.tableContains(table, element)
    for _, containedElement in ipairs(table) do
        if containedElement == element then
            return true
        end
    end
    return false
end

---
function Helper.hasAllTags(object, tags)
    for _, tag in ipairs(tags) do
        if not object.hasTag(tag) then
            return false
        end
    end
    return true
end

---
function Helper.stringConcat(elements)
    local str = ""
    for _, element in ipairs(elements) do
        str = str .. tostring(element)
    end
    return str
end

---
function Helper.dump(...)
    local arg = {...}
    local str = ""
    for i, element in ipairs(arg) do
        if i > 1 then
            str = str .. " "
        end
        str = str .. tostring(element)
    end
    log(str)
end

---
function Helper.concatTables(...)
    local arg = {...}
    local result = {}
    for _, t in ipairs(arg) do
        for _, element in ipairs(t) do
            table.insert(result, element)
        end
    end
    return result
end

---
function Helper.shallowCopy(elements)
    local copy = {}
    for k, v in pairs(elements) do
        copy[k] = v
    end
    --[[
    for i, e in ipairs(elements) do
        copy[i] = e
    end
    ]]--
    return copy
end

---
function Helper.deepCopy(something)
    local t = type(something)
    if Helper.isBasicType(t) then
        if t == "table" then
            local copy = {}
            for k, v in pairs(something) do
                copy[k] = Helper.deepCopy(v)
            end
            --[[
            for i, e in ipairs(something) do
                copy[i] = e:copy()
            end
            ]]--
            return copy
        else
            return something
        end
    else
        assert(false)
        --return something:copy()
    end
end

---
function Helper.isBasicType(t)
    return t == "nil"
        or t == "boolean"
        or t == "number"
        or t == "string"
        or t == "userdata"
        or t == "function"
        or t == "thread"
        or t == "table"
end

---
function Helper.getKeys(elements)
    local keys = {}
    for k, _ in pairs(elements) do
        table.insert(keys, k)
    end
    return keys
end

---
function Helper.getValues(elements)
    local values = {}
    for _, v in pairs(elements) do
        table.insert(values, v)
    end
    return values
end

---
function Helper.getSubSet(set, keys)
    local subSet = {}
    for _, k in ipairs(keys) do
        local value = set[k]
        if type(k) == "number" then
            subSet[k] = value
        else
            table.insert(subSet, value)
        end
    end
    return subSet
end

---
function Helper.indexOf(table, element)
    for i, existingElement in ipairs(table) do
        if existingElement == element then
            return i
        end
    end
    return 0
end

---
function Helper.findPlayer(color)
    for _, player in ipairs(Player.getPlayers()) do
        if player.color == color then
            return player
        end
    end
    return nil
end

---
function Helper.cons(head, tail)
    local list = { head }
    for _, element in pairs(tail) do
        table.insert(list, element)
    end
    return list
end

return Helper