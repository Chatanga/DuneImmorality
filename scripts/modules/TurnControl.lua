local Module = require("utils.Module")
local Helper = require("utils.Helper")

local PlayBoard = Module.lazyRequire("PlayBoard")
local Hagal = Module.lazyRequire("Hagal")

local TurnControl = {
    phaseOrder = {
        'leaderSelection',
        'gameStart',
        'roundStart',
        'playerTurns',
        'combat',
        'combatEnd',
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

function TurnControl.onLoad(state)
    if state.TurnControl then
        TurnControl.players = state.TurnControl.players
        TurnControl.firstPlayerLuaIndex = state.TurnControl.firstPlayerLuaIndex
        TurnControl.reversed = state.TurnControl.reversed
        TurnControl.currentRound = state.TurnControl.currentRound
        TurnControl.currentPhaseLuaIndex = state.TurnControl.currentPhaseLuaIndex
        TurnControl.currentPlayerLuaIndex = state.TurnControl.currentPlayerLuaIndex
    end
end

function TurnControl.onSave(state)
    state.TurnControl = {
        players = TurnControl.players,
        firstPlayerLuaIndex = TurnControl.firstPlayerLuaIndex,
        reversed = TurnControl.reversed,
        currentRound = TurnControl.currentRound,
        currentPhaseLuaIndex = TurnControl.currentPhaseLuaIndex,
        currentPlayerLuaIndex = TurnControl.currentPlayerLuaIndex,
    }
end

--- Initialize the turn system with the provided players (or all the seated players) and start a new round.
function TurnControl.setUp(settings, players)
    Turns.enable = false
    TurnControl.players = players
    TurnControl.scoreGoal = settings.epicMode and 12 or 10

    if settings.numberOfPlayers == 1 then
        for i, player in ipairs(players) do
            if PlayBoard.isHuman(player) then
                TurnControl.firstPlayerLuaIndex = TurnControl._getNextPlayer(i, true)
                break
            end
        end
    elseif settings.numberOfPlayers == 2 then
        for i, player in ipairs(players) do
            if PlayBoard.isRival(player) then
                TurnControl.firstPlayerLuaIndex = TurnControl._getNextPlayer(i, math.random() > 0)
                break
            end
        end
        assert(TurnControl.firstPlayerLuaIndex)
    else
        TurnControl.firstPlayerLuaIndex = math.random(#TurnControl.players)
    end
end

---
function TurnControl.getPhaseTurnSequence()
    local turnSequence = {}
    local playerLuaIndex = TurnControl.firstPlayerLuaIndex
    repeat
        table.insert(turnSequence, TurnControl.players[playerLuaIndex])
        playerLuaIndex = TurnControl._getNextPlayer(playerLuaIndex, TurnControl.reversed)
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
    TurnControl._startPhase(TurnControl.phaseOrder[1], reverseLeaderSelection)
end

---
function TurnControl._startPhase(phase, reversed)
    assert(phase)

    log("=== Phase: " .. phase .. " ===")
    broadcastToAll("Phase: " .. phase, Color.fromString("Pink"))
    if phase == "roundStart" then
        TurnControl.currentRound = TurnControl.currentRound + 1
        if TurnControl.currentRound > 1 then
            TurnControl.firstPlayerLuaIndex = TurnControl._getNextPlayer(TurnControl.firstPlayerLuaIndex, TurnControl.reversed)
        end
    end

    TurnControl.reversed = reversed
    if TurnControl.currentPhase then
        Helper.emitEvent("phaseEnd", TurnControl.currentPhase)
    end
    TurnControl.currentPhase = phase
    if reversed then
        TurnControl.currentPlayerLuaIndex = TurnControl._getNextPlayer(TurnControl.firstPlayerLuaIndex, TurnControl.reversed)
    else
        TurnControl.currentPlayerLuaIndex = TurnControl.firstPlayerLuaIndex
    end
    TurnControl.customTurnSequence = nil
    Helper.emitEvent("phaseStart", TurnControl.currentPhase, TurnControl.players[TurnControl.firstPlayerLuaIndex])

    Wait.frames(function ()
        if TurnControl.customTurnSequence then
            TurnControl._next(TurnControl.customTurnSequence[1])
        else
            TurnControl._next(TurnControl.currentPlayerLuaIndex)
        end
    end, 1)
end

---
function TurnControl.endOfTurn()
    TurnControl._next(TurnControl._getNextPlayer(TurnControl.currentPlayerLuaIndex, TurnControl.reversed))
end

---
function TurnControl._next(startPlayerLuaIndex)
    TurnControl.currentPlayerLuaIndex = TurnControl._findActivePlayer(startPlayerLuaIndex)
    --Helper.dump("TurnControl.currentPlayerLuaIndex =", TurnControl.currentPlayerLuaIndex)
    if TurnControl.currentPlayerLuaIndex then
        local player = TurnControl.players[TurnControl.currentPlayerLuaIndex]
        log("--- Turn: " .. player .. " ---")
        Helper.emitEvent("playerTurns", TurnControl.currentPhase, player)
    else
        local nextPhase = TurnControl._getNextPhase(TurnControl.currentPhase)
        if nextPhase then
            TurnControl.reversed = Hagal.getRivalCount() == 1 and not TurnControl.reversed or false
            TurnControl._startPhase(nextPhase, TurnControl.reversed)
        else
            TurnControl.currentPhase = nil
            Helper.emitEvent("phaseEnd", TurnControl.currentPhase)
        end
    end
end

---
function TurnControl._findActivePlayer(startPlayerLuaIndex)
    local playerLuaIndex = startPlayerLuaIndex
    local n = TurnControl.getPlayerCount()
    for _ = 1, n do
        if TurnControl._isPlayerActive(playerLuaIndex) then
            return playerLuaIndex
        end
        playerLuaIndex = TurnControl._getNextPlayer(playerLuaIndex, TurnControl.reversed)
    end
    return nil
end

---
function TurnControl._getNextPlayer(playerLuaIndex, reversed)
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
function TurnControl._getNextPhase(phase)
    if phase == 'leaderSelection' then
        return 'gameStart'
    elseif phase == 'gameStart' then
        return 'roundStart'
    elseif phase == 'roundStart' then
        return 'playerTurns'
    elseif phase == 'playerTurns' then
        return 'combat'
    elseif phase == 'combat' then
        return 'combatEnd'
    elseif phase == 'combatEnd' then
        return 'makers'
    elseif phase == 'makers' then
        return 'recall'
    elseif phase == 'recall' then
        return TurnControl._endgameGoalReached() and 'endgame' or 'roundStart'
    elseif phase == 'endgame' then
        return nil
    else
        assert(false)
    end
end

---
function TurnControl._endgameGoalReached()
    local bestScore = 0
    for _, color in ipairs(PlayBoard.getPlayboardColors()) do
        bestScore = math.max(bestScore, PlayBoard.getPlayboard(color):getScore())
    end
    return bestScore >= TurnControl.scoreGoal
end

---
function TurnControl._isPlayerActive(playerLuaIndex)
    local phase = TurnControl.currentPhase
    local color = TurnControl.players[playerLuaIndex]
    return PlayBoard.acceptTurn(phase, color)
end

---
function TurnControl.isCombat()
    return TurnControl.currentPhase == "combat"
        or TurnControl.currentPhase == "combatEnd"
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

---
function TurnControl.getFirstPlayer()
    return TurnControl.players[TurnControl.firstPlayerLuaIndex]
end

return TurnControl
