local Module = require("utils.Module")
local Helper = require("utils.Helper")
local AcquireCard = require("utils.AcquireCard")

local Deck = Module.lazyRequire("Deck")
local Playboard = Module.lazyRequire("Playboard")
local TleilaxuResearch = Module.lazyRequire("TleilaxuResearch")
local Action = Module.lazyRequire("Action")

local TleilaxuRow = {
    tleilaxuCardCostByName = {
        beguilingPheromones = 3,
        dogchair = 2,
        contaminator = 1,
        corrinoGenes = 1,
        faceDancer = 2,
        faceDancerInitiate = 1,
        fromTheTanks = 2,
        ghola = 3,
        guildImpersonator = 2,
        industrialEspionage = 1,
        scientificBreakthrough = 3,
        sligFarmer = 2,
        stitchedHorror = 3,
        subjectX137 = 2,
        tleilaxuInfiltrator = 2,
        twistedMentat = 4,
        unnaturalReflexes = 3,
        usurper = 4,
        piterGeniusAdvisor = 3,
        reclaimedForces = 3
    }
}

---
function TleilaxuRow.onLoad(_)
    Helper.append(TleilaxuRow, Helper.resolveGUIDs(true, {
        deckZone = "14b2ca",
        slotZones = {
            'e5ba35',
            '1e5a32',
            '965fea'
        }
    }))

    TleilaxuRow.acquireCards = {}
    for i, zone in ipairs(TleilaxuRow.slotZones) do
        local acquireCard = AcquireCard.new(zone, "Imperium", function (_, color)
            Action.acquireTleilaxuCard(color, i)
        end)
        table.insert(TleilaxuRow.acquireCards, acquireCard)
    end
end

---
function TleilaxuRow.setUp()
    Deck.generateTleilaxuDeck(TleilaxuRow.deckZone).doAfter(function (deck)
        deck.shuffle()
        for i = 1, 2 do
            local zone = TleilaxuRow.slotZones[i]
            Helper.moveCardFromZone(TleilaxuRow.deckZone, zone.getPosition(), Vector(0, 180, 0), false, false)
        end
    end)
    Deck.generateSpecialDeck("reclaimedForces", TleilaxuRow.slotZones[3])
end

---
function TleilaxuRow.tearDown()
    TleilaxuRow.deckZone.destruct()
    for _, slotZone in ipairs(TleilaxuRow.slotZones) do
        slotZone.destruct()
    end
end

---
function TleilaxuRow.acquireTleilaxuCard(indexInRow, color)
    local acquireCard = TleilaxuRow.acquireCards[indexInRow]
    local card = Helper.getCard(acquireCard.zone)
    local cardName = card.getDescription()
    local price = TleilaxuRow.tleilaxuCardCostByName[cardName]
    assert(price, "Unknown tleilaxu card: " .. cardName)
    assert((cardName == "reclaimedForces") == (indexInRow == 3))

    if card and TleilaxuResearch.getSpecimenCount(color) >= price then
        local leader = Playboard.getLeader(color)
        if cardName == "reclaimedForces" then
            local options = {
                "Troops",
                "Beetle"
            }
            Player[color].showOptionsDialog("Reclaimed forces", options, 1, function (_, index, _)
                if index == 1 then
                    leader.troops(color, "tanks", "supply", price)
                    leader.troops(color, "supply", "garrison", 2)
                elseif index == 2 then
                    leader.troops(color, "tanks", "supply", price)
                    leader.beetle(color)
                end
            end)
            return true
        else
            leader.troops(color, "tanks", "supply", price)

            -- TODO "Reclaimed Forces" -> dialogue de choix.
            Playboard.giveCard(color, card, false)

            -- Replenish the slot in the row.
            Helper.moveCardFromZone(TleilaxuRow.deckZone, acquireCard.zone.getPosition(), Vector(0, 180, 0), false, false)
            return true
        end
    else
        return false
    end
end

return TleilaxuRow
