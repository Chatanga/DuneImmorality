i18n = require("i18n")
require("locales")

constants = require("Constants")

helperModule = require("HelperModule")

boardCommonModule = require("BoardCommonModule")

DrawOne = helperModule.DrawOne

players = constants.players

local techCosts = {
    windtraps = 2,
    detonation_devices = 3,
    memocorders = 2,
    flagship = 8,
    spaceport = 5,
    artillery = 1,
    holoprojectors = 2,
    restricted_ordnance = 4,
    shuttle_fleet = 6,
    spy_satellites = 4,
    disposal_facility = 3,
    chaumurky = 4,
    sonic_snoopers = 2,
    training_drones = 3,
    troop_transports = 2,
    holtzman_engine = 6,
    minimic_film = 2,
    invasion_ships = 5
}

local allTechTiles = {
    english = {
        windtraps = '3eb7b6',
        detonation_devices = '065d51',
        memocorders = '3938e5',
        flagship = 'c81426',
        spaceport = 'cf4203',
        artillery = 'fd26f9',
        holoprojectors = '613e52',
        restricted_ordnance = 'cc9e13',
        shuttle_fleet = '408909',
        spy_satellites = '70339e',
        disposal_facility = '57bb62',
        chaumurky = '3c6492',
        sonic_snoopers = '84ab7f',
        training_drones = 'c42af8',
        troop_transports = 'e13a99',
        holtzman_engine = 'aa3745',
        minimic_film = '630428',
        invasion_ships = 'd92994'
    },
    french = {
        windtraps = 'a9c164',
        detonation_devices = 'e81010',
        memocorders = 'b69554',
        flagship = '9896fc',
        spaceport = '3d0abb',
        artillery = 'd587c2',
        holoprojectors = '601011',
        restricted_ordnance = 'af2140',
        shuttle_fleet = '42454c',
        spy_satellites = '32b07b',
        disposal_facility = '560202',
        chaumurky = '10a87f',
        sonic_snoopers = '5e7a52',
        training_drones = '5bab3e',
        troop_transports = 'bf8ad7',
        holtzman_engine = '058ca0',
        minimic_film = '7bc7f5',
        invasion_ships = '4eee41'
    }
}

local techDiscounts = {}

local techSlotZones = {}

local negotiationZones = {}

local negotiationParks = {}

_ = require("Core").registerLoadablePart(function(savedData)
    self.interactable = false

    if savedData ~= '' then
        local state = JSON.decode(savedData)
        for i, zoneGUID in ipairs(state.techSlotZoneGUIDs) do
            techSlotZones[i] = getObjectFromGUID(zoneGUID)
        end
        for color, GUID in pairs(state.negotiationZoneGUIDs) do
            negotiationZones[color] = getObjectFromGUID(GUID)
        end
    else
        createTechZones()
    end

    negotiationParks = {
        Green = createNegotiationPark("Green"),
        Yellow = createNegotiationPark("Yellow"),
        Blue = createNegotiationPark("Blue"),
        Red = createNegotiationPark("Red")
    }

    Dreadnought_zone = getObjectFromGUID("83ea90")
    TechNegociation_zone = getObjectFromGUID("04f512")
    activateButtons()
end)

function onLocaleChange()
    self.clearButtons()
    activateButtons()
end

function saveState()
    local state = {
        techSlotZoneGUIDs = {},
        negotiationZoneGUIDs = {}
    }
    for i, zone in ipairs(techSlotZones) do
        state.techSlotZoneGUIDs[i] = zone.getGUID()
    end
    for color, zone in pairs(negotiationZones) do
        state.negotiationZoneGUIDs[color] = zone.getGUID()
    end
    self.script_state = JSON.encode(state)
end

function activateButtons()

    for i, zone in ipairs(techSlotZones) do
        helperModule.createAbsoluteButtonWithRoundness(self, 0.2, false, {
            label = i18n("acquireButton"),
            click_function = "acquireTech" .. tostring(i),
            function_owner = self,
            position = zone.getPosition() + Vector(0, -0.1, -0.65),
            color = {0.25, 0.25, 0.25, 1},
            font_color = {1, 1, 1, 1},
            height = 400 * 0.3,
            width = 1600 * 0.3,
            font_size = 400 * 0.3
        })
    end

    self.createButton({
        label = i18n("addNegotiator"),
        click_function = "addNegotiator",
        function_owner = self,
        position = Vector(-0.25, 0.1 , 0.8),
        scale = Vector(0.18, 0.18, 0.18),
        width = 350,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })

    self.createButton({
        click_function = "removeNegotiator",
        function_owner = self,
        label = i18n("removeNegotiator"),
        position = Vector(-0.05, 0.1 , 0.8),
        scale = Vector(0.18, 0.18, 0.18),
        width = 350,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })

    self.createButton({
        click_function = "TechNegotiation",
        function_owner = self,
        label = "get",
        position = {-0.2, 0.1, -0.4},
        scale = {0.18, 0.18, 0.18},
        width = 400,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })

    self.createButton({
        click_function = "Dreadnought",
        function_owner = self,
        label = "pay & get",
        position = {-0.2, 0.1 , 0.1},
        scale = {0.18, 0.18, 0.18},
        width = 900,
        height = 350,
        font_size = 200,
        color = {0.25, 0.25, 0.25, 1},
        font_color = {0.7843, 0.7843, 0.7843, 1}
    })

end

function createTechZones()

    local origin = constants.getLandingPositionFromGUID(constants.ixPlanetBoard)
    local techSlotPositions = {
        Vector(1.69, 3.02, 2.35) + origin,
        Vector(1.69, 3.02, 0.30) + origin,
        Vector(1.69, 3.02, -1.75) + origin
    }

    techSlotZones = {}
    for _, position in ipairs(techSlotPositions) do
        spawnObject({
            type= 'ScriptingTrigger',
            position = position + Vector(0, -2.5, 0),
            rotation = Vector(0, 0, 0),
            scale = Vector(3, 2, 2),
            callback_function = function (zone)
                techSlotZones[#techSlotZones + 1] = zone
                if #techSlotZones == 3 then
                    self.clearButtons()
                    activateButtons()
                    saveState()
                end
            end
        })
    end
end

function acquireTech1(object, playerColor)
    acquireTech(1, object, playerColor)
end

function acquireTech2(object, playerColor)
    acquireTech(2, object, playerColor)
end

function acquireTech3(object, playerColor)
    acquireTech(3, object, playerColor)
end

function acquireTech(index, _, playerColor)
    if playerColor ~= "Red" and playerColor ~= "Blue" and playerColor ~= "Green" and playerColor ~= "Yellow" then
        broadcastToColor(i18n("noTouch"), playerColor, {1, 0.011765, 0})
        return
    end

    -- Easier to separate the two of them because the top tile share the same Y coordinate as the one below.
    local otherTiles = {}
    local topTile = nil
    for _, object in ipairs(techSlotZones[index].getObjects()) do
        if object.getDescription() == "Tech" then
            if not object.is_face_down then
                topTile = object
            else
                otherTiles[#otherTiles + 1] = object
            end
        end
    end
    table.sort(otherTiles, function (t1, t2) return t1.getPosition().y > t2.getPosition().y end)

    if topTile then
        local techName = getTechName(topTile)
        local techCost = techCosts[techName]

        local discount = techDiscounts[playerColor]
        local discountAmount = 0
        if discount then
            discountAmount = discount.amount
        end
        local negotiatorCount = #parkModule.getObjects(negotiationParks[playerColor])

        local adjustedTechCost = math.max(0, techCost - discountAmount - negotiatorCount)
        local recalledNegociatorCount = math.max(0, techCost - adjustedTechCost - discountAmount)

        if paySpiceCost(playerColor, adjustedTechCost) then

            local orbit = constants.players[playerColor].board.call("getOrbitPark")
            local negotiation = negotiationParks[playerColor]
            parkModule.transfert(recalledNegociatorCount, negotiation, orbit)

            self.clearButtons()
            Wait.time(function() activateButtons() end, 1)

            local leaderName = helperModule.getLeaderName(playerColor)
            local spiceCost
            if adjustedTechCost == 0 then
                spiceCost = i18n("freeAsInBeer")
            elseif adjustedTechCost == 1 then
                spiceCost = tostring(adjustedTechCost) .. " " .. i18n("spice")
            else
                spiceCost = tostring(adjustedTechCost) .. " " .. i18n("spices")
            end
            broadcastToAll(i18n("acquireTech"):format(leaderName, i18n(techName), spiceCost), playerColor)

            techDiscounts[playerColor] = nil

            helperModule.grantTechTile(playerColor, topTile)
            if #otherTiles > 0 then
                otherTiles[1].flip()
            end

            applyBuyEffect(playerColor, techName)
        end
    else
        log("No tiles!")
    end

end

function paySpiceCost(color, cost)
    return transfertResources(color, "spice", -cost, "noSpice")
end

function transfertResources(color, type, amount, errorMessage)
    local spice = constants.players[color][type]

    if spice.call("collectVal") < -amount then
        if errorMessage then
            broadcastToColor(i18n(errorMessage), color, color)
        end
        return false
    end

    local t = 0
    for _ = 1, math.abs(amount) do
        Wait.time(function()
            if amount > 0 then
                spice.call("incrementVal")
            else
                spice.call("decrementVal")
            end
        end, t)
        t = t + 0.2
    end

    return true
end

function applyBuyEffect(color, techName)
    local message = nil

    if techName == "windtraps" then
        transfertResources(color, "water", 1, nil)
        message = "acquireWindrapsTechBenefits"
    elseif techName == "detonation_devices" then
    elseif techName == "memocorders" then
        -- 1 influence
    elseif techName == "flagship" then
        local vpToken = getObjectFromGUID("366237")
        helperModule.grantScoreToken(color, vpToken)
        message = "acquireFlagshipTechBenefits"
    elseif techName == "spaceport" then
        helperModule.DrawCards(2, color, nil)
        message = "acquireSpaceportTechBenefits"
    elseif techName == "artillery" then
    elseif techName == "holoprojectors" then
    elseif techName == "restricted_ordnance" then
    elseif techName == "shuttle_fleet" then
        -- 2 influences différentes
    elseif techName == "spy_satellites" then
    elseif techName == "disposal_facility" then
        -- 1 trash
    elseif techName == "chaumurky" then
        local intrigueDeck = getObjectFromGUID(constants.intrigue_base)
        intrigueDeck.deal(2, color)
        message = "acquireChamurkyTechBenefits"
    elseif techName == "sonic_snoopers" then
        local intrigueDeck = getObjectFromGUID(constants.intrigue_base)
        intrigueDeck.deal(1, color)
        message = "acquireSonicSnoopersBenefits"
    elseif techName == "training_drones" then
    elseif techName == "troop_transports" then
    elseif techName == "holtzman_engine" then
    elseif techName == "minimic_film" then
    elseif techName == "invasion_ships" then
        helperModule.landTroopsFromOrbit(color, 4)
        message = "acquireInvasionShipsBenefits"
    end

    if message then
        local leaderName = helperModule.getLeaderName(color)
        broadcastToAll(i18n(message):format(leaderName), color)
    end
end

function getTechName(techTile)
    for _, techTiles in pairs(allTechTiles) do
        for name, GUID in pairs(techTiles) do
            if techTile.getGUID() == GUID then
                return name
            end
        end
    end
    return "?"
end

function callRegisterTechDiscount(parameters)
    registerTechDiscount(parameters.color, parameters.source, parameters.amount)
end

function registerTechDiscount(color, source, amount)
    techDiscounts[color] = {
        source = source,
        amount = amount
    }
end

function onPlayerTurn(playerColor, previousPlayerColor)
    if previousPlayerColor then
        techDiscounts[previousPlayerColor] = nil
    end
end

function createNegotiationPark(playerColor)
    local offsets = {
        Red = Vector(-0.45, 0, 0.45),
        Blue = Vector(-0.45, 0, -0.45),
        Green = Vector(0.45, 0, 0.45),
        Yellow = Vector(0.45, 0, -0.45)
    }

    local baseOffset = Vector(-0.75, 0, -1.5)

    local origin = constants.getLandingPositionFromGUID(constants.ixPlanetBoard) + baseOffset + offsets[playerColor]
    origin:setAt('y', 0.86) -- ground level
    local slots = {}
    for k = 1, 2 do
        for j = 1, 2 do
            for i = 1, 2 do
                local x = (i - 1) * 0.4
                local y = (k - 1) * 0.4
                local z = (1 - j) * 0.4
                local slot = Vector(x, y, z) + origin
                slots[#slots + 1] = slot
            end
        end
    end

    if not negotiationZones[playerColor] then
        negotiationZones[playerColor] = parkModule.findBoundingZone(0, Vector(0.25, 0.25, 0.25), slots)
    end

    return parkModule.createPark(
        "negotiation." .. playerColor,
        slots,
        Vector(0, 0, 0),
        negotiationZones[playerColor],
        playerColor,
        playerColor,
        false)
end

function addNegotiator(_, color, silent)
    assert(constants.players[color], "Action from an unknown player: " .. tostring(color))

    local orbit = constants.players[color].board.call("getOrbitPark")
    local negotiation = negotiationParks[color]

    local count = parkModule.transfert(1, orbit, negotiation)

    if count > 0 then
        if not silent then
            local leaderName = helperModule.getLeaderName(color)
            broadcastToAll(i18n("negotiatorAdded"):format(leaderName), color)
        end
    else
        broadcastToColor(i18n("negotiatorLimitWarning"), color, "Purple")
    end
end

function removeNegotiator(_, color, silent)
    assert(constants.players[color], "Action from an unknown player: " .. tostring(color))

    local orbit = constants.players[color].board.call("getOrbitPark")
    local negotiation = negotiationParks[color]

    parkModule.transfert(1, negotiation, orbit)

    if not silent then
        local leaderName = helperModule.getLeaderName(color)
        broadcastToAll(i18n("negotiatorRemoved"):format(leaderName), color)
    end
end

function TechNegotiation(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)

    if boardCommonModule.CheckAgentAndPlayer(color, TechNegociation_zone) then
        local leaderName = helperModule.getLeaderName(color)

        local orbit = constants.players[color].board.call("getOrbitPark")
        local negotiation = negotiationParks[color]

        local count = parkModule.transfert(1, orbit, negotiation)

        if count > 0 then
            if not silent then
                broadcastToAll(i18n("negotiatorAdded"):format(leaderName), color)
            end
        else
            registerTechDiscount(color, "tech_negotiation", 1)
        end

        constants.players[color].board.call("updateSpecialSummaryCards")
    end
end

function Dreadnought(_, color)
    self.clearButtons()
    Wait.time(activateButtons, 1)

    agentCheck = 0
    local t = 0

    if boardCommonModule.CheckAgentAndPlayer(color, Dreadnought_zone) then

        local leader = helperModule.getLeader(color)
        assert(leader)
        local leaderName = leader.getName()
        local solariObj = constants.players[color].solari

        local price = 3


        if leader.hasTag("Leto") then price = 2 end

        if solariObj.call("collectVal") < price then

            broadcastToColor(i18n("noSolari"), color, color)
        else

            for i = 1, price, 1 do
                Wait.time(function()
                    solariObj.call("decrementVal")
                end, t)
                t = t + 0.25
            end

            registerTechDiscount(color, "dreadnought", 0)

            buyDreadnought(_, color)

            if leader.hasTag("Ilban") then

                local numberToDraw = 1

                local enoughCards = helperModule.isDeckContainsEnough(color, numberToDraw)

                if not enoughCards then
                    broadcastToAll(i18n("dreadBuy"):format(leaderName, price),
                                   color)

                    broadcastToAll(i18n("isDecidingToDraw"):format(leaderName),
                                   "Pink")
                    local card = i18n("cards")
                    if numberToDraw == 1 then
                        card = i18n("card")
                    end
                    Player[color].showConfirmDialog(
                        i18n("warningBeforeDraw"):format(numberToDraw, card),
                        function(player_color)
                            DrawOne(_, color)
                            broadcastToAll(i18n("ilbanDraw"):format(leaderName),
                                           color)
                        end)
                else
                    DrawOne(_, color)
                    broadcastToAll(i18n("dreadBuy"):format(leaderName, price),
                                   color)
                    broadcastToAll(i18n("ilbanDraw"):format(leaderName), color)

                end
            else
                broadcastToAll(i18n("dreadBuy"):format(leaderName, price), color)
            end

        end
    end
end

function buyDreadnought(_, color)
    local objects = constants.players[color].zone_player.getObjects()
    for _, object in ipairs(objects) do
        local p = helperModule.getDreadnoughtRestingPosition(object.getName())
        if p then
            object.setPositionSmooth(p, false, false)
            break
        end
    end
end

function hasAgentInTechNegotiation(color)
    return boardCommonModule.hasAgentInSpace(color, TechNegociation_zone)
end