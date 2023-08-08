local Core = require("utils.Core")
local Park = require("utils.Park")
local Helper = require("utils.Helper")

local Playboard = Helper.lazyRequire("Playboard")
local Action = Helper.lazyRequire("Action")

local Combat = {
    origins = {
        Green = Vector(8.15, 0.85, -7.65),
        Yellow = Vector(8.15, 0.85, -10.35),
        Blue = Vector(1.55, 0.85, -10.35),
        Red = Vector(1.55, 0.85, -7.65),
    }
}

function Combat.onLoad(_)
    Helper.append(Combat, Core.resolveGUIDs(true, {
        combatDetectionZone = "722609",
        combatCenterZone = "6d632e",
        combatTokenZone = "1d4424",
    }))
end

---
function Combat.setUp(ix, epic)
    Helper.allModules.Deck.generateConflictDeck(getObjectFromGUID("07e239"), getObjectFromGUID("43f00f"), ix, epic)

    Combat.garrisonParks = {}
    for color, _ in pairs(Playboard.getPlayboardByColor()) do
        Combat.garrisonParks[color] = Combat.createGarrisonPark(color)
    end

    if ix then
        Combat.dreadnoughtParks = {}
        for color, _ in pairs(Playboard.getPlayboardByColor()) do
            Combat.dreadnoughtParks[color] = Combat.createDreadnoughtPark(color)
        end
    end
end

---
function Combat.createGarrisonPark(color)
    local slots = {}
    for j = 3, 1, -1 do
        for i = 1, 4 do
            local x = (i - 2.5) * 0.45
            local z = (j - 2) * 0.45
            local slot = Combat.origins[color] + Vector(x, 0, z)
            slots[#slots + 1] = slot
        end
    end

    local zone = Park.createBoundingZone(0, Vector(0.35, 0.35, 0.35), slots)

    local park = Park.createPark(
        color .. "Garrison",
        slots,
        Vector(0, 0, 0),
        zone,
        { "Troop", color },
        nil,
        false)

    local p = zone.getPosition()
    -- FIXME Hardcoded height, use an existing parent anchor.
    p:setAt('y', 0.65)
    Helper.createTransientAnchor("Garrison anchor", p).doAfter(function (anchor)
        park.anchor = anchor
        anchor.locked = true
        anchor.interactable = true
        Combat.createButton(color, park)
    end)

    return park
end

---
function Combat.createDreadnoughtPark(color)
    local origin = Combat.origins[color]
    local center = Helper.getCenter(Helper.getValues(Combat.origins))
    local dir = Helper.signum((origin - center).x)
    local slots = {
        origin + Vector(1.3 * dir, 0, 0.9),
        origin + Vector(1.3 * dir, 0, -0.9),
    }

    local zone = Park.createBoundingZone(0, Vector(0.25, 3, 0.25), slots)

    local park = Park.createPark(
        color .. "DreadnoughtGarrison",
        slots,
        Vector(0, 0, 0),
        zone,
        { "Dreadnought", color },
        nil,
        false)

    return park
end

---
function Combat.createButton(color, park)
    local position = park.anchor.getPosition()
    local areaColor = Color.fromString(color)
    areaColor:setAt('a', 0.3)
    Helper.createAbsoluteButtonWithRoundness(park.anchor, 7, false, {
        click_function = Helper.wrapCallback({ color, "Garrison" }, function (_, playerColor, altClick)
            if playerColor == color then
                if altClick then
                    Action.troops(color, "garrison", "supply", 1)
                else
                    Action.troops(color, "supply", "garrison", 1)
                end
            end
        end),
        position = Vector(position.x, 0.7, position.z),
        width = 1200,
        height = 1200,
        color = areaColor,
        tooltip = "Troop: ±1"
    })
end

---
function Combat.getGarrisonPark(color)
    return Combat.garrisonParks[color]
end

---
function Combat.getDreadnoughtPark(color)
    return Combat.dreadnoughtParks[color]
end

return Combat
