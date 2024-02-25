local boardCommonModule = {}

core = require("Core")

i18n = require("i18n")
require("locales")

constants = require("Constants")

helperModule = require("HelperModule")

DrawOne = helperModule.DrawOne

-- Beware that this variable is processed on loading to resolve its GUIDs.
pion_reput = {
    emperor = {
        Red = 'acfcef',
        Blue = '426a23',
        Green = 'd7c9ba',
        Yellow = '489871'
    },
    spacingGuild = {
        Red = 'be464e',
        Blue = '4069d8',
        Green = '89da7d',
        Yellow = '9d0075'
    },
    beneGesserit = {
        Red = '713eae',
        Blue = '2a88a6',
        Green = '2dc980',
        Yellow = 'a3729e'
    },
    fremen = {
        Red = '088f51',
        Blue = '0e6e41',
        Green = 'd390dc',
        Yellow = '77d7c8'
    }
}

initial_position_pion_reput = {
    emperor = {
        Red = core.getHardcodedPositionFromGUID('acfcef', -9.718932, 0.752500057, 1.85001969),
        Blue = core.getHardcodedPositionFromGUID('426a23', -10.1873131, 0.7525, 1.85005844),
        Green = core.getHardcodedPositionFromGUID('d7c9ba', -9.273371, 0.754999936, 1.85001135),
        Yellow = core.getHardcodedPositionFromGUID('489871', -8.834659, 0.755000055, 1.8500545)
    },
    spacingGuild = {
        Red = core.getHardcodedPositionFromGUID('be464e', -9.737917, 0.752500057, -3.64000726),
        Blue = core.getHardcodedPositionFromGUID('4069d8', -10.1552429, 0.7525, -3.64000773),
        Green = core.getHardcodedPositionFromGUID('89da7d', -9.288127, 0.754999936, -3.64001036),
        Yellow = core.getHardcodedPositionFromGUID('9d0075', -8.846331, 0.755000055, -3.63998413)
    },
    beneGesserit = {
        Red = core.getHardcodedPositionFromGUID('713eae', -9.766583, 0.752500057, -9.100027),
        Blue = core.getHardcodedPositionFromGUID('2a88a6', -10.2121153, 0.7525, -9.100084),
        Green = core.getHardcodedPositionFromGUID('2dc980', -9.319731, 0.754999936, -9.100017),
        Yellow = core.getHardcodedPositionFromGUID('a3729e', -8.888711, 0.755000055, -9.100081)
    },
    fremen = {
        Red = core.getHardcodedPositionFromGUID('088f51', -9.762483, 0.752500057, -14.5700312),
        Blue = core.getHardcodedPositionFromGUID('0e6e41', -10.2238894, 0.7525, -14.5700541),
        Green = core.getHardcodedPositionFromGUID('d390dc', -9.328378, 0.754999936, -14.570013),
        Yellow = core.getHardcodedPositionFromGUID('77d7c8', -8.88775, 0.755000055, -14.5700016)
    }
}

initial_alliance_pos = {
    emperor = core.getHardcodedPositionFromGUID('13e990', -9.511963, 0.780000031, 5.860889),
    spacingGuild = core.getHardcodedPositionFromGUID('ad1aae', -9.507135, 0.780000031, 0.249080971),
    beneGesserit = core.getHardcodedPositionFromGUID('33452e', -9.551374, 0.780000031, -5.21345472),
    fremen = core.getHardcodedPositionFromGUID('4c2bcc', -9.543688, 0.780000031, -10.6707687)
}

--[[
-- TODO Généraliser (uniquement avec Ix pour l’instant).
agent_spaces = {
    Stillsuits = "556f43",
    HardyWarriors = "a2fd8e",
    Secrets = "1f7c08",
    SelectiveBreeding = "7dc6e5",
    Foldspace = "9a9eb5",
    Heighliner = "8b0515",
    Wealth = "b2c461",
    Conspire = "cd9386",
    SietchTabr = "5bc970",
    ResearchStation = "af11aa",
    Carthag = "b1c938",
    Arrakeen = "17b646",
    TheGreatFlat = "69f925",
    HaggaBasin = "622708",
    ImperialBasin = "2c77c1",
    HighCouncil = "8a6315",
    Mentat = "30cff9",
    Swordmaster = "",
    InterstellarShipping = "",
    Smuggling = "",
    TechNegotiation = "",
    Dreadnought = ""
}
]]--

_ = core.registerLoadablePart(function(_)
    flag_basin_zone = getObjectFromGUID("3fe117")
    flag_arrakeen_zone = getObjectFromGUID("f1f53d")
    flag_carthag_zone = getObjectFromGUID("9fc2e1")

    Zone_mentat = getObjectFromGUID("565d09")

    Zone_foldspace = getObjectFromGUID("6b62e0")
    bonus_spice1 = getObjectFromGUID('3cdb2d')
    bonus_spice2 = getObjectFromGUID('394db2')
    bonus_spice3 = getObjectFromGUID('116807')

    Stillsuits_zone = getObjectFromGUID("556f43")
    HardyWarriors_zone = getObjectFromGUID("a2fd8e")
    Secrets_zone = getObjectFromGUID("1f7c08")
    SelectiveBreeding_zone = getObjectFromGUID("7dc6e5")
    Foldspace_zone = getObjectFromGUID("9a9eb5")
    Heighliner_zone = getObjectFromGUID("8b0515")
    Wealth_zone = getObjectFromGUID("b2c461")
    Conspire_zone = getObjectFromGUID("cd9386")
    SietchTabr_zone = getObjectFromGUID("5bc970")
    ResearchStation_zone = getObjectFromGUID("af11aa")
    Carthag_zone = getObjectFromGUID("b1c938")
    Arrakeen_zone = getObjectFromGUID("17b646")
    TheGreatFlat_zone = getObjectFromGUID("69f925")
    HaggaBasin_zone = getObjectFromGUID("622708")
    ImperialBasin_zone = getObjectFromGUID("2c77c1")
    HighCouncil_zone = getObjectFromGUID("8a6315")
    Mentat_zone = getObjectFromGUID("30cff9")
    foldspace = getObjectFromGUID("38ffc0")
    intrigue_zone = getObjectFromGUID("a377d8")

    pion_reput = core.resolveGUIDs(false, pion_reput)

    alliance_token = {
        emperor = getObjectFromGUID('13e990'),
        spacingGuild = getObjectFromGUID('ad1aae'),
        beneGesserit = getObjectFromGUID('33452e'),
        fremen = getObjectFromGUID('4c2bcc')
    }
end)

function boardCommonModule.CheckAgentAndPlayer(color, zone)
    if color ~= "Red" and color ~= "Blue" and color ~= "Green" and color ~= "Yellow" then
        broadcastToColor(i18n("noTouch"), color, {1, 0.011765, 0})
        return false
    elseif not boardCommonModule.hasAgentInSpace(color, zone) then
        broadcastToColor(i18n("noAgent"), color, "Purple")
        return false
    else
        return true
    end
end

function boardCommonModule.hasAgentInSpace(color, spaceZone)
    for _, object in ipairs(spaceZone.getObjects()) do
        if helperModule.isAgent(object, color) then
            return true
        end
    end
    return false
end

function HarvestSpice(color, base, bonusRef)
    local t = 0
    local nbSpice = base + bonusRef.call("collectVal")
    bonusRef.call("resetVal")
    for i = 1, nbSpice, 1 do
        Wait.time(function() constants.players[color].spice.call("incrementVal") end, t)
        t = t + (1.5 / nbSpice)
    end
    return nbSpice
end

function boardCommonModule.ImperialBasin(color)

    if boardCommonModule.CheckAgentAndPlayer(color, ImperialBasin_zone) then
        local leader = helperModule.getLeader(color)
        assert(leader)
        local leaderName = leader.getName()
        if leader.hasTag("Ariana") then
            local nbSpice = HarvestSpice(color, 0, bonus_spice1)

            local numberToDraw = 1

            local enoughCards = helperModule.isDeckContainsEnough(color, numberToDraw)

            if not enoughCards then
                broadcastToAll(
                    i18n("imperialBasin"):format(leaderName, nbSpice) .. ".",
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
                        broadcastToAll(i18n("imperialBasinDraw"):format(
                                           leaderName), color)
                    end)
            else

                DrawOne(_, color)
                broadcastToAll(
                    i18n("imperialBasin"):format(leaderName, nbSpice) ..
                        i18n("et") .. i18n("drawOneCard"), color)
            end
        else
            local nbSpice = HarvestSpice(color, 1, bonus_spice1)
            broadcastToAll(i18n("imperialBasin"):format(leaderName, nbSpice) ..
                               ".", color)
        end
        Wait.time(flag_basin, 0.5)
    end
end

function boardCommonModule.HaggaBasin(color)

    if boardCommonModule.CheckAgentAndPlayer(color, HaggaBasin_zone) then
        local leader = helperModule.getLeader(color)
        assert(leader)
        local leaderName = leader.getName()
        local waterObj = constants.players[color].water
        if waterObj.call("collectVal") < 1 then
            broadcastToColor(i18n("noWater"), color, color)
        else
            waterObj.call("decrementVal")
            if leader.hasTag("Ariana") then
                local nbSpice = HarvestSpice(color, 1, bonus_spice2)

                local numberToDraw = 1

                local enoughCards = helperModule.isDeckContainsEnough(color, numberToDraw)

                if not enoughCards then
                    broadcastToAll(
                        i18n("haggaBasin"):format(leaderName, nbSpice) .. ".",
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
                            broadcastToAll(
                                i18n("haggaBasinDraw"):format(leaderName), color)
                        end)
                else

                    DrawOne(_, color)
                    broadcastToAll(
                        i18n("haggaBasin"):format(leaderName, nbSpice) ..
                            i18n("et") .. i18n("drawOneCard"), color)
                end

            else
                local nbSpice = HarvestSpice(color, 2, bonus_spice2)
                broadcastToAll(
                    i18n("haggaBasin"):format(leaderName, nbSpice) .. ".", color)
            end
        end
    end
end

function boardCommonModule.TheGreatFlat(color)

    if boardCommonModule.CheckAgentAndPlayer(color, TheGreatFlat_zone) then
        local leader = helperModule.getLeader(color)
        assert(leader)
        local leaderName = leader.getName()
        local waterObj = constants.players[color].water
        if waterObj.call("collectVal") < 2 then
            broadcastToColor(i18n("noWater"), color, color)
        else
            waterObj.call("decrementVal")
            waterObj.call("decrementVal")
            if leader.hasTag("Ariana") then
                local nbSpice = HarvestSpice(color, 2, bonus_spice3)

                local numberToDraw = 1

                local enoughCards = helperModule.isDeckContainsEnough(color, numberToDraw)

                if not enoughCards then
                    broadcastToAll(
                        i18n("greatFlat"):format(leaderName, nbSpice) .. ".",
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
                            broadcastToAll(
                                i18n("greatFlatDraw"):format(leaderName), color)
                        end)
                else
                    DrawOne(_, color)
                    broadcastToAll(
                        i18n("greatFlat"):format(leaderName, nbSpice) ..
                            i18n("et") .. i18n("drawOneCard"), color)
                end

            else
                local nbSpice = HarvestSpice(color, 3, bonus_spice3)
                broadcastToAll(i18n("greatFlat"):format(leaderName, nbSpice) ..
                                   ".", color)
            end
        end
    end
end

function boardCommonModule.Stillsuits(color)

    if boardCommonModule.CheckAgentAndPlayer(color, Stillsuits_zone) then
        local leaderName = helperModule.getLeaderName(color)
        constants.players[color].water.call("incrementVal")
        broadcastToAll(i18n("stillSuits"):format(leaderName), color)
        if leaderName == "Shaddam IV" then
            boardCommonModule.FremenDown(color)
        else
            boardCommonModule.FremenUp(color)
        end
    end
end

function boardCommonModule.HardyWarriors(color)

    if boardCommonModule.CheckAgentAndPlayer(color, HardyWarriors_zone) then

        local waterObj = constants.players[color].water
        if waterObj.call("collectVal") < 1 then
            broadcastToColor(i18n("noWater"), color, color)
        else
            local leaderName = helperModule.getLeaderName(color)
            waterObj.call("decrementVal")
            helperModule.landTroopsFromOrbit(color, 2)
            broadcastToAll(i18n("hardyWarriors"):format(leaderName), color)
            if leaderName == "Shaddam IV" then
                boardCommonModule.FremenDown(color)
            else
                boardCommonModule.FremenUp(color)
            end
        end
    end
end

function boardCommonModule.Secrets(color)

    if boardCommonModule.CheckAgentAndPlayer(color, Secrets_zone) then
        local leaderName = helperModule.getLeaderName(color)
        Wait.time(function() boardCommonModule.drawIntrigue(color) end, 0.2)
        broadcastToAll(i18n("secrets"):format(leaderName), color)
        if leaderName == "Shaddam IV" then
            boardCommonModule.BeneDown(color)
        else
            boardCommonModule.BeneUp(color)
        end
    end

end

function boardCommonModule.SelectiveBreeding(color)

    if boardCommonModule.CheckAgentAndPlayer(color, SelectiveBreeding_zone) then
        local leaderName = helperModule.getLeaderName(color)
        local t0 = 0
        local spiceObj = constants.players[color].spice

        if spiceObj.call("collectVal") < 2 then
            broadcastToColor(i18n("noSpice"), color, color)
        else
            for i = 1, 2, 1 do
                t0 = t0 + 0.35
                Wait.time(function()
                    spiceObj.call("decrementVal")
                end, t0)
            end
            broadcastToAll(i18n("selectiveBreeding"):format(leaderName), color)
            if leaderName == "Shaddam IV" then
                boardCommonModule.BeneDown(color)
            else
                boardCommonModule.BeneUp(color)
            end
        end
    end
end

function boardCommonModule.Foldspace(color)

    if boardCommonModule.CheckAgentAndPlayer(color, Foldspace_zone) then
        local deck_foldspace = helperModule.GetDeckOrCard(Zone_foldspace)
        local leaderName = helperModule.getLeaderName(color)

        if deck_foldspace.type == "Deck" then
            deck_foldspace.takeObject({
                position = constants.players[color].pos_discard,
                rotation = {0, 180, 0},
                smooth = false
            })
        elseif deck_foldspace.type == "Card" then
            deck_foldspace.setPosition(constants.players[color].pos_discard)
        end
        broadcastToAll(i18n("foldspace"):format(leaderName), color)
        if leaderName == "Shaddam IV" then
            boardCommonModule.GuildDown(color)
        else
            boardCommonModule.GuildUp(color)
        end
    end
end

function boardCommonModule.Heighliner(color)

    if boardCommonModule.CheckAgentAndPlayer(color, Heighliner_zone) then
        local spiceObj = constants.players[color].spice

        if spiceObj.call("collectVal") < 6 then
            broadcastToColor(i18n("noSpice"), color, color)
        else
            local t0 = 0
            local t1 = 0
            local t2 = 0
            local leaderName = helperModule.getLeaderName(color)

            for i = 1, 6, 1 do
                t0 = t0 + 0.2
                Wait.time(function()
                    spiceObj.call("decrementVal")
                end, t0)
            end
            for i = 1, 2, 1 do
                t1 = t1 + 0.4
                Wait.time(function()
                    constants.players[color].water.call("incrementVal")
                end, t1)
            end
            helperModule.landTroopsFromOrbit(color, 5)
            broadcastToAll(i18n("heighliner"):format(leaderName), color)
            if leaderName == "Shaddam IV" then
                boardCommonModule.GuildDown(color)
            else
                boardCommonModule.GuildUp(color)
            end
        end
    end
end

function boardCommonModule.Wealth(color)

    if boardCommonModule.CheckAgentAndPlayer(color, Wealth_zone) then
        local leader = helperModule.getLeader(color)
        assert(leader)
        local leaderName = leader.getName()
        local solari = 2
        local t1 = 0

        if leader.hasTag("Yuna") then solari = 3 end

        for i = 1, solari, 1 do
            Wait.time(function()
                constants.players[color].solari.call("incrementVal")
            end, t1)
            t1 = t1 + 0.3
        end
        broadcastToAll(i18n("wealth"):format(leaderName, solari), color)

        if leaderName == "Shaddam IV" then
            boardCommonModule.EmperorDown(color)
        else
            boardCommonModule.EmperorUp(color)
        end
    end
end

function boardCommonModule.Conspire(color)

    if boardCommonModule.CheckAgentAndPlayer(color, Conspire_zone) then

        local spiceObj = constants.players[color].spice

        if spiceObj.call("collectVal") < 4 then
            broadcastToColor(i18n("noSpice"), color, color)
        else
            local leader = helperModule.getLeader(color)
            assert(leader)
            local leaderName = leader.getName()
            local solari = 5
            local t0 = 0
            local t1 = 0
            local t2 = 0

            local leader = helperModule.getLeader(color)
            if leader.hasTag("Yuna") then solari = 6 end

            for i = 1, 4, 1 do
                Wait.time(function()
                    spiceObj.call("decrementVal")
                end, t0)
                t0 = t0 + 0.3
            end
            for i = 1, solari, 1 do
                Wait.time(function()
                    constants.players[color].solari.call("incrementVal")
                end, t1)
                t1 = t1 + 0.25
            end
            helperModule.landTroopsFromOrbit(color, 2)
            Wait.time(function()
                boardCommonModule.drawIntrigue(color)
            end, 0.2)
            broadcastToAll(i18n("conspire"):format(leaderName, solari), color)

            if leaderName == "Shaddam IV" then
                boardCommonModule.EmperorDown(color)
            else
                boardCommonModule.EmperorUp(color)
            end
        end
    end
end

function boardCommonModule.initReputationLevels()
    local reputationLevels = {}
    for faction, initialPositions in pairs(initial_position_pion_reput) do
        local factionLevels = {}
        for color, position in pairs(initialPositions) do
            local startingCell = position
            local allianceToken = initial_alliance_pos[faction]
            local step = (allianceToken.z - startingCell.z) / 5 -- The token is centered on the 5th level (but you only need to reach the 4th to get it).
            local zero = startingCell.z - step / 2
            factionLevels[color] = {
                step = step,
                none = zero + step * 0,
                friendship = zero + step * 2,
                alliance = zero + step * 4,
                min = zero + step * 1,
                max = zero + step * 6,
            }
        end
        reputationLevels[faction] = factionLevels
    end
    return reputationLevels
end

boardCommonModule.reputationLevels = boardCommonModule.initReputationLevels()

function boardCommonModule.getReputationLevels(faction, color)
    return boardCommonModule.reputationLevels[faction][color]
end

function boardCommonModule.ReputationUp(color, faction)
    local reputationLevels = boardCommonModule.getReputationLevels(faction, color)
    local pos = pion_reput[faction][color].getPosition()
    local leaderName = helperModule.getLeaderName(color)
    if pos.z < reputationLevels.max then
        pion_reput[faction][color].setPositionSmooth({
            pos.x, pos.y, pos.z + reputationLevels.step
        }, false, false)
        giveAlliance(faction, color)
        broadcastToAll(i18n("reputUp"):format(leaderName, i18n(faction)), color)
    else
        broadcastToColor(i18n("reputMax"), color, "Pink")
    end
end

function boardCommonModule.ReputationDown(color, faction)
    local reputationLevels = boardCommonModule.getReputationLevels(faction, color)
    local pos = pion_reput[faction][color].getPosition()
    local leaderName = helperModule.getLeaderName(color)
    if pos.z > reputationLevels.min then
        pion_reput[faction][color].setPositionSmooth({
            pos.x, pos.y, pos.z - reputationLevels.step
        }, false, false)
        giveAlliance(faction, color)
        broadcastToAll(i18n("reputDown"):format(leaderName, i18n(faction)),
                       color)
    else
        broadcastToColor(i18n("reputMin"), color, "Orange")
    end
end

function giveAlliance(faction, color)
    local leaderName = helperModule.getLeaderName(color)

    local posz_liste = {}

    for playerColor, pion in pairs(pion_reput[faction]) do
        if core.stillExist(pion) and playerColor ~= color then
            posz_liste[playerColor] = pion.getPosition().z
        end
    end

    local playerVictoryTokens =  helperModule.getScoreTokens(color)
    local hasAlliance = false
    for _, victoryToken in ipairs(playerVictoryTokens) do
        if victoryToken == alliance_token[faction] then
            hasAlliance = true
        end
    end

    Wait.time(function()
        local posz = pion_reput[faction][color].getPosition().z
        local posz_requis = boardCommonModule.getReputationLevels(faction, color).alliance

        if hasAlliance then
            local biggestDelta = 0;
            local playerTakingAlliance = ""
            local tiedForVP = false

            for otherColor, posz_compared in pairs(posz_liste) do

                if posz < (posz_compared - 0.5) then
                    local delta = posz_compared - posz

                    if (delta - biggestDelta) < 0.5 and (delta - biggestDelta) >
                        -0.5 then tiedForVP = true end

                    if delta > biggestDelta then
                        biggestDelta = delta
                        playerTakingAlliance = otherColor
                    end
                end

            end

            if tiedForVP or biggestDelta > 0 or posz < posz_requis then
                broadcastToAll(i18n("loseAlliance"):format(leaderName,
                                                           i18n(faction)), color)
            end

            if tiedForVP then
                broadcastToAll(i18n("tiedAlliance"):format(i18n(faction)),
                               "Pink")

            elseif biggestDelta > 0 then
                local leaderTakingAllianceName = helperModule.getLeaderName(playerTakingAlliance)
                helperModule.grantScoreToken(playerTakingAlliance, alliance_token[faction])
                broadcastToAll(i18n("recoverAlliance"):format(leaderTakingAllianceName, i18n(faction)), playerTakingAlliance)
            elseif posz < posz_requis then
                alliance_token[faction].setPositionSmooth(initial_alliance_pos[faction], false, false)
            end

        end

        if not hasAlliance and posz > posz_requis then
            local isReputStrongest = true
            for k, posz_compared in pairs(posz_liste) do

                if posz < (posz_compared + 0.5) then
                    isReputStrongest = false
                end
            end

            if isReputStrongest then
                helperModule.grantScoreToken(color, alliance_token[faction])
                broadcastToAll(i18n("recoverAlliance"):format(leaderName, i18n(faction)), color)
            end
        end

    end, 1)
end

function boardCommonModule.FremenUp(color)
    boardCommonModule.ReputationUp(color, "fremen")
end

function boardCommonModule.FremenDown(color)
    boardCommonModule.ReputationDown(color, "fremen")
end

function boardCommonModule.BeneUp(color)
    boardCommonModule.ReputationUp(color, "beneGesserit")
end

function boardCommonModule.BeneDown(color)
    boardCommonModule.ReputationDown(color, "beneGesserit")
end

function boardCommonModule.GuildUp(color)
    boardCommonModule.ReputationUp(color, "spacingGuild")
end

function boardCommonModule.GuildDown(color)
    boardCommonModule.ReputationDown(color, "spacingGuild")
end

function boardCommonModule.EmperorUp(color)
    boardCommonModule.ReputationUp(color, "emperor")
end

function boardCommonModule.EmperorDown(color)
    boardCommonModule.ReputationDown(color, "emperor")
end

function boardCommonModule.SietchTabr(color)
    if boardCommonModule.CheckAgentAndPlayer(color, SietchTabr_zone) then
        local reputationLevels = boardCommonModule.getReputationLevels("fremen", color)
        if pion_reput.fremen[color].getPosition().z < reputationLevels.friendship then
            broadcastToColor(i18n("notReputation"), color, "Red")
            return 1
        end

        constants.players[color].water.call("incrementVal")
        helperModule.landTroopsFromOrbit(color, 1)

        local leaderName = helperModule.getLeaderName(color)

        broadcastToAll(i18n("sietchTabr"):format(leaderName), color)
    end
end

function boardCommonModule.ResearchStation(color)
    if boardCommonModule.CheckAgentAndPlayer(color, ResearchStation_zone) then

        local waterObj = constants.players[color].water
        local leaderName = helperModule.getLeaderName(color)

        if waterObj.call("collectVal") < 2 then
            broadcastToColor(i18n("noWater"), color, color)
        else
            for i = 1, 2, 1 do waterObj.call("decrementVal") end

            local numberToDraw = 3

            local enoughCards = helperModule.isDeckContainsEnough(color, numberToDraw)

            if not enoughCards then

                broadcastToAll(
                    i18n("researchStationPayOnly"):format(leaderName) .. ".",
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

                        broadcastToAll(i18n("researchStationDraw"):format(
                                           leaderName, 3) .. ".", color)

                        for i = 0, numberToDraw - 1, 1 do
                            Wait.time(function()
                                DrawOne(_, color)
                            end, i)
                        end

                    end)
            else

                broadcastToAll(i18n("researchStation"):format(leaderName, 3) ..
                                   ".", color)

                for i = 0, numberToDraw - 1, 1 do
                    Wait.time(function() DrawOne(_, color) end, i)
                end

            end
        end
    end
end

function boardCommonModule.Carthag(color)
    if boardCommonModule.CheckAgentAndPlayer(color, Carthag_zone) then
        local leaderName = helperModule.getLeaderName(color)

        Wait.time(function() boardCommonModule.drawIntrigue(color) end, 0.2)
        helperModule.landTroopsFromOrbit(color, 1)
        broadcastToAll(i18n("carthag"):format(leaderName), color)
        Wait.time(function() flag_carthag(color) end, 0.5)
    end
end

function boardCommonModule.Arrakeen(color)

    if boardCommonModule.CheckAgentAndPlayer(color, Arrakeen_zone) then
        local leaderName = helperModule.getLeaderName(color)

        local numberToDraw = 1

        local enoughCards = helperModule.isDeckContainsEnough(color, numberToDraw)

        if not enoughCards then
            broadcastToAll(i18n("arrakeenTroopOnly"):format(leaderName), color)

            broadcastToAll(i18n("isDecidingToDraw"):format(leaderName), "Pink")
            local card = i18n("cards")
            if numberToDraw == 1 then
                card = i18n("card")
            end
            Player[color].showConfirmDialog(
                i18n("warningBeforeDraw"):format(numberToDraw, card),
                function(player_color)
                    DrawOne(_, color)
                    broadcastToAll(i18n("arrakeenDraw"):format(leaderName),
                                   color)
                end)
        else
            DrawOne(_, color)
            broadcastToAll(i18n("arrakeen"):format(leaderName), color)
        end

        helperModule.landTroopsFromOrbit(color, 1)
        Wait.time(function() flag_arrakeen(color) end, 0.5)
    end
end

function boardCommonModule.Swordmaster(color, zone)

    local t = 0

    if boardCommonModule.CheckAgentAndPlayer(color, zone) then

        local solariObj = constants.players[color].solari
        local leader = helperModule.getLeader(color)
        assert(leader)
        local leaderName = leader.getName()
        local price = 8

        if leader.hasTag("Leto") then price = 7 end

        if solariObj.call("collectVal") < price then
            broadcastToColor(i18n("noSolari"), color, color)
        else
            for i = 1, price, 1 do
                Wait.time(function()
                    solariObj.call("decrementVal")
                end, t)
                t = t + 0.15
            end
            local p = constants.players[color].agent_positions[3]
            constants.players[color].swordmaster.setPositionSmooth(p, false, false)
            if leader.hasTag("Ilban") then

                local numberToDraw = 1

                local enoughCards = helperModule.isDeckContainsEnough(color, numberToDraw)

                if not enoughCards then
                    broadcastToAll(
                        i18n("swordMaster"):format(leaderName, price) .. ".",
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
                    broadcastToAll(
                        i18n("swordMaster"):format(leaderName, price) ..
                            i18n("et") .. i18n("drawOneCard"), color)
                end

            else
                broadcastToAll(i18n("swordMaster"):format(leaderName, price) ..
                                   ".", color)
            end
        end
    end
end

function boardCommonModule.Mentat(color)

    if boardCommonModule.CheckAgentAndPlayer(color, Mentat_zone) then

        local solariObj = constants.players[color].solari
        local leader = helperModule.getLeader(color)
        assert(leader)
        local leaderName = leader.getName()
        local price = 2
        local t = 0
        local talk = " "

        if leader.hasTag("Leto") then price = 1 end

        if solariObj.call("collectVal") < price then
            broadcastToColor(i18n("noSolari"), color, color)
        else
            for i = 1, price, 1 do
                Wait.time(function()
                    solariObj.call("decrementVal")
                end, t)
                t = t + 0.3
            end
            local mentats = getMentat()
            if mentats ~= nil then
                talk = i18n("mentatToken")
                mentats.setPositionSmooth(constants.players[color].agent_positions[4], false, false)
            end

            local numberToDraw = 1

            if leader.hasTag("Ilban") then numberToDraw = 2 end

            local enoughCards = helperModule.isDeckContainsEnough(color, numberToDraw)

            if not enoughCards then
                broadcastToAll(
                    leaderName .. i18n("mentatPayment"):format(price) .. talk ..
                        ".", color)

                broadcastToAll(i18n("isDecidingToDraw"):format(leaderName),
                               "Pink")

                    local card = i18n("cards")
                    if numberToDraw == 1 then
                        card = i18n("card")
                    end
                    Player[color].showConfirmDialog(
                        i18n("warningBeforeDraw"):format(numberToDraw, card),
                    function(player_color)
                        if leader.hasTag("Ilban") then

                            broadcastToAll(
                                leaderName .. i18n("mentatIlbanDraw"), color)
                            Wait.time(function()
                                DrawOne(_, color)
                            end, 1)
                        else
                            broadcastToAll(leaderName .. i18n("drawOneCard"),
                                           color)
                        end
                        DrawOne(_, color)
                    end)
            else
                if leader.hasTag("Ilban") then
                    broadcastToAll(leaderName ..
                                       i18n("mentatPayment"):format(price) ..
                                       talk .. i18n("et") ..
                                       i18n("mentatIlbanDraw"), color)
                    Wait.time(function() DrawOne(_, color) end, 1)
                else
                    broadcastToAll(leaderName ..
                                       i18n("mentatPayment"):format(price) ..
                                       talk .. i18n("et") .. i18n("drawOneCard"),
                                   color)
                end
                DrawOne(_, color)
            end
        end
    end
end

function getMentat()
    local returnValue = nil
    for _, obj in ipairs(Zone_mentat.getObjects()) do
        if obj.getName() == "Mentat" then returnValue = obj end
    end
    return returnValue
end

function boardCommonModule.HighCouncil(color)

    if boardCommonModule.CheckAgentAndPlayer(color, HighCouncil_zone) then

        local solariObj = constants.players[color].solari
        local leader = helperModule.getLeader(color)
        assert(leader)
        local leaderName = leader.getName()
        local price = 5
        local t = 0

        if leader.hasTag("Leto") then price = 4 end

        if solariObj.call("collectVal") < price then
            broadcastToColor(i18n("noSolari"), color, color)
        else
            for i = 1, price, 1 do
                Wait.time(function()
                    solariObj.call("decrementVal")
                end, t)
                t = t + 0.2
            end
            -- place the council token and get back a 2 persuasion token near the player board
            local destination = constants.players[color].council_zone
            local ix_CHOAM_overlay = getObjectFromGUID("a139cd")
            if not ix_CHOAM_overlay then
                destination = constants.players[color].vanilla_council_zone
            end

            constants.players[color].council_token.setPositionSmooth(destination, false, false)
            constants.players[color].council_token.interactable = false

            if false then
                local council_influence_bonus_bag = getObjectFromGUID("074f6d")
                council_influence_bonus_bag.takeObject({
                    position = constants.players[color].council_bonus_zone,
                    rotation = Vector(0, 180, 0),
                    callback_function = function (object)
                        object.locked = true
                        object.setScale(Vector(0.4, 1, 0.4))
                        object.setPosition(object.getPosition() + Vector(0, -0.2, 0))
                    end
                })
            else
                Wait.time(function ()
                    constants.players[color].board.call("updateSpecialSummaryCards")
                end, 2)
            end

            if leader.hasTag("Ilban") then

                local numberToDraw = 1

                local enoughCards = helperModule.isDeckContainsEnough(color, numberToDraw)

                if not enoughCards then
                    broadcastToAll(
                        i18n("highCouncil"):format(leaderName, price) .. ".",
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
                    broadcastToAll(
                        i18n("highCouncil"):format(leaderName, price) ..
                            i18n("et") .. i18n("drawOneCard"), color)
                end
            else
                broadcastToAll(i18n("highCouncil"):format(leaderName, price) ..
                                   ".", color)
            end
        end
    end

end

function boardCommonModule.drawIntrigue(color)
    local x = 1
    if helperModule.getLeaderName(color) == "Count Fenring" then
        x = 2
        Wait.time(function()
            broadcastToAll(helperModule.getLeaderName(color) ..
                               i18n("fenring"), "Purple")
        end, 0.5)
    end
    local t = 0
    for i = 1, x, 1 do
        Wait.time(function()
            local handZone = Player[color].getHandTransform()
            local intrigueDeck = helperModule.GetDeckOrCard(intrigue_zone)
            local my_card = intrigueDeck.takeObject({
                position = {
                    handZone.position.x - 7.5, handZone.position.y,
                    handZone.position.z
                },
                flip = false,
                smooth = false
            })
            Wait.time(function() my_card.flip() end, 0.2)
        end, t)
        t = t + 0.25
    end
end

function flag_basin()
    local dread = 0
    local table = flag_basin_zone.getObjects()
    for _, obj in ipairs(table) do
        if obj.getName() == "Red Dreadnought" or obj.getName() ==
            "Red dreadnought" then
            dread = 1
        elseif obj.getName() == "Blue Dreadnought" or obj.getName() ==
            "Blue dreadnought" then
            dread = 2
        elseif obj.getName() == "Green Dreadnought" or obj.getName() ==
            "Green dreadnought" then
            dread = 3
        elseif obj.getName() == "Yellow Dreadnought" or obj.getName() ==
            "Yellow dreadnought" then
            dread = 4
        end
    end
    if dread == 0 then
        for _, obj in ipairs(table) do
            if obj.getName() == "Red Flag" then
                dread = 1
            elseif obj.getName() == "Blue Flag" then
                dread = 2
            elseif obj.getName() == "Green Flag" then
                dread = 3
            elseif obj.getName() == "Yellow Flag" then
                dread = 4
            end
        end
    end
    if dread == 1 then
        constants.players["Red"].spice.call("incrementVal")
        broadcastToAll(helperModule.getLeaderName("Red") .. i18n("flagBasin"), {0.956, 0.392, 0.113})
    elseif dread == 2 then
        constants.players["Blue"].spice.call("incrementVal")
        broadcastToAll(helperModule.getLeaderName("Blue") .. i18n("flagBasin"), {0.956, 0.392, 0.113})
    elseif dread == 3 then
        constants.players["Green"].spice.call("incrementVal")
        broadcastToAll(helperModule.getLeaderName("Green") ..i18n("flagBasin"), {0.956, 0.392, 0.113})
    elseif dread == 4 then
        constants.players["Yellow"].spice.call("incrementVal")
        broadcastToAll(helperModule.getLeaderName("Yellow") ..i18n("flagBasin"), {0.956, 0.392, 0.113})
    end
end

function flag_arrakeen(color)
    local dread = 0
    local table = flag_arrakeen_zone.getObjects()
    if helperModule.getLeaderName(color) == "Princess Yuna" then
        for _, obj in ipairs(table) do
            if obj.getName() == color .. " Dreadnought" or obj.getName() ==
                color .. " dreadnought" then dread = 5 end
        end
        if dread == 0 then
            for _, obj in ipairs(table) do
                if obj.getName() == color .. " Flag" then
                    dread = 5
                end
            end
        end
    end
    if dread == 0 then
        for _, obj in ipairs(table) do
            if obj.getName() == "Red Dreadnought" or obj.getName() ==
                "Red dreadnought" then
                dread = 1
            elseif obj.getName() == "Blue Dreadnought" or obj.getName() ==
                "Blue dreadnought" then
                dread = 2
            elseif obj.getName() == "Green Dreadnought" or obj.getName() ==
                "Green dreadnought" then
                dread = 3
            elseif obj.getName() == "Yellow Dreadnought" or obj.getName() ==
                "Yellow dreadnought" then
                dread = 4
            end
        end
        if dread == 0 then
            for _, obj in ipairs(table) do
                if obj.getName() == "Red Flag" then
                    dread = 1
                elseif obj.getName() == "Blue Flag" then
                    dread = 2
                elseif obj.getName() == "Green Flag" then
                    dread = 3
                elseif obj.getName() == "Yellow Flag" then
                    dread = 4
                end
            end
        end
    end
    if dread == 1 then
        constants.players["Red"].solari.call("incrementVal")
        broadcastToAll(helperModule.getLeaderName("Red") ..
                           i18n("flagArrakeen"):format(1), {0.8, 0.8, 0.8})
    elseif dread == 2 then
        constants.players["Blue"].solari.call("incrementVal")
        broadcastToAll(helperModule.getLeaderName("Blue") ..
                           i18n("flagArrakeen"):format(1), {0.8, 0.8, 0.8})
    elseif dread == 3 then
        constants.players["Green"].solari.call("incrementVal")
        broadcastToAll(helperModule.getLeaderName("Green") ..
                           i18n("flagArrakeen"):format(1), {0.8, 0.8, 0.8})
    elseif dread == 4 then
        constants.players["Yellow"].solari.call("incrementVal")
        broadcastToAll(helperModule.getLeaderName("Yellow") ..
                           i18n("flagArrakeen"):format(1), {0.8, 0.8, 0.8})
    elseif dread == 5 then
        constants.players[color].solari.call("incrementVal")
        Wait.time(function() constants.players[color].solari.call("incrementVal") end, 0.3)
        broadcastToAll(helperModule.getLeaderName(color) ..
                           i18n("flagArrakeen"):format(2), {0.8, 0.8, 0.8})
    end
end

function flag_carthag(color)
    local dread = 0
    local table = flag_carthag_zone.getObjects()
    if helperModule.getLeaderName(color) == "Princess Yuna" then
        for _, obj in ipairs(table) do
            if obj.getName() == color .. " Dreadnought" or obj.getName() ==
                color .. " dreadnought" then dread = 5 end
        end
        if dread == 0 then
            for _, obj in ipairs(table) do
                if obj.getName() == color .. " Flag" then
                    dread = 5
                end
            end
        end
    end
    if dread == 0 then
        for _, obj in ipairs(table) do
            if obj.getName() == "Red Dreadnought" or obj.getName() ==
                "Red dreadnought" then
                dread = 1
            elseif obj.getName() == "Blue Dreadnought" or obj.getName() ==
                "Blue dreadnought" then
                dread = 2
            elseif obj.getName() == "Green Dreadnought" or obj.getName() ==
                "Green dreadnought" then
                dread = 3
            elseif obj.getName() == "Yellow Dreadnought" or obj.getName() ==
                "Yellow dreadnought" then
                dread = 4
            end
        end
        if dread == 0 then
            for _, obj in ipairs(table) do
                if obj.getName() == "Red Flag" then
                    dread = 1
                elseif obj.getName() == "Blue Flag" then
                    dread = 2
                elseif obj.getName() == "Green Flag" then
                    dread = 3
                elseif obj.getName() == "Yellow Flag" then
                    dread = 4
                end
            end
        end
    end
    if dread == 1 then
        constants.players["Red"].solari.call("incrementVal")
        broadcastToAll(helperModule.getLeaderName("Red") .. i18n("flagCarthag"):format(1), {0.8, 0.8, 0.8})
    elseif dread == 2 then
        constants.players["Blue"].solari.call("incrementVal")
        broadcastToAll(helperModule.getLeaderName("Blue") .. i18n("flagCarthag"):format(1), {0.8, 0.8, 0.8})
    elseif dread == 3 then
        constants.players["Green"].solari.call("incrementVal")
        broadcastToAll(helperModule.getLeaderName("Green") ..i18n("flagCarthag"):format(1), {0.8, 0.8, 0.8})
    elseif dread == 4 then
        constants.players["Yellow"].solari.call("incrementVal")
        broadcastToAll(helperModule.getLeaderName("Yellow") ..i18n("flagCarthag"):format(1), {0.8, 0.8, 0.8})
    elseif dread == 5 then
        constants.players[color].solari.call("incrementVal")
        Wait.time(function() constants.players[color].solari.call("incrementVal") end, 0.3)
        broadcastToAll(helperModule.getLeaderName(color) ..
                           i18n("flagCarthag"):format(2), {0.8, 0.8, 0.8})
    end
end

return boardCommonModule