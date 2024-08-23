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
local deploy = CardEffect.deploy
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
local control = CardEffect.control
local spy = CardEffect.spy
local contract = CardEffect.contract
local perDreadnoughtInConflict = CardEffect.perDreadnoughtInConflict
local perSwordCard = CardEffect.perSwordCard
local perFremen = CardEffect.perFremen
local perEmperor = CardEffect.perEmperor
local perFulfilledContract = CardEffect.perFulfilledContract
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
local twoSpies = CardEffect.twoSpies
local spyMakerSpace = CardEffect.spyMakerSpace
local swordmaster = CardEffect.swordmaster

local ConflictCard = {
    skirmishA = {level = 1, uprising = true, objective = "crysknife", rewards = {{influence(1)}, {intrigue(1), spice(1)}, {spice(1)}}},
    skirmishB = {level = 1, uprising = true, objective = "ornithopter", rewards = {{intrigue(1), solari(1)}, {intrigue(1), solari(2)}, {intrigue(1)}}},
    skirmishC = {level = 1, uprising = true, objective = "muadDib", rewards = {{solari(2)}, {solari(3)}, {solari(2)}}},
    --[[
    desertPower = {level = 2, legacy = true, rewards = {{vp(1), water(1)}, {water(1), spice(1)}, {spice(1)}}},
    raidStockpiles = {level = 2, legacy = true, rewards = {{intrigue(1), spice(3)}, {spice(2)}, {spice(1)}}},
    cloakAndDagger = {level = 2, legacy = true, rewards = {{influence(1), intrigue(2)}, {intrigue(1), spice(1)}, {choice(1, {intrigue(1), spice(1)})}}},
    machinations = {level = 2, legacy = true, rewards = {{choice(2, {influence(1, "emperor"), influence(1, "spacingGuild"), influence(1, "beneGesserit"), influence(1, "fremen")})}, {water(1), solari(2)}, {water(1)}}},
    sortThroughTheChaos = {level = 2, legacy = true, rewards = {{mentat(), intrigue(1), solari(2)}, {intrigue(1), solari(2)}, {solari(2)}}},
    terriblePurpose = {level = 2, legacy = true, rewards = {{vp(1), trash(1)}, {water(1), spice(1)}, {spice(1)}}},
    guildBankRaid = {level = 2, legacy = true, rewards = {{solari(6)}, {solari(4)}, {solari(2)}}},
    siegeOfArrakeen = {level = 2, legacy = true, rewards = {{vp(1), control("arrakeen")}, {solari(4)}, {solari(2)}}},
    siegeOfCarthag = {level = 2, legacy = true, rewards = {{vp(1), control("carthag")}, {intrigue(1), spice(1)}, {spice(1)}}},
    secureImperialBasin = {level = 2, legacy = true, rewards = {{vp(1), control("imperialBasin")}, {water(2)}, {water(1)}}},
    tradeMonopoly = {level = 2, ix = true, rewards = {{shipment(2), troop(1)}, {intrigue(1), water(1)}, {choice(1, {intrigue(1), water(1)})}}},
    ]]
    choamSecurity = {level = 2, uprising = true, objective = "crysknife", rewards = {{influence(1, "spacingGuild"), contract(), troop(1)}, {water(1), solari(2), troop(2)}, {intrigue(1), troop(1)}}},
    spiceFreighters = {level = 2, uprising = true, objective = "crysknife", rewards = {{ influence(1), optional({spice(-3), vp(1)})}, {water(1), spice(1), troop(1)}, {spice(1), troop(1)}}},
    siegeOfArrakeen = {level = 2, uprising = true, objective = "ornithopter", rewards = {{control("arrakeen"), solari(2), troop(2)}, {solari(4), troop(1)}, {solari(3)}}},
    seizeSpiceRefinery = {level = 2, uprising = true, objective = "crysknife", rewards = {{control("spiceRefinery"), spy(1), spice(2)}, {intrigue(1), spice(1), troop(1)}, {spice(2)}}},
    testOfLoyalty = {level = 2, uprising = true, objective = "ornithopter", rewards = {{influence(1, "emperor"), spy(1), solari(2)}, {solari(4), troop(1)}, {solari(3)}}},
    shadowContest = {level = 2, uprising = true, objective = "ornithopter", rewards = {{influence(1, "beneGesserit"), intrigue(1)}, {intrigue(1), spice(1), troop(1)}, {spice(1), troop(1)}}},
    secureImperialBasin = {level = 2, uprising = true, objective = "muadDib", rewards = {{control("imperialBasin"), spice(2), troop(1)}, {water(2), troop(1)}, {water(1), troop(1)}}},
    protectTheSietches = {level = 2, uprising = true, objective = "muadDib", rewards = {{influence(1, "fremen"), water(1), troop(1)}, {spice(3), troop(1)}, {spice(2)}}},
    tradeDispute = {level = 2, uprising = true, objective = "muadDib", rewards = {{contract(), water(1), trash(1)}, {water(1), spice(1), trash(1)}, {water(1), troop(1)}}},
    --[[
    battleForImperialBasin = {level = 3, legacy = true, rewards = {{vp(2), control("imperialBasin")}, {spice(5)}, {spice(3)}}},
    grandVision = {level = 3, legacy = true, rewards = {{influence(2), intrigue(1)}, {intrigue(1), spice(3)}, {spice(3)}}},
    battleForCarthag = {level = 3, legacy = true, rewards = {{vp(2), control("carthag")}, {intrigue(1), spice(3)}, {spice(3)}}},
    battleForArrakeen = {level = 3, legacy = true, rewards = {{vp(2), control("arrakeen")}, {choice(2, {intrigue(1), spice(2), solari(3)})}, {intrigue(1), solari(2)}}},
    ]]
    economicSupremacy = {level = 3, ix = true, rewards = {{vp(1), optional({solari(-6), vp(1)}), optional({spice(-4), vp(1)})}, {vp(1)}, {spice(2), solari(2)}}},
    propaganda = {level = 3, uprising = true, objective = "joker", rewards = {{choice(2, {influence(1, "emperor"), influence(1, "spacingGuild"), influence(1, "beneGesserit"), influence(1, "fremen")})}, {intrigue(1), spice(3)}, {spice(3)}}},
    battleForImperialBasin = {level = 3, uprising = true, objective = "ornithopter", rewards = {{vp(1), control("imperialBasin"), optional({spice(-4), vp(1)})}, {spice(5)}, {spice(3)}}},
    battleForArrakeen = {level = 3, uprising = true, objective = "crysknife", rewards = {{vp(1), control("arrakeen"), optional({spy(-2), vp(1)})}, {intrigue(1), spice(1), solari(3)}, {spice(2), solari(2)}}},
    battleForSpiceRefinery = {level = 3, uprising = true, objective = "muadDib", rewards = {{vp(1), control("spiceRefinery"), optional({solari(-6), vp(1)})}, {intrigue(1), spice(3)}, {spice(3)}}},
}

function ConflictCard.getObjective(conflictName)
    local conflict = ConflictCard[conflictName]
    assert(conflict, "Unknown conflict: " .. tostring(conflictName))
    return conflict.objective
end

function ConflictCard.collectReward(color, conflictName, rank, doubleRewards, postAction)
    Types.assertIsInRange(1, 3, rank)
    local conflict = ConflictCard[conflictName]
    assert(conflict, "Unknown conflict: " .. tostring(conflictName))
    local rewards = conflict.rewards[rank]

    local context = {
        color = color,
        player = PlayBoard.getLeader(color),
        cardName = conflictName,
    }

    Action.setContext("combatEnded")

    if rank == 1 and conflict.objective then
        context.player.gainObjective(context.color, conflict.objective)
    end

    local continuation = Helper.createContinuation("ConflictCard.collectReward")

    local functionHolder = {}
    functionHolder.i = 1
    functionHolder.f = function ()
        for _, reward in ipairs(rewards) do
            CardEffect.evaluate(context, reward)
        end

        local innerContinuation = postAction and postAction() or Helper.fakeContinuation()
        innerContinuation.doAfter(function ()
            Action.flushTroopTransfer()
            if doubleRewards and functionHolder.i == 1 then
                Helper.onceTimeElapsed(2).doAfter(function ()
                    functionHolder.i = functionHolder.i + 1
                    functionHolder.f()
                end)
            else
                Helper.dump("Triggering " .. continuation.name);
                continuation.run()
            end
        end)
    end

    functionHolder.f()

    return continuation
end

function ConflictCard.getLevel(conflictName)
    local conflict = ConflictCard[conflictName]
    assert(conflict, conflictName)
    return conflict.level
end

function ConflictCard.isBehindTheWall(conflictName)
    local behindTheWallConflictCards = {
        siegeOfArrakeen = "arrakeen",
        seizeSpiceRefinery = "spiceRefinery",
        secureImperialBasin = "imperialBasin",
        battleForImperialBasin = "imperialBasin",
        battleForArrakeen = "arrakeen",
        battleForSpiceRefinery = "spiceRefinery",
    }
    return Helper.isElementOf(conflictName, Helper.getKeys(behindTheWallConflictCards))
end

return ConflictCard
