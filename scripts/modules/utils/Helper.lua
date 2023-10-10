local Helper = {
    sharedTables = {},
    eventListenersByTopic = {},
    --areaButtonColor = { 1, 0, 0, 0.5 },
    areaButtonColor = { 0, 0, 0, 0 },
    ERASE = function ()
        return "__erase__"
    end
}

math.randomseed(os.time())

---
function Helper.registerEventListener(topic, listener)
    assert(listener)
    local listeners = Helper.eventListenersByTopic[topic]
    if not listeners then
        listeners = {}
        Helper.eventListenersByTopic[topic] = listeners
    end
    listeners[listener] = listener
    return listener
end

---
function Helper.unregisterEventListener(topic, listener)
    assert(listener)
    local listeners = Helper.eventListenersByTopic[topic]
    assert(listeners and listeners[listener])
    listeners[listener] = nil
    if #Helper.getKeys(listeners) == 0 then
        Helper.eventListenersByTopic[topic] = nil
    end
end

---
function Helper.emitEvent(topic, ...)
    local listeners = Helper.eventListenersByTopic[topic]
    if listeners then
        for _, eventListener in pairs(Helper.shallowCopy(listeners)) do
            eventListener(...)
        end
    end
end

---
function Helper.getIdentity()
    if self then
        if self.guid == "-1" then
            return "Global"
        else
            return self.getGUID() .. " - " .. self.getName()
        end
    else
        return "?"
    end
end

---
function Helper.isSomeKindOfObject(data)
    return getmetatable(data) ~= nil
end

---
function Helper.stillExist(object)
    return object and getObjectFromGUID(object.getGUID())
end

---
function Helper.resolveGUIDs(reportUnresolvedGUIDs, data)
    local newData = data
    if data then
        local t = type(data)
        if t == "string" then
            if string.match(data, "[a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9]") then
                newData = getObjectFromGUID(data)
                if not newData and reportUnresolvedGUIDs then
                    log("[resolveGUIDs] Unknow GUID: '" .. data .. "'")
                end
            else
                --log("[resolveGUIDs] Not a GUID: " .. data)
                -- NOP
            end
        elseif t == "table" then
            if not Helper.isSomeKindOfObject(data) then
                newData = {}
                for i, v in ipairs(data) do
                    newData[i] = Helper.resolveGUIDs(reportUnresolvedGUIDs, v)
                end
                for k, v in pairs(data) do
                    newData[k] = Helper.resolveGUIDs(reportUnresolvedGUIDs, v)
                end
            end
        elseif t == "number" then
            -- NOP
        else
            --log("[resolveGUIDs] Unknown type: " .. t)
            -- NOP
        end
    end
    return newData
end

--[[
    A rather useless function in appearance. However, calls to this function are
    intended to be patched by a small utility which will replace the provided
    coordinates by those existing in the TTS save file.

    Why not doing this replacement at runtime you're wondering? Because scripts
    are reloaded on multiple occasions: when loading a mod (which is nothing
    more than a blank save), when restoring a game at any point, but also when
    spawning an object or simply moving an instance out of a bag.

    In other words, no assumptions can be made on the world state, at least
    regarding any object which can move around. This is especially true for
    inline code running before 'onLoad' which can well be executed before all
    legitimate objects have been created or recreated.

    As such, things like taking the "initial" position of an object is doomed to
    fail, and one shall rely on hardcoded positions or using some kind of anchor
    objects. This function and its small update utility is simply a way to get
    around this problem when developing by recovering a truly stable information.
]]--
---
function Helper.getHardcodedPositionFromGUID(GUID, x, y, z)
    return Vector(x, y, z)
end

---
function Helper.moveObject(card, position, rotation, smooth, flipAtTheEnd)
    assert(card)

    local continuation = Helper.createContinuation()

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

    Helper.onceMotionless(card).doAfter(function ()
        if flipAtTheEnd then
            card.flip()
        end
        continuation.run(card)
    end)

    return continuation
end

---
function Helper.getCards(deckOrCard)
    if deckOrCard then
        if deckOrCard.type == "Deck" then
            return deckOrCard.getObjects()
        elseif deckOrCard.type == "Card" then
            return { deckOrCard }
        else
            error("Unexpected type: " .. deckOrCard.type)
        end
    else
        return {}
    end
end

--- Prefer the "deal" method when possible? Would it prevent the card from being
--- grabbed by anther player's hand zone?
function Helper.moveCardFromZone(zone, position, rotation, smooth, flipAtTheEnd)
    local deckOrCard = Helper.getDeckOrCard(zone)
    if deckOrCard then
        local continuation = Helper.createContinuation()

        if deckOrCard.type == "Deck" then
            local parameters = {
                position = position,
                flip = flipAtTheEnd and true,
                smooth = smooth or false,
                callback_function = continuation.run
            }
            if rotation then
                parameters.rotation = rotation
            end
            deckOrCard.takeObject(parameters)
        elseif deckOrCard.type == "Card" then
            Helper.moveObject(deckOrCard, position, rotation, smooth, flipAtTheEnd).doAfter(continuation.run)
        else
            error("Unexpected type: " .. deckOrCard.type)
        end

        return continuation
    end
    return nil
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
        if not object.held_by_color and (object.type == "Card" or object.type == "Deck") then
            return object
        end
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
        position = parent.positionToLocal(p) + Vector(0, 0.25, 0),
        rotation_snap = rotationSnap,
        tags = tags
    }
    return snapPoint
end

---
function Helper.createAnchoredAreaButton(zone, ground, aboveGround, tooltip, callback)
    assert(zone)
    assert(aboveGround)
    local p = zone.getPosition()
    local anchorPosition = Vector(p.x, ground - 0.5, p.z)
    Helper.createTransientAnchor(nil, anchorPosition).doAfter(function (anchor)
        Helper.createAreaButton(zone, anchor, ground + aboveGround, tooltip, callback)
    end)
end

---
function Helper.createAreaButton(zone, anchor, altitude, tooltip, callback)
    assert(zone)
    assert(anchor)
    assert(altitude)

    local zoneScale = zone.getScale()
    local sizeFactor = 500 -- 350

    local width = zoneScale.x * sizeFactor
    local height = zoneScale.z * sizeFactor

    return Helper.createSizedAreaButton(width, height, anchor, altitude, tooltip, callback)
end

---
function Helper.createSizedAreaButton(width, height, anchor, altitude, tooltip, callback)
    assert(anchor)

    local anchorPosition = anchor.getPosition()

    local parameters = {
        click_function = Helper.registerGlobalCallback(callback),
        position = Vector(anchorPosition.x, altitude, anchorPosition.z),
        width = width,
        height = height,
        color = Helper.areaButtonColor,
        press_color = { 0.5, 1, 0.5, 0.4 },
        font_color = { 1, 1, 1, 100 },
        tooltip = tooltip,
    }

    -- 0.75 | 10 ?
    Helper.createAbsoluteButtonWithRoundness(anchor, 0.75, false, parameters)

    return parameters.click_function
end

---
function Helper.createButton(object, parameters)
    return Helper._createWidget("Button", object, parameters)
end

---
function Helper.createInput(object, parameters)
    return Helper._createWidget("Input", object, parameters)
end

---
function Helper._createWidget(name, object, parameters)
    assert(object)
    local createWidget = object["create" .. name]
    assert(createWidget)
    local getWidgets = object["get" .. name .. "s"]
    assert(getWidgets)

    local isOldIndexes = {}
    Helper.forEach(getWidgets() or {}, function (k, v)
        assert(v.index)
        isOldIndexes[v.index] = true
    end)

    createWidget(parameters)

    local newIndexes = {}
    Helper.forEach(getWidgets() or {}, function (k, v)
        if not isOldIndexes[v.index] then
            table.insert(newIndexes, v.index)
        end
    end)

    --assert(#newIndexes == 1)
    assert(#newIndexes <= 1)
    return newIndexes[1]
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
    return Helper.createAbsoluteButtonWithRoundness(object, 0.25, false, parameters)
end

---
function Helper.createAbsoluteButtonWithRoundness(object, roundness, quirk, parameters)
    return Helper.createButton(object, Helper.createAbsoluteWidgetWithRoundnessParameters(object, roundness, quirk, parameters))
end

---
function Helper.createAbsoluteInputWithRoundness(object, roundness, quirk, parameters)
    return Helper.createInput(object, Helper.createAbsoluteWidgetWithRoundnessParameters(object, roundness, quirk, parameters))
end

---
function Helper.createAbsoluteWidgetWithRoundnessParameters(object, roundness, quirk, parameters)
    assert(object)
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
        we also needs to ajust the font height, which is capped and more or less blurry
        depending on it...
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
    assert(font_size <= 720, "You hit the max font size of 720.")
    parameters['font_size'] = font_size

    return parameters
end

---
function Helper.setSharedTable(tableName, table)
    --Global.setTable(tableName, table)
    Helper.sharedTables[tableName] = table
end

---
function Helper.getSharedTable(tableName)
    --return Global.getTable(tableName)
    return Helper.sharedTables[tableName]
end

---
function Helper.toCamelCase(...)
    local chameauString = ""
    for i, str in ipairs({...}) do
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
    local parent = root
    for _, str in ipairs({...}) do
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
    elseif Helper.isSomeKindOfObject(data) then
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
        Helper.onceMotionless(object).doAfter(function ()
            Helper.repeatMovingAction(object, count - 1, action).doAfter(function (_)
                continuation.run(object)
            end)
        end)
    else
        Helper.onceMotionless(object).doAfter(function ()
            continuation.run(object)
        end)
    end
    return continuation
end

---
function Helper.onceMotionless(object)
    local continuation = Helper.createContinuation()
    -- Wait 1 frame for the movement to start.
    Wait.frames(function ()
        Wait.condition(function()
            Wait.frames(function ()
                continuation.run(object)
            end, 1)
        end, function()
            continuation.tick()
            return object.resting
        end)
    end, 1)
    return continuation
end

---
function Helper.onceShuffled(container)
    local continuation = Helper.createContinuation()
    Wait.time(function ()
        continuation.run(container)
    end, 1.5) -- TODO Search for a better way.
    return continuation
end

---
function Helper.onceOneDeck(zone)
    local continuation = Helper.createContinuation()
    Wait.condition(function()
        continuation.run(Helper.getDeck(zone))
    end, function()
        local objects = Helper.filter(zone.getObjects(), function (object)
            return object.type == "Card" or object.type == "Deck"
        end)
        if #objects == 1 and objects[1].type == "Deck" then
            local deck = objects[1]
            if deck.resting then
                return true
            end
        end
        continuation.tick()
        return false
    end)
    return continuation
end

-- Intended to be used in a coroutine.
---
function Helper.sleep(durationInSeconds)
    local Time = os.clock() + durationInSeconds
    while os.clock() < Time do
        coroutine.yield()
    end
end

---
function Helper.createContinuation()
    local continuation = {
        start = Time.time,
        what = function ()
            return "continuation"
        end
    }
    continuation.tick = function (toBeNotified)
        local duration = Time.time - continuation.start
        if toBeNotified and duration > 10 then
            toBeNotified()
        end
        assert(duration < 10, "Roting continuation!")
    end

    continuation.actions = {}

    continuation.doAfter = function (action)
        assert(type(action) == 'function')
        if continuation.done then
            action(continuation.parameters)
        else
            table.insert(continuation.actions, action)
        end
    end

    continuation.run = function (parameters)
        continuation.done = true
        continuation.parameters = parameters
        for _, action in ipairs(continuation.actions) do
            action(parameters)
        end
    end

    return continuation
end

---
function Helper.createTermination()
    local continuation = Helper.createContinuation()
    continuation.run()
    return continuation
end

---
function Helper.trace(name, data)
    log(name .. ": " .. tostring(data))
    return data
end

---
function Helper.createClass(superclass, data)
    --  We can't make this test unfortunately, since it superclasses typically come through lazyRequire.
    --assert(not superclass or superclass.__index, "Superclass doesn't look like a class itself.")
    local class = data or {}
    class.__index = class
    class.what = function ()
        return "class"
    end
    if superclass then
        setmetatable(class, superclass)
    end
    return class
end

---
function Helper.createClassInstance(class, data)
    assert(class)
    assert(class.__index, "Provided class doesn't look like a class actually.")
    local instance = data or {}
    instance.what = function ()
        return "instance"
    end
    setmetatable(instance, class)
    return instance
end

---
function Helper.getClass(instance)
    assert(instance.what() == "instance")
    local class = getmetatable(instance)
    assert(class and class.what() == "class")
    return class
end

---
function Helper._getNopCallback()
    local uniqueName = "generatedCallback0"
    local nopCallback = Global.getVar(uniqueName)
    if not nopCallback then
        Global.setVar(uniqueName, function ()
            -- NOP
        end)
    end
    return uniqueName
end

Helper.uniqueNamePool = {}

---
function Helper.registerGlobalCallback(callback)
    local GLOBAL_COUNTER_NAME = "generatedCallbackNextIndex"
    if callback then
        assert(type(callback) == "function", "Expected a function, got a " .. type(callback))
        local uniqueName
        if #Helper.uniqueNamePool > 0 then
            uniqueName = Helper.uniqueNamePool[1]
            table.remove(Helper.uniqueNamePool, 1)
        else
            local nextIndex = Global.getVar(GLOBAL_COUNTER_NAME) or 1
            assert(nextIndex < 200, "Probably a callback leak (or are you too greedy ?).")
            --Helper.dumpFunction("Global.setVar", GLOBAL_COUNTER_NAME, nextIndex + 1)
            Global.setVar(GLOBAL_COUNTER_NAME, nextIndex + 1)
            --log("Global callback count: " .. tostring(nextIndex))
            uniqueName = "generatedCallback" .. tostring(nextIndex)
        end
        --Helper.dumpFunction("Global.setVar", uniqueName)
        Global.setVar(uniqueName, callback)
        return uniqueName
    else
        return Helper._getNopCallback()
    end
end

---
function Helper.unregisterGlobalCallback(uniqueName)
    --Helper.dumpFunction("Helper.unregisterGlobalCallback", uniqueName)
    if uniqueName ~= "generatedCallback0" then
        local callback = Global.getVar(uniqueName)
        assert(callback, "Unknown global callback: " .. uniqueName)
        --Global.setVar(uniqueName, nil)
        table.insert(Helper.uniqueNamePool, uniqueName)
    end
end

---
function Helper.clearButtons(object)
    local buttons = object.getButtons()
    if buttons then
        for _, button in ipairs(buttons) do
            local callback = button.click_function
            if callback then
                assert(Helper.startsWith(callback, "generatedCallback"), "Not a generated callback: " .. callback)
                Helper.unregisterGlobalCallback(callback)
            end
        end
        object.clearButtons()
    end
end

---
function Helper.getButton(object, index)
    local buttons = object.getButtons()
    assert(buttons)
    for _, button in ipairs(buttons) do
        if button.index == index then
            return button
        end
    end
    return nil
end

---
function Helper.removeButton(object, index)
    local button = Helper.getButton(object, index)
    assert(button, "No button with index: " .. tostring(index))
    local callback = button.click_function
    if callback then
        assert(Helper.startsWith(callback, "generatedCallback"), "Not a generated callback: " .. callback)
        Helper.unregisterGlobalCallback(callback)
    end
    object.removeButton(index)
end

---
function Helper.removeButtons(object, indexes)
    local orderedIndexes = indexes
    table.sort(orderedIndexes, function(a, b) return a > b end)
    local previousIndex
    for _, index in ipairs(indexes) do
        assert(not previousIndex or previousIndex > index)
        Helper.removeButton(object, index)
        previousIndex = index
    end
end

---
function Helper.getID(object)
    assert(object)
    if object.getGMNotes then
        return object.getGMNotes()
    else
        return object.gm_notes
    end
end

--- The created anchor will be saved but could be automatically destroyed at reload using Helper.destroyTransientObjects().
function Helper.createTransientAnchor(nickname, position)
    local continuation = Helper.createContinuation()

    local data = {
        Name = "Custom_Model",
        Transform = {
            posX = 0,
            posY = 0,
            posZ = 0,
            rotX = 0,
            rotY = 180,
            rotZ = 0,
            scaleX = 1,
            scaleY = 1,
            scaleZ = 1
        },
        Nickname = nickname,
        Description = "Generated transient anchor.",
        GMNotes = "",
        AltLookAngle = {
            x = 0,
            y = 0,
            z = 0
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
                    r = 0,
                    g = 0,
                    b = 0
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
            anchor.interactable = false
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
    local count = 0
    for _, object in ipairs(Global.getObjects()) do
        if Helper.isTransient(object) then
            --log("Destroy " .. object.getName())
            object.destruct()
            count = count + 1
        end
    end
    -- log("Destroyed " .. tostring(count) .. " anchors.")
end

---
function Helper.append(parent, set)
    for name, value in pairs(set) do
        parent[name] = value
    end
    return parent
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
    assert(#table > 0 or #Helper.getKeys(table) == 0, "Not an indexed table")
    if true then
        for i = #table, 2, -1 do
            local j = math.random(i)
            table[i], table[j] = table[j], table[i]
        end
    end
end

function Helper.pickAny(table)
    return table[math.random(#table)]
end

function Helper.pickAnyKey(set)
    local keys = Helper.getKeys(set)
    return keys[math.random(#keys)]
end

function Helper.shuffleDeck(deck)
    assert(deck)
    if true then
        deck.shuffle()
    end
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
function Helper.isElementOf(element, elements)
    return Helper.tableContains(elements, element)
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
function Helper.hasAnyTag(object, tags)
    for _, tag in ipairs(tags) do
        if object.hasTag(tag) then
            return true
        end
    end
    return false
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
    local str = ""
    for i, element in ipairs({...}) do
        if i > 1 then
            str = str .. " "
        end
        str = str .. tostring(element)
    end
    log(str)
end

---
function Helper.dumpFunction(...)
    local args = {...}
    local str
    local notNilArgCount = #Helper.getKeys(args)
    local argCount = notNilArgCount
    local i = 1
    while i <= argCount do
        local element = args[i]
        if element == nil and i < argCount then
            argCount = argCount + 1
        end

        if i == 1 then
            assert(type(element) == "string")
            str = element .. "("
        else
            local strElement
            if type(element) == "string" then
                strElement = '"' .. tostring(element) .. '"'
            elseif type(element) == "function" then
                strElement = '<func>'
            else
                strElement = tostring(element) or "?"
            end
            str = str .. strElement
        end

        if i == argCount then
            str = str .. ")"
        elseif i > 1 then
            str = str .. ", "
        end

        i = i + 1
    end
    log(str)
end

---
function Helper.concatTables(...)
    local result = {}
    for _, t in ipairs({...}) do
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
            return copy
        else
            return something
        end
    else
        error("Unexpected type: " .. t)
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

---
function Helper.filter(elements, p)
    local filteredElements = {}
    for _, element in ipairs(elements) do
        if p(element) then
            table.insert(filteredElements, element)
        end
    end
    return filteredElements
end

---
function Helper.map(elements, f)
    local newElements = {}
    for k, v in pairs(elements) do
        newElements[k] = f(k, v)
    end
    return newElements
end

---
function Helper.mapValues(elements, f)
    local newElements = {}
    for k, v in ipairs(elements) do
        newElements[k] = f(v)
    end
    return newElements
end

---
function Helper.forEach(elements, f)
    assert(elements)
    assert(f)
    for k, v in pairs(elements) do
        f(k, v)
    end
end

---
function Helper.forEachRecursively(elements, f)
    assert(elements)
    assert(f)
    for k, v in pairs(elements) do
        if type(v) == "table" and not Helper.isSomeKindOfObject(v) then
            Helper.forEachRecursively(v, f)
        else
            f(k, v)
        end
    end
end

---
function Helper.clearTable(table)
    for k, _ in pairs(table) do
        table[k] = nil
    end
end

---
function Helper.mutateTable(table, newTable)
    Helper.clearTable(table)
    for k, v in pairs(newTable) do
        table[k] = v
    end
end

---
function Helper.partialApply(f, ...)
    assert(f)
    local args = {...}
    return function (...)
        for _, arg in ipairs({...}) do
            table.insert(args, arg)
        end
        return f(table.unpack(args))
    end
end

---
function Helper.noPhysicsNorPlay(...)
    for _, object in pairs({...}) do
        object.setLock(true)
        object.interactable = false
    end
end

---
function Helper.noPlay(...)
    for _, object in pairs({...}) do
        object.setLock(false)
        object.interactable = false
    end
end

---
function Helper.physicsAndPlay(...)
    for _, object in pairs({...}) do
        object.setLock(false)
        object.interactable = true
    end
end

---
function Helper.negate(predicate)
    return function (...)
        return not predicate(...)
    end
end

--- http://lua-users.org/wiki/StringRecipes
function Helper.startsWith(str, start)
    return str:sub(1, #start) == start
end

--- http://lua-users.org/wiki/StringRecipes
function Helper.endsWith(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

---
function Helper.createTemporalQueue(delay)
    local tq = {
        delay = delay or 0.25,
        actions = {}
    }

    function tq.submit(action)
        assert(action)
        table.insert(tq.actions, action)
        if #tq.actions == 1 then
            tq.activateLater()
        end
    end

    function tq.activateLater()
        Wait.time(function ()
            local action = tq.actions[1]
            table.remove(tq.actions, 1)
            if #tq.actions > 0 then
                tq.activateLater()
            end
            action()
        end, tq.delay)
    end

    return tq
end

return Helper
