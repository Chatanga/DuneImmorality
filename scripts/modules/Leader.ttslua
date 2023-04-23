local leader = {}

constants = require("Constants")

i18n = require("i18n")
require("locales")

leader.claimed = nil

leader.onClaimCallback = nil

function leader.init(onClaimCallback, savedData)
    leader.onClaimCallback = onClaimCallback
    if savedData ~= '' then
        local state = JSON.decode(savedData)
        leader.claimed = state.claimed
    else
        leader.createClaimButton()
    end
end

function onLocaleChange()
    if leader.claimed == nil then
        self.clearButtons()
        leader.createClaimButton()
    end
end

function leader.updateSave(color)
    leader.claimed = color
    local state = {
        claimed = leader.claimed
    }
    self.script_state = JSON.encode(state)
end

function leader.createClaimButton()
    self.createButton({
       click_function = "claimLeader",
       function_owner = self,
       label          = i18n("claimLeaderButton"),
       position       = {0.3, 0.2, 0.4},
       rotation       = {0, 0, 0},
       scale          = {0.75, 1, 0.75},
       width          = 600,
       height         = 150,
       tooltip        = "",
       font_color     = {1, 1, 1},
       font_size      = 85,
       color          = "Black"
       })
end

function claimLeaderCall(params)
    claimLeader(getObjectFromGUID(params.leaderChoiceGUID) , params.color)
end

function claimLeader(object, color)
    local setup = getObjectFromGUID("4a3e76")
    local authorizedColors = {
        Red = true,
        Blue = true,
        Green = true,
        Yellow = true,
        Grey = false
    }

    if setup.getVar("banPhase") == 1 then
        setup.call("updateLeaderBan", {
            leaderSelectedGUID = object.guid,
            playerColor = color
        })
    elseif setup.getVar("hiddenPicks") == 1 then
        if authorizedColors[color] then
            local otherPlayerColors = {}
            for c, _ in pairs(authorizedColors) do
                if c ~= color then
                    otherPlayerColors[#otherPlayerColors + 1] = c
                end
            end
            object.setInvisibleTo(otherPlayerColors)
            object.setPositionSmooth(constants.leaderPos[color])
            object.setRotationSmooth({0, 180, 0})
            object.clearButtons()

            Wait.time(function() object.lock() end, 2)
            setup.call("updateLeaderChoices", {
                leaderSelectedGUID = object.guid,
                playerColor = color
            })
        end
    else
        if authorizedColors[color] then
            if not self.getLock() then
                object.setPositionSmooth(constants.leaderPos[color])
                object.setRotationSmooth({0,180,0})
                object.clearButtons()
                Wait.time(function() object.lock() end, 2)
            end
            leader.updateSave(color)
            if leader.onClaimCallback then
                Wait.time(function() leader.onClaimCallback(color) end, 2)
            end
            broadcastToAll(i18n("willBe"):format(i18n(color:lower()), object.getName()), color)
        else
            broadcastToColor(i18n("cantClaimLeader"), color, color)
        end
        object.setInvisibleTo({})
    end
end

return leader
