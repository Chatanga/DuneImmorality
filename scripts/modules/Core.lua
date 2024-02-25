local core = {}

core.onLoadCallbacks = {}

--[[
    Other modules (and final scripts) should use registerLoadablePart *after*
    any require calls to be initialized at the right time (if needed) and not
    define "onLoad" themselves.

    A typical usage is:

        core = require("core")
        a = require("A")
        b = require("B")
        c = require("C")

        _ = core.registerLoadablePart(function(script_state)
            ...
        end)
]]--
function core.registerLoadablePart(onLoadCallback)
    assert(not core.loaded, "Looks like you're calling 'registerLoadablePart' from a function.")
    assert(onLoadCallback)
    for _, existingOnLoadCallback in ipairs(core.onLoadCallbacks) do
        if existingOnLoadCallback == onLoadCallback then
            return
        end
    end
    core.onLoadCallbacks[#core.onLoadCallbacks + 1] = onLoadCallback
    return onLoadCallback
end

--[[
    See core.registerLoadablePart.
]]--
function onLoad(script_state)
    --log("Loading object " .. self.getGUID() .. " - " .. self.name)
    assert(not core.loaded, "Looks like you're calling 'onLoad' from a function.")
    core.loaded = true
    for _, onLoadCallback in ipairs(core.onLoadCallbacks) do
        onLoadCallback(script_state)
    end

    core.setGlobalStatus(self, true)
end

function onDestroy()
    --log("Destroying object " .. self.getGUID() .. " - " .. self.name)
    core.setGlobalStatus(self, nil)
end

function core.safeReload(object)
    assert(object)
    if core.setGlobalStatus(object, false) ~= true then
        --log("Reloading the not yet loaded object " .. object.getGUID() .. " - " .. object.name)
    end
    local newObject = object.reload()
    return newObject
end

function core.callOnAllLoadedObjects(functionToCall, parameters)
    local statuses = Global.getTable("core.statuses")
    if statuses then

        local copyOfStatuses = {}
        for GUID, loaded in pairs(statuses) do
            copyOfStatuses[GUID] = loaded
        end

        for GUID, loaded in pairs(copyOfStatuses) do
            if loaded then
                local loadedObject = nil
                if GUID == "-1" then -- Not an integer, but a GUID (string).
                    loadedObject = Global
                else
                    loadedObject = getObjectFromGUID(GUID)
                    assert(loadedObject, "Unresolvable loaded object " .. GUID)
                end
                if loadedObject.getVar(functionToCall) then
                    --log("On object ".. GUID .. " -> " .. loadedObject.name)
                    loadedObject.call(functionToCall, parameters)
                end
            else
                --log("Skipping reloading object ".. GUID)
            end
        end
    end
end

-- Atomic?
function core.setGlobalStatus(object, status)
    local GUID = object.getGUID()
    local statuses = Global.getTable("core.statuses")
    local oldStatus = nil
    if statuses then
        oldStatus = statuses[GUID]
    else
        statuses = {}
    end
    statuses[GUID] = status
    Global.setTable("core.statuses", statuses)
    return oldStatus
end

--[[
    A rather useless function in itself. However, calls to this function are
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
function core.getHardcodedPositionFromGUID(GUID, x, y, z)
    return Vector(x, y, z)
end

function core.isSomeKindOfObject(data)
    return getmetatable(data) ~= nil
end

function core.resolveGUIDs(reportUnresolvedGUIDs, data)
    local newData = data
    if data then
        local t = type(data)
        if t == "string" and string.match(data, "[a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9]") then
            newData = getObjectFromGUID(data)
            if not newData and reportUnresolvedGUIDs then
                log("[resolveGUIDs] Unknow GUID: " .. data)
            end
        elseif t == "table" then
            if not core.isSomeKindOfObject(data) then
                newData = {}
                for i, v in ipairs(data) do
                    newData[i] = core.resolveGUIDs(reportUnresolvedGUIDs, v)
                end
                for k, v in pairs(data) do
                    newData[k] = core.resolveGUIDs(reportUnresolvedGUIDs, v)
                end
            end
        elseif t == "number" then
            -- NOP
        else
            log("[resolveGUIDs] Unknown type: " .. t)
        end
    end
    return newData
end

function core.stillExist(object)
    return object and getObjectFromGUID(object.getGUID())
end

return core