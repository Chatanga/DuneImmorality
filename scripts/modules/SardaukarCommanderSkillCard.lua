local Helper = require("utils.Helper")

-- Exceptional Immediate require for the sake of aliasing.
local CardEffect = require("CardEffect")

-- Function aliasing for a more readable code.
local persuasion = CardEffect.persuasion
local sword = CardEffect.sword
local spice = CardEffect.spice
local troop = CardEffect.troop
local agentInGreenSpace = CardEffect.agentInGreenSpace
local emperorSuperFriendship = CardEffect.emperorSuperFriendship

local SardaukarCommanderSkillCard = {
    -- bloodlines
    charismatic = {reveal = {persuasion(1)}},
    desperate = {combat = {'trash --> sword(3)'}},
    canny = {combat = {sword(agentInGreenSpace(2))}},
    driven = {reveal = {spice(1)}},
    loyal = {combat = {sword(emperorSuperFriendship(2))}},
    hardy = {reveal = {troop(1)}},
}

function SardaukarCommanderSkillCard._resolveCard(cardName)
    local cardInfo = SardaukarCommanderSkillCard[cardName]
    assert(cardInfo, "Unknown card: " .. tostring(cardName))
    cardInfo.name = cardName
    return cardInfo
end

function SardaukarCommanderSkillCard.unused_getDetails(skillCard)
    return SardaukarCommanderSkillCard._resolveCard(skillCard)
end

function SardaukarCommanderSkillCard.evaluateReveal(color, skillCardNames)
    local skillCards = Helper.mapValues(skillCardNames, SardaukarCommanderSkillCard._resolveCard)

    local result = {}

    local context = {
        color = color,
        -- This mock up is enough since reveal effects only cover persuasion and strength (or other resources).
        player = {
            resources = function (_, resourceName, amount)
                result[resourceName] = (result[resourceName] or 0) + amount
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

    for cardName, card in ipairs(skillCards) do
        if card.reveal then
            context.card = card
            context.cardName = cardName
            for _, effect in ipairs(card.reveal) do
                CardEffect.evaluate(context, effect)
            end
        end
    end

    return result
end

function SardaukarCommanderSkillCard.evaluateCombat(color, skillCardNames)
    local skillCards = Helper.mapValues(skillCardNames, SardaukarCommanderSkillCard._resolveCard)

    local result = {}

    local context = {
        color = color,
        player = {
            resources = function (_, resourceName, amount)
                result[resourceName] = (result[resourceName] or 0) + amount
            end
        }
    }

    for cardName, card in ipairs(skillCards) do
        if card.combat then
            context.card = card
            context.cardName = cardName
            for _, effect in ipairs(card.combat) do
                CardEffect.evaluate(context, effect)
            end
        end
    end

    return result.strength
end

return SardaukarCommanderSkillCard
