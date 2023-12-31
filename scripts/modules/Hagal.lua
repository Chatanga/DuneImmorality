local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")
local I18N = require("utils.I18N")

local Deck = Module.lazyRequire("Deck")
local TurnControl = Module.lazyRequire("TurnControl")
local LeaderSelection = Module.lazyRequire("LeaderSelection")
local PlayBoard = Module.lazyRequire("PlayBoard")
local Action = Module.lazyRequire("Action")
local HagalCard = Module.lazyRequire("HagalCard")
local Combat = Module.lazyRequire("Combat")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")
local ShipmentTrack = Module.lazyRequire("ShipmentTrack")
local TechMarket = Module.lazyRequire("TechMarket")
local ConflictCard = Module.lazyRequire("ConflictCard")
local MainBoard = Module.lazyRequire("MainBoard")
local Intrigue = Module.lazyRequire("Intrigue")
local Types = Module.lazyRequire("Types")

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

local Rival = Helper.createClass(Action, {
    rivals = {}
})

---
function Hagal.onLoad(state)
    Helper.append(Hagal, Helper.resolveGUIDs(true, {
        deckZone = "8f49e3",
        mentatSpaceCostPatch = "ba730f",
    }))

    if state.settings and state.settings.numberOfPlayers < 3 then
        Hagal._staticSetUp(state.settings)
    end
end

---
function Hagal.getDifficulties()
    return Hagal.difficulties
end

---
function Hagal.setUp(settings)
    if settings.numberOfPlayers < 3 then
        Hagal._staticSetUp(settings)

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
function Hagal._staticSetUp(settings)
    Hagal.numberOfPlayers = settings.numberOfPlayers
    Hagal.difficulty = settings.difficulty
    Hagal.riseOfIx = settings.riseOfIx

    Deck.generateHagalDeck(Hagal.deckZone, settings.riseOfIx, settings.immortality, settings.numberOfPlayers).doAfter(function (deck)
        Helper.shuffleDeck(deck)
    end)

    Hagal.selectedDifficulty = settings.difficulty

    Helper.registerEventListener("phaseStart", function (phase)
        if phase == "combat" then
            for color, _ in pairs(Rival.rivals) do
                if Combat.isInCombat(color) then
                    Hagal._setStrengthFromFirstValidCard(color)
                end
            end
        elseif phase == "recall" then
            if Hagal.getRivalCount() == 2 then
                local turn = TurnControl.getCurrentRound()
                local arrivalTurn = Hagal.difficulties[Hagal.selectedDifficulty].swordmasterArrivalTurn
                if turn + 1 == arrivalTurn then
                    for color, rival in pairs(Rival.rivals) do
                        rival.recruitSwordmaster(color)
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
function Hagal.getMentatSpaceCost()
    if Hagal.getRivalCount() == 2 and Helper.isElementOf(Hagal.selectedDifficulty, {"veteran", "expert"}) then
        return 5
    else
        return 2
    end
end

---
function Hagal.newRival(color, leader)
    local rival = Helper.createClassInstance(Rival, {
        leader = leader or Hagal,
    })
    rival.name = rival.leader.name
    assert((Hagal.getRivalCount() == 1) == (leader == nil))
    if not leader then
        rival.recruitSwordmaster(color)
    end
    Rival.rivals[color] = rival
    return rival
end

---
function Hagal.activate(phase, color)
    Helper.dumpFunction("Hagal.activate", phase, color)
    -- A delay before and after the action, to let the human(s) see the progress.
    Helper.onceTimeElapsed(1).doAfter(function ()
        Hagal._lateActivate(phase, color).doAfter(function ()
            if Hagal.getRivalCount() == 1 then
                Helper.onceTimeElapsed(1).doAfter(TurnControl.endOfTurn)
            else
                PlayBoard.createEndOfTurnButton(color)
            end
        end)
    end)
end

---
function Hagal._lateActivate(phase, color)
    local continuation = Helper.createContinuation("Hagal._lateActivate")

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
        if Hagal.getRivalCount() == 2 then
            Hagal._collectReward(color).doAfter(continuation.run)
        else
            Hagal._cleanUpConflict(color).doAfter(continuation.run)
        end
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
    local continuation = Helper.createContinuation("Hagal._collectReward")
    Helper.onceFramesPassed(1).doAfter(function ()
        local conflictName = Combat.getCurrentConflictName()
        local rank = Combat.getRank(color).value
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
    --log("Reshuffling Hagal deck.")
    for _, object in ipairs(getObjects()) do
        if object.hasTag("Hagal") and (object.type == "Deck" or object.type == "Card") then
            if not object.is_face_down then
                object.flip()
            end
            object.setPosition(Hagal.deckZone.getPosition())
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
function Hagal.isLeaderCompatible(leader)
    assert(leader)
    for _, compatibleLeader in ipairs(Helper.getKeys(Hagal.compatibleLeaders)) do
        if compatibleLeader == Helper.getID(leader) then
            return true
        end
    end
    return false
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
function Rival.prepare(color, settings)
    if Hagal.numberOfPlayers == 1 then
        Action.resources(color, "water", 1)
        if settings.difficulty ~= "novice" then
            Action.troops(color, "supply", "garrison", 3)
            Action.drawIntrigues(color, 1)
        end
    -- https://boardgamegeek.com/thread/2570879/article/36734124#36734124
    elseif Hagal.numberOfPlayers == 2 then
        Action.resources(color, "water", 1)
        Action.troops(color, "supply", "garrison", 3)
    end
end

---
function Rival.influence(color, faction, amount)
    local finalFaction = faction
    if not finalFaction then
        local factions = { "emperor", "spacingGuild", "beneGesserit", "fremen" }
        Helper.shuffle(factions)
        table.sort(factions, function (f1, f2)
            local i1 = InfluenceTrack.getInfluence(f1, color)
            local i2 = InfluenceTrack.getInfluence(f2, color)
            return i1 < i2
        end)
        finalFaction = factions[1]
    end
    return Action.influence(color, finalFaction, amount)
end

---
function Rival.shipments(color, amount)
    Helper.repeatChainedAction(amount, function ()
        local level = ShipmentTrack.getFreighterLevel(color)
        if level < 2 then
            Rival.advanceFreighter(color, 1)
        else
            Rival.recallFreighter(color)
            Rival.influence(color, nil, 1)
            if PlayBoard.hasTech(color, "troopTransports") then
                Rival.troops(color, "supply", "combat", 3)
            else
                Rival.troops(color, "supply", "garrison", 2)
            end
            Rival.resources(color, "solari", 5)
            for _, otherColor in ipairs(PlayBoard.getPlayBoardColors()) do
                if otherColor ~= color then
                    local otherLeader = PlayBoard.getLeader(otherColor)
                    otherLeader.resources(otherColor, "solari", 1)
                end
            end
        end
        -- FIXME
        return Helper.onceTimeElapsed(0.5)
    end)
    return true
end

---
function Rival.acquireTech(color, stackIndex, discount)

    local finalStackIndex  = stackIndex
    if not finalStackIndex then
        local spiceBudget = PlayBoard.getResource(color, "spice"):get()

        local bestTechIndex
        local bestTech
        for otherStackIndex = 1, 3 do
            local tech = TechMarket.getTopCardDetails(otherStackIndex)
            if tech.hagal and tech.cost <= spiceBudget + discount and (not bestTech or bestTech.cost < tech.cost) then
                bestTechIndex = otherStackIndex
                bestTech = tech
            end
        end

        if bestTech then
            Rival.resources(color, "spice", -bestTech.cost)
            finalStackIndex = bestTechIndex
        else
            return false
        end
    end

    local techDetails = TechMarket.getTopCardDetails(finalStackIndex)
    if Action.acquireTech(color, finalStackIndex, discount) then
        if techDetails.name == "trainingDrones" then
            if PlayBoard.useTech(color, "trainingDrones") then
                Rival.troops(color, "supply", "garrison", 1)
            end
        end
        return true
    else
        return false
    end
end

---
function Rival.choose(color, topic)
    --Helper.dumpFunction("Rival.choose", color, topic)

    local function pickTwoBestFactions()
        local factions = { "emperor", "spacingGuild", "beneGesserit", "fremen" }
        for _ = 1, 2 do
            Helper.shuffle(factions)
            table.sort(factions, function (f1, f2)
                local i1 = InfluenceTrack.getInfluence(f1, color)
                local i2 = InfluenceTrack.getInfluence(f2, color)
                return i1 > i2
            end)
            local faction = factions[1]
            table.remove(factions, 1)

            return Rival.influence(color, faction, 1)
        end
    end

    if topic == "shuttleFleet" then
        pickTwoBestFactions()
        return true
    elseif topic == "machinations" then
        pickTwoBestFactions()
        return true
    else
        return false
    end
end

---
function Rival.resources(color, nature, amount)
    if Hagal.getRivalCount() == 2 then
        if Action.resources(color, nature, amount) then
            local resource = PlayBoard.getResource(color, nature)
            if nature == "spice" then
                if Hagal.riseOfIx then
                    local tech = PlayBoard.getTech(color, "spySatellites")
                    if tech and nature == "spice" and resource:get() >= 3 then
                        MainBoard.trash(tech)
                        Rival.gainVictoryPoint(color, "spySatellites")
                    end
                else
                    if resource:get() >= 7 then
                        resource:change(-7)
                        Rival.gainVictoryPoint(color, "spice")
                    end
                end
            elseif nature == "water" then
                if resource:get() >= 3 then
                    resource:change(-3)
                    Rival.gainVictoryPoint(color, "water")
                end
            elseif nature == "solari" then
                if resource:get() >= 7 then
                    resource:change(-7)
                    Rival.gainVictoryPoint(color, "solari")
                end
            end
            return true
        end
    elseif Hagal.getRivalCount() == 1 and nature == "strength"  then
        return Action.resources(color, nature, amount)
    end
    return false
end

---
function Rival.beetle(color, jump)
    Types.assertIsPlayerColor(color)
    Types.assertIsInteger(jump)
    if Hagal.getRivalCount() == 2 then
        return Action.beetle(color, jump)
    else
        return false
    end
end

---
function Rival.drawIntrigues(color, amount)
    if Action.drawIntrigues(color, amount) then
        Helper.onceTimeElapsed(1).doAfter(function ()
            local intrigues = PlayBoard.getIntrigues(color)
            if #intrigues >= 3 then
                for i = 1, 3 do
                    -- Not smooth to avoid being recaptured by the hand zone.
                    intrigues[i].setPosition(Intrigue.discardZone.getPosition() + Vector(0, 1, 0))
                end
                Rival.gainVictoryPoint(color, "intrigue")
            end
        end)
        return true
    else
        return false
    end
end

---
function Rival.troops(color, from, to, amount)
    local finalTo = to
    if to == "garrison" and (Action.checkContext({ troopTransports = true }) or Action.checkContext({ hagalCard = HagalCard.isCombatCard })) then
        finalTo = "combat"
    end
    return Action.troops(color, from, finalTo, amount)
end

---
function Rival.gainVictoryPoint(color, name)
    -- We make an exception for alliance token to make it clear that the rival owns it.
    if Hagal.getRivalCount() == 2 or Helper.endsWith(name, "Alliance") then
        return Action.gainVictoryPoint(color, name)
    else
        return false
    end
end

---
function Rival.signetRing(color)
    -- FIXME Fix Park instead!
    Helper.onceTimeElapsed(0.25).doAfter(function ()
        -- We don't redispatch to the leader in other cases, because rivals ignore their passive abilities.
        local leader = Rival.rivals[color].leader
        return leader.signetRing(color)
    end)
end

return Hagal
