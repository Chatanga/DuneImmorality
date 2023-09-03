local Module = require("utils.Module")
local Helper = require("utils.Helper")

local Utils = Module.lazyRequire("Utils")
local PlayBoard = Module.lazyRequire("PlayBoard")
local MainBoard = Module.lazyRequire("MainBoard")

local function vp(n)
    return function (color, conflictName, collectOptionalRewards)
        for _ = 1, n do
            PlayBoard.getLeader(color).gainVictoryPoint(color, conflictName)
        end
        return true
    end
end

local function intrigue(n)
    return function (color)
        return PlayBoard.getLeader(color).drawIntrigues(color, n)
    end
end

local function water(n)
    return function (color)
        return PlayBoard.getLeader(color).resources(color, "water", n)
    end
end

local function spice(n)
    return function (color)
        return PlayBoard.getLeader(color).resources(color, "spice", n)
    end
end

local function solari(n)
    return function (color)
        return PlayBoard.getLeader(color).resources(color, "solari", n)
    end
end

local function influence(n, faction)
    return function (color)
        return PlayBoard.getLeader(color).influence(color, faction, n)
    end
end

local function shipment(n)
    return function (color)
        return PlayBoard.getLeader(color).shipments(color, n)
    end
end

local function troop(n)
    return function (color)
        return PlayBoard.getLeader(color).troops(color, "supply", "garrison", n)
    end
end

local function mentat(n)
    return function (color)
        if PlayBoard.getLeader(color).takeMentat(color) then
            -- Locked to avoid being recalled.
            MainBoard.getMentat().setLock(true)
            return true
        else
            return false
        end
    end
end

local function control(space)
    return function (color)
        return PlayBoard.getLeader(color).takeMentat(color, space)
    end
end

local function trash(space)
    return function (color)
        return false
    end
end

local function choice(n, options)
    return function (color, conflictName)
        if not PlayBoard.getLeader(color).choose(color, conflictName) then
            local shuffledOptions = Helper.shallowCopy(options)
            Helper.shuffle(shuffledOptions)
            for i = 1, n do
                shuffledOptions[i](color, conflictName)
            end
        end
        return true
    end
end

local function optional(options)
    return function (color, conflictName, collectOptionalRewards)
        if collectOptionalRewards then
            for  _, option in options do
                if not option(color, conflictName, collectOptionalRewards) then
                    return false
                end
            end
            return true
        else
            return false
        end
    end
end

local ConflictCard = {
    skirmishA = {level = 1, base = true, rewards = {{vp(1)}, {intrigue(1), solari(2)}, {solari(2)}}},
    skirmishB = {level = 1, base = true, rewards = {{vp(1)}, {water(1)}, {spice(1)}}},
    skirmishC = {level = 1, base = true, rewards = {{influence(1), spice(1)}, {spice(2)}, {spice(1)}}},
    skirmishD = {level = 1, base = true, rewards = {{influence(1), solari(2)}, {solari(3)}, {solari(2)}}},
    skirmishE = {level = 1, ix = true, rewards = {{shipment(1), spice(1)}, {solari(3)}, {solari(2)}}},
    skirmishF = {level = 1, ix = true, rewards = {{shipment(1), troop(1)}, {spice(2)}, {spice(1)}}},

    desertPower = {level = 2, base = true, rewards = {{vp(1), water(1)}, {water(1), spice(1)}, {spice(1)}}},
    raidStockpiles = {level = 2, base = true, rewards = {{intrigue(1), spice(3)}, {spice(2)}, {spice(1)}}},
    cloakAndDagger = {level = 2, base = true, rewards = {{influence(1), intrigue(2)}, {intrigue(1), spice(1)}, {choice(1, {intrigue(1), spice(1)})}}},
    machinations = {level = 2, base = true, rewards = {{choice(2, {influence(1, "emperor"), influence(1, "spacingGuild"), influence(1, "beneGesserit"), influence(1, "fremen")})}, {water(2), solari(2)}, {water(1)}}},
    sortThroughTheChaos = {level = 2, base = true, rewards = {{mentat(1), intrigue(1), solari(2)}, {intrigue(1), solari(2)}, {solari(2)}}},
    terriblePurpose = {level = 2, base = true, rewards = {{vp(1), trash(1)}, {water(1), spice(1)}, {spice(1)}}},
    guildBankRaid = {level = 2, base = true, rewards = {{solari(6)}, {solari(4)}, {solari(2)}}},
    siegeOfArrakeen = {level = 2, base = true, rewards = {{vp(1), control("arrakeen")}, {solari(4)}, {solari(2)}}},
    siegeOfCarthag = {level = 2, base = true, rewards = {{vp(1), control("carthag")}, {intrigue(1), spice(1)}, {spice(1)}}},
    secureImperialBasin = {level = 2, base = true, rewards = {{vp(1), control("imperialBasin")}, {water(2)}, {water(1)}}},
    tradeMonopoly = {level = 2, ix = true, rewards = {{shipment(2), troop(1)}, {intrigue(1), water(1)}, {choice(1, {intrigue(1), water(1)})}}},

    battleForImperialBasin = {level = 3, base = true, rewards = {{vp(2), control("imperialBasin")}, {spice(5)}, {spice(3)}}},
    grandVision = {level = 3, base = true, rewards = {{influence(2), intrigue(1)}, {intrigue(1), spice(3)}, {spice(3)}}},
    battleForCarthag = {level = 3, base = true, rewards = {{vp(2), control("carthag")}, {intrigue(1), spice(3)}, {spice(3)}}},
    battleForArrakeen = {level = 3, base = true, rewards = {{vp(2), control("arrakeen")}, {choice(2, {intrigue(1), spice(2), solari(3)})}, {intrigue(1), solari(2)}}},
    onomicSupremacy = {level = 3, ix = true, rewards = {{vp(1), optional({solari(-6), vp(1)}), optional({spice(-4), vp(1)})}, {vp(1)}, {spice(2), solari(2)}}},
}

function ConflictCard.collectReward(color, conflictName, rank, collectOptionalRewards)
    Utils.assertIsInRange(1, 3, rank)
    local conflict = ConflictCard[conflictName]
    assert(conflict, "Unknown conflict: ", conflictName)
    local rewards = conflict.rewards[rank]
    for i, reward in ipairs(rewards) do
        reward(color, conflictName, collectOptionalRewards)
    end
end

return ConflictCard
