local helperModule = {}

core = require("Core")

constants = require("Constants")

parkModule = require("ParkModule")

function helperModule.DrawOne(_, color)
    local starterDeck = helperModule.GetDeckOrCard(constants.players[color].drawDeckZone)
    local discardFound = false

    if starterDeck ~= nil then
        starterDeck.deal(1, color)
    else
        discardFound = helperModule.ResetDiscard(_, color)
        if discardFound then
            Wait.time(function()
                local drawDeck = helperModule.GetDeckOrCard(constants.players[color].drawDeckZone)
                drawDeck.deal(1, color)
            end, 1.5)
        else
            broadcastToColor("Missing one card to draw because your discard is empty", color, color)
        end
    end
    return discardFound
end

function helperModule.DrawCards(numberToDraw, color, message)
    assert(numberToDraw > 0)

    local enoughCards = helperModule.isDeckContainsEnough(color, numberToDraw)
    if not enoughCards then

        local leaderName = helperModule.getLeaderName(color)
        broadcastToAll(i18n("isDecidingToDraw"):format(leaderName), "Pink")

        local card = i18n("cards")
        if numberToDraw == 1 then
            card = i18n("card")
        end

        Player[color].showConfirmDialog(
            i18n("warningBeforeDraw"):format(numberToDraw, card),

            function(_)
                if message then
                    broadcastToAll(message, color)
                end
                for i = 0, numberToDraw - 1, 1 do
                    Wait.time(function()
                        DrawOne(_, color)
                    end, i)
                end
            end)
    else
        for i = 1, numberToDraw do
            Wait.time(function() DrawOne(_, color) end, i)
        end
    end
end

function helperModule.ResetDiscard(_, color)
    discardArea = helperModule.GetDeckOrCard(constants.players[color].discardZone)
    local discardFound = true
    if discardArea ~= nil then
        discardArea.setRotationSmooth({0, 180, 180}, false, false)
        discardArea.shuffle()
        discardArea.setPositionSmooth(constants.getLandingPosition(constants.players[color].drawDeckZone), false, true)
        Wait.time(function()
            helperModule.GetDeckOrCard(constants.players[color].drawDeckZone).shuffle()
        end, 0.5)
    else
        discardFound = false
    end

    return discardFound

end

function helperModule.GetDeckOrCard(zone)
    assert(zone)
    assert(type(zone) ~= 'string', tostring(zone) .. ' is a GUID, not a zone')
    for _, obj in ipairs(zone.getObjects()) do
        if obj.type == "Card" or obj.type == "Deck" then return obj end
    end
    --log(zone.getGUID() .. " contains no card nor deck!")
    return nil
end

function helperModule.GetDeckOrCardFromGUID(zoneGUID)
    assert(type(zoneGUID) == 'string', tostring(zoneGUID) .. ' is not a GUID')
    local object = getObjectFromGUID(zoneGUID)
    assert(object, "Failed to resolve GUID: " .. tostring(zoneGUID))
    return helperModule.GetDeckOrCard(object)
end

function helperModule.isDeckContainsEnough(color, numberToDraw)

    local starterDeck = helperModule.GetDeckOrCard(constants.players[color].drawDeckZone)

    local enoughCards = true

    if starterDeck == nil then
        enoughCards = false
    else
        local countCheck = starterDeck.getQuantity()
        local typeCheck = starterDeck.type

        if typeCheck == "Card" then countCheck = 1 end

        if countCheck < numberToDraw then enoughCards = false end
    end

    return enoughCards
end

-- Les nouvelles ancres ont toutes une échelle unitaire, ce qui n’était pas le
-- cas des anciennes.
function helperModule.correctAnchorPosition(pos, originalScale)
    return Vector(
        pos[1] * originalScale[1],
        pos[2] * originalScale[2],
        pos[3] * originalScale[3])
end

function helperModule.getPlayerTextColors(playerColor)

    local background = {0, 0, 0, 1}
    local foreground = {1, 1, 1, 1}

    if playerColor == 'Green' then
        background = {0.192, 0.701, 0.168, 1}
        foreground = {0.7804, 0.7804, 0.7804, 1}
    elseif playerColor == 'Yellow' then
        background = {0.9058, 0.898, 0.1725, 1}
        foreground = {0, 0, 0, 1}
    elseif playerColor == 'Blue' then
        background = {0.118, 0.53, 1, 1}
        foreground = {0.7804, 0.7804, 0.7804, 1}
    elseif playerColor == 'Red' then
        background =  {0.856, 0.1, 0.094, 1}
        foreground = {0.7804, 0.7804, 0.7804, 1}
    end

    return {
        bg = background,
        fg = foreground
    }
end

function helperModule.toVector(data)
    if not data or core.isSomeKindOfObject(data) then
        return data
    else
        return Vector(data[1], data[2], data[3])
    end
end

--[[
    Indirect call to createButton adjusting the provided parameters to
    counteract the position, scale and rotation of the parent object.
    TTS does offer a positionToLocal method, but which only accounts for
    the position and (partly to the) scale, not the rotation. The
    convention for the world coordinates is a bit twisted here since the
    X coordinate is inverted.
]]--
function helperModule.createAbsoluteButton(object, parameters)
    helperModule.createAbsoluteButtonWithRoundness(object, 0.25, true, parameters)
end

function helperModule.createAbsoluteButtonWithRoundness(object, roundness, quirk, parameters)
    local scale = object.getScale()
    local invScale = Vector(1 / scale.x, 1 / scale.y, 1 / scale.z)

    -- Only to counteract the absolute roundness of the background.
    local rescale = 1 / roundness

    local p = helperModule.toVector(parameters['position'])
    if p then
        -- Inverting the X coordinate comes from our global 180° rotation around Y.
        -- TODO Get rid of this quirk.
        if quirk then
            p = Vector(-p.x, p.y, p.z)
        else
            p = Vector(p.x, p.y, p.z)
        end

        p = p - object.getPosition()

        if quirk then
            p = Vector(p.x, p.y, p.z)
        else
            p = Vector(-p.x, p.y, p.z)
        end

        p:scale(invScale)

        -- Proper order?
        local r = object.getRotation()
        p:rotateOver('x', -r.x)
        p:rotateOver('y', -r.y)
        p:rotateOver('z', -r.z)

        parameters['position'] = p
    end

    local s = helperModule.toVector(parameters['scale'])
    if not s then
        s = Vector(1, 1, 1)
    end
    s = s * invScale * (1 / rescale)
    parameters['scale'] = s

    local w = parameters['width']
    if not w then
        w = 1
    end
    w = w * rescale
    parameters['width'] = w

    local h = parameters['height']
    if not h then
        h = 1
    end
    h = h * rescale
    parameters['height'] = h

    local font_size = parameters['font_size']
    if not font_size then
        font_size = 1
    end
    font_size = font_size * rescale
    parameters['font_size'] = font_size

    object.createButton(parameters)
end

function helperModule.getLeader(playerColor)
    local leaderZone = helperModule.getPlayer(playerColor).leader_zone
    for _, object in ipairs(leaderZone.getObjects()) do
        if object.hasTag("Leader") then
            return object
        end
    end
    return nil
end

function helperModule.getLeaderName(playerColor)
    local leader = helperModule.getLeader(playerColor)
    if leader then
        return leader.getName()
    else
        log(playerColor .. " player has no leader")
        return "?"
    end
end

function helperModule.landTroopsFromOrbit(playerColor, count)
    local mainBoard = getObjectFromGUID('2da390')
    mainBoard.call("landTroopsFromOrbit", {playerColor, count})
end

function helperModule.sendTroopsBackToOrbit(playerColor, troops)
    local mainBoard = getObjectFromGUID('2da390')
    mainBoard.call("sendTroopsBackToOrbit", {playerColor, troops})
end

function helperModule.getTroopsFromOrbit(playerColor)
    local mainBoard = getObjectFromGUID('2da390')
    return mainBoard.call("getTroopsFromOrbit", playerColor)
end

function helperModule.grantTechTile(playerColor, techTile)
    local playerBoard = helperModule.getPlayer(playerColor).board
    local techPark = playerBoard.call("getTechPark")
    parkModule.putObject(techTile, techPark)
end

function helperModule.getScoreTokens(playerColor)
    local playerBoard = helperModule.getPlayer(playerColor).board
    local scorePark = playerBoard.call("getScorePark")
    return parkModule.getObjects(scorePark)
end

function helperModule.grantScoreToken(playerColor, token)
    local playerBoard = helperModule.getPlayer(playerColor).board
    local scorePark = playerBoard.call("getScorePark")
    parkModule.putObject(token, scorePark)
end

function helperModule.grantScoreTokenFromBag(playerColor, tokenBag)
    local playerBoard = helperModule.getPlayer(playerColor).board
    local scorePark = playerBoard.call("getScorePark")
    parkModule.putObjectFromBag(tokenBag, scorePark)
end

function helperModule.getPlayerScore(playerColor)
    local playerBoard = helperModule.getPlayer(playerColor).board
    return playerBoard.call("getScore")
end

function helperModule.getPlayer(playerColor)
    local player = constants.players[playerColor]
    assert(player, "Unknow player color: " .. tostring(playerColor))
    return player
end

function helperModule.hasPlayer(playerColor)
    return constants.players[playerColor] ~= nil
end

function helperModule.hasHighCouncilSeat(color)
    local councilZone = getObjectFromGUID("e51f6e")
    for _, object in ipairs(councilZone.getObjects()) do
        if object.getName() == color .. " Councilor" then
            return true
        end
    end
    return false
end

function helperModule.getTechName(techTile)
    local boardPlanetIx = getObjectFromGUID('d75455')
    -- More general alternative to tech.hasTag(techName)
    return boardPlanetIx.call("getTechName", techTile)
end

function helperModule.hasTech(playerColor, techName)
    local techs = constants.players[playerColor].techZone.getObjects()
    for _, tech in ipairs(techs) do
        if helperModule.getTechName(tech) == techName then
            return true
        end
    end
    return false
end

function helperModule.isAgent(object, color)
    local name = object.getName()
    if name == "" .. color .. " Agent" or name == "" .. color .. " Swordmaster" then
        return true
    elseif object.getName() == "Mentat" then
        return object.getColorTint() == constants.players[color].swordmaster.getColorTint()
    end
end

function helperModule.getDreadnoughtRestingPosition(dreadnoughName)
    local makerAndRecall = getObjectFromGUID('120026')
    return makerAndRecall.call("getDreadnoughtRestingPosition", dreadnoughName)
end

function helperModule.getPrestigeBonus(color)
    local prestige = 0

    if helperModule.hasHighCouncilSeat(color) then
        prestige = prestige + 2
    end
    if helperModule.hasTech(color, "minimic_film") then
        prestige = prestige + 1
    end

    local boardPlanetIx = getObjectFromGUID("d75455")
    local boardNormalCHOAMOverlay = getObjectFromGUID("0552a2")

    if boardPlanetIx and boardPlanetIx.call("hasAgentInTechNegotiation", color) then
        prestige = prestige + 1
    elseif boardNormalCHOAMOverlay and boardNormalCHOAMOverlay.call("hasAgentInHallOfOratory", color) then
        prestige = prestige + 1
    end

    return prestige
end

function helperModule.getRevealCardPosition(color, i)
    local offsets = {
        Red = Vector(13, 0.69, -5),
        Blue = Vector(13, 0.69, -5),
        Green = Vector(-13, 0.69, -5),
        Yellow = Vector(-13, 0.69, -5)
    }

    local step = 0
    if color == "Yellow" or color == "Green" then
        step = 2.5
    end
    if color == "Red" or color == "Blue" then
        step = -2.5
    end
    local p = constants.players[color].board.getPosition() + offsets[color]
    return p + Vector(i * step, 0, 0)
end

function helperModule.setSharedTable(tableName, table)
    local mainBoard = getObjectFromGUID('2da390')
    mainBoard.setTable(tableName, table)
end

function helperModule.getSharedTable(tableName)
    local mainBoard = getObjectFromGUID('2da390')
    return mainBoard.getTable(tableName)
end

return helperModule