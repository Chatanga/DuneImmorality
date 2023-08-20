local Module = require("utils.Module")
local Helper = require("utils.Helper")

local Playboard = Module.lazyRequire("Playboard")
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

    if settings.numberOfPlayers == 1 then
        for i, player in ipairs(players) do
            if Playboard.isHuman(player) then
                TurnControl.firstPlayerLuaIndex = TurnControl.getNextPlayer(i, true)
                break
            end
        end
    elseif settings.numberOfPlayers == 2 then
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
    if phase == "roundStart" then
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
function TurnControl.next(startPlayerLuaIndex)
    TurnControl.currentPlayerLuaIndex = TurnControl.findActivePlayer(startPlayerLuaIndex)
    Helper.dump("TurnControl.currentPlayerLuaIndex =", TurnControl.currentPlayerLuaIndex)
    if TurnControl.currentPlayerLuaIndex then
        local player = TurnControl.players[TurnControl.currentPlayerLuaIndex]
        log("--- Turn: " .. player .. " ---")
        Helper.emitEvent("playerTurns", TurnControl.currentPhase, player)
    else
        local nextPhase = TurnControl.getNextPhase(TurnControl.currentPhase)
        if nextPhase then
            TurnControl.reversed = Hagal.getRivalCount() == 1 and not TurnControl.reversed or false
            TurnControl.startPhase(nextPhase, TurnControl.reversed)
        end
    end
end

---
function TurnControl.findActivePlayer(startPlayerLuaIndex)
    local playerLuaIndex = startPlayerLuaIndex
    local n = TurnControl.getPlayerCount()
    for _ = 1, n do
        if TurnControl.isPlayerActive(playerLuaIndex) then
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
        return 'combatEnd'
    elseif phase == 'combatEnd' then
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
    return Playboard.acceptTurn(phase, color)
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

return TurnControl
