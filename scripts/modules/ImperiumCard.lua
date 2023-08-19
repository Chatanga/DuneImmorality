local ImperiumCard = {}

--[[

access = {
    spaceType = emperor|spacingGuild|beneGesserit|fremen|landsraadAndIx|cities|choamAndDesert,
    infiltration = true|false
}

]]--

--[[
function ImperiumCard.isGraft(card)
end

function ImperiumCard.getAgentAccesses(card, grafted)
end

function ImperiumCard.getAgentEffect(color, graftedCardIfAny)
end

function ImperiumCard.getRevealEffect(color)
end
]]--

function ImperiumCard.getFixedRevealPersuasion(color, card)
end

function ImperiumCard.getFixedRevealStrength(color, card)
end

function ImperiumCard.getPersuasionCost(card)
end

function ImperiumCard.getSpecimenCost(card)
end

function ImperiumCard.getAcquisitionBonus(card)
end

return ImperiumCard
