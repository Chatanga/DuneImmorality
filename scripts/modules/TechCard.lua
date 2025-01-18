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
}

function TechCard._resolveCard(card)
    assert(card)
    local cardName = Helper.getID(card)
    local cardInfo = TechCard[cardName]
    assert(cardInfo, "Unknown card (empty name usually means that the card is stacked with another): " .. tostring(cardName))
    cardInfo.name = cardName
    return cardInfo
end

function TechCard.getDetails(techCard)
    return TechCard._resolveCard(techCard)
end

function TechCard.getCost(techCard)
    return TechCard._resolveCard(techCard).cost
end

function TechCard.isHagal(techCard)
    return TechCard._resolveCard(techCard).hagal
end

function TechCard.evaluatePreReveal(color)
    return TechCard._evaluateReveal(color, true)
end

function TechCard.evaluatePostReveal(color, oldContributions)
    return TechCard._evaluateReveal(color, false, oldContributions)
end

function TechCard._evaluateReveal(color, preElsePost, oldContributions)
    local result = {}

    local context = {
        oldContributions = oldContributions,
        color = color,
        techCards = Helper.mapValues(PlayBoard.getAllTechs(color), TechCard._resolveCard),
        -- This mock up is enough since reveal effects only cover persuasion and strength (or other resources).
        player = {
            resources = function (_, resourceName, amount)
                result[resourceName] = (result[resourceName] or 0) + amount
            end,

            drawIntrigues = function (_, amount)
                result.intrigues = (result.intrigues or 0) + amount
            end,

            troops = function (_, from, to, amount)
                if from == "supply" then
                    if to == "garrison" then
                        result.troops = (result.troops or 0) + amount
                    elseif to == "combat" then
                        result.fighters = (result.fighters or 0) + amount
                    elseif to == "negotiation" then
                        result.negotiators = (result.negotiators or 0) + amount
                    elseif to == "tanks" then
                        result.specimens = (result.specimens or 0) + amount
                    end
                end
            end
        }
    }

    for cardName, card in pairs(context.techCards) do
        local effects = preElsePost and card.preReveal or card.postReveal
        if effects then
            context.card = card
            context.cardName = cardName
            for _, effect in ipairs(effects) do
                CardEffect.evaluate(context, effect)
            end
        end
    end

    return result
end

function TechCard.applyBuyEffect(color, techCard)
    assert(Types.isPlayerColor(color))
    assert(techCard)

    local details = TechCard.getDetails(techCard)
    local bonus = details.acquireBonus
    if bonus then
        local context = {
            color = color,
            player = PlayBoard.getLeader(color),
            cardName = Helper.getID(techCard),
            card = techCard,
        }

        for _, bonusItem in ipairs(bonus) do
            CardEffect.evaluate(context, bonusItem)
        end
    end
end

return TechCard
