local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")

local Deck = Module.lazyRequire("Deck")
local TurnControl = Module.lazyRequire("TurnControl")
local LeaderSelection = Module.lazyRequire("LeaderSelection")
local PlayBoard = Module.lazyRequire("PlayBoard")
local Action = Module.lazyRequire("Action")
local HagalCard = Module.lazyRequire("HagalCard")
local Combat = Module.lazyRequire("Combat")
local ConflictCard = Module.lazyRequire("ConflictCard")
local MainBoard = Module.lazyRequire("MainBoard")
local Rival = Module.lazyRequire("Rival")

-- Enlighting clarifications: https://boardgamegeek.com/thread/2578561/summarizing-automa-2p-and-1p-similarities-and-diff
local Hagal = Helper.createClass(Action, {
    name = "houseHagal",
    difficulties = {
        novice = { name = "Mercenary", swordmasterArrivalTurn = 5 },
        veteran = { name = "Sardaukar", swordmasterArrivalTurn = 4 },
        expert = { name = "Mentat", swordmasterArrivalTurn = 3 },
        expertPlus = { name = "Kwisatz", swordmasterArrivalTurn = 3 },
    },
    compatibleLeaders = {
        vladimirHarkonnen = 1,
        glossuRabban = 1,
        ilbanRichese = 1,
        letoAtreides = 1,
        arianaThorvald = 1,
        memnonThorvald = 1,
        rhomburVernius = 1,
        hundroMoritani = 1,
    }
})

---
function Hagal.onLoad(state)
    Helper.append(Hagal, Helper.resolveGUIDs(true, {
        deckZone = "8f49e3",
        mentatSpaceCostPatch = "ba730f",
    }))

    if state.settings and state.settings.numberOfPlayers < 3 then
        Hagal._transientSetUp(state.settings)
    end
end

---
function Hagal.getDifficulties()
    return Hagal.difficulties
end

---
function Hagal.setUp(settings)
    if settings.numberOfPlayers < 3 then
        Deck.generateHagalDeck(Hagal.deckZone, settings.riseOfIx, settings.immortality, settings.numberOfPlayers).doAfter(function (deck)
            Helper.shuffleDeck(deck)
        end)
        Hagal._transientSetUp(settings)

        if Hagal.getRivalCount() == 1 then
            Hagal.mentatSpaceCostPatch.destruct()
        elseif  Hagal.getRivalCount() == 2 then
            if Hagal.getMentatSpaceCost() == 5 then
                Hagal.mentatSpaceCostPatch.setLock(true)
                Hagal.mentatSpaceCostPatch.setPosition(Vector(-3.98, 0.57, 3.43))
            else
                Hagal.mentatSpaceCostPatch.destruct()
            end
        end
    else
        Hagal._tearDown()
    end
end

---
function Hagal.getMentatSpaceCost()
    if Hagal.getRivalCount() == 2 and Helper.isElementOf(Hagal.selectedDifficulty, {"veteran", "expert"}) then
        return 5
    else
        return 2
    end
end

---
function Hagal._transientSetUp(settings)
    Hagal.numberOfPlayers = settings.numberOfPlayers
    Hagal.difficulty = settings.difficulty
    Hagal.riseOfIx = settings.riseOfIx

    Hagal.selectedDifficulty = Hagal.numberOfPlayers == 1 and settings.difficulty or nil

    Helper.registerEventListener("phaseStart", function (phase)
        if phase == "combat" then
            for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
                if PlayBoard.isRival(color) and Combat.isInCombat(color) then
                    Hagal._setStrengthFromFirstValidCard(color)
                end
            end
        elseif phase == "recall" then
            if Hagal.getRivalCount() == 2 then
                local turn = TurnControl.getCurrentRound()
                local arrivalTurn = Hagal.difficulties[Hagal.selectedDifficulty].swordmasterArrivalTurn
                if turn + 1 == arrivalTurn then
                    for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
                        if PlayBoard.isRival(color) and Combat.isInCombat(color) then
                            local leader = PlayBoard.getLeader(color)
                            leader.recruitSwordmaster(color)
                        end
                    end
                end
            end
        end
    end)
end

---
function Hagal._tearDown()
    Hagal.mentatSpaceCostPatch.destruct()
    Hagal.deckZone.destruct()
end

---
function Hagal.activate(phase, color)
    -- A delay before and after the action, to let the human(s) see the progress.
    Helper.onceTimeElapsed(1).doAfter(function ()
        Hagal._lateActivate(phase, color).doAfter(function ()
            -- The leader selection already has an automatic end of turn when a leader is picked.
            if phase ~= "leaderSelection" then
                if Hagal.getRivalCount() == 1 then
                    Helper.onceTimeElapsed(1).doAfter(TurnControl.endOfTurn)
                else
                    PlayBoard.createEndOfTurnButton(color)
                end
            end
        end)
    end)
end

---
function Hagal._lateActivate(phase, color)
    local continuation = Helper.createContinuation("Hagal._lateActivate")

    if phase == "leaderSelection" then
        -- TODO To be confirmed.
        --Hagal.pickAnyCompatibleLeader(color)
        continuation.run()
    elseif phase == "gameStart" then
        continuation.run()
    elseif phase == "roundStart" then
        continuation.run()
    elseif phase == "playerTurns" then
        Hagal._activateFirstValidActionCard(color).doAfter(continuation.run)
    elseif phase == "combat" then
        continuation.run()
    elseif phase == "combatEnd" then
        if Hagal.getRivalCount() == 2 then
            Hagal._collectReward(color).doAfter(continuation.run)
        else
            Hagal._cleanUpConflict(color).doAfter(continuation.run)
        end
    elseif phase == "endgame" then
        continuation.run()
    else
        error("Unknown phase: " .. tostring(phase))
    end

    return continuation
end

---
function Hagal._activateFirstValidActionCard(color)
    return Hagal._activateFirstValidCard(color, function (card)
        return HagalCard.activate(color, card, Hagal.riseOfIx)
    end)
end

---
function Hagal._collectReward(color)
    local continuation = Helper.createContinuation("Hagal._collectReward")
    Helper.onceFramesPassed(1).doAfter(function ()
        local rank = Combat.getRank(color).value
        local conflictName = Combat.getTurnConflictName()
        ConflictCard.collectReward(color, conflictName, rank)
        if rank == 1 then
            local leader = PlayBoard.getLeader(color)
            if PlayBoard.hasTech(color, "windtraps") then
                leader.resources(color, "water", 1)
            end

            local dreadnoughts = Combat.getDreadnoughtsInConflict(color)

            if #dreadnoughts > 0 and PlayBoard.hasTech(color, "detonationDevices") then
                Park.putObject(dreadnoughts[1], PlayBoard.getDreadnoughtPark(color))
                table.remove(dreadnoughts, 1)
                leader.gainVictoryPoint(color, "detonationDevices")
            end

            if #dreadnoughts > 0 then
                local bestBannerZone = Hagal._findBestBannerZone(color)
                dreadnoughts[1].setPositionSmooth(bestBannerZone.getPosition())
            end
        end
        continuation.run()
    end)
    return continuation
end

---
function Hagal._findBestBannerZone(color)
    local bestValue
    local bestBannerZone
    -- Already properly ordered (CCW from Imperial Basin).
    for i, bannerZone in ipairs(MainBoard.getBannerZones()) do
        if not MainBoard.getControllingDreadnought(bannerZone) then
            local owner = MainBoard.getControllingPlayer(bannerZone)
            local value
            if not owner then
                value = 10
            elseif owner ~= color then
                value = 20
            else
                value = 0
            end
            value = value + i
            if not bestValue or bestValue < value then
                bestValue = value
                bestBannerZone = bannerZone
            end
        end
    end
    assert(bestBannerZone)
    return bestBannerZone
end

---
function Hagal._cleanUpConflict(color)
    local continuation = Helper.createContinuation("Hagal._cleanUpConflict")
    Helper.onceFramesPassed(1).doAfter(function ()
        local conflictName = Combat.getCurrentConflictName()
        local rank = Combat.getRank(color).value
        if rank == 1 then
            ConflictCard.cleanUpConflict(color, conflictName)
        end
        continuation.run()
    end)
    return continuation
end

---
function Hagal._setStrengthFromFirstValidCard(color)
    return Hagal._activateFirstValidCard(color, function (card)
        return HagalCard.setStrength(color, card)
    end)
end

---
function Hagal._activateFirstValidCard(color, action)
    local continuation = Helper.createContinuation("Hagal._activateFirstValidCard")

    local emptySlots = Park.findEmptySlots(PlayBoard.getAgentCardPark(color))
    assert(emptySlots and #emptySlots > 0)

    Hagal._doActivateFirstValidCard(color, action, 0, continuation)

    return continuation
end

---
function Hagal._doActivateFirstValidCard(color, action, n, continuation)
    local emptySlots = Park.findEmptySlots(PlayBoard.getRevealCardPark(color))
    assert(emptySlots and #emptySlots > 0)
    assert(n < 10, "Something is not right!")
    Helper.moveCardFromZone(Hagal.deckZone, emptySlots[2] + Vector(0, 1 + 0.4 * n, 0), Vector(0, 180, 0)).doAfter(function (card)
        if card then
            if Helper.getID(card) == "reshuffle" then
                Hagal._reshuffleDeck(color, action, n, continuation)
            elseif action(card) then
                continuation.run(card)
            else
                Hagal._doActivateFirstValidCard(color, action, n + 1, continuation)
            end
        else
            Hagal._reshuffleDeck(color, action, n, continuation)
        end
    end)
end

---
function Hagal._reshuffleDeck(color, action, n, continuation)
    local i = 1
    for _, object in ipairs(getObjects()) do
        if object.hasTag("Hagal") and (object.type == "Deck" or object.type == "Card") then
            for _, otherColor in ipairs(PlayBoard.getActivePlayBoardColors()) do
                if (PlayBoard.isInside(otherColor, object)) then
                    if not object.is_face_down then
                        object.flip()
                    end
                    object.setPosition(Hagal.deckZone.getPosition() + Vector(0, i, 0))
                    i = i + 1
                    break
                end
            end
        end
    end
    Helper.onceTimeElapsed(2).doAfter(function ()
        local deck = Helper.getDeck(Hagal.deckZone)
        Helper.shuffleDeck(deck)
        Helper.onceShuffled(deck).doAfter(function ()
            Hagal._doActivateFirstValidCard(color, action, n + 1, continuation)
        end)
    end)
end

---
function Hagal.getRivalCount()
    if Hagal.numberOfPlayers then
        return 3 - Hagal.numberOfPlayers
    else
        return 0
    end
end

---
function Hagal.pickAnyCompatibleLeader(color)
    if Hagal.getRivalCount() == 1 then
        local pseudoLeader = Helper.getDeck(Hagal.deckZone)
        assert(pseudoLeader, "Missing Hagal deck!")
        Hagal.deckZone = PlayBoard.getContent(color).leaderZone
        PlayBoard.setLeader(color, pseudoLeader)
    else
        local leaders = {}
        for _, leader in ipairs(LeaderSelection.getSelectableLeaders()) do
            if Hagal.isLeaderCompatible(leader) then
                table.insert(leaders , leader)
            end
        end
        assert(#leaders > 0, "No leader left for Hagal!")
        LeaderSelection.claimLeader(color, Helper.pickAny(leaders))
    end
end

---
function Hagal.isLeaderCompatible(leader)
    assert(leader)
    for _, compatibleLeader in ipairs(Helper.getKeys(Hagal.compatibleLeaders)) do
        if compatibleLeader == Helper.getID(leader) then
            return true
        end
    end
    return false
end

return Hagal
