local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")
local I18N = require("utils.I18N")

local Resource = Module.lazyRequire("Resource")
local PlayBoard = Module.lazyRequire("PlayBoard")

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

    local value = state.MainBoard and state.TleilaxuResearch.tleilaxSpiceBonusToken or 2
    TleilaxuResearch.spiceBonus = Resource.new(TleilaxuResearch.tleilaxSpiceBonusToken, nil, "spice", value)

    if state.settings and state.settings.immortality then
        TleilaxuResearch._staticSetUp()
    end
end

---
function TleilaxuResearch.onSave(state)
    state.TleilaxuResearch = {
        spiceBonus = TleilaxuResearch.spiceBonus:get(),
    }
end

---
function TleilaxuResearch.setUp(settings)
    if settings.immortality then
        TleilaxuResearch._staticSetUp()
    else
        TleilaxuResearch._tearDown()
    end
end

---
function TleilaxuResearch._staticSetUp()
    TleilaxuResearch.researchTokenOrigin = TleilaxuResearch._getAveragePosition("researchTokenInitalPosition")
    TleilaxuResearch._generateResearchButtons()

    TleilaxuResearch.tleilaxTokenOrigin = TleilaxuResearch._getAveragePosition("tleilaxTokenInitalPosition")
    TleilaxuResearch._generateTleilaxButtons()

    for _, color in ipairs(PlayBoard.getPlayboardColors()) do
        TleilaxuResearch.tanksParks[color] = TleilaxuResearch._createTanksPark(color)
    end
    TleilaxuResearch._createTanksButton()
end

---
function TleilaxuResearch._tearDown()
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
function TleilaxuResearch._researchSpaceToWorldPosition(positionInResearchSpace)
    local offset = Vector(
        positionInResearchSpace.x * 1.225 - 0.07,
        0.27,
        positionInResearchSpace.z * 0.7)
    local positionInWorldSpace = TleilaxuResearch.researchTokenOrigin + offset
    return positionInWorldSpace
end

---
function TleilaxuResearch._worlPositionToResearchSpace(positionInWorldSpace)
    local offset = positionInWorldSpace - TleilaxuResearch.researchTokenOrigin
    local x = math.floor((offset.x + 0.07) / 1.225 + 0.5)
    local z = x == 0 and 0 or math.floor((offset.z) / 0.7)
    local positionInResearchSpace = Vector(x, 0, z)
    return positionInResearchSpace
end

---
function TleilaxuResearch._getAveragePosition(positionField)
    local p = Vector(0, 0, 0)
    local count = 0
    for _, color in pairs(PlayBoard.getPlayboardColors()) do
        p = p + PlayBoard.getContent(color)[positionField]
        count = count + 1
    end
    return p * (1 / count)
end

---
function TleilaxuResearch._generateResearchButtons()
    for cellPosition, _ in pairs(TleilaxuResearch.researchCellBenefits) do
        local p = TleilaxuResearch._researchSpaceToWorldPosition(cellPosition)
        local cellZone = spawnObject({
            type = 'ScriptingTrigger',
            position = p,
            scale = Vector(1.2, 1, 1.35)
        })
        Helper.markAsTransient(cellZone)
        Helper.createAnchoredAreaButton(cellZone, 0.6, 0.1, "Progress on the research track", function (_, color, _)
            local token = PlayBoard.getContent(color).researchToken
            local tokenCellPosition = TleilaxuResearch._worlPositionToResearchSpace(token.getPosition())
            local jump = cellPosition - tokenCellPosition
            if jump.x == 1 and math.abs(jump.z) <= 1 then
                TleilaxuResearch._advanceResearch(color, jump, true)
            else
                Player[color].showConfirmDialog("Forbidden move. Do you confirm it neverless?", function()
                    TleilaxuResearch._advanceResearch(color, jump, false)
                end)
            end
        end)
    end
end

---
function TleilaxuResearch._findResearchCellBenefits(cellPosition)
    for existingCellPosition, cell in pairs(TleilaxuResearch.researchCellBenefits) do
        if Vector.distance(existingCellPosition, cellPosition) < 0.1 then
            return cell
        end
    end
    return nil
end

---
function TleilaxuResearch.advanceResearch(color, jump)
    TleilaxuResearch._advanceResearch(color, jump, true)
end

---
function TleilaxuResearch._advanceResearch(color, jump, withBenefits)
    local leader = PlayBoard.getLeader(color)
    local researchToken = PlayBoard.getContent(color).researchToken
    local cellPosition = TleilaxuResearch._worlPositionToResearchSpace(researchToken.getPosition())
    local newCellPosition = cellPosition + jump

    local p = TleilaxuResearch._researchSpaceToWorldPosition(newCellPosition)
    researchToken.setPositionSmooth(p + Vector(0, 1, 0.25))

    if withBenefits then
        Helper.onceMotionless(researchToken).doAfter(function ()
            local researchCellBenefits = TleilaxuResearch._findResearchCellBenefits(newCellPosition)
            assert(researchCellBenefits, "No cell benefits at cell " .. tostring(newCellPosition))

            for _, resource in ipairs({"spice", "solari"}) do
                if researchCellBenefits[resource] then
                    leader.resource(color, resource, researchCellBenefits[resource])
                end
            end

            if researchCellBenefits.specimen then
                leader.troops(color, "supply", "tanks", 1)
            end

            if researchCellBenefits.beetle then
                leader.beetle(color, 1)
            end

            if researchCellBenefits.research then
                leader.research(color, Vector(1, 0, -Helper.signum(newCellPosition.z)))
            end

            if researchCellBenefits.solariToBeetle then
                Player[color].showConfirmDialog(I18N("confirmSolarisToBeetles"), function()
                    if leader.resource(color, "solari", -7) then
                        TleilaxuResearch.advanceTleilax(color, 1)
                    end
                end)
            end
        end)
    end
end

---
function TleilaxuResearch.hasReachedOneHelix(color)
    local researchToken = PlayBoard.getContent(color).researchToken
    local cellPosition = TleilaxuResearch._worlPositionToResearchSpace(researchToken.getPosition())
    return cellPosition.x >= 4
end

---
function TleilaxuResearch.hasReachedTwoHelices(color)
    local researchToken = PlayBoard.getContent(color).researchToken
    local cellPosition = TleilaxuResearch._worlPositionToResearchSpace(researchToken.getPosition())
    return cellPosition.x == 8
end

---
function TleilaxuResearch._tleilaxSpaceToWorldPosition(positionInTleilaxSpace)
    return TleilaxuResearch.tleilaxuLevelZones[positionInTleilaxSpace].getPosition()
end

---
function TleilaxuResearch._worlPositionToTleilaxSpace(positionInWorldSpace)
    local nearestLevel = nil
    local nearestDistance = 0
    for level, zone in ipairs(TleilaxuResearch.tleilaxuLevelZones) do
        local d = Vector.distance(positionInWorldSpace, zone.getPosition())
        if not nearestLevel or d < nearestDistance then
            nearestLevel = level
            nearestDistance = d
        end
    end
    return nearestLevel
end

---
function TleilaxuResearch._generateTleilaxButtons()
    for level, _ in pairs(TleilaxuResearch.tleilaxLevelBenefits) do
        local levelZone = TleilaxuResearch.tleilaxuLevelZones[level]
        Helper.createAnchoredAreaButton(levelZone, 0.6, 0.1, "Progress on the Tleilax track", function (_, color, _)
            local token = PlayBoard.getContent(color).tleilaxToken
            local tokenLevel = TleilaxuResearch._worlPositionToTleilaxSpace(token.getPosition())
            local jump = level - tokenLevel
            if jump == 1 then
                TleilaxuResearch._advanceTleilax(color, jump, true)
            else
                Player[color].showConfirmDialog("Forbidden move. Do you confirm it neverless?", function()
                    TleilaxuResearch._advanceTleilax(color, jump, false)
                end)
            end
        end)
    end
end

---
function TleilaxuResearch.advanceTleilax(color, jump)
    TleilaxuResearch._advanceTleilax(color, jump, true)
end

---
function TleilaxuResearch._advanceTleilax(color, jump, withBenefits)
    local leader = PlayBoard.getLeader(color)
    local tleilaxToken = PlayBoard.getContent(color).tleilaxToken
    local level = TleilaxuResearch._worlPositionToTleilaxSpace(tleilaxToken.getPosition())
    local newLevel = level + jump

    local p = TleilaxuResearch._tleilaxSpaceToWorldPosition(newLevel)
    tleilaxToken.setPositionSmooth(p + Vector(0, 1, 0.25))

    if withBenefits then
        Helper.onceMotionless(tleilaxToken).doAfter(function ()
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
        end)
    end
end

---
function TleilaxuResearch._createTanksButton()
    Helper.createAnchoredAreaButton(TleilaxuResearch.TanksZone, 0.6, 0.1, "Specimen: ±1", function (_, color, altClick)
        local leader = PlayBoard.getLeader(color)
        if altClick then
            leader.troops(color, "tanks", "supply", 1)
        else
            leader.troops(color, "supply", "tanks", 1)
        end
    end)
end

---
function TleilaxuResearch._createTanksPark(color)
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
