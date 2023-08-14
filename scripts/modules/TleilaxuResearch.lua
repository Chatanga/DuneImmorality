local TleilaxuResearch = {
    beetleAdvancing = false,
    researchAdvancing = false,
    --[[
        Research path for each player in a discrete 2D space (we use the usual X-Z
        coordinates from the Vector class for simpliciy). It abstracts us away from
        the board layout.
    ]]
    researchConducted = {
        Red = {},
        Blue = {},
        Green = {},
        Yellow = {}
    },

    board = "d5c2db",
    specimenZone = "f5de09",
    --firstLimitZone = "042b49",
    --firstLimitAfterZone = "da08cd",
    --secondLimitZone = "60a0fd",
    --firstIntrigueBonusZone = "1054b7",
    --victoryPointAndSpiceBonusZone = "5e4d40",
    --secondIntrigueBonusZone = "5d6083",
    --victoryPointBonusZone = "a1a4e8",
    tleilaxuBonusSpice = "46cd6b",
    --[[
    cells = {
        "ab9e8d",
        "d2b9be",
        "90e82d",
        "659227",
        "95bb64",
        "1696ae",
        "1f11e0",
        "79f487",
        "6518bf",
        "778685",
        "d4fb57",
        "52bcf4",
        "f9ddaa",
        "e91e6b",
        "b60372",
        "f8c1b0",
        "8a3807",
        "78a5cf",
        "2a7803",
        "6c0d3e",
        "459e80"
    }
    ]]--
    tleilaxuCardCostByName = {
        beguiling_pheromones = 3,
        dogchair = 2,
        contaminator = 1,
        corrino_genes = 1,
        face_dancer = 2,
        face_dancer_initiate = 1,
        from_the_tanks = 2,
        ghola = 3,
        guild_impersonator = 2,
        industrial_espionage = 1,
        scientific_breakthrough = 3,
        slig_farmer = 2,
        stitched_horror = 3,
        subject_x_137 = 2,
        tleilaxu_infiltrator = 2,
        twisted_mentat = 4,
        unnatural_reflexes = 3,
        usurper = 4,
        piter_genius_advisor = 3
    }
}

--[[

getSpecimenCount(color)
hasReachedOneHelix(color)
hasReachedTwoHelices(color)
getDreadnoughtRestingPosition(dreadnoughName)

]]--

-- 2 tleilaxu bonus
--resource.init(nil, "spice", 2, savedData)

---
function TleilaxuResearch.setUp()
end

---
function TleilaxuResearch.tearDown()
    local board = getObjectFromGUID("d5c2db")
    board.destruct()
    local spiceBonus = getObjectFromGUID('46cd6b')
    spiceBonus.destruct()
end

function TleilaxuResearch.__onLoad(savedData)
    self.interactable = false

    pos_TleilaxuTrack = generateTleilaxuTrackPositions()

    researchTokenOrigin = getAveragePosition("researchTokens_inital_position")

    specimen_zone = getObjectFromGUID("f5de09")

    axlotlTanksZones = {}

    if savedData ~= "" then
        local state = JSON.decode(savedData)
        researchConducted = state.researchConducted
        for color, GUID in pairs(state.axlotlTanksZoneGUIDs) do
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

    activateButtons()
end

---
function TleilaxuResearch.updateSave()
    local state = {
        researchConducted = researchConducted,
        axlotlTanksZoneGUIDs = {
            Red = axlotlTanksZones.Red.getGUID(),
            Green = axlotlTanksZones.Green.getGUID(),
            Blue = axlotlTanksZones.Blue.getGUID(),
            Yellow = axlotlTanksZones.Yellow.getGUID(),
        }
    }
    self.script_state = JSON.encode(state)
end

---
function TleilaxuResearch.onLocaleChange()
    self.clearButtons()
    activateButtons()
end

---
function TleilaxuResearch.activateButtons()

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

    rollbackResearchParams = {
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
    self.createButton(rollbackResearchParams)
end

---
function TleilaxuResearch.researchSpaceToWorldPosition(positionInResearchSpace)
    local offset = Vector(
        positionInResearchSpace.x * 1.2 + 1.2,
        2,
        positionInResearchSpace.z * 0.7)
    return researchTokenOrigin + offset
end

---
function TleilaxuResearch.createAxlotlTanksPark(playerColor)
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
                table.insert(slots, slot)
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
        { "Troop", playerColor },
        nil,
        true)
end

---
function TleilaxuResearch.getAveragePosition(positionField)
    local p = Vector(0, 0, 0)
    local count = 0
    for _, player in pairs(constants.players) do
        p = p + player[positionField]
        count = count + 1
    end
    return p * (1 / count)
end

---
function TleilaxuResearch.generateTleilaxuTrackPositions()
    local positions = {}
    local origin = getAveragePosition("tleilaxuTokens_inital_position")
    local xCoords = {1.3, 2.6, 3.9, 5.2, 7.4, 8.4, 9.2}
    for i, x in ipairs(xCoords) do
        positions[i] = origin + Vector(x, 2, 0)
    end
    return positions
end

---
function TleilaxuResearch.advanceUpResearch(obj, color)
    hideBrieflyResearchTrackButtons(obj)
    advanceResearchToken(color, "up")
end

---
function TleilaxuResearch.advanceDownResearch(obj, color)
    hideBrieflyResearchTrackButtons(obj)
    advanceResearchToken(color, "down")
end

---
function TleilaxuResearch.rollbackResearch(obj, color)
    hideBrieflyResearchTrackButtons(obj)
    Player[color].showConfirmDialog(i18n("rollbackWarning"), function(color) rollrollbackResearch(color) end)
end

---
function TleilaxuResearch.hideBrieflyResearchTrackButtons(obj)
    obj.editButton({index = advanceUpResearchParams.index, scale = {0, 0, 0}})
    obj.editButton({index = advanceDownResearchParams.index, scale = {0, 0, 0}})
    obj.editButton({index = rollbackResearchParams.index, scale = {0, 0, 0}})

    Wait.time(function()
        obj.editButton(advanceUpResearchParams)
        obj.editButton(advanceDownResearchParams)
        obj.editButton(rollbackResearchParams)
    end, 1)
end

---
function TleilaxuResearch.advanceTleilaxu(obj, color)
    obj.editButton({index = advanceTleilaxuParams.index, scale = {0, 0, 0}})
    Wait.time(function() obj.editButton(advanceTleilaxuParams) end, 1)
    moveBeneTleilaxToken(color)
end

---
function TleilaxuResearch.backTleilaxu(obj, color)
    obj.editButton({index = backTleilaxuParams.index, scale = {0, 0, 0}})
    Wait.time(function() obj.editButton(backTleilaxuParams) end, 1)

    Player[color].showConfirmDialog(i18n("rollbackWarning"), function(color)
        backBeneTleilaxToken(color)
    end)
end

---
function TleilaxuResearch.advanceResearchToken(color, verticalDirection)
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
        local leaderName = helper.getLeaderName(color)
        broadcastToAll(i18n("researchIncreased"):format(leaderName), color)

        table.insert(playerResearchDone, coords)
        updateSave()

        local token = constants.players[color].researchTokens
        token.setPositionSmooth(researchSpaceToWorldPosition(coords), false, false)

        researchAdvancing = true
    end
end

---
function TleilaxuResearch.rollrollbackResearch(color)
    local playerResearchDone = researchConducted[color]

    if #playerResearchDone == 0 then
        broadcastToColor(i18n("researchStartingPos"), color, color)
    else
        local leaderName = helper.getLeaderName(color)
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

---
function TleilaxuResearch.moveBeneTleilaxToken(color, silent)
    local token = constants.players[color].tleilaxuTokens
    local posToken = token.getPosition()
    local tokenMoved = false

    local leaderName = helper.getLeaderName(color)

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

---
function TleilaxuResearch.backBeneTleilaxToken(color)
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

---
function TleilaxuResearch.isBeetleRollBacked(token, lowerThreshold, upperThreshold,
                            destinationPos, color)
    local leaderName = helper.getLeaderName(color)
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

---
function TleilaxuResearch.moveTleilaxuCall(params)
    moveBeneTleilaxToken(params.color, params.silent)
    return true
end

---
function TleilaxuResearch.AddSpecimen(_, color, silent)
    assert(constants.players[color], "Action from an unknown player: " .. tostring(color))

    local orbit = constants.players[color].board.call("getOrbitPark")
    local axlotlTanks = axlotlTanksParks[color]

    local count = parkModule.transfert(1, orbit, axlotlTanks)

    if count > 0 then
        if not silent then
            local leaderName = helper.getLeaderName(color)
            broadcastToAll(i18n("specimenAdded"):format(leaderName), color)
        end
    else
        broadcastToColor(i18n("specimenLimitWarning"), color, "Purple")
    end
end

---
function TleilaxuResearch.RemoveSpecimen(_, color, silent)
    assert(constants.players[color], "Action from an unknown player: " .. tostring(color))

    local orbit = constants.players[color].board.call("getOrbitPark")
    local axlotlTanks = axlotlTanksParks[color]

    parkModule.transfert(1, axlotlTanks, orbit)

    if not silent then
        local leaderName = helper.getLeaderName(color)
        broadcastToAll(i18n("specimenRemoved"):format(leaderName), color)
    end
end

---
function TleilaxuResearch.RemoveSpecimenCall(params)
    RemoveSpecimen(nil, params.color, params.silent)
    return true
end

--[[
    TODO Wouldn't it be better to do it directly in the move/back functions?
]]--
---
function TleilaxuResearch.onObjectEnterScriptingZone(zone, enter_object)
    local color = TleilaxuResearch.getResearchTokenOwner(enter_object)
    if color then
        if researchAdvancing then
            TleilaxuResearch.advanceResearch(zone, color)
        elseif beetleAdvancing then
            TleilaxuResearch.advanceBeetle(zone, color)
        end
    end
end

---
function TleilaxuResearch.advanceResearch(zone, color)
    local leaderName = helper.getLeader(color).getName()

    local allCellBenefits = {
        ["ab9e8d"] = { specimen = true },
        ["d2b9be"] = { specimen = true },
        ["79f487"] = { specimen = true },
        ["d4fb57"] = { specimen = true },
        ["1696ae"] = { beetle = true },
        ["95bb64"] = { trashSpecimen = true },
        ["78a5cf"] = { trashSpecimen = true },
        ["90e82d"] = { beetle = true },
        ["1f11e0"] = { beetle = true },
        ["e91e6b"] = { beetle = true },
        ["f8c1b0"] = { beetle = true },
        ["6c0d3e"] = { beetle = true },
        ["52bcf4"] = { beetle = true },
        ["f9ddaa"] = { spice = 1 },
        ["2a7803"] = { spice = 2 },
        ["8a3807"] = { trashIntrigue = true },
        ["659227"] = { research = "up" },
        ["778685"] = { research = "down" },
        ["6518bf"] = { research = "down" },
        ["459e80"] = { solariToBeetle = 7 }
    }

    local cellBenefits = allCellBenefits[zone.guid]
    assert(cellBenefits)

    for _, resource in ipairs({"spice", "solari"}) do
        if cellBenefits[resource] then
            boardCommonModule.gainResource(color, resource, cellBenefits[resource])
            local counter = i18n.translateCountable(cellBenefits[resource], resource, resource .. "s")
            broadcastToAll(i18n("researchIncome"):format(leaderName, counter), color)
        end
    end

    if cellBenefits.specimen then
        AddSpecimen(nil, color, true)
        broadcastToAll(i18n("researchSpecimen"):format(leaderName), color)
    end

    if cellBenefits.beetle then
        moveBeneTleilaxToken(color, true)
        broadcastToAll(i18n("researchBeetle"):format(leaderName), color)
    end

    if cellBenefits.trashIntrigue then
        broadcastToAll(i18n("researchTrashIntrigue"):format(leaderName), color)
    end

    if cellBenefits.research then
        Wait.condition(function()
            advanceResearchToken(color, cellBenefits.research)
        end, function()
            return not enter_object.isSmoothMoving()
        end)
        broadcastToAll(i18n("researchAgain"):format(leaderName), color)
    end

    if cellBenefits.solariToBeetle then
        Player[color].showConfirmDialog(i18n("confirmSolarisToBeetles"), function(_)
            if boardCommonModule.payResource(color, "solari", cellBenefits.solariToBeetle) then
                helper.repeatMovingAction(object, function() moveBeneTleilaxToken(color, true) end , 2)
                broadcastToAll(i18n("researchSolarisToBeetles"):format( leaderName), color)
            end
        end)
    end
end

---
function TleilaxuResearch.advanceBeetle(zone, color)
    local leaderName = helper.getLeader(color).getName()

    local allCellBenefits = {
        ["1054b7"] = { intrigue = true },
        ["5d6083"] = { intrigue = true },
        ["5e4d40"] = { victoryToken = true, spiceBonus = true },
        ["a1a4e8"] = { victoryToken = true }
    }

    local cellBenefits = allCellBenefits[zone.guid]
    assert(cellBenefits)

    if cellBenefits.intrigue then
        boardCommonModule.drawIntrigue(color)
        broadcastToAll(i18n("tleilaxuIntrigue"):format(leaderName), color)
    end

    if cellBenefits.victoryToken then
        helper.grantScoreTokenFromBag(color, getObjectFromGUID('082e07'))
        broadcastToAll(i18n("tleilaxuVP"):format(leaderName), color)
    end

    if cellBenefits.spiceBonus then
        local spiceBonus = getObjectFromGUID('46cd6b')
        local spiceCount = spiceBonus.call("collectVal")

        if spiceCount > 0 then
            spiceBonus.call("resetVal")
            boardCommonModule.gainResource(color, "spice", spiceCount)
            broadcastToAll(i18n("tleilaxuSpice"):format(leaderName), color)
        end
    end
end

---
function TleilaxuResearch.getResearchTokenOwner(object)
    --[[
    for color, _ in pairs(constants.players) do
        if object.hasTag(color) and object.hasTag("ResearchToken") then
            return color
        end
    end
    ]]--
    return nil
end

---
function TleilaxuResearch.hasReachedOneHelices()
    error("TODO")
end

---
function TleilaxuResearch.hasReachedOneHelix(color)
    local scriptZone_middleTrack_research = getObjectFromGUID("60a0fd")
    local objs = scriptZone_middleTrack_research.getObjects()
    for _, item in ipairs(objs) do
        if item.hasTag(color) then
            return true
        end
    end
    return false
end

---
function TleilaxuResearch.hasReachedTwoHelices(color)
    local scriptZone_endTrack_research = getObjectFromGUID("da08cd")
    local objs = scriptZone_endTrack_research.getObjects()
    local maxSearch = false
    for _, item in ipairs(objs) do
        if item.hasTag(color) then maxSearch = true end
    end
    return maxSearch
end

---
function TleilaxuResearch.getSpecimenCount(color)
    local specimenCount = 0
    for _, object in ipairs(constants.structure.immortalityBoard.specimenZone.getObjects()) do
        if object.hasTag("Troop") and object.hasTag(color) then
            specimenCount = specimenCount + 1
        end
    end
    return specimenCount
end

return TleilaxuResearch
