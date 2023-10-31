i18n = require("i18n")
require("locales")

constants = require("Constants")

boardCommonModule = require("BoardCommonModule")

parkModule = require("ParkModule")

beetleAdvancing = false
researchAdvancing = false

--[[
    Research path for each player in a discrete 2D space (we use the usual X-Z
    coordinates from the Vector class for simpliciy). It abstracts us from the
    board layout.
]]
researchConducted = {
    Red = {},
    Blue = {},
    Green = {},
    Yellow = {}
}

function researchSpaceToWorldPosition(positionInResearchSpace)
    local offset = Vector(
        positionInResearchSpace.x * 1.2 + 1.2,
        2,
        positionInResearchSpace.z * 0.7 + 0.3)
    return researchTokenOrigin + offset
end

function createAxlotlTanksPark(playerColor)
    local offsets = {
        Red = Vector(-0.8, 0, 0.5),
        Blue = Vector(-0.8, 0, -0.5),
        Green = Vector(0.8, 0, 0.5),
        Yellow = Vector(0.8, 0, -0.5)
    }

    local origin = getObjectFromGUID("f5de09").getPosition() + offsets[playerColor]
    origin:setAt('y', 0.86) -- ground level
    local slots = {}
    for k = 1, 2 do
        for j = 1, 2 do
            for i = 1, 3 do
                local x = (i - 2) * 0.4
                local y = (k - 1) * 0.4
                local z = (1.5 - j) * 0.4
                local slot = Vector(x, y, z) + origin
                slots[#slots + 1] = slot
            end
        end
    end

    if not axlotlTanksZones[playerColor] then
        axlotlTanksZones[playerColor] = parkModule.findBoundingZone(0, Vector(0.35, 0.35, 0.35), slots)
    end

    return parkModule.createPark(
        "axlotlTanks." .. playerColor,
        slots,
        Vector(0, 0, 0),
        axlotlTanksZones[playerColor],
        playerColor,
        playerColor,
        true)
end

function getAveragePosition(positionField)
    local p = Vector(0, 0, 0)
    local count = 0
    for _, player in pairs(constants.players) do
        p = p + player[positionField]
        count = count + 1
    end
    return p * (1 / count)
end

function generateTleilaxuTrackPositions()
    local positions = {}
    local origin = getAveragePosition("tleilaxuTokens_inital_position")
    local xCoords = {1.3, 2.6, 3.9, 5.2, 7.4, 8.4, 9.2}
    for i, x in ipairs(xCoords) do
        positions[i] = origin + Vector(x, 2, 0.35)
    end
    return positions
end

_ = require("Core").registerLoadablePart(function(saved_data)
    self.interactable = false

    pos_TleilaxuTrack = generateTleilaxuTrackPositions()

    researchTokenOrigin = getAveragePosition("researchTokens_inital_position")

    specimen_zone = getObjectFromGUID("f5de09")

    axlotlTanksZones = {}

    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        researchConducted = loaded_data.researchConducted
        for _, path in pairs(researchConducted) do
            for i, coords in ipairs(path) do
                -- Needs to be reconstructed since objects are not saved as is.
                path[i] = Vector(coords.x, coords.y, coords.z)
            end
        end
        for color, GUID in pairs(loaded_data.axlotlTanksZoneGUIDs) do
            axlotlTanksZones[color] = getObjectFromGUID(GUID)
        end
    end

    axlotlTanksParks = {
        Green = createAxlotlTanksPark("Green"),
        Yellow = createAxlotlTanksPark("Yellow"),
        Blue = createAxlotlTanksPark("Blue"),
        Red = createAxlotlTanksPark("Red")
    }

    updateSave()

    AddSpecimenParams = {
        index = 0,
        click_function = "AddSpecimen",
        function_owner = self,
        label = i18n("addSpecimen"),
        position = {-0.47, 0.1, 0.6},
        scale = {0.1, 0.1, 0.1},
        width = 1550,
        height = 350,
        font_size = 300,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    }

    self.createButton(AddSpecimenParams)

    RemoveSpecimenParams = {
        index = 1,
        click_function = "RemoveSpecimen",
        function_owner = self,
        label = i18n("spentSpecimen"),
        position = {-0.47, 0.1, 0.80},
        scale = {0.1, 0.1, 0.1},
        width = 1550,
        height = 350,
        font_size = 300,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    }

    self.createButton(RemoveSpecimenParams)

    advanceTleilaxuParams = {
        index = 2,
        click_function = "advanceTleilaxu",
        function_owner = self,
        label = "→",
        position = {-0.8, 0.1, -0.475},
        scale = {0.15, 0.1, 0.2},
        width = 550,
        height = 250,
        font_size = 450,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1},
        tooltip = i18n("tleilaxuButtonTooltip")
    }

    self.createButton(advanceTleilaxuParams)

    backTleilaxuParams = {
        index = 3,
        click_function = "backTleilaxu",
        function_owner = self,
        label = "←",
        position = {-1.38, 0.1, -0.475},
        scale = {0.05, 0.1, 0.08},
        width = 550,
        height = 250,
        font_size = 450,
        color = {0.25, 0.25, 0.25, 1},
        font_color = "Red",
        tooltip = i18n("tleilaxuBackTooltip")
    }

    self.createButton(backTleilaxuParams)

    advanceUpResearchParams = {
        index = 4,
        click_function = "advanceUpResearch",
        function_owner = self,
        label = "→",
        position = {-0.95, 0.1, -0.21},
        rotation = {0, -30, 0},
        scale = {0.15, 0.2, 0.2},
        width = 550,
        height = 250,
        font_size = 450,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1},
        tooltip = i18n("researchUpButtonTooltip")
    }

    self.createButton(advanceUpResearchParams)

    advanceDownResearchParams = {
        index = 5,
        click_function = "advanceDownResearch",
        function_owner = self,
        label = "→",
        position = {-0.95, 0.1, 0.29},
        rotation = {0, 30, 0},
        scale = {0.15, 0.2, 0.2},
        width = 550,
        height = 250,
        font_size = 450,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1},
        tooltip = i18n("researchDownButtonTooltip")
    }

    self.createButton(advanceDownResearchParams)

    backResearchParams = {
        index = 6,
        click_function = "backResearch",
        function_owner = self,
        label = "←",
        position = {-1.38, 0.1, 0.025},
        scale = {0.0500000007450581, 0.100000001490116, 0.0799999982118607},
        width = 550,
        height = 250,
        font_size = 450,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.856, 0.1, 0.094, 1},
        tooltip = i18n("researchBackToolTip")
    }

    self.createButton(backResearchParams)

end)

function updateSave()
    local data_to_save = {
        researchConducted = researchConducted,
        axlotlTanksZoneGUIDs = {
            Red = axlotlTanksZones.Red.getGUID(),
            Green = axlotlTanksZones.Green.getGUID(),
            Blue = axlotlTanksZones.Blue.getGUID(),
            Yellow = axlotlTanksZones.Yellow.getGUID(),
        }
    }
    saved_data = JSON.encode(data_to_save)
    self.script_state = saved_data
end

function advanceUpResearch(obj, color)

    hideBrieflyResearchTrackButtons(obj)

    advanceResearchToken(color, "up")

end

function advanceDownResearch(obj, color)

    hideBrieflyResearchTrackButtons(obj)

    advanceResearchToken(color, "down")

end

function backResearch(obj, color)

    hideBrieflyResearchTrackButtons(obj)

    Player[color].showConfirmDialog(i18n("rollbackWarning"),
                                    function(color) rollBackResearch(color) end)
end

function hideBrieflyResearchTrackButtons(obj)
    obj.editButton({index = advanceUpResearchParams.index, scale = {0, 0, 0}})
    obj.editButton({index = advanceDownResearchParams.index, scale = {0, 0, 0}})
    obj.editButton({index = backResearchParams.index, scale = {0, 0, 0}})

    Wait.time(function()
        obj.editButton(advanceUpResearchParams)
        obj.editButton(advanceDownResearchParams)
        obj.editButton(backResearchParams)
    end, 1)
end

function advanceTleilaxu(obj, color)

    obj.editButton({index = advanceTleilaxuParams.index, scale = {0, 0, 0}})
    Wait.time(function() obj.editButton(advanceTleilaxuParams) end, 1)

    -- Player[color].showConfirmDialog(
    --     i18n("tleilaxuWarning"), function(color)
    moveBeneTleilaxToken(color)
    -- end)
end

function backTleilaxu(obj, color)

    obj.editButton({index = backTleilaxuParams.index, scale = {0, 0, 0}})
    Wait.time(function() obj.editButton(backTleilaxuParams) end, 1)

    Player[color].showConfirmDialog(i18n("rollbackWarning"), function(color)
        backBeneTleilaxToken(color)
    end)

end

function advanceResearchToken(color, verticalDirection)
    local playerResearchDone = researchConducted[color]
    local coords = playerResearchDone[#playerResearchDone]

    if coords then
        if verticalDirection == "up" then
            coords = coords + Vector(1, 0, 1)
        elseif verticalDirection == "down" then
            coords = coords + Vector(1, 0, -1)
        end
    else
        coords = Vector(0, 0, 0)
    end

    if coords.z > 2 then
        broadcastToColor(i18n("researchTopMost"), color, color)
    elseif coords.z < -3 then
        broadcastToColor(i18n("researchBottomMost"), color, color)
    elseif coords.x > 7 then
        broadcastToColor(i18n("researchEnd"), color, color)
    else
        local leaderName = helperModule.getLeaderName(color)
        broadcastToAll(i18n("researchIncreased"):format(leaderName), color)

        table.insert(playerResearchDone, coords)
        updateSave()

        local token = constants.players[color].researchTokens
        token.setPositionSmooth(researchSpaceToWorldPosition(coords), false, false)

        researchAdvancing = true
    end
end

function rollBackResearch(color)
    local playerResearchDone = researchConducted[color]

    if #playerResearchDone == 0 then
        broadcastToColor(i18n("researchStartingPos"), color, color)
    else
        local leaderName = helperModule.getLeaderName(color)
        broadcastToAll(i18n("researchDecreased"):format(leaderName), "Pink")

        table.remove(playerResearchDone, #playerResearchDone)
        updateSave()

        local p
        if #playerResearchDone > 0 then
            p = researchSpaceToWorldPosition(playerResearchDone[#playerResearchDone])
        else
            p = constants.players[color].researchTokens_inital_position
        end

        local token = constants.players[color].researchTokens
        token.setPositionSmooth(p, false, false)
        researchAdvancing = false
    end

end

function moveBeneTleilaxToken(color, silent)
    local silent = silent or false
    local token = constants.players[color].tleilaxuTokens
    local posToken = token.getPosition()
    local tokenMoved = false

    local leaderName = helperModule.getLeaderName(color)

    for _, posTleilaxu in ipairs(pos_TleilaxuTrack) do

        if not tokenMoved and posToken.x + 0.1 < posTleilaxu.x then
            beetleAdvancing = true
            token.setPositionSmooth(posTleilaxu, false, false)
            tokenMoved = true
            if not silent then
                broadcastToAll(i18n("tleilaxuIncreased"):format(leaderName),
                               color)
            end
        end
    end

    if not tokenMoved then
        broadcastToColor(i18n("tleilaxuMax"), color, color)
    end
end

function backBeneTleilaxToken(color)
    local token = constants.players[color].tleilaxuTokens
    local tokenMoved = false

    for index, posTleilaxu in ipairs(pos_TleilaxuTrack) do
        if index == 1 and token.getPosition().x + 0.1 < posTleilaxu.x then
            tokenMoved = true
        end

        if not tokenMoved and index == 1 then
            local tokenStarterPos = constants.players[color].tleilaxuTokens_inital_position
            tokenMoved = isBeetleRollBacked(token, 1.10, posTleilaxu.x,
                                            tokenStarterPos + constants.someHeight, color)
        end

        if not tokenMoved then
            tokenMoved = isBeetleRollBacked(token, posTleilaxu.x,
                                            pos_TleilaxuTrack[index + 1][1],
                                            posTleilaxu, color)
        end
    end
end

function isBeetleRollBacked(token, lowerThreshold, upperThreshold,
                            destinationPos, color)
    local leaderName = helperModule.getLeaderName(color)
    local tokenMoved = false

    if token.getPosition().x - 0.1 > lowerThreshold and token.getPosition().x -
        0.1 < upperThreshold then
        beetleAdvancing = false
        token.setPositionSmooth(destinationPos, false, false)
        tokenMoved = true
        broadcastToAll(i18n("tleilaxuDecreased"):format(leaderName), "Pink")
    end

    return tokenMoved
end

function moveTleilaxuCall(params)
    moveBeneTleilaxToken(params.color, params.silent)
    return true
end

function AddSpecimen(_, color, silent)
    assert(constants.players[color], "Action from an unknown player: " .. tostring(color))

    local orbit = constants.players[color].board.call("getOrbitPark")
    local axlotlTanks = axlotlTanksParks[color]

    local count = parkModule.transfert(1, orbit, axlotlTanks)

    if count > 0 then
        if not silent then
            local leaderName = helperModule.getLeaderName(color)
            broadcastToAll(i18n("specimenAdded"):format(leaderName), color)
        end
    else
        broadcastToColor(i18n("specimenLimitWarning"), color, "Purple")
    end
end

function RemoveSpecimen(_, color, silent)
    assert(constants.players[color], "Action from an unknown player: " .. tostring(color))

    local orbit = constants.players[color].board.call("getOrbitPark")
    local axlotlTanks = axlotlTanksParks[color]

    parkModule.transfert(1, axlotlTanks, orbit)

    if not silent then
        local leaderName = helperModule.getLeaderName(color)
        broadcastToAll(i18n("specimenRemoved"):format(leaderName), color)
    end
end

function RemoveSpecimenCall(params)
    RemoveSpecimen(params.osef, params.color, params.silent)
    return true
end

function onObjectEnterScriptingZone(zone, enter_object)

    if researchAdvancing and
        (zone.guid == "ab9e8d" or zone.guid == "d2b9be" or zone.guid == "79f487" or
            zone.guid == "d4fb57" or zone.guid == "1696ae" or zone.guid ==
            "95bb64" or zone.guid == "78a5cf") then
        for color, _ in pairs(constants.players) do

            if enter_object.hasTag(color) and
                enter_object.hasTag("ResearchToken") then

                AddSpecimen("", color, true)

                local leaderName = helperModule.getLeaderName(color)

                if zone.guid == "1696ae" then
                    moveBeneTleilaxToken(color, true)
                    broadcastToAll(i18n("researchSpecimenBeetle"):format(
                                       leaderName), color)
                elseif zone.guid == "95bb64" or zone.guid == "78a5cf" then
                    broadcastToAll(i18n("researchSpecimenTrash"):format(
                                       leaderName), color)

                else
                    broadcastToAll(i18n("researchSpecimen"):format(leaderName),
                                   color)
                end
            end
        end
    end

    if researchAdvancing and
        (zone.guid == "90e82d" or zone.guid == "1f11e0" or zone.guid == "e91e6b" or
            zone.guid == "f8c1b0" or zone.guid == "6c0d3e") then
        for color, _ in pairs(constants.players) do

            if enter_object.hasTag(color) and
                enter_object.hasTag("ResearchToken") then

                moveBeneTleilaxToken(color, true)
                local leaderName = helperModule.getLeaderName(color)
                broadcastToAll(i18n("researchBeetle"):format(leaderName), color)
            end
        end
    end

    if researchAdvancing and (zone.guid == "52bcf4") then
        for color, player in pairs(constants.players) do

            if enter_object.hasTag(color) and
                enter_object.hasTag("ResearchToken") then

                local solariIncome = 1
                local solari = "Solari"

                local leader = helperModule.getLeader(color)
                if leader and leader.hasTag("Yuna") then
                    solariIncome = 2
                    solari = "Solaris"
                end

                Wait.time(function()
                    player.solari.call("incrementVal")
                end, 0.25, solariIncome)

                local solariString = solariIncome .. " " .. solari

                local leaderName = helperModule.getLeaderName(color)
                broadcastToAll(i18n("researchIncome"):format(leaderName,
                                                             solariString),
                               color)
            end
        end
    end

    if researchAdvancing and zone.guid == "b60372" then
        for color, _ in pairs(constants.players) do

            if enter_object.hasTag(color) and
                enter_object.hasTag("ResearchToken") then

                local leaderName = helperModule.getLeaderName(color)
                broadcastToAll(i18n("researchFaction"):format(leaderName), color)
            end
        end
    end

    if researchAdvancing and (zone.guid == "f9ddaa" or zone.guid == "2a7803") then
        for color, player in pairs(constants.players) do

            if enter_object.hasTag(color) and
                enter_object.hasTag("ResearchToken") then

                local income = 1
                local spice = "Spice"

                if zone.guid == "2a7803" then
                    income = 2
                    spice = "Spices"
                end

                Wait.time(function()
                    player.spice.call("incrementVal")
                end, 0.25, income)

                local spiceString = income .. " " .. spice

                local leaderName = helperModule.getLeaderName(color)
                broadcastToAll(i18n("researchIncome"):format(leaderName,
                                                             spiceString), color)
            end
        end
    end

    if researchAdvancing and zone.guid == "8a3807" then
        for color, _ in pairs(constants.players) do

            if enter_object.hasTag(color) and
                enter_object.hasTag("ResearchToken") then

                local leaderName = helperModule.getLeaderName(color)
                broadcastToAll(i18n("researchTrashIntrigue"):format(leaderName),
                               color)
            end
        end
    end

    if researchAdvancing and
        (zone.guid == "659227" or zone.guid == "778685" or zone.guid == "6518bf") then
        for color, _ in pairs(constants.players) do

            if enter_object.hasTag(color) and
                enter_object.hasTag("ResearchToken") then

                if zone.guid == "6518bf" then
                    Wait.condition(function()
                        advanceResearchToken(color, "up")
                    end, function()
                        return not enter_object.isSmoothMoving()
                    end)
                else
                    Wait.condition(function()
                        advanceResearchToken(color, "down")
                    end, function()
                        return not enter_object.isSmoothMoving()
                    end)

                end

                local leaderName = helperModule.getLeaderName(color)
                broadcastToAll(i18n("researchAgain"):format(leaderName), color)
            end
        end
    end

    if researchAdvancing and zone.guid == "459e80" then
        for color, player in pairs(constants.players) do

            if enter_object.hasTag(color) and
                enter_object.hasTag("ResearchToken") then

                Player[color].showConfirmDialog(i18n("confirmSolarisToBeetles"),
                                                function(color)
                    local solariObj = player.solari
                    local price = 7

                    if solariObj.call("collectVal") < price then
                        broadcastToColor(i18n("noSolari"), color, color)
                    else
                        Wait.time(function()
                            solariObj.call("decrementVal")
                        end, 0.15, price)

                        local leaderName =
                            helperModule.getLeaderName(color)

                        moveBeneTleilaxToken(color, true)
                        Wait.condition(function()
                            moveBeneTleilaxToken(color, true)
                        end, function()
                            return not constants.players[color].tleilaxuTokens.isSmoothMoving()
                        end)

                        broadcastToAll(i18n("researchSolarisToBeetles"):format(
                                           leaderName), color)

                    end
                end)
            end
        end
    end

    if beetleAdvancing and (zone.guid == "1054b7" or zone.guid == "5d6083") then

        for color, _ in pairs(constants.players) do

            if enter_object.hasTag(color) and
                enter_object.hasTag("TleilaxuToken") then

                Wait.time(function()
                    boardCommonModule.drawIntrigue(color)
                end, 0.75)
                local leaderName = helperModule.getLeaderName(color)
                broadcastToAll(i18n("tleilaxuIntrigue"):format(leaderName),
                               color)
            end
        end
    end

    if beetleAdvancing and (zone.guid == "5e4d40" or zone.guid == "a1a4e8") then

        for color, player in pairs(constants.players) do

            if enter_object.hasTag(color) and
                enter_object.hasTag("TleilaxuToken") then

                local leaderName = helperModule.getLeaderName(color)
                giveTleilaxuVP(color)
                broadcastToAll(i18n("tleilaxuVP"):format(leaderName), color)

                local bonusSpiceCounter = getObjectFromGUID('46cd6b')
                local nbSpice = bonusSpiceCounter.call("collectVal")

                if nbSpice == 2 and zone.guid == "5e4d40" then
                    local t = 0
                    getObjectFromGUID('46cd6b').call("resetVal")

                    for i = 1, nbSpice, 1 do
                        Wait.time(function()
                            player.spice.call("incrementVal")
                        end, t)
                        t = t + (1.5 / nbSpice)
                    end

                    broadcastToAll(i18n("tleilaxuSpice"):format(leaderName),
                                   color)
                end
            end
        end
    end
end

function giveTleilaxuVP(color)
    helperModule.grantScoreTokenFromBag(color, getObjectFromGUID('082e07'))
end
