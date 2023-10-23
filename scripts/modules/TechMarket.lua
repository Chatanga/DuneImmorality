local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")
local AcquireCard = require("utils.AcquireCard")

local PlayBoard = Module.lazyRequire("PlayBoard")
local Deck = Module.lazyRequire("Deck")
local TechCard = Module.lazyRequire("TechCard")
local MainBoard = Module.lazyRequire("MainBoard")

local TechMarket = {
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

    Helper.noPhysicsNorPlay(TechMarket.board)

    if state.settings and state.settings.riseOfIx then
        TechMarket.hagalSoloModeEnabled = state.TechMarket.hagalSoloModeEnabled
    end
end

---
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
            Helper.onceTimeElapsed(1).doAfter(TechMarket.pruneStacksForSoloMode)
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
            if TechCard.isHagal(techTileStack.topCard) then
                TechMarket.frozen = false
                return
            end
        end
    end
    if highestHeightIndex then
        TechMarket._doAcquireTech(highestHeightIndex).doAfter(function (card)
            Helper.onceTimeElapsed(1).doAfter(TechMarket.pruneStacksForSoloMode)
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
function TechMarket._acquireTech1(_, color)
    TechMarket.acquireTech(1, color)
end

---
function TechMarket._acquireTech2(_, color)
    TechMarket.acquireTech(2, color)
end

---
function TechMarket._acquireTech3(_, color)
    TechMarket.acquireTech(3, color)
end

---
function TechMarket.acquireTech(stackIndex, color)
    if not TechMarket.frozen then
        TechMarket.frozen = true
        TechMarket._doAcquireTech(stackIndex, color).doAfter(function ()
            if TechMarket.hagalSoloModeEnabled then
                TechMarket.pruneStacksForSoloMode()
            else
                TechMarket.frozen = false
            end
        end)
    end
end

---
function TechMarket._doAcquireTech(stackIndex, color)
    local continuation = Helper.createContinuation("TechMarket._doAcquireTech")
    local acquireCard = TechMarket.acquireCards[stackIndex]

    log(1)
    local techTileStack = TechMarket._getTechTileStack(stackIndex)
    log(2)
    if techTileStack.topCard then

        if color then
            log(3)
            PlayBoard.grantTechTile(color, techTileStack.topCard)
            log(4)
            TechCard.applyBuyEffect(color, techTileStack.topCard)
        else
            log(5)
            MainBoard.trash(techTileStack.topCard)
        end

        log(6)
        Helper.onceTimeElapsed(0.5).doAfter(function ()
            if techTileStack.otherCards then
                local above = acquireCard.zone.getPosition() + Vector(0, 1, 0)
                log(7)
                Helper.moveCardFromZone(acquireCard.zone, above, Vector(0, 180, 0), true).doAfter(function (card)
                    Helper.onceMotionless(card).doAfter(function ()
                        log(8)
                        continuation.run(techTileStack.topCard)
                    end)
                end)
            else
                continuation.run(techTileStack.topCard)
            end
        end)
    else
        continuation.cancel()
    end

    return continuation
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
        error("No tiles!")
    end
end

---
function TechMarket._doBuyTech(techTileStack, acquireCard, option, color)
    local techCost = TechCard.getCost(techTileStack.topCard)

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
    if leader.resources(color, optionDetails.resourceType, -adjustedTechCost) then
        local continuation = Helper.createContinuation("TechMarket._doBuyTech")

        local supply = PlayBoard.getSupplyPark(color)
        Park.transfert(recalledNegociatorCount, negotiation, supply)

        TechMarket.acquireTechOptions[option] = nil

        PlayBoard.grantTechTile(color, techTileStack.topCard)
        if techTileStack.otherCards then
            Helper.onceTimeElapsed(0.5).doAfter(function ()
                local above = acquireCard.zone.getPosition() + Vector(0, 1, 0)
                Helper.moveCardFromZone(acquireCard.zone, above, Vector(0, 180, 0), true).doAfter(continuation.run)
            end)
        end

        TechCard.applyBuyEffect(color, techTileStack.topCard)

        return continuation
    end

    return nil
end

---
function TechMarket.getTopCardDetails(stackIndex)
    local techTileStack = TechMarket._getTechTileStack(stackIndex)
    if techTileStack.topCard then
        return TechCard.getDetails(techTileStack.topCard)
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
