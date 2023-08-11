local Module = require("utils.Module")
local Helper = require("utils.Helper")

local Deck = Module.lazyRequire("Deck")
local TurnControl = Module.lazyRequire("TurnControl")
local Playboard = Module.lazyRequire("Playboard")
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
function LeaderSelection.onLoad(state)
    Helper.append(LeaderSelection, Helper.resolveGUIDs(true, {
        deckZone = getObjectFromGUID("23f2b5"),
        secondaryTable = getObjectFromGUID("662ced"),
    }))
end

---
function LeaderSelection.setUp(ix, immortality, fanMadeLeaders, opponents, selectionMethod)
    Deck.generateLeaderDeck(LeaderSelection.deckZone, ix, immortality, fanMadeLeaders).doAfter(function (deck)
        if selectionMethod == "random" then
            LeaderSelection.setUpPicking(opponents, #deck.getObjects(), true, false)
        elseif selectionMethod == "reversePick" then
            LeaderSelection.setUpPicking(opponents, #deck.getObjects(), false, false)
        elseif selectionMethod == "hiddenPick" then
            LeaderSelection.setUpPicking(opponents, #deck.getObjects(), false, true)
        else
            error(LeaderSelection)
        end

        LeaderSelection.layoutLeaders(#deck.getObjects(), function (_, position)
            deck.takeObject({
                position = position,
                flip = true
            })
        end)

        local w = LeaderSelection.deckZone.getScale().x
        local h = LeaderSelection.deckZone.getScale().z
        local cardCount = #deck.getObjects()
        local origin = LeaderSelection.deckZone.getPosition() - Vector(w / 2 - 6, 0, h / 2 - 10)
        for i = 0, cardCount - 1 do
            local x = (i % 6) * 5
            local y = math.floor(i / 6) * 4
            deck.takeObject({
                position = origin + Vector(x, 1, y),
                flip = true
            })
        end
    end)
end

---
function LeaderSelection.layoutLeaders(count, callback)
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
function LeaderSelection.setUpPicking(opponents, numberOfLeaders, random, hidden)
    local fontColor = Color(223/255, 151/255, 48/255)

    if hidden then
        Helper.createAbsoluteButtonWithRoundness(LeaderSelection.secondaryTable, 2, false, {
            click_function = Helper.createGlobalCallback(function () end),
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
            click_function = Helper.createGlobalCallback(function ()
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
            click_function = Helper.createGlobalCallback(function () end),
            label = tostring(LeaderSelection.leaderSelectionPoolSize),
            position = LeaderSelection.secondaryTable.getPosition() + Vector(0, 1.8, -29),
            width = 0,
            height = 0,
            font_size = 400,
            font_color = fontColor
        })

        Helper.createAbsoluteButtonWithRoundness(LeaderSelection.secondaryTable, 2, false, {
            click_function = Helper.createGlobalCallback(function ()
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
        click_function = Helper.createGlobalCallback(function () end),
        label = "You can flip out (or delete) any leader you want to exclude.\nOnce satisfied, hit the 'Start' button.",
        position = LeaderSelection.secondaryTable.getPosition() + Vector(0, 1.8, -30),
        width = 0,
        height = 0,
        font_size = 250,
        font_color = fontColor
    })

    Helper.createAbsoluteButtonWithRoundness(LeaderSelection.secondaryTable, 2, false, {
        click_function = Helper.createGlobalCallback(function ()
            if #LeaderSelection.getVisibleLeaders() >= #Helper.getKeys(opponents) then
                local visibleLeaders = LeaderSelection.prepareVisibleLeaders(hidden)
                LeaderSelection.createDynamicLeaderSelection(visibleLeaders)
                LeaderSelection.secondaryTable.clearButtons()
                TurnControl.start(true)
            else
                print("Not enough leaders left!")
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
        Helper.registerEventListener("phaseStart", "LeaderSelection", function (phase, _)
            if phase == 'leaderSelection' then
                -- Rivals
                for color, opponent in pairs(opponents) do
                    if opponent == "rival" then
                        Hagal.pickAnyCompatibleLeader(color)
                    end
                end
                -- Then players
                for color, opponent in pairs(opponents) do
                    if opponent ~= "rival" then
                        local leaders = LeaderSelection.getSelectableLeaders()
                        Helper.shuffle(leaders)
                        LeaderSelection.claimLeader(color, leaders[1])
                    end
                end
            end
        end)
    end

    if hidden then
        Helper.registerEventListener("phaseTurn", "LeaderSelection", function (phase, color)
            if phase == 'leaderSelection' then
                local remainingLeaders = {}
                for leader, selected in pairs(LeaderSelection.dynamicLeaderSelection) do
                    if not selected then
                        LeaderSelection.setOnlyVisibleFrom(leader, color)
                        table.insert(remainingLeaders, leader)
                    end
                end
                Helper.shuffle(remainingLeaders)
                LeaderSelection.layoutLeaders(#remainingLeaders, function (i, position)
                    remainingLeaders[i].setPosition(position)
                end)
            end
        end)
    end

    Helper.registerEventListener("phaseEnd", "LeaderSelection", function (phase)
        if phase == 'leaderSelection' then
            for leader, selected in pairs(LeaderSelection.dynamicLeaderSelection) do
                if selected then
                    leader.setInvisibleTo({})
                else
                    leader.destruct()
                end
            end
            LeaderSelection.secondaryTable.destruct()
        end
    end)
end

function LeaderSelection.setOnlyVisibleFrom(object, color)
    local excludedColors = {}
    for _, otherColor in ipairs(TurnControl.getPlayers()) do
        if otherColor ~= color then
            table.insert(excludedColors, otherColor)
        end
    end
    object.setInvisibleTo(excludedColors)
end

function LeaderSelection.getVisibleLeaders()
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

function LeaderSelection.prepareVisibleLeaders(hidden)
    local leaders = {}
    for _, object in ipairs(LeaderSelection.deckZone.getObjects()) do
        if object.hasTag("Leader") then
            if object.is_face_down then
                object.destruct()
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

function LeaderSelection.createDynamicLeaderSelection(leaders)
    Helper.shuffle(leaders)

    for i, leader in ipairs(leaders) do
        if i <= LeaderSelection.leaderSelectionPoolSize then
            LeaderSelection.dynamicLeaderSelection[leader] = false
            local position = leader.getPosition()
            Helper.createAbsoluteButtonWithRoundness(leader, 1, false, {
                click_function = Helper.createGlobalCallback(function (_, color, _)
                    if color == TurnControl.getCurrentPlayer() then
                        LeaderSelection.claimLeader(color, leader)
                        Wait.time(TurnControl.endOfTurn, 1)
                    end
                end),
                position = Vector(position.x, 0.9, position.z),
                width = 1100,
                height = 1700, -- FIXME Cadded size and weird ratio...
                color = { 0, 0, 0, 0 },
                tooltip = "Claim"
            })
        else
            leader.destruct()
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
    if Playboard.setLeader(color, leader) then
        leader.clearButtons()
        return true
    else
        return false
    end
end

return LeaderSelection
