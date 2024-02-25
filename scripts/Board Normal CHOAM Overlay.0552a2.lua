i18n = require("i18n")
require("locales")

constants = require("Constants")

helperModule = require("HelperModule")

boardCommonModule = require("BoardCommonModule")

DrawOne = helperModule.DrawOne

_ = require("Core").registerLoadablePart(function()
    SecureContract_zone = getObjectFromGUID("db4022")
    SellMelange_zone = getObjectFromGUID("7539a3")

    RallyTroops_zone = getObjectFromGUID("6932df")
    Swordmaster_zone = getObjectFromGUID("6cc2f8")
    HallOfOratory_zone = getObjectFromGUID("3e7409")

    self.interactable = false
    activateButtons()
end)

function onLocaleChange()
    self.clearButtons()
    activateButtons()
end

function activateButtons()

    self.createButton({
        click_function = "SecureContract",
        function_owner = self,
        label = "get",
        position = {2.2, 0.1, 0.58},
        scale = {0.238, 0.238, 0.238},
        width = 400,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "SellMelange2",
        function_owner = self,
        label = "↓",
        position = {2.165, 0.1, -0.66},
        scale = {0.238, 0.238, 0.238},
        width = 300,
        height = 330,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "SellMelange3",
        function_owner = self,
        label = "↓",
        position = {2.344, 0.1, -0.66},
        scale = {0.238, 0.238, 0.238},
        width = 300,
        height = 330,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "SellMelange4",
        function_owner = self,
        label = "↓",
        position = {2.515, 0.1, -0.66},
        scale = {0.238, 0.238, 0.238},
        width = 300,
        height = 330,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "SellMelange5",
        function_owner = self,
        label = "↓",
        position = {2.69, 0.1, -0.66},
        scale = {0.238, 0.238, 0.238},
        width = 300,
        height = 330,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "HighCouncil",
        function_owner = self,
        label = "pay & get",
        position = {-2, 0.1, -0.15},
        scale = {0.238, 0.238, 0.238},
        width = 900,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "Mentat",
        function_owner = self,
        label = "pay & get",
        position = {-2, 0.1, 0.65},
        scale = {0.238, 0.238, 0.238},
        width = 900,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "RallyTroops",
        function_owner = self,
        label = "pay & get",
        position = {-0.55, 0.1, 0.65},
        scale = {0.238, 0.238, 0.238},
        width = 900,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "Swordmaster",
        function_owner = self,
        label = "pay & get",
        position = {0.72, 0.1, 0.65},
        scale = {0.238, 0.238, 0.238},
        width = 900,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "HallOfOratory",
        function_owner = self,
        label = "get",
        position = {0.7, 0.1, -0.1},
        scale = {0.238, 0.238, 0.238},
        width = 400,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
end

function Swordmaster(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)
    boardCommonModule.Swordmaster(color, Swordmaster_zone)
end

function Mentat(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)
    boardCommonModule.Mentat(color)
end

function HighCouncil(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)
    boardCommonModule.HighCouncil(color)
end

function SecureContract(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)

    if boardCommonModule.CheckAgentAndPlayer(color, SecureContract_zone) then

        local leaderName = helperModule.getLeaderName(color)

        local player = constants.players[color]
        player.solari.call("incrementVal")
        player.solari.call("incrementVal")
        player.solari.call("incrementVal")
        broadcastToAll(i18n("secureContract"):format(leaderName), color)
    end
end

function sellMelange(color, spiceAmount, solariAmount)

    local val = constants.players[color].spice.call("collectVal")

    if boardCommonModule.CheckAgentAndPlayer(color, SellMelange_zone) then

        local leaderName = helperModule.getLeaderName(color)

        if val < spiceAmount then
            broadcastToColor(i18n("noSpice"), color, color)
        else
            for i = 1, spiceAmount, 1 do
                constants.players[color].spice.call("decrementVal")
            end
            for i = 1, solariAmount, 1 do
                constants.players[color].solari.call("incrementVal")
            end
            broadcastToAll(i18n("sellMelange"):format(leaderName, spiceAmount,
                                                      solariAmount), color)
        end
    end

end

function SellMelange2(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)

    sellMelange(color, 2, 6)
end

function SellMelange4(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)

    sellMelange(color, 4, 10)
end

function SellMelange5(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)

    sellMelange(color, 5, 12)
end

function SellMelange3(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)

    sellMelange(color, 3, 8)
end

function RallyTroops(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)

    if boardCommonModule.CheckAgentAndPlayer(color, RallyTroops_zone) then

        local leader = helperModule.getLeader(color)
        assert(leader)
        local leaderName = leader.getName()
        local solariObj = constants.players[color].solari
        local t = 0
        local t1 = 0

        local price = 4

        if leader.hasTag("Leto") then price = 3 end

        if solariObj.call("collectVal") < price then
            broadcastToColor(i18n("noSolari"), color, color)
        else
            for i = 1, price, 1 do
                Wait.time(function()
                    solariObj.call("decrementVal")
                end, t)
                t = t + 0.3
            end

            helperModule.landTroopsFromOrbit(color, 4)

            if leader.hasTag("Ilban") then

                local numberToDraw = 1

                local enoughCards = helperModule.isDeckContainsEnough(color, numberToDraw)

                if not enoughCards then
                    broadcastToAll(
                        i18n("rallyTroops"):format(leaderName, price) .. ".",
                        color)

                    broadcastToAll(i18n("isDecidingToDraw"):format(leaderName),
                                   "Pink")

                    Player[color].showConfirmDialog(
                        i18n("warningBeforeDraw"):format(numberToDraw),
                        function(player_color)
                            DrawOne(_, color)
                            broadcastToAll(i18n("ilbanDraw"):format(leaderName),
                                           color)
                        end)
                else
                    DrawOne(_, color)
                    broadcastToAll(
                        i18n("rallyTroops"):format(leaderName, price) ..
                            i18n("et") .. i18n("drawOneCard"), color)
                end
            else
                broadcastToAll(i18n("rallyTroops"):format(leaderName, price) ..
                                   ".", color)
            end
        end
    end
end

function HallOfOratory(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)

    if boardCommonModule.CheckAgentAndPlayer(color, HallOfOratory_zone) then
        local leaderName = helperModule.getLeaderName(color)
        helperModule.landTroopsFromOrbit(color, 1)
        broadcastToAll(i18n("oratory"):format(leaderName), color)
    end
end

function hasAgentInHallOfOratory(color)
    return boardCommonModule.hasAgentInSpace(color, HallOfOratory_zone)
end