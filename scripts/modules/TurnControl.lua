local Module = require("utils.Module")
local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

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
    currentRound = 0,
    currentPhaseLuaIndex = nil,
    currentPlayerLuaIndex = nil,
    customTurnSequence = nil,
}

function TurnControl.onLoad(state)
    Helper.append(TurnControl, Helper.resolveGUIDs(true, {
        forceEndOfTurnButton = "2d3ce4",
        forceEndOfPhaseButton = "26b41d"
    }))

    Helper.noPlay(TurnControl.forceEndOfTurnButton)
    Helper.noPlay(TurnControl.forceEndOfPhaseButton)

    if state.settings then
        if state.TurnControl then
            TurnControl.players = state.TurnControl.players
            TurnControl.scoreGoal = state.TurnControl.scoreGoal
            TurnControl.specialPhase = state.TurnControl.specialPhase
            TurnControl.firstPlayerLuaIndex = state.TurnControl.firstPlayerLuaIndex
            TurnControl.currentRound = state.TurnControl.currentRound
            TurnControl.currentPhaseLuaIndex = state.TurnControl.currentPhaseLuaIndex
            TurnControl.currentPlayerLuaIndex = state.TurnControl.currentPlayerLuaIndex
            TurnControl.customTurnSequence = state.TurnControl.customTurnSequence
        end
    end
end

function TurnControl.onSave(state)
    state.TurnControl = {
        players = TurnControl.players,
        scoreGoal = TurnControl.scoreGoal,
        specialPhase = TurnControl.specialPhase,
        firstPlayerLuaIndex = TurnControl.firstPlayerLuaIndex,
        --
        currentRound = TurnControl.currentRound,
        currentPhaseLuaIndex = TurnControl.currentPhaseLuaIndex,
        currentPlayerLuaIndex = TurnControl.currentPlayerLuaIndex,
        customTurnSequence = TurnControl.customTurnSequence,
    }
end

--- Initialize the turn system with the provided players (or all the seated players) and start a new round.
function TurnControl.setUp(settings, _, players)
    TurnControl.players = players
    TurnControl.scoreGoal = settings.epicMode and 12 or 10

    if settings.numberOfPlayers == 1 then
        for i, player in ipairs(players) do
            if PlayBoard.isHuman(player) then
                TurnControl.firstPlayerLuaIndex = TurnControl._getNextPlayer(i)
                break
            end
        end
    elseif settings.numberOfPlayers == 2 then
        for i, player in ipairs(players) do
            if PlayBoard.isRival(player) then
                -- TODO Random
                TurnControl.firstPlayerLuaIndex = TurnControl._getNextPlayer(i, math.random() > 0)
                break
            end
        end
        assert(TurnControl.firstPlayerLuaIndex)
    else
        -- TODO Random
        TurnControl.firstPlayerLuaIndex = math.random(#TurnControl.players)
    end

    TurnControl._bindButton("Force\nend of\nTurn", TurnControl.forceEndOfTurnButton, TurnControl.endOfTurn)
    TurnControl._bindButton("Force\nend of\nPhase", TurnControl.forceEndOfPhaseButton, TurnControl.endOfPhase)
end

---
function TurnControl._bindButton(label, button, callback)
    button.createButton({
        click_function = TurnControl._createExclusiveCallback(function (...)
            button.AssetBundle.playTriggerEffect(0)
            callback(...)
        end),
        position = Vector(0, 0.6, 0),
        label = label,
        width = 1500,
        height = 1500,
        color = { 0, 0, 0, 0 },
        font_size = 350,
        font_color = { 1, 1, 1, 100 }
    })
end

---
function TurnControl._createExclusiveCallback(innerCallback)
    return Helper.registerGlobalCallback(function (_, color, _)
        if color == "Black" then
            if not TurnControl.buttonsDisabled then
                TurnControl.buttonsDisabled = true
                Helper.onceTimeElapsed(0.5).doAfter(function ()
                    TurnControl.buttonsDisabled = false
                end)
                innerCallback()
            end
        else
            broadcastToColor(I18N('noTouch'), color, "Purple")
        end
    end)
end

---
function TurnControl.registerSpecialPhase(specialPhase)
    TurnControl.specialPhase = specialPhase
end

---
function TurnControl.getPhaseTurnSequence()
    local turnSequence = {}
    local playerLuaIndex = TurnControl.firstPlayerLuaIndex
    repeat
        table.insert(turnSequence, TurnControl.players[playerLuaIndex])
        playerLuaIndex = TurnControl._getNextPlayer(playerLuaIndex)
    until playerLuaIndex == TurnControl.firstPlayerLuaIndex
    return turnSequence
end

---
function TurnControl.overridePhaseTurnSequence(turnSequence)
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
function TurnControl.start()
    TurnControl._startPhase(TurnControl.phaseOrder[1])
end

---
function TurnControl._startPhase(phase)
    assert(phase)

    if phase == "roundStart" then
        TurnControl.currentRound = TurnControl.currentRound + 1
        if TurnControl.currentRound > 1 then
            TurnControl.firstPlayerLuaIndex = TurnControl._getNextPlayer(TurnControl.firstPlayerLuaIndex)
            if Hagal.getRivalCount() == 1 and PlayBoard.isRival(TurnControl.players[TurnControl.firstPlayerLuaIndex]) then
                TurnControl.firstPlayerLuaIndex = TurnControl._getNextPlayer(TurnControl.firstPlayerLuaIndex)
            end
        end
    end

    TurnControl.currentPhase = phase
    TurnControl.customTurnSequence = nil
    TurnControl.currentPlayerLuaIndex = TurnControl.firstPlayerLuaIndex

    local firstPlayer = TurnControl.players[TurnControl.firstPlayerLuaIndex]
    Helper.dump("> Round:", TurnControl.getCurrentRound(), "- Phase:", phase, "- first player:", firstPlayer)
    broadcastToAll(I18N(Helper.toCamelCase("phase", phase)), Color.fromString("Pink"))
    Helper.emitEvent("phaseStart", TurnControl.currentPhase, firstPlayer)

    Helper.onceFramesPassed(1).doAfter(function ()
        if TurnControl.customTurnSequence then
            if #TurnControl.customTurnSequence > 0 then
                TurnControl._next(TurnControl.customTurnSequence[1])
            else
                TurnControl.endOfPhase()
            end
        else
            TurnControl._next(TurnControl.currentPlayerLuaIndex)
        end
    end)
end

---
function TurnControl.endOfTurn()
    TurnControl._next(TurnControl._getNextPlayer(TurnControl.currentPlayerLuaIndex))
end

---
function TurnControl.endOfPhase()
    if TurnControl.currentPhase then
        Helper.emitEvent("phaseEnd", TurnControl.currentPhase)
    end
    local heavyPhases = { "leaderSelection", "recall" }
    local delay = Helper.isElementOf(TurnControl.currentPhase, heavyPhases) and 2 or 0
    Helper.onceTimeElapsed(delay).doAfter(function ()
        local nextPhase = TurnControl._getNextPhase(TurnControl.currentPhase)
        if nextPhase then
            TurnControl._startPhase(nextPhase)
        else
            TurnControl.currentPhase = nil
        end
    end)
end

---
function TurnControl._next(startPlayerLuaIndex)
    TurnControl.currentPlayerLuaIndex = TurnControl._findActivePlayer(startPlayerLuaIndex)
    if TurnControl.currentPlayerLuaIndex then
        local player = TurnControl.players[TurnControl.currentPlayerLuaIndex]
        Helper.dump(">> Turn:", player)
        Helper.emitEvent("playerTurns", TurnControl.currentPhase, player)
    else
        TurnControl.endOfPhase()
    end
end

---
function TurnControl._findActivePlayer(startPlayerLuaIndex)
    assert(startPlayerLuaIndex)
    local playerLuaIndex = startPlayerLuaIndex
    local n = TurnControl.getPlayerCount()
    for _ = 1, n do
        if TurnControl._isPlayerActive(playerLuaIndex) then
            return playerLuaIndex
        end
        playerLuaIndex = TurnControl._getNextPlayer(playerLuaIndex)
    end
    return nil
end

---
function TurnControl._getNextPlayer(playerLuaIndex)
    assert(playerLuaIndex)
    if TurnControl.customTurnSequence then
        for i, otherPlayerLuaIndex in ipairs(TurnControl.customTurnSequence) do
            if otherPlayerLuaIndex == playerLuaIndex then
                return TurnControl.customTurnSequence[(i % #TurnControl.customTurnSequence) + 1]
            end
        end
        error("Incorrect custom turn sequence")
    else
        local n = TurnControl.getPlayerCount()
        local nextPlayerLuaIndex = (playerLuaIndex % n) + 1
        assert(nextPlayerLuaIndex)
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
        return TurnControl.specialPhase or 'playerTurns'
    elseif phase == 'playerTurns' then
        return 'combat'
    elseif phase == 'combat' then
        return 'combatEnd'
    elseif phase == 'combatEnd' then
        return 'makers'
    elseif phase == 'makers' then
        return 'recall'
    elseif phase == 'recall' then
        if TurnControl._endgameGoalReached() then
            broadcastToAll(I18N("endgameReached"), Color.fromString("Pink"))
        end
        return TurnControl._endgameGoalReached(true) and 'endgame' or 'roundStart'
    elseif phase == 'endgame' then
        return nil
    elseif phase == TurnControl.specialPhase then
        return 'playerTurns'
    else
        error("Unknown phase: ", phase)
    end
end

---@param hardLimit boolean?
---@return boolean
function TurnControl._endgameGoalReached(hardLimit)
    if TurnControl.currentRound == 10 then
        return true
    elseif hardLimit then
        return false
    end

    local bestScore = 0
    for _, color in ipairs(PlayBoard.getPlayBoardColors()) do
        bestScore = math.max(bestScore, PlayBoard.getPlayBoard(color):getScore())
    end
    return bestScore >= TurnControl.scoreGoal
end

---
function TurnControl._isPlayerActive(playerLuaIndex)
    assert(playerLuaIndex)
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

---
function TurnControl.getCurrentRound()
    return TurnControl.currentRound
end

return TurnControl
