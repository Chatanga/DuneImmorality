local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")
local I18N = require("utils.I18N")

local Deck = Module.lazyRequire("Deck")
local TurnControl = Module.lazyRequire("TurnControl")
local LeaderSelection = Module.lazyRequire("LeaderSelection")
local PlayBoard = Module.lazyRequire("PlayBoard")
local HagalCard = Module.lazyRequire("HagalCard")
local Combat = Module.lazyRequire("Combat")
local MainBoard = Module.lazyRequire("MainBoard")
local ConflictCard = Module.lazyRequire("ConflictCard")
local Rival = Module.lazyRequire("Rival")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")
local ImperiumRow = Module.lazyRequire("ImperiumRow")
local Action = Module.lazyRequire("Action")

local Hagal = {}

---
function Hagal.onLoad(state)
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
    return {
        novice = "novice",
        veteran = "veteran",
        expert = "expert",
        expertPlus = "expertPlus",
    }
end

---
function Hagal.setUp(settings)
    if settings.numberOfPlayers < 3 then
        Deck.generateHagalDeck(Hagal.deckZone, settings.riseOfIx, settings.immortality, settings.numberOfPlayers).doAfter(function (deck)
            assert(deck, "No Hagal deck!")
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
    Hagal.riseOfIx = settings.riseOfIx
    Hagal.difficulty = Hagal.numberOfPlayers == 1 and settings.difficulty or nil
    Hagal.autoTurnInSolo = settings.autoTurnInSolo
    Hagal.brutalEscalation = settings.brutalEscalation
    Hagal.expertDeployment = settings.expertDeployment
    Hagal.smartPolitics = settings.smartPolitics

    Helper.registerEventListener("phaseStart", function (phase)
        if phase == "combat" then
            local actions = {}
            for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
                if PlayBoard.isRival(color) and Combat.isInCombat(color) then
                    table.insert(actions, Helper.partialApply(Hagal._setStrengthFromFirstValidCard, color))
                end
            end
            Helper.chainActions(actions)
        end
    end)

    if settings.imperiumRowChurn then
        Helper.registerEventListener("phaseEnd", function (phase)
            if phase == "playerTurns" then
                ImperiumRow.churn()
            end
        end)
    end
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
    -- A delay before and after the action, to let the human(s) see the progress.
    Helper.onceTimeElapsed(1).doAfter(function ()
        Hagal._lateActivate(phase, color).doAfter(function ()
            -- The leader selection already has an automatic end of turn when a leader is picked.
            if phase ~= "leaderSelection" then
                if Hagal.getRivalCount() == 1 or Hagal.autoTurnInSolo then
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
        continuation.cancel()
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
        local conflictName = Combat.getCurrentConflictName()
        local hasSandworms = Combat.hasSandworms(color)
        local postAction = Helper.partialApply(Rival.triggerHagalReaction, color)
        ConflictCard.collectReward(color, conflictName, rank, hasSandworms, postAction).doAfter(function ()
            if rank == 1 then
                local leader = PlayBoard.getLeader(color)
                if PlayBoard.hasTech(color, "windtraps") then
                    leader.resources(color, "water", 1)
                end

                local dreadnoughts = Combat.getDreadnoughtsInConflict(color)

                if #dreadnoughts > 0 and PlayBoard.hasTech(color, "detonationDevices") then
                    Park.putObject(dreadnoughts[1], PlayBoard.getDreadnoughtPark(color))
                    table.remove(dreadnoughts, 1)
                    leader.gainVictoryPoint(color, "detonationDevices", 1)
                end

                if #dreadnoughts > 0 then
                    local bestBannerZone = Hagal._findBestBannerZone(color)
                    dreadnoughts[1].setPositionSmooth(bestBannerZone.getPosition())
                end
            end
            continuation.run()
        end)
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
function Hagal._setStrengthFromFirstValidCard(color)
    local level3Conflict = Combat.getCurrentConflictLevel() == 3

    -- Brutal Escalation
    local n = (level3Conflict and Hagal.brutalEscalation) and 2 or 1

    return Hagal._activateFirstValidCard(color, function (card)
        if HagalCard.setStrength(color, card) then
            n = n - 1
            if n > 0 then
                Action.log(I18N("brutalEscalation"), color)
            end
            return n == 0
        else
            return false
        end
    end)
end

---
function Hagal.getExpertDeploymentLimit(color)
    local level3Conflict = Combat.getCurrentConflictLevel() == 3

    local n
    if not level3Conflict and Hagal.expertDeployment then
        local colorUnitCount = 0
        local otherColorMaxUnitCount = 0
        for otherColor, unitCount in pairs(Combat.getUnitCounts()) do
            if otherColor == color then
                colorUnitCount = unitCount
            else
                otherColorMaxUnitCount = math.max(otherColorMaxUnitCount, unitCount)
            end
        end
        n = math.max(0, 3 + otherColorMaxUnitCount - colorUnitCount)
        Action.log(I18N("expertDeploymentLimit", { limit = n }), color)
    else
        n = 12
    end
    --Helper.dump("level3Conflict:", level3Conflict, "/ expertDeploymentLimit:", n)
    return n
end

---
function Hagal.isSmartPolitics(color, faction)
    if Hagal.smartPolitics then
        local colorRank = 0
        local otherColorMaxRank = 0
        for _, otherColor in ipairs(PlayBoard.getActivePlayBoardColors()) do
            local rank = InfluenceTrack.getInfluence(faction, otherColor, true)
            if otherColor == color then
                colorRank = rank
            else
                otherColorMaxRank = math.max(otherColorMaxRank, rank)
            end
        end
        local leadMargin = colorRank - otherColorMaxRank

        local smart
        if InfluenceTrack.hasAlliance(color, faction) then
            smart = leadMargin < 1
        elseif InfluenceTrack.hasFriendship(color, faction) then
            smart = leadMargin > -2
        else
            smart = true
        end

        --Helper.dump("alliance:", InfluenceTrack.hasAlliance(color, faction), "/ friendship:", InfluenceTrack.hasFriendship(color, faction), "/ lead margin:", leadMargin)

        if not smart then
            Action.log(I18N("smartPolitics"), color)
        end

        return smart
    end

    return true
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
            Helper.onceTimeElapsed(1).doAfter(function ()
                if Helper.getID(card) == "reshuffle" then
                    Hagal._reshuffleDeck(color, action, n, continuation)
                elseif action(card) then
                    Rival.triggerHagalReaction(color).doAfter(function ()
                        HagalCard.flushTurnActions(color)
                        continuation.run(card)
                    end)
                else
                    Rival.triggerHagalReaction(color).doAfter(function ()
                        Hagal._doActivateFirstValidCard(color, action, n + 1, continuation)
                    end)
                end
            end)
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
        assert(deck, "No Hagal deck anymore!")
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
function Hagal.isSwordmasterAvailable()
    return Hagal.difficulty ~= "expertPlus"
end

return Hagal
