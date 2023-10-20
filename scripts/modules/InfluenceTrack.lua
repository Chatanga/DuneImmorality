local Module = require("utils.Module")
local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

local Utils = Module.lazyRequire("Utils")
local PlayBoard = Module.lazyRequire("PlayBoard")
local MainBoard = Module.lazyRequire("MainBoard")

local InfluenceTrack = {
    influenceTokenInitialPositions = {
        emperor = {
            Red = Helper.getHardcodedPositionFromGUID('acfcef', -9.718932, 0.752500057, 1.85002029),
            Blue = Helper.getHardcodedPositionFromGUID('426a23', -10.1873131, 0.7525, 1.85005832),
            Green = Helper.getHardcodedPositionFromGUID('d7c9ba', -9.273371, 0.754999936, 1.8500092),
            Yellow = Helper.getHardcodedPositionFromGUID('489871', -8.834659, 0.755000055, 1.85005462)
        },
        spacingGuild = {
            Red = Helper.getHardcodedPositionFromGUID('be464e', -9.737917, 0.752500057, -3.640007),
            Blue = Helper.getHardcodedPositionFromGUID('4069d8', -10.1552429, 0.7525, -3.64000773),
            Green = Helper.getHardcodedPositionFromGUID('89da7d', -9.288127, 0.754999936, -3.64001),
            Yellow = Helper.getHardcodedPositionFromGUID('9d0075', -8.846331, 0.755000055, -3.63998413)
        },
        beneGesserit = {
            Red = Helper.getHardcodedPositionFromGUID('713eae', -9.766583, 0.752500057, -9.100027),
            Blue = Helper.getHardcodedPositionFromGUID('2a88a6', -10.2121153, 0.7525, -9.100084),
            Green = Helper.getHardcodedPositionFromGUID('2dc980', -9.319731, 0.754999936, -9.100017),
            Yellow = Helper.getHardcodedPositionFromGUID('a3729e', -8.888711, 0.755000055, -9.100081)
        },
        fremen = {
            Red = Helper.getHardcodedPositionFromGUID('088f51', -9.762483, 0.752500057, -14.5700312),
            Blue = Helper.getHardcodedPositionFromGUID('0e6e41', -10.2238894, 0.7525, -14.5700541),
            Green = Helper.getHardcodedPositionFromGUID('d390dc', -9.328378, 0.754999936, -14.570013),
            Yellow = Helper.getHardcodedPositionFromGUID('77d7c8', -8.887749, 0.755000055, -14.5700006)
        }
    },
    allianceTokenInitialPositions = {
        emperor = Helper.getHardcodedPositionFromGUID('13e990', -9.511963, 0.78, 5.86089),
        spacingGuild = Helper.getHardcodedPositionFromGUID('ad1aae', -9.507135, 0.780000031, 0.24908106),
        beneGesserit = Helper.getHardcodedPositionFromGUID('33452e', -9.551374, 0.780000031, -5.21345472),
        fremen = Helper.getHardcodedPositionFromGUID('4c2bcc', -9.543688, 0.780000031, -10.6707687)
    },
    influenceLevels = {},
    actionsLocked = {
        emperor = {},
        spacingGuild = {},
        beneGesserit = {},
        fremen = {}
    },
}

---
function InfluenceTrack.onLoad()
    Helper.append(InfluenceTrack, Helper.resolveGUIDs(true, {
        snoopers = {
            emperor = "a58ce8",
            spacingGuild = "857f74",
            beneGesserit = "bed196",
            fremen = "b10897",
        },
        influenceTokens = {
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
        },
        friendshipBags = {
            emperor = "6a4186",
            spacingGuild = "400d45",
            beneGesserit = "e763f6",
            fremen = "8bcfe7"
        },
        allianceTokens = {
            emperor = '13e990',
            spacingGuild = 'ad1aae',
            beneGesserit = '33452e',
            fremen = '4c2bcc'
        }
    }))

    InfluenceTrack.influenceLevels = InfluenceTrack._initInfluenceTracksLevels()

    for _, bag in pairs(InfluenceTrack.friendshipBags) do
        bag.interactable = false
    end
end

---
function InfluenceTrack.setUp()
    -- NOP
end

---
function InfluenceTrack._initInfluenceTracksLevels()
    local influenceLevels = {}
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
                local actionName = "Progress on the " .. faction .. " influence track"
                Helper.createSizedAreaButton(1000, 400, anchor, 0.7, actionName, function (_, color, _)
                    if not InfluenceTrack.actionsLocked[faction][color] then
                        local rank = InfluenceTrack._getInfluenceTracksRank(faction, color)
                        InfluenceTrack.actionsLocked[faction][color] = true
                        InfluenceTrack._changeInfluenceTracksRank(color, faction, i - rank).doAfter(function ()
                            InfluenceTrack.actionsLocked[faction][color] = false
                        end)
                    end
                end)
            end)
        end
        influenceLevels[faction] = factionLevels
    end
    return influenceLevels
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
function InfluenceTrack.hasFriendship(color, faction)
    Utils.assertIsPlayerColor(color)
    Utils.assertIsFaction(faction)

    local influenceLevels = InfluenceTrack.influenceLevels[faction][color]
    if InfluenceTrack.influenceTokens[faction][color].getPosition().z > influenceLevels.friendship then
        return true
    end
end

---
function InfluenceTrack.getInfluence(faction, color)
    return InfluenceTrack._getInfluenceTracksRank(faction, color)
end

---
function InfluenceTrack._getInfluenceTracksRank(faction, color)
    local influenceLevels = InfluenceTrack.influenceLevels[faction][color]
    local pos = InfluenceTrack.influenceTokens[faction][color].getPosition()
    return math.floor((pos.z - influenceLevels.none) / influenceLevels.step)
end

---
function InfluenceTrack.change(color, faction, change)
    return InfluenceTrack._changeInfluenceTracksRank(color, faction, change)
end

---
function InfluenceTrack._changeInfluenceTracksRank(color, faction, change)
    Utils.assertIsPlayerColor(color)
    Utils.assertIsFaction(faction)
    Utils.assertIsInteger(change)

    local levels = InfluenceTrack.influenceLevels[faction][color]
    local token = InfluenceTrack.influenceTokens[faction][color]

    local oldRank = InfluenceTrack._getInfluenceTracksRank(faction, color)
    local direction = Helper.signum(change)

    local realChange = math.min(math.max(oldRank + change, 0), 6) - oldRank

    local continuation = Helper.createContinuation()

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
        if oldRank < 2 and newRank >= 2 then
            InfluenceTrack._gainFriendship(faction, color)
        end
        if oldRank >= 2 and newRank < 2 then
            InfluenceTrack._loseFriendship(faction, color)
        end
        continuation.run(realChange)
    end)

    return continuation
end

---
function InfluenceTrack._gainFriendship(faction, color)
    PlayBoard.getLeader(color).gainVictoryPoint(color, Helper.getID(InfluenceTrack.friendshipBags[faction]))
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

    for _, color in ipairs(PlayBoard.getPlayBoardColors()) do
        if InfluenceTrack.hasAlliance(color, faction) then
            allianceOwner = color
        end
        local rank = InfluenceTrack._getInfluenceTracksRank(faction, color)
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
                broadcastToAll(allianceOwner .. " must grant alliance to one of " .. tostring(bestRankedPlayers), "Pink")
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
    PlayBoard.getLeader(color).gainVictoryPoint(color, Helper.getID(InfluenceTrack.allianceTokens[faction]))
    if not PlayBoard.isRival(color) then
        InfluenceTrack._gainAllianceBonus(faction, color)
    end
end

---
function InfluenceTrack._gainAllianceBonus(faction, color)
    local leader = PlayBoard.getLeader(color)
    if not PlayBoard.isRival(color) then
        if faction == "emperor" then
            leader.troops(color, "supply", "garrison", 2)
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

---
function InfluenceTrack._loseAlliance(faction, color)
    local position = InfluenceTrack.allianceTokenInitialPositions[faction]
    InfluenceTrack.allianceTokens[faction].setPositionSmooth(position, false, false)
end

function InfluenceTrack.gainVictoryPoint(color, name)
    for _, friendshipTokenBag in pairs(InfluenceTrack.friendshipBags) do
        -- FIXME No "bag" suffix?
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
