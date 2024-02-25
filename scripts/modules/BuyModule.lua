core = require("Core")

i18n = require("i18n")
require("locales")

constants = require("Constants")

helperModule = require("HelperModule")

GetDeckOrCard = helperModule.GetDeckOrCard
GetDeckOrCardFromGUID = helperModule.GetDeckOrCardFromGUID

local buyModule = {}

zone_deck_imperium = constants.zone_deck_imperium
zone_deck_tleilaxu = constants.zone_deck_tleilaxu

_ = core.registerLoadablePart(function(_)
    scriptZone_middleTrack_research = getObjectFromGUID("60a0fd")
end)

function buyModule.Buy(zone, pColor, pos, activateButton, buyTleilaxu)
    buyTleilaxu = buyTleilaxu or false
    local card = helperModule.GetDeckOrCard(zone)
    if card then
        self.clearButtons()
        Wait.time(function() activateButton() end, 2)

        if pColor ~= "Red" and pColor ~= "Blue" and pColor ~= "Green" and pColor ~=
            "Yellow" then
            broadcastToColor(i18n("noTouch"), pColor, {1, 0.011765, 0})
        else
            local enoughSpecimen = false
            if buyTleilaxu then
                local countSpecimen = 0
                local price = getObjectFromGUID("4a3e76").call("getTleilaxuCardPrice", card)
                for _, troop in ipairs(getObjectFromGUID("f5de09").getObjects()) do -- comptage Spécimen
                    if troop.hasTag("Troop") and troop.hasTag(pColor) then
                        countSpecimen = countSpecimen + 1
                    end
                end
                if price > countSpecimen then
                    broadcastToColor(i18n("notEnoughSpecimen"), pColor, "Red")
                else
                    enoughSpecimen = true

                    local leaderName = helperModule.getLeaderName(pColor)
                    Wait.time(function()
                        params = {osef = "", color = pColor, silent = true}
                        getObjectFromGUID("d5c2db").Call("RemoveSpecimenCall",
                                                         params)
                    end, 0.3, price)
                    local specimen = i18n("specimens")
                    if price == 1 then
                        specimen = i18n("specimen")
                    end
                    broadcastToAll(i18n("acquiredTleilaxu"):format(leaderName, price, specimen), pColor)
                end
            end

            if not buyTleilaxu or enoughSpecimen then

                card.setPosition(constants.players[pColor].pos_discard)

                local objs = scriptZone_middleTrack_research.getObjects()
                local middleSearch = false
                for _, item in ipairs(objs) do
                    if item.hasTag(pColor) then
                        middleSearch = true
                    end
                end

                local spaceportCheck = helperModule.hasTech(pColor, "spaceport")

                if buyTleilaxu and middleSearch or spaceportCheck then
                    Player[pColor].showConfirmDialog(
                        i18n("dialogCardAbove"),
                        function(player_color)
                            local player = constants.players[pColor]
                            local deckorcard = GetDeckOrCard(player.discardZone)
                            local topOfPlayerDeck = player.drawDeckZone.getPosition()
                            if deckorcard.type == 'Card' then
                                deckorcard.setPositionSmooth(topOfPlayerDeck, false, false)
                                deckorcard.setRotationSmooth({0, 180, 180}, false, false)
                            else
                                local nb_cards = #deckorcard.getObjects()
                                deckorcard.takeObject({
                                    position = topOfPlayerDeck,
                                    rotation = {0, 180, 180},
                                    index = nb_cards - 1
                                })
                            end
                        end)
                end

                local params = {position = pos, rotation = {0, 180, 0}}
                local zone_deck = zone_deck_imperium
                if buyTleilaxu then
                    zone_deck = zone_deck_tleilaxu
                end
                GetDeckOrCardFromGUID(zone_deck).takeObject(params)
            end
        end
    end
end

return buyModule