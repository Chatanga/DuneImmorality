i18n = require("i18n")
require("locales")

constants = require("Constants")

boardCommonModule = require("BoardCommonModule")

parkModule = require("ParkModule")

_ = require("Core").registerLoadablePart(function()
    self.interactable = false
    activateButtons()
end)

function onLocaleChange()
    self.clearButtons()
    activateButtons()
end

function activateButtons()

    self.createButton({
        click_function = "Stillsuits",
        function_owner = self,
        label = "get",
        position = {-1, 0.05, 1.75},
        scale = {0.1, 0.1, 0.1},
        width = 400,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "HardyWarriors",
        function_owner = self,
        label = "pay & get",
        position = {-1, 0.05, 1.37},
        scale = {0.1, 0.1, 0.1},
        width = 900,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "Foldspace",
        function_owner = self,
        label = "get",
        position = {-1, 0.05, -0.08},
        scale = {0.1, 0.1, 0.1},
        width = 400,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "Heighliner",
        function_owner = self,
        label = "pay & get",
        position = {-1, 0.05, -0.42},
        scale = {0.1, 0.1, 0.1},
        width = 900,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "Wealth",
        function_owner = self,
        label = "get",
        position = {-1, 0.05, -1.01},
        scale = {0.1, 0.1, 0.1},
        width = 400,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "Conspire",
        function_owner = self,
        label = "pay & get",
        position = {-1, 0.05, -1.34},
        scale = {0.1, 0.1, 0.1},
        width = 900,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "SietchTabr",
        function_owner = self,
        label = "get",
        position = {-0.2, 0.05, 0.16},
        scale = {0.1, 0.1, 0.1},
        width = 400,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "ResearchStation",
        function_owner = self,
        label = "pay & get",
        position = {0.15, 0.05, -0.24},
        scale = {0.1, 0.1, 0.1},
        width = 900,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "Carthag",
        function_owner = self,
        label = "get",
        position = {0.75, 0.05, -0.55},
        scale = {0.1, 0.1, 0.1},
        width = 400,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "Arrakeen",
        function_owner = self,
        label = "get",
        position = {1.4, 0.05, -0.67},
        scale = {0.1, 0.1, 0.1},
        width = 400,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "ImperialBasin",
        function_owner = self,
        label = "Collect",
        position = {1.38, 0.0500000007450581, -0.1},
        scale = {0.100000001490116, 0.100000001490116, 0.100000001490116},
        width = 700,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "HaggaBasin",
        function_owner = self,
        label = "pay & Collect",
        position = {0.65, 0.0500000007450581, 0.105},
        scale = {0.100000001490116, 0.100000001490116, 0.100000001490116},
        width = 1200,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "TheGreatFlat",
        function_owner = self,
        label = "pay & Collect",
        position = {-0.32, 0.0500000007450581, 0.54},
        scale = {0.100000001490116, 0.100000001490116, 0.100000001490116},
        width = 1200,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "Secrets",
        function_owner = self,
        label = "get",
        position = {-1, 0.0500000007450581, 0.875},
        scale = {0.100000001490116, 0.100000001490116, 0.100000001490116},
        width = 400,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "SelectiveBreeding",
        function_owner = self,
        label = "pay",
        position = {-1, 0.0500000007450581, 0.5},
        scale = {0.100000001490116, 0.100000001490116, 0.100000001490116},
        width = 400,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })
    self.createButton({
        click_function = "EmperorDown",
        function_owner = self,
        label = "↓",
        position = {-1.82, 0.05, -1.25},
        scale = {0.15, 0.100000001490116, 0.100000001490116},
        width = 300,
        height = 450,
        font_size = 350,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1},
        tooltip = i18n("toolTipDecreaseRep")
    })
    self.createButton({
        click_function = "EmperorUp",
        function_owner = self,
        label = "↑",
        position = {-1.82, 0.05, -1.35},
        scale = {0.15, 0.100000001490116, 0.100000001490116},
        width = 300,
        height = 450,
        font_size = 350,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1},
        tooltip = i18n("toolTipIncreaseRep")
    })
    self.createButton({
        click_function = "GuildDown",
        function_owner = self,
        label = "↓",
        position = {-1.82, 0.05, -0.48},
        scale = {0.15, 0.100000001490116, 0.100000001490116},
        width = 300,
        height = 450,
        font_size = 350,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1},
        tooltip = i18n("toolTipDecreaseRep")
    })
    self.createButton({
        click_function = "GuildUp",
        function_owner = self,
        label = "↑",
        position = {-1.82, 0.05, -0.58},
        scale = {0.15, 0.100000001490116, 0.100000001490116},
        width = 300,
        height = 450,
        font_size = 350,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1},
        tooltip = i18n("toolTipIncreaseRep")
    })
    self.createButton({
        click_function = "BeneDown",
        function_owner = self,
        label = "↓",
        position = {-1.82, 0.05, 0.52},
        scale = {0.15, 0.100000001490116, 0.100000001490116},
        width = 300,
        height = 450,
        font_size = 350,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1},
        tooltip = i18n("toolTipDecreaseRep")
    })
    self.createButton({
        click_function = "BeneUp",
        function_owner = self,
        label = "↑",
        position = {-1.82, 0.05, 0.42},
        scale = {0.15, 0.100000001490116, 0.100000001490116},
        width = 300,
        height = 450,
        font_size = 350,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1},
        tooltip = i18n("toolTipIncreaseRep")
    })
    self.createButton({
        click_function = "FremenDown",
        function_owner = self,
        label = "↓",
        position = {-1.82, 0.05, 1.58},
        scale = {0.15, 0.100000001490116, 0.100000001490116},
        width = 300,
        height = 450,
        font_size = 350,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1},
        tooltip = i18n("toolTipDecreaseRep")
    })
    self.createButton({
        click_function = "FremenUp",
        function_owner = self,
        label = "↑",
        position = {-1.82, 0.05, 1.48},
        scale = {0.15, 0.100000001490116, 0.100000001490116},
        width = 300,
        height = 450,
        font_size = 350,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1},
        tooltip = i18n("toolTipIncreaseRep")
    })

    garrisonParks = {}
    createGarrisonPark("Green", Vector(8.15, 0.85, -7.65))
    createGarrisonPark("Yellow", Vector(8.15, 0.85, -10.35))
    createGarrisonPark("Blue", Vector(1.55, 0.85, -10.35))
    createGarrisonPark("Red", Vector(1.55, 0.85, -7.65))
end

function createGarrisonPark(playerColor, origin)
    local slots = {}
    for j = 3, 1, -1 do
        for i = 1, 4 do
            local x = (i - 2.5) * 0.45
            local z = (j - 2) * 0.45
            local slot = Vector(x, 0, z) + origin
            slots[#slots + 1] = slot
        end
    end

    local zone = parkModule.findBoundingZone(0, Vector(0.35, 0.35, 0.35), slots)

    local garrison = parkModule.createPark(
        "garrison." .. playerColor,
        slots,
        Vector(0, 0, 0),
        zone,
        playerColor,
        playerColor,
        false)

    local textColors =  helperModule.getPlayerTextColors(playerColor)

    helperModule.createAbsoluteButton(self, {
        click_function = "landOne" .. playerColor .. "TroopFromOrbit",
        function_owner = self,
        label = i18n("addTroopSmallButton"),
        position = origin + Vector(0, 0.01, -1),
        width = 650,
        height = 180,
        font_size = 150,
        color = textColors.bg,
        font_color = textColors.fg
    })

    garrisonParks[playerColor] = garrison
end

function landOneGreenTroopFromOrbit()
    landTroopsFromOrbit({"Green", 1})
end

function landOneYellowTroopFromOrbit()
    landTroopsFromOrbit({"Yellow", 1})
end

function landOneBlueTroopFromOrbit()
    landTroopsFromOrbit({"Blue", 1})
end

function landOneRedTroopFromOrbit()
    landTroopsFromOrbit({"Red", 1})
end

function landTroopsFromOrbit(parameters)
    local playerColor = parameters[1]
    local count = parameters[2]
    local orbit = constants.players[playerColor].board.call("getOrbitPark")
    local garrison = garrisonParks[playerColor]
    parkModule.transfert(count, orbit, garrison)
end

function sendTroopsBackToOrbit(parameters)
    local playerColor = parameters[1]
    local troops = parameters[2]
    local orbit = constants.players[playerColor].board.call("getOrbitPark")
    parkModule.putObjects(troops, orbit)
end

function getTroopsFromOrbit(playerColor)
    local orbit = constants.players[playerColor].board.call("getOrbitPark")
    return parkModule.getObjects(orbit)
end

function ImperialBasin(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)

    boardCommonModule.ImperialBasin(color);
end

function HaggaBasin(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)

    boardCommonModule.HaggaBasin(color);

end

function TheGreatFlat(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)

    boardCommonModule.TheGreatFlat(color)

end

function Stillsuits(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)

    boardCommonModule.Stillsuits(color)
end

function HardyWarriors(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)

    boardCommonModule.HardyWarriors(color)
end

function Secrets(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)

    boardCommonModule.Secrets(color)
end

function SelectiveBreeding(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)

    boardCommonModule.SelectiveBreeding(color)
end

function Foldspace(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)

    boardCommonModule.Foldspace(color)
end

function Heighliner(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)

    boardCommonModule.Heighliner(color)
end

function Wealth(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)

    boardCommonModule.Wealth(color)
end

function Conspire(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)

    boardCommonModule.Conspire(color)
end

function FremenUp(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)
    boardCommonModule.FremenUp(color)
end

function FremenDown(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)
    boardCommonModule.FremenDown(color)
end

function BeneUp(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)
    boardCommonModule.BeneUp(color)
end

function BeneDown(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)
    boardCommonModule.BeneDown(color)
end

function GuildUp(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)
    boardCommonModule.GuildUp(color)
end

function GuildDown(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)
    boardCommonModule.GuildDown(color)
end

function EmperorUp(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)
    boardCommonModule.EmperorUp(color)
end

function EmperorDown(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)
    boardCommonModule.EmperorDown(color)
end

function SietchTabr(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)
    boardCommonModule.SietchTabr(color)
end

function ResearchStation(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)
    boardCommonModule.ResearchStation(color)
end

function Carthag(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)
    boardCommonModule.Carthag(color)
end

function Arrakeen(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)
    boardCommonModule.Arrakeen(color)
end

function BonusFremen(_, color)
    constants.players[color].water.call("incrementVal")
    local leaderName = helperModule.getLeaderName(color)
    broadcastToAll(i18n("fremenBonus"):format(leaderName), color)
end

function BonusBene(_, color)
    Wait.time(function() boardCommonModule.drawIntrigue(color) end, 0.75)
    local leaderName = helperModule.getLeaderName(color)
    broadcastToAll(i18n("beneBonus"):format(leaderName), color)
end

function BonusSpatial(_, color)
    local t0 = 0
    local combat = Global.call("getFight")
    local solariAmount = 3
    local leader = helperModule.getLeader(color)
    assert(leader)
    local leaderName = leader.getName()

    if leader.hasTag("Yuna") and combat == 0 then
        solariAmount = 4
    end

    for i = 1, solariAmount, 1 do
        t0 = t0 + 0.2
        Wait.time(function() constants.alivePlayers[color].solari.call("incrementVal") end, t0)
    end
    broadcastToAll(i18n("spaceBonus"):format(leaderName, solariAmount), color)
end

function BonusEmperor(_, color)

    local leaderName = helperModule.getLeaderName(color)

    helperModule.landTroopsFromOrbit(color, 2)
    broadcastToAll(i18n("emperorBonus"):format(leaderName), color)
end

function recallSnooper(parameters)
    local factionName = parameters.factionName
    local color = parameters.color

    local factions = {
        ["Emperor"] = {
            id = "emperor",
            upAction = "EmperorUp",
            bonusAction = function() BonusEmperor(nil, color) end,
            snooperGUID = "a58ce8"
        },
        ["Spacing Guild"] = {
            id = "spacingGuild",
            upAction = "GuildUp",
            bonusAction = function() BonusSpatial(nil, color) end,
            snooperGUID = "857f74"
        },
        ["Bene Gesserit"] = {
            id = "beneGesserit",
            upAction = "BeneUp",
            bonusAction = function() BonusBene(nil, color) end,
            snooperGUID = "bed196"
        },
        ["Fremen"] = {
            id = "fremen",
            upAction = "FremenUp",
            bonusAction = function() BonusFremen(nil, color) end,
            snooperGUID = "b10897"
        }
    }

    local foundSnooper = nil
    local snooperRank = 4
    for name, faction in pairs(factions) do
        local snooper = getObjectFromGUID(faction.snooperGUID)
        if not isInZone(constants.players[color].leader_zone, snooper) then
            if factionName == name then
                foundSnooper = snooper
            else
                snooperRank = snooperRank - 1
            end
        end
    end

    if foundSnooper then
        Wait.time(function()
            local p = constants.leaderPos[color] + Vector(snooperRank / 4 - 2, 0, 1.4 - snooperRank / 2)
            foundSnooper.setPositionSmooth(p)

            local factionLabel = i18n(factions[factionName].id)

            if snooperRank == 1 then
                broadcastToAll(i18n("firstSnooperRecall"):format(factionLabel), color)
                Player[color].showInfoDialog(i18n("firstSnooperRecallEffectInfo"))
            elseif snooperRank == 2 then
                broadcastToAll(i18n("secondSnooperRecall"):format(factionLabel), color)
                factions[factionName].bonusAction()
            elseif snooperRank == 3 then
                broadcastToAll(i18n("thirdSnooperRecall"):format(factionLabel), color)
                boardCommonModule[factions[factionName].upAction](color)
            elseif snooperRank == 4 then
                broadcastToAll(i18n("fourthSnooperRecall"):format(factionLabel), color)
                factions[factionName].bonusAction()
                boardCommonModule[factions[factionName].upAction](color)
            else
                assert(false)
            end
        end, 1)
    end
end

function isInZone(zone, object)
    for _, otherObject in ipairs(zone.getObjects()) do
        if otherObject == object then
            return true
        end
    end
    return false
end

zone_alliance = {
    ["Emperor"] = getObjectFromGUID('2c3c38'),
    ["Spacing Guild"] = getObjectFromGUID('8d2035'),
    ["Bene Gesserit"] = getObjectFromGUID('53e26c'),
    ["Fremen"] = getObjectFromGUID('ae150a')
}


function onObjectEnterScriptingZone(zone, enter_object)

    if zone.guid == zone_alliance["Emperor"].guid then
        local name = enter_object.getName()
        local color = ""
        if name == "Emperor Faction Red" then
            color = "Red"
        elseif name == "Emperor Faction Blue" then
            color = "Blue"
        elseif name == "Emperor Faction Green" then
            color = "Green"
        elseif name == "Emperor Faction Yellow" then
            color = "Yellow"
        end
        if color == "Red" or color == "Blue" or color == "Green" or color ==
            "Yellow" then BonusEmperor(_, color) end
    end

    if zone.guid == zone_alliance["Spacing Guild"].guid then
        local name = enter_object.getName()
        local color = ""
        if name == "Spacing Guild Faction Red" then
            color = "Red"
        elseif name == "Spacing Guild Faction Blue" then
            color = "Blue"
        elseif name == "Spacing Guild Faction Green" then
            color = "Green"
        elseif name == "Spacing Guild Faction Yellow" then
            color = "Yellow"
        end
        if color == "Red" or color == "Blue" or color == "Green" or color ==
            "Yellow" then BonusSpatial(_, color) end
    end
    if zone.guid == zone_alliance["Bene Gesserit"].guid then
        local name = enter_object.getName()
        local color = ""
        if name == "Bene Gesserit Faction Red" then
            color = "Red"
        elseif name == "Bene Gesserit Faction Blue" then
            color = "Blue"
        elseif name == "Bene Gesserit Faction Green" then
            color = "Green"
        elseif name == "Bene Gesserit Faction Yellow" then
            color = "Yellow"
        end
        if color == "Red" or color == "Blue" or color == "Green" or color ==
            "Yellow" then BonusBene(_, color) end
    end
    if zone.guid == zone_alliance["Fremen"].guid then
        local name = enter_object.getName()
        local color = ""
        if name == "Fremen Faction Red" then
            color = "Red"
        elseif name == "Fremen Faction Blue" then
            color = "Blue"
        elseif name == "Fremen Faction Green" then
            color = "Green"
        elseif name == "Fremen Faction Yellow" then
            color = "Yellow"
        end
        if color == "Red" or color == "Blue" or color == "Green" or color ==
            "Yellow" then BonusFremen(_, color) end
    end
end