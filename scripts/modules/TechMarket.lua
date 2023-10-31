local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")
local AcquireCard = require("utils.AcquireCard")
local I18N = require("utils.I18N")

local PlayBoard = Module.lazyRequire("PlayBoard")
local Deck = Module.lazyRequire("Deck")
local TechCard = Module.lazyRequire("TechCard")
local MainBoard = Module.lazyRequire("MainBoard")
local Types = Module.lazyRequire("Types")

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
        table.insert(TechMarket.acquireCards, AcquireCard.new(zone, "Tech", PlayBoard.withLeader(TechMarket["_acquireTech" .. tostring(i)])))
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
    Helper.createAnchoredAreaButton(TechMarket.negotiationZone, 0.6, 0.1, I18N("negotiatorEdit"), PlayBoard.withLeader(function (_, color, altClick)
        local leader = PlayBoard.getLeader(color)
        if altClick then
            leader.troops(color, "negotiation", "supply", 1)
        else
            leader.troops(color, "supply", "negotiation", 1)
        end
    end))
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
        -- Pending continuaton force us to this kind of simplification.
        Helper.onceTimeElapsed(2).doAfter(function ()
            TechMarket.frozen = false
        end)
        TechMarket._doAcquireTech(stackIndex, color).doAfter(function (card)
            if card and TechMarket.hagalSoloModeEnabled then
                TechMarket.pruneStacksForSoloMode()
            else
                TechMarket.frozen = false
            end
            if not card then
                broadcastToColor(I18N('notAffordableOption'), color, "Purple")
            end
        end)
    else
        log("Still frozen...")
    end
end

---
function TechMarket._doAcquireTech(stackIndex, color)
    --Helper.dumpFunction("TechMarket._doAcquireTech", stackIndex, color)
    local continuation = Helper.createContinuation("TechMarket._doAcquireTech")
    local acquireCard = TechMarket.acquireCards[stackIndex]

    local techTileStack = TechMarket._getTechTileStack(stackIndex)
    if techTileStack.topCard then

        local innerContinuation = Helper.createContinuation("TechMarket._doAcquireTech#inner")
        innerContinuation.doAfter(function (success)
            if success then
                PlayBoard.grantTechTile(color, techTileStack.topCard)
                TechCard.applyBuyEffect(color, techTileStack.topCard)

                Helper.onceTimeElapsed(0.5).doAfter(function ()
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
                end)
            else
                continuation.run(nil)
            end
        end)

        if color then
            if PlayBoard.isHuman(color) then
                TechMarket._buyTech(stackIndex, color).doAfter(innerContinuation.run)
            else
                innerContinuation.run(true)
            end
        else
            printToAll(I18N("pruneTechCard", { card = Helper.getID(techTileStack.topCard) }), "White")
            MainBoard.trash(techTileStack.topCard)
            innerContinuation.cancel()
        end
    else
        continuation.cancel()
    end

    return continuation
end

---
function TechMarket._buyTech(stackIndex, color)
    --Helper.dumpFunction("TechMarket._buyTech", stackIndex, color)
    local continuation = Helper.createContinuation("TechMarket._buyTech")
    local techTileStack = TechMarket._getTechTileStack(stackIndex)
    if techTileStack.topCard then
        local options = Helper.getKeys(TechMarket.acquireTechOptions)
        if #options > 0 then
            if #options > 1 then
                -- FIXME Pending continuation if the dialog is canceled.
                Player[color].showOptionsDialog(I18N("buyTechSelection"), Helper.mapValues(options, I18N), 1, function (_, index, _)
                    continuation.run(index and TechMarket._doBuyTech(techTileStack, options[index], color))
                end)
            else
                continuation.run(TechMarket._doBuyTech(techTileStack, options[1], color))
            end
        else
            -- FIXME Pending continuation if the dialog is canceled.
            Player[color].showConfirmDialog(I18N("manuallyBuyTech"), function ()
                continuation.run(true)
            end)
        end
    else
        continuation.run(false)
    end
    return continuation
end

---
function TechMarket._doBuyTech(techTileStack, option, color)
    --Helper.dumpFunction("TechMarket._doBuyTech", techTileStack, option, color)
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

    --Helper.dump("adjustedTechCost:", adjustedTechCost)
    --Helper.dump("recalledNegociatorCount:", recalledNegociatorCount)

    local leader = PlayBoard.getLeader(color)
    if leader.resources(color, optionDetails.resourceType, -adjustedTechCost) then

        local supply = PlayBoard.getSupplyPark(color)
        Park.transfert(recalledNegociatorCount, negotiation, supply)

        TechMarket.acquireTechOptions[option] = nil

        printToAll(I18N("buyTechCard", {
            card = I18N(Helper.getID(techTileStack.topCard)),
            amount = adjustedTechCost,
            resource =  I18N.agree(adjustedTechCost, optionDetails.resourceType) }),
        color)

        return true
    else
        return false
    end
end

---
function TechMarket.getTopCardDetails(stackIndex)
    --Helper.dumpFunction("TechMarket.getTopCardDetails", stackIndex)
    local techTileStack = TechMarket._getTechTileStack(stackIndex)
    if techTileStack.topCard then
        return TechCard.getDetails(techTileStack.topCard)
    end
    return nil
end

function TechMarket._getTechTileStack(stackIndex)
    --Helper.dumpFunction("TechMarket._getTechTileStack", stackIndex)
    Types.assertIsInteger(stackIndex)
    Types.assertIsInRange(1, 3, stackIndex)

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

---@param color PlayerColor
---@param source any
---@param resourceType ResourceName
---@param amount integer
function TechMarket.registerAcquireTechOption(color, source, resourceType, amount)
    --Helper.dumpFunction("TechMarket.registerAcquireTechOption", color, source, resourceType, amount)
    Types.assertIsPlayerColor(color)
    assert(color)
    Types.assertIsResourceName(resourceType)
    Types.assertIsInteger(amount)

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
