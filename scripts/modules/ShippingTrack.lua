local Module = require("utils.Module")
local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

local PlayBoard = Module.lazyRequire("PlayBoard")
local TechMarket = Module.lazyRequire("TechMarket")
local Board = Module.lazyRequire("Board")

local ShippingTrack = {
    initialFreighterPositions = {
        Yellow = Helper.getHardcodedPositionFromGUID('521923', 9.0, 1.77500021, 2.95),
        Green = Helper.getHardcodedPositionFromGUID('704034', 8.5, 1.77500021, 2.95),
        Blue = Helper.getHardcodedPositionFromGUID('9b1fe4', 7.5, 1.77250016, 2.95),
        Red = Helper.getHardcodedPositionFromGUID('9ec642', 8.0, 1.77250028, 2.95)
    }
}

---@param state table
function ShippingTrack.onLoad(state)
    if state.settings and state.settings.ix then
        ShippingTrack.board = Board.getBoard("shippingBoard")
        ShippingTrack._transientSetUp(state.settings)
    end
end

---@param settings Settings
function ShippingTrack.setUp(settings)
    if settings.ix then
        ShippingTrack.board = Board.selectBoard("shippingBoard", I18N.getLocale(), false)
        ShippingTrack._transientSetUp(settings)
    else
        Board.destructBoard("shippingBoard")
    end
end

---@param settings Settings
function ShippingTrack._transientSetUp(settings)

    local createZone = function (position, scale)
        local object = Helper.markAsTransient(spawnObject({
            type = 'ScriptingTrigger',
            position = position,
            scale = scale,
        }))
        ---@cast object Zone
        return object
    end

    Helper.collectSnapPoints(ShippingTrack.board, {

        freighterSpace = function (name, position)
            local index = tonumber(name)
            assert(index, "Not a number: " .. name)
            local levelSlot = createZone(position, Vector(index > 0 and 2.3 or 3.6, 2, 1))
            ShippingTrack._createLevelButton(index, levelSlot)
        end,

        freighterBonus = function (name, position)
            local bounds
            if name == "troopsAndInfluence" then
                bounds = Vector(1.3, 1, 1)
            elseif name == "solaris" then
                bounds = Vector(0.7, 1, 0.7)
            elseif name == "spice" then
                bounds = Vector(0.7, 1, 0.7)
            else
                error(name)
            end
            local bonusSlot = createZone(position, bounds)
            ShippingTrack._createBonusButton(name, bonusSlot)
        end,
    })
end

---@return Object?
function ShippingTrack.getBoard()
    return ShippingTrack.board
end

---@param level integer
---@param levelSlot Zone
function ShippingTrack._createLevelButton(level, levelSlot)
    local tooltip = level == 0
        and I18N("recallYourFreighter")
        or I18N("progressOnShipmentTrack")
    local ground = levelSlot.getPosition().y - 0.1
    Helper.createAnchoredAreaButton(levelSlot, ground, 0.2, tooltip, PlayBoard.withLeader(function (leader, color, _)
        local freighterLevel = ShippingTrack.getFreighterLevel(color)
        if freighterLevel < level then
            leader.advanceFreighter(color, level - freighterLevel)
        elseif level == 0 then
            leader.recallFreighter(color)
        end
    end))
end

---@param bonusName string
---@param bonusSlot Zone
function ShippingTrack._createBonusButton(bonusName, bonusSlot)
    local tooltip = I18N("pickBonus", { bonus = I18N(bonusName) })
    local ground = bonusSlot.getPosition().y - 0.1
    local callbackName = Helper.toCamelCase("_pick", bonusName, "bonus")
    local callback = ShippingTrack[callbackName]
    assert(callback, "No callback named " .. callbackName)
    Helper.createAnchoredAreaButton(bonusSlot, ground, 0.2, tooltip, PlayBoard.withLeader(function (_, color, _)
        callback(color)
    end))
end

---@param color PlayerColor
---@return integer
function ShippingTrack.getFreighterLevel(color)
    local p = PlayBoard.getContent(color).freighter.getPosition()
    return math.floor((p.z - ShippingTrack.initialFreighterPositions[color].z) / 1.1 + 0.5)
end

---@param color PlayerColor
---@param level integer
function ShippingTrack._setFreighterPositionSmooth(color, level)
    local p = ShippingTrack.initialFreighterPositions[color]:copy()
    p:setAt('z', p.z + 1.1 * level)
    PlayBoard.getContent(color).freighter.setPositionSmooth(p, false, true)
end

---@param color PlayerColor
---@param count integer
function ShippingTrack.freighterGoUp(color, count)
    Helper.repeatMovingAction(PlayBoard.getContent(color).freighter, count, function ()
        ShippingTrack.freighterUp(color)
    end)
end

---@param color PlayerColor
---@param baseCount? integer
---@return boolean
function ShippingTrack.freighterUp(color, baseCount)
    local level = ShippingTrack.getFreighterLevel(color)
    local count = math.min(baseCount or 1, 3 - level)
    if count > 0 then
        ShippingTrack._setFreighterPositionSmooth(color, level + count)
        return true
    else
        return false
    end
end

---@param color PlayerColor
---@return boolean
function ShippingTrack.freighterReset(color)
    local level = ShippingTrack.getFreighterLevel(color)
    if level > 0 then
        ShippingTrack._setFreighterPositionSmooth(color, 0)
        if level >= 3 then
            TechMarket.registerAcquireTechOption(color, "freighterTechBuyOption", "spice", 2)
        end
        return true
    else
        return false
    end
end

---@param color PlayerColor
function ShippingTrack._pickSolarisBonus(color)
    local leader = PlayBoard.getLeader(color)
    leader.resources(color, "solari", 5)
    for _, otherColor in ipairs(PlayBoard.getActivePlayBoardColors()) do
        if otherColor ~= color then
            local otherLeader = PlayBoard.getLeader(otherColor)
            otherLeader.resources(otherColor, "solari", 1)
        end
    end
end

---@param color PlayerColor
function ShippingTrack._pickSpiceBonus(color)
    local leader = PlayBoard.getLeader(color)
    leader.resources(color, "spice", 2)
end

---@param color PlayerColor
function ShippingTrack._pickTroopsAndInfluenceBonus(color)
    local leader = PlayBoard.getLeader(color)
    local troopAmount = 2
    if PlayBoard.hasTech(color, "troopTransports") then
        troopAmount = 3
    end
    leader.setContext("troopTransports")
    leader.troops(color, "supply", "garrison", troopAmount)
    leader.unsetContext("troopTransports")
end

return ShippingTrack
