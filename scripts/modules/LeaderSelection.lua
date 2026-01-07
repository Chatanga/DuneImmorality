local Module = require("utils.Module")
local Helper = require("utils.Helper")
local I18N = require("utils.I18N")
local Dialog = require("utils.Dialog")

local Deck = Module.lazyRequire("Deck")
local TurnControl = Module.lazyRequire("TurnControl")
local PlayBoard = Module.lazyRequire("PlayBoard")
local Hagal = Module.lazyRequire("Hagal")
local Board = Module.lazyRequire("Board")

local LeaderSelection = {
    dynamicLeaderSelection = {},
    turnSequence = {},
}

local Stage = {
    INITIALIZED = 1,
    STARTED = 2,
    DONE = 3,
}

---@param numberOfPlayers integer
---@return string[]
function LeaderSelection.getSelectionMethods(numberOfPlayers)
    local selectionMode = {
        random = "random",
        reversePick = "reversePick",
        reverseHiddenPick = "reverseHiddenPick",
    }
    if numberOfPlayers == 4 then
        selectionMode.altHiddenPick = "altHiddenPick"
    end
    return selectionMode
end

---@param state table
function LeaderSelection.onLoad(state)
    Helper.append(LeaderSelection, Helper.resolveGUIDs(false, {
        deckZone = "23f2b5",
        secondaryTable = GameTableGUIDs.secondary,
    }))

    if state.settings and state.LeaderSelection then
        LeaderSelection._transientSetUp(
            state.settings,
            state.LeaderSelection.leaderSelectionPoolSize,
            state.LeaderSelection.players,
            state.LeaderSelection.stage)
    end
end

---@param state table
function LeaderSelection.onSave(state)
    state.LeaderSelection = {
        leaderSelectionPoolSize = LeaderSelection.leaderSelectionPoolSize,
        players = LeaderSelection.players,
        stage = LeaderSelection.stage,
    }
end

---@param settings Settings
---@param activeOpponents table<PlayerColor, ActiveOpponent>
---@return Continuation
function LeaderSelection.setUp(settings, activeOpponents)
    --[[
    Works as long as LeaderSelection is the last module to use Board (the others
    being MainBoard and TechMarket actually). It should be in Global, but
    LeaderSelection needs a clean secondary table before.
    ]]
    Board.destructInactiveBoards()

    local preContinuation = Helper.fakeContinuation("LeaderSelection.setUp.preContinuation")

    local postContinuation = Helper.createContinuation("LeaderSelection.setUp.postContinuation")

    preContinuation.doAfter(function ()
        Deck.generateLeaderDeck(LeaderSelection.deckZone, settings).doAfter(function (deck)
            local start = settings.numberOfPlayers > 2 and 0 or 12
            LeaderSelection._layoutLeaderDeck(deck, start).doAfter(function ()
                if true then
                    local players = TurnControl.toCanonicallyOrderedPlayerList(activeOpponents)
                    LeaderSelection._transientSetUp(settings, settings.leaderPoolSize, players, Stage.INITIALIZED)
                end
                postContinuation.run()
            end)
        end)
    end)

    return postContinuation
end

---@param deck Deck
---@param start integer
---@return Continuation
function LeaderSelection._layoutLeaderDeck(deck, start)
    local continuation = Helper.createContinuation("LeaderSelection._layoutLeaderDeck")
    local numberOfLeaders = deck.getQuantity()
    local count = numberOfLeaders

    LeaderSelection._layoutLeaders(start, numberOfLeaders, function (_, position)
        deck.takeObject({
            position = position,
            flip = true,
            callback_function = function (card)
                if card.hasTag("Unselected") then
                    card.flip()
                end
                count = count - 1
                if count == 0 then
                    Helper.onceTimeElapsed(1).doAfter(continuation.run)
                end
            end
        })
    end)

    return continuation
end

---@param settings Settings
---@param leaderSelectionPoolSize integer
---@param players PlayerColor[]
---@param stage integer
function LeaderSelection._transientSetUp(settings, leaderSelectionPoolSize, players, stage)
    LeaderSelection.leaderSelectionPoolSize = leaderSelectionPoolSize
    LeaderSelection.players = players
    LeaderSelection.stage = stage

    if LeaderSelection.stage == Stage.DONE then
        return
    end

    -- Do it *before* calling _setUpXxx which could trigger an immediate
    -- TurnControl.start and a subsequent "leaderSelection" phase event.
    Helper.registerEventListener("phaseStart", function (phase, firstPlayer)
        if phase == "leaderSelection" then
            local turnSequence = Helper.shallowCopy(players)
            while turnSequence[1] ~= firstPlayer do
                Helper.cycleInPlace(turnSequence)
            end

            if settings.leaderSelection == "reversePick" then
                Helper.reverseInPlace(turnSequence)
            elseif settings.leaderSelection == "reverseHiddenPick" then
                Helper.reverseInPlace(turnSequence)
            elseif settings.leaderSelection == "altHiddenPick" then
                Helper.reverseInPlace(turnSequence)
                if #turnSequence == 4 then
                    Helper.swap(turnSequence, 4, 3)
                else
                    Helper.dump("Skipping 4 <-> 3 for less than 4 players.")
                end
            end

            TurnControl.overridePhaseTurnSequence(turnSequence)
        end
    end)

    local autoStart = not settings.tweakLeaderSelection
    local testSetUp = type(settings.leaderSelection) == "table"

    if testSetUp then
        local leaderNames = settings.leaderSelection
        ---@cast leaderNames string[]
        LeaderSelection._setUpTest(players, leaderNames)
    elseif settings.leaderSelection == "random" then
        LeaderSelection._setUpPicking(autoStart, true, false)
    elseif settings.leaderSelection == "reversePick" then
        LeaderSelection._setUpPicking(autoStart, false, false)
    elseif settings.leaderSelection == "reverseHiddenPick" then
        LeaderSelection._setUpPicking(autoStart, false, true)
    elseif settings.leaderSelection == "altHiddenPick" then
        LeaderSelection._setUpPicking(autoStart, false, true)
    else
        error(settings.leaderSelection)
    end

    Helper.registerEventListener("phaseEnd", function (phase)
        if phase == 'gameStart' then
            for _, object in ipairs(LeaderSelection.deckZone.getObjects()) do
                if settings.variant ~= 'arrakeenScouts' then
                -- if object ~= LeaderSelection.secondaryTable then
                    object.destruct()
                end
            end
        end
    end)
end

---@param start integer
---@param count integer
---@param callback fun(index: integer, position: Vector)
function LeaderSelection._layoutLeaders(start, count, callback)
    local h = LeaderSelection.deckZone.getScale().z
    local colCount = 6
    local origin = LeaderSelection.deckZone.getPosition() - Vector((colCount / 2 - 0.5) * 5, 0, h / 2 - 10)
    for i = start, start + count - 1 do
        local x = (i % colCount) * 5
        local y = math.floor(i / colCount) * 4
        callback(i + 1, origin + Vector(x, 1, y))
    end
end

--- Return all the leaders laid out on the secondary table.
---@return Card[]
function LeaderSelection._grabLeaders()
    local leaders = {}
    for _, object in ipairs(LeaderSelection.deckZone.getObjects()) do
        if (object.hasTag("Leader")) then
            leaders[Helper.getID(object)] = object
        end
    end
    return leaders
end

---@param players PlayerColor[]
---@param leaderNames string[]
function LeaderSelection._setUpTest(players, leaderNames)
    local leaders = LeaderSelection._grabLeaders()

    for _, color in pairs(players) do
        assert(leaderNames[color], "No leader for color " .. color)
        assert(#LeaderSelection.deckZone.getObjects(), "No leader to select")
        local leaderName = leaderNames[color]
        local leader = leaders[leaderName]
        assert(leader, "Unknown leader " .. tostring(leaderName))
        PlayBoard.setLeader(color, leader)
    end

    LeaderSelection.stage = Stage.DONE
    TurnControl.start()
end

---@param autoStart boolean
---@param random boolean
---@param hidden boolean
function LeaderSelection._setUpPicking(autoStart, random, hidden)
    local fontColor = Color(223/255, 151/255, 48/255)

    if LeaderSelection.stage == Stage.INITIALIZED then
        if not random then
            Helper.createAbsoluteButtonWithRoundness(LeaderSelection.secondaryTable, 2, {
                click_function = Helper.registerGlobalCallback(),
                label = I18N("leaderSelectionAdjust"),
                position = LeaderSelection.secondaryTable.getPosition() + Vector(0, 1.8, -28),
                width = 0,
                height = 0,
                font_size = 250,
                font_color = fontColor
            })

            local adjustValue = function (value)
                local numberOfLeaders = #Helper.getKeys(LeaderSelection._grabLeaders())
                local minValue = #LeaderSelection.players
                local maxValue = numberOfLeaders
                LeaderSelection.leaderSelectionPoolSize = math.max(minValue, math.min(maxValue, value))
                LeaderSelection.secondaryTable.editButton({ index = 2, label = tostring(LeaderSelection.leaderSelectionPoolSize) })
            end

            Helper.createAbsoluteButtonWithRoundness(LeaderSelection.secondaryTable, 2, {
                click_function = Helper.registerGlobalCallback(function ()
                    adjustValue(LeaderSelection.leaderSelectionPoolSize - 1)
                end),
                label = "-",
                position = LeaderSelection.secondaryTable.getPosition() + Vector(-1, 1.8, -29),
                width = 400,
                height = 400,
                font_size = 600,
                color = fontColor,
                font_color = { 0, 0, 0, 1 }
            })

            Helper.createAbsoluteButtonWithRoundness(LeaderSelection.secondaryTable, 1, {
                click_function = Helper.registerGlobalCallback(),
                label = tostring(LeaderSelection.leaderSelectionPoolSize),
                position = LeaderSelection.secondaryTable.getPosition() + Vector(0, 1.8, -29),
                width = 0,
                height = 0,
                font_size = 400,
                font_color = fontColor
            })

            Helper.createAbsoluteButtonWithRoundness(LeaderSelection.secondaryTable, 2, {
                click_function = Helper.registerGlobalCallback(function ()
                    adjustValue(LeaderSelection.leaderSelectionPoolSize + 1)
                end),
                label = "+",
                position = LeaderSelection.secondaryTable.getPosition() + Vector(1, 1.8, -29),
                width = 400,
                height = 400,
                font_size = 600,
                color = fontColor,
                font_color = { 0, 0, 0, 1 }
            })
        end

        Helper.createAbsoluteButtonWithRoundness(LeaderSelection.secondaryTable, 2, {
            click_function = Helper.registerGlobalCallback(),
            label = I18N("leaderSelectionExclude"),
            position = LeaderSelection.secondaryTable.getPosition() + Vector(0, 1.8, -30),
            width = 0,
            height = 0,
            font_size = 250,
            font_color = fontColor
        })

        local start = function ()
            local availableLeaderCount = #LeaderSelection._getVisibleLeaders()
            local requiredLeaderCount = #LeaderSelection.players
            if availableLeaderCount >= requiredLeaderCount then
                local visibleLeaders = LeaderSelection._prepareVisibleLeaders(hidden)
                LeaderSelection._createDynamicLeaderSelection(visibleLeaders)
                Helper.clearButtons(LeaderSelection.secondaryTable)
                LeaderSelection.stage = Stage.STARTED
                TurnControl.start()
            else
                broadcastToAll(I18N("notEnoughLeaderLeft"), "Red")
            end
        end

        if autoStart then
            start()
        else
            Helper.createAbsoluteButtonWithRoundness(LeaderSelection.secondaryTable, 2, {
                click_function = Helper.registerGlobalCallback(start),
                label = I18N("start"),
                position = LeaderSelection.secondaryTable.getPosition() + Vector(0, 1.8, -32),
                width = 2200,
                height = 600,
                font_size = 500,
                color = fontColor,
                font_color = { 0, 0, 0, 1 }
            })
        end
    elseif LeaderSelection.stage == Stage.STARTED then
        local visibleLeaders = LeaderSelection._getVisibleLeaders()
        LeaderSelection._createDynamicLeaderSelection(visibleLeaders)
        Helper.clearButtons(LeaderSelection.secondaryTable)

        Helper.onceFramesPassed(1).doAfter(function ()
            for i, color in ipairs(LeaderSelection.players) do
                local leaderCard = PlayBoard.findLeaderCard(color)
                if leaderCard then
                    LeaderSelection._setOnlyVisibleFrom(leaderCard, color)
                end
            end
        end)
    else
        error("Unexpected stage: " .. tostring(LeaderSelection.stage))
    end

    Helper.registerEventListener("playerTurn", function (phase, color)
        if phase == 'leaderSelection' then

            if random then
                if PlayBoard.isHuman(color) then
                    local leaders = LeaderSelection.getSelectableLeaders()
                    local leader = Helper.pickAny(leaders)
                    LeaderSelection.claimLeader(color, leader)
                else
                    Hagal.pickAnyCompatibleLeader(color)
                end
            elseif PlayBoard.isRival(color) and Hagal.getRivalCount() == 1 then
                Hagal.pickAnyCompatibleLeader(color)
            end

            if hidden then
                local remainingLeaders = {}
                for leader, selected in pairs(LeaderSelection.dynamicLeaderSelection) do
                    if not selected then
                        LeaderSelection._setOnlyVisibleFrom(leader, color)
                        table.insert(remainingLeaders, leader)
                    end
                end
                Helper.shuffle(remainingLeaders)
                LeaderSelection._layoutLeaders(0, #remainingLeaders, function (i, position)
                    remainingLeaders[i].setPosition(position)
                end)
            end
        end
    end)

    Helper.registerEventListener("phaseEnd", function (phase)
        if phase == 'leaderSelection' then
            for leader, selected in pairs(LeaderSelection.dynamicLeaderSelection) do
                if selected then
                    leader.setInvisibleTo({})
                else
                    LeaderSelection._destructLeader(leader)
                end
            end
            LeaderSelection.stage = Stage.DONE
        end
    end)
end

---@param object Object
---@param color PlayerColor
function LeaderSelection._setOnlyVisibleFrom(object, color)
    local excludedColors = {}
    for _, otherColor in ipairs(TurnControl.getPlayers()) do
        if otherColor ~= color then
            table.insert(excludedColors, otherColor)
        end
    end
    object.setInvisibleTo(excludedColors)
end

---@return Card[]
function LeaderSelection._getVisibleLeaders()
    local leaders = {}
    for _, object in ipairs(LeaderSelection.deckZone.getObjects()) do
        if object.hasTag("Leader") then
            if not object.is_face_down then
                table.insert(leaders, object)
            end
        end
    end
    return leaders
end

---@param hidden boolean
---@return Card[]
function LeaderSelection._prepareVisibleLeaders(hidden)
    local leaders = {}
    for _, object in ipairs(LeaderSelection.deckZone.getObjects()) do
        if object.hasTag("Leader") then
            if object.is_face_down then
                LeaderSelection._destructLeader(object)
            else
                table.insert(leaders, object)
                if hidden then
                    object.setInvisibleTo(TurnControl.getPlayers())
                end
            end
        end
    end
    return leaders
end

---@param leaders Card[]
function LeaderSelection._createDynamicLeaderSelection(leaders)
    Helper.shuffle(leaders)

    for i, leader in ipairs(leaders) do
        if i <= LeaderSelection.leaderSelectionPoolSize then
            LeaderSelection.dynamicLeaderSelection[leader] = false
            local position = leader.getPosition()
            Helper.createAbsoluteButtonWithRoundness(leader, 1, {
                click_function = Helper.registerGlobalCallback(function (_, color, _)
                    if color == TurnControl.getCurrentPlayer() then
                        LeaderSelection.claimLeader(color, leader)
                    end
                end),
                position = Vector(position.x, 1.9, position.z),
                width = 600,
                height = 900,
                color = Helper.AREA_BUTTON_COLOR,
                hover_color = { 0.7, 0.7, 0.7, 0.7 },
                press_color = { 0.5, 1, 0.5, 0.4 },
                font_color = { 1, 1, 1, 100 },
                tooltip = I18N("claimLeader", { leader = I18N(Helper.getID(leader)) })
            })
        else
            LeaderSelection._destructLeader(leader)
        end
    end
end

---@return Card[]
function LeaderSelection.getSelectableLeaders()
    local selectableLeaders = {}
    for leader, selected in pairs(LeaderSelection.dynamicLeaderSelection) do
        if not selected then
            table.insert(selectableLeaders, leader)
        end
    end
    return selectableLeaders
end

---@param color PlayerColor
---@param leader Card
function LeaderSelection.claimLeader(color, leader)
    assert(leader)
    local continuation = PlayBoard.setLeader(color, leader)
    if continuation then
        Helper.clearButtons(leader)
        LeaderSelection.dynamicLeaderSelection[leader] = true
        continuation.doAfter(TurnControl.endOfTurn)
    else
        Dialog.broadcastToColor(I18N("incompatibleLeaderForRival", { leader = I18N(Helper.getID(leader)) }), color, "Purple")
    end
end

---@param leader Card
function LeaderSelection._destructLeader(leader)
    leader.destruct()
end

return LeaderSelection
