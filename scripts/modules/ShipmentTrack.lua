local Module = require("utils.Module")
local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

local PlayBoard = Module.lazyRequire("PlayBoard")
local TechMarket = Module.lazyRequire("TechMarket")

local ShipmentTrack = {
    initialFreighterPositions = {
        Yellow = Helper.getHardcodedPositionFromGUID('8fa76f', 8.999361, 1.692984, 2.8496747),
        Green = Helper.getHardcodedPositionFromGUID('34281d', 8.449358, 1.6929840999999999, 2.850195),
        Blue = Helper.getHardcodedPositionFromGUID('68e424', 7.34958, 1.692984, 2.8548522),
        Red = Helper.getHardcodedPositionFromGUID('e9096d', 7.89935, 1.692984, 2.853141)
    }
}

---
function ShipmentTrack.onLoad(state)
    --Helper.dumpFunction("ShipmentTrack.onLoad")

    Helper.append(ShipmentTrack, Helper.resolveGUIDs(false, {
        --[[
        levelSlots = {
            "1eeba7",
            "4c40e8",
            "8d2ee6",
            "5764db",
        },
        bonusSlots = {
            spice = "5bf4d1",
            solari = "1cb928",
            troopsAndInfluence = "69a137",
        },
        ignoredBonusSlots = {
            tech = "0990d7", -- Implicit when the freighter is reset.
        }
        ]]
    }))

    if state.settings and state.settings.riseOfIx then
        ShipmentTrack._transientSetUp()
    end
end

---
function ShipmentTrack.setUp(settings)
    if settings.riseOfIx then
        ShipmentTrack._transientSetUp()
    else
        ShipmentTrack._tearDown()
    end
end

---
function ShipmentTrack._transientSetUp()
    --[[
    for i, levelSlot in ipairs(ShipmentTrack.levelSlots) do
        ShipmentTrack._createLevelButton(i - 1, levelSlot)
    end

    for bonusName, bonusSlot in pairs(ShipmentTrack.bonusSlots) do
        ShipmentTrack._createBonusButton(bonusName, bonusSlot)
    end
    ]]
end

---
function ShipmentTrack._tearDown()
    --[[
    for _, levelSlot in ipairs(ShipmentTrack.levelSlots) do
        levelSlot.destruct()
    end

    for _, bonusSlot in pairs(ShipmentTrack.bonusSlots) do
        bonusSlot.destruct()
    end

    for _, bonusSlot in pairs(ShipmentTrack.ignoredBonusSlots) do
        bonusSlot.destruct()
    end
    ]]
end

---
function ShipmentTrack._createLevelButton(level, levelSlot)
    local tooltip = level == 0
        and I18N("recallYourFreighter")
        or I18N("progressOnShipmentTrack")
    local ground = levelSlot.getPosition().y - 0.5
    Helper.createAnchoredAreaButton(levelSlot, ground, 0.2, tooltip, PlayBoard.withLeader(function (_, color, _)
        local leader = PlayBoard.getLeader(color)
        local freighterLevel = ShipmentTrack.getFreighterLevel(color)
        if freighterLevel < level then
            leader.advanceFreighter(color, level - freighterLevel)
        elseif level == 0 then
            leader.recallFreighter(color)
        end
    end))
end

---
function ShipmentTrack._createBonusButton(bonusName, bonusSlot)
    local tooltip = I18N("pickBonus", { bonus = I18N(bonusName) })
    local ground = bonusSlot.getPosition().y - 0.5
    local callbackName = Helper.toCamelCase("_pick", bonusName, "bonus")
    local callback = ShipmentTrack[callbackName]
    assert(callback, "No callback named " .. callbackName)
    Helper.createAnchoredAreaButton(bonusSlot, ground, 0.2, tooltip, PlayBoard.withLeader(function (_, color, _)
        callback(color)
    end))
end

---
function ShipmentTrack.getFreighterLevel(color)
    local p = PlayBoard.getContent(color).freighter.getPosition()
    return math.floor((p.z - ShipmentTrack.initialFreighterPositions[color].z) / 1.1 + 0.5)
end

---
function ShipmentTrack._setFreighterPositionSmooth(color, level)
    local p = ShipmentTrack.initialFreighterPositions[color]:copy()
    p:setAt('z', p.z + 1.1 * level)
    PlayBoard.getContent(color).freighter.setPositionSmooth(p, false, true)
end

---
function ShipmentTrack._freighterGoUp(color, count)
    Helper.repeatMovingAction(PlayBoard.getContent(color).freighter, count, function ()
        ShipmentTrack.freighterUp(color)
    end)
end

---
function ShipmentTrack.freighterUp(color, baseCount)
    local level = ShipmentTrack.getFreighterLevel(color)
    local count = math.min(baseCount or 1, 3 - level)
    if count > 0 then
        ShipmentTrack._setFreighterPositionSmooth(color, level + count)
        return true
    else
        return false
    end
end

---
function ShipmentTrack.freighterReset(color)
    local level = ShipmentTrack.getFreighterLevel(color)
    if level > 0 then
        ShipmentTrack._setFreighterPositionSmooth(color, 0)
        if level >= 3 then
            TechMarket.registerAcquireTechOption(color, "freighterTechBuyOption", "spice", 2)
        end
        return true
    else
        return false
    end
end

---
function ShipmentTrack._pickSolariBonus(color)
    local leader = PlayBoard.getLeader(color)
    leader.resources(color, "solari", 5)
    for _, otherColor in ipairs(PlayBoard.getActivePlayBoardColors()) do
        if otherColor ~= color then
            local otherLeader = PlayBoard.getLeader(otherColor)
            otherLeader.resources(otherColor, "solari", 1)
        end
    end
end

---
function ShipmentTrack._pickSpiceBonus(color)
    local leader = PlayBoard.getLeader(color)
    leader.resources(color, "spice", 2)
end

---
function ShipmentTrack._pickTroopsAndInfluenceBonus(color)
    local leader = PlayBoard.getLeader(color)
    local troopAmount = 2
    if PlayBoard.hasTech(color, "troopTransports") then
        troopAmount = 3
    end
    leader.setContext("troopTransports")
    leader.troops(color, "supply", "garrison", troopAmount)
    leader.unsetContext("troopTransports")
end

return ShipmentTrack
