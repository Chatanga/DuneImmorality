local Helper = require("utils.Helper")
local Park = require("utils.Park")

local Utils = Helper.lazyRequire("Utils")
local Playboard = Helper.lazyRequire("Playboard")
local InfluenceTrack = Helper.lazyRequire("InfluenceTrack")
local Combat = Helper.lazyRequire("Combat")
local TleilaxuResearch = Helper.lazyRequire("TleilaxuResearch")
local Intrigue = Helper.lazyRequire("Intrigue")
local Reserve = Helper.lazyRequire("Reserve")
local MainBoard = Helper.lazyRequire("MainBoard")
local TechMarket = Helper.lazyRequire("TechMarket")

--[[

    Playboard.setLeader -> wrapping Action

    Action.sendAgent(spaceName) => query (play + discard) & flush imperiumCards + intrigueCards

    Action.setContext((phase, color (=> leader),) context) -- on clic action cascade
            context = space(name) | imperium_card(name) (< signet) | intrigue_card(name) | leader_ability | influence_track_bonus(faction, level) | commercial_track_bonus(level) | research_track_bonus | tleilaxu_track_bonus | imperium_card_bonus(card) | tech_tile_bonus(tech) | tech_tile_effect(tech) | conflict_reward(conflict, position) | flag_control(space)

    -- On oublie les actions génériques, trop fragiles.
    -- On mantient la coalescence dans Resource et on ne la gère pas dans Action.

    -- Changer la couleur des troupes déployables.

    (color <=> leader)
    log:
            [Round]
            <leader>
                Tech (Moteur Holtzman) > +1 carte
            [Agent / révélation]
            <leader>
                    Intrigue (Méditation Bindu) > +1 carte
                    Tech (Drone d'entraînement)
                    -1 carte (Dague)
                    +1 troupe
                    Carte (Expérimentation)
                    Agent (Bassin impérial) > +2 épices
                    Research > +1 spécimen

]]--

local Action = {
    executionQueue = {}
}

---
function Action.onLoad(_)
    startLuaCoroutine(Global, "Actions_execute")
end

---
function Action.apply()
    for _, action in ipairs(Action.transaction) do
        table.insert(Action.executionQueue, action)
    end
end

---
function Actions_execute()
    while true do
        while #Action.executionQueue > 0 do
            local action = table.remove(Action.executionQueue, 1)
            action.run()
        end
        Action.pause(0.5)
    end
end

---
function Action.pause(durationInSeconds)
    local t0 = Time.time
    while Time.time - t0 < durationInSeconds do
        coroutine.yield(0)
    end
end

-- Phases ------------------------------------------------------------------------------------------------

---
function Action.roundStart()
end

---
function Action.playerTurn(color)
end

---
function Action.combat()
end

---
function Action.fightTurn(color)
end

---
function Action.combatOutcome(winner)
end

---
function Action.exploitationTurn(color)
end

---
function Action.makersAndRecall()
end

---
function Action.endgame()
end

-- Action ------------------------------------------------------------------------------------------------

---
function Action.sendAgent(spaceName, cardContext, intrigueContext)
end

---
function Action.reveal()
end

---
function Action.takeMentat(color)
    local mentat = MainBoard.getMentat()
    if mentat then
        Park.putObject(mentat, Playboard.getAgentPark(color))
        return true
    else
        return false
    end
end

---
function Action.recruitSwordmaster(color)
    return Playboard.recruitSwordmaster(color)
end

---
function Action.takeHighCouncilSeat(color)
    local destination = MainBoard.getHighCouncilSeatPosition(color)
    local token = Playboard.getCouncilToken(color)
    token.setPositionSmooth(destination, false, false)
    token.interactable = false
end

---
function Action.resource(color, resourceName, amount)
    Utils.assertIsPlayerColor(color)
    Utils.assertIsResourceName(resourceName)
    Utils.assertIsInteger(amount)

    local resource = Playboard.getResource(color, resourceName)
    if resource:get() >= -amount then
        resource:change(amount)
        return true
    else
        return false
    end
end

---
function Action.drawImperiumCards(color, amount)
    Utils.assertIsPlayerColor(color)
    Playboard.playboards[color]:drawCards(amount)
    return true
end

---
function Action.influence(color, faction, amount)
    return InfluenceTrack.change(color, faction, amount)
end

---
function Action.gainCommercialMoves(color, count)
    -- TODO
end

---
function Action.gainPersuasion(color, amount)
    -- TODO
end

---
function Action.troops(color, from, to, amount)
    Utils.assertIsPlayerColor(color)
    Utils.assertIsTroopLocation(from)
    Utils.assertIsTroopLocation(to)
    Utils.assertIsInteger(amount)
    return Park.transfert(amount, Action.getPark(color, from), Action.getPark(color, to))
end

---
function Action.getPark(color, parkName)
    if parkName == "supply" then
        return Playboard.getSupplyPark(color)
    elseif parkName == "garrison" then
        return Combat.getGarrisonPark(color)
    elseif parkName == "combat" then
        return nil
    elseif parkName == "negotiation" then
        return TechMarket.getNegotiationPark(color)
    elseif parkName == "tanks" then
        return TleilaxuResearch.getTankPark(color)
    else
        assert(false, "Unknow park name: " .. tostring(parkName))
    end
end

---
function Action.gainVictoryPoint(name)
    local victoryPointArea = {
        base = {
            theSpicemustFlowBag = "43c7b5",
            guildAmbassadorBag = "4bdbd5",
            sayyadinaBag = "4575f3",
            opulenceBag = "67fbba",
            theSleeperMustAwaken = "946ca1",
            stagedIncident = "bee42f",
            endgameCardBag = "cfe0cb",
            endgameTechBag = "1d3e4f",
            combatVictoryPointBag = "d9a457"
        },
        ix = {
            detonationDevicesBag = "7b3fa2",
            ixianEngineerBag = "3371d8",
            flagship = "366237",
            spySatellites = "73a68f",
            choamShares = "c530e6"
        },
        immortality = {
            scientificBreakthrough = "d22031",
            beneTleilaxBag = "082e07",
            forHumanityBag = "71c0c8"
        }
    }
end

---
function Action.loseVictoryPoint(name)
end

---
function Action.voiceForbid(space)
end

---
function Action.acquireImperiumCard(name)
end

---
function Action.acquireFoldspaceCard(color)
    Reserve.acquireFoldspace(Reserve.foldspace, color)
end

---
function Action.imperiumCardEffect(name)
end

---
function Action.intrigueCardEffect(name)
end

---
function Action.leaderPassiveEffect(name)
end

---
function Action.giveInstructions(message)
end

---
function Action.claimLeader(name)
end

---
function Action.advanceFreighter(positiveAmount)
end

---
function Action.recallFreighter()
end

---
function Action.dreadnought(from, to)
end

---
function Action.flagControl(space)
end

---
function Action.acquireTech(name, spiceCost, negotiatorCost, solariCost)
end

---
function Action.destroyTech(name)
end

---
function Action.techEffect(name)
end

---
function Action.recallSnooper(faction)
end

---
function Action.acquireTleilaxuCard(name)
end

---
function Action.acquireReclaimedForcesCard(option)
end

---
function Action.research()
    -- pending generic
end

---
function Action.researchUp()
end

---
function Action.researchDown()
end

---
function Action.beetle(positiveAmount)
end

---
function Action.atomics()
end

---
function Action.drawIntrigues(color, amount)
    Utils.assertIsPlayerColor(color)
    Utils.assertIsInteger(amount)

    local realAmount = amount
    if Playboard.is(color, "hasimirFenring") then
        realAmount = realAmount + 1
    end
    return Intrigue.drawIntrigue(color, realAmount)
end

---
function Action.stealIntrigue(color, otherColor, amount)
    Utils.assertIsPlayerColor(color)
    Utils.assertIsPlayerColor(otherColor)
    Utils.assertIsInteger(amount)

    return Intrigue.stealIntrigue(color, otherColor, amount)
end

--[[
function Action.trashImperiumCard(name)
end

function Action.trashIntrigueCard(?)
end
]]--

return Action
