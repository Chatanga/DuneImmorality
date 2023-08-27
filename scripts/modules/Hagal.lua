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

-- Enlighting clarifications: https://boardgamegeek.com/thread/2578561/summarizing-automa-2p-and-1p-similarities-and-diff
local Hagal = {
    soloDifficulties = {
        novice = "Mercenary",
        veteran = "Sardaukar",
        expert = "Mentat",
        expertPlus = "Kwisatz",
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
}

local Rival = Helper.createClass(Action, {
    rivals = {}
})

---
function Hagal.onLoad(state)
    Helper.append(Hagal, Helper.resolveGUIDs(true, {
        deckZone = "8f49e3",
    }))

    if state.settings and state.settings.numberOfPlayers < 3 then
        Hagal._staticSetUp(state.settings)
    end
end

---
function Hagal.setUp(settings)
    if settings.numberOfPlayers < 3 then
        Hagal._staticSetUp(settings)
    else
        Hagal._tearDown()
    end
end

---
function Hagal._staticSetUp(settings)
    if settings.numberOfPlayers < 3 then
        Hagal.numberOfPlayers = settings.numberOfPlayers
        Hagal.difficulty = settings.difficulty

        Deck.generateHagalDeck(Hagal.deckZone, settings.riseOfIx, settings.immortality, settings.numberOfPlayers).doAfter(function (deck)
            deck.shuffle()
        end)

        if settings.difficulty == "novice" then
            Hagal.swordmasterCountdown = 5
        elseif settings.difficulty == "veteran" then
            Hagal.swordmasterCountdown = 4
        elseif settings.difficulty == "expert" or settings.difficulty == "expertPlus" then
            Hagal.swordmasterCountdown = 3
        end
    end

    Helper.registerEventListener("phaseStart", function (phase)
        if phase == "combat" then
            for color, _ in pairs(Rival.rivals) do
                if Combat.isInCombat(color) then
                    Hagal._setStrengthFromFirstValidCard(color)
                end
            end
        end
    end)
end

---
function Hagal._tearDown()
    -- 5 solari patch.
    getObjectFromGUID("ba730f").destruct()
end

---
function Hagal.newRival(color, leader)
    local rival = Helper.createClassInstance(Rival, {
        leader = leader
    })
    Rival.rivals[color] = rival
    return rival
end

---
function Hagal.activate(phase, color)
    -- A delay before and after the action, to let the human(s) see the progress.
    Wait.time(function ()
        Hagal._lateActivate(phase, color).doAfter(function ()
            Wait.time(TurnControl.endOfTurn, 1)
        end)
    end, 1)
end

---
function Hagal._lateActivate(phase, color)
    local continuation = Helper.createContinuation()

    if phase == "leaderSelection" then
        Hagal.pickAnyCompatibleLeader(color)
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
        continuation.run()
    elseif phase == "endgame" then
        continuation.run()
    else
        assert(false)
    end

    return continuation
end

---
function Hagal._activateFirstValidActionCard(color)
    return Hagal._activateFirstValidCard(color, function (card)
        return HagalCard.activate(color, card)
    end)
end

---
function Hagal._setStrengthFromFirstValidCard(color)
    return Hagal._activateFirstValidCard(color, function (card)
        return HagalCard.setStrength(color, card)
    end)
end

---
function Hagal._activateFirstValidCard(color, action)
    local continuation = Helper.createContinuation()

    local emptySlots = Park.findEmptySlots(PlayBoard.getAgentCardPark(color))
    assert(emptySlots and #emptySlots > 0)

    Hagal._doActivateFirstValidCard(color, action, 0, continuation)

    return continuation
end

---
function Hagal._doActivateFirstValidCard(color, action, n, continuation)
    local emptySlots = Park.findEmptySlots(PlayBoard.getAgentCardPark(color))
    assert(emptySlots and #emptySlots > 0)

    assert(n < 10, "Something is not right!")

    local success = Helper.moveCardFromZone(Hagal.deckZone, emptySlots[2] + Vector(0, 1 + 0.4 * n, 0), Vector(0, 180, 0))
    if success then
        success.doAfter(function (card)
            log(card.getDescription())
            if card.getDescription() == "reshuffle" then
                Hagal._reshuffleDeck(color, action, n, continuation)
            elseif action(card) then
                continuation.run(card)
            else
                Hagal._doActivateFirstValidCard(color, action, n + 1, continuation)
            end
        end)
    else
        Hagal._reshuffleDeck(color, action, n, continuation)
    end
end

---
function Hagal._reshuffleDeck(color, action, n, continuation)
    log("Reshuffling Hagal deck.")
    for _, object in ipairs(getObjects()) do
        if object.hasTag("Hagal") and (object.type == "Deck" or object.type == "Card") then
            if not object.is_face_down then
                object.flip()
            end
            object.setPosition(Hagal.deckZone.getPosition())
        end
    end
    Wait.time(function ()
        local deck = Helper.getDeck(Hagal.deckZone)
        deck.shuffle()
        Helper.onceShuffled(deck).doAfter(function ()
            Hagal._doActivateFirstValidCard(color, action, n + 1, continuation)
        end)
    end, 2)
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
function Hagal.isLeaderCompatible(leader)
    for _, compatibleLeader in ipairs(Helper.getKeys(Hagal.compatibleLeaders)) do
        if compatibleLeader == leader.getDescription() then
            return true
        end
    end
    return false
end

---
function Hagal.pickAnyCompatibleLeader(color)
    local leaderOrPseudoLeader
    if Hagal.getRivalCount() == 1 then
        leaderOrPseudoLeader = Helper.getDeck(Hagal.deckZone)
        assert(leaderOrPseudoLeader, "Missing Hagal deck!")
    else
        local leaders = {}
        for _, leader in ipairs(LeaderSelection.getSelectableLeaders()) do
            if Hagal.isLeaderCompatible(leader) then
                table.insert(leaders , leader)
            end
        end
        assert(#leaders > 0, "No leader left for Hagal!")
        Helper.shuffle(leaders)
        leaderOrPseudoLeader = leaders[1]
    end
    LeaderSelection.claimLeader(color, leaderOrPseudoLeader)
end

---
function Rival.setUp(color, settings)
    if Hagal.numberOfPlayers == 1 then
        Action.resource(color, "water", 1)
        if settings.difficulty ~= "novice" then
            Action.troops(color, "supply", "garrison", 3)
            Action.drawIntrigues(color, 1)
        end
    end
end

return Hagal
