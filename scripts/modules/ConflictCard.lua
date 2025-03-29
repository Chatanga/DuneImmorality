local Module = require("utils.Module")
local Helper = require("utils.Helper")

-- Exceptional Immediate require for the sake of aliasing.
local CardEffect = require("CardEffect")

local PlayBoard = Module.lazyRequire("PlayBoard")
local Action = Module.lazyRequire("Action")

-- Function aliasing for a more readable code.
local spice = CardEffect.spice
local water = CardEffect.water
local solari = CardEffect.solari
local troop = CardEffect.troop
local intrigue = CardEffect.intrigue
local trash = CardEffect.trash
local influence = CardEffect.influence
local vp = CardEffect.vp
local control = CardEffect.control
local spy = CardEffect.spy
local deepCoverSpy = CardEffect.deepCoverSpy
local contract = CardEffect.contract
local choice = CardEffect.choice
local optional = CardEffect.optional

local ConflictCard = {
    skirmishA = {level = 1, uprising = true, objective = "crysknife", rewards = {{influence(1)}, {intrigue(1), spice(1)}, {spice(1)}}},
    skirmishB = {level = 1, uprising = true, objective = "ornithopter", rewards = {{intrigue(1), solari(1)}, {intrigue(1), solari(2)}, {intrigue(1)}}},
    skirmishC = {level = 1, uprising = true, objective = "muadDib", rewards = {{solari(2)}, {solari(3)}, {solari(2)}}},
    skirmishD = {level = 1, bloodlines = true, objective = "joker", rewards = {{}, {water(1), solari(1)}, {solari(2)}}},

    choamSecurity = {level = 2, uprising = true, objective = "crysknife", rewards = {{influence(1, "spacingGuild"), contract(1), troop(1)}, {water(1), solari(2), troop(2)}, {intrigue(1), troop(1)}}},
    spiceFreighters = {level = 2, uprising = true, objective = "crysknife", rewards = {{ influence(1), optional({spice(-3), vp(1)})}, {water(1), spice(1), troop(1)}, {spice(1), troop(1)}}},
    siegeOfArrakeen = {level = 2, uprising = true, objective = "ornithopter", rewards = {{control("arrakeen"), solari(2), troop(2)}, {solari(4), troop(1)}, {solari(3)}}},
    seizeSpiceRefinery = {level = 2, uprising = true, objective = "crysknife", rewards = {{control("spiceRefinery"), spy(1), spice(2)}, {intrigue(1), spice(1), troop(1)}, {spice(2)}}},
    testOfLoyalty = {level = 2, uprising = true, objective = "ornithopter", rewards = {{influence(1, "emperor"), spy(1), solari(2)}, {solari(4), troop(1)}, {solari(3)}}},
    shadowContest = {level = 2, uprising = true, objective = "ornithopter", rewards = {{influence(1, "beneGesserit"), intrigue(1)}, {intrigue(1), spice(1), troop(1)}, {spice(1), troop(1)}}},
    secureImperialBasin = {level = 2, uprising = true, objective = "muadDib", rewards = {{control("imperialBasin"), spice(2), troop(1)}, {water(2), troop(1)}, {water(1), troop(1)}}},
    protectTheSietches = {level = 2, uprising = true, objective = "muadDib", rewards = {{influence(1, "fremen"), water(1), troop(1)}, {spice(3), troop(1)}, {spice(2)}}},
    tradeDispute = {level = 2, uprising = true, objective = "muadDib", rewards = {{contract(1), water(1), trash(1)}, {water(1), spice(1), trash(1)}, {water(1), troop(1)}}},
    stormsInTheSouth = {level = 2, bloodlines = true, objective = "joker", rewards = {{deepCoverSpy(1), spy(2), spice(2)}, {intrigue(2), solari(2)}, {intrigue(1), solari(2)}}},

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

---@param color PlayerColor
---@param conflictName string
---@param rank integer
---@param doubleRewards boolean
---@param postAction? fun(): nil
---@return Continuation
function ConflictCard.collectReward(color, conflictName, rank, doubleRewards, postAction)
    assert(Helper.isInRange(1, 3, rank))
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
                continuation.run()
            end
        end)
    end

    functionHolder.f()

    return continuation
end

---@param conflictName string
---@return integer
function ConflictCard.getLevel(conflictName)
    local conflict = ConflictCard[conflictName]
    assert(conflict, conflictName)
    return conflict.level
end

---@param conflictName string
---@return boolean
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
