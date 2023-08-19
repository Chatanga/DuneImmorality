local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")

local Playboard = Module.lazyRequire("Playboard")
local Action = Module.lazyRequire("Action")
local Deck = Module.lazyRequire("Deck")
local Utils = Module.lazyRequire("Utils")
local TurnControl = Module.lazyRequire("TurnControl")
local MainBoard = Module.lazyRequire("MainBoard")

local Combat = {
    origins = {
        Green = Vector(8.15, 0.85, -7.65),
        Yellow = Vector(8.15, 0.85, -10.35),
        Blue = Vector(1.55, 0.85, -10.35),
        Red = Vector(1.55, 0.85, -7.65),
    },
    victoryPointTokenPositions = {},
    dreadnoughStrengths = {},
}

function Combat.onLoad(_)
    Helper.append(Combat, Helper.resolveGUIDs(true, {
        conflictDeckZone = "07e239",
        conflictDiscardZone = "43f00f",
        combatCenterZone = "6d632e",
        combatTokenZone = "1d4424",
        victoryPointTokenZone = "25b541",
        victoryPointTokenBag = "d9a457"
    }))

    local origin = Combat.combatTokenZone.getPosition()
    Combat.noCombatForcePositions = Vector(origin.x, 0.66, origin.z)
    Combat.combatForcePositions = {}
    for i = 0, 19 do
        Combat.combatForcePositions[i + 1] = Vector(
            origin.x - 0.4 + (i % 10) * 0.9,
            0.66,
            origin.z - 0.93 - math.floor(i / 10) * 1.03
        )
    end
end

---
function Combat.setUp(ix, epic)
    Deck.generateConflictDeck(Combat.conflictDeckZone, ix, epic)

    Combat.garrisonParks = {}
    for _, color in ipairs(Playboard.getPlayboardColors()) do
        Combat.garrisonParks[color] = Combat.createGarrisonPark(color)
    end

    if ix then
        Combat.dreadnoughtParks = {}
        for _, color in ipairs(Playboard.getPlayboardColors()) do
            Combat.dreadnoughtParks[color] = Combat.createDreadnoughtPark(color)
        end
    end

    Helper.registerEventListener("strengthValueChanged", function ()
        Combat.updateCombatForces(Combat.calculateCombatForces())
    end)

    Helper.registerEventListener("phaseStart", function (phase)
        if phase == "roundStart" then
            Combat.setUpConflict()
        elseif phase == "combatEnd" then
            local forces = Combat.calculateCombatForces()
            local turnSequence = Combat.calculateOutcomeTurnSequence(forces)
            TurnControl.setPhaseTurnSequence(turnSequence)
        elseif phase == "recall" then
            for _, object in ipairs(Combat.victoryPointTokenZone.getObjects()) do
                if Utils.isVictoryPointToken(object) then
                    -- TODO Send to trash instead.
                    object.destruct()
                end
            end
            -- TODO Recalling troops lost in combat.
        end
    end)
end

---
function Combat.setUpConflict()
    local card = Helper.moveCardFromZone(Combat.conflictDeckZone, Combat.conflictDiscardZone.getPosition(), nil, true, true)
    if card then
        local i = 0
        for _, object in pairs(Combat.victoryPointTokenBag.getObjects()) do
            if object.description == card.getDescription() then
                local origin = Combat.victoryPointTokenZone.getPosition()
                local position = origin + Vector(0.5 - (i % 2), 0.5 + math.floor(i / 2), 0)
                i = i + 1
                local victoryPointToken = Combat.victoryPointTokenBag.takeObject({
                    position = position,
                    rotation = Vector(0, 180, 0),
                    smooth = true,
                    guid = object.guid,
                })

                local controlableSpace = MainBoard.findControlableSpace(victoryPointToken)
                if controlableSpace then
                    local color = MainBoard.getControllingPlayer(controlableSpace)
                    if color then
                        local troop = Park.getAnyObject(Playboard.getSupplyPark(color))
                        if troop then
                            troop.setPositionSmooth(Combat.combatCenterZone.getPosition())
                        end
                    end
                end
            end
        end
    end
end

---
function Combat.onObjectEnterScriptingZone(zone, object)
    if zone == Combat.combatCenterZone and Utils.isUnit(object) then
        Combat.updateCombatForces(Combat.calculateCombatForces())
    end
end

---
function Combat.onObjectLeaveScriptingZone(zone, object)
    if zone == Combat.combatCenterZone and Utils.isUnit(object) then
        Combat.updateCombatForces(Combat.calculateCombatForces())
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
            table.insert(slots, slot)
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
        false,
        true)

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
        false,
        true)

    return park
end

---
function Combat.createButton(color, park)
    local position = park.anchor.getPosition()
    local areaColor = Color.fromString(color)
    areaColor:setAt('a', 0.3)
    Helper.createAbsoluteButtonWithRoundness(park.anchor, 7, false, {
        click_function = Helper.createGlobalCallback(function (_, playerColor, altClick)
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

---
function Combat.setDreadnoughtStrength(color, strength)
    Combat.dreadnoughStrengths[color] = strength
end

---
function Combat.isInCombat(color)
    for _, object in ipairs(Combat.combatCenterZone.getObjects()) do
        if Utils.isUnit(object, color) then
            return true
        end
    end
    return false
end

---
function Combat.calculateOutcomeTurnSequence(forces)
    local distinctForces = {}
    for i, color in ipairs(TurnControl.getPhaseTurnSequence()) do
        distinctForces[color] = forces[color] - i * 0.1
    end

    local combatEndTurnSequence = Helper.getKeys(forces)
    table.sort(combatEndTurnSequence, function(c1, c2)
        return distinctForces[c1] > distinctForces[c2]
    end)

    -- No Nth winner in a N players game.
    if #combatEndTurnSequence == #Playboard.getPlayboardColors() then
        table.remove(combatEndTurnSequence, #combatEndTurnSequence)
    end

    return combatEndTurnSequence
end

---
function Combat.calculateCombatForces()
    local forces = {}

    -- TODO Better having a zone with filtering tags.
    for _, color in ipairs(Playboard.getPlayboardColors()) do
        local force = 0
        for _, object in ipairs(Combat.combatCenterZone.getObjects()) do
            if Utils.isUnit(object, color) then
                if Utils.isTroop(object, color) then
                    force = force + 2
                elseif Utils.isDreadnought(object, color) then
                    force = force + (Combat.dreadnoughStrengths[color] or 3)
                else
                    error("Unknown unit type: " .. object.getGUID())
                end
            end
        end

        if force > 0 then
            force = force + Playboard.getResource(color, "strength"):get()
        end

        forces[color] = force
    end

    return forces
end

---
function Combat.updateCombatForces(forces)
    local occupations = {}

    -- TODO Better having a zone with filtering tags.
    for _, color in ipairs(Playboard.getPlayboardColors()) do
        local force = forces[color]

        local minorForce = force > 0 and (force - 1) % 20 + 1 or 0
        local majorForce = force > 0 and math.floor((force - 1) / 20) or 0

        occupations[minorForce] = (occupations[minorForce] or 0) + 1
        local height = Vector(0, (occupations[minorForce] - 1) * 0.35, 0)

        local forceMarker = Playboard.getContent(color).forceMarker
        if force > 0 then
            forceMarker.setPositionSmooth(Combat.combatForcePositions[minorForce] + height, false, false)
            forceMarker.setRotationSmooth(Vector(0, 180 + 90 * math.floor(majorForce / 2), 180 * math.min(1, majorForce)))
        else
            forceMarker.setPositionSmooth(Combat.noCombatForcePositions + height, false, false)
            forceMarker.setRotationSmooth(Vector(0, 180, 0))
        end

        forces[color] = force
    end
end

return Combat
