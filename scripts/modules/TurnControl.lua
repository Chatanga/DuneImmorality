local Module = require("utils.Module")
local Helper = require("utils.Helper")

local Playboard = Module.lazyRequire("Playboard")
local Combat = Module.lazyRequire("Combat")
local Hagal = Module.lazyRequire("Hagal")

local TurnControl = {
    phaseOrder = {
        'leaderSelection',
        'gameStart',
        'roundStart',
        'playerTurns',
        'combat',
        'outcome',
        'makers',
        'recall',
        'endgame',
    },
    players = {},
    firstPlayerLuaIndex = nil,
    reversed = false,
    currentRound = 0,
    currentPhaseLuaIndex = nil,
    currentPlayerLuaIndex = nil,
}

--- Initialize the turn system with the provided players (or all the seated players) and start a new round.
function TurnControl.setUp(numberOfPlayers, players)
    Turns.enable = false
    TurnControl.players = players

    if numberOfPlayers == 1 then
        for i, player in ipairs(players) do
            if Playboard.isHuman(player) then
                TurnControl.firstPlayerLuaIndex = TurnControl.getNextPlayer(i, true)
                break
            end
        end
    elseif numberOfPlayers == 2 then
        for i, player in ipairs(players) do
            if Playboard.isRival(player) then
                TurnControl.firstPlayerLuaIndex = TurnControl.getNextPlayer(i, math.random() > 0)
                break
            end
        end
        assert(TurnControl.firstPlayerLuaIndex)
    else
        TurnControl.firstPlayerLuaIndex = math.random(#TurnControl.players)
    end
end

---
function TurnControl.getFirstPlayer()
    return TurnControl.players[TurnControl.firstPlayerLuaIndex]
end

---
function TurnControl.getPhaseTurnSequence()
    local turnSequence = {}
    local playerLuaIndex = TurnControl.firstPlayerLuaIndex
    repeat
        table.insert(turnSequence, TurnControl.players[playerLuaIndex])
        playerLuaIndex = TurnControl.getNextPlayer(playerLuaIndex, TurnControl.reversed)
    until playerLuaIndex == TurnControl.firstPlayerLuaIndex
    return turnSequence
end

---
function TurnControl.setPhaseTurnSequence(turnSequence)
    TurnControl.customTurnSequence = {}
    for _, color in ipairs(turnSequence) do
        for playerLuaIndex, otherColor in ipairs(TurnControl.players) do
            if otherColor == color then
                table.insert(TurnControl.customTurnSequence, playerLuaIndex)
            end
        end
    end
end

---
function TurnControl.start(reverseLeaderSelection)
    TurnControl.startPhase(TurnControl.phaseOrder[1], reverseLeaderSelection)
end

---
function TurnControl.startPhase(phase, reversed)
    log("=== Phase: " .. phase .. " ===")
    broadcastToAll("Phase: " .. phase, Color.fromString("Pink"))
    if phase == "round" then
        TurnControl.currentRound = TurnControl.currentRound + 1
        if TurnControl.currentRound > 1 then
            TurnControl.firstPlayerLuaIndex = TurnControl.getNextPlayer(TurnControl.firstPlayerLuaIndex, TurnControl.reversed)
        end
    end

    TurnControl.reversed = reversed
    if TurnControl.currentPhase then
        Helper.emitEvent("phaseEnd", TurnControl.currentPhase)
    end
    TurnControl.currentPhase = phase
    if reversed then
        TurnControl.currentPlayerLuaIndex = TurnControl.getNextPlayer(TurnControl.firstPlayerLuaIndex, TurnControl.reversed)
    else
        TurnControl.currentPlayerLuaIndex = TurnControl.firstPlayerLuaIndex
    end
    TurnControl.activatedPlayers = {}
    TurnControl.customTurnSequence = nil
    Helper.emitEvent("phaseStart", TurnControl.currentPhase, TurnControl.players[TurnControl.firstPlayerLuaIndex])

    Wait.frames(function ()
        if TurnControl.customTurnSequence then
            TurnControl.next(TurnControl.customTurnSequence[1])
        else
            TurnControl.next(TurnControl.currentPlayerLuaIndex)
        end
    end, 1)
end

---
function TurnControl.endOfTurn()
    TurnControl.next(TurnControl.getNextPlayer(TurnControl.currentPlayerLuaIndex, TurnControl.reversed))
end

---
function TurnControl.next(starPlayerLuaIndex)
    TurnControl.currentPlayerLuaIndex = TurnControl.findActivePlayer(starPlayerLuaIndex)
    Helper.dump("TurnControl.currentPlayerLuaIndex =", TurnControl.currentPlayerLuaIndex)
    if TurnControl.currentPlayerLuaIndex then
        local player = TurnControl.players[TurnControl.currentPlayerLuaIndex]
        log("--- Turn: " .. player .. " ---")
        Helper.emitEvent("phaseTurn", TurnControl.currentPhase, player)
    else
        local nextPhase = TurnControl.getNextPhase(TurnControl.currentPhase)
        if nextPhase then
            TurnControl.reversed = Hagal.getRivalCount() == 1 and not TurnControl.reversed or false
            TurnControl.startPhase(nextPhase, TurnControl.reversed)
        end
    end
end

---
function TurnControl.findActivePlayer(starPlayerLuaIndex)
    local playerLuaIndex = starPlayerLuaIndex
    local n = TurnControl.getPlayerCount()
    for _ = 1, n do
        if not TurnControl.activatedPlayers[playerLuaIndex] and TurnControl.isPlayerActive(playerLuaIndex) then
            return playerLuaIndex
        end
        playerLuaIndex = TurnControl.getNextPlayer(playerLuaIndex, TurnControl.reversed)
    end
    return nil
end

---
function TurnControl.getNextPlayer(playerLuaIndex, reversed)
    if TurnControl.customTurnSequence then
        for i, otherPlayerLuaIndex in ipairs(TurnControl.customTurnSequence) do
            if otherPlayerLuaIndex == playerLuaIndex then
                return TurnControl.customTurnSequence[(i % #TurnControl.customTurnSequence) + 1]
            end
        end
        error("Incorrect custom turn sequence")
    else
        local n = TurnControl.getPlayerCount()
        local nextPlayerLuaIndex
        if reversed then
            nextPlayerLuaIndex = ((playerLuaIndex + n - 2) % n) + 1
        else
            nextPlayerLuaIndex = (playerLuaIndex % n) + 1
        end
        --Helper.dump(playerLuaIndex, " % ", n, "->", nextPlayerLuaIndex)
        return nextPlayerLuaIndex
    end
end

---
function TurnControl.getNextPhase(phase)
    if phase == 'leaderSelection' then
        return 'gameStart'
    elseif phase == 'gameStart' then
        return 'roundStart'
    elseif phase == 'roundStart' then
        return 'playerTurns'
    elseif phase == 'playerTurns' then
        return 'combat'
    elseif phase == 'combat' then
        return 'outcome'
    elseif phase == 'outcome' then
        return 'makers'
    elseif phase == 'makers' then
        return 'recall'
    elseif phase == 'recall' then
        -- Leave it to the players to decide when the game ends.
        --return 'endgame'
        return 'roundStart'
    elseif phase == 'endgame' then
        return nil
    else
        assert(false)
    end
end

---
function TurnControl.isPlayerActive(playerLuaIndex)
    local phase = TurnControl.currentPhase
    local color = TurnControl.players[playerLuaIndex]
    --Helper.dump(playerLuaIndex, "->", color)

    if phase == 'leaderSelection' then
        return Playboard.getLeader(color) == nil
    elseif phase == 'gameStart' then
        if Playboard.getLeader(color).instruct(phase, color) then
            TurnControl.activatedPlayers[playerLuaIndex] = 1
            return true
        end
    elseif phase == 'roundStart' then
        if Playboard.getLeader(color).instruct(phase, color) then
            TurnControl.activatedPlayers[playerLuaIndex] = 1
            return true
        end
    elseif phase == 'playerTurns' then
        return Playboard.couldSendAgentOrReveal(color)
    elseif phase == 'combat' then
        -- TODO Pass count < player in combat count.
        TurnControl.activatedPlayers[playerLuaIndex] = 1
        return Combat.isInCombat(color)
    elseif phase == 'outcome' then
        -- TODO Player is victorious and the combat provied a reward (auto?) or a dreadnought needs to be placed or a combat card remains to be played.
        TurnControl.activatedPlayers[playerLuaIndex] = 1
        return Combat.isInCombat(color)
    elseif phase == 'makers' then
        return false
    elseif phase == 'recall' then
        return false
    elseif phase == 'endgame' then
        -- TODO
        return false
    else
        error("Unknown phase: " .. phase)
    end
end

---
function TurnControl.isCombat()
    return TurnControl.currentPhase == "combat"
        or TurnControl.currentPhase == "outcome"
end

---
function TurnControl.getCurrentPlayer()
    return TurnControl.players[TurnControl.currentPlayerLuaIndex]
end

---
function TurnControl.getPlayerCount()
    return #TurnControl.players
end

---
function TurnControl.getPlayers()
    return TurnControl.players
end

return TurnControl
