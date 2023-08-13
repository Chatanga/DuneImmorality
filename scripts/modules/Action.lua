local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")

local Utils = Module.lazyRequire("Utils")
local Playboard = Module.lazyRequire("Playboard")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")
local Combat = Module.lazyRequire("Combat")
local TleilaxuResearch = Module.lazyRequire("TleilaxuResearch")
local Intrigue = Module.lazyRequire("Intrigue")
local Reserve = Module.lazyRequire("Reserve")
local MainBoard = Module.lazyRequire("MainBoard")
local TechMarket = Module.lazyRequire("TechMarket")
local ImperiumRow = Module.lazyRequire("ImperiumRow")
local CommercialTrack = Module.lazyRequire("CommercialTrack")

--[[
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
]]--

--[[
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
    context = {}
}

---
function Action.onLoad(state)
    Helper.registerEventListener("phaseStart", function (phase, color)
        Action.context = {
            phase = phase
        }
    end)
    Helper.registerEventListener("phaseTurn", function (phase, color)
        Action.context = {
            phase = phase,
            color = color
        }
    end)
end

--[[
    space(name)
    imperium_card(name) (< signet)
    intrigue_card(name)
    leader_ability
    influence_track_bonus(faction, level)
    commercial_track_bonus(level)
    research_track_bonus
    tleilaxu_track_bonus
    imperium_card_bonus(card)
    tech_tile_bonus(tech)
    tech_tile_effect(tech)
    conflict_reward(conflict, position)
    flag_control(space)
]]--
---
function Action.checkContext(attributes)
    for name, expectedValue in pairs(attributes) do
        local value = Action.context and Action.context[name] or nil
        local valid
        if type(expectedValue) == "function" then
            valid = expectedValue(value)
        else
            valid = value == expectedValue
        end
        if not valid then
            --Helper.dump("Bad context key:", name, "->", value)
            return false
        end
    end
    return true
end

---
function Action.instruct(phase, color)
end

---
function Action.setUp(color, epic)
    Action.resource(color, "water", 1)
    if epic then
        Action.troops(color, "supply", "garrison", 5)
        Action.drawIntrigues(color, 1)
    else
        Action.troops(color, "supply", "garrison", 3)
    end
end

---
function Action.tearDown()
end

---
function Action.sendAgent(color, spaceName)
    Action.context.space = spaceName
    MainBoard.sendAgent(color, spaceName)
end

---
function Action.reveal(color)
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
    -- Generic if not faction
    return InfluenceTrack.change(color, faction, amount)
end

---
function Action.troops(color, from, to, amount)
    Utils.assertIsPlayerColor(color)
    Utils.assertIsTroopLocation(from)
    Utils.assertIsTroopLocation(to)
    Utils.assertIsInteger(amount)
    return Park.transfert(amount, Action.getTroopPark(color, from), Action.getTroopPark(color, to))
end

---
function Action.getTroopPark(color, parkName)
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
        error("Unknow park name: " .. tostring(parkName))
    end
end

---
function Action.gainVictoryPoint(name)
    local victoryPointArea = {
        base = {
            theSpiceMustFlowBag = "43c7b5",
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
function Action.acquireReservedImperiumCard(color)
    return false
end

---
function Action.acquireImperiumCard(color, indexInRow)
    return ImperiumRow.acquireImperiumCard(indexInRow, color)
end

---
function Action.acquireFoldspaceCard(color)
    Reserve.acquireFoldspace(Reserve.foldspace, color)
end

---
function Action.signetRing(color)
end

---
function Action.advanceFreighter(color, positiveAmount)
    Utils.assertIsPositiveInteger(positiveAmount)
    for _ = 1, positiveAmount do
        CommercialTrack.cargoUp(color)
    end
end

---
function Action.recallFreighter(color)
    CommercialTrack.cargoReset(color)
end

---
function Action.moveFreighter(color, amount)
    -- Generic
end

---
function Action.dreadnought(color, from, to, amount)
    Utils.assertIsPlayerColor(color)
    Utils.assertIsDreadnoughtLocation(from)
    Utils.assertIsDreadnoughtLocation(to)
    Utils.assertIsInteger(amount)
    return Park.transfert(amount, Action.getDreadnoughtPark(color, from), Action.getDreadnoughtPark(color, to))
end

---
function Action.getDreadnoughtPark(color, parkName)
    if parkName == "supply" then
        return Playboard.getDreadnoughtSupplyPark(color)
    elseif parkName == "garrison" then
        return Combat.getDreadnoughtGarrisonPark(color)
    elseif parkName == "combat" then
        return nil
    elseif parkName == "carthag" then
        return nil
    elseif parkName == "arrakeen" then
        return nil
    elseif parkName == "imperialBassin" then
        return nil
    else
        error("Unknow park name: " .. tostring(parkName))
    end
end

---
function Action.flagControl(space)
end

---
function Action.dreadnoughtControl(space)
end

---
function Action.acquireTech(name)
end

---
function Action.acquireTechWithSolari(name)
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
function Action.researchRight()
end

---
function Action.researchLeft()
end

---
function Action.rollbackResearch()
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
    return Intrigue.drawIntrigue(color, amount)
end

---
function Action.stealIntrigue(color, otherColor, amount)
    Utils.assertIsPlayerColor(color)
    Utils.assertIsPlayerColor(otherColor)
    Utils.assertIsInteger(amount)

    return Intrigue.stealIntrigue(color, otherColor, amount)
end

function Action.trashImperiumCard(name)
end

function Action.discardImperiumCard(name)
end

function Action.discardIntrigueCard(name)
end

return Action
