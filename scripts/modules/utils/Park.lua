local Helper = require("utils.Helper")

-- TODO Make it a class (and upgrade createPark into newPark).
local Park = {}

---
function Park.createCommonPark(tags, slots, margins, rotation)
    local zone = Park.createBoundingZone(0, margins, slots)

    local name = Helper.stringConcat(tags)

    local p = slots[1]
    p:setAt("y", 1)
    Helper.createTransientAnchor(name .. "Park", p).doAfter(function (anchor)
        local snapPoints = {}
        for _, slot in ipairs(slots) do
            table.insert(snapPoints, Helper.createRelativeSnapPoint(anchor, slot, false, tags))
        end
        anchor.setSnapPoints(snapPoints)
    end)

    return Park.createPark(
        name,
        slots,
        rotation or Vector(0, 0, 0),
        zone,
        tags,
        nil,
        false,
        true)
end

--[[
    A park is basically an open field bag with a fixed size and a visual
    arrangement of its content. A park content is determined at each operation
    (usually implying a tidy up on the way), so beware of the asynchronous
    moves from park to park.

    name: a unique name for the park.
    slots: the slot positions.
    rotation: the optional rotation to apply to parked objects.
    zone: a zone to test if an object is in the park.
    tags: restriction on the park content.
    description: an optional restriction on the park content.
    locked: should the park content be locked?
]]--
---
function Park.createPark(name, slots, rotation, zone, tags, description, locked, smooth)
    assert(#slots > 0, "No slot provided for new park.")
    assert(zone, "No park zone provided.")

    Helper.setSharedTable(name, {})

    -- Check all slots in the zone.

    return {
        name = name,
        slots = slots,
        rotation = rotation,
        zone = zone,
        tags = tags,
        tagUnion = false,
        description = description,
        locked = locked,
        smooth = smooth
    }
end

--[[
    Transfert objects from a park to another. Beware that moves are asynchronous
    and that chaining multiple calls to this function could be problematic. A
    single call, whatever the amount transfered, is ok.

    n: the number of objects to be transfered.
    fromParkName: the source park.
    toParkName: the destination park.
]]--
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
]]--
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
function Park.putObjectFromBag(objectBag, toPark)
    assert(objectBag, "No object bag provided.")
    return Park._putHolders({{bag = objectBag}}, toPark) > 0
end

---
function Park._putHolders(holders, toPark)
    assert(holders, "No holders provided.")
    assert(toPark, "No destination park.")

    --[[
        Park objects usually come from other objects (one of them at least). As
        such, it shall not be assigned (it is treated as a pure right value).
        Copies must be made when needed (even for temporarily storing it).
    ]]--

    local now = Time.time

    local objectsInTransit = Helper.getSharedTable(toPark.name)

    local newObjectsInTransit = {}
    for object, transit in pairs(objectsInTransit) do
        if now - transit < 3.0 then
            newObjectsInTransit[object] = transit
        end
    end

    Park._instantTidyUp(toPark, newObjectsInTransit)

    local emptySlots = Park._findEmptySlots(toPark)

    -- Count *after* newObjectsInTransit (and it's a sparse table).
    local skipCount = 0
    for _, _ in pairs(newObjectsInTransit) do
        skipCount = skipCount + 1
    end
    local count = math.max(0, math.min(#emptySlots - skipCount, #holders))

    for i = 1, count do
        local holder = holders[i]
        if holder.object then
            Park._moveObjectToPark(holder.object, emptySlots[i + skipCount], toPark)
            newObjectsInTransit[holder.object] = now
        elseif holder.bag then
            Park._takeObjectToPark(holder.bag, emptySlots[i + skipCount], toPark)
            -- Can't really register anything for a transit and doing it
            -- asynchronously would be both too late and unsafe.
        end
    end

    Helper.setSharedTable(toPark.name, newObjectsInTransit)

    return count
end

---
function Park._waitStabilisation(park, callback)
    Wait.condition(callback, function()
        local objectsInTransit = Helper.getSharedTable(park.name)
        return #objectsInTransit == 0
    end)
end

---
function Park.getObjects(park)
    assert(park)
    local objects = {}
    for _, object in ipairs(park.zone.getObjects()) do
        local objectsInTransit = Helper.getSharedTable(park.name)
        if not Helper.tableContains(objectsInTransit, object) then
            local isOneOfThem =
                (park.tagUnion and Helper.hasAnyTag(object, park.tags) or Helper.hasAllTags(object, park.tags)) and
                (not park.description or park.description == object.getDescription())
            if isOneOfThem then
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
function Park._instantTidyUp(park, newObjectsInTransit)

    local freeSlots = {}
    local freeSlotCount = 0
    for _, slot in ipairs(park.slots) do
        freeSlots[slot:copy()] = {}
        freeSlotCount = freeSlotCount + 1
    end

    local freeObjects = {}
    local freeObjectCount = 0
    for _, object in ipairs(Park.getObjects(park)) do
        freeObjects[object] = true
        freeObjectCount = freeObjectCount + 1
        newObjectsInTransit[object] = nil
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
                nearestObject.setRotation(park.rotation:copy())
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
    local takeParameters = {}
    local offset = Vector(0, 0, 0)
    if not park.locked then
        -- Nice drop are only for unlocked objects.
        offset = Vector(0, 1, 0)
    end
    takeParameters.position = slot + offset
    if park.rotation then
        takeParameters.rotation = park.rotation:copy()
    end
    takeParameters.callback_function = function ()
        takeParameters.locked = park.locked
    end
    bag.takeObject(takeParameters)
end

---
function Park._findEmptySlots(park)
    local freeSlots = Park.deepCopy(park.slots)

    for _, object in ipairs(Park.getObjects(park)) do
        for i, slot in ipairs(freeSlots) do
            if Vector.sqrDistance(slot, object.getPosition()) < 0.1 then
                table.remove(freeSlots, i)
                break
            end
        end
        if #freeSlots == 0 then
            break
        end
    end

    return freeSlots
end

--- TODO Unify with Helper.deepCopy which doesn't use copy?
function Park.deepCopy(c)
    local copy = {}
    for i, e in ipairs(c) do
        copy[i] = e:copy()
    end
    return copy
end

---
function Park.createBoundingZone(rotationAroundY, margins, points)
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

    local minBounds = nil
    local maxBounds = nil
    for i, slot in ipairs(points) do
        local transformedSlot = (slot:copy() - barycenter):rotateOver('y', -rotationAroundY)
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

    -- FIXME Created zones are not usable immediately.
    local zone = spawnObject({
        type = 'ScriptingTrigger',
        position = barycenter,
        rotation = Vector(0, rotationAroundY, 0),
        scale = {
            math.max(1, sx + margins.x),
            math.max(1, sy + margins.y),
            math.max(1, sz + margins.z)}
    })

    Helper.markAsTransient(zone)

    return zone
end

return Park
