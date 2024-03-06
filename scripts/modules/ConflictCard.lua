local Module = require("utils.Module")
local Helper = require("utils.Helper")

-- Exceptional Immediate require for the sake of aliasing.
local CardEffect = require("CardEffect")

local PlayBoard = Module.lazyRequire("PlayBoard")
local Types = Module.lazyRequire("Types")
local Action = Module.lazyRequire("Action")

-- Function aliasing for a more readable code.
local persuasion = CardEffect.persuasion
local sword = CardEffect.sword
local spice = CardEffect.spice
local water = CardEffect.water
local solari = CardEffect.solari
local troop = CardEffect.troop
local dreadnought = CardEffect.dreadnought
local negotiator = CardEffect.negotiator
local specimen = CardEffect.specimen
local intrigue = CardEffect.intrigue
local trash = CardEffect.trash
local research = CardEffect.research
local beetle = CardEffect.beetle
local influence = CardEffect.influence
local vp = CardEffect.vp
local draw = CardEffect.draw
local shipment = CardEffect.shipment
local mentat = CardEffect.mentat
local control = CardEffect.control
local perDreadnoughtInConflict = CardEffect.perDreadnoughtInConflict
local perSwordCard = CardEffect.perSwordCard
local perFremen = CardEffect.perFremen
local choice = CardEffect.choice
local optional = CardEffect.optional
local seat = CardEffect.seat
local fremenBond = CardEffect.fremenBond
local agentInEmperorSpace = CardEffect.agentInEmperorSpace
local emperorAlliance = CardEffect.emperorAlliance
local spacingGuildAlliance = CardEffect.spacingGuildAlliance
local beneGesseritAlliance = CardEffect.beneGesseritAlliance
local fremenAlliance = CardEffect.fremenAlliance
local fremenFriendship = CardEffect.fremenFriendship
local anyAlliance = CardEffect.anyAlliance
local oneHelix = CardEffect.oneHelix
local twoHelices = CardEffect.twoHelices
local winner = CardEffect.winner
local swordmaster = CardEffect.swordmaster

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
    machinations = {level = 2, base = true, rewards = {{choice(2, {influence(1, "emperor"), influence(1, "spacingGuild"), influence(1, "beneGesserit"), influence(1, "fremen")})}, {water(1), solari(2)}, {water(1)}}},
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
    economicSupremacy = {level = 3, ix = true, rewards = {{vp(1), optional({solari(-6), vp(1)}), optional({spice(-4), vp(1)})}, {vp(1)}, {spice(2), solari(2)}}},
}

function ConflictCard.collectReward(color, conflictName, rank)
    Types.assertIsInRange(1, 3, rank)
    local conflict = ConflictCard[conflictName]
    assert(conflict, "Unknown conflict: " .. tostring(conflictName))
    local rewards = conflict.rewards[rank]

    local context = {
        color = color,
        player = PlayBoard.getLeader(color),
        cardName = conflictName,
    }

    for _, reward in ipairs(rewards) do
        log(reward)
        CardEffect.evaluate(context, reward)
    end
end

function ConflictCard.getLevel(conflictName)
    local conflict = ConflictCard[conflictName]
    assert(conflict, conflictName)
    return conflict.level
end

function ConflictCard.cleanUpConflict(color, conflictName)
    local conflict = ConflictCard[conflictName]
    assert(conflict, "Unknown conflict: ", conflictName)
    local rewards = conflict.rewards[1]

    local context = {
        color = color,
        player = {
            control = function (spaceName)
                local controlableSpace = MainBoard.findControlableSpaceFromConflictName(conflictName)
                MainBoard.occupy(controlableSpace, color, true)
            end
        },
        cardName = conflictName,
    }

    Helper.dump("Cleaning conflict", conflictName, "...")
    for _, reward in ipairs(rewards) do
        log(reward)
        CardEffect.evaluate(context, reward)
    end
    Helper.dump("... end")
end

return ConflictCard
