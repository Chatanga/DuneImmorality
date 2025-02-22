local Module = require("utils.Module")
local Helper = require("utils.Helper")

-- Exceptional Immediate require for the sake of aliasing.
local CardEffect = require("CardEffect")

local PlayBoard = Module.lazyRequire("PlayBoard")
local Types = Module.lazyRequire("Types")

-- Function aliasing for a more readable code.
local persuasion = CardEffect.persuasion
local sword = CardEffect.sword
local water = CardEffect.water
local solari = CardEffect.solari
local troop = CardEffect.troop
local intrigue = CardEffect.intrigue
local trash = CardEffect.trash
local influence = CardEffect.influence
local vp = CardEffect.vp
local draw = CardEffect.draw
local spy = CardEffect.spy
local deepCoverSpy = CardEffect.deepCoverSpy
local contract = CardEffect.contract
local perSwordCard = CardEffect.perSwordCard
local choice = CardEffect.choice
local seat = CardEffect.seat
local command = CardEffect.command

local TechCard = {
    -- ix
    windtraps = {cost = 2, hagal = true, acquireBonus = {water(1)}},
    detonationDevices = {cost = 3, hagal = true},
    memocorders = {cost = 2, hagal = true, acquireBonus = {influence(1)}},
    flagship = {cost = 8, hagal = true, acquireBonus = {vp(1)}},
    spaceport = {cost = 5, hagal = false, acquireBonus = {draw(2)}},
    artillery = {cost = 1, hagal = false, postReveal = {sword(perSwordCard(1))}},
    holoprojectors = {cost = 3, hagal = false},
    restrictedOrdnance = {cost = 4, hagal = false, preReveal = {sword(seat(4))}},
    shuttleFleet = {cost = 6, hagal = true, acquireBonus = {choice(2, {influence(1, "emperor"), influence(1, "spacingGuild"), influence(1, "beneGesserit"), influence(1, "fremen")})}},
    spySatellites = {cost = 4, hagal = true},
    disposalFacility = {cost = 3, hagal = false, acquireBonus = {trash(1)}},
    chaumurky = {cost = 4, hagal = true, acquireBonus = {intrigue(2)}},
    sonicSnoopers = {cost = 2, hagal = true, acquireBonus = {intrigue(1)}},
    trainingDrones = {cost = 3, hagal = true},
    troopTransports = {cost = 2, hagal = true},
    holtzmanEngine = {cost = 6, hagal = true},
    minimicFilm = {cost = 2, hagal = false, preReveal = {persuasion(1)}},
    invasionShips = {cost = 5, hagal = true, acquireBonus = {troop(4)}},
    -- bloodlines
    trainingDepot = {cost = 1, postReveal = {sword(command(2))}},
    geneLockedVault = {cost = 2, hagal = true},
    glowglobes = {cost = 2, hagal = true, acquireBonus = {influence(1)}},
    planetaryArray = {cost = 2, hagal = false},
    servoReceivers = {cost = 2, hagal = true},
    deliveryBay = {cost = 3, hagal = true, acquireBonus = {draw(1)}, postReveal = {solari(command(2))}},
    plasteelBlades = {cost = 3, hagal = false, acquireBonus = {solari(4)}},
    suspensorSuits = {cost = 3, hagal = false},
    rapidDropships = {cost = 4, hagal = true, acquireBonus = {troop(2)}},
    selfDestroyingMessages = {cost = 4, hagal = true, acquireBonus = {intrigue(2)}, preReveal = {persuasion(1)}},
    navigationChamber = {cost = 5, hagal = false, acquireBonus = {influence(1)}},
    sardaukarHighCommand = {cost = 7, hagal = true, acquireBonus = {vp(1)}},
    forbiddenWeapons = {cost = 2, hagal = false, acquireBonus = {troop(1)}},
    advancedDataAnalysis = {cost = 3, hagal = false},
    ornithopterFleet = {cost = 4, hagal = true, acquireBonus = {troop(2)}},
    panopticon = {cost = 5, hagal = true, postReveal = {spy(1), troop(1)}},
    spyDrones = {cost = 5, hagal = true, acquireBonus = {deepCoverSpy(2)}},
    choamTransports = {cost = 6, hagal = false, acquireBonus = {contract(1)}},
}

---@alias TechCardDetails {
--- name: string,
--- cost: integer,
--- hagal: boolean,
--- acquireBonus: function[],
--- preReveal: function[],
--- postReveal: function[] }

---@param techCard Card
---@return TechCardDetails
function TechCard._resolveCard(techCard)
    assert(techCard)
    local cardName = Helper.getID(techCard)
    local cardInfo = TechCard[cardName]
    assert(cardInfo, "Unknown card (empty name usually means that the card is stacked with another): " .. tostring(cardName))
    cardInfo.name = cardName
    return cardInfo
end

---@param techCard Card
---@return TechCardDetails
function TechCard.getDetails(techCard)
    return TechCard._resolveCard(techCard)
end

---@param techCard Card
---@return integer
function TechCard.getCost(techCard)
    return TechCard._resolveCard(techCard).cost
end

---@param techCard Card
---@return boolean
function TechCard.isHagal(techCard)
    return TechCard._resolveCard(techCard).hagal
end

---@param color PlayerColor
---@return TechRevealContributions
function TechCard.evaluatePreReveal(color)
    return TechCard._evaluateReveal(color, true)
end

---@param color PlayerColor
---@return TechRevealContributions
function TechCard.evaluatePostReveal(color, oldContributions)
    return TechCard._evaluateReveal(color, false, oldContributions)
end

---@alias TechRevealContributions {
--- spice: integer,
--- water: integer,
--- solari: integer,
--- persuasion: integer,
--- strength: integer,
--- intrigues: integer,
--- troops: integer,
--- fighters: integer,
--- negotiators: integer,
--- tanks: integer }

---@param color PlayerColor
---@param preElsePost boolean
---@param oldContributions? TechRevealContributions
---@return TechRevealContributions
function TechCard._evaluateReveal(color, preElsePost, oldContributions)
    local contributions = {}

    local context = {
        oldContributions = oldContributions,
        color = color,
        -- This mock up is enough since reveal effects only cover persuasion and strength (or other resources).
        player = {
            resources = function (_, resourceName, amount)
                contributions[resourceName] = (contributions[resourceName] or 0) + amount
            end,

            drawIntrigues = function (_, amount)
                contributions.intrigues = (contributions.intrigues or 0) + amount
            end,

            troops = function (_, from, to, amount)
                if from == "supply" then
                    if to == "garrison" then
                        contributions.troops = (contributions.troops or 0) + amount
                    elseif to == "combat" then
                        contributions.fighters = (contributions.fighters or 0) + amount
                    elseif to == "negotiation" then
                        contributions.negotiators = (contributions.negotiators or 0) + amount
                    elseif to == "tanks" then
                        contributions.specimens = (contributions.specimens or 0) + amount
                    end
                end
            end
        },
    }

    for _, techCard in ipairs(PlayBoard.getAllTechs(color)) do
        local details = TechCard._resolveCard(techCard)
        local effects = preElsePost and details.preReveal or details.postReveal
        if effects then

            -- TODO Doesn't matter?
            context.card = techCard
            context.cardName = Helper.getID(techCard)

            for _, effect in ipairs(effects) do
                CardEffect.evaluate(context, effect)
            end
        end
    end

    return contributions
end

---@param color PlayerColor
---@param techCard Card
function TechCard.applyBuyEffect(color, techCard)
    assert(Types.isPlayerColor(color))
    assert(techCard)

    local details = TechCard.getDetails(techCard)
    if details.acquireBonus then
        local context = {
            color = color,
            player = PlayBoard.getLeader(color),

            -- TODO Doesn't matter?
            card = techCard,
            cardName = Helper.getID(techCard),
        }

        for _, effect in ipairs(details.acquireBonus) do
            CardEffect.evaluate(context, effect)
        end
    end

    if details.name == "ornithopterFleet" then
        for _, objective in ipairs({ "muadDib", "crysknife" }) do
            local position = PlayBoard.getObjectiveStackPosition(color, objective)
            local tag = Helper.toPascalCase(objective, "ObjectiveToken")
            local hitTokens = PlayBoard.collectObjectiveTokens(position, tag)
            for _, hitToken in ipairs(hitTokens) do
                hitToken.destruct()
                PlayBoard.getLeader(color).gainObjective(color, "ornithopter", true)
            end
        end
    end
end

return TechCard
