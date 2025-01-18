--[[
    Reify the turn sequence in interaction with the PlayBoard module (as well
    as Hagal and Commander for the more specialized game modes), emitting events
    along the way to offer a mean to other modules to activate when needed.
]]

local Module = require("utils.Module")
local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

local PlayBoard = Module.lazyRequire("PlayBoard")
local Hagal = Module.lazyRequire("Hagal")

local TurnControl = {
    hotSeat = false,
    players = {},
    firstPlayerLuaIndex = nil,
    counterClockWise = false,
    currentRound = 0,
    currentPhase = nil,
    currentPlayerLuaIndex = nil,
    customTurnSequence = nil,
}

function TurnControl.onLoad(state)
    if state.settings and state.TurnControl then
        TurnControl.hotSeat = state.TurnControl.hotSeat
        TurnControl.players = state.TurnControl.players
        TurnControl.scoreGoal = state.TurnControl.scoreGoal
        TurnControl.specialPhase = state.TurnControl.specialPhase
        TurnControl.firstPlayerLuaIndex = state.TurnControl.firstPlayerLuaIndex
        TurnControl.firstPlayerOfTheGame = state.TurnControl.firstPlayerOfTheGame
        TurnControl.counterClockWise = state.TurnControl.counterClockWise
        TurnControl.currentRound = state.TurnControl.currentRound
        TurnControl.currentPhase = state.TurnControl.currentPhase
        TurnControl.currentPlayerLuaIndex = state.TurnControl.currentPlayerLuaIndex
        TurnControl.customTurnSequence = state.TurnControl.customTurnSequence

        if TurnControl.currentPlayerLuaIndex then
            Helper.onceTimeElapsed(2).doAfter(Helper.partialApply(TurnControl._notifyPlayerTurn, true))
        else
            TurnControl._createReclaimRewardsButton()
        end
    end
end

function TurnControl.onSave(state)
    state.TurnControl = {
        hotSeat = TurnControl.hotSeat,
        players = TurnControl.players,
        scoreGoal = TurnControl.scoreGoal,
        specialPhase = TurnControl.specialPhase,
        firstPlayerLuaIndex = TurnControl.firstPlayerLuaIndex,
        firstPlayerOfTheGame = TurnControl.firstPlayerOfTheGame,
        counterClockWise = TurnControl.counterClockWise,
        currentRound = TurnControl.currentRound,
        currentPhase = TurnControl.currentPhase,
        currentPlayerLuaIndex = TurnControl.currentPlayerLuaIndex,
        customTurnSequence = TurnControl.customTurnSequence,
    }
end

--- Initialize the turn system with the provided players (or all the seated
--- players) and start a new round.
function TurnControl.setUp(settings, activeOpponents)
    TurnControl.hotSeat = settings.hotSeat
    TurnControl.players = TurnControl.toCanonicallyOrderedPlayerList(activeOpponents)
    TurnControl.scoreGoal = settings.epicMode and 12 or 10

    if settings.numberOfPlayers == 2 then
        for i, player in ipairs(TurnControl.players) do
            if PlayBoard.isRival(player) then
                TurnControl.firstPlayerLuaIndex = TurnControl._getNextPlayer(i, math.random() > 0)
                break
            end
        end
        assert(TurnControl.firstPlayerLuaIndex)
    elseif settings.numberOfPlayers == 1 then
        for i, player in ipairs(TurnControl.players) do
            if PlayBoard.isHuman(player) then
                TurnControl.firstPlayerLuaIndex = TurnControl._getNextPlayer(i)
                break
            end
        end
    elseif settings.firstPlayer == "Random" then
        TurnControl.firstPlayerLuaIndex = math.random(#TurnControl.players)
    else
        TurnControl.firstPlayerLuaIndex = 1
        while TurnControl.firstPlayerLuaIndex < #TurnControl.players and TurnControl.players[TurnControl.firstPlayerLuaIndex] ~= settings.firstPlayer do
            TurnControl.firstPlayerLuaIndex = TurnControl.firstPlayerLuaIndex + 1
        end
    end

    if not TurnControl.firstPlayerOfTheGame then
        TurnControl.firstPlayerOfTheGame = TurnControl.players[TurnControl.firstPlayerLuaIndex]
    end
end

--- Return the (colors of the) active opponents in the mod canonical order,
--- starting from Green and progressing clockwise.
function TurnControl.toCanonicallyOrderedPlayerList(activeOpponents)
    local orderedColors = { "Green", "Purple", "Yellow", "Blue", "White", "Red" }

    local players = {}
    for _, color in ipairs(orderedColors) do
        if activeOpponents[color] then
            table.insert(players, color)
        end
    end

    return players
end

function TurnControl.registerSpecialPhase(specialPhase)
    TurnControl.specialPhase = specialPhase
end

function TurnControl.getPhaseTurnSequence()
    local turnSequence = {}
    local playerLuaIndex = TurnControl.firstPlayerLuaIndex
    repeat
        table.insert(turnSequence, TurnControl.players[playerLuaIndex])
        playerLuaIndex = TurnControl._getNextPlayer(playerLuaIndex, TurnControl.counterClockWise)
    until playerLuaIndex == TurnControl.firstPlayerLuaIndex
    return turnSequence
end

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

function TurnControl.start()
    assert(TurnControl.firstPlayerLuaIndex, "A setup failure is highly probable!")
    TurnControl._startPhase("leaderSelection")
end

function TurnControl._startPhase(phase)
    assert(phase)
    TurnControl.lastTransition = os.time()

    local getNextPlayer = function ()
        return TurnControl._getNextPlayer(TurnControl.firstPlayerLuaIndex, TurnControl.counterClockWise)
    end

    if phase == "roundStart" then
        TurnControl.currentRound = TurnControl.currentRound + 1
        if TurnControl.currentRound > 1 then
            TurnControl.firstPlayerLuaIndex = getNextPlayer()
            -- Skip House Hagal which always play second.
            if Hagal.getRivalCount() == 1 and PlayBoard.isRival(TurnControl.players[TurnControl.firstPlayerLuaIndex]) then
                TurnControl.firstPlayerLuaIndex = getNextPlayer()
            end
        end
        -- Reverse turn sequence to have House Hagal second.
        if Hagal.getRivalCount() == 1 and not PlayBoard.isRival(TurnControl.players[getNextPlayer()]) then
            TurnControl.counterClockWise = not TurnControl.counterClockWise
        end
    end

    TurnControl.currentPhase = phase
    TurnControl.customTurnSequence = nil
    if phase == "leaderSelection" and TurnControl.counterClockWise then
        TurnControl.currentPlayerLuaIndex = getNextPlayer()
    else
        TurnControl.currentPlayerLuaIndex = TurnControl.firstPlayerLuaIndex
    end

    local firstPlayer = TurnControl.players[TurnControl.firstPlayerLuaIndex]
    Helper.dump("> Round:", TurnControl.getCurrentRound(), "- Phase:", phase)
    broadcastToAll(I18N(Helper.toCamelCase("phase", phase), { round = TurnControl.currentRound }), Color.fromString("Pink"))
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

function TurnControl.endOfTurn()
    Helper.onceStabilized().doAfter(function ()
        TurnControl._next(TurnControl._getNextPlayer(TurnControl.currentPlayerLuaIndex, TurnControl.counterClockWise))
    end)
end

function TurnControl.endOfPhase(haltAfter)
    local bestTrigger
    local heavyPhases = { "recall" }
    if TurnControl.getPlayerCount() < 3 then
        table.insert(heavyPhases, "combat")
    end
    if Helper.isElementOf(TurnControl.currentPhase, heavyPhases) then
        bestTrigger = Helper.onceTimeElapsed(2)
    else
        bestTrigger = Helper.onceStabilized()
    end

    -- Current phase could change meanwhile (not great though).
    local phase = TurnControl.currentPhase

    bestTrigger.doAfter(function ()
        if phase ~= TurnControl.currentPhase then
            Helper.dump(phase, "=/=", TurnControl.currentPhase)
        end
        if phase then
            Helper.emitEvent("phaseEnd", phase)
        end
        if not haltAfter then
            TurnControl._nextPhase()
        end
    end)
end

function TurnControl._nextPhase()
    local nextPhase = TurnControl._getNextPhase(TurnControl.currentPhase)
    if nextPhase then
        TurnControl._startPhase(nextPhase)
    else
        TurnControl.currentPhase = nil
    end
end

function TurnControl._next(startPlayerLuaIndex)
    TurnControl.currentPlayerLuaIndex = TurnControl._findActivePlayer(startPlayerLuaIndex)
    if TurnControl.currentPlayerLuaIndex then
        TurnControl._notifyPlayerTurn()
    else
        if TurnControl.currentPhase == "combat" then
            TurnControl._createReclaimRewardsButton()
            TurnControl.endOfPhase(true)
        elseif TurnControl.currentPhase == "combatEnd" and TurnControl._endgameGoalReached() and TurnControl.currentRound < 10 then
            TurnControl._createNextRoundButton()
            TurnControl.endOfPhase(true)
        else
            TurnControl.endOfPhase()
        end
    end
end

function TurnControl._getButtonAnchor()
    local primaryTable = getObjectFromGUID("2b4b92")

    local continuation = Helper.createContinuation("TurnControl._createReclaimRewardsButton")
    if not TurnControl.buttonAnchor then
        Helper.createTransientAnchor("AgentPark", primaryTable.getPosition() + Vector(5, 1.3, -15.8)).doAfter(function (anchor)
            TurnControl.buttonAnchor = anchor
            continuation.run(TurnControl.buttonAnchor)
        end)
    else
        continuation.run(TurnControl.buttonAnchor)
    end

    return continuation
end

function TurnControl._createReclaimRewardsButton()
    local fromIntRGB = function (r, g, b)
        return Color(r / 255, g / 255, b / 255)
    end

    Turns.order = {}
    Turns.enable = false

    TurnControl._getButtonAnchor().doAfter(function (anchor)
        Helper.createAbsoluteButtonWithRoundness(anchor, 1, {
            click_function = Helper.registerGlobalCallback(function ()
                anchor.clearButtons()
                TurnControl._nextPhase()
            end),
            label = I18N("reclaimRewards"),
            position = anchor.getPosition() + Vector(0, 0.5, 0),
            width = 3500,
            height = 420,
            font_size = 300,
            color = fromIntRGB(128, 77, 0),
            font_color = fromIntRGB(204, 153, 0),
        })
    end)
end

function TurnControl._createNextRoundButton()
    local fromIntRGB = function (r, g, b)
        return Color(r / 255, g / 255, b / 255)
    end

    Turns.order = {}
    Turns.enable = false

    TurnControl._getButtonAnchor().doAfter(function (anchor)
        Helper.createAbsoluteButtonWithRoundness(anchor, 1, {
            click_function = Helper.registerGlobalCallback(function ()
                anchor.clearButtons()
                TurnControl._nextPhase()
            end),
            label = I18N("doYouWantAnotherRound"),
            position = anchor.getPosition() + Vector(0, 0.5, 0),
            width = 3500,
            height = 420,
            font_size = 300,
            color = fromIntRGB(128, 77, 0),
            font_color = fromIntRGB(204, 153, 0),
        })
    end)
end

function TurnControl._notifyPlayerTurn(refreshing)
    local playerColor = TurnControl.players[TurnControl.currentPlayerLuaIndex]
    local player = Helper.findPlayerByColor(playerColor)
    if player then
        if  not player.seated and
            (not PlayBoard.isRival(playerColor) or TurnControl.currentPhase == "leaderSelection") and
            not TurnControl.assumeDirectControl(playerColor)
        then
            broadcastToAll(I18N("noSeatedPlayer", { color = I18N(playerColor) }), Color.fromString("Pink"))
        end
        Helper.onceFramesPassed(1).doAfter(function ()
            Turns.turn_color = playerColor
            Turns.order = { playerColor }
            if not Turns.enable and not TurnControl.hotSeat then
                Turns.enable = #Turns.order > 0
            end
            Helper.dump(">> Turn:", playerColor)
            Helper.emitEvent("playerTurn", TurnControl.currentPhase, playerColor, refreshing)
        end)
    end
end

function TurnControl.assumeDirectControl(color)
    local legitimatePlayers = TurnControl.getLegitimatePlayers(color)
    if not Helper.isEmpty(legitimatePlayers) then
        legitimatePlayers[1].changeColor(color)
        return true
    else
        return false
    end
end

function TurnControl.getLegitimatePlayers(color)

    local legitimatePlayers = {}

    if Helper.isEmpty(legitimatePlayers) then
        for _, player in ipairs(Player.getPlayers()) do
            if player.host then
                table.insert(legitimatePlayers, player)
            end
        end
    end

    return legitimatePlayers
end

function TurnControl._findActivePlayer(startPlayerLuaIndex)
    assert(startPlayerLuaIndex)
    local playerLuaIndex = startPlayerLuaIndex
    local n = TurnControl.getPlayerCount()
    for _ = 1, n do
        if TurnControl._isPlayerActive(playerLuaIndex) then
            return playerLuaIndex
        end
        playerLuaIndex = TurnControl._getNextPlayer(playerLuaIndex, TurnControl.counterClockWise)
    end
    return nil
end

function TurnControl._getNextPlayer(playerLuaIndex, counterClockWise)
    assert(playerLuaIndex)
    if TurnControl.customTurnSequence then
        for i, otherPlayerLuaIndex in ipairs(TurnControl.customTurnSequence) do
            if otherPlayerLuaIndex == playerLuaIndex then
                local nextPlayerLuaIndex = TurnControl.customTurnSequence[(i % #TurnControl.customTurnSequence) + 1]
                return nextPlayerLuaIndex
            end
        end
        error("Incorrect custom turn sequence")
    else
        local n = TurnControl.getPlayerCount()
        local nextPlayerLuaIndex
        if counterClockWise then
            nextPlayerLuaIndex = ((playerLuaIndex + n - 2) % n) + 1
        else
            nextPlayerLuaIndex = (playerLuaIndex % n) + 1
        end
        assert(nextPlayerLuaIndex)
        return nextPlayerLuaIndex
    end
end

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
        error("Unknown phase: " .. tostring(phase))
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
    for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
        bestScore = math.max(bestScore, PlayBoard.getPlayBoard(color):getScore())
    end
    return bestScore >= TurnControl.scoreGoal
end

function TurnControl._isPlayerActive(playerLuaIndex)
    assert(playerLuaIndex)
    local phase = TurnControl.currentPhase
    local color = TurnControl.players[playerLuaIndex]
    return PlayBoard.acceptTurn(phase, color)
end

function TurnControl.unused_isCombat()
    return TurnControl.currentPhase == "combat"
        or TurnControl.currentPhase == "combatEnd"
end

function TurnControl.getCurrentPlayer()
    return TurnControl.players[TurnControl.currentPlayerLuaIndex]
end

function TurnControl.getPlayerCount()
    return #TurnControl.players
end

function TurnControl.getPlayers()
    return TurnControl.players
end

function TurnControl.getFirstPlayer()
    return TurnControl.players[TurnControl.firstPlayerLuaIndex]
end

function TurnControl.getFirstPlayerOfTheGame()
    return TurnControl.firstPlayerOfTheGame
end

function TurnControl.getCurrentRound()
    return TurnControl.currentRound
end

function TurnControl.getCurrentPhase()
    return TurnControl.currentPhase
end

function TurnControl.isHotSeatEnabled()
    return TurnControl.hotSeat
end

return TurnControl
