playerBoardModule = {}

constants = require("Constants")

helperModule = require("HelperModule")

parkModule = require("ParkModule")

playerBoardModule.playerColor = nil

playerBoardModule.orbitZone = nil

playerBoardModule.orbitPark = nil

playerBoardModule.score = 0

playerBoardModule.global_score_positions = {}

playerBoardModule.scoreboardZone = nil

playerBoardModule.scorePark = nil

playerBoardModule.techPark = nil

playerBoardModule.alive = true

function playerBoardModule.init(playerColor, centerPosition, savedData)
    playerBoardModule.playerColor = playerColor

    if savedData ~= '' then
        local state = JSON.decode(savedData)
        playerBoardModule.orbitZone = getObjectFromGUID(state.orbitZoneGUID)
        playerBoardModule.scoreboardZone = getObjectFromGUID(state.scoreboardZoneGUID)
        playerBoardModule.alive = state.alive
    end

    if not playerBoardModule.alive then
        return
    end

    playerBoardModule.orbitPark = playerBoardModule.createOrbitPark(centerPosition)
    playerBoardModule.techPark = playerBoardModule.createTechPark(centerPosition)

    playerBoardModule.initPlayerScore()

    playerBoardModule.saveState()
end

function playerBoardModule.saveState()
    local state = {
        orbitZoneGUID = playerBoardModule.orbitZone.getGUID(),
        scoreboardZoneGUID = playerBoardModule.scoreboardZone.getGUID(),
        alive = playerBoardModule.alive
    }
    self.script_state = JSON.encode(state)
end

function playerBoardModule.createOrbitPark(centerPosition)
    local allSlots = {}
    local slots = {}
    for i = 1, 4 do
        for j = 1, 4 do
            local x = (i - 2.5) * 0.5
            local z = (j - 2.5) * 0.5
            local slot = Vector(x, 0.29, z):rotateOver('y', -45) + centerPosition
            allSlots[#allSlots + 1] = slot
            if i < 3 or j < 3 then
                slots[#slots + 1] = slot
            end
        end
    end

    if not playerBoardModule.orbitZone then
        playerBoardModule.orbitZone = parkModule.findBoundingZone(45, Vector(0.35, 0.35, 0.35), allSlots)

        for i, troop in ipairs(constants.players[playerBoardModule.playerColor].troops) do
            troop.locked = true
            troop.setPosition(slots[i])
            troop.setRotation(Vector(0, 45, 0))
        end
    end

    return parkModule.createPark(
        "orbit." .. playerBoardModule.playerColor,
        slots,
        Vector(0, -45, 0),
        playerBoardModule.orbitZone,
        playerBoardModule.playerColor,
        playerBoardModule.playerColor,
        true)
end

function playerBoardModule.createTechPark(centerPosition)

    local color = playerBoardModule.playerColor
    local slots = {}
    for i = 1, 2 do
        for j = 3, 1, -1 do
            local x = (i - 1.5) * 3 + 6
            if color == "Red" or color == "Blue" then
                x = -x
            end
                local z = (j - 2) * 2 + 0.4
            local slot = Vector(x, 0.29, z) + centerPosition
            slots[#slots + 1] = slot
        end
    end

    return parkModule.createPark(
        "tech." .. playerBoardModule.playerColor,
        slots,
        Vector(0, 180, 0),
        constants.players[playerBoardModule.playerColor].techZone,
        nil,
        "Tech",
        false)
end

function playerBoardModule.initPlayerScore()
    playerBoardModule.generateGlobalScoreboardPositions()
    playerBoardModule.scorePark = playerBoardModule.createPlayerScoreboardPark()
    playerBoardModule.updatePlayerScore()
end

function playerBoardModule.generateGlobalScoreboardPositions()
    local origin = constants.players[playerBoardModule.playerColor].score_marker_initial_position

    -- Avoid collision between markers by giving a different height to each.
    local h = 1
    for color, _ in pairs(constants.players) do
        if color == playerBoardModule.playerColor then
            break
        else
            h = h + 0.5
        end
    end

    playerBoardModule.global_score_positions = {}
    for i = 1, 14 do
        playerBoardModule.global_score_positions[i] = {
            origin.x,
            2.7 + h,
            origin.z + (i - 2) * 1.165
        }
    end
end

function playerBoardModule.createPlayerScoreboardPark()
    local origin = constants.players[playerBoardModule.playerColor].vp_4_players_token_initial_position

    local direction = 1
    if playerBoardModule.playerColor == "Red" or  playerBoardModule.playerColor == "Blue" then
        direction = -1
    end

    local slots = {}
    for i = 0, 17 do
        slots[i + 1] = Vector(
            origin.x + i * 1.092 * direction,
            origin.y,
            origin.z)
    end

    if not playerBoardModule.scoreboardZone then
        playerBoardModule.scoreboardZone = parkModule.findBoundingZone(0, Vector(0.6, 0.2, 0.6), slots)
    end

    return parkModule.createPark(
        "scoreboard." .. playerBoardModule.playerColor,
        slots,
        Vector(0, 180, 0),
        playerBoardModule.scoreboardZone,
        nil,
        "VP",
        false)
end

function playerBoardModule.updatePlayerScore()
    local zoneObjects = playerBoardModule.scoreboardZone.getObjects()
    local newScore = 0
    for _, object in ipairs(zoneObjects) do
        if object.getDescription() == "VP" then
            newScore = newScore + 1
        end
    end

    local vpIndex = math.min(14, newScore + 1)
    local score_marker = constants.players[playerBoardModule.playerColor].score_marker
    score_marker.setPositionSmooth(playerBoardModule.global_score_positions[vpIndex])
    score_marker.setRotationSmooth({0, 0, 0}, false, false)

    if newScore ~= playerBoardModule.score then
        playerBoardModule.score = newScore
        local setup = getObjectFromGUID("4a3e76")
        setup.call("updateScores")
    end
end

function playerBoardModule.onObjectEnterScriptingZone(zone, enter_object)
    if playerBoardModule.alive then
        if zone.guid == playerBoardModule.scoreboardZone.guid then
            local description = enter_object.getDescription()
            if description == "VP" then
                playerBoardModule.updatePlayerScore()
            end
        end

        if zone == constants.players[playerBoardModule.playerColor].techZone then
            for _, object in ipairs(zone.getObjects()) do
                if object.getDescription() == "Tech" then
                    if helperModule.getTechName(object) == "minimic_film" then
                        updateSpecialSummaryCards()
                    end
                end
            end
        end
    end
end

function playerBoardModule.onObjectLeaveScriptingZone(zone, enter_object)
    if playerBoardModule.alive then
        if zone.guid == playerBoardModule.scoreboardZone.guid then
            local description = enter_object.getDescription()
            if description == "VP" then
                playerBoardModule.updatePlayerScore()
            end
        end

        if zone.guid == "04f512" and helperModule.isAgent(enter_object, playerBoardModule.playerColor) then
            updateSpecialSummaryCards()
        end
    end
end

function playerBoardModule.shutdown(riseOfIxEnabled, immortalityEnabled)
    playerBoardModule.alive = false
    playerBoardModule.saveState()

    local player = constants.players[playerBoardModule.playerColor]

    local toBeRemoved = {
        player.swordmaster,
        player.council_token,
        -- player.vp_4_players_token,
        player.score_marker,
        player.flag_bag,
        player.marker_combat
    }

    if riseOfIxEnabled then
        playerBoardModule.addAll(toBeRemoved, player.dreadnoughts)
        toBeRemoved[#toBeRemoved + 1] = player.cargo
    end

    if immortalityEnabled then
        toBeRemoved[#toBeRemoved + 1] = player.tleilaxuTokens
        toBeRemoved[#toBeRemoved + 1] = player.researchTokens
    end

    playerBoardModule.addAll(toBeRemoved, player.agents)
    playerBoardModule.addAll(toBeRemoved, player.troops)

    for _, object in ipairs(toBeRemoved) do
        if toBeRemoved then
            object.interactable = true
            object.destruct()
        end
    end
end

function playerBoardModule.addAll(objects, otherObjects)
    assert(objects)
    assert(otherObjects)
    for _, object in ipairs(otherObjects) do
        objects[#objects + 1] = object
    end
end

function updateSpecialSummaryCards()
    local highCouncilCardPosition = helperModule.getRevealCardPosition(playerBoardModule.playerColor, 0)
    local setup = getObjectFromGUID("4a3e76")
    local prestige = helperModule.getPrestigeBonus(playerBoardModule.playerColor)
    setup.call("createSeatOfPowerCard", {
        color = playerBoardModule.playerColor,
        prestige = prestige,
        position = highCouncilCardPosition})
end

return playerBoardModule