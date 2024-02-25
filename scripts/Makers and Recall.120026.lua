core = require("Core")

i18n = require("i18n")
require("locales")

constants = require("Constants")

helperModule = require("HelperModule")

GetDeckOrCard = helperModule.GetDeckOrCard
GetDeckOrCardFromGUID = helperModule.GetDeckOrCardFromGUID

DrawOne = helperModule.DrawOne

pos_trash = constants.pos_trash_lower

zone_deck = constants.zone_deck_imperium

combat_marker_offside_positions = {
    Red = core.getHardcodedPositionFromGUID('2d1d17', 1.20173931, 1.2722795, -12.093792) + Vector(0, 0, 0),
    Blue = core.getHardcodedPositionFromGUID('f22e20', 1.161782, 1.57149315, -12.090004) + Vector(1, 0, 0),
    Yellow = core.getHardcodedPositionFromGUID('c2dd31', 1.27570391, 0.6798308, -12.11749) + Vector(2, 0, 0),
    Green = core.getHardcodedPositionFromGUID('a1a9a7', 1.2276181, 0.9726786, -12.102025) + Vector(3, 0, 0)
}

-- TODO Make these positions relative to some anchor.
dreadnoughtRestingPositions =
{
    Yellow = {
        Vector(9.32, 1.57, -11.0),
        Vector(9.32, 1.57, -9.5)
    },
    Green = {
        Vector(9.32, 1.58, -7.0),
        Vector(9.32, 1.58, -8.5)
    },
    Blue = {
        Vector(0.35, 1.58, -11.0),
        Vector(0.35, 1.58, -9.5)
        },
    Red = {
        Vector(0.35, 1.58, -7.09),
        Vector(0.35, 1.58, -8.5)
    }
}

-------- Initialize Parameter ---------

button_offset_y = 0 -- Set number. Value greater than or equal to 0. Defaults to 0.10.
button_width = 800 -- Set number. Defaults to 450.
button_height = 10 -- Set number. Defaults to 300.
button_color = {0.25, 0.25, 0.25} -- Set number {Red,Green,Blue}. Value bitween 0.00 to 1.00. Defaults to {1.00,1.00,1.00] ("White").
text_color = {1.00, 1.00, 1.00} -- Set number {Red,Green,Blue}. Value bitween 0.00 to 1.00. Defaults to {0.25,0.25,0.25] ("Black").
text_size = 80 -- Set number. Defaults to 100.

_ = core.registerLoadablePart(function(saved_data)
    self.interactable = false
    pos_intrigue_discard = constants.getLandingPositionFromGUID("90f762")

    buttonPass = {
        ["Red"] = getObjectFromGUID("0e9fa2"),
        ["Blue"] = getObjectFromGUID("643f32"),
        ["Green"] = getObjectFromGUID("9c69b9"),
        ["Yellow"] = getObjectFromGUID("65876d")
    }

    bonus_spice1 = getObjectFromGUID('3cdb2d')
    bonus_spice2 = getObjectFromGUID('394db2')
    bonus_spice3 = getObjectFromGUID('116807')
    blue_spice = getObjectFromGUID('9cc286')
    red_spice = getObjectFromGUID('3074d4')
    green_spice = getObjectFromGUID('22478f')
    yellow_spice = getObjectFromGUID('78fb8a')
    marker_round = getObjectFromGUID('fb41e2')

    conflictZone = "6d632e"
    conflict_discard = core.getHardcodedPositionFromGUID('cb0478', -1.15463293, 0.63, -9.798157) + constants.someHeight
    zone_vp_encours = getObjectFromGUID("740624")
    trash = getObjectFromGUID("ef8614")
    makerZones = {"69f925", "622708", "2c77c1"}

    marker = constants.first_player_marker
    position_marker = constants.first_player_positions

    firstPlayerMarkerZone = {
        Yellow = getObjectFromGUID("e9a44c"),
        Green = getObjectFromGUID("59523d"),
        Blue = getObjectFromGUID("1fc559"),
        Red = getObjectFromGUID("346e0d")
    }

    round_start = 1
    activateButton()
end)

function onLocaleChange()
    self.clearButtons()
    activateButton()
end

function activateButton()
    self.createButton({
        click_function = "Makers",
        function_owner = self,
        color = button_color,
        font_color = text_color,
        rotation = {0, 0, 0},
        label = "MAKERS\nRECALL",
        position = {-7.1, 0.2, 8},
        scale = {2, 1, 2},
        width = 600,
        height = 310,
        font_size = 120
    })
end

function getRoundStart() return round_start end

function Makers()
    if not identifyFirstPlayer() then
        broadcastToAll(i18n("noFirstPlayer"))
        return
    end

    round_start = 1
    for index in pairs(buttonPass) do buttonPass[index].clearButtons() end
    self.clearButtons()
    marker_round.setPositionSmooth(constants.marker_positions.makers, false, false)
    for i = 1, 3 do
        local agentCheck = 0
        spaceCheck = getObjectFromGUID(makerZones[i]).getObjects()

        for _, item in ipairs(spaceCheck) do
            if item.getDescription() == "Agent" then agentCheck = 1 end
        end

        if i == 1 and agentCheck == 0 then
            Wait.time(function()
                broadcastToAll(i18n('spiceGreatFlat'), {0.956, 0.392, 0.113})
                bonus_spice3.call("incrementVal")
            end, 0.5)
        elseif i == 2 and agentCheck == 0 then
            Wait.time(function()
                broadcastToAll(i18n('spiceHaggaBasin'), {0.956, 0.392, 0.113})
                bonus_spice2.call("incrementVal")
            end, 1)
        elseif i == 3 and agentCheck == 0 then
            Wait.time(function()
                broadcastToAll(i18n('spiceImperialBasin'), {0.956, 0.392, 0.113})
                bonus_spice1.call("incrementVal")
            end, 1.5)
        end
    end
    Wait.time(Recall, 2)
end

function Recall() startLuaCoroutine(self, "ConflictZone") end

function getDreadnoughtRestingPosition(dreadnoughName)
    for color, _ in pairs(constants.players) do
        if dreadnoughName == color .. " dreadnought" then
            return dreadnoughtRestingPositions[color][1]
        elseif dreadnoughName == color .. " Dreadnought" then
            return dreadnoughtRestingPositions[color][2]
        end
    end
    return nil
end

function ConflictZone()
    marker_round.setPositionSmooth(constants.marker_positions.combat, false, false)
    local conflictArea = getObjectFromGUID(conflictZone).getObjects()

    for _, item in ipairs(conflictArea) do
        local itemName = item.getName()
        if constants.players[itemName] then
            helperModule.sendTroopsBackToOrbit(itemName, {item})
        else
            local p = getDreadnoughtRestingPosition(itemName)
            if p then
                item.setPositionSmooth(p, false, true)
                item.setRotation({0, 0, 0})
            end
        end

        local Time = os.clock() + 0.1
        while os.clock() < Time do coroutine.yield() end
    end

    local mentat = getObjectFromGUID("c2a908")
    mentat.setColorTint("White")
    mentat.setPositionSmooth(getObjectFromGUID("565d09").getPosition(), false, true)
    mentat.setRotationSmooth({0, 180, 0})

    -- General Agent Reset

    -- Red

    if getObjectFromGUID("afa978") then
        getObjectFromGUID("afa978").setPositionSmooth(constants.players["Red"].agent_positions[1],
                                                      false, true)
        getObjectFromGUID("afa978").setRotationSmooth({0, 180, 0})
        local Time = os.clock() + 0.1
        while os.clock() < Time do coroutine.yield() end

    end
    if getObjectFromGUID("7751c8") then
        getObjectFromGUID("7751c8").setPositionSmooth(constants.players["Red"].agent_positions[2],
                                                      false, true)
        getObjectFromGUID("7751c8").setRotationSmooth({0, 180, 0})
        local Time = os.clock() + 0.1
        while os.clock() < Time do coroutine.yield() end

    end

    -- Blue

    if getObjectFromGUID("106d8b") then
        getObjectFromGUID("106d8b").setPositionSmooth(constants.players["Blue"].agent_positions[1],
                                                      false, true)
        getObjectFromGUID("106d8b").setRotationSmooth({0, 180, 0})
        local Time = os.clock() + 0.1
        while os.clock() < Time do coroutine.yield() end

    end
    if getObjectFromGUID("64d013") then
        getObjectFromGUID("64d013").setPositionSmooth(constants.players["Blue"].agent_positions[2],
                                                      false, true)
        getObjectFromGUID("64d013").setRotationSmooth({0, 180, 0})
        local Time = os.clock() + 0.1
        while os.clock() < Time do coroutine.yield() end

    end

    -- Yellow

    if getObjectFromGUID("5068c8") then
        getObjectFromGUID("5068c8").setPositionSmooth(constants.players["Yellow"].agent_positions[1],
                                                      false, true)
        getObjectFromGUID("5068c8").setRotationSmooth({0, 180, 0})
        local Time = os.clock() + 0.1
        while os.clock() < Time do coroutine.yield() end

    end
    if getObjectFromGUID("67b476") then
        getObjectFromGUID("67b476").setPositionSmooth(constants.players["Yellow"].agent_positions[2],
                                                      false, true)
        getObjectFromGUID("67b476").setRotationSmooth({0, 180, 0})
        local Time = os.clock() + 0.1
        while os.clock() < Time do coroutine.yield() end

    end

    -- Green

    if getObjectFromGUID("bceb0e") then
        getObjectFromGUID("bceb0e").setPositionSmooth(constants.players["Green"].agent_positions[1],
                                                      false, true)
        getObjectFromGUID("bceb0e").setRotationSmooth({0, 180, 0})
        local Time = os.clock() + 0.1
        while os.clock() < Time do coroutine.yield() end

    end
    if getObjectFromGUID("66ae45") then
        getObjectFromGUID("66ae45").setPositionSmooth(constants.players["Green"].agent_positions[2],
                                                      false, true)
        getObjectFromGUID("66ae45").setRotationSmooth({0, 180, 0})
        local Time = os.clock() + 0.1
        while os.clock() < Time do coroutine.yield() end

    end

    local objectByGUID = {}
    for _, zoneGUID in ipairs({"83ea90", "c68e45", "04f512"}) do
        for _, object in ipairs(getObjectFromGUID(zoneGUID).getObjects()) do
            objectByGUID[object.getGUID()] = object
        end
    end

    for _, item in pairs(objectByGUID) do
        for _, color in ipairs({"Yellow", "Green", "Blue", "Red"}) do
            if item.getName() == color .. " Swordmaster" then
                item.setPositionSmooth(constants.players[color].agent_positions[3], false, true)
                item.setRotation({0, 180, 0})
                local Time = os.clock() + 0.1
                while os.clock() < Time do
                    coroutine.yield()
                end
            end
            if item.getName() == color .. " Combat Marker" then
                item.setPositionSmooth(combat_marker_offside_positions[color], false, true)
                item.setRotation({0, 180, 0})
                local Time = os.clock() + 0.1
                while os.clock() < Time do
                    coroutine.yield()
                end
            end
        end
    end

    for _, obj in ipairs(zone_vp_encours.getObjects()) do
        if obj then
            if obj.getDescription() == "VP" then
                trash.putObject(obj)
            end
        end
    end

    local conflictDeckOrCard = helperModule.GetDeckOrCardFromGUID('07e239')
    if conflictDeckOrCard then
        if conflictDeckOrCard.type == 'Deck' then
            conflictDeckOrCard.takeObject({
                position = conflict_discard,
                top = true,
                flip = true
            })
        elseif conflictDeckOrCard.type == 'Card' then
            conflictDeckOrCard.setPosition(conflict_discard)
            conflictDeckOrCard.setRotation({0, 180, 0})
        end
    end

    for col, player in pairs(constants.players) do
        local cards = player.playZone.getObjects()
        for _, card in ipairs(cards) do
            if card.type == 'Card' or card.type == 'Deck' then
                if card.hasTag('Intrigue') then
                    card.setPosition(pos_intrigue_discard)
                elseif card.hasTag('Imperium') then
                    card.setPosition(constants.players[col].pos_discard)
                end
            end
        end
        Wait.time(function ()
            player.board.call("updateSpecialSummaryCards")
        end, 2)
    end

    local Time = os.clock() + 1 -- wait after collecting reveal zones into discards for letting time for cards to stack in the discard pile before drawing for holtzman effects
    while os.clock() < Time do coroutine.yield() end

    broadcastToAll(i18n('nextRound'), "Purple")

    local blackMarketBoard = getObjectFromGUID("ab7ac5")
    blackMarketBoard.call("updateBlackMarket")

    Global.call("resetRound")

    local activePlayers = getObjectFromGUID("4a3e76").call("getPlayersBasedOnHotseat")
    local firstPlayerColor = findNextPlayer(activePlayers)
    -- Not true: assert((#activePlayers > 1) == (firstPlayerColor ~= nil))
    if firstPlayerColor then
        Global.call("TableTurnPlayers")
        setFirstPlayer(firstPlayerColor)
    end

    marker_round.setPositionSmooth(constants.marker_positions.round_start, false, false)

    local t1 = 0.1
    for color, _ in pairs(constants.players) do
        local playerObjects = constants.players[color].techZone.getObjects()
        for _, obj in ipairs(playerObjects) do
            if obj.hasTag("Holtzman") then
                DrawOne(_, color)
                broadcastToAll(
                    helperModule.getLeaderName(color) ..
                        i18n("holtzmanEngine"), color)
            elseif obj.hasTag("Shuttle Fleet") then
                for _ = 1, 2 do
                    Wait.time(function()
                        constants.players[color].solari.call("incrementVal")
                    end, t1)
                    t1 = t1 + 0.3
                end
                broadcastToAll(
                    helperModule.getLeaderName(color) ..
                        i18n("shuttleFleet"), color)
            elseif obj.getDescription() == "Tech" then
                obj.setRotationSmooth({0, 180, 0}, false, false)
            end
        end
    end

    for color, _ in pairs(constants.players) do
        local playerObjects = constants.players[color].techZone.getObjects()
        for _, obj in ipairs(playerObjects) do
            if obj.getGMNotes() == "ok" and
                helperModule.getLeaderName(color) == "Norma Cenva" then
                DrawOne(_, color)
                broadcastToAll(
                    helperModule.getLeaderName(color) ..
                        i18n("holtzmanEffect"), color)
                break
            end
        end
    end

    Wait.time(function() broadcastToAll(i18n("drawFive"), {0.5, 0.5, 0.5}) end, 2)
    Wait.time(function()
        marker_round.setPositionSmooth(constants.marker_positions.player_turns, false, false)
        broadcastToAll(i18n("playersTurn"), "Pink")
        activateButton()
        round_start = 0
    end, 4)

    return 1
end

function identifyFirstPlayer()
    for color, _ in pairs(constants.players) do
        for _, object in ipairs(firstPlayerMarkerZone[color].getObjects()) do
            if object == marker then
                return color
            end
        end
    end
    return nil
end

function findNextPlayer(activePlayers)
    local nextPlayer = identifyFirstPlayer()
    local playerPresences = {}
    for _, color in ipairs(activePlayers) do
        playerPresences[color] = true
    end
    repeat
        assert(nextPlayer)
        nextPlayer = constants.turnOrder[nextPlayer]
    until playerPresences[nextPlayer]
    return nextPlayer
end

function setFirstPlayer(firstPlayerColor)
    broadcastToAll(i18n('firstPlayer') .. helperModule.getLeaderName(firstPlayerColor), firstPlayerColor)
    if getObjectFromGUID("4a3e76").getVar("hotseat_mode") then
        Player.getPlayers()[1].changeColor(firstPlayerColor)
    else
        Turns.turn_color = firstPlayerColor
        Turns.enable = true
    end

    -- TODO Why it wasn't here in the first place?
    marker.setPositionSmooth(constants.first_player_positions[firstPlayerColor], false, false)
end