local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")

local Deck = Module.lazyRequire("Deck")
local TurnControl = Module.lazyRequire("TurnControl")
local LeaderSelection = Module.lazyRequire("LeaderSelection")
local PlayBoard = Module.lazyRequire("PlayBoard")
local HagalCard = Module.lazyRequire("HagalCard")
local Combat = Module.lazyRequire("Combat")
local MainBoard = Module.lazyRequire("MainBoard")
local ConflictCard = Module.lazyRequire("ConflictCard")
local Rival = Module.lazyRequire("Rival")

--[[
    Prendre en compte les niveaux de difficultés.
    Vérifier absence gain bonus alliance.
    Attention à  bien marquer les troupes gagnées durant le tour mais pas encore déployées en raison du multi-cartisme !

    automated:
        [] 1P -> Churn
        [] 2P -> Difficulté streamlined Rivals (=> Rival Leader selection reduced to 2)
        [] Brutal Escalation (auto-selected if >= Mentat + 1J)
        [] Expert Deployment (auto-selected if >= Mentat + 1J)
        [] Smart Politics (auto-selected if >= Mentat + 1J)
]]

local Hagal = {
    difficulties = {
        novice = { name = "Mercenary" },
        veteran = { name = "Sardaukar" },
        expert = { name = "Mentat" },
        expertPlus = { name = "Kwisatz" },
    }
}

---
function Hagal.onLoad(state)
    --Helper.dumpFunction("Hagal.onLoad")

    if not state.settings or state.settings.numberOfPlayers < 3 then
        Helper.append(Hagal, Helper.resolveGUIDs(true, {
            deckZone = "8f49e3",
        }))
    end

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
    else
        Hagal._tearDown()
    end
end

---
function Hagal._transientSetUp(settings)
    Hagal.numberOfPlayers = settings.numberOfPlayers
    Hagal.difficulty = settings.difficulty
    Hagal.riseOfIx = settings.riseOfIx

    Hagal.selectedDifficulty = settings.difficulty

    Helper.registerEventListener("phaseStart", function (phase)
        if phase == "combat" then
            for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
                if PlayBoard.isRival(color) and Combat.isInCombat(color) then
                    Hagal._setStrengthFromFirstValidCard(color)
                end
            end
        end
    end)
end

---
function Hagal._tearDown()
    Hagal.deckZone.destruct()
end

---
function Hagal.newRival(name)
    return Rival.newRival(name)
end

---
function Hagal.activate(phase, color)
    --Helper.dumpFunction("Hagal.activate", phase, color)
    -- A delay before and after the action, to let the human(s) see the progress.
    Helper.onceTimeElapsed(1).doAfter(function ()
        Hagal._lateActivate(phase, color).doAfter(function ()
            -- The leader selection already has an automatic end of turn when a leader is picked.
            if phase ~= "leaderSelection" then
                if Hagal.getRivalCount() == 1 and Hagal.automated then
                    Helper.onceTimeElapsed(1).doAfter(Helper.partialApply(TurnControl.endOfTurn, 1))
                else
                    PlayBoard.createEndOfTurnButton(color)
                end
            end
        end)
    end)
end

---
function Hagal._lateActivate(phase, color)
    Helper.dumpFunction("Hagal._lateActivate", phase, color)
    local continuation = Helper.createContinuation("Hagal._lateActivate")

    if phase == "leaderSelection" then
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
        Hagal._collectReward(color).doAfter(continuation.run)
    elseif phase == "endgame" then
        continuation.run()
    else
        error("Unknown phase: " .. phase)
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
    Helper.dumpFunction("Hagal._collectReward", color)
    local continuation = Helper.createContinuation("Hagal._collectReward")
    Helper.onceFramesPassed(1).doAfter(function ()
        local conflictName = Combat.getCurrentConflictName()
        local rank = Combat.getRank(color).value
        local hasSandworms = Combat.hasSandworms(color)
        ConflictCard.collectReward(color, conflictName, rank, hasSandworms)
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
                dreadnoughts[1].setPositionSmooth(bestBannerZone.getPosition())
            end
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
                HagalCard.flushTurnActions(color)
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
    --Helper.dump("Reshuffling Hagal deck.")
    local i = 1
    for _, object in ipairs(getObjects()) do
        if object.hasTag("Hagal") and (object.type == "Deck" or object.type == "Card") then
            if not object.is_face_down then
                object.flip()
            end
            object.setPosition(Hagal.deckZone.getPosition() + Vector(0, i, 0))
            i = i + 1
            -- For some weird reason, the reformed deck is invisible, some part of
            -- it seeming to remembering having been pulled from a hidden deck at
            -- startup...
            object.setInvisibleTo({})
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
function Hagal.pickAnyRivalLeader(color)
    --Helper.dumpFunction("Hagal.pickAnyRivalLeader", color)
    local leaders = {}
    for _, leader in ipairs(LeaderSelection.getSelectableLeaders(true)) do
        table.insert(leaders , leader)
    end
    assert(#leaders > 0, "No rival leaders left!")
    LeaderSelection.claimLeader(color, Helper.pickAny(leaders))
end

return Hagal
