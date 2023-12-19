local Module = require("utils.Module")
local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

local Types = Module.lazyRequire("Types")
local PlayBoard = Module.lazyRequire("PlayBoard")
local MainBoard = Module.lazyRequire("MainBoard")
local TurnControl = Module.lazyRequire("TurnControl")
local Commander = Module.lazyRequire("Commander")

local InfluenceTrack = {
    influenceTokens = {},
    influenceTokenInitialPositions = {},
    allianceTokenInitialPositions = {},
    influenceLevels = {},
    actionsLocked = {
        emperor = {},
        spacingGuild = {},
        beneGesserit = {},
        fremen = {},
        greatHouses = {},
        fringeWorlds = {},
    },
}

---
function InfluenceTrack.onLoad(state)
    --Helper.dumpFunction("InfluenceTrack.onLoad(...)")

    Helper.append(InfluenceTrack, Helper.resolveGUIDs(false, {
        snoopers = {
            emperor = "a58ce8",
            spacingGuild = "857f74",
            beneGesserit = "bed196",
            fremen = "b10897",
        },
        friendshipBags = {
            emperor = "6a4186",
            spacingGuild = "400d45",
            beneGesserit = "e763f6",
            fremen = "8bcfe7",
            greatHouses = '95926b',
            fringeWorlds = 'a43ec0',
        },
        allianceTokens = {}
    }))

    for _, bag in pairs(InfluenceTrack.friendshipBags) do
        bag.interactable = false
    end

    if state.settings then
        InfluenceTrack._staticSetUp(state.settings, false)
    end
end

---
function InfluenceTrack.setUp(settings)
    InfluenceTrack._staticSetUp(settings, true)

    if settings.numberOfPlayers < 6 then
        InfluenceTrack.allianceTokens.greatHouses.destruct()
        InfluenceTrack.allianceTokens.fringeWorlds.destruct()
    end
end

---
function InfluenceTrack._staticSetUp(settings, firstTime)
    InfluenceTrack._processSnapPoints(settings, firstTime)
    InfluenceTrack.isTeamGame = settings.numberOfPlayers == 6

    for faction, initialPositions in pairs(InfluenceTrack.influenceTokenInitialPositions) do
        local factionLevels = {}
        local meanStartPosition = Vector(0, 0, 0)
        local meanStep = 0
        local n = 0
        for color, position in pairs(initialPositions) do
            local allianceToken = InfluenceTrack.allianceTokenInitialPositions[faction]
            local step = (allianceToken.z - position.z) / 5 -- The token is centered on the 5th level (but you only need to reach the 4th to get it).
            local zero = position.z - step / 2
            factionLevels[color] = {
                step = step,
                none = zero + step * 0,
                friendship = zero + step * 2,
                alliance = zero + step * 4,
                max = zero + step * 6,
            }
            meanStartPosition = meanStartPosition + position
            meanStep = meanStep + step
            n = n + 1
        end
        meanStartPosition:scale(1/n)
        meanStep = meanStep / n
        for i = 0, 6 do
            local levelPosition = meanStartPosition + Vector(0, 0, meanStep * i)
            levelPosition:setAt('y', 0.5)
            Helper.createTransientAnchor(faction .. "Rank" .. tostring(i), levelPosition).doAfter(function (anchor)
                local actionName = I18N("progressOnInfluenceTrack", { withFaction = I18N(Helper.toCamelCase("with", faction)) })
                Helper.createSizedAreaButton(1000, 400, anchor, 0.75, actionName, PlayBoard.withLeader(function (_, color, _)
                    if not InfluenceTrack.actionsLocked[faction][color] then
                        if InfluenceTrack.hasAccess(color, faction) then
                            local rank = InfluenceTrack._getInfluenceTracksRank(faction, color)
                            InfluenceTrack.actionsLocked[faction][color] = true
                            PlayBoard.getLeader(color).influence(color, faction, i - rank, true).doAfter(function ()
                                InfluenceTrack.actionsLocked[faction][color] = false
                            end)
                        end
                    end
                end))
            end)
        end
        InfluenceTrack.influenceLevels[faction] = factionLevels
    end
end

---
function InfluenceTrack._processSnapPoints(settings, firstTime)
    -- TODO Get rid of the *InitialPositions variables

    local allColors = { "Green", "Yellow", "Blue", "Red", "Teal", "Brown" }

    local influenceTokens = {}
    for _, object in ipairs(getObjects()) do
        if object.hasTag("AllianceToken") then
            for faction, _ in pairs(InfluenceTrack.actionsLocked) do
                if object.hasTag(faction) then
                    InfluenceTrack.allianceTokens[faction] = object
                    break
                end
            end
        elseif object.hasTag("InfluenceTokens") then
            for _, color in ipairs(allColors) do
                if object.hasTag(color) then
                    table.insert(influenceTokens, object)
                    break
                end
            end
        end
    end

    local net = {
        faction = function (faction, position)
            InfluenceTrack.influenceTokens[faction] = {}
            InfluenceTrack.influenceTokenInitialPositions[faction] = {}
            for _, influenceToken in ipairs(influenceTokens) do
                local tokenPosition = influenceToken.getPosition()
                if tokenPosition.z < position.z and Vector.distance(tokenPosition, position) < 2 then
                    for _, color in ipairs(allColors) do
                        if influenceToken.hasTag(color) then
                            InfluenceTrack.influenceTokens[faction][color] = influenceToken

                            local xOffsets = {
                                Blue = -0.66,
                                Red = -0.22,
                                Green = 0.22,
                                Yellow = 0.66,
                                Teal = 0,
                                Brown = 0,
                            }
                            local influenceTokenInitialPosition = position + Vector(xOffsets[color], 0, -1.6)
                            InfluenceTrack.influenceTokenInitialPositions[faction][color] = influenceTokenInitialPosition
                            if firstTime then
                                --Helper.dump("Influence token", faction, color)
                                influenceToken.setPosition(influenceTokenInitialPosition)
                                Helper.noPhysicsNorPlay(influenceToken)
                            end
                            break
                        end
                    end
                end
            end

            local allianceTokenInitialPosition = position + Vector(-0.02, 0, 2.32)
            InfluenceTrack.allianceTokenInitialPositions[faction] = allianceTokenInitialPosition
            if firstTime then
                InfluenceTrack.allianceTokens[faction].setPositionSmooth(allianceTokenInitialPosition)
            end
        end
    }

    MainBoard.collectSnapPointsEverywhere(settings, net)
end

---
function InfluenceTrack.setUpSnoopers()
    for faction, snooper in pairs(InfluenceTrack.snoopers) do
        local position = MainBoard.getSnooperTrackPosition(faction)
        snooper.setPositionSmooth(position, false, false)
        snooper.setRotationSmooth(Vector(0, 90, 0))
        Helper.onceTimeElapsed(3).doAfter(function ()
            snooper.setLock(true)
        end, 3)
    end
end

---
function InfluenceTrack.tearDownSnoopers()
    for _, snooper in pairs(InfluenceTrack.snoopers) do
        snooper.destruct()
    end
end

---
function InfluenceTrack.recallSnooper(faction, color)

    local foundSnooper
    local snooperRank = 4
    for otherFaction, snooper in pairs(InfluenceTrack.snoopers) do
        local position = MainBoard.getSnooperTrackPosition(otherFaction)
        local distance = (snooper.getPosition() - position):magnitude()
        if distance < 1 then
            if otherFaction == faction then
                foundSnooper = snooper
            else
                snooperRank = snooperRank - 1
            end
        end
    end

    if foundSnooper then
        local p = PlayBoard.findLeaderCard(color).getPosition() + Vector(snooperRank / 4 - 2, 0.5, 1.4 - snooperRank / 2)
        Helper.noPlay(foundSnooper)
        foundSnooper.setPositionSmooth(p)

        Helper.onceTimeElapsed(1).doAfter(function()
            local parameters = { withFaction = I18N(Helper.toCamelCase("with", faction)) }
            local leader = PlayBoard.getLeader(color)
            if snooperRank == 1 then
                broadcastToAll(I18N("firstSnooperRecall", parameters), color)
                Player[color].showInfoDialog(I18N("firstSnooperRecallEffectInfo"))
            elseif snooperRank == 2 then
                broadcastToAll(I18N("secondSnooperRecall", parameters), color)
                InfluenceTrack._gainAllianceBonus(faction, color)
            elseif snooperRank == 3 then
                broadcastToAll(I18N("thirdSnooperRecall", parameters), color)
                leader.influence(color, faction, 1)
            elseif snooperRank == 4 then
                broadcastToAll(I18N("fourthSnooperRecall", parameters), color)
                InfluenceTrack._gainAllianceBonus(faction, color)
                leader.influence(color, faction, 1)
            else
                assert(false)
            end
        end)
    end
end

---
function InfluenceTrack.hasAccess(color, faction)
    Types.assertIsPlayerColor(color)
    Types.assertIsFaction(faction)
    if faction == "emperor" then
        return Commander.isShaddam(color)
    elseif faction == "fremen" then
        return Commander.isMuadDib(color)
    else
        return not Commander.isCommander(color)
    end
end

---
function InfluenceTrack.hasFriendship(color, faction)
    Types.assertIsPlayerColor(color)
    Types.assertIsFaction(faction)
    return InfluenceTrack.getInfluence(faction, color) >= 2
end

---
function InfluenceTrack.getInfluence(faction, color, direct)
    --Helper.dumpFunction("InfluenceTrack.getInfluence", faction, color)
    if TurnControl.getPlayerCount() == 6 and not direct then
        if Commander.isCommander(color) then
            local bestInfluence = 0
            for _, otherColor in ipairs(Commander.getAllies(color)) do
                bestInfluence = math.max(bestInfluence, InfluenceTrack.getInfluence(faction, otherColor))
            end
            if faction == "emperor" and Commander.isShaddam(color) then
                bestInfluence = math.max(bestInfluence, InfluenceTrack._getInfluenceTracksRank(faction, color))
            end
            if faction == "fremen" and Commander.isMuadDib(color) then
                bestInfluence = math.max(bestInfluence, InfluenceTrack._getInfluenceTracksRank(faction, color))
            end
            return bestInfluence
        else
            local finalFaction = faction
            if faction == "emperor" then
                finalFaction = "greatHouses"
            elseif faction == "fremen" then
                finalFaction = "fringeWorlds"
            end
            return InfluenceTrack._getInfluenceTracksRank(finalFaction, color)
        end
    else
        return InfluenceTrack._getInfluenceTracksRank(faction, color)
    end
end

---
function InfluenceTrack._getInfluenceTracksRank(faction, color)
    --Helper.dumpFunction("InfluenceTrack._getInfluenceTracksRank", faction, color)
    local influenceLevels = InfluenceTrack.influenceLevels[faction][color]
    local token = InfluenceTrack.influenceTokens[faction][color]
    if token then
        local pos = token.getPosition()
        return math.floor((pos.z - influenceLevels.none) / influenceLevels.step)
    else
        return 0
    end
end

---
function InfluenceTrack.change(color, faction, change)
    return InfluenceTrack._changeInfluenceTracksRank(color, faction, change)
end

---
function InfluenceTrack._changeInfluenceTracksRank(color, faction, change)
    --Helper.dumpFunction("InfluenceTrack._changeInfluenceTracksRank", color, faction, change)
    Types.assertIsPlayerColor(color)
    Types.assertIsFaction(faction)
    Types.assertIsInteger(change)

    local levels = InfluenceTrack.influenceLevels[faction][color]
    local token = InfluenceTrack.influenceTokens[faction][color]

    local oldRank = InfluenceTrack._getInfluenceTracksRank(faction, color)
    local direction = Helper.signum(change)

    local realChange = math.min(math.max(oldRank + change, 0), 6) - oldRank

    local continuation = Helper.createContinuation("InfluenceTrack._changeInfluenceTracksRank")

    Helper.repeatMovingAction(token, math.abs(realChange), function (_)
        local position = token.getPosition()
        position.z = position.z + levels.step * direction
        token.setPositionSmooth(position, false, false)
    end).doAfter(function (_)
        local newRank = InfluenceTrack._getInfluenceTracksRank(faction, color)
        --[[
            Check alliance before friendship (because friendship tokens come
            from a bag which induces a invisible transit with parks, ending in
            2 stacked tokens in the case a player gain 3+ influences on the
            track in a single move).
        ]]
        if oldRank >= 4 or newRank >= 4 then
            InfluenceTrack._challengeAlliance(faction)
        end

        if oldRank < 4 and newRank >= 4 then
            InfluenceTrack._gainAllianceBonus(faction, color)
        end
        if oldRank < 1 and newRank >= 1 then
            InfluenceTrack._gainCommanderBonus(faction, color, 1)
        end
        if oldRank < 2 and newRank >= 2 then
            InfluenceTrack._gainFriendship(faction, color)
        end
        if oldRank >= 2 and newRank < 2 then
            InfluenceTrack._loseFriendship(faction, color)
        end
        if oldRank < 3 and newRank >= 3 then
            InfluenceTrack._gainCommanderBonus(faction, color, 3)
        end

        continuation.run(realChange)
        Helper.emitEvent("influence", faction, color, newRank)
    end)

    return continuation
end

---
function InfluenceTrack._gainFriendship(faction, color)
    Types.assertIsFaction(faction)
    Types.assertIsPlayerColor(color)
    local token = InfluenceTrack.friendshipBags[faction]
    assert(token)
    PlayBoard.getLeader(color).gainVictoryPoint(color, Helper.getID(token))
end

---
function InfluenceTrack._loseFriendship(faction, color)
    local friendshipTokenName = faction .. "Friendship"
    for _, scoreToken in ipairs(PlayBoard.getScoreTokens(color)) do
        if Helper.getID(scoreToken) == friendshipTokenName then
            scoreToken.destruct()
        end
    end
end

---
function InfluenceTrack._challengeAlliance(faction)
    local bestRankedPlayers = {}
    local bestRank = 4
    local allianceOwner

    for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
        if InfluenceTrack.hasAlliance(color, faction) then
            allianceOwner = color
        end
        local rank = InfluenceTrack.getInfluence(faction, color, true)
        if rank >= bestRank then
            if rank > bestRank then
                bestRank = rank
                bestRankedPlayers = {}
            end
            table.insert(bestRankedPlayers, color)
        end
    end

    if not Helper.tableContains(bestRankedPlayers, allianceOwner) then
        InfluenceTrack._loseAlliance(faction, allianceOwner)

        if #bestRankedPlayers > 0 then
            if #bestRankedPlayers == 1 then
                allianceOwner = bestRankedPlayers[1]
                InfluenceTrack._gainAlliance(faction, allianceOwner)
            else
                broadcastToAll(tostring(allianceOwner) .. " must grant alliance to one of " .. tostring(bestRankedPlayers), "Pink") -- FIXME
            end
        end
    end
end

---
function InfluenceTrack.hasAlliance(color, faction)
    local playerVictoryTokens = PlayBoard.getScoreTokens(color)
    for _, victoryToken in ipairs(playerVictoryTokens) do
        if victoryToken == InfluenceTrack.allianceTokens[faction] then
            return true
        end
    end
    return false
end

---
function InfluenceTrack.hasAnyAlliance(color)
    for faction, _ in pairs(InfluenceTrack.influenceTokenInitialPositions) do
        if InfluenceTrack.hasAlliance(color, faction) then
            return true
        end
    end
    return false
end

---
function InfluenceTrack._gainAlliance(faction, color)
    Types.assertIsFaction(faction)
    Types.assertIsPlayerColor(color)
    local token = InfluenceTrack.allianceTokens[faction]
    assert(token)
    --Helper.dump(Helper.getID(token), "=", token.getGUID())
    PlayBoard.getLeader(color).gainVictoryPoint(color, Helper.getID(token))
end

---
function InfluenceTrack._gainAllianceBonus(faction, color)
    local leader = PlayBoard.getLeader(color)
    if not PlayBoard.isRival(color) then
        if TurnControl.getPlayerCount() == 6 then
            if faction == "greatHouses" then
                leader.troops(color, "supply", "garrison", 2)
            elseif faction == "spacingGuild" then
                leader.resources(color, "solari", 3)
            elseif faction == "beneGesserit" then
                leader.drawIntrigues(color, 1)
            elseif faction == "fringeWorlds" then
                -- 1 spy
            end
        else
            if faction == "emperor" then
                -- 1 spy
            elseif faction == "spacingGuild" then
                leader.resources(color, "solari", 3)
            elseif faction == "beneGesserit" then
                leader.drawIntrigues(color, 1)
            elseif faction == "fremen" then
                leader.resources(color, "water", 1)
            else
                error("Unknown faction: ", faction)
            end
        end
    end
end

---
function InfluenceTrack._gainCommanderBonus(faction, color, level)
    if TurnControl.getPlayerCount() == 6 then
        if faction == "emperor" then
            for _, otherColor in ipairs(Commander.getShaddamTeam()) do
                if level == 1 then
                    PlayBoard.getLeader(otherColor).resources(otherColor, "solari", 1)
                end
            end
        elseif faction == "fremen" then
            for _, otherColor in ipairs(Commander.getMuadDibTeam()) do
                if level == 1 then
                    PlayBoard.getLeader(otherColor).resources(otherColor, "spice", 1)
                elseif level == 3 then
                    PlayBoard.getLeader(otherColor).resources(otherColor, "water", 1)
                end
            end
        end
    end
end

---
function InfluenceTrack._loseAlliance(faction, color)
    local position = InfluenceTrack.allianceTokenInitialPositions[faction]
    InfluenceTrack.allianceTokens[faction].setPositionSmooth(position, false, false)
end

function InfluenceTrack.gainVictoryPoint(color, name)
    for _, friendshipTokenBag in pairs(InfluenceTrack.friendshipBags) do
        if Helper.getID(friendshipTokenBag) == name then
            PlayBoard.grantScoreTokenFromBag(color, friendshipTokenBag)
            return true
        end
    end
    for _, allianceToken in pairs(InfluenceTrack.allianceTokens) do
        if Helper.getID(allianceToken) == name then
            PlayBoard.grantScoreToken(color, allianceToken)
            return true
        end
    end
    return false
end

return InfluenceTrack
