local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")
local AcquireCard = require("utils.AcquireCard")

local Resource = Module.lazyRequire("Resource")
local Playboard = Module.lazyRequire("Playboard")

local TleilaxuResearch = {
    --[[
        Research path for each player in a discrete 2D space (we use the usual X-Z
        coordinates from the Vector class for simpliciy). It abstracts us away from
        the board layout.
    ]]
    researchCellBenefits = {
        [Vector(1, 0, 0)] = { specimen = true },
        [Vector(2, 0, 1)] = { specimen = true },
        [Vector(2, 0, -1)] = { beetle = true },
        [Vector(3, 0, 2)] = { research = true },
        [Vector(3, 0, 0)] = { trashImperiumCard = true, specimen = true },
        [Vector(3, 0, -2)] = { bettle = true, specimen = true },
        [Vector(4, 0, 1)] = { beetle = true },
        [Vector(4, 0, -1)] = { specimen = true },
        [Vector(4, 0, -3)] = { research = true },
        [Vector(5, 0, 2)] = { research = true },
        [Vector(5, 0, 0)] = { specimen = true },
        [Vector(5, 0, -2)] = { solari = 1 },
        [Vector(6, 0, 1)] = { spice = 1 },
        [Vector(6, 0, -1)] = { beetle = true },
        [Vector(6, 0, -3)] = { influence = 1 },
        [Vector(7, 0, 2)] = { beetle = true },
        [Vector(7, 0, 0)] = { trashIntrigueTodrawImperiumAndIntrigueCards = true },
        [Vector(7, 0, -2)] = { trashImperiumCard = true, specimen = true },
        [Vector(8, 0, 1)] = { spice = 2 },
        [Vector(8, 0, -1)] = { beetle = true },
        [Vector(8, 0, -3)] = { solariToBeetle = true }
    },
    tleilaxLevelBenefits = {
        {},
        {},
        { intrigue = true },
        {},
        { victoryToken = true, spiceBonus = true },
        {},
        { intrigue = true },
        { victoryToken = true }
    },
    tanksParks = {}
}

---
function TleilaxuResearch.onLoad(state)
    Helper.append(TleilaxuResearch, Helper.resolveGUIDs(true, {
        board = "d5c2db",
        TanksZone = "f5de09",
        tleilaxSpiceBonusToken = "46cd6b",
        tleilaxuLevelZones = {
            "b3137b",
            "a4181a",
            "2a16a4",
            "cef27c",
            "ed5509",
            "2bfdb0",
            "33c0fd",
            "cab3eb"
        }
    }))

    TleilaxuResearch.spiceBonus = Resource.new(TleilaxuResearch.tleilaxSpiceBonusToken, nil, "spice", 2, state)
end

---
function TleilaxuResearch.setUp()
    TleilaxuResearch.researchTokenOrigin = TleilaxuResearch.getAveragePosition("researchTokenInitalPosition")
    TleilaxuResearch.generateReseachButtons()

    TleilaxuResearch.tleilaxTokenOrigin = TleilaxuResearch.getAveragePosition("tleilaxTokenInitalPosition")
    TleilaxuResearch.generateTleilaxButtons()

    for _, color in ipairs(Playboard.getPlayboardColors()) do
        TleilaxuResearch.tanksParks[color] = TleilaxuResearch.createTanksPark(color)
    end
    TleilaxuResearch.createTanksButton()
end

---
function TleilaxuResearch.tearDown()
    TleilaxuResearch.TanksZone.destruct()
    TleilaxuResearch.board.destruct()
    TleilaxuResearch.tleilaxSpiceBonusToken.destruct()
    for _, zone in ipairs(TleilaxuResearch.tleilaxuLevelZones) do
        zone.destruct()
    end
end

---
function TleilaxuResearch.getSpecimenCount(color)
    return #Park.getObjects(TleilaxuResearch.tanksParks[color])
end

---
function TleilaxuResearch.researchSpaceToWorldPosition(positionInResearchSpace)
    local offset = Vector(
        positionInResearchSpace.x * 1.225 - 0.07,
        0.27,
        positionInResearchSpace.z * 0.7)
    local positionInWorldSpace = TleilaxuResearch.researchTokenOrigin + offset
    return positionInWorldSpace
end

---
function TleilaxuResearch.worlPositionToResearchSpace(positionInWorldSpace)
    local offset = positionInWorldSpace - TleilaxuResearch.researchTokenOrigin
    local positionInResearchSpace = Vector(
        math.floor((offset.x + 0.07) / 1.225 + 0.5),
        0,
        math.floor((offset.z) / 0.7))
        return positionInResearchSpace
end

---
function TleilaxuResearch.getAveragePosition(positionField)
    local p = Vector(0, 0, 0)
    local count = 0
    for _, color in pairs(Playboard.getPlayboardColors()) do
        p = p + Playboard.getContent(color)[positionField]
        count = count + 1
    end
    return p * (1 / count)
end

---
function TleilaxuResearch.generateReseachButtons()
    for cellPosition, _ in pairs(TleilaxuResearch.researchCellBenefits) do
        local p = TleilaxuResearch.researchSpaceToWorldPosition(cellPosition)
        local cellZone = spawnObject({
            type = 'ScriptingTrigger',
            position = p,
            scale = Vector(1.2, 1, 1.35)
        })
        Helper.markAsTransient(cellZone)
        Helper.createAnchoredAreaButton(cellZone, 0.6, 0.1, "Progress on the research track", function (_, color, _)
            local token = Playboard.getContent(color).researchToken
            local tokenCellPosition = TleilaxuResearch.worlPositionToResearchSpace(token.getPosition())
            local jump = cellPosition - tokenCellPosition
            if jump.x == 1 and math.abs(jump.z) <= 1 then
                TleilaxuResearch.advanceResearch(color, jump)
            else
                log("One cell at a time!")
            end
        end)
    end
end

---
function TleilaxuResearch.advanceResearch(color, jump)
    local leader = Playboard.getLeader(color)
    local researchToken = Playboard.getContent(color).researchToken
    local cellPosition = TleilaxuResearch.worlPositionToResearchSpace(researchToken.getPosition())
    local newCellPosition = cellPosition + jump

    local p = TleilaxuResearch.researchSpaceToWorldPosition(newCellPosition)
    researchToken.setPositionSmooth(p + Vector(0, 1, 0.25))

    local researchCellBenefits = TleilaxuResearch.researchCellBenefits[newCellPosition]
    assert(researchCellBenefits, "No cell benefits at cell " .. tostring(newCellPosition))

    for _, resource in ipairs({"spice", "solari"}) do
        if researchCellBenefits[resource] then
            leader.resource(color, resource, researchCellBenefits[resource])
        end
    end

    if researchCellBenefits.specimen then
        leader.troop(color, "suppy", "tanks", 1)
    end

    if researchCellBenefits.beetle then
        leader.beetle(color, 1)
    end

    if researchCellBenefits.research then
        Wait.time(function ()
            local nextCellPosition = newCellPosition.z + Vector(0, 0, Helper.signum(newCellPosition.z))
            leader.research(color, nextCellPosition)
        end, 1)
    end

    if researchCellBenefits.solariToBeetle then
        Player[color].showConfirmDialog(i18n("confirmSolarisToBeetles"), function()
            if leader.resource(color, "solari", -7) then
                local tleilaxToken = Playboard.getContent(color).tleilaxToken
                Helper.repeatMovingAction(tleilaxToken, function() TleilaxuResearch.advanceTleilax(color) end , 2)
            end
        end)
    end
end

---
function TleilaxuResearch.hasReachedOneHelix(color)
    local researchToken = Playboard.getContent(color).researchToken
    local cellPosition = TleilaxuResearch.worlPositionToResearchSpace(researchToken.getPosition())
    return cellPosition.x >= 4
end

---
function TleilaxuResearch.hasReachedTwoHelices(color)
    local researchToken = Playboard.getContent(color).researchToken
    local cellPosition = TleilaxuResearch.worlPositionToResearchSpace(researchToken.getPosition())
    return cellPosition.x == 8
end

---
function TleilaxuResearch.tleilaxSpaceToWorldPosition(positionInTleilaxSpace)
    return TleilaxuResearch.tleilaxuLevelZones[positionInTleilaxSpace].getPosition()
end

---
function TleilaxuResearch.worlPositionToTleilaxSpace(positionInWorldSpace)
    for level, zone in ipairs(TleilaxuResearch.tleilaxuLevelZones) do
        if Vector.distance(positionInWorldSpace, zone.getPosition()) < 0.75 then
            return level
        end
    end
    error("Not a position in Tleilax space: " .. tostring(positionInWorldSpace))
end

---
function TleilaxuResearch.generateTleilaxButtons()
    for level, _ in pairs(TleilaxuResearch.tleilaxLevelBenefits) do
        local levelZone = TleilaxuResearch.tleilaxuLevelZones[level]
        Helper.createAnchoredAreaButton(levelZone, 0.6, 0.1, "Progress on the Tleilax track", function (_, color, _)
            local token = Playboard.getContent(color).tleilaxToken
            local tokenLevel = TleilaxuResearch.worlPositionToTleilaxSpace(token.getPosition())
            local jump = level - tokenLevel
            if jump == 1 then
                TleilaxuResearch.advanceTleilax(color)
            else
                log("One cell at a time!")
            end
        end)
    end
end

---
function TleilaxuResearch.advanceTleilax(color)
    local leader = Playboard.getLeader(color)
    local tleilaxToken = Playboard.getContent(color).tleilaxToken
    local level = TleilaxuResearch.worlPositionToTleilaxSpace(tleilaxToken.getPosition())
    local newLevel = level + 1

    local p = TleilaxuResearch.tleilaxSpaceToWorldPosition(newLevel)
    tleilaxToken.setPositionSmooth(p + Vector(0, 1, 0.25))

    local researchLevelBenefits = TleilaxuResearch.tleilaxLevelBenefits[newLevel] or {}
    assert(researchLevelBenefits, "No level benefits at level " .. tostring(newLevel))

    if researchLevelBenefits.intrigue then
        leader.drawIntrigues(color, 1)
    end

    if researchLevelBenefits.victoryToken then
        leader.gainVictoryPoint(color, "tleilax")
    end

    if researchLevelBenefits.spiceBonus then
        local amount = TleilaxuResearch.spiceBonus:get()
        leader.resource(color, "spice", amount)
        TleilaxuResearch.spiceBonus:set(0)
    end
end

---
function TleilaxuResearch.createTanksButton()
    Helper.createAnchoredAreaButton(TleilaxuResearch.TanksZone, 0.6, 0.1, "Specimen: ±1", function (_, color, altClick)
        local leader = Playboard.getLeader(color)
        if altClick then
            leader.troops(color, "tanks", "supply", 1)
        else
            leader.troops(color, "supply", "tanks", 1)
        end
    end)
end

---
function TleilaxuResearch.createTanksPark(color)
    local offsets = {
        Red = Vector(-0.65, 0, 0.45),
        Blue = Vector(-0.65, 0, -0.45),
        Green = Vector(0.65, 0, 0.45),
        Yellow = Vector(0.65, 0, -0.45)
    }

    local origin = getObjectFromGUID("f5de09").getPosition() + offsets[color]
    origin:setAt('y', 0.86) -- ground level
    local slots = {}
    for k = 1, 2 do
        for j = 1, 2 do
            for i = 1, 3 do
                local x = (i - 2) * 0.4
                local y = (k - 1) * 0.4
                local z = (1.5 - j) * 0.4
                local slot = Vector(x, y, z) + origin
                table.insert(slots, slot)
            end
        end
    end

    local zone = Park.createBoundingZone(0, Vector(0.25, 0.25, 0.25), slots)

    return Park.createPark(
        color .. "Tanks",
        slots,
        Vector(0, 0, 0),
        zone,
        { "Troop", color },
        nil,
        false,
        true)
end

---
function TleilaxuResearch.getTankPark(color)
    return TleilaxuResearch.tanksParks[color]
end

return TleilaxuResearch
