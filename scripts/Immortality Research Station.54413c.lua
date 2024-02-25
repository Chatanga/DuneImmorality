i18n = require("i18n")
require("locales")

constants = require("Constants")

helperModule = require("HelperModule")

boardCommonModule = require("BoardCommonModule")

DrawOne = helperModule.DrawOne

_ = require("Core").registerLoadablePart(function()

    scriptZone_endTrack_research = getObjectFromGUID("da08cd")

    self.createButton({
        click_function = "ResearchStation",
        function_owner = self,
        label = "pay & get",
        position = {0.9, 0.15, 0.7},
        scale = {0.5, 0.5, 0.5},
        width = 900,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
end)

function ResearchStation(_, color)

    if boardCommonModule.CheckAgentAndPlayer(color, ResearchStation_zone) then

        local objs = scriptZone_endTrack_research.getObjects()
        local maxSearch = false
        for _, item in ipairs(objs) do
            if item.hasTag(color) then maxSearch = true end
        end

        local leaderName = helperModule.getLeaderName(color)
        local waterObj = constants.players[color].water

        if waterObj.call("collectVal") < 2 then
            broadcastToColor(i18n("noWater"), color, color)
        else
            for i = 1, 2, 1 do waterObj.call("decrementVal") end

            local numberToDraw = 2
            local researchMaxed = ""
            local advanceResearch = i18n("advanceResearch")

            if maxSearch then
                numberToDraw = 3
                researchMaxed = i18n("researchMaxed")
                advanceResearch = ""
            end

            local enoughCards = helperModule.isDeckContainsEnough(color, numberToDraw)

            if not enoughCards then

                broadcastToAll(
                    i18n("researchStationPayOnly"):format(leaderName) ..
                        advanceResearch .. ".", color)

                broadcastToAll(i18n("isDecidingToDraw"):format(leaderName),
                        "Pink")
                local card = i18n("cards")
                if numberToDraw == 1 then
                    card = i18n("card")
                end
                Player[color].showConfirmDialog(
                    i18n("warningBeforeDraw"):format(numberToDraw, card),
                    function(player_color)

                        broadcastToAll(i18n("researchStationDraw"):format(
                                           leaderName, numberToDraw) ..
                                           researchMaxed .. ".", color)

                        for i = 0, numberToDraw - 1, 1 do
                            Wait.time(function()
                                DrawOne(_, color)
                            end, i)
                        end
                    end)
            else
                broadcastToAll(i18n("researchStation"):format(leaderName,
                                                              numberToDraw) ..
                                   advanceResearch .. researchMaxed .. ".", color)

                for i = 0, numberToDraw - 1, 1 do
                    Wait.time(function() DrawOne(_, color) end, i)
                end
            end
        end
    end
end