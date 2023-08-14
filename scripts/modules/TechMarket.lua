local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")
local AcquireCard = require("utils.AcquireCard")

local Playboard = Module.lazyRequire("Playboard")
local Action = Module.lazyRequire("Action")
local Deck = Module.lazyRequire("Deck")

local TechMarket = {
    techCosts = {
        windtraps = 2,
        detonationDevices = 3,
        memocorders = 2,
        flagship = 8,
        spaceport = 5,
        artillery = 1,
        holoprojectors = 2,
        restrictedOrdnance = 4,
        shuttleFleet = 6,
        spySatellites = 4,
        disposalFacility = 3,
        chaumurky = 4,
        sonicSnoopers = 2,
        trainingDrones = 3,
        troopTransports = 2,
        holtzmanEngine = 6,
        minimicFilm = 2,
        invasionShips = 5
    },
    negotiationParks = {},
    techDiscounts = {}
}

---
function TechMarket.onLoad(state)
    TechMarket.negotiationZone = getObjectFromGUID("2253fa")
end

---
function TechMarket.setUp()

    for color, _ in pairs(Playboard.getPlayboards()) do
        TechMarket.negotiationParks[color] = TechMarket.createNegotiationPark(color)
    end

    TechMarket.createNegotiationButton()

    TechMarket.techSlotZones = Helper.resolveGUIDs(true, {
        "7e131d",
        "5a22f7",
        "9c81c1"
    })

    for i, zone in ipairs(TechMarket.techSlotZones) do
        AcquireCard.new(zone, "Tech", TechMarket["acquireTech" .. tostring(i)])
    end

    Deck.generateTechDeck({
        getObjectFromGUID("7e131d"),
        getObjectFromGUID("5a22f7"),
        getObjectFromGUID("9c81c1")
    })
end

---
function TechMarket.tearDown()
    getObjectFromGUID("d75455").destruct()
end

---
function TechMarket.createNegotiationButton()
    local position = TechMarket.negotiationZone.getPosition()
    Helper.createTransientAnchor("AgentPark", Vector(position.x, 0.4, position.z)).doAfter(function (anchor)
        anchor.interactable = false
        Helper.createAbsoluteButtonWithRoundness(anchor, 1, false, {
            click_function = Helper.createGlobalCallback(function (_, color, altClick)
                if altClick then
                    Action.troops(color, "negotiation", "supply", 1)
                else
                    Action.troops(color, "supply", "negotiation", 1)
                end
            end),
            position = Vector(position.x, 0.7, position.z),
            width = 850,
            height = 975,
            color = { 0, 0, 0, 0 },
            tooltip = "Negotiator: ±1"
        })
    end)
end

---
function TechMarket.acquireTech1(acquireCard, color)
    TechMarket.acquireTech(1, acquireCard, color)
end

---
function TechMarket.acquireTech2(acquireCard, color)
    TechMarket.acquireTech(2, acquireCard, color)
end

---
function TechMarket.acquireTech3(acquireCard, color)
    TechMarket.acquireTech(3, acquireCard, color)
end

---
function TechMarket.acquireTech(stackIndex, acquireCard, color)
    local cardAndDeck = TechMarket.getCardAndDeck(stackIndex)
    if cardAndDeck.card then
        local techName = cardAndDeck.card.getDescription()
        local techCost = TechMarket.techCosts[techName]

        local discount = TechMarket.techDiscounts[color]
        local discountAmount = 0
        if discount then
            discountAmount = discount.amount
        end
        local negotiation = TechMarket.getNegotiationPark(color)
        local negotiatorCount = #Park.getObjects(negotiation)

        local adjustedTechCost = math.max(0, techCost - discountAmount - negotiatorCount)
        local recalledNegociatorCount = techCost - adjustedTechCost - discountAmount

        if Action.resource(color, "spice", -adjustedTechCost) then

            local supply = Playboard.getSupplyPark(color)
            Park.transfert(recalledNegociatorCount, negotiation, supply)

            TechMarket.techDiscounts[color] = nil

            Playboard.grantTechTile(color, cardAndDeck.card)
            if cardAndDeck.deck then
                local above = acquireCard.zone.getPosition() + Vector(0, 1, 0)
                Helper.moveCardFromZone(acquireCard.zone, above, nil, false, true)
            end

            TechMarket.applyBuyEffect(color, techName)
        end
    else
        log("No tiles!")
    end
end

---
function TechMarket.getCardAndDeck(stackIndex)
    local cardAndDeck = {}

    local zone = TechMarket.techSlotZones[stackIndex]
    for _, object in ipairs(zone.getObjects()) do
        if object.type == "Card" then
            cardAndDeck.card = object
        elseif object.type == "Deck" then
            cardAndDeck.deck = object.getObjects()
        end
    end

    return cardAndDeck
end

---
function TechMarket.applyBuyEffect(color, techName)
    log(techName)
    if techName == "windtraps" then
        Action.resource(color, "water", 1)
    elseif techName == "detonationDevices" then
    elseif techName == "memocorders" then
        -- 1 influence
    elseif techName == "flagship" then
        Action.gainVictoryPoint(color, "flagshipTech")
    elseif techName == "spaceport" then
        Action.drawCards(color, 2)
    elseif techName == "artillery" then
    elseif techName == "holoprojectors" then
    elseif techName == "restrictedOrdnance" then
    elseif techName == "shuttleFleet" then
        -- 2 influences différentes
    elseif techName == "spySatellites" then
    elseif techName == "disposalFacility" then
        -- 1 trash
    elseif techName == "chaumurky" then
        Action.drawIntrigues(color, 2)
    elseif techName == "sonicSnoopers" then
        Action.drawIntrigues(color, 1)
    elseif techName == "trainingDrones" then
    elseif techName == "troopTransports" then
    elseif techName == "holtzmanEngine" then
    elseif techName == "minimicFilm" then
    elseif techName == "invasionShips" then
        Action.troops(color, "supply", "garrison", 4)
    end
end

---
function TechMarket.registerTechDiscount(color, source, amount)
    TechMarket.techDiscounts[color] = {
        source = source,
        amount = amount
    }
end

---
function TechMarket.onPlayerTurn(_, previousPlayerColor)
    if previousPlayerColor then
        TechMarket.techDiscounts[previousPlayerColor] = nil
    end
end

---
function TechMarket.createNegotiationPark(color)
    local offsets = {
        Red = Vector(-0.45, 0, 0.45),
        Blue = Vector(-0.45, 0, -0.45),
        Green = Vector(0.45, 0, 0.45),
        Yellow = Vector(0.45, 0, -0.45)
    }

    local origin = TechMarket.negotiationZone.getPosition() + offsets[color]
    origin:setAt('y', 0.86) -- ground level
    local slots = {}
    for k = 1, 2 do
        for j = 1, 2 do
            for i = 1, 2 do
                local x = (i - 1.5) * 0.4
                local y = (k - 1) * 0.4
                local z = (1.5 - j) * 0.4
                local slot = Vector(x, y, z) + origin
                table.insert(slots, slot)
            end
        end
    end

    local zone = Park.createBoundingZone(0, Vector(0.25, 0.25, 0.25), slots)

    return Park.createPark(
        "negotiation." .. color,
        slots,
        Vector(0, 0, 0),
        zone,
        { "Troop", color },
        nil,
        false)
end

---
function TechMarket.getNegotiationPark(color)
    return TechMarket.negotiationParks[color]
end

---
function TechMarket.addNegotiator(color)
    local supply = Playboard.getSupplyPark()
    local negotiation = TechMarket.negotiationParks[color]
    return Park.transfert(1, supply, negotiation) > 0
end

---
function TechMarket.removeNegotiator(color)
    local supply = Playboard.getSupplyPark()
    local negotiation = TechMarket.negotiationParks[color]
    return Park.transfert(1, negotiation, supply) > 0
end

return TechMarket
