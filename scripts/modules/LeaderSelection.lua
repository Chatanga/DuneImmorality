local Module = require("utils.Module")
local Helper = require("utils.Helper")

local Deck = Module.lazyRequire("Deck")
local TurnControl = Module.lazyRequire("TurnControl")
local PlayBoard = Module.lazyRequire("PlayBoard")
local Hagal = Module.lazyRequire("Hagal")

local LeaderSelection = {
    selectionMethods = {
        random = "Random",
        reversePick = "Reverse pick",
        hiddenPick = "Reverse hidden pick"
    },
    leaderSelectionPoolSize = 6,
    dynamicLeaderSelection = {},
}

---
function LeaderSelection.onLoad()
    Helper.append(LeaderSelection, Helper.resolveGUIDs(true, {
        deckZone = "23f2b5",
        secondaryTable = "662ced",
    }))

    -- We don't event try to save the leader selection state.
end

---
function LeaderSelection.getSelectionMethods()
    return LeaderSelection.selectionMethods
end

---
function LeaderSelection.setUp(settings, opponents)
    Deck.generateLeaderDeck(LeaderSelection.deckZone, settings.riseOfIx, settings.immortality, settings.fanmadeLeaders).doAfter(function (deck)
        local numberOfLeaders = #deck.getObjects()
        local continuation = Helper.createContinuation()
        continuation.count = numberOfLeaders

        LeaderSelection._layoutLeaders(numberOfLeaders, function (_, position)
            deck.takeObject({
                position = position,
                flip = true,
                callback_function = function (card)
                    continuation.count = continuation.count - 1
                    if continuation.count == 0 then
                        Wait.time(continuation.run, 1)
                    end
                end
            })
        end)

        continuation.doAfter(function ()
            if type(settings.leaderSelection) == "table" then
                LeaderSelection._setUpTest(opponents, settings.leaderSelection)
            elseif settings.leaderSelection == "random" then
                LeaderSelection._setUpPicking(opponents, numberOfLeaders, true, false)
            elseif settings.leaderSelection == "reversePick" then
                LeaderSelection._setUpPicking(opponents, numberOfLeaders, false, false)
            elseif settings.leaderSelection == "hiddenPick" then
                LeaderSelection._setUpPicking(opponents, numberOfLeaders, false, true)
            else
                error(settings.leaderSelection)
            end
        end)
    end)
end

---
function LeaderSelection._layoutLeaders(count, callback)
    local w = LeaderSelection.deckZone.getScale().x
    local h = LeaderSelection.deckZone.getScale().z
    local origin = LeaderSelection.deckZone.getPosition() - Vector(w / 2 - 6, 0, h / 2 - 10)
    for i = 0, count - 1 do
        local x = (i % 6) * 5
        local y = math.floor(i / 6) * 4
        callback(i + 1, origin + Vector(x, 1, y))
    end
end

---
function LeaderSelection._setUpTest(opponents, leaderNames)
    local leaders = {}
    for _, object in ipairs(LeaderSelection.deckZone.getObjects()) do
        if object.hasTag("Leader") then
            leaders[Helper.getID(object)] = object
        end
    end

    for color, _ in pairs(opponents) do
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

    TurnControl.start(true)
end

---
function LeaderSelection._setUpPicking(opponents, numberOfLeaders, random, hidden)
    local fontColor = Color(223/255, 151/255, 48/255)

    if hidden then
        Helper.createAbsoluteButtonWithRoundness(LeaderSelection.secondaryTable, 2, false, {
            click_function = Helper.registerGlobalCallback(),
            label = "Adjust the number of leaders who will be randomly\nselected for the players to choose among:",
            position = LeaderSelection.secondaryTable.getPosition() + Vector(0, 1.8, -28),
            width = 0,
            height = 0,
            font_size = 250,
            font_color = fontColor
        })

        local adjustValue = function (value)
            local minValue = #Helper.getKeys(opponents)
            local maxValue = numberOfLeaders
            LeaderSelection.leaderSelectionPoolSize = math.max(minValue, math.min(maxValue, value))
            LeaderSelection.secondaryTable.editButton({ index = 2, label = tostring(LeaderSelection.leaderSelectionPoolSize) })
        end

        -- TTS input widgets are shitty. Let's forget them.

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
        label = "You can flip out (or delete) any leader you want to exclude.\nOnce satisfied, hit the 'Start' button.",
        position = LeaderSelection.secondaryTable.getPosition() + Vector(0, 1.8, -30),
        width = 0,
        height = 0,
        font_size = 250,
        font_color = fontColor
    })

    Helper.createAbsoluteButtonWithRoundness(LeaderSelection.secondaryTable, 2, false, {
        click_function = Helper.registerGlobalCallback(function ()
            if #LeaderSelection._getVisibleLeaders() >= #Helper.getKeys(opponents) then
                local visibleLeaders = LeaderSelection._prepareVisibleLeaders(hidden)
                LeaderSelection._createDynamicLeaderSelection(visibleLeaders)
                Helper.clearButtons(LeaderSelection.secondaryTable)
                TurnControl.start(true)
            else
                error("Not enough leaders left!")
            end
        end),
        label = "Start",
        position = LeaderSelection.secondaryTable.getPosition() + Vector(0, 1.8, -32),
        width = 1600,
        height = 600,
        font_size = 500,
        color = fontColor,
        font_color = { 0, 0, 0, 1 }
    })

    if random then
        Helper.registerEventListener("phaseStart", function (phase, _)
            if phase == 'leaderSelection' then
                -- Rivals
                for color, opponent in pairs(opponents) do
                    if opponent == "rival" then
                        --Helper.dumpFunction("Hagal.pickAnyCompatibleLeader", color)
                        Hagal.pickAnyCompatibleLeader(color)
                    end
                end
                -- Then players
                local i = 0
                for color, opponent in pairs(opponents) do
                    --Helper.dump(i, opponent)
                    if opponent ~= "rival" then
                        local leaders = LeaderSelection.getSelectableLeaders()
                        local leader = Helper.pickAny(leaders)
                        --Helper.dumpFunction("LeaderSelection.claimLeader", color, leader)
                        LeaderSelection.claimLeader(color, leader)
                    end
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
                    LeaderSelection.destructLeader(leader)
                end
            end
            LeaderSelection.secondaryTable.destruct()
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
                LeaderSelection.destructLeader(object)
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

function LeaderSelection._createDynamicLeaderSelection(leaders)
    Helper.shuffle(leaders)

    for i, leader in ipairs(leaders) do
        if i <= LeaderSelection.leaderSelectionPoolSize then
            LeaderSelection.dynamicLeaderSelection[leader] = false
            local position = leader.getPosition()
            Helper.createAbsoluteButtonWithRoundness(leader, 1, false, {
                click_function = Helper.registerGlobalCallback(function (_, color, _)
                    if color == TurnControl.getCurrentPlayer() then
                        LeaderSelection.claimLeader(color, leader)
                        Wait.time(TurnControl.endOfTurn, 1)
                    end
                end),
                position = Vector(position.x, 0.9, position.z),
                width = 1100,
                height = 1700, -- FIXME Capped size and weird ratio...
                color = { 0, 0, 0, 0 },
                tooltip = "Claim"
            })
        else
            LeaderSelection.destructLeader(leader)
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
    LeaderSelection.dynamicLeaderSelection[leader] = true
    if PlayBoard.setLeader(color, leader) then
        leader.clearButtons()
        return true
    else
        return false
    end
end

---
function LeaderSelection.destructLeader(leader)
    leader.destruct()
end

return LeaderSelection
