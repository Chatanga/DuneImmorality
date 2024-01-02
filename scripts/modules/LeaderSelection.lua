local Module = require("utils.Module")
local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

local Deck = Module.lazyRequire("Deck")
local TurnControl = Module.lazyRequire("TurnControl")
local PlayBoard = Module.lazyRequire("PlayBoard")
local Hagal = Module.lazyRequire("Hagal")

local LeaderSelection = {
    dynamicLeaderSelection = {},
    leaderSelectionPoolSize = 8,
    turnSequence = {},
}

local Stage = {
    INITIALIZED = 1,
    STARTED = 2,
    DONE = 3,
}

---
function LeaderSelection.getSelectionMethods(numberOfPlayers)
    local selectionMode = {
        random = "Random",
        reversePick = "Reverse pick",
        reverseHiddenPick = "Reverse hidden pick",
    }
    if numberOfPlayers == 4 then
        selectionMode.altHiddenPick = "4·3·1·2 hidden pick"
    end
    return selectionMode
end

---
function LeaderSelection.onLoad(state)
    --Helper.dumpFunction("LeaderSelection.onLoad")

    Helper.append(LeaderSelection, Helper.resolveGUIDs(false, {
        deckZone = "23f2b5",
        secondaryTable = "662ced",
    }))

    if state.settings then
        LeaderSelection._transientSetUp(
            state.settings,
            state.LeaderSelection.players,
            state.LeaderSelection.stage)
    end
end

---
function LeaderSelection.onSave(state)
    --Helper.dumpFunction("LeaderSelection.onSave")
    state.LeaderSelection = {
        players = LeaderSelection.players,
        stage = LeaderSelection.stage,
    }
end

---
function LeaderSelection.setUp(settings, activeOpponents)
    LeaderSelection.leaderSelectionPoolSize = settings.defaultLeaderPoolSize

    Deck.generateLeaderDeck(LeaderSelection.deckZone, settings.useContracts, settings.riseOfIx, settings.immortality, settings.fanmadeLeaders).doAfter(function (deck)
        local numberOfLeaders = deck.getQuantity()
        local continuation = Helper.createContinuation("LeaderSelection.setUp")
        local count = numberOfLeaders

        -- Layout all the leader cards on the secondary table.
        LeaderSelection._layoutLeaders(numberOfLeaders, function (_, position)
            deck.takeObject({
                position = position,
                flip = true,
                callback_function = function (card)
                    count = count - 1
                    if count == 0 then
                        Helper.onceTimeElapsed(1).doAfter(continuation.run)
                    end
                end
            })
        end)

        continuation.doAfter(function ()
            local testSetUp = type(settings.leaderSelection) == "table"

            -- The commander's leaders are always the same. It is not enforced
            -- in a test set up, but it won't work with different leaders.
            if settings.numberOfPlayers == 6 and not testSetUp then
                local leaders = LeaderSelection._grabLeaders()

                PlayBoard.setLeader("Teal", leaders["muadDib"])
                PlayBoard.setLeader("Brown", leaders["shaddamCorrino"])
            end

            -- Give minimal time to the 2 leaders above to exit the zone.
            Helper.onceFramesPassed(1).doAfter(function ()
                local players = TurnControl.toCanonicallyOrderedPlayerList(activeOpponents)
                LeaderSelection._transientSetUp(settings, players, Stage.INITIALIZED)
            end)
        end)
    end)
end

---
function LeaderSelection._transientSetUp(settings, players, stage)
    LeaderSelection.players = players
    LeaderSelection.stage = stage

    if LeaderSelection.stage == Stage.DONE then
        return
    end

    local autoStart = not settings.tweakLeaderSelection
    local testSetUp = type(settings.leaderSelection) == "table"

    if testSetUp then
        LeaderSelection._setUpTest(players, settings.leaderSelection)
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

    Helper.registerEventListener("phaseStart", function (phase, firstPlayer)
        if phase == "leaderSelection" then
            local turnSequence = Helper.shallowCopy(players)
            while turnSequence[1] ~= firstPlayer do
                Helper.cycle(turnSequence)
            end

            if settings.leaderSelection == "reversePick" then
                Helper.reverse(turnSequence)
            elseif settings.leaderSelection == "reverseHiddenPick" then
                Helper.reverse(turnSequence)
            elseif settings.leaderSelection == "altHiddenPick" then
                Helper.reverse(turnSequence)
                if #turnSequence == 4 then
                    Helper.swap(turnSequence, 4, 3)
                else
                    Helper.dump("Skipping 4 <-> 3 for less than 4 players.")
                end
            end

            TurnControl.overridePhaseTurnSequence(turnSequence)
        end
    end)
end

---
function LeaderSelection._layoutLeaders(count, callback)
    local w = LeaderSelection.deckZone.getScale().x
    local h = LeaderSelection.deckZone.getScale().z
    local colCount = 6
    local origin = LeaderSelection.deckZone.getPosition() - Vector((colCount / 2 - 0.5) * 5, 0, h / 2 - 10)
    for i = 0, count - 1 do
        local x = (i % colCount) * 5
        local y = math.floor(i / colCount) * 4
        callback(i + 1, origin + Vector(x, 1, y))
    end
end

--- Return all the leaders laid out on the secondary table.
function LeaderSelection._grabLeaders()
    local leaders = {}
    for _, object in ipairs(LeaderSelection.deckZone.getObjects()) do
        if object.hasTag("Leader") then
            leaders[Helper.getID(object)] = object
        end
    end
    return leaders
end

---
function LeaderSelection._setUpTest(players, leaderNames)
    local leaders = LeaderSelection._grabLeaders()

    for _, color in pairs(players) do
        assert(leaderNames[color], "No leader for color " .. color)
        assert(#LeaderSelection.deckZone.getObjects(), "No leader to select")
        local leaderName = leaderNames[color]
        if leaderName == "hagal" then
            assert(Hagal.getRivalCount() == 1, "Only one rival (house Hagal) expected!")
            Hagal.pickAnyCompatibleLeader(color)
        else
            local leader = leaders[leaderName]
            assert(leader, "Unknown leader " .. leaderName)
            PlayBoard.setLeader(color, leader)
        end
    end

    LeaderSelection.stage = Stage.DONE
    TurnControl.start()
end

---
function LeaderSelection._setUpPicking(autoStart, random, hidden)
    local fontColor = Color(223/255, 151/255, 48/255)

    if LeaderSelection.stage == Stage.INITIALIZED then
        if not random then
            Helper.createAbsoluteButtonWithRoundness(LeaderSelection.secondaryTable, 2, false, {
                click_function = Helper.registerGlobalCallback(),
                label = I18N("leaderSelectionAdjust"),
                position = LeaderSelection.secondaryTable.getPosition() + Vector(0, 1.8, -28),
                width = 0,
                height = 0,
                font_size = 250,
                font_color = fontColor
            })

            local adjustValue = function (value)
                local numberOfLeaders = #LeaderSelection._grabLeaders()
                local minValue = #LeaderSelection.players
                local maxValue = numberOfLeaders
                LeaderSelection.leaderSelectionPoolSize = math.max(minValue, math.min(maxValue, value))
                LeaderSelection.secondaryTable.editButton({ index = 2, label = tostring(LeaderSelection.leaderSelectionPoolSize) })
            end

            Helper.createAbsoluteButtonWithRoundness(LeaderSelection.secondaryTable, 2, false, {
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

            Helper.createAbsoluteButtonWithRoundness(LeaderSelection.secondaryTable, 1, false, {
                click_function = Helper.registerGlobalCallback(),
                label = tostring(LeaderSelection.leaderSelectionPoolSize),
                position = LeaderSelection.secondaryTable.getPosition() + Vector(0, 1.8, -29),
                width = 0,
                height = 0,
                font_size = 400,
                font_color = fontColor
            })

            Helper.createAbsoluteButtonWithRoundness(LeaderSelection.secondaryTable, 2, false, {
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

        Helper.createAbsoluteButtonWithRoundness(LeaderSelection.secondaryTable, 2, false, {
            click_function = Helper.registerGlobalCallback(),
            label = I18N("leaderSelectionExclude"),
            position = LeaderSelection.secondaryTable.getPosition() + Vector(0, 1.8, -30),
            width = 0,
            height = 0,
            font_size = 250,
            font_color = fontColor
        })

        local start = function ()
            if #LeaderSelection._getVisibleLeaders() >= #LeaderSelection.players then
                local visibleLeaders = LeaderSelection._prepareVisibleLeaders(hidden)
                LeaderSelection._createDynamicLeaderSelection(visibleLeaders, hidden)
                Helper.clearButtons(LeaderSelection.secondaryTable)
                LeaderSelection.stage = Stage.STARTED
                TurnControl.start()
            else
                error("Not enough leaders left!")
            end
        end

        if autoStart then
            start()
        else
            Helper.createAbsoluteButtonWithRoundness(LeaderSelection.secondaryTable, 2, false, {
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
        LeaderSelection._createDynamicLeaderSelection(visibleLeaders, hidden)
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

    if random then
        assert(LeaderSelection.stage == Stage.STARTED)
        Helper.registerEventListener("playerTurns", function (phase, color)
            if phase == 'leaderSelection' then
                if PlayBoard.isRival(color) then
                    -- Always auto and random in fact.
                    Hagal.pickAnyCompatibleLeader(color)
                elseif PlayBoard.isHuman(color) then
                    local leaders = LeaderSelection.getSelectableLeaders()
                    local leader = Helper.pickAny(leaders)
                    LeaderSelection.claimLeader(color, leader)
                end
            end
        end)
    end

    if hidden then
        Helper.registerEventListener("playerTurns", function (phase, color)
            if phase == 'leaderSelection' then
                local remainingLeaders = {}
                for leader, selected in pairs(LeaderSelection.dynamicLeaderSelection) do
                    if not selected then
                        LeaderSelection._setOnlyVisibleFrom(leader, color)
                        table.insert(remainingLeaders, leader)
                    end
                end
                Helper.shuffle(remainingLeaders)
                LeaderSelection._layoutLeaders(#remainingLeaders, function (i, position)
                    remainingLeaders[i].setPosition(position)
                end)
            end
        end)
    end

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

        if phase == 'gameStart' then
            for _, object in ipairs(LeaderSelection.deckZone.getObjects()) do
                object.destruct()
            end
        end
    end)
end

function LeaderSelection._setOnlyVisibleFrom(object, color)
    local excludedColors = {}
    for _, otherColor in ipairs(TurnControl.getPlayers()) do
        if otherColor ~= color then
            table.insert(excludedColors, otherColor)
        end
    end
    object.setInvisibleTo(excludedColors)
end

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

function LeaderSelection._createDynamicLeaderSelection(leaders, hidden)
    if hidden then
        Helper.shuffle(leaders)
    end

    for i, leader in ipairs(leaders) do
        if i <= LeaderSelection.leaderSelectionPoolSize then
            LeaderSelection.dynamicLeaderSelection[leader] = false
            local position = leader.getPosition()
            Helper.createAbsoluteButtonWithRoundness(leader, 1, false, {
                click_function = Helper.registerGlobalCallback(function (_, color, _)
                    if color == TurnControl.getCurrentPlayer() then
                        LeaderSelection.claimLeader(color, leader)
                    end
                end),
                position = Vector(position.x, 0.9, position.z),
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

---
function LeaderSelection.getSelectableLeaders()
    local selectableLeaders = {}
    for leader, selected in pairs(LeaderSelection.dynamicLeaderSelection) do
        if not selected then
            table.insert(selectableLeaders, leader)
        end
    end
    return selectableLeaders
end

---
function LeaderSelection.claimLeader(color, leader)
    Helper.clearButtons(leader)
    LeaderSelection.dynamicLeaderSelection[leader] = true
    if PlayBoard.setLeader(color, leader) then
        TurnControl.endOfTurn()
    end
end

---
function LeaderSelection._destructLeader(leader)
    leader.destruct()
end

return LeaderSelection
