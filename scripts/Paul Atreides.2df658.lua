leader = require("Leader")

helperModule = require("HelperModule")

_ = require("Core").registerLoadablePart(function(savedData)
    leader.init(onClaim, savedData)
end)

function onClaim(color)
    createPrescienceButton()
end

function createPrescienceButton()
    self.createButton({
        click_function = "prescience",
        function_owner = self,
        label = i18n("prescienceButton"),
        position = {-0.8, 0.200000002980232, 0.400000005960464},
        scale = {0.75, 1, 0.75},
        width = 500,
        height = 150,
        font_size = 85,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {1, 1, 1, 1},
        tooltip = i18n("prescienceTooltip")
    })
end

function prescience(_, color)
    if color == leader.claimed then
        local leaderName = helperModule.getLeaderName(color)
        local cardOrDeck = helperModule.GetDeckOrCard(constants.players[color].drawDeckZone)

        if cardOrDeck == nil then
            broadcastToColor(i18n("prescienceVoid"), color, "Purple")
        elseif cardOrDeck.type == "Card" then
            broadcastToAll(i18n("prescienceUsed"):format(leaderName), color)
            broadcastToColor(i18n("prescienceManual"), color, "Purple")
        else
            cardOrDeck.Container.search(color, 1)
            broadcastToAll(i18n("prescienceUsed"):format(leaderName), color)
        end
    else
        broadcastToColor(i18n("noTouch"), color, color)
    end
end
