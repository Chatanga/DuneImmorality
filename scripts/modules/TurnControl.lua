--[[
    Reify the turn sequence in interaction with the PlayBoard module (as well
    as Hagal and Commander for the more specialized game modes), emitting events
    along the way to offer a mean to other modules to activate when needed.
]]

local Module = require("utils.Module")
local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

local PlayBoard = Module.lazyRequire("PlayBoard")
local Commander = Module.lazyRequire("Commander")
local Hagal = Module.lazyRequire("Hagal")
local Deck = Module.lazyRequire("Deck")

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
    --Helper.dumpFunction("TurnControl.onLoad")
    if state.settings then
        if state.TurnControl then
            TurnControl.hotSeat = state.TurnControl.hotSeat
            TurnControl.players = state.TurnControl.players
            TurnControl.scoreGoal = state.TurnControl.scoreGoal
            TurnControl.specialPhase = state.TurnControl.specialPhase
            TurnControl.firstPlayerLuaIndex = state.TurnControl.firstPlayerLuaIndex
            TurnControl.counterClockWise = state.TurnControl.counterClockWise
            TurnControl.currentRound = state.TurnControl.currentRound
            TurnControl.currentPhase = state.TurnControl.currentPhase
            TurnControl.currentPlayerLuaIndex = state.TurnControl.currentPlayerLuaIndex
            TurnControl.customTurnSequence = state.TurnControl.customTurnSequence

            if TurnControl.currentPlayerLuaIndex then
                Helper.onceTimeElapsed(2).doAfter(TurnControl._notifyPlayerTurn)
            else
                TurnControl._createMakersAndRecallButton()
            end
        end
    end
end

function TurnControl.onSave(state)
    --Helper.dumpFunction("TurnControl.onSave")
    state.TurnControl = {
        hotSeat = TurnControl.hotSeat,
        players = TurnControl.players,
        scoreGoal = TurnControl.scoreGoal,
        specialPhase = TurnControl.specialPhase,
        firstPlayerLuaIndex = TurnControl.firstPlayerLuaIndex,
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

    if settings.numberOfPlayers == 1 then
        for i, player in ipairs(TurnControl.players) do
            if PlayBoard.isHuman(player) then
                TurnControl.firstPlayerLuaIndex = TurnControl._getNextPlayer(i)
                break
            end
        end
    elseif settings.numberOfPlayers == 2 then
        for i, player in ipairs(TurnControl.players) do
            if PlayBoard.isRival(player) then
                TurnControl.firstPlayerLuaIndex = TurnControl._getNextPlayer(i, math.random() > 0)
                break
            end
        end
        assert(TurnControl.firstPlayerLuaIndex)
    else
        local firstPlayer
        repeat
            TurnControl.firstPlayerLuaIndex = math.random(#TurnControl.players)
            firstPlayer = TurnControl.players[TurnControl.firstPlayerLuaIndex]
        until not Commander.isCommander(firstPlayer)
        TurnControl._assignObjectives()
    end
end

--- Return the (colors of the) active opponents in the mod canonical order,
--- starting from Green and progressing clockwise.
function TurnControl.toCanonicallyOrderedPlayerList(activeOpponents)
    local orderedColors = { "Green", "Brown", "Yellow", "Blue", "Teal", "Red" }

    local players = {}
    for _, color in ipairs(orderedColors) do
        if activeOpponents[color] then
            table.insert(players, color)
        end
    end

    return players
end

--- Generate an objective deck and randomly deal a card to each player within
--- two constraints: preserving the current first player (already choosen) and
--- not giving the same card to two allies (6P mode).
--- Note: it would be possible to designate the first player in this function,
--- but the two have been kept separated for historical reasons.
--- FIXME Way too convoluted!
function TurnControl._assignObjectives()
    local cardNames = { "crysknife" }
    if #TurnControl.players == 3 then
        table.insert(cardNames, "ornithopter1to3p")
    elseif #TurnControl.players >= 4 then
        table.insert(cardNames, "muadDib4to6p")
        table.insert(cardNames, "crysknife4to6p")
    else
        error("Unexpected number of players: " .. tostring(#TurnControl.players))
    end
    Helper.shuffle(cardNames)

    local objectiveCards = {}
    for i, color in ipairs(TurnControl.players) do
        if not Commander.isCommander(color) then
            if i == TurnControl.firstPlayerLuaIndex then
                objectiveCards[color] = "muadDibFirstPlayer"
            else
                objectiveCards[color] = cardNames[1]
                table.remove(cardNames, 1)
            end
        end
    end

    local getCategory = function (cardName)
        for _, category in ipairs({ "ornithopter", "crysknife", "muadDib" }) do
            if Helper.startsWith(cardName, category) then
                return category
            end
        end
        assert(false)
    end

    if #TurnControl.players == 6 and getCategory(objectiveCards.Green) == getCategory(objectiveCards.Yellow) then
        if objectiveCards.Green == "muadDibFirstPlayer" or objectiveCards.Red == "muadDibFirstPlayer" then
            local tmp = objectiveCards.Yellow
            objectiveCards.Yellow = objectiveCards.Blue
            objectiveCards.Blue = tmp
        else
            local tmp = objectiveCards.Green
            objectiveCards.Green = objectiveCards.Red
            objectiveCards.Red = tmp
        end
    end

    cardNames = {}
    for i, color in ipairs(TurnControl.players) do
        if not Commander.isCommander(color) then
            -- TODO Check ordering guarantees.
            cardNames[objectiveCards[color]] = 1
        end
    end

    local combatZone = getObjectFromGUID("6d632e")
    assert(combatZone)

    Deck.generateObjectiveDeck(combatZone, cardNames).doAfter(function (deck)
        assert(Helper.getDeckOrCard(combatZone) == deck)
        local reversedPlayers = Helper.shallowCopy(TurnControl.players)
        Helper.reverse(reversedPlayers)
        for i, color in ipairs(reversedPlayers) do
            if not Commander.isCommander(color) then
                PlayBoard.giveObjectiveCardFromZone(color, combatZone)
            end
        end
    end)
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
            broadcastToColor(I18N('noTouch'), color, "Brown")
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
        playerLuaIndex = TurnControl._getNextPlayer(playerLuaIndex, TurnControl.counterClockWise)
    until playerLuaIndex == TurnControl.firstPlayerLuaIndex
    return turnSequence
end

---
function TurnControl.overridePhaseTurnSequence(turnSequence)
    --Helper.dumpFunction("TurnControl.overridePhaseTurnSequence:", turnSequence)
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
    assert(TurnControl.firstPlayerLuaIndex, "A setup failure is highly probable!")
    TurnControl._startPhase(TurnControl.phaseOrder[1])
end

---
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
        TurnControl.currentPlayerLuaIndex = TurnControl._getNextPlayer(TurnControl.firstPlayerLuaIndex, TurnControl.counterClockWise)
    else
        TurnControl.currentPlayerLuaIndex = TurnControl.firstPlayerLuaIndex
    end

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
    Helper.onceStabilized().doAfter(function ()
        TurnControl._next(TurnControl._getNextPlayer(TurnControl.currentPlayerLuaIndex, TurnControl.counterClockWise))
    end)
end

---
function TurnControl.endOfPhase()
    local bestTrigger
    local heavyPhases = { "recall" }
    if Helper.isElementOf(TurnControl.currentPhase, heavyPhases) then
        bestTrigger = Helper.onceTimeElapsed(2)
    else
        bestTrigger = Helper.onceStabilized()
    end

    bestTrigger.doAfter(function ()
        if TurnControl.currentPhase then
            Helper.emitEvent("phaseEnd", TurnControl.currentPhase)
        end

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
        TurnControl._notifyPlayerTurn()
    else
        if TurnControl.currentPhase == "combat" then
            TurnControl._createMakersAndRecallButton()
        else
            TurnControl.endOfPhase()
        end
    end
end

function TurnControl._createMakersAndRecallButton()
    local fromIntRGB = function (r, g, b)
        return Color(r / 255, g / 255, b / 255)
    end

    Turns.order = {}
    Turns.enable = false

    local primaryTable = getObjectFromGUID("2b4b92")
    Helper.createAbsoluteButtonWithRoundness(primaryTable, 1, false, {
        click_function = Helper.registerGlobalCallback(function ()
            primaryTable.clearButtons()
            TurnControl.endOfPhase()
        end),
        label = I18N("makersAndRecall"),
        position = primaryTable.getPosition() + Vector(3.5, 1.8, -15.8),
        width = 2600,
        height = 420,
        font_size = 300,
        color = fromIntRGB(128, 77, 0),
        font_color = fromIntRGB(204, 153, 0),
    })
end

---
function TurnControl._notifyPlayerTurn()
    local playerColor = TurnControl.players[TurnControl.currentPlayerLuaIndex]
    local player = Helper.findPlayerByColor(playerColor)
    --Helper.dump(playerColor, "is", player.seated and "seated" or "not seated")
    if player then
        if not player.seated and (not TurnControl.hotSeat or not TurnControl._assumeDirectControl(playerColor)) then
            broadcastToAll(I18N("noSeatedPlayer", { color = I18N(playerColor) }), Color.fromString("Pink"))
        end
        Helper.onceFramesPassed(1).doAfter(function ()
            Turns.turn_color = playerColor
            Turns.order = { playerColor }
            if not Turns.enable and not TurnControl.hotSeat then
                Turns.enable = #Turns.order > 0
            end
            Helper.dump(">> Turn:", playerColor)
            Helper.emitEvent("playerTurns", TurnControl.currentPhase, playerColor)
        end)
    end
end

function TurnControl._assumeDirectControl(color)
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

    -- In 6P we add any seated player of the same team.
    if TurnControl.getPlayerCount() == 6 then
        for _, player in ipairs(Player.getPlayers()) do
            if player.seated and Commander.inSameTeam(color, player.color) then
                table.insert(legitimatePlayers, player)
            end
        end
    end

    -- Failing to find at least one, we take the host player.
    if Helper.isEmpty(legitimatePlayers) then
        for _, player in ipairs(Player.getPlayers()) do
            if player.host then
                table.insert(legitimatePlayers, player)
            end
        end
    end

    return legitimatePlayers
end

---
function TurnControl._findActivePlayer(startPlayerLuaIndex)
    --Helper.dumpFunction("TurnControl._findActivePlayer", startPlayerLuaIndex)
    assert(startPlayerLuaIndex)
    local playerLuaIndex = startPlayerLuaIndex
    local n = TurnControl.getPlayerCount()
    for _ = 1, n do
        if TurnControl._isPlayerActive(playerLuaIndex) then
            --Helper.dump("->", playerLuaIndex)
            return playerLuaIndex
        end
        playerLuaIndex = TurnControl._getNextPlayer(playerLuaIndex, TurnControl.counterClockWise)
    end
    --Helper.dump("-> -")
    return nil
end

---
function TurnControl._getNextPlayer(playerLuaIndex, counterClockWise)
    --Helper.dumpFunction("TurnControl._getNextPlayer", playerLuaIndex, counterClockWise)
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
        local nextPlayerLuaIndex
        if counterClockWise then
            nextPlayerLuaIndex = ((playerLuaIndex + n - 2) % n) + 1
        else
            nextPlayerLuaIndex = (playerLuaIndex % n) + 1
        end
        assert(nextPlayerLuaIndex)
        --Helper.dump("->", nextPlayerLuaIndex)
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
        -- return 'combatEnd' -- Skipped
        return 'makers'
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
    for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
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

---
function TurnControl.isHotSeatEnabled()
    return TurnControl.hotSeat
end

return TurnControl
