local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")
local I18N = require("utils.I18N")
local Dialog = require("utils.Dialog")

local Resource = Module.lazyRequire("Resource")
local PlayBoard = Module.lazyRequire("PlayBoard")
local DynamicBonus = Module.lazyRequire("DynamicBonus")
local Board = Module.lazyRequire("Board")

---@alias CellBenefit {
--- spice: integer,
--- solari: integer,
--- specimen: boolean,
--- beetle: boolean,
--- research: boolean,
--- solariToBeetle: boolean }

---@alias LevelBenefit {
--- intrigue: boolean,
--- victoryToken: boolean,
--- spiceBonus: boolean }

---@class TleilaxuResearch
---@field researchCellBenefits table<Vector, CellBenefit>
---@field board Object
---@field tleilaxSpiceBonusToken Object
---@field tanksZone Zone
---@field tleilaxuLevelZones Zone[]
---@field oneHelixZone Zone
---@field twoHelicesZone Zone
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
        [Vector(3, 0, -2)] = { beetle = true, specimen = true },
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
    tanksParks = {},
    extraBonuses = {},
}

---@param state table
function TleilaxuResearch.onLoad(state)
    Helper.append(TleilaxuResearch, Helper.resolveGUIDs(false, {
        tanksZone = "f5de09",
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
        },
        oneHelixZone = "53e9ac",
        twoHelicesZone = "03e529"
    }))

    if state.settings and state.settings.immortality and state.TleilaxuResearch then
        local board = Board.getBoard("tleilaxBoard")
        assert(board)
        TleilaxuResearch.board = board
        local value = state.TleilaxuResearch.tleilaxSpiceBonusToken
        TleilaxuResearch.spiceBonus = Resource.new(TleilaxuResearch.tleilaxSpiceBonusToken, nil, "spice", value)
        TleilaxuResearch._transientSetUp()
    end
end

---@param state table
function TleilaxuResearch.onSave(state)
    if TleilaxuResearch.board and TleilaxuResearch.spiceBonus then
        state.TleilaxuResearch = {
            spiceBonus = TleilaxuResearch.spiceBonus:get(),
        }
    end
end

---@param settings Settings
function TleilaxuResearch.setUp(settings)
    if settings.immortality then
        TleilaxuResearch.board = Board.selectBoard("tleilaxBoard", settings.language)
        TleilaxuResearch.spiceBonus = Resource.new(TleilaxuResearch.tleilaxSpiceBonusToken, nil, "spice", 2)
        TleilaxuResearch._transientSetUp()
    else
        TleilaxuResearch._tearDown()
    end
end

function TleilaxuResearch._transientSetUp()

    TleilaxuResearch.researchTokenOrigin = TleilaxuResearch._getAveragePosition("researchTokenInitalPosition")
    TleilaxuResearch._generateResearchButtons()

    TleilaxuResearch.tleilaxTokenOrigin = TleilaxuResearch._getAveragePosition("tleilaxTokenInitalPosition")
    TleilaxuResearch._generateTleilaxButtons()

    for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
        if true then
            TleilaxuResearch.tanksParks[color] = TleilaxuResearch._createTanksPark(color)
        end
    end
    TleilaxuResearch._createTanksButton()
end

function TleilaxuResearch._tearDown()
    Board.destructBoard("tleilaxBoard")
    TleilaxuResearch.tanksZone.destruct()
    TleilaxuResearch.tleilaxSpiceBonusToken.destruct()
    for _, zone in ipairs(TleilaxuResearch.tleilaxuLevelZones) do
        zone.destruct()
    end
    TleilaxuResearch.oneHelixZone.destruct()
    TleilaxuResearch.twoHelicesZone.destruct()
end

---@param color PlayerColor
---@return integer
function TleilaxuResearch.getSpecimenCount(color)
    return #Park.getObjects(TleilaxuResearch.tanksParks[color])
end

---@param positionInResearchSpace Vector
---@return Vector
function TleilaxuResearch._researchSpaceToWorldPosition(positionInResearchSpace)
    local offset = Vector(
        positionInResearchSpace.x * 1.225 - 0.07,
        Board.onTleilaxBoard(-0.41),
        positionInResearchSpace.z * 0.7)
    local positionInWorldSpace = TleilaxuResearch.researchTokenOrigin + offset
    return positionInWorldSpace
end

---@param positionInWorldSpace Vector
---@return Vector
function TleilaxuResearch._worlPositionToResearchSpace(positionInWorldSpace)
    local offset = positionInWorldSpace - TleilaxuResearch.researchTokenOrigin
    local x = math.floor((offset.x + 0.07) / 1.225 + 0.5)
    local z = x == 0 and 0 or math.floor((offset.z) / 0.7)
    local positionInResearchSpace = Vector(x, 0, z)
    return positionInResearchSpace
end

---@param positionField string
---@return Vector
function TleilaxuResearch._getAveragePosition(positionField)
    local p = Vector(0, 0, 0)
    local count = 0
    for _, color in pairs(PlayBoard.getActivePlayBoardColors()) do
        if true then
            p = p + PlayBoard.getContent(color)[positionField]
            count = count + 1
        end
    end
    return p * (1 / count)
end

---@param color PlayerColor
---@return Vector
function TleilaxuResearch.getTokenCellPosition(color)
    local token = PlayBoard.getContent(color).researchToken
    local tokenCellPosition = TleilaxuResearch._worlPositionToResearchSpace(token.getPosition())
    return tokenCellPosition
end

--- When a zone is only needed to create a button.
---@param position Vector
---@param scale Vector
function TleilaxuResearch._createPseudoZone(position, scale)
    return {
        getPosition = function ()
            return position
        end,
        getScale = function ()
           return scale
        end
    }
end

function TleilaxuResearch._generateResearchButtons()
    for cellPosition, _ in pairs(TleilaxuResearch.researchCellBenefits) do
        local p = TleilaxuResearch._researchSpaceToWorldPosition(cellPosition)
        local pseudoCellZone = TleilaxuResearch._createPseudoZone(p, Vector(1.2, 1, 1.35))
        Helper.createAnchoredAreaButton(pseudoCellZone, Board.onTleilaxBoard(-0.08), 0.1, I18N("progressOnResearchTrack"), PlayBoard.withLeader(function (leader, color, _)
            if not PlayBoard.isRival(color) then
                local token = PlayBoard.getContent(color).researchToken
                local tokenCellPosition = TleilaxuResearch._worlPositionToResearchSpace(token.getPosition())
                local jump = cellPosition - tokenCellPosition

                if jump.x == 1 and math.abs(jump.z) <= 1 then
                    leader.research(color, jump)
                else
                    Dialog.showConfirmDialog(color, I18N("forbiddenMove"), function ()
                        leader.research(color, jump)
                    end)
                end
            else
                Dialog.broadcastToColor(I18N('noTouch'), color, "Purple")
            end
        end))
    end

    Helper.createAnchoredAreaButton(TleilaxuResearch.twoHelicesZone, Board.onTleilaxBoard(-0.08), 0.1, I18N("progressAfterResearchTrack"), PlayBoard.withLeader(function (leader, color, _)
        if not PlayBoard.isRival(color) and TleilaxuResearch.hasReachedTwoHelices(color) then
            local specialJump = Vector(1, 0, 0)
            leader.research(color, specialJump)
        else
            Dialog.broadcastToColor(I18N('noTouch'), color, "Purple")
        end
    end))
end

---@param cellPosition Vector
---@return CellBenefit?
function TleilaxuResearch._findResearchCellBenefits(cellPosition)
    for existingCellPosition, cell in pairs(TleilaxuResearch.researchCellBenefits) do
        if Vector.distance(existingCellPosition, cellPosition) < 0.1 then
            return cell
        end
    end
    return nil
end

---@param color PlayerColor
---@param jump? Vector
---@return Continuation
function TleilaxuResearch.advanceResearch(color, jump)
    local continuation = Helper.createContinuation("TleilaxuResearch.advanceResearch")
    local finalJump = jump
    if not finalJump and TleilaxuResearch.hasReachedTwoHelices(color) then
        finalJump = Vector(1, 0, 0)
    end
    if finalJump then
        local legit = finalJump.x == 1 and math.abs(finalJump.z) <= 1
        TleilaxuResearch._advanceResearch(color, finalJump, legit)
        continuation.run(finalJump)
    else
        continuation.cancel()
    end
    return continuation
end

---@param color PlayerColor
---@param jump Vector
---@param withBenefits boolean
function TleilaxuResearch._advanceResearch(color, jump, withBenefits)
    local leader = PlayBoard.getLeader(color)
    local researchToken = PlayBoard.getContent(color).researchToken

    if TleilaxuResearch.hasReachedTwoHelices(color) and jump.x > 0 then
        if withBenefits then
            PlayBoard.getLeader(color).drawImperiumCards(color, 1)
            Helper.emitEvent("researchProgress", color)
        end
    else
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
                        local amount = researchCellBenefits[resource]
                        ---@cast amount integer
                        leader.resources(color, resource, amount)
                    end
                end

                if researchCellBenefits.specimen then
                    leader.troops(color, "supply", "tanks", 1)
                end

                if researchCellBenefits.beetle then
                    leader.beetle(color, 1)
                end

                if researchCellBenefits.research then
                    Helper.onceTimeElapsed(0.5).doAfter(function ()
                        leader.research(color, Vector(1, 0, -Helper.signum(newCellPosition.z)))
                    end)
                end

                if researchCellBenefits.solariToBeetle then
                    if PlayBoard.getResource(color, "solari"):get() >= 7 then
                        Dialog.showConfirmDialog(color, I18N("confirmSolarisToBeetles"), function ()
                            leader.resources(color, "solari", -7)
                            leader.beetle(color, 2)
                        end)
                    end
                end
            end)

            local bonuses = TleilaxuResearch.extraBonuses["oneHelix"]
            if bonuses then
                if cellPosition.x < 4 and newCellPosition.x >= 4 then
                    DynamicBonus.collectExtraBonuses(color, leader, bonuses)
                end
            end

            Helper.emitEvent("researchProgress", color)
        end
    end
end

---@param color PlayerColor
---@return boolean
function TleilaxuResearch.hasReachedOneHelix(color)
    return TleilaxuResearch.getBestResearch(color) >= 4
end

---@param color PlayerColor
---@return boolean
function TleilaxuResearch.hasReachedTwoHelices(color)
    return TleilaxuResearch.getBestResearch(color) == 8
end

---@param color PlayerColor
---@return integer
function TleilaxuResearch.getBestResearch(color)
    local bestResearch = 0
    bestResearch = TleilaxuResearch.getTokenCellPosition(color).x
    return bestResearch
end

---@param positionInTleilaxSpace integer
---@return Vector
function TleilaxuResearch._tleilaxSpaceToWorldPosition(positionInTleilaxSpace)
    local tleilaxuLevelZone = TleilaxuResearch.tleilaxuLevelZones[positionInTleilaxSpace]
    assert(tleilaxuLevelZone, "No zone at coordinates " .. tostring(positionInTleilaxSpace))
    return tleilaxuLevelZone.getPosition()
end

---@param positionInWorldSpace Vector
---@return integer
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

function TleilaxuResearch._generateTleilaxButtons()
    for level, _ in pairs(TleilaxuResearch.tleilaxLevelBenefits) do
        local levelZone = TleilaxuResearch.tleilaxuLevelZones[level]
        Helper.createAnchoredAreaButton(levelZone, Board.onTleilaxBoard(-0.08), 0.1, I18N("progressOnTleilaxTrack"), PlayBoard.withLeader(function (leader, color, _)
            local token = PlayBoard.getContent(color).tleilaxToken
            local tokenLevel = TleilaxuResearch._worlPositionToTleilaxSpace(token.getPosition())
            -- Human players are required to advance step by step.
            local jump = math.min(1, level - tokenLevel)

            if jump < 0 then
                Dialog.showConfirmDialog(color, I18N("forbiddenMove"), function ()
                    TleilaxuResearch._advanceTleilax(color, jump, false).doAfter(function ()
                        leader.beetle(color, jump)
                    end)
                end)
            else
                leader.beetle(color, jump)
            end
        end))
    end
end

---@param color PlayerColor
---@param jump integer
---@return Continuation
function TleilaxuResearch.advanceTleilax(color, jump)
    if jump >= 1 then
        return Helper.repeatChainedAction(jump, function ()
            return TleilaxuResearch._advanceTleilax(color, 1, true)
        end)
    else
        return TleilaxuResearch._advanceTleilax(color, jump, false)
    end
end

---@param color PlayerColor
---@param jump integer
---@param withBenefits boolean
---@return Continuation
function TleilaxuResearch._advanceTleilax(color, jump, withBenefits)
    local continuation = Helper.createContinuation("TleilaxuResearch._advanceTleilax")

    local leader = PlayBoard.getLeader(color)
    local tleilaxToken = PlayBoard.getContent(color).tleilaxToken
    local level = TleilaxuResearch._worlPositionToTleilaxSpace(tleilaxToken.getPosition())


    local finalJump = jump
    finalJump = math.min(8, level + finalJump) - level
    finalJump = math.max(0, level + finalJump) - level

    if finalJump ~= 0 then
        local newLevel = level + finalJump

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
                    leader.gainVictoryPoint(color, "tleilax", 1)
                end

                if researchLevelBenefits.spiceBonus then
                    local amount = TleilaxuResearch.spiceBonus:get()
                    leader.resources(color, "spice", amount)
                    TleilaxuResearch.spiceBonus:set(0)
                end

                for i = level + 1, newLevel do
                    local bonuses = TleilaxuResearch.extraBonuses[i]
                    if bonuses then
                        DynamicBonus.collectExtraBonuses(color, leader, bonuses)
                    end
                end

                Helper.emitEvent("tleilaxProgress", color)

                continuation.run(finalJump)
            end)
        else
            continuation.run(finalJump)
        end
    else
        continuation.run(finalJump)
    end

    return continuation
end

function TleilaxuResearch._createTanksButton()
    Helper.createAnchoredAreaButton(TleilaxuResearch.tanksZone, Board.onTleilaxBoard(-0.08), 0.1, I18N("specimenEdit"), PlayBoard.withLeader(function (leader, color, altClick)
        if altClick then
            leader.troops(color, "tanks", "supply", 1)
        else
            leader.troops(color, "supply", "tanks", 1)
        end
    end))
end

---@param color PlayerColor
---@return Park
function TleilaxuResearch._createTanksPark(color)
    local offsets = {
        Red = Vector(-0.65, 0, 0.45),
        Blue = Vector(-0.65, 0, -0.45),
        Green = Vector(0.65, 0, 0.45),
        Yellow = Vector(0.65, 0, -0.45)
    }

    local origin = TleilaxuResearch.tanksZone.getPosition() + offsets[color]
    origin:setAt('y', Board.onTleilaxBoard(0.18)) -- ground level
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

    local zone = Park.createTransientBoundingZone(0, Vector(0.25, 0.25, 0.25), slots)

    return Park.createPark(
        color .. "Tanks",
        slots,
        Vector(0, 0, 0),
        { zone },
        { "Troop", color },
        nil,
        false,
        true)
end

---@param color PlayerColor
---@return Park
function TleilaxuResearch.getTankPark(color)
    return TleilaxuResearch.tanksParks[color]
end

---@param location string|integer
---@param bonuses table<TARGET, table<CATEGORY, any>>
function TleilaxuResearch.addSpaceBonus(location, bonuses)
    local position
    if location == "oneHelix" then
        position = TleilaxuResearch.board.getPosition() + Vector(-0.55, 0, -3)
    elseif type(location) == "number" then
        position = TleilaxuResearch._tleilaxSpaceToWorldPosition(location) + Vector(0, 0, -0.5)
    else
        error("Unknow location: " .. location)
    end
    if not TleilaxuResearch.extraBonuses[location] then
        TleilaxuResearch.extraBonuses[location] = {}
    end
    DynamicBonus.createSpaceBonus(position, bonuses, TleilaxuResearch.extraBonuses[location])
end

return TleilaxuResearch
