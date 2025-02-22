local Helper = require("utils.Helper")

-- Exceptional Immediate require for the sake of aliasing.
local CardEffect = require("CardEffect")

-- Function aliasing for a more readable code.
local todo = CardEffect.todo
local persuasion = CardEffect.persuasion
local sword = CardEffect.sword
local spice = CardEffect.spice
local troop = CardEffect.troop
local opponentHasSandworm = CardEffect.opponentHasSandworm
local agentInGreenSpace = CardEffect.agentInGreenSpace
local emperorSuperFriendship = CardEffect.emperorSuperFriendship

---@class SkillCardInfo: CardInfo
---@field reveal CardEffect[]
---@field combat CardEffect[]

local SardaukarCommanderSkillCard = {
    -- bloodlines
    charismatic = {reveal = {persuasion(1)}},
    desperate = {combat = {todo('trash --> sword(3)')}},
    fierce = {combat = {sword(1), sword(opponentHasSandworm(1))}},
    canny = {combat = {sword(agentInGreenSpace(2))}},
    driven = {reveal = {spice(1)}},
    loyal = {combat = {sword(emperorSuperFriendship(2))}},
    hardy = {reveal = {troop(1)}},
}

---@param cardName string
---@return SkillCardInfo
function SardaukarCommanderSkillCard._resolveCard(cardName)
    local cardInfo = SardaukarCommanderSkillCard[cardName]
    assert(cardInfo, "Unknown card: " .. tostring(cardName))
    cardInfo.name = cardName
    return cardInfo
end

---@param cardName string
---@return SkillCardInfo
function SardaukarCommanderSkillCard.getDetails(cardName)
    return SardaukarCommanderSkillCard._resolveCard(cardName)
end

---@param color PlayerColor
---@param skillCardNames string[]
---@return table
function SardaukarCommanderSkillCard.evaluateReveal(color, skillCardNames)
    local skillCards = Helper.mapArrayValues(skillCardNames, SardaukarCommanderSkillCard._resolveCard)

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

---@param color PlayerColor
---@param skillCardNames string[]
---@return integer
function SardaukarCommanderSkillCard.evaluateCombat(color, skillCardNames)
    local skillCards = Helper.mapArrayValues(skillCardNames, SardaukarCommanderSkillCard._resolveCard)

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
