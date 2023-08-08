local Core = {
    eventListenersByTopic = {}
}

---
function Core.registerEventListener(topic, byTopicKey, listener)
    assert(listener)
    local listeners = Core.eventListenersByTopic[topic]
    if not listeners then
        listeners = {}
        Core.eventListenersByTopic[topic] = listeners
        --log("Adding Core handle: " .. tostring(topic))
        Core["" .. topic] = function (...)
            Core.emitEvent(topic, ...)
        end
    end
    listeners[byTopicKey] = listener
end

---
function Core.unregisterEventListener(topic, byTopicKey)
    local listeners = Core.eventListenersByTopic[topic]
    assert(listeners and listeners[byTopicKey])
    listeners[byTopicKey] = nil
    if #Core.eventListenersByTopic[topic] == 0 then
        Core.eventListenersByTopic[topic] = nil
        Core["" .. topic] = nil
    end
end

---
function Core.emitEvent(topic, ...)
    local listeners = Core.eventListenersByTopic[topic]
    if listeners then
        for _, eventListener in pairs(listeners) do
            eventListener(...)
        end
    end
end

---
function Core.getIdentity()
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
function Core.isSomeKindOfObject(data)
    return getmetatable(data) ~= nil
end

---
function Core.stillExist(object)
    return object and getObjectFromGUID(object.getGUID())
end

---
function Core.resolveGUIDs(reportUnresolvedGUIDs, data)
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
            if not Core.isSomeKindOfObject(data) then
                newData = {}
                for i, v in ipairs(data) do
                    newData[i] = Core.resolveGUIDs(reportUnresolvedGUIDs, v)
                end
                for k, v in pairs(data) do
                    newData[k] = Core.resolveGUIDs(reportUnresolvedGUIDs, v)
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
function Core.getHardcodedPositionFromGUID(GUID, x, y, z)
    return Vector(x, y, z)
end

return Core
