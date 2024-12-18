local Helper = require("utils.Helper")

-- Make it a class (and upgrade createPark into newPark)?
local Park = {
    objectsInTransit = {}
}

---
function Park.createCommonPark(tags, slots, margins, rotation, rotationSnap, zones)
    assert(#slots > 0)
    local finalZones = (zones and #zones > 0) and zones or { Park.createTransientBoundingZone(0, margins, slots) }
    local name = Helper.stringConcat(tags) .. "_" .. finalZones[1].getGUID()

    local park = Park.createPark(
        name,
        slots,
        rotation,
        finalZones,
        tags,
        nil,
        false,
        true)

    local p = slots[1]:copy()
    p:setAt("y", 2)
    Helper.createTransientAnchor(name .. "Park", p).doAfter(function (anchor)
        park.anchor = anchor
        park.slots = nil
        park.slotHeight = slots[1].y
        local snapPoints = {}
        for _, slot in ipairs(slots) do
            table.insert(snapPoints, Helper.createRelativeSnapPoint(anchor, slot, rotationSnap or false, tags))
        end
        anchor.setSnapPoints(snapPoints)
    end)

    return park
end

--[[
    A park is basically an open field bag with a fixed size and a visual
    arrangement of its content.

    name: a unique name for the park.
    slots: the slot positions.
    rotation: the optional rotation to apply to parked objects.
    zones: one or more zones to test if an object is in the park.
    tags: restriction on the park content.
    description: an optional restriction on the park content.
    locked: should the park content be locked?
]]
---
function Park.createPark(name, slots, rotation, zones, tags, description, locked, smooth)
    assert(#slots > 0, "No slot provided for new park.")
    assert(zones and #zones > 0, "No park zones provided.")

    -- Check all slots in the zone.

    return {
        name = name,
        slots = slots,
        rotation = rotation,
        zones = zones,
        tags = tags,
        tagUnion = false,
        description = description,
        locked = locked,
        smooth = smooth,
    }
end

---
function Park._getSlots(park)
    local slots = park.slots
    if not slots then
        slots = {}
        for _, snapPoint in ipairs(park.anchor.getSnapPoints()) do
            local slot = Helper.getSnapPointAbsolutePosition(park.anchor, snapPoint.position)
            slot:setAt('y', park.slotHeight)
            table.insert(slots, slot)
        end
    end
    assert(#slots > 0, park.name)
    return slots
end

---
function Park.move(park, offset)
    if park.slots then
        for _, slot in ipairs(park.slots) do
            slot.x = slot.x + offset.x
            slot.y = slot.y + offset.y
            slot.z = slot.z + offset.z
        end
    end
end

--[[
    Transfert objects from a park to another.

    n: the number of objects to be transfered.
    fromParkName: the source park.
    toParkName: the destination park.
]]
---
function Park.transfert(n, fromPark, toPark)
    assert(n >= 0, "Negative count.")
    assert(fromPark, "No source park.")
    assert(toPark, "No destination park.")
    assert(fromPark ~= toPark, "Source and destination parks are the same.")

    local holders = {}
    for i, object in ipairs(Park.getObjects(fromPark)) do
        if i <= n then
            holders[i] = {object = object}
        else
            break
        end
    end

    return Park._putHolders(holders, toPark)
end

--[[
    Put an external object into a park, provided it remains a free slot.
    object: the object to put in the park.
    toParkName: the name of the destination park.
]]
---
function Park.putObject(object, toPark)
    assert(object, "No object provided.")
    return Park.putObjects({object}, toPark) > 0
end

---
function Park.putObjects(objects, toPark)
    assert(objects, "No objects provided.")
    local holders = {}
    for _, object in ipairs(objects) do
        table.insert(holders, { object = object })
    end
    return Park._putHolders(holders, toPark)
end

---
function Park.putObjectFromBag(objectBag, toPark, count)
    assert(objectBag, "No object bag provided.")
    local holders = {}
    for _ = 1, (count or 1) do
        table.insert(holders, {bag = objectBag})
    end
    return Park._putHolders(holders, toPark) == (count or 1)
end

---
function Park._putHolders(holders, toPark)
    assert(toPark, "No destination park.")

    local now = Time.time
    Park._updateObjectsInTransit(now)

    Park._instantTidyUp(toPark)

    local emptySlots = Park.findEmptySlots(toPark)

    local count = math.max(0, math.min(#emptySlots, #holders))

    for i = 1, count do
        local holder = holders[i]
        if holder.object then
            Park._moveObjectToPark(holder.object, emptySlots[i], toPark)
            Park.objectsInTransit[holder.object] = { time = now, destination = toPark }
        elseif holder.bag then
            Park.uid = (Park.uid or 0) + 1
            local uid = Park.uid
            Park.objectsInTransit[uid] = { time = now, destination = toPark }
            Park._takeObjectToPark(holder.bag, emptySlots[i], toPark).doAfter(function (object)
                Park._mutateObjectInTransit(uid, object)
            end)
        end
    end

    return count
end

---
function Park._mutateObjectInTransit(before, after)
    local newObjectsInTransit = {}
    for object, transit in pairs(Park.objectsInTransit) do
        if object == before then
            if after then
                newObjectsInTransit[after] = transit
            end
        else
            newObjectsInTransit[object] = transit
        end
    end
    Park.objectsInTransit = newObjectsInTransit
end

---
function Park._updateObjectsInTransit(now)
    local newObjectsInTransit = {}
    for object, transit in pairs(Park.objectsInTransit) do
        local duration = now - transit.time
        local notResting = function (o)
            return type(o) ~= "number" and not o.resting
        end
        if Helper.isNotNil(object) and duration < 2.5 and (duration == 0 or notResting(object)) then
            newObjectsInTransit[object] = transit
        end
    end
    Park.objectsInTransit = newObjectsInTransit
end

--- FIXME Not needed anymore.
function Park.onceStabilized(toPark)
    return Helper.fakeContinuation("Park.onceStabilized")
end

---
function Park.getZones(park)
    return park.zones
end

---
function Park.getPosition(park)
    return park.zones[1].getPosition()
end

---
function Park.getObjects(park, customFilter, ignoreTransit)
    assert(park)
    local parkId = Helper.getID(park)

    local isOneOfThem
    if customFilter then
        isOneOfThem = function (object)
           return customFilter(object, park.tags)
        end
    else
        isOneOfThem = function (object)
            return
                (park.tagUnion and Helper.hasAnyTag(object, park.tags) or Helper.hasAllTags(object, park.tags)) and
                (not parkId or parkId == Helper.getID(object))
        end
    end

    Park._updateObjectsInTransit(Time.time)
    local objects = {}
    for _, zone in ipairs(park.zones) do
        for _, object in ipairs(zone.getObjects()) do
            if not Park.objectsInTransit[object] and isOneOfThem(object) then
                table.insert(objects, object)
            end
        end
    end
    if not ignoreTransit then
        for object, transit in pairs(Park.objectsInTransit) do
            if transit.destination == park and isOneOfThem(object) then
                table.insert(objects, object)
            end
        end
    end
    return objects
end

---
function Park.getAnyObject(park)
    local objects = Park.getObjects(park)
    return #objects > 0 and objects[1] or nil
end

---
function Park.isEmpty(park)
    return #Park.getObjects(park) == 0
end

---
function Park._instantTidyUp(park)

    local freeSlots = {}
    local freeSlotCount = 0
    for _, slot in ipairs(Park._getSlots(park)) do
        freeSlots[slot] = {}
        freeSlotCount = freeSlotCount + 1
    end

    local freeObjects = {}
    local freeObjectCount = 0
    for _, object in ipairs(Park.getObjects(park, nil, true)) do
        freeObjects[object] = true
        freeObjectCount = freeObjectCount + 1
    end

    while freeSlotCount > 0 and freeObjectCount > 0 do

        for object, _ in pairs(freeObjects) do
            local nearestSqrtDistance = 0
            local nearestCandidates = nil
            for slot, candidates in pairs(freeSlots) do
                if candidates then
                    local sqrtDistance = Vector.sqrDistance(slot, object.getPosition())
                    if not nearestCandidates or sqrtDistance < nearestSqrtDistance then
                        nearestSqrtDistance = sqrtDistance
                        nearestCandidates = candidates
                    end
                end
            end
            assert(nearestCandidates)
            nearestCandidates[object] = nearestSqrtDistance
        end

        for slot, candidates in pairs(freeSlots) do
            local nearestSqrtDistance = 0
            local nearestObject = nil
            for object, sqrtDistance in pairs(candidates) do
                if not nearestObject or sqrtDistance < nearestSqrtDistance then
                    nearestSqrtDistance = sqrtDistance
                    nearestObject = object
                end
            end
            if nearestObject then
                freeSlots[slot] = nil
                freeSlotCount = freeSlotCount - 1
                freeObjects[nearestObject] = nil
                freeObjectCount = freeObjectCount - 1

                nearestObject.setPosition(slot)
                if park.rotation then
                    nearestObject.setRotation(park.rotation:copy())
                end
                nearestObject.setLock(park.locked)
            end
        end
    end

    --assert(#freeObjects == 0, "Too many objects.")
end

---
function Park._moveObjectToPark(object, slot, park)
    object.setLock(park.locked)
    local offset = Vector(0, 0, 0)
    if not object.getLock() then
        -- Nice drop are only for unlocked objects.
        offset = Vector(0, 1, 0)
    end
    if park.smooth then
        object.setPositionSmooth(slot + offset, false, false)
    else
        object.setPosition(slot + offset)
    end
    if park.rotation then
        object.setRotation(park.rotation:copy())
    end
end

---
function Park._takeObjectToPark(bag, slot, park)
    local continuation = Helper.createContinuation("Park._takeObjectToPark/" .. park.name)
    local takeParameters = {}
    local offset = Vector(0, 0, 0)
    if not park.locked then
        -- Nice drop are only for unlocked objects.
        offset = Vector(0, 1, 0)
    end
    takeParameters.position = slot + offset
    if park.rotation then
        takeParameters.rotation = park.rotation
    end
    takeParameters.callback_function = function (object)
        object.locked = park.locked
        continuation.run(object)
    end
    bag.takeObject(takeParameters)
    return continuation
end

function Park.findEmptySlots(park)
    local freeSlots = {}
    if park.avoidStacking then
        freeSlots = Park._findEmptySlots(park, function (object)
            return Helper.getID(object) ~= "Transient"
        end)
    end
    if #freeSlots == 0 then
        freeSlots = Park._findEmptySlots(park, nil)
    end
    return freeSlots
end

-- freeSlots is built in such a way that we only check each object once
-- (i.e. a given object cannot take multiple slots). We also take care
-- of only considering the 2D distance and selecting the lowest slot.
function Park._findEmptySlots(park, customFilter)
    --Helper.dumpFunction("Park._findEmptySlots")
    local freeSlots = Helper.shallowCopy(Park._getSlots(park))

    for _, object in ipairs(Park.getObjects(park, customFilter)) do
        local sameHeightPosition = object.getPositionSmooth() or object.getPosition()
        local lowerSlotIndex = nil
        local lowerSlotHeight = nil
        for i, slot in ipairs(freeSlots) do
            sameHeightPosition.y = slot.y
            if Vector.sqrDistance(slot, sameHeightPosition) < 0.1 and (not lowerSlotIndex or slot.y < lowerSlotHeight) then
                lowerSlotIndex = i
                lowerSlotHeight = slot.y
            end
        end
        --Helper.dump("Found:", object.getGUID(), "->", tostring(object), "@", lowerSlotIndex)
        if lowerSlotIndex then
            table.remove(freeSlots, lowerSlotIndex)
        end
        if #freeSlots == 0 then
            break
        end
    end

    return freeSlots
end

---
function Park.createTransientBoundingZone(rotationAroundY, margins, points)
    assert(#points > 0)

    local barycenter = nil
    for _, slot in ipairs(points) do
        assert(slot)
        if barycenter then
            barycenter = barycenter + slot
        else
            barycenter = slot:copy()
        end
    end
    barycenter = barycenter * (1.0 / #points)

    local minBounds
    local maxBounds
    for i, slot in ipairs(points) do
        local transformedSlot = (slot - barycenter):rotateOver('y', -rotationAroundY)
        if i > 1 then
            minBounds.x = math.min(minBounds.x, transformedSlot.x)
            minBounds.y = math.min(minBounds.y, transformedSlot.y)
            minBounds.z = math.min(minBounds.z, transformedSlot.z)
            maxBounds.x = math.max(maxBounds.x, transformedSlot.x)
            maxBounds.y = math.max(maxBounds.y, transformedSlot.y)
            maxBounds.z = math.max(maxBounds.z, transformedSlot.z)
        else
            minBounds = transformedSlot:copy()
            maxBounds = transformedSlot:copy()
        end
    end

    local sx = 2 * math.max(math.abs(minBounds.x), math.abs(maxBounds.x))
    local sy = 2 * math.max(math.abs(minBounds.y), math.abs(maxBounds.y))
    local sz = 2 * math.max(math.abs(minBounds.z), math.abs(maxBounds.z))

    local zone = spawnObject({
        type = 'ScriptingTrigger',
        position = barycenter,
        rotation = Vector(0, rotationAroundY, 0),
        scale = {
            math.max(0.1, sx + margins.x),
            math.max(0.1, sy + margins.y),
            math.max(0.1, sz + margins.z)}
    })

    Helper.markAsTransient(zone)

    return zone
end

return Park
