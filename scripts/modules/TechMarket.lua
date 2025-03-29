local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")
local AcquireCard = require("utils.AcquireCard")
local I18N = require("utils.I18N")
local Dialog = require("utils.Dialog")

local PlayBoard = Module.lazyRequire("PlayBoard")
local Deck = Module.lazyRequire("Deck")
local MainBoard = Module.lazyRequire("MainBoard")
local Types = Module.lazyRequire("Types")
local Commander = Module.lazyRequire("Commander")
local TechCard = Module.lazyRequire("TechCard")
local Action = Module.lazyRequire("Action")
local Board = Module.lazyRequire("Board")

---@alias TechTileStack {
--- topCard: Card,
--- otherCards: Deck }

---@class TechMarket
---@field acquireTechOptions table<string, { resourceType: ResourceName, amount: integer }>
local TechMarket = {
    negotiationParks = {},
    acquireTechOptions = {},
}

---@param state table
function TechMarket.onLoad(state)
    if state.settings and (state.settings.ix or state.settings.ixAmbassy) then
        if state.settings.ixAmbassy then
            TechMarket.board = Board.getBoard("ixAmbassyBoard")
        else
            TechMarket.board = Board.getBoard("ixBoard")
        end
        TechMarket._transientSetUp(state.settings)
    end
end

---@param settings Settings
function TechMarket.setUp(settings)
    if settings.ix or settings.ixAmbassy then
        if settings.ixAmbassy then
            TechMarket.board = Board.selectBoard("ixAmbassyBoard", settings.language)
            Board.destructBoard("ixBoard")
        else
            TechMarket.board = Board.selectBoard("ixBoard", settings.language)
            Board.destructBoard("ixAmbassyBoard")
        end

        TechMarket._transientSetUp(settings)

        Deck.generateTechDeck(TechMarket.techSlots, settings)
        .doAfter(function (decks)
            for _, deck in ipairs(decks) do
                deck.interactable = false
            end

            if TechMarket.hagalSoloModeEnabled then
                Helper.onceTimeElapsed(1).doAfter(TechMarket.pruneStacksForSoloMode)
            end
        end)
    else
        TechMarket._tearDown()
    end
end

---@param settings Settings
function TechMarket._transientSetUp(settings)
    TechMarket._processSnapPoints()

    TechMarket.hagalSoloModeEnabled = settings.numberOfPlayers == 1

    if settings.ix then
        for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
            if not Commander.isCommander(color) then
                TechMarket.negotiationParks[color] = TechMarket._createNegotiationPark(color)
            end
        end
        TechMarket._createNegotiationButton()
    end

    TechMarket.acquireCards = {}
    for i, zone in ipairs(TechMarket.techSlots) do
        local acquireCard = AcquireCard.new(zone, Board.onIxBoard(0), "Tech", PlayBoard.withLeader(function (leader, color)
            leader.acquireTech(color, i)
        end))
        table.insert(TechMarket.acquireCards, acquireCard)
    end

    Helper.registerEventListener("playerTurn", function (phase, color)
        -- The "agentSent" event is not yet sent when revealing card such as "Acquire Tech".
        TechMarket.acquireTechOptions = {}
    end)

    Helper.registerEventListener("agentSent", function (color, spaceName)
        -- Only needed when playing multiple times as a human (Jessica of Arrakis).
        TechMarket.acquireTechOptions = {}
        if settings.ixAmbassy and MainBoard.isGreenSpace(spaceName) then
            local discount = PlayBoard.hasHighCouncilSeat(color) and 1 or 0
            TechMarket.registerAcquireTechOption(color, "ixAmbassyTechBuyOption", "spice", discount)
        end
    end)

    Helper.registerEventListener("highCouncilSeatTaken", function (color)
        if settings.ixAmbassy and TechMarket.acquireTechOptions["ixAmbassyTechBuyOption"] then
            TechMarket.registerAcquireTechOption(color, "ixAmbassyTechBuyOption", "spice", 1)
        end
        TechMarket.setContributions(color)
    end)
end

---@param color PlayerColor
function TechMarket.setContributions(color)
    local contributions = TechCard.evaluatePreReveal(color)
    PlayBoard.getResource(color, "persuasion"):setBaseValueContribution("techTiles", contributions.persuasion or 0)
    PlayBoard.getResource(color, "strength"):setBaseValueContribution("techTiles", contributions.strength or 0)
end

function TechMarket._tearDown()
    Board.destructBoard("ixBoard")
    Board.destructBoard("ixAmbassyBoard")
end

function TechMarket._processSnapPoints()
    TechMarket.techSlots = {}
    TechMarket.negotiatorSlot = nil

    assert(TechMarket.board, "No tech market board!")

    Helper.collectSnapPoints(TechMarket.board, {

        slotTech = function (name, position)
            local index = tonumber(name)
            assert(index, "Not a number: " .. name)
            local zone = spawnObject({
                type = 'ScriptingTrigger',
                position = position,
                rotation = Vector(0, 0, 0),
                scale = { 2.8, 2.0, 1.8 }
            })
            Helper.markAsTransient(zone)
            TechMarket.techSlots[index] = zone
        end,

        slotNegotiator = function (name, position)
            TechMarket.negotiationZone = spawnObject({
                type = 'ScriptingTrigger',
                position = position,
                rotation = Vector(0, 0, 0),
                scale = { 2.0, 2.0, 2.0 }
            })
            Helper.markAsTransient(TechMarket.negotiationZone)
        end
    })
end

---@return Object?
function TechMarket.getBoard()
    return TechMarket.board
end

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

function TechMarket._createNegotiationButton()
    Helper.createAnchoredAreaButton(TechMarket.negotiationZone, Board.onIxBoard(0.08), 0.1, I18N("negotiatorEdit"), PlayBoard.withLeader(function (leader, color, altClick)
        if altClick then
            leader.troops(color, "negotiation", "supply", 1)
        else
            leader.troops(color, "supply", "negotiation", 1)
        end
    end))
end

---@param color PlayerColor
---@param techCard Card
---@param cumulativeDiscound integer
function TechMarket.acquireRandomTech(color, techCard, cumulativeDiscound)
    assert(Types.isPlayerColor(color))
    assert(Types.isTech(techCard))

    TechMarket._buyTech(techCard, color, cumulativeDiscound).doAfter(function (success)
        if success then
            if techCard.is_face_down then
                techCard.flip()
            end
            PlayBoard.grantTechTile(color, techCard)
            TechCard.applyBuyEffect(color, techCard)
        end
    end)
end

---@param stackIndex integer
---@param color PlayerColor
function TechMarket.acquireTech(stackIndex, color)
    if not TechMarket.frozen then
        TechMarket.frozen = true
        TechMarket._doAcquireTech(stackIndex, color).doAfter(function (card)
            if card and TechMarket.hagalSoloModeEnabled then
                TechMarket.pruneStacksForSoloMode()
            else
                TechMarket.frozen = false
            end
            if not card then
                Dialog.broadcastToColor(I18N('notAffordableOption'), color, "Purple")
            end
        end)
    else
        Helper.dump("Still frozen...")
    end
end

---@param stackIndex integer
---@param color? PlayerColor
---@return Continuation
function TechMarket._doAcquireTech(stackIndex, color)
    local continuation = Helper.createContinuation("TechMarket._doAcquireTech")
    local acquireCard = TechMarket.acquireCards[stackIndex]

    local techTileStack = TechMarket._getTechTileStack(stackIndex)
    if techTileStack.topCard then

        local innerContinuation = Helper.createContinuation("TechMarket._doAcquireTech#inner")
        innerContinuation.doAfter(function (success)
            if success then
                if color then
                    local techCard = techTileStack.topCard
                    PlayBoard.grantTechTile(color, techCard)
                    -- Async simply to avoid an exception to break the whole market.
                    Helper.onceFramesPassed(1).doAfter(function ()
                        TechCard.applyBuyEffect(color, techCard)
                    end)
                end
                Helper.onceTimeElapsed(0.5).doAfter(function ()
                    if techTileStack.otherCards then
                        local above = acquireCard.zone.getPosition() + Vector(0, 1, 0)
                        Helper.moveCardFromZone(acquireCard.zone, above, Vector(0, 180, 0), true).doAfter(function (card)
                            assert(card)
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
            if techTileStack.topCard then
                TechMarket._buyTech(techTileStack.topCard, color).doAfter(innerContinuation.run)
            else
                innerContinuation.run(false)
            end
        else
            printToAll(I18N("pruneTechCard", { card = I18N(Helper.getID(techTileStack.topCard)) }), "Pink")
            MainBoard.trash(techTileStack.topCard)
            innerContinuation.run(true)
        end
    else
        continuation.run(nil)
    end

    return continuation
end

---@param techCard Card
---@param color PlayerColor
---@param cumulativeDiscound? integer
---@return Continuation
function TechMarket._buyTech(techCard, color, cumulativeDiscound)
    local continuation = Helper.createContinuation("TechMarket._buyTech")
    local options = Helper.getKeys(TechMarket.acquireTechOptions)
    if #options > 0 then
        if #options > 1 then
            -- The functor nature of I18N seems to confuse annotation typing.
            local translate = function (str)
                return I18N(str)
            end
            Dialog.showOptionsAndCancelDialog(color, I18N("buyTechSelection"), Helper.mapValues(options, translate), continuation, function (index)
                if index > 0 then
                    continuation.run(index and TechMarket._doBuyTech(techCard, options[index], color, cumulativeDiscound))
                else
                    continuation.run(false)
                end
            end)
        else
            continuation.run(TechMarket._doBuyTech(techCard, options[1], color, cumulativeDiscound))
        end
    elseif not PlayBoard.isRival(color) then
        Dialog.showYesOrNoDialog(color, I18N("manuallyBuyTech"), continuation, function (confirmed)
            continuation.run(confirmed)
        end)
    else
        continuation.run(false)
    end
    return continuation
end

---@param techCard Card
---@param option string
---@param color PlayerColor
---@param cumulativeDiscound? integer
---@return boolean
function TechMarket._doBuyTech(techCard, option, color, cumulativeDiscound)
    local techCost = TechCard.getCost(techCard)

    local optionDetails = TechMarket.acquireTechOptions[option]
    local discountAmount = optionDetails.amount + (cumulativeDiscound or 0)
    local negotiation = TechMarket.getNegotiationPark(color)
    local recalledNegociatorCount
    local adjustedTechCost

    if negotiation and optionDetails.resourceType == "spice" then
        local negotiatorCount = #Park.getObjects(negotiation)

        adjustedTechCost = math.max(0, techCost - discountAmount - negotiatorCount)
        recalledNegociatorCount = math.max(0, techCost - adjustedTechCost - discountAmount)
    else
        adjustedTechCost = math.max(0, techCost - discountAmount)
        recalledNegociatorCount = 0
    end

    local leader = PlayBoard.getLeader(color)
    if leader.resources(color, optionDetails.resourceType, -adjustedTechCost) then

        local supply = PlayBoard.getSupplyPark(color)
        if recalledNegociatorCount > 0 then
            Park.transfer(recalledNegociatorCount, negotiation, supply)
        end

        TechMarket.acquireTechOptions[option] = nil

        Action.log(I18N("buyTech", {
                name = I18N(Helper.getID(techCard)),
                amount = adjustedTechCost,
                resource =  I18N.agree(adjustedTechCost, optionDetails.resourceType) }),
            color)

        return true
    else
        return false
    end
end

---@param stackIndex integer
---@return TechCardDetails?
function TechMarket.getTopCardDetails(stackIndex)
    local techTileStack = TechMarket._getTechTileStack(stackIndex)
    if techTileStack.topCard then
        return TechCard.getDetails(techTileStack.topCard)
    end
    return nil
end

---@param stackIndex integer
---@return string?
function TechMarket.getBottomCardDetails(stackIndex)
    local techTileStack = TechMarket._getTechTileStack(stackIndex)
    if techTileStack.otherCards then
        local cards = techTileStack.otherCards.getObjects()
        local bottomCard = cards[#cards]
        return Helper.getID(bottomCard)
    end
    return nil
end

---@param stackIndex integer
---@param position Vector
---@return Card?
function TechMarket.grapBottomCard(stackIndex, position)
    local techTileStack = TechMarket._getTechTileStack(stackIndex)
    if techTileStack.otherCards then
        local cards = techTileStack.otherCards.getObjects()
        local bottomCard = cards[#cards]
        local parameters = {
            guid = bottomCard.guid,
            position = position,
            smooth = false,
        }
        return techTileStack.otherCards.takeObject(parameters)
    end
    return nil
end

---@param stackIndex integer
---@return TechTileStack
function TechMarket._getTechTileStack(stackIndex)
    assert(Helper.isInRange(1, 3, stackIndex))

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
---@param source string
---@param resourceType ResourceName
---@param amount integer
function TechMarket.registerAcquireTechOption(color, source, resourceType, amount)
    assert(Types.isPlayerColor(color))
    assert(color)
    assert(Types.isResourceName(resourceType))

    TechMarket.acquireTechOptions[source] = {
        resourceType = resourceType,
        amount = amount
    }
end

---@return integer
function TechMarket.getRivalSpiceDiscount()
    local options = Helper.getValues(TechMarket.acquireTechOptions)
    assert(#options == 1, #options)
    local option = options[1]
    assert(option.resourceType == "spice")
    return option.amount
end

---@param color PlayerColor
---@return Park
function TechMarket._createNegotiationPark(color)
    local offsets = {
        Red = Vector(-0.45, 0, 0.45),
        Blue = Vector(-0.45, 0, -0.45),
        Green = Vector(0.45, 0, 0.45),
        Yellow = Vector(0.45, 0, -0.45)
    }

    assert(TechMarket.negotiationZone, "No " .. color .. " negotiation zone!")
    local origin = TechMarket.negotiationZone.getPosition() + offsets[color]
    origin:setAt('y', Board.onIxBoard(0.18)) -- ground level
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

    local zone = Park.createTransientBoundingZone(0, Vector(0.25, 0.25, 0.25), slots)

    return Park.createPark(
        color .. "Negotiation",
        slots,
        Vector(0, 0, 0),
        { zone },
        { "Troop", color },
        nil,
        false,
        true)
end

---@param color PlayerColor
---@return Park
function TechMarket.getNegotiationPark(color)
    assert(TechMarket.negotiationParks, "Missing Rise of Ix extension!")
    return TechMarket.negotiationParks[color]
end

---@param color PlayerColor
---@return boolean
function TechMarket.unused_addNegotiator(color)
    assert(TechMarket.negotiationParks, "Missing Rise of Ix extension!")
    local supply = PlayBoard.getSupplyPark(color)
    local negotiation = TechMarket.negotiationParks[color]
    return Park.transfer(1, supply, negotiation) > 0
end

---@param color PlayerColor
---@return boolean
function TechMarket.removeNegotiator(color)
    assert(TechMarket.negotiationParks, "Missing Rise of Ix extension!")
    local supply = PlayBoard.getSupplyPark(color)
    local negotiation = TechMarket.negotiationParks[color]
    return Park.transfer(1, negotiation, supply) > 0
end

--- In TechMarket for convenience, but it could also be in MainBoard.
---@param object Object
---@return boolean
function TechMarket.isInside(object)
    if TechMarket.board then
        local position = object.getPosition()
        local center = TechMarket.board.getPosition()
        local offset = position - center
        return math.abs(offset.x) < 3.5 and math.abs(offset.z) < 4
    else
        return false
    end
end

return TechMarket
