local Module = require("utils.Module")
local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

local PlayBoard = Module.lazyRequire("PlayBoard")
local TechMarket = Module.lazyRequire("TechMarket")

local ShippingTrack = {
    initialFreighterPositions = {
        Yellow = Helper.getHardcodedPositionFromGUID('8fa76f', 8.999569, 0.664116144, 2.85036254),
        Green = Helper.getHardcodedPositionFromGUID('34281d', 8.44955349, 0.6641097, 2.850371),
        Blue = Helper.getHardcodedPositionFromGUID('68e424', 7.34954262, 0.6641074, 2.85441518),
        Red = Helper.getHardcodedPositionFromGUID('e9096d', 7.899618, 0.6641103, 2.853234)
    }
}

---
function ShippingTrack.onLoad(state)
    Helper.append(ShippingTrack, Helper.resolveGUIDs(true, {
        levelSlots = {
            "1eeba7",
            "4c40e8",
            "8d2ee6",
            "5764db",
        },
        bonusSlots = {
            spice = "5bf4d1",
            solaris = "1cb928",
            troopsAndInfluence = "69a137",
        },
        ignoredBonusSlots = {
            tech = "0990d7", -- Implicit when the freighter is reset.
        }
    }))

    if state.settings and state.settings.riseOfIx then
        ShippingTrack._transientSetUp(state.settings)
    end
end

---
function ShippingTrack.setUp(settings)
    if settings.riseOfIx then
        ShippingTrack._transientSetUp(settings)
    else
        ShippingTrack._tearDown()
    end
end

---
function ShippingTrack._transientSetUp(settings)
    for i, levelSlot in ipairs(ShippingTrack.levelSlots) do
        ShippingTrack._createLevelButton(i - 1, levelSlot)
    end

    for bonusName, bonusSlot in pairs(ShippingTrack.bonusSlots) do
        ShippingTrack._createBonusButton(bonusName, bonusSlot)
    end
end

---
function ShippingTrack._tearDown()
    for _, levelSlot in ipairs(ShippingTrack.levelSlots) do
        levelSlot.destruct()
    end

    for _, bonusSlot in pairs(ShippingTrack.bonusSlots) do
        bonusSlot.destruct()
    end

    for _, bonusSlot in pairs(ShippingTrack.ignoredBonusSlots) do
        bonusSlot.destruct()
    end
end

---
function ShippingTrack._createLevelButton(level, levelSlot)
    local tooltip = level == 0
        and I18N("recallYourFreighter")
        or I18N("progressOnShippingTrack")
    local ground = levelSlot.getPosition().y - 0.5
    Helper.createAnchoredAreaButton(levelSlot, ground, 0.2, tooltip, PlayBoard.withLeader(function (_, color, _)
        local leader = PlayBoard.getLeader(color)
        local freighterLevel = ShippingTrack.getFreighterLevel(color)
        if freighterLevel < level then
            leader.advanceFreighter(color, level - freighterLevel)
        elseif level == 0 then
            leader.recallFreighter(color)
        end
    end))
end

---
function ShippingTrack._createBonusButton(bonusName, bonusSlot)
    local tooltip = I18N("pickBonus", { bonus = I18N(bonusName) })
    local ground = bonusSlot.getPosition().y - 0.5
    local callbackName = Helper.toCamelCase("_pick", bonusName, "bonus")
    local callback = ShippingTrack[callbackName]
    assert(callback, "No callback named " .. callbackName)
    Helper.createAnchoredAreaButton(bonusSlot, ground, 0.2, tooltip, PlayBoard.withLeader(function (_, color, _)
        callback(color)
    end))
end

---
function ShippingTrack.getFreighterLevel(color)
    local p = PlayBoard.getContent(color).freighter.getPosition()
    return math.floor((p.z - ShippingTrack.initialFreighterPositions[color].z) / 1.1 + 0.5)
end

---
function ShippingTrack._setFreighterPositionSmooth(color, level)
    local p = ShippingTrack.initialFreighterPositions[color]:copy()
    p:setAt('z', p.z + 1.1 * level)
    PlayBoard.getContent(color).freighter.setPositionSmooth(p, false, true)
end

---
function ShippingTrack._freighterGoUp(color, count)
    Helper.repeatMovingAction(PlayBoard.getContent(color).freighter, count, function ()
        ShippingTrack.freighterUp(color)
    end)
end

---
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

---
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

---
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

---
function ShippingTrack._pickSpiceBonus(color)
    local leader = PlayBoard.getLeader(color)
    leader.resources(color, "spice", 2)
end

---
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
