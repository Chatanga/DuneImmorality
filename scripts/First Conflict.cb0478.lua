i18n = require("i18n")
require("locales")

constants = require("Constants")

helperModule = require("HelperModule")

_ = require("Core").registerLoadablePart(function()
    self.interactable = false
end)

function ConflictButton()
    self.createButton({
        click_function = "RevealConflict",
        function_owner = self,
        label = i18n("revealFirstConflictButton"),
        position = helperModule.correctAnchorPosition({0, 0.6, 0}, {1.37866032, 0.165157527, 1.34989369}),
        scale = {0.3, 0.3, 0.4},
        width = 1800,
        height = 1300,
        font_size = 400,
        color = {0.5, 0, 0., 0.75},
        font_color = {0.8, 0.8, 0.8, 1},
        tooltip = i18n("revealFirstConflictTooltip")
    })
end

function RevealConflict()
    local players = getObjectFromGUID("4a3e76").call("getPlayersBasedOnHotseat")
    for _, color in pairs(players) do
        if not helperModule.getLeader(color) then
            broadcastToAll(i18n("chooseLeaderFirst"), 'Orange')
            return 1
        end
    end
    local conflict_zone = getObjectFromGUID("07e239")
    local objects = conflict_zone.getObjects()
    if objects ~= nil then
        for _, obj in ipairs(objects) do
            if obj.type == 'Deck' then
                obj.takeObject({ position = constants.getLandingPosition(self), top = true, flip = true })
            end
        end

        -- Utile ?
        local makersAndRecallToken = getObjectFromGUID("fb41e2")
        makersAndRecallToken.setPositionSmooth(constants.marker_positions.round_start, false, false)

        self.destruct()
    end
end