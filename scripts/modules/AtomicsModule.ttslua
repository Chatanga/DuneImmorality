core = require("Core")

i18n = require("i18n")
require("locales")

helperModule = require("HelperModule")

constants = require("Constants")

GetDeckOrCard = helperModule.GetDeckOrCard
GetDeckOrCardFromGUID = helperModule.GetDeckOrCardFromGUID

ImperiumRow = constants.imperiumRow

zone_deck_imperium = constants.zone_deck_imperium

pos_trash = constants.pos_trash_lower

local atomicsModule = {}

_ = core.registerLoadablePart(function(_)
    board_display_leaders = getObjectFromGUID("662ced")
end)

function atomicsModule:homeButton()

    self.clearButtons()
    self.createButton({
        ['click_function'] = 'nukeConfirm',
        ['label'] = i18n('atomics'),
        ['function_owner'] = self,
        ['position'] = {0, 0.1, 0},
        ['rotation'] = {0, 0, 0},
        ['width'] = 700,
        ['height'] = 700,
        ['scale'] = {3, 3, 3},
        ['font_size'] = 300,
        ['font_color'] = {1, 1, 1, 100},
        ['color'] = {0, 0, 0, 0}
    })

end

function nukeConfirm(obj, color)

    if obj.hasTag(color) then

        obj.clearButtons()
        obj.createButton({
            ['click_function'] = 'doNothing',
            ['label'] = i18n("atomicsConfirm"),
            ['function_owner'] = obj,
            ['position'] = {0, 0.2, -2},
            ['rotation'] = {0, 0, 0},
            ['width'] = 0,
            ['height'] = 0,
            ['scale'] = {3, 3, 3},
            ['font_size'] = 300,
            ['font_color'] = {1, 0, 0, 100},
            ['color'] = {0, 0, 0, 0}
        })
        obj.createButton({
            ['click_function'] = 'nukeImperiumRow',
            ['label'] = i18n('yes'),
            ['function_owner'] = obj,
            ['position'] = {-4, 0.2, 1},
            ['rotation'] = {0, 0, 0},
            ['width'] = 500,
            ['height'] = 300,
            ['scale'] = {3, 3, 3},
            ['font_size'] = 300,
            ['font_color'] = {1, 1, 1},
            ['color'] = "Green"
        })
        obj.createButton({
            ['click_function'] = 'cancelChoice',
            ['label'] = i18n('no'),
            ['function_owner'] = obj,
            ['position'] = {4, 0.2, 1},
            ['rotation'] = {0, 0, 0},
            ['width'] = 500,
            ['height'] = 300,
            ['scale'] = {3, 3, 3},
            ['font_size'] = 300,
            ['font_color'] = {1, 1, 1},
            ['color'] = "Red"
        })

    else

        broadcastToColor(i18n("noTouch"), color, color)

    end

end

function cancelChoice(obj) atomicsModule.homeButton(obj) end

function nukeImperiumRow(obj, color)
    local t = 0
    obj.clearButtons()
    local soundEnabled = board_display_leaders.call("isSoundEnabled")
    if soundEnabled then
        t = 2
        MusicPlayer.setCurrentAudioclip({
            url = "http://cloud-3.steamusercontent.com/ugc/2044115565050309958/03DC77BB02B42FC405B134BCC0B0A393056F1046/",
            title = "Explosion"
        })
    end
    Wait.time(function()
        for i = 1, 5, 1 do
            local card = GetDeckOrCardFromGUID(ImperiumRow[i].zoneGuid)
            card.setPositionSmooth(pos_trash, false, false)

            local params = {position = ImperiumRow[i].pos, rotation = {0, 180, 0}}

            GetDeckOrCardFromGUID(zone_deck_imperium).takeObject(params)

        end

        obj.destruct()

        local leaderName = helperModule.getLeaderName(color)
        broadcastToAll(leaderName .. i18n("atomicsUsed"), color)
    end, t)
end

function doNothing() end

return atomicsModule
