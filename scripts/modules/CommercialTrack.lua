local Module = require("utils.Module")
local Helper = require("utils.Helper")

local Playboard = Module.lazyRequire("Playboard")
local TechMarket = Module.lazyRequire("TechMarket")
local TurnControl = Module.lazyRequire("TurnControl")
local Action = Module.lazyRequire("Action")

local CommercialTrack = {
    initialCargoPositions = {
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
end

---
function CommercialTrack.setUp()

    for i, levelSlot in ipairs(CommercialTrack.levelSlots) do
        CommercialTrack.createLevelButton(i - 1, levelSlot)
    end

    for bonusName, bonusSlot in pairs(CommercialTrack.bonusSlots) do
        CommercialTrack.createBonusButton(bonusName, bonusSlot)
    end
end

---
function CommercialTrack.tearDown()

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
function CommercialTrack.createLevelButton(level, levelSlot)
    local tooltip = level == 0 and "Recall your freighter" or "Progress on the commercial track"
    local ground = levelSlot.getPosition().y - 0.5
    Helper.createAnchoredAreaButton(levelSlot, ground, 0.2, tooltip, function (_, color, _)
        local cargoLevel = CommercialTrack.getCargoLevel(color)
        if cargoLevel < level then
            CommercialTrack.cargoGoUp(color, level - cargoLevel)
        elseif level == 0 then
            CommercialTrack.cargoReset(color)
        end
    end)
end

---
function CommercialTrack.createBonusButton(bonusName, bonusSlot)
    local tooltip = "Pick your " .. bonusName .. " bonus"
    local ground = bonusSlot.getPosition().y - 0.5
    local callbackName = Helper.toCamelCase("pick", bonusName, "bonus")
    local callback = CommercialTrack[callbackName]
    assert(callback, "No callback named " .. callbackName)
    Helper.createAnchoredAreaButton(bonusSlot, ground, 0.2, tooltip, function (_, color, _)
        callback(color)
    end)
end

---
function CommercialTrack.getCargoLevel(color)
    local p = Playboard.getContent(color).cargo.getPosition()
    return math.floor((p.z - CommercialTrack.initialCargoPositions[color].z) / 1.1 + 0.5)
end

---
function CommercialTrack.setCargoPositionSmooth(color, level)
    local p = CommercialTrack.initialCargoPositions[color]:copy()
    p:setAt('z', p.z + 1.1 * level)
    Playboard.getContent(color).cargo.setPositionSmooth(p, false, true)
end

---
function CommercialTrack.cargoGoUp(color, count)
    Helper.repeatMovingAction(Playboard.getContent(color).cargo, count, function ()
        CommercialTrack.cargoUp(color)
    end)
end

---
function CommercialTrack.cargoUp(color)
    local level = CommercialTrack.getCargoLevel(color)
    if level < 3 then
        CommercialTrack.setCargoPositionSmooth(color, level + 1)
        return true
    else
        return false
    end
end

---
function CommercialTrack.cargoReset(color)
    local level = CommercialTrack.getCargoLevel(color)
    if level > 0 then
        CommercialTrack.setCargoPositionSmooth(color, 0)
        if level >= 3 then
            TechMarket.registerAcquireTechOption(color, "cargo", "spice", 2)
        end
        return true
    else
        return false
    end
end

---
function CommercialTrack.pickSolariBonus(color)
    local leader = Playboard.getLeader(color)
    leader.resource(color, "solari", 5)
    for _, otherColor in ipairs(Playboard.getPlayboardColors()) do
        if otherColor ~= color then
            leader.resource(otherColor, "solari", 1)
        end
    end
end

---
function CommercialTrack.pickSpiceBonus(color)
    local leader = Playboard.getLeader(color)
    leader.resource(color, "spice", 2)
end

---
function CommercialTrack.pickTroopsAndInfluenceBonus(color)
    local leader = Playboard.getLeader(color)
    local troopAmount = 2
    if Playboard.hasTech(color, "troopTransports") then
        troopAmount = 3
    end
    leader.troops(color, "supply", "garrison", troopAmount)
end

return CommercialTrack
