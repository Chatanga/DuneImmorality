--[[
    Miscellaneous. Sections marked with (!) are used extensively in this mod
    and should be studied closely to understand it.
    - Exception handling
    - Event listeners (!)
    - GUID helper functions
    - Deck manipulations
    - Anchors (!)
    - Snappoints and anchored buttons
    - Dynamic (button) callbacks (!)
    - Continuations (!)
    - Basic OOP (!)
    - player color support
    - Specialized queues
    - TTS miscellaneous
    - Lua miscellaneous
]]
local Helper = {
    eventListenersByTopic = {},
    uniqueNamePool = {},

    MINIMAL_DURATION = 1/30,
    AREA_BUTTON_COLOR = { 0, 0, 0, 0 },
    ERASE = function ()
        return "__erase__"
    end
}

math.randomseed(os.time())

---@generic TreeParameter
---@alias Tree<TreeParameter> TreeParameter | table<string, Tree<TreeParameter>>

-- *** Exception handling ***

--[[
    Note: this function won't be able to catch any "<Unknow Error>",
    because it happens inside the native code called by Lua. When
    facing this kind of error, you probably need to look for any access
    to dead reference. Per instance:

        local x = getObjectFromGUID('...')
        x.doSomething()
        x.destruct()
        x.doSomething() -- Ok, because destruct is asynchronous.
        Wait.time(function()
            if x then
                x.doSomething() -- Raise an <Unknow Error>.
            end
            if x ~= nil then
                x.doSomething() -- Line not executed.
            end
        end, 1)
]]
---@param context string
---@param callable function
function Helper.wrapFailable(context, callable, defaultReturnValue)
    return function (...)
        local ranSuccessfully, returnValue = pcall(callable, ...)
        if ranSuccessfully then
            return returnValue
        else
            broadcastToAll("An error has happened in a script!", "Red")
            log("Error in script (Global): " .. returnValue)
            Helper._postError(Helper.functionToString(context, ...), returnValue)
            return defaultReturnValue
        end
    end
end

--[[
    Post an anonymous error log on my site in case an error has occured and been
    catched.
]]
---@param context string
---@param error string
function Helper._postError(context, error)

    local saveInfo = Global.getVar("saveInfo")
    if not saveInfo then
        return
    end

    local url = "https://hihan.org/tts-error-log/index.php"
    local form = {
        action = "add",
        modname = saveInfo.modname,
        build = saveInfo.build,
        stable = saveInfo.stable,
        context = Helper.toString(context),
        error = Helper.toString(error),
    }

    WebRequest.post(url, form, function(request)
        if request.is_error then
            Helper.dump("Request failed:", request.error)
        else
            local responseData = JSON.decode(request.text)
            if not responseData.code or responseData.code ~= "0" then
                Helper.dump("Response:", responseData)
            end
        end
    end)
end

-- *** Event listeners ***

---@param topic string
---@param listener function
---@return function
function Helper.registerEventListener(topic, listener)
    return Helper.registerEventListenerWithPriority(topic, 0, listener)
end

--[[
    Register a callback to be synchronously called each time an event of the
    corresponding topic is emitted. Each callback will be called with the same
    parameters used for emitting the event. The provided priority specifies in
    which order a callback is called (higher priority callbacks are called
    first). Note that it is best to rely as little as possible on priorities.
]]
---@param topic string
---@param priority integer
---@param listener function
---@return function the provided callback (to register and store it in the same line).
function Helper.registerEventListenerWithPriority(topic, priority, listener)
    assert(topic)
    assert(priority)
    assert(listener)

    local listenersWithPriority = Helper.eventListenersByTopic[topic]
    if not listenersWithPriority then
        listenersWithPriority = {}
        Helper.eventListenersByTopic[topic] = listenersWithPriority
    end

    local index
    for i, listenerWithPriority in ipairs(listenersWithPriority) do
        if listenerWithPriority.priority < priority then
            index = i
            break
        end
    end
    index = index or #listenersWithPriority + 1

    table.insert(listenersWithPriority, index, {
        listener = listener,
        priority = priority,
    })

    return listener
end

--[[
    Unregister a previously registered callback for a given topic.
]]
---@param topic string
---@param listener function
function Helper.unregisterEventListener(topic, listener)
    assert(listener)
    local listenersWithPriority = Helper.eventListenersByTopic[topic]

    local found = false
    for i, listenerWithPriority in ipairs(listenersWithPriority) do
        if listenerWithPriority.listener == listener then
            table.remove(listenersWithPriority, i)
            found = true
            break
        end
    end
    assert(found)

    if #Helper.getKeys(listenersWithPriority) == 0 then
        Helper.eventListenersByTopic[topic] = nil
    end
end

--[[
    Emit an event: all listeners registered for the specified topic will
    be called with the following parameters.
]]
---@param topic string
---@param ... unknown
function Helper.emitEvent(topic, ...)
    local listenersWithPriority = Helper.eventListenersByTopic[topic]
    if listenersWithPriority then
        for _, listenerWithPriority in ipairs(Helper.shallowCopy(listenersWithPriority)) do
            Helper.wrapFailable("listener on " .. tostring(topic), listenerWithPriority.listener)(...)
        end
    end
end

-- *** GUID helper functions ***

---@param data any
---@return boolean
function Helper._isSomeKindOfObject(data)
    return getmetatable(data) ~= nil
end

--[[
    Return a copy of the provided data where every leaf identified as a
    GUID is replaced by the corresponding object (or nil if it can't be
    resolved).
]]
---@param reportUnresolvedGUIDs boolean
---@param data any
---@return any
function Helper.resolveGUIDs(reportUnresolvedGUIDs, data)
    local newData = data
    if data == Helper.ERASE then
        -- NOP
        newData = nil
    elseif data then
        local t = type(data)
        if t == "string" then
            -- FIXME Doesn't Lua support more elaborate regex?
            if data:match("[a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9]") then
                newData = getObjectFromGUID(data)
                if not newData and reportUnresolvedGUIDs then
                    log("[resolveGUIDs] Unknow GUID: '" .. data .. "'")
                end
            else
                log("[resolveGUIDs] Not a GUID: '" .. data .. "'")
            end
        elseif t == "table" then
            -- Avoid digging inside complex object.
            if not Helper._isSomeKindOfObject(data) then
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
            -- Not a problem per se, but still unexpected in our use cases.
            log("[resolveGUIDs] Unknown type: " .. t)
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
]]
---@param guid string
---@param x number
---@param y number
---@param z number
---@return Vector
function Helper.getHardcodedPositionFromGUID(guid, x, y, z)
    return Vector(x, y, z)
end

-- *** Deck manipulations ***

--[[
    A synthetic move of an object, combining multiple operations.
]]
---@param object Object
---@param position Vector
---@param rotation? Vector
---@param smooth? boolean
---@param flipAtTheEnd? boolean
---@return Continuation A continuation run once the object is motionless.
function Helper._moveObject(object, position, rotation, smooth, flipAtTheEnd)
    assert(object)

    local continuation = Helper.createContinuation("Helper._moveObject")

    if smooth then
        object.setPositionSmooth(position)
    else
        object.setPosition(position)
    end

    if rotation then
        if smooth then
            object.setRotationSmooth(rotation)
        else
            object.setRotation(rotation)
        end
    end

    Helper.onceMotionless(object).doAfter(function ()
        if flipAtTheEnd then
            object.flip()
        end
        continuation.run(object)
    end)

    return continuation
end

--[[
    Prefer the "deal" method when possible? Would it prevent the card from being
    grabbed by anther player's hand zone?
]]
---@param zone table
---@param position Vector?
---@param rotation Vector?
---@param smooth boolean?
---@param flipAtTheEnd boolean?
---@return Continuation A continuation run once the object is spawned.
function Helper.moveCardFromZone(zone, position, rotation, smooth, flipAtTheEnd)
    assert(zone.type == "Scripting")
    local continuation = Helper.createContinuation("Helper.moveCardFromZone")
    local deckOrCard = Helper.getDeckOrCard(zone)
    if deckOrCard then
        if deckOrCard.type == "Deck" then
            local parameters = {
                position = position,
                flip = flipAtTheEnd and true,
                smooth = smooth or false,
                -- It matters that the target position is not directly a deck or card.
                -- Otherwise, the taken card won't be created and the callback won't be
                -- called.
                callback_function = continuation.run
            }
            if rotation then
                parameters.rotation = rotation
            end
            deckOrCard.takeObject(parameters)
        elseif deckOrCard.type == "Card" then
            local safePosition = position + Vector(0, 1, 0)
            Helper._moveObject(deckOrCard, safePosition, rotation, smooth, flipAtTheEnd).doAfter(continuation.run)
        else
            error("Unexpected type: " .. deckOrCard.type)
        end
    else
        continuation.run(nil)
    end
    return continuation
end

---@param objects Object[]
---@return string[]
function Helper.getAllCardNames(objects)
    local allCardNames = {}
    for _, object in ipairs(objects) do
        local t = object.type
        if t == "Card" then
            table.insert(allCardNames, Helper.getID(object))
        elseif t == "Deck" then
            ---@cast object Bag
            for _, innerObject in ipairs(object.getObjects()) do
                table.insert(allCardNames, Helper.getID(innerObject))
            end
        end
    end
    return allCardNames
end

--[[
    Return a list of cards (not spawned in general) from the returned value of
    'Helper.getDeckOrCard(zone)'. If there is none, an empty list is returned.
]]
---@param deckOrCard? DeckOrCard
---@return (Card|DeadObject)[]
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

--[[
    Return the number of cards from the returned value of 'Helper.getDeckOrCard(zone)'.
]]
---@param object? Object
---@return integer
function Helper.getCardCount(object)
    if not object then
        return 0
    elseif object.type == "Card" then
        return 1
    elseif object.type == "Deck" then
        ---@cast object Deck
        return object.getQuantity()
    else
        return 0
    end
end

--[[
    Return the first deck or card found in the provide zone. Deck and card hold
    by a player are ignored.
]]
---@param zone Zone
---@return DeckOrCard?
function Helper.getDeckOrCard(zone)
    assert(zone)
    assert(type(zone) ~= 'string', tostring(zone) .. ' looks like a GUID, not a zone')
    -- It is pairs, not ipairs!
    -- TODO Confirm it...
    for _, object in pairs(zone.getObjects()) do
        if object.type and not object.held_by_color and (object.type == "Card" or object.type == "Deck") then
            ---@cast object Card|Deck
            return object
        end
    end
    return nil
end

---@param zone Zone
---@param action fun(deck: Deck)
---@return boolean
function Helper.withAnyDeck(zone, action)
    local predicate = function (object)
        return not object.held_by_color and object.type == "Deck"
    end
    return Helper.withAnyItem(zone, predicate, action)
end

---@param zone Zone
---@param action fun(deck: Deck)
---@return integer
function Helper.withAllDecks(zone, action)
    local predicate = function (object)
        return not object.held_by_color and object.type == "Deck"
    end
    return Helper.withAllItems(zone, predicate, action)
end

---@param zone Zone
---@param action fun(card: Card)
---@return boolean
function Helper.withAnyCard(zone, action)
    local predicate = function (object)
        return not object.held_by_color and object.type == "Card"
    end
    return Helper.withAnyItem(zone, predicate, action)
end

---@param zone Zone
---@param action fun(object: Object)
---@return boolean
function Helper.withAnyItem(zone, predicate, action)
    return Helper._with(zone, false, predicate, action) > 0
end

---@param zone Zone
---@param predicate fun(object: Object): boolean
---@param action fun(object: Object)
---@return integer
function Helper.withAllItems(zone, predicate, action)
    return Helper._with(zone, true, predicate, action)
end

---@param zone Zone
---@param all boolean
---@param predicate fun(object: Object): boolean
---@param action fun(object: Object)
---@return integer
function Helper._with(zone, all, predicate, action)
    assert(zone)
    assert(type(zone) ~= 'string', tostring(zone) .. ' looks like a GUID, not a zone')
    local cards = {}
    for _, object in ipairs(zone.getObjects()) do
        if predicate(object) then
            table.insert(cards, object)
        end
    end
    for _, card in ipairs(cards) do
        action(card)
        if not all then
            break
        end
    end
    return #cards
end

-- *** Anchors (small uniscale pink squares used to anchor things around) ***

--[[
    The created anchor will be saved but could be automatically destroyed at
    reload using Helper.destroyTransientObjects().
]]
---@param nickname string?
---@param position Vector
---@return Continuation A continuation run once the anchor is spawned.
function Helper.createTransientAnchor(nickname, position)
    local continuation = Helper.createContinuation("Helper.createTransientAnchor")

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
            MeshURL = "https://steamusercontent-a.akamaihd.net/ugc/2042984592862608679/0383C231514AACEB52B88A2E503A90945A4E8143/",
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

-- @generic T: Object (not possible?)
---@param object Object
---@return Object
function Helper.markAsTransient(object)
    -- Tagging is not usable on a zone without filtering its content.
    object.setGMNotes("Transient")
    return object
end

---@param object Object
---@return boolean
function Helper._isTransient(object)
    return object.getGMNotes() == "Transient"
end

function Helper.destroyTransientObjects()
    local count = 0
    for _, object in ipairs(Global.getObjects()) do
        if Helper._isTransient(object) then
            --log("Destroy " .. object.getName())
            object.destruct()
            count = count + 1
        end
    end
    --log("Destroyed " .. tostring(count) .. " anchors.")
end

-- *** Snappoints and anchored buttons ***

--[[
    Create a snapPoint relative to a parent centered on the provided zone, but
    at the height of the parent.
]]
---@param parent Object
---@param zone Zone
---@param rotationSnap boolean
---@param tags string[]
---@return SnapPoint
function Helper.createRelativeSnapPointFromZone(parent, zone, rotationSnap, tags)
    return Helper.createRelativeSnapPoint(parent, zone.getPosition(), rotationSnap, tags)
end

---@param parent Object
---@param position Vector
---@param rotationSnap boolean
---@param tags string[]
---@return SnapPoint
function Helper.createRelativeSnapPoint(parent, position, rotationSnap, tags)
    local p = Vector(position.x, parent.getPosition().y, position.z)
    local snapPoint = {
        position = parent.positionToLocal(p),
        rotation_snap = rotationSnap,
        tags = tags
    }
    return snapPoint
end

---@param parent Object
---@param snapPoint SnapPoint
---@return Vector
function Helper.getSnapPointAbsolutePosition(parent, snapPoint)
    return parent.positionToWorld(snapPoint)
end

---@param zone Zone
---@param ground number
---@param aboveGround number
---@param tooltip string
---@param callback ClickFunction
function Helper.createAnchoredAreaButton(zone, ground, aboveGround, tooltip, callback)
    assert(zone)
    assert(aboveGround)
    local p = zone.getPosition()
    local anchorPosition = Vector(p.x, ground - 0.5, p.z)
    Helper.createTransientAnchor(nil, anchorPosition).doAfter(function (anchor)
        Helper.createAreaButton(zone, anchor, ground + aboveGround, tooltip, callback)
    end)
end

---@param zone Zone
---@param anchor Object
---@param altitude number
---@param tooltip string
---@param callback ClickFunction
---@return string
function Helper.createAreaButton(zone, anchor, altitude, tooltip, callback)
    assert(zone)
    assert(anchor)
    assert(altitude)

    local zoneOffset = zone.getPosition() - anchor.getPosition()
    local zoneScale = zone.getScale()
    local sizeFactor = 500 -- 350

    local width = zoneScale.x * sizeFactor
    local height = zoneScale.z * sizeFactor

    local dx = zoneOffset.x
    local dz = zoneOffset.z

    return Helper.createSizedAreaButton(width, height, anchor, dx, dz, altitude, tooltip, callback)
end

---@param zone Zone
---@param anchor Object
---@param altitude number
---@param tooltip string
---@param callback ClickFunction
---@return string
function Helper.createExperimentalAreaButton(zone, anchor, altitude, tooltip, callback)
    assert(zone)
    assert(anchor)
    assert(altitude)

    local zoneOffset = zone.getPosition() - anchor.getPosition()
    local zoneScale = zone.getScale()

    local width = zoneScale.x * 450
    local height = zoneScale.z * 200

    local dx = zoneOffset.x
    local dz = zoneOffset.z

    return Helper.createSizedAreaButton(width, height, anchor, dx, dz, altitude, tooltip, callback)
end

---@param width number
---@param height number
---@param anchor Object
---@param dx number
---@param dz number
---@param altitude number
---@param tooltip string
---@param callback ClickFunction
---@return string
function Helper.createSizedAreaButton(width, height, anchor, dx, dz, altitude, tooltip, callback)
    assert(anchor)

    local anchorPosition = anchor.getPosition()

    local parameters = {
        click_function = Helper.registerGlobalCallback(callback),
        position = Vector(anchorPosition.x + dx, altitude, anchorPosition.z + dz),
        width = width,
        height = height,
        color = Helper.AREA_BUTTON_COLOR,
        hover_color = { 0.7, 0.7, 0.7, 0.7 },
        press_color = { 0.5, 1, 0.5, 0.4 },
        font_color = { 1, 1, 1, 100 },
        tooltip = tooltip,
    }

    -- 0.75 | 10 ?
    Helper.createAbsoluteButtonWithRoundness(anchor, 0.75, parameters)

    return parameters.click_function
end

---@param object Object
---@param parameters {}
---@return Button
function Helper.createButton(object, parameters)
    local button = Helper._createWidget("Button", object, parameters)
    ---@cast button Button
    return button
end

---@param name string
---@param object Object
---@param parameters {}
---@return Widget
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
]]
---
---@param object Object
---@param roundness number
---@param parameters {}
---@return Button
function Helper.createAbsoluteButtonWithRoundness(object, roundness, parameters)
    return Helper.createButton(object, Helper._createAbsoluteWidgetWithRoundnessParameters(object, roundness, parameters))
end

---@param object Object
---@param roundness number
---@param parameters {}
---@return {}
function Helper._createAbsoluteWidgetWithRoundnessParameters(object, roundness, parameters)
    assert(object)
    assert(roundness >= 0, "Zero or negative roundness won't work as intended.")
    assert(roundness <= 10, "Roundness beyond 10 won't work as intended.")
    if parameters.color and parameters.font_color then
        --[[
            The opacity of a button color is applied to its content, including the label.
            Thus, to achieve a transparent button with a visible lablel, the alpha of the
            "font_color" needs to be pushed beyond 1. In fact, in this situation, the
            alpha seems to be interpreted as a percentage (100% being full opaque).
        ]]
        assert(parameters.color[4] > 0 or parameters.font_color[4] > 1, "Unproper label opacity!")
    end

    --[[
        Scale is a problem here. We change it to artificially adjust the roundness, but
        we also needs to ajust the font height, which is capped and more or less blurry
        depending on it...
    ]]

    local scale = object.getScale()
    local invScale = Vector(1 / scale.x, 1 / scale.y, 1 / scale.z)

    -- Only to counteract the absolute roundness of the background.
    local rescale = 1 / roundness

    local p = parameters['position']
    if p then
        p = Helper.toVector(p)
        -- Inverting the X coordinate comes from our global 180° rotation around Y.
        p = Vector(p.x, p.y, p.z)

        p = p - object.getPosition()
        p = Vector(-p.x, p.y, p.z)

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

---@alias CollectNet table<string, fun(name: string, position: Vector)>

---@param object Object
---@param net CollectNet
function Helper.collectSnapPoints(object, net)
    if not object then
        return
    end
    local snapPoints = object.getSnapPoints()
    for _, snapPoint in ipairs(snapPoints) do
        if snapPoint.tags then
            for _, tag in ipairs(snapPoint.tags) do
                for prefix, collector in pairs(net) do
                    if Helper.startsWith(tag, prefix) then
                        local name = tag:sub(prefix:len() + 1):gsub("^%u", string.lower)
                        collector(name, object.positionToWorld(snapPoint.position))
                    end
                end
            end
        else
            Helper.dump("Unexpected snap tags:", snapPoint.tags)
        end
    end
end

-- *** Dynamic (button) callbacks ***

---@param callback? function
---@return string
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
            if nextIndex >= 300 then
                Helper.dump("Alarming dynamic global callback count:", nextIndex)
            end
            Global.setVar(GLOBAL_COUNTER_NAME, nextIndex + 1)
            uniqueName = "generatedCallback" .. tostring(nextIndex)
        end
        Global.setVar(uniqueName, Helper.wrapFailable(uniqueName, callback))
        return uniqueName
    else
        return Helper._getNopCallback()
    end
end

---@param uniqueName string
function Helper.unregisterGlobalCallback(uniqueName)
    if uniqueName ~= "generatedCallback0" then
        local callback = Global.getVar(uniqueName)
        --assert(callback, "Unknown global callback: " .. uniqueName)
        if callback then
            Global.setVar(uniqueName, function ()
                Helper.dump("Dead callback called:", uniqueName)
            end)
            table.insert(Helper.uniqueNamePool, uniqueName)
        else
            Helper.dump("Unknown global callback: " .. uniqueName)
        end
    end
end

---@return string
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

---@param object Object
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

---@param object Object
---@param index integer
---@return Button?
function Helper._getButton(object, index)
    local buttons = object.getButtons()
    assert(buttons)
    for _, button in ipairs(buttons) do
        if button.index == index then
            return button
        end
    end
    return nil
end

---@param object Object
---@param index integer
function Helper._removeButton(object, index)
    local button = Helper._getButton(object, index)
    assert(button, "No button with index: " .. tostring(index))
    local callback = button.click_function
    if callback then
        assert(Helper.startsWith(callback, "generatedCallback"), "Not a generated callback: " .. callback)
        Helper.unregisterGlobalCallback(callback)
    end
    object.removeButton(index)
end

---@param object Object
---@param indexes integer[]
function Helper.removeButtons(object, indexes)
    local orderedIndexes = indexes
    table.sort(orderedIndexes, function (a, b) return a > b end)
    local previousIndex
    for _, index in ipairs(indexes) do
        assert(not previousIndex or previousIndex > index)
        Helper._removeButton(object, index)
        previousIndex = index
    end
end

-- *** Continuations (some kind of promises) ***

---@param name string?
---@return Continuation
function Helper.createContinuation(name)
    assert(name)

    if not Helper.pendingContinuations then
        Helper.pendingContinuations = {}
    end

    -- TODO Add run function as generic parameter?
    ---@class Continuation
    ---@field name string
    ---@field what function
    ---@field tick function
    ---@field doAfter function
    ---@field next function
    ---@field finish function
    ---@field run function
    ---@field cancel function
    ---@field forget function

    local continuation = {
        name = name,
        start = Time.time,
        canceled = false,
        done = false,
        actions = {},
        what = function ()
            return "continuation"
        end
    }

    continuation.tick = function (toBeNotified)
        local duration = Time.time - continuation.start
        if toBeNotified and duration > 10 then
            toBeNotified()
        else
            assert(duration < 10, "Roting continuation: " .. (continuation.name or "<nil>"))
        end
    end

    continuation.doAfter = function (action)
        assert(type(action) == 'function')
        if continuation.done then
            if not continuation.canceled then
                local wrappedAction = Helper.wrapFailable("sync after " .. tostring(continuation.name), action)
                wrappedAction(table.unpack(continuation.parameters, 1, continuation.parameters.n))
            end
        else
            table.insert(continuation.actions, action)
        end
    end

    continuation.next = function (...)
        continuation.parameters = table.pack(...)
        for _, action in ipairs(continuation.actions) do
            local wrappedAction = Helper.wrapFailable("async after " .. tostring(continuation.name), action)
            wrappedAction(...)
        end
    end

    continuation.finish = function ()
        Helper.pendingContinuations[continuation] = nil
        continuation.done = true
    end

    continuation.run = function (...)
        continuation.next(...)
        continuation.finish()
    end

    continuation.cancel = function ()
        continuation.canceled = true
        continuation.finish()
    end

    continuation.forget = function ()
        Helper.pendingContinuations[continuation] = nil
    end

    Helper.pendingContinuations[continuation] = true

    return continuation
end

---@return Continuation
function Helper.fakeContinuation(...)
    local fakeContinuation = Helper.createContinuation("Helper.alwaysContinuation")
    fakeContinuation.run(...)
    return fakeContinuation
end

---@param timeout? number
---@return Continuation
function Helper.onceStabilized(timeout)
    local continuation = Helper.createContinuation("Helper.onceStabilized")
    continuation.forget()

    local start = os.time()
    local delayed = false
    local success = false

    Wait.condition(function ()
        continuation.run(success)
    end, function ()
        local duration = os.time() - start
        success = Helper.isStabilized(delayed or duration <= 5)
        if not success then
            if not delayed and duration > 5 then
                delayed = true
                broadcastToAll("Delaying transition (see system log)...")
            end
            if duration > (timeout or 10) then
                return true
            end
        end
        return success
    end)

    return continuation
end

---@return boolean
function Helper.isStabilized(beQuiet)
    local count = 0
    if Helper.pendingContinuations then
        for continuation, _ in pairs(Helper.pendingContinuations) do
            if continuation then
                if not beQuiet then
                    log("Pending continuation: " .. continuation.name)
                    continuation.tick(function ()
                        log("Forgetting the pending continuation on timeout")
                        continuation.forget()
                    end)
                end
                count = count + 1
            end
        end
    end
    return count == 0
end

---@return Continuation
function Helper.onceMotionless(object)
    local guid = object.getGUID()
    local continuation = Helper.createContinuation("Helper.onceMotionless")
    -- Wait 1 frame for the movement to start.
    Wait.time(function ()
        Wait.condition(function ()
            Wait.time(function ()
                continuation.run(object)
            end, Helper.MINIMAL_DURATION)
        end, function ()
            continuation.tick()
            --- Deal with a card/object being swallowed up in a deck/bag at the end of its move.
            local objectHasDisappeared = getObjectFromGUID(guid) == nil
            return objectHasDisappeared or object.resting
        end)
    end, Helper.MINIMAL_DURATION)
    return continuation
end

---@return Continuation
function Helper.onceSwallowedUp(object)
    local guid = object.getGUID()
    local continuation = Helper.createContinuation("Helper.onceSwallowedUp")
    -- Wait 1 frame for the movement to start.
    Wait.time(function ()
        Wait.condition(function ()
            Wait.time(function ()
                continuation.run(object)
            end, Helper.MINIMAL_DURATION)
        end, function ()
            continuation.tick()
            local objectHasDisappeared = getObjectFromGUID(guid) == nil
            return objectHasDisappeared
        end)
    end, Helper.MINIMAL_DURATION)
    return continuation
end

---@return Continuation
function Helper.onceShuffled(container)
    local continuation = Helper.createContinuation("Helper.onceShuffled")
    -- TODO Is there a better way?
    Wait.time(function ()
        continuation.run(container)
    end, 2)
    return continuation
end

---@param delay number
---@param count? integer
---@return Continuation
function Helper.onceTimeElapsed(delay, count)
    local continuation = Helper.createContinuation("Helper.onceTimeElapsed")
    local countdown = count or 1
    Wait.time(function ()
        countdown = countdown - 1
        continuation.next()
        if countdown == 0 then
            continuation.finish()
        end
    end, delay, count)
    return continuation
end

---@param count integer
---@return Continuation
function Helper.onceFramesPassed(count)
    local continuation = Helper.createContinuation("Helper.onceFramesPassed")
    -- Wait.frames is unreliable with players with high FPS configurations.
    Wait.time(function ()
        continuation.run()
    end, count * Helper.MINIMAL_DURATION)
    return continuation
end

---@return Continuation
function Helper.onceOneDeck(zone)
    local continuation = Helper.createContinuation("Helper.onceOneDeck")

    local getDecksOrCards = function ()
        return Helper.filter(zone.getObjects(), function (object)
            return object.type == "Card" or object.type == "Deck"
        end)
    end

    local maxCardCount = 0
    for _, deckOrCard in ipairs(getDecksOrCards()) do
        maxCardCount = math.max(maxCardCount, Helper.getCardCount(deckOrCard))
    end

    Wait.condition(function ()
        Helper.withAnyDeck(zone, continuation.run)
    end, function ()
        local deckOrCards = getDecksOrCards()
        if #deckOrCards == 1 then
            local deckOrCard = deckOrCards[1]
            local cardCound = Helper.getCardCount(deckOrCard)
            if cardCound > maxCardCount and deckOrCard.resting then
                return true
            end
        end
        continuation.tick()
        return false
    end)
    return continuation
end

---@return Continuation
function Helper.repeatChainedAction(count, action)
    local continuation = Helper.createContinuation("Helper.repeatChainedAction")
    if count > 0 then
        local innerContinuation = action()
        assert(innerContinuation and innerContinuation.doAfter, "Provided action must return a continuation!")
        innerContinuation.doAfter(function ()
            Helper.repeatChainedAction(count - 1, action).doAfter(function ()
                continuation.run(count)
            end)
        end)
    else
        continuation.run(count)
    end
    return continuation
end

---@param actions (fun(): Continuation)[]
---@return Continuation
function Helper.chainActions(actions)
    return Helper._chainActions(1, actions)
end

---@param actions (fun(): Continuation)[]
---@return Continuation
function Helper._chainActions(i, actions)
    local continuation = Helper.createContinuation("Helper._chainActions")
    if i <= #actions then
        local innerContinuation = actions[i]()
        assert(innerContinuation and innerContinuation.doAfter, "Provided action must return a continuation!")
        innerContinuation.doAfter(function ()
            Helper._chainActions(i + 1, actions).doAfter(continuation.run)
        end)
    else
        continuation.run()
    end
    return continuation
end

---@param object Object
---@param count integer
---@param action fun()
---@return Continuation
function Helper.repeatMovingAction(object, count, action)
    local continuation = Helper.createContinuation("Helper.repeatMovingAction")
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

-- *** Basic OOP ***

---@param superclass? table
---@param data? table
---@return table
function Helper.createClass(superclass, data)
    -- We can't make this test unfortunately, since it superclasses typically come through lazyRequire.
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

---@param class table
---@param data? table
---@return table
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

---@param instance table
---@return table
function Helper.unused_getClass(instance)
    assert(instance.what() == "instance")
    local class = getmetatable(instance)
    assert(class and class.what() == "class")
    return class
end

-- *** player color support ***

---@param color string
---@return Player
function Helper.findPlayerByColor(color)
    return Player[color]
end

--- Colour shuffler script, developed by markimus on steam.
---@param colors string[]
---@return Continuation
function Helper.randomizePlayerPositions(colors)
    local continuation = Helper.createContinuation("Helper.randomizePlayerPositions")

    if #colors <= 1 then
        printToAll("There must be more than one player for shuffling to work.", "Red")
        continuation.run()
        return continuation
    end
    if Player["Black"].seated then
        printToAll("Please remove Player Black for shuffling to work.", "Red")
        continuation.run()
        return continuation
    end

    local randomColours = {}

    -- Insert the colours.

    for _, v in pairs(colors) do
        table.insert(randomColours, v)
    end

    Helper.shuffle(randomColours)

    local seatedPlayers = {}
    for i, v in pairs(colors) do
        seatedPlayers[v] = {}
        seatedPlayers[v].target = randomColours[i]
        seatedPlayers[v].myColour = v
        --printToAll(Player[v].steam_name .. "(".. v ..") -> ".. ranColours[i], {1, 1, 1})
        if seatedPlayers[v].target == v then
            seatedPlayers[v].prevMoved = true
            seatedPlayers[v].moved = true
        else
            seatedPlayers[v].prevMoved = false
            seatedPlayers[v].moved = false
        end
    end

    -- Start shuffling players.

    local coroutineHolder = {}
    coroutineHolder.registeredCallback = Helper.registerGlobalCallback(function ()
        Helper.unregisterGlobalCallback(coroutineHolder.registeredCallback)

        for timeout = 1, 50 do

            -- Go through seated players. if they haven't moved, check if they can be moved.
            for i, v in pairs(seatedPlayers) do
                --print("Test")
                if v.moved == false then
                    if not Player[v.target].seated then
                        local myC = v.myColour
                        if Player[myC].seated then
                            --print("Moving player ".. myC)
                            Player[myC]:changeColor(v.target)
                            while Player[myC].seated and not Player[v.target].seated do
                                coroutine.yield(0)
                            end
                            v.myColour = v.target
                            v.moved = true
                        else
                            table.remove(seatedPlayers, i)
                        end
                    end
                end
            end

            local checkIfSame = true
            for _, v in pairs(seatedPlayers) do
                if v.prevMoved ~= v.moved then
                    checkIfSame = false
                    break
                end
            end

            if checkIfSame then
                --print("Is same.")
                local allNonMovedPlayers = {}
                for i, v in pairs(seatedPlayers) do
                    if not v.moved then
                        table.insert(allNonMovedPlayers, v)
                    end
                end

                if #allNonMovedPlayers ~= 0 then
                    local lastPlayer = allNonMovedPlayers[#allNonMovedPlayers]
                    Player[lastPlayer.myColour]:changeColor("Black")
                    lastPlayer.myColour = "Black"
                    while not Player["Black"].seated do
                        coroutine.yield(0)
                    end
                end
            end

            local count1, count2 = 0, 0
            for _, v in pairs(seatedPlayers) do
                count1 = count1 + 1
                if v.moved then
                    count2 = count2 + 1
                end
            end

            if count1 == count2 then
                break
            end

            for _, v in pairs(seatedPlayers) do
                v.prevMoved = v.moved
            end

            coroutine.yield(0)
        end

        Helper.sleep(2)
        continuation.run()

        return 1
    end)
    startLuaCoroutine(Global, coroutineHolder.registeredCallback)

    return continuation
end

-- *** Specialized queues ***

---@param delay? number
---@return { submit: fun(action: fun()) }
function Helper.createTemporalQueue(delay)
    local tq = {
        delay = delay or 0.25,
        actions = {},
    }

    function tq.submit(action)
        assert(action)
        table.insert(tq.actions, action)
        if #tq.actions == 1 then
            tq._activateLater()
        end
    end

    function tq._activateLater()
        Helper.onceTimeElapsed(tq.delay).doAfter(function ()
            local action = tq.actions[1]
            table.remove(tq.actions, 1)
            if #tq.actions > 0 then
                tq._activateLater()
            end
            action()
        end)
    end

    return tq
end

---@return { submit: fun(action: fun(distance: integer)) }
function Helper.createSpaceQueue()
    local sq = {
        distance = 0,
    }

    function sq.submit(action)
        assert(action)
        action(sq.distance)
        if sq.distance == 0 then
            sq.updater = Wait.time(sq._reduce, 1)
        end
        sq.distance = sq.distance + 1
    end

    function sq._reduce()
        sq.distance = sq.distance - 1
        if sq.distance > 0 then
            Wait.time(sq._reduce, 1)
        end
    end

    return sq
end

---@generic T
---@param name string
---@param separationDelay number
---@param coalesce fun(event: T, lastEvent: T): T
---@param handle fun(event: T)
---@return { submit: fun(event: T), flush: fun() }
function Helper.createCoalescentQueue(name, separationDelay, coalesce, handle)
    local cq = {
        separationDelay = separationDelay or 1,
    }

    function cq._handleLater()
        assert(cq.lastEvent)
        if cq.delayedHandler then
            Wait.stop(cq.delayedHandler)
            cq.delayedHandler = nil
            cq.continuation.cancel()
        end
        cq.continuation = Helper.createContinuation("Helper.createCoalescentQueue/" .. name)
        cq.continuation.doAfter(function ()
            assert(cq.lastEvent)
            cq.delayedHandler = nil
            local event = cq.lastEvent
            cq.lastEvent = nil
            handle(event)
        end)
        cq.delayedHandler = Wait.time(cq.continuation.run, cq.separationDelay)
    end

    function cq.submit(event)
        assert(event)
        if cq.lastEvent then
            local newEvent = coalesce(event, cq.lastEvent)
            if newEvent then
                cq.lastEvent = newEvent
            else
                local oldEvent = cq.lastEvent
                cq.lastEvent = event
                handle(oldEvent)
            end
        else
            cq.lastEvent = event
        end
        cq._handleLater()
    end

    function cq.flush()
        if cq.delayedHandler then
            assert(cq.lastEvent)
            Wait.stop(cq.delayedHandler)
            cq.delayedHandler = nil
            cq.continuation.cancel()
            local event = cq.lastEvent
            cq.lastEvent = nil
            handle(event)
        end
    end

    return cq
end

-- *** TTS miscellaneous ***

--- Intended to be called from a coroutine.
---@param durationInSeconds number
function Helper.sleep(durationInSeconds)
    local Time = os.clock() + durationInSeconds
    while os.clock() < Time do
        coroutine.yield(0)
    end
end

---@param object Object|DeadObject
---@return string
function Helper.getID(object)
    assert(object)
    if object.getGMNotes then
        ---@cast object Object
        return object.getGMNotes()
    else
        ---@cast object DeadObject
        return object.gm_notes
    end
end

---@param deck Deck
function Helper.shuffleDeck(deck)
    assert(deck)
    if true then
        deck.shuffle()
    end
end

---@param object Object
---@param tags string[]
---@return boolean
function Helper.hasAllTags(object, tags)
    for _, tag in ipairs(tags) do
        if not object.hasTag(tag) then
            return false
        end
    end
    return true
end

---@param object Object
---@param tags string[]
---@return boolean
function Helper.hasAnyTag(object, tags)
    for _, tag in ipairs(tags) do
        if object.hasTag(tag) then
            return true
        end
    end
    return false
end

---@param ... Object
function Helper.noPhysics(...)
    for _, object in pairs({...}) do
        object.setLock(true)
        object.interactable = true
    end
end

---@param ... Object
function Helper.noPlay(...)
    for _, object in pairs({...}) do
        object.setLock(false)
        object.interactable = false
    end
end

---@param ... Object
function Helper.noPhysicsNorPlay(...)
    for _, object in pairs({...}) do
        object.setLock(true)
        object.interactable = false
    end
end

---@param ... Object
function Helper.physicsAndPlay(...)
    for _, object in pairs({...}) do
        object.setLock(false)
        object.interactable = true
    end
end

-- *** Lua miscellaneous ***

---@param ... string
function Helper.toCamelCase(...)
    local camelString
    for i, str in ipairs({...}) do
        if i > 1 then
            camelString = camelString .. str:gsub("^%l", string.upper)
        else
            camelString = str:gsub("^%u", string.lower)
        end
    end
    return camelString
end

---@param ... string
function Helper.unused_toPascalCase(...)
    local pascalString
    for i, str in ipairs({...}) do
        if i > 1 then
            pascalString = pascalString .. str:gsub("^%l", string.upper)
        else
            pascalString = str:gsub("^%l", string.upper)
        end
    end
    return pascalString
end

---@param data table
---@return Vector
function Helper.toVector(data)
    if not data then
        log("nothing to vectorize")
        return Vector(0, 0, 0)
    elseif type(data) ~= "table" then
        error("Can't vectorize back a " .. type(data) .. " (" .. tostring(data) .. ")")
    elseif Helper._isSomeKindOfObject(data) then
        return data
    elseif #data > 0 then
        return Vector(data[1], data[2], data[3])
    else
        return Vector(data.x, data.y, data.z)
    end
end

---@param position Vector the original position
---@param ground integer The absolute height (y coordinate)
function Helper.onGround(position, ground)
    return Vector(position.x, ground, position.z)
end

---@param table table
---@return boolean
function Helper.isEmpty(table)
    return #table == 0 and #Helper.getKeys(table) == 0
end

---@generic T
---@param objects T[]
---@param otherObjects T[]
function Helper.unused_addAll(objects, otherObjects)
    assert(objects)
    assert(otherObjects)
    for _, object in ipairs(otherObjects) do
        assert(object)
        table.insert(objects, object)
    end
end

---@param parent table
---@param set table
---@return table
function Helper.append(parent, set)
    for name, value in pairs(set) do
        parent[name] = value
    end
    return parent
end

---@param zone Zone
---@param object Object
---@return boolean
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

--[[
    Fisher-Yates shuffle, in-place – for each position, pick an element from those not yet picked.
]]
---@generic T
---@param items T[]
function Helper.shuffle(items)
    assert(items)
    assert(#items > 0 or #Helper.getKeys(items) == 0, "Not an indexed table")
    if true then
        for i = #items, 2, -1 do
            local j = math.random(i)
            items[i], items[j] = items[j], items[i]
        end
    end
end

---@generic T
---@param items T[]
---@return T
function Helper.pickAny(items)
    return items[math.random(#items)]
end

---@generic K, V
---@param items table<K, V>
---@return K
function Helper.pickAnyKey(items)
    local keys = Helper.getKeys(items)
    return keys[math.random(#keys)]
end

---@param n number
---@return integer
function Helper.signum(n)
    if n > 0 then
        return 1
    elseif n < 0 then
        return -1
    else
        return 0
    end
end

---@param positions Vector[]
---@return Vector
function Helper.unused_getCenter(positions)
    assert(positions)
    assert(#positions > 0)
    local p = Vector(0, 0, 0)
    for _, position in ipairs(positions) do
        p = p + position
    end
    p:scale(1 / #positions)
    return p
end

---@generic T
---@param table T[]
---@param element T
---@return boolean
function Helper.tableContains(table, element)
    for _, containedElement in ipairs(table) do
        if containedElement == element then
            return true
        end
    end
    return false
end

---@generic T
---@param element T
---@param elements T[]
---@return boolean
function Helper.isElementOf(element, elements)
    return Helper.tableContains(elements, element)
end

---@param elements any[]
---@return string
function Helper.stringConcat(elements)
    local str = ""
    for _, element in ipairs(elements) do
        str = str .. tostring(element)
    end
    return str
end

---@param ... any
function Helper.dump(...)
    Helper._log(Helper.argumentsToString(...))
end

---@param ... any
function Helper.argumentsToString(...)
    local str = ""
    local args = table.pack(...)
    for i = 1, args.n do
        if i > 1 then
            str = str .. " "
        end
        str = str .. Helper.toString(args[i])
    end
    return str
end

---@param ... any
function Helper.dumpFunction(...)
    Helper._log(Helper.functionToString(...))
end

---@param ... any
---@return string
function Helper.functionToString(...)
    local args = table.pack(...)
    local str
    for i = 1, args.n do
        local arg = args[i]

        if i == 1 then
            assert(type(arg) == "string")
            str = arg .. "("
        else
            str = str .. Helper.toString(args[i], true)
        end

        if i == args.n then
            str = str .. ")"
        elseif i > 1 then
            str = str .. ", "
        end
    end
    return str
end

---@param str string
function Helper._log(str)
    if Helper.lastMessage ~= str then
        if Helper.lastMessage then
            if Helper.lastMessageCount > 1 then
                log("[x" .. tostring(Helper.lastMessageCount) .. "] " .. Helper.lastMessage)
            elseif Helper.lastMessageCount > 0 then
                log(Helper.lastMessage)
            end
        end
        log(str)
        Helper.lastMessage = str
        Helper.lastMessageCount = 0
    else
        Helper.lastMessageCount = Helper.lastMessageCount + 1
    end
end

---@param object any
---@param quoted? boolean
---@return string
function Helper.toString(object, quoted)
    if object ~= nil then
        local objectType = type(object)
        if objectType == "table" then
            local str
            if #object > 0 then
                str = "["
                for i, element in ipairs(object) do
                    if i > 1 then
                        str = str .. ", "
                    end
                    str = str .. Helper.toString(element, quoted)
                end
                str = str .. "]"
            else
                str = "{"
                local i = 0
                for key, value in pairs(object) do
                    i = i + 1
                    if i > 1 then
                        str = str .. ", "
                    end
                    str = str .. Helper.toString(key, quoted) .. " -> " .. Helper.toString(value, quoted)
                end
                str = str .. "}"
            end
            return str
        elseif objectType == "function" then
            return "<function>"
        elseif objectType == "string" then
            return quoted and '"' .. object .. '"' or object
        elseif objectType == "userdata" then
            return tostring(object) .. "/" .. tostring(Helper.getID(object))
        else
            return tostring(object)
        end
    else
        return "<nil>"
    end
end

---@generic T
---@param ... T[]
---@return T[]
function Helper.concatTables(...)
    local result = {}
    for _, t in ipairs({...}) do
        for _, element in ipairs(t) do
            table.insert(result, element)
        end
    end
    return result
end

---@param elements table
---@return table
function Helper.shallowCopy(elements)
    local copy = {}
    for k, v in pairs(elements) do
        copy[k] = v
    end
    return copy
end

---@param something table
---@return table
function Helper.deepCopy(something)
    local t = type(something)
    if Helper._isBasicType(t) then
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

---@param t string
---@return boolean
function Helper._isBasicType(t)
    return t == "nil"
        or t == "boolean"
        or t == "number"
        or t == "string"
        or t == "userdata"
        or t == "function"
        or t == "thread"
        or t == "table"
end

---@generic K
---@param elements table<K, any>
---@return K[]
function Helper.getKeys(elements)
    local keys = {}
    for k, _ in pairs(elements) do
        table.insert(keys, k)
    end
    return keys
end

---@generic V
---@param elements table<any, V>
---@return V[]
function Helper.getValues(elements)
    local values = {}
    for _, v in pairs(elements) do
        table.insert(values, v)
    end
    return values
end

---@generic T
---@param elements T[]
---@param i integer
---@param j integer
function Helper.swap(elements, i, j)
    assert(elements)
    if i ~= j then
        local tmp = elements[i]
        elements[i] = elements[j]
        elements[j] = tmp
    end
end

---@generic T
---@param elements T[]
function Helper.reverseInPlace(elements)
    assert(elements)
    local count = #elements
    for i = 1, count do
        local j = count + 1 - i
        if i < j then
            Helper.swap(elements, i, j)
        else
            break
        end
    end
end

---@generic T
---@param elements T[]
function Helper.cycleInPlace(elements)
    assert(elements)
    local count = #elements
    local first = elements[1]
    for i = 1, count do
        elements[i] = i < count and elements[i + 1] or first
    end
end

---@generic T
---@param elements T[]
---@param p fun(element: T): boolean
---@return T[]
function Helper.filter(elements, p)
    assert(elements)
    local filteredElements = {}
    for _, element in ipairs(elements) do
        if p(element) then
            table.insert(filteredElements, element)
        end
    end
    return filteredElements
end

-- TODO Explicit array=list/table=map versions.

---@generic K, V
---@param elements table<K, V>
---@param p fun(key: K, value: V): boolean
---@return integer
function Helper.count(elements, p)
    assert(elements)
    local count = 0
    for k, v in pairs(elements) do
        if p(k, v) then
            count = count + 1
        end
    end
    return count
end

---@generic K, V, W
---@param elements table<K, V>
---@param f fun(key: K, value: V): W
---@return table<K, W>
function Helper.map(elements, f)
    assert(elements)
    local newElements = {}
    for k, v in pairs(elements) do
        newElements[k] = f(k, v)
    end
    return newElements
end

---@generic K, V, W
---@param elements table<K, V>
---@param f fun(value: V): W
---@return table<K, W>
function Helper.mapValues(elements, f)
    assert(elements)
    local newElements = {}
    for k, v in pairs(elements) do
        newElements[k] = f(v)
    end
    return newElements
end

---@generic V, W
---@param elements V[]
---@param f fun(value: V): W
---@return W[]
function Helper.mapArrayValues(elements, f)
    assert(elements)
    local newElements = {}
    for i, v in ipairs(elements) do
        newElements[i] = f(v)
    end
    return newElements
end

---@generic K, V
---@param elements table<K, V>
---@param f fun(key: K, value: V)
function Helper.forEach(elements, f)
    assert(elements)
    assert(f)
    for k, v in pairs(elements) do
        f(k, v)
    end
end

---@generic K, V
---@param elements table<K, V>
---@param f fun(value: V)
function Helper.forEachValue(elements, f)
    assert(elements)
    assert(f)
    for _, v in ipairs(elements) do
        f(v)
    end
end

---@generic K, V
---@param elements table<K, V|table>
---@param f fun(key: K, value: V)
function Helper.forEachRecursively(elements, f)
    assert(elements)
    assert(f)
    for k, v in pairs(elements) do
        if type(v) == "table" and not Helper._isSomeKindOfObject(v) then
            Helper.forEachRecursively(v, f)
        else
            f(k, v)
        end
    end
end

---@param table table
function Helper._clearTable(table)
    for k, _ in pairs(table) do
        table[k] = nil
    end
end

---@param table table
---@param newTable table
function Helper.mutateTable(table, newTable)
    Helper._clearTable(table)
    for k, v in pairs(newTable) do
        table[k] = v
    end
end

---@param f function
---@param ... any
---@return function
function Helper.partialApply(f, ...)
    assert(f)
    local args = table.pack(...)
    return function (...)
        local appendedArgs = table.pack(...)
        for i = 1, appendedArgs.n do
            table.insert(args, appendedArgs[i])
        end
        args.n = args.n + appendedArgs.n
        return f(table.unpack(args, 1, args.n))
    end
end

---@param name string
---@return fun(object: table): any
function Helper.field(name)
    return function (object)
        return object[name]
    end
end

---@param predicate fun(...): boolean
---@return fun(...): boolean
function Helper.negate(predicate)
    return function (...)
        return not predicate(...)
    end
end

--- http://lua-users.org/wiki/StringRecipes
---@param str string
---@param start string
---@return boolean
function Helper.startsWith(str, start)
    return str:sub(1, #start) == start
end

--- http://lua-users.org/wiki/StringRecipes
---@param str string
---@param ending string
---@return boolean
function Helper.endsWith(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

---@param str string
---@param sep string
---@return string[]
function Helper.splitString(str, sep)
    local tokens = {}
    for token in string.gmatch(str, "([^" .. (sep or "%s") .. "]+)") do
        table.insert(tokens, token)
    end
    return tokens
end

---@param object Object
---@return boolean
function Helper.isNil(object)
    return object == nil
end

---@param object Object
---@return boolean
function Helper.isNotNil(object)
    return object ~= nil
end

---@generic T
---@param p fun(index: integer, element: T): boolean
---@param elements T[]
---@return T[]
function Helper.takeWhile(p, elements)
    assert(elements)
    local prefix = {}
    for i, element in ipairs(elements) do
        if p(i, element) then
            table.insert(prefix, element)
        else
            break
        end
    end
    return prefix
end

---@param min number
---@param max number
---@param n number
---@return boolean
function Helper.isInRange(min, max, n)
    return min <= n and n <= max
end

return Helper
