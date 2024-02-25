i18n = require("i18n")
require("locales")

constants = require("Constants")

helperModule = require("HelperModule")

GetDeckOrCard = helperModule.GetDeckOrCard
GetDeckOrCardFromGUID = helperModule.GetDeckOrCardFromGUID

_ = require("Core").registerLoadablePart(function()
    self.interactable = false

    counter_VP = {
        ["Red"] = getObjectFromGUID("e0ed4b"),
        ["Blue"] = getObjectFromGUID("121bb6"),
        ["Green"] = getObjectFromGUID("caaba4"),
        ["Yellow"] = getObjectFromGUID("99a860")
    }

    Zone_foldspace = getObjectFromGUID("6b62e0")
    Zone_arrakis = getObjectFromGUID("cbcd9a")
    Zone_tsmf = getObjectFromGUID("c087d2")
    deck_imperium = constants.zone_deck_imperium

    TSMF_point = getObjectFromGUID("43c7b5")

    activateButtons()
end)

function onLocaleChange()
    self.clearButtons()
    activateButtons()
end

function activateButtons()
    self.createButton({
        click_function = "acquireFoldspace",
        function_owner = self,
        label = i18n("acquireButton"),
        position = helperModule.correctAnchorPosition({0, 2, 0}, {1.37866032, 0.165157527, 1.34989369}),
        scale = {0.3, 0.3, 0.4},
        width = 1600,
        height = 400,
        font_size = 400,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {1, 1, 1, 1}
    })

    self.createButton({
        click_function = "acquireArrakis",
        function_owner = self,
        label = i18n("acquireButton"),
        position = helperModule.correctAnchorPosition({1.85, 2.1, 0}, {1.37866032, 0.165157527, 1.34989369}),
        scale = {0.3, 0.3, 0.4},
        width = 1600,
        height = 400,
        font_size = 400,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {1, 1, 1, 1}
    })

    self.createButton({
        click_function = "acquireTSMF",
        function_owner = self,
        label = i18n("acquireButton"),
        position = helperModule.correctAnchorPosition({3.70, 2.3, 0}, {1.37866032, 0.165157527, 1.34989369}),
        scale = {0.3, 0.3, 0.4},
        width = 1600,
        height = 400,
        font_size = 400,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {1, 1, 1, 1}
    })

end

function acquireFoldspace(object, pColor)
    local deck_foldspace = helperModule.GetDeckOrCard(Zone_foldspace)

    if deck_foldspace == nil then
        broadcastToColor(
            i18n("noFoldspaceLeft"), pColor,
            {1, 0.011765, 0})
    else
        moveCardFromDeck(pColor, deck_foldspace)
    end
end

function acquireArrakis(object, pColor)
    local deck_liaison = helperModule.GetDeckOrCard(Zone_arrakis)

    if deck_liaison == nil then
        broadcastToColor(i18n("noLiaisonLeft"), pColor,
                         {1, 0.011765, 0})
    else
        moveCardFromDeck(pColor, deck_liaison)
    end
end

function acquireTSMF(object, pColor)
    local deck_TSMF = helperModule.GetDeckOrCard(Zone_tsmf)

    if deck_TSMF== nil then
        broadcastToColor(i18n("noTSMFLeft"), pColor, {1, 0.011765, 0})
    else
        moveCardFromDeck(pColor, deck_TSMF, true)
    end
end

function moveCardFromDeck(pColor, deck, scoreToMove)

    scoreToMove = scoreToMove or false

    self.clearButtons()
    Wait.time(function() activateButtons() end, 1)

    if pColor ~= "Red" and pColor ~= "Blue" and pColor ~= "Green" and pColor ~=
        "Yellow" then
        broadcastToColor(i18n("noTouch"), pColor, {1, 0.011765, 0})
    else

        if scoreToMove == true then
            helperModule.grantScoreTokenFromBag(pColor, TSMF_point)
        end

        if deck.type == "Deck" then
            deck.takeObject({
                position = constants.players[pColor].pos_discard,
                rotation = {0, 180, 0},
                smooth = false
            })
        elseif deck.type == "Card" then
            deck.setPosition(constants.players[pColor].pos_discard)
        end

        local spaceportCheck = helperModule.hasTech(pColor, "spaceport")

        if spaceportCheck then
            Player[pColor].showConfirmDialog(
                i18n("dialogCardAbove"),
                function(player_color)
                    local player = constants.players[pColor]
                    local deckorcard = GetDeckOrCard(player.discardZone)
                    local topOfPlayerDeck = player.drawDeckZone.getPosition()
                    if deckorcard.type=='Card' then
                        deckorcard.setPositionSmooth(topOfPlayerDeck, false, false)
                        deckorcard.setRotationSmooth({0,180,180}, false, false)
                    else
                        local nb_cards = #deckorcard.getObjects()
                        deckorcard.takeObject({
                            position          = topOfPlayerDeck,
                            rotation          = {0,180,180},
                            index             = nb_cards-1
                        })
                    end
                end)
        end

    end
end