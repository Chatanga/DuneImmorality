local Module = require("utils.Module")
local Helper = require("utils.Helper")

local PlayBoard = Module.lazyRequire("PlayBoard")
local TechMarket = Module.lazyRequire("TechMarket")

local CommercialTrack = {
    initialFreighterPositions = {
        Yellow = Helper.getHardcodedPositionFromGUID('8fa76f', 8.999577, 0.680369258, 2.85036778),
        Green = Helper.getHardcodedPositionFromGUID('34281d', 8.44957352, 0.680363059, 2.850372),
        Blue = Helper.getHardcodedPositionFromGUID('68e424', 7.34955072, 0.680377, 2.8544054),
        Red = Helper.getHardcodedPositionFromGUID('e9096d', 7.89962, 0.6803636, 2.8532238)
    }
}

---
function CommercialTrack.onLoad(state)
    Helper.append(CommercialTrack, Helper.resolveGUIDs(true, {
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
    }))

    if state.settings and state.settings.riseOfIx then
        CommercialTrack._staticSetUp()
    end
end

---
function CommercialTrack.setUp(settings)
    if settings.riseOfIx then
        CommercialTrack._staticSetUp()
    else
        CommercialTrack._tearDown()
    end
end

---
function CommercialTrack._staticSetUp()
    for i, levelSlot in ipairs(CommercialTrack.levelSlots) do
        CommercialTrack._createLevelButton(i - 1, levelSlot)
    end

    for bonusName, bonusSlot in pairs(CommercialTrack.bonusSlots) do
        CommercialTrack._createBonusButton(bonusName, bonusSlot)
    end
end

---
function CommercialTrack._tearDown()
    for _, levelSlot in ipairs(CommercialTrack.levelSlots) do
        levelSlot.destruct()
    end

    for _, bonusSlot in pairs(CommercialTrack.bonusSlots) do
        bonusSlot.destruct()
    end

    for _, bonusSlot in pairs(CommercialTrack.ignoredBonusSlots) do
        bonusSlot.destruct()
    end
end

---
function CommercialTrack._createLevelButton(level, levelSlot)
    local tooltip = level == 0 and "Recall your freighter" or "Progress on the commercial track"
    local ground = levelSlot.getPosition().y - 0.5
    Helper.createAnchoredAreaButton(levelSlot, ground, 0.2, tooltip, function (_, color, _)
        local freighterLevel = CommercialTrack._getFreighterLevel(color)
        if freighterLevel < level then
            CommercialTrack._freighterGoUp(color, level - freighterLevel)
        elseif level == 0 then
            CommercialTrack.freighterReset(color)
        end
    end)
end

---
function CommercialTrack._createBonusButton(bonusName, bonusSlot)
    local tooltip = "Pick your " .. bonusName .. " bonus"
    local ground = bonusSlot.getPosition().y - 0.5
    local callbackName = Helper.toCamelCase("_pick", bonusName, "bonus")
    local callback = CommercialTrack[callbackName]
    assert(callback, "No callback named " .. callbackName)
    Helper.createAnchoredAreaButton(bonusSlot, ground, 0.2, tooltip, function (_, color, _)
        callback(color)
    end)
end

---
function CommercialTrack._getFreighterLevel(color)
    local p = PlayBoard.getContent(color).freighter.getPosition()
    return math.floor((p.z - CommercialTrack.initialFreighterPositions[color].z) / 1.1 + 0.5)
end

---
function CommercialTrack._setFreighterPositionSmooth(color, level)
    local p = CommercialTrack.initialFreighterPositions[color]:copy()
    p:setAt('z', p.z + 1.1 * level)
    PlayBoard.getContent(color).freighter.setPositionSmooth(p, false, true)
end

---
function CommercialTrack._freighterGoUp(color, count)
    Helper.repeatMovingAction(PlayBoard.getContent(color).freighter, count, function ()
        CommercialTrack.freighterUp(color)
    end)
end

---
function CommercialTrack.freighterUp(color)
    local level = CommercialTrack._getFreighterLevel(color)
    if level < 3 then
        CommercialTrack._setFreighterPositionSmooth(color, level + 1)
        return true
    else
        return false
    end
end

---
function CommercialTrack.freighterReset(color)
    local level = CommercialTrack._getFreighterLevel(color)
    if level > 0 then
        CommercialTrack._setFreighterPositionSmooth(color, 0)
        if level >= 3 then
            TechMarket.registerAcquireTechOption(color, "freighter", "spice", 2)
        end
        return true
    else
        return false
    end
end

---
function CommercialTrack._pickSolariBonus(color)
    local leader = PlayBoard.getLeader(color)
    leader.resource(color, "solari", 5)
    for _, otherColor in ipairs(PlayBoard.getPlayboardColors()) do
        if otherColor ~= color then
            leader.resource(otherColor, "solari", 1)
        end
    end
end

---
function CommercialTrack._pickSpiceBonus(color)
    local leader = PlayBoard.getLeader(color)
    leader.resource(color, "spice", 2)
end

---
function CommercialTrack._pickTroopsAndInfluenceBonus(color)
    local leader = PlayBoard.getLeader(color)
    local troopAmount = 2
    if PlayBoard.hasTech(color, "troopTransports") then
        troopAmount = 3
    end
    leader.troops(color, "supply", "garrison", troopAmount)
end

return CommercialTrack
