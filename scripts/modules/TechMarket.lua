local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")
local AcquireCard = require("utils.AcquireCard")

local PlayBoard = Module.lazyRequire("PlayBoard")
local Deck = Module.lazyRequire("Deck")
local Utils = Module.lazyRequire("Utils")

local TechMarket = {
    techDetails = {
        windtraps = { cost = 2, hagal = true },
        detonationDevices = { cost = 3, hagal = true },
        memocorders = { cost = 2, hagal = true },
        flagship = { cost = 8, hagal = true },
        spaceport = { cost = 5, hagal = false },
        artillery = { cost = 1, hagal = false },
        holoprojectors = { cost = 2, hagal = false },
        restrictedOrdnance = { cost = 4, hagal = false },
        shuttleFleet = { cost = 6, hagal = true },
        spySatellites = { cost = 4, hagal = true },
        disposalFacility = { cost = 3, hagal = false },
        chaumurky = { cost = 4, hagal = true },
        sonicSnoopers = { cost = 2, hagal = true },
        trainingDrones = { cost = 3, hagal = true },
        troopTransports = { cost = 2, hagal = true },
        holtzmanEngine = { cost = 6, hagal = true },
        minimicFilm = { cost = 2, hagal = false },
        invasionShips = { cost = 5, hagal = true },
    },
    negotiationParks = {},
    acquireTechOptions = {},
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

    if state.settings and state.settings.riseOfIx then
        TechMarket.hagalSoloModeEnabled = state.TechMarket.hagalSoloModeEnabled
    end
end

function TechMarket.onSave(state)
    state.TechMarket = {
        hagalSoloModeEnabled = TechMarket.hagalSoloModeEnabled
    }
end

---
function TechMarket.setUp(settings)
    if settings.riseOfIx then
        TechMarket.hagalSoloModeEnabled = settings.numberOfPlayers == 1
        TechMarket._staticSetUp()
    else
        TechMarket._tearDown()
    end
end

---
function TechMarket._staticSetUp()
    for _, color in ipairs(PlayBoard.getPlayBoardColors()) do
        TechMarket.negotiationParks[color] = TechMarket._createNegotiationPark(color)
    end
    TechMarket._createNegotiationButton()

    TechMarket.acquireCards = {}
    for i, zone in ipairs(TechMarket.techSlots) do
        table.insert(TechMarket.acquireCards, AcquireCard.new(zone, "Tech", TechMarket["_acquireTech" .. tostring(i)]))
    end

    Deck.generateTechDeck(TechMarket.techSlots).doAfter(function (decks)
        for _, deck in ipairs(decks) do
            deck.interactable = false
        end

        if TechMarket.hagalSoloModeEnabled then
            Wait.time(TechMarket.pruneStacksForSoloMode, 1)
        end
    end)

    Helper.registerEventListener("agentSent", function (color, spaceName)
        TechMarket.acquireTechOptions = {}
    end)
end

---
function TechMarket._tearDown()
    TechMarket.board.destruct()
    TechMarket.negotiationZone.destruct()
    for _, techSlot in ipairs(TechMarket.techSlots) do
        techSlot.destruct()
    end
end

---
function TechMarket.pruneStacksForSoloMode()
    local highestHeightIndex
    local highestHeight
    for stackIndex = 1, 3 do
        local techTileStack = TechMarket._getTechTileStack(stackIndex)
        if techTileStack.topCard then
            local height = Helper.getCardCount(techTileStack.otherCards)
            if not highestHeightIndex or highestHeight < height then
                highestHeightIndex = stackIndex
                highestHeight = height
            end
            local techName = techTileStack.topCard.getDescription()
            if TechMarket.techDetails[techName].hagal then
                TechMarket.frozen = false
                return
            end
        end
    end
    if highestHeightIndex then
        TechMarket._doAcquireTech(highestHeightIndex, TechMarket.acquireCards[highestHeightIndex]).doAfter(function (card)
            Wait.time(TechMarket.pruneStacksForSoloMode, 1)
        end)
    else
        TechMarket.frozen = false
        return
    end
end

---
function TechMarket._createNegotiationButton()
    Helper.createAnchoredAreaButton(TechMarket.negotiationZone, 0.6, 0.1, "Negotiator: ±1", function (_, color, altClick)
        local leader = PlayBoard.getLeader(color)
        if altClick then
            leader.troops(color, "negotiation", "supply", 1)
        else
            leader.troops(color, "supply", "negotiation", 1)
        end
    end)
end

---
function TechMarket._acquireTech1(acquireCard, color)
    TechMarket.acquireTech(1, acquireCard, color)
end

---
function TechMarket._acquireTech2(acquireCard, color)
    TechMarket.acquireTech(2, acquireCard, color)
end

---
function TechMarket._acquireTech3(acquireCard, color)
    TechMarket.acquireTech(3, acquireCard, color)
end

---
function TechMarket.acquireTech(stackIndex, acquireCard, color)
    if not TechMarket.frozen then
        TechMarket.frozen = true
        TechMarket._doAcquireTech(stackIndex, acquireCard, color).doAfter(function ()
            if TechMarket.hagalSoloModeEnabled then
                TechMarket.pruneStacksForSoloMode()
            end
        end)
    end
end

---
function TechMarket._doAcquireTech(stackIndex, acquireCard, color)
    local techTileStack = TechMarket._getTechTileStack(stackIndex)
    if techTileStack.topCard then
        local techName = techTileStack.topCard.getDescription()

        local continuation = Helper.createContinuation()

        if color then
            PlayBoard.grantTechTile(color, techTileStack.topCard)
            TechMarket._applyBuyEffect(color, techName)
        else
            Utils.trash(techTileStack.topCard)
        end

        Wait.time(function ()
            if techTileStack.otherCards then
                local above = acquireCard.zone.getPosition() + Vector(0, 1, 0)
                Helper.moveCardFromZone(acquireCard.zone, above, Vector(0, 180, 0), true).doAfter(function (card)
                    Helper.onceMotionless(card).doAfter(function ()
                        continuation.run(techTileStack.topCard)
                    end)
                end)
            else
                continuation.run(techTileStack.topCard)
            end
        end, 0.5)

        return continuation
    end
end

---
function TechMarket._buyTech(stackIndex, acquireCard, color)
    local techTileStack = TechMarket._getTechTileStack(stackIndex)
    if techTileStack.topCard then
        local options = Helper.getKeys(TechMarket.acquireTechOptions)
        if #options > 0 then
            if #options > 1 then
                Player[color].showOptionsDialog("Select which tech acquisition option you want to use.", options, 1, function (_, index, _)
                    if index then
                        TechMarket._doBuyTech(techTileStack, acquireCard, options[index], color)
                    end
                end)
            else
                TechMarket._doBuyTech(techTileStack, acquireCard, options[1], color)
            end
        end
    else
        log("No tiles!")
    end
end

---
function TechMarket._doBuyTech(techTileStack, acquireCard, option, color)
    local techName = techTileStack.topCard.getDescription()
    local techCost = TechMarket.techDetails[techName].cost

    local optionDetails = TechMarket.acquireTechOptions[option]
    local discountAmount = optionDetails.amount
    local negotiation = TechMarket.getNegotiationPark(color)
    local recalledNegociatorCount
    local adjustedTechCost

    if optionDetails.resourceType == "spice" then
        local negotiatorCount = #Park.getObjects(negotiation)

        adjustedTechCost = math.max(0, techCost - discountAmount - negotiatorCount)
        recalledNegociatorCount = math.max(0, techCost - adjustedTechCost - discountAmount)
    else
        adjustedTechCost = math.max(0, techCost - discountAmount)
        recalledNegociatorCount = 0
    end

    local leader = PlayBoard.getLeader(color)
    if leader.resource(color, optionDetails.resourceType, -adjustedTechCost) then
        local continuation = Helper.createContinuation()

        local supply = PlayBoard.getSupplyPark(color)
        Park.transfert(recalledNegociatorCount, negotiation, supply)

        TechMarket.acquireTechOptions[option] = nil

        PlayBoard.grantTechTile(color, techTileStack.topCard)
        if techTileStack.otherCards then
            Wait.time(function ()
                local above = acquireCard.zone.getPosition() + Vector(0, 1, 0)
                Helper.moveCardFromZone(acquireCard.zone, above, Vector(0, 180, 0), true).doAfter(continuation.run)
            end, 0.5)
        end

        TechMarket._applyBuyEffect(color, techName)

        return continuation
    end

    return nil
end

---
function TechMarket._getTechTileStack(stackIndex)
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
function TechMarket._applyBuyEffect(color, techName)
    local leader = PlayBoard.getLeader(color)
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
        if PlayBoard.hasACouncilSeat(color) then
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
function TechMarket._createNegotiationPark(color)
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
    local supply = PlayBoard.getSupplyPark()
    local negotiation = TechMarket.negotiationParks[color]
    return Park.transfert(1, supply, negotiation) > 0
end

---
function TechMarket.removeNegotiator(color)
    local supply = PlayBoard.getSupplyPark()
    local negotiation = TechMarket.negotiationParks[color]
    return Park.transfert(1, negotiation, supply) > 0
end

return TechMarket
