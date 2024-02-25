local parkModule = {}

helperModule = require("HelperModule")

--[[
    A park is basically an open field bag with a fixed size and a visual
    arrangement of its content. A park content is determined at each operation
    (usually implying a tidy up on the way), so beware of the asynchronous
    moves from park to park.

    name: a unique name for the park.
    slots: the slot positions.
    rotation: the optional rotation to apply to parked objects.
    zone: a zone to test if an object is in the park.
    tag: an optional restriction on the park content.
    description: an optional restriction on the park content.
    locked: should the park content be locked?
]]--
function parkModule.createPark(name, slots, rotation, zone, tag, description, locked)
    assert(#slots > 0, "No slot provided for new park.")
    assert(zone, "No park zone provided.")

    helperModule.setSharedTable(name, {})

    -- Check all slots in the zone.

    return {
        name = name,
        slots = slots,
        rotation = rotation,
        zone = zone,
        tag = tag,
        description = description,
        locked = locked
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
function parkModule.transfert(n, fromPark, toPark)
    assert(n >= 0, "Negative count.")
    assert(fromPark, "No source park.")
    assert(toPark, "No destination park.")
    assert(fromPark ~= toPark, "Source and destination parks are the same.")

    local holders = {}
    for i, object in ipairs(parkModule.getObjects(fromPark)) do
        if i <= n then
            holders[i] = {object = object}
        else
            break
        end
    end

    return parkModule.putHolders(holders, toPark)
end

--[[
    Put an external object in a park, provided it remains a free slot.
    object: the object to put in the park.
    toParkName: the name of the destination park.
]]--
function parkModule.putObject(object, toPark)
    assert(object, "No object provided.")
    return parkModule.putObjects({object}, toPark) > 0
end

--[[
]]--
function parkModule.putObjects(objects, toPark)
    assert(objects, "No objects provided.")
    local holders = {}
    for _, object in ipairs(objects) do
        holders[#holders + 1] = {object = object}
    end
    return parkModule.putHolders(holders, toPark)
end

--[[
]]--
function parkModule.putObjectFromBag(objectBag, toPark)
    assert(objectBag, "No object bag provided.")
    return parkModule.putHolders({{bag = objectBag}}, toPark) > 0
end

function parkModule.putHolders(holders, toPark)
    assert(holders, "No holders provided.")
    assert(toPark, "No destination park.")

    --[[
        Park objects usually come from other object (one of them at least). As
        such, it shall not be assigned (it is treated as a pure right value).
        Copies must be made when needed (even for temporarily storing it).
    ]]--

    local now = Time.time

    local objectsInTransit = helperModule.getSharedTable(toPark.name)

    local newObjectsInTransit = {}
    for object, transit in pairs(objectsInTransit) do
        if now - transit < 3.0 then
            newObjectsInTransit[object] = transit
        end
    end

    parkModule.instantTidyUp(toPark, newObjectsInTransit)

    local emptySlots = parkModule.findEmptySlots(toPark)

    -- Count *after* newObjectsInTransit (and it's a sparse table).
    local skipCount = 0
    for _, _ in pairs(newObjectsInTransit) do
        skipCount = skipCount + 1
    end
    local count = math.max(0, math.min(#emptySlots - skipCount, #holders))

    for i = 1, count do
        local holder = holders[i]
        if holder.object then
            parkModule.moveObjectToPark(holder.object, emptySlots[i + skipCount], toPark)
            newObjectsInTransit[holder.object] = now
        elseif holder.bag then
            parkModule.takeObjectToPark(holder.bag, emptySlots[i + skipCount], toPark)
            -- Can't really register anything for a transit and doing is async
            -- would be both too late and no safe.
        end
    end

    helperModule.setSharedTable(toPark.name, newObjectsInTransit)

    return count
end

--[[
]]--
function parkModule.getObjects(park)
    local objects = {}
    for _, object in ipairs(park.zone.getObjects()) do
        if object.resting then
            local isOneOfThem =
                (not park.tag or object.hasTag(park.tag)) and
                (not park.description or park.description == object.getDescription())
            if isOneOfThem then
                objects[#objects + 1] = object
            end
        end
    end
    return objects
end

function parkModule.instantTidyUp(park, newObjectsInTransit)

    local freeSlots = {}
    local freeSlotCount = 0
    for _, slot in ipairs(park.slots) do
        freeSlots[slot:copy()] = {}
        freeSlotCount = freeSlotCount + 1
    end

    local freeObjects = {}
    local freeObjectCount = 0
    for _, object in ipairs(parkModule.getObjects(park)) do
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
                nearestObject.locked = park.locked
            end
        end
    end

    --assert(#freeObjects == 0, "Too many objects.")
end

function parkModule.moveObjectToPark(object, slot, park)
    object.locked = park.locked
    local offset = Vector(0, 0, 0)
    if not object.locked then
        -- Nice drop are only for unlocked objects.
        offset = Vector(0, 1, 0)
    end
    object.setPositionSmooth(slot + offset, false, false)
    if park.rotation then
        object.setRotation(park.rotation:copy())
    end
end

function parkModule.takeObjectToPark(bag, slot, park)
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

function parkModule.findEmptySlots(park)
    local freeSlots = parkModule.deep_copy(park.slots)

    for _, object in ipairs(parkModule.getObjects(park)) do
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

function parkModule.shallow_copy(c)
    local copy = {}
    for i, e in ipairs(c) do
        copy[i] = e
    end
    return copy
end

function parkModule.deep_copy(c)
    local copy = {}
    for i, e in ipairs(c) do
        copy[i] = e:copy()
    end
    return copy
end

function parkModule.findBoundingZone(rotationAroundY, margins, points)
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

    local zone = spawnObject({
        type= 'ScriptingTrigger',
        position = barycenter,
        rotation = Vector(0, rotationAroundY, 0),
        scale = {
            math.max(1, sx + margins.x),
            math.max(1, sy + margins.y),
            math.max(1, sz + margins.z)}
    })

    return zone
end

return parkModule