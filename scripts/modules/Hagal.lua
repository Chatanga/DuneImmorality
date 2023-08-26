local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")

local Deck = Module.lazyRequire("Deck")
local TurnControl = Module.lazyRequire("TurnControl")
local LeaderSelection = Module.lazyRequire("LeaderSelection")
local PlayBoard = Module.lazyRequire("PlayBoard")
local Action = Module.lazyRequire("Action")
local HagalCard = Module.lazyRequire("HagalCard")

local Hagal = {
    soloDifficulties = {
        novice = "Mercenary",
        veteran = "Sardaukar",
        expertPlus = "Mentat",
        expert = "Kwisatz",
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
    },
}

local Rival = Helper.createClass(Action)

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
    end
end

---
function Hagal._tearDown()
    -- 5 solari patch.
    getObjectFromGUID("ba730f").destruct()
end

---
function Hagal.newRival(leader)
    return Helper.createClassInstance(Rival, {
        leader = leader
    })
end

---
function Hagal.activate(phase, color)
    -- A delay before and after the action, to let the human(s) see the progress.
    Wait.time(function ()
        Hagal._lateActivate(phase, color).doAfter(function ()
            Wait.time(TurnControl.endOfTurn, 2)
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
        Hagal._activateFirstValidCard(color).doAfter(continuation.run)
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
function Hagal._activateFirstValidCard(color)
    local continuation = Helper.createContinuation()

    local emptySlots = Park.findEmptySlots(PlayBoard.getAgentCardPark(color))
    assert(emptySlots and #emptySlots > 0)

    local i = 0
    while true do
        i = i + 1
        assert(i < 10, "Something is not right!")
        local card = Helper.moveCardFromZone(Hagal.deckZone, emptySlots[2] + Vector(0, 0.4 * i, 0), nil, true, true)
        if not card then
            local cards = {}
            for _, object in ipairs(getObjects()) do
                if object.hasTag("Hagal") and (object.type == "Deck" or object.type == "Card") then
                    table.insert(cards, object)
                end
            end
            Helper.forEach(cards, function (_, otherCard)
                otherCard.flip()
                otherCard.setPosition(Hagal.deckZone.getPosition())
            end)
            Wait.time(function ()
                local deckOrCard = Helper.getDeckOrCard(Hagal.deckZone)
                assert(deckOrCard)
                if deckOrCard.type == "Deck" then
                    deckOrCard.shuffle()
                    Helper.onceShuffled(deckOrCard).doAfter(function ()
                        Hagal._activateFirstValidCard(color).doAfter(continuation.run)
                    end)
                else
                    Hagal._activateFirstValidCard(color).doAfter(continuation.run)
                end
            end, 3)
            return continuation
        else
            if HagalCard.activateCard(color, card) then
                Wait.frames(continuation.run, 1)
                return continuation
            end
        end
    end
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

return Hagal
