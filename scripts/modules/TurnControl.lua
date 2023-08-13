local Module = require("utils.Module")
local Helper = require("utils.Helper")

local Playboard = Module.lazyRequire("Playboard")
local Hagal = Module.lazyRequire("Hagal")

local TurnControl = {
    phaseOrder = {
        'leaderSelection',
        'startOfGame',
        'startOfRound',
        'agentOrReveal',
        'combat',
        'outcome',
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
function TurnControl.setUp(players, epicMode, goToEleven)
    Turns.enable = false
    TurnControl.players = players

    local rivalCount = Hagal.getRivalCount()
    if rivalCount == 1 then
        for i, player in ipairs(players) do
            if Playboard.isRival(player) then
                TurnControl.firstPlayerLuaIndex = TurnControl.getNextPlayer(i, true)
                break
            end
        end
    elseif rivalCount == 2 then
        for i, player in ipairs(players) do
            if Playboard.isRival(player) then
                TurnControl.firstPlayerLuaIndex = i
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
function TurnControl.start(reverseLeaderSelection)
    TurnControl.startPhase(TurnControl.phaseOrder[1], reverseLeaderSelection)
end

---
function TurnControl.startPhase(phase, reversed)
    log("Start phase: " .. phase)
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
    Helper.emitEvent("phaseStart", TurnControl.currentPhase, TurnControl.players[TurnControl.firstPlayerLuaIndex])

    Wait.frames(function ()
        TurnControl.next(TurnControl.currentPlayerLuaIndex)
    end, 1)
end

---
function TurnControl.endOfTurn()
    TurnControl.next(TurnControl.getNextPlayer(TurnControl.currentPlayerLuaIndex, TurnControl.reversed))
end

---
function TurnControl.next(starPlayerLuaIndex)
    TurnControl.currentPlayerLuaIndex = TurnControl.findActivePlayer(starPlayerLuaIndex)
    --Helper.dump("TurnControl.currentPlayerLuaIndex =", TurnControl.currentPlayerLuaIndex)
    if TurnControl.currentPlayerLuaIndex then
        local player = TurnControl.players[TurnControl.currentPlayerLuaIndex]
        log("Turn phase: " .. player)
        Helper.emitEvent("phaseTurn", TurnControl.currentPhase, player)
    else
        local nextPhase = TurnControl.getNextPhase(TurnControl.currentPhase)
        if nextPhase then
            TurnControl.startPhase(nextPhase, false)
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

---
function TurnControl.getNextPhase(phase)
    if phase == 'leaderSelection' then
        return 'startOfGame'
    elseif phase == 'startOfGame' then
        return 'startOfRound'
    elseif phase == 'startOfRound' then
        return 'agentOrReveal'
    elseif phase == 'agentOrReveal' then
        return 'combat'
    elseif phase == 'combat' then
        return 'outcome'
    elseif phase == 'outcome' then
        -- Leave it to the players to decide when the game ends.
        return nil
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
    elseif phase == 'startOfGame' then
        if Playboard.getLeader(color).instruct(phase) then
            TurnControl.activatedPlayers[playerLuaIndex] = 1
            return true
        end
    elseif phase == 'startOfRound' then
        if Playboard.getLeader(color).instruct(phase) then
            TurnControl.activatedPlayers[playerLuaIndex] = 1
            return true
        end
    elseif phase == 'agentOrReveal' then
        return Playboard.couldSendAgentOrReveal(color)
    elseif phase == 'combat' then
        -- TODO Pass count < player in combat count.
        return Playboard.isInCombat(color)
    elseif phase == 'outcome' then
        -- TODO Player is victorious and the combat provied a reward (auto?) or a dreadnought needs to be placed or a combat card remains to be played.
        return Playboard.isInCombat(color)
    elseif phase == 'endgame' then
        return nil
    else
        assert(false)
    end

    return false
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
