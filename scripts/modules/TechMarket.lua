local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")
local AcquireCard = require("utils.AcquireCard")

local Playboard = Module.lazyRequire("Playboard")
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
    acquireTechOptions = {}
}

---
function TechMarket.onLoad(state)
    Helper.append(TechMarket, Helper.resolveGUIDs(true, {
        board = "d75455",
        negotiationZone = "2253fa",
        techSlots = {
            "7e131d",
            "5a22f7",
            "9c81c1"
        },
    }))
end

---
function TechMarket.setUp()

    for _, color in ipairs(Playboard.getPlayboardColors()) do
        TechMarket.negotiationParks[color] = TechMarket.createNegotiationPark(color)
    end
    TechMarket.createNegotiationButton()

    for i, zone in ipairs(TechMarket.techSlots) do
        AcquireCard.new(zone, "Tech", TechMarket["acquireTech" .. tostring(i)])
    end

    Deck.generateTechDeck(TechMarket.techSlots)

    Helper.registerEventListener("agentSent", function (color, spaceName)
        TechMarket.acquireTechOptions = {}
    end)
end

---
function TechMarket.tearDown()
    TechMarket.board.destruct()
    TechMarket.negotiationZone.destruct()
    for _, techSlot in ipairs(TechMarket.techSlots) do
        techSlot.destruct()
    end
end

---
function TechMarket.createNegotiationButton()
    Helper.createAnchoredAreaButton(TechMarket.negotiationZone, 0.6, 0.1, "Negotiator: ±1", function (_, color, altClick)
        local leader = Playboard.getLeader(color)
        if altClick then
            leader.troops(color, "negotiation", "supply", 1)
        else
            leader.troops(color, "supply", "negotiation", 1)
        end
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
    local techTileStack = TechMarket.getTechTileStack(stackIndex)
    if techTileStack.topCard then
        local options = Helper.getKeys(TechMarket.acquireTechOptions)
        if #options > 0 then
            if #options > 1 then
                Player[color].showOptionsDialog("Select which tech acquisition option you want to use.", options, 1, function (_, index, _)
                    if index then
                        TechMarket._doAcquireTech(techTileStack, acquireCard, options[index], color)
                    end
                end)
            else
                TechMarket._doAcquireTech(techTileStack, acquireCard, options[1], color)
            end
        end
    else
        log("No tiles!")
    end
end

---
function TechMarket._doAcquireTech(techTileStack, acquireCard, option, color)
    local techName = techTileStack.topCard.getDescription()
    local techCost = TechMarket.techCosts[techName]

    local optionDetails = TechMarket.acquireTechOptions[option]
    local discountAmount = optionDetails.amount
    local negotiation = TechMarket.getNegotiationPark(color)
    local recalledNegociatorCount
    local adjustedTechCost

    if optionDetails.resourceType == "spice" then
        local negotiatorCount = #Park.getObjects(negotiation)

        adjustedTechCost = math.max(0, techCost - discountAmount - negotiatorCount)
        recalledNegociatorCount = techCost - adjustedTechCost - discountAmount
    else
        adjustedTechCost = math.max(0, techCost - discountAmount)
        recalledNegociatorCount = 0
    end

    local leader = Playboard.getLeader(color)
    if leader.resource(color, optionDetails.resourceType, -adjustedTechCost) then

        local supply = Playboard.getSupplyPark(color)
        Park.transfert(recalledNegociatorCount, negotiation, supply)

        TechMarket.acquireTechOptions[option] = nil

        Playboard.grantTechTile(color, techTileStack.topCard)
        if techTileStack.otherCards then
            Wait.time(function ()
                local above = acquireCard.zone.getPosition() + Vector(0, 1, 0)
                Helper.moveCardFromZone(acquireCard.zone, above, Vector(0, 180, 0), true, false)
            end, 0.5)
        else
            acquireCard:delete()
        end

        TechMarket.applyBuyEffect(color, techName)
    end
end

---
function TechMarket.getTechTileStack(stackIndex)
    local techTileStack = {}

    local zone = TechMarket.techSlots[stackIndex]
    for _, object in ipairs(zone.getObjects()) do
        if object.type == "Card" and not object.is_face_down then
            techTileStack.topCard = object
        elseif object.type == "Deck" or (object.type == "Card" and object.is_face_down) then
            techTileStack.otherCards = object
        end
    end

    return techTileStack
end

---
function TechMarket.applyBuyEffect(color, techName)
    local leader = Playboard.getLeader(color)
    if techName == "windtraps" then
        leader.resource(color, "water", 1)
    elseif techName == "detonationDevices" then
    elseif techName == "memocorders" then
        -- 1 influence
    elseif techName == "flagship" then
        leader.gainVictoryPoint(color, "flagship")
    elseif techName == "spaceport" then
        leader.drawImperiumCards(color, 2)
    elseif techName == "artillery" then
    elseif techName == "holoprojectors" then
    elseif techName == "restrictedOrdnance" then
        if Playboard.hasACouncilSeat(color) then
            leader.resource(color, "strength", 4)
        end
    elseif techName == "shuttleFleet" then
        -- 2 influences différentes
    elseif techName == "spySatellites" then
    elseif techName == "disposalFacility" then
        -- 1 trash
    elseif techName == "chaumurky" then
        leader.drawIntrigues(color, 2)
    elseif techName == "sonicSnoopers" then
        leader.drawIntrigues(color, 1)
    elseif techName == "trainingDrones" then
    elseif techName == "troopTransports" then
    elseif techName == "holtzmanEngine" then
    elseif techName == "minimicFilm" then
        leader.resource(color, "persuasion", 1)
    elseif techName == "invasionShips" then
        leader.troops(color, "supply", "garrison", 4)
    end
end

---
function TechMarket.registerAcquireTechOption(color, source, resourceType, amount)
    TechMarket.acquireTechOptions[source] = {
        resourceType = resourceType,
        amount = amount
    }
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
        color .. "Negotiation",
        slots,
        Vector(0, 0, 0),
        zone,
        { "Troop", color },
        nil,
        false,
        true)
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
