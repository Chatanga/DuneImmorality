local Module = require("utils.Module")
local Helper = require("utils.Helper")

local Deck = Module.lazyRequire("Deck")
local TurnControl = Module.lazyRequire("TurnControl")
local LeaderSelection = Module.lazyRequire("LeaderSelection")
local Action = Module.lazyRequire("Action")

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
function Hagal.activate(phase, color, playboard)
    Wait.frames(function ()
        -- Let the other event listeners do their job (we are simulating a human player here).
        Hagal._lateActivate(phase, color, playboard)
        Wait.time(TurnControl.endOfTurn, 1)
    end, 1)
end

---
function Hagal._lateActivate(phase, color, playboard)
    if phase == "leaderSelection" then
        Hagal.pickAnyCompatibleLeader(color)
    elseif phase == "gameStart" then
        log("TODO")
    elseif phase == "roundStart" then
        log("TODO")
    elseif phase == "playerTurns" then
        log("TODO")
    elseif phase == "combat" then
        log("TODO")
    elseif phase == "combatEnd" then
        log("TODO")
    elseif phase == "endgame" then
        log("TODO")
    else
        assert(false)
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
