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
local ShippingTrack = Module.lazyRequire("ShippingTrack")

local TechMarket = {
    negotiationParks = {},
    acquireTechOptions = {},
}

---
function TechMarket.onLoad(state)
    --Helper.dumpFunction("TechMarket.onLoad")

    Helper.append(TechMarket, Helper.resolveGUIDs(false, {
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
        TechMarket._transientSetUp(state.settings)
    end
end

---
function TechMarket.onSave(state)
    --Helper.dumpFunction("TechMarket.onSave")
    state.TechMarket = {
        hagalSoloModeEnabled = TechMarket.hagalSoloModeEnabled
    }
end

---
function TechMarket.setUp(settings)
    if settings.riseOfIx then
        TechMarket.hagalSoloModeEnabled = settings.numberOfPlayers == 1
        Deck.generateTechDeck(TechMarket.techSlots).doAfter(function (decks)
            for _, deck in ipairs(decks) do
                deck.interactable = false
            end

            if TechMarket.hagalSoloModeEnabled then
                Helper.onceTimeElapsed(1).doAfter(TechMarket.pruneStacksForSoloMode)
            end

            TechMarket._transientSetUp(settings)
        end)
    else
        TechMarket._tearDown()
    end
end

---
function TechMarket._transientSetUp(settings)
    for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
        if not Commander.isCommander(color) then
            TechMarket.negotiationParks[color] = TechMarket._createNegotiationPark(color)
        end
    end
    TechMarket._createNegotiationButton()

    TechMarket.acquireCards = {}
    for i, zone in ipairs(TechMarket.techSlots) do
        local acquireCard = AcquireCard.new(zone, "Tech", PlayBoard.withLeader(function (_, color)
            local leader = PlayBoard.getLeader(color)
            leader.acquireTech(color, i)
        end))
        acquireCard.groundHeight = acquireCard.groundHeight + 0.2
        table.insert(TechMarket.acquireCards, acquireCard)
    end

    Helper.registerEventListener("agentSent", function (color, spaceName)
        TechMarket.acquireTechOptions = {}
    end)
end

---
function TechMarket._tearDown()
    TechMarket.board.destruct()
    TechMarket.board = nil
    TechMarket.negotiationZone.destruct()
    for _, techSlot in ipairs(TechMarket.techSlots) do
        techSlot.destruct()
    end
end

---
function TechMarket.getBoard()
    return TechMarket.board
end

---
function TechMarket._processSnapPoints(settings)
    local highCouncilSeats = {}
    TechMarket.spaces = {}
    TechMarket.observationPosts = {}
    TechMarket.banners = {}

    for _, board in ipairs({ TechMarket.board, ShippingTrack.getBoard() }) do
        Helper.collectSnapPoints(settings, {

            seat = function (name, position)
                local str = name:sub(12)
                local index = tonumber(str)
                assert(index, "Not a number: " .. str)
                highCouncilSeats[index] = position
            end,

            space = function (name, position)
                if settings.riseOfIx then
                    local ignoredSpaceNames = {
                        "assemblyHall",
                        "gatherSupport",
                        "shipping",
                        "acceptContract",
                    }
                    for _, ignoredSpaceName in ipairs(ignoredSpaceNames) do
                        if Helper.startsWith(name, ignoredSpaceName) then
                            return
                        end
                    end
                end
                MainBoard.spaces[name] = { name = name, position = position }
            end,

            post = function (name, position)
                if settings.riseOfIx then
                    local ignoredSpaceNames = {
                        "choam",
                        "landsraadCouncil2"
                    }
                    for _, ignoredSpaceName in ipairs(ignoredSpaceNames) do
                        if Helper.startsWith(name, ignoredSpaceName) then
                            return
                        end
                    end
                end
                MainBoard.observationPosts[name] = { name = name, position = position }
            end,

            spice = function (name, position)
                local token = MainBoard.spiceBonusTokens[name]
                token.setPosition(position + Vector(0, -0.05, 0))
                Helper.noPhysics(token)
                if not MainBoard.spiceBonuses[name] then
                    MainBoard.spiceBonuses[name] = Resource.new(token, nil, "spice", 0, name)
                end
            end,

            flag = function (name, position)
                local zone = spawnObject({
                    type = 'ScriptingTrigger',
                    position = position,
                    scale = { 0.8, 1, 0.8 },
                })
                Helper.markAsTransient(zone)
                MainBoard.banners[name .. "BannerZone"] = zone
            end
        })
    end

    assert(#highCouncilSeats > 0)
    MainBoard.highCouncilPark = Park.createPark(
        "HighCouncil",
        highCouncilSeats,
        Vector(0, 0, 0),
        { Park.createTransientBoundingZone(0, Vector(0.5, 1, 0.5), highCouncilSeats) },
        { "HighCouncilSeatToken" },
        nil,
        true,
        true)

    -- A trick to ensure that parent space are created before
    -- their child spaces (which always have a longer name).
    local orderedSpaces = Helper.getValues(MainBoard.spaces)
    table.sort(orderedSpaces, function (s1, s2)
        return s1.name:len() < s2.name:len()
    end)
    for _, space in ipairs(orderedSpaces) do
        MainBoard._createSpaceButton(space)
    end

    for _, observationPost in pairs(MainBoard.observationPosts) do
        MainBoard._createObservationPostButton(observationPost)
    end

    for _, bannerZone in pairs(MainBoard.banners) do
        MainBoard._createBannerSpace(bannerZone)
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
    Helper.createAnchoredAreaButton(TechMarket.negotiationZone, 1.6, 0.1, I18N("negotiatorEdit"), PlayBoard.withLeader(function (_, color, altClick)
        local leader = PlayBoard.getLeader(color)
        if altClick then
            leader.troops(color, "negotiation", "supply", 1)
        else
            leader.troops(color, "supply", "negotiation", 1)
        end
    end))
end

---
function TechMarket.acquireTech(stackIndex, color)
    if not TechMarket.frozen then
        TechMarket.frozen = true
        -- Pending continuation force us to this kind of simplification.
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
                Dialog.broadcastToColor(I18N('notAffordableOption'), color, "Purple")
            end
        end)
    else
        Helper.dump("Still frozen...")
    end
end

---
function TechMarket._doAcquireTech(stackIndex, color)
    Helper.dumpFunction("TechMarket._doAcquireTech", stackIndex, color)
    local continuation = Helper.createContinuation("TechMarket._doAcquireTech")
    local acquireCard = TechMarket.acquireCards[stackIndex]

    local techTileStack = TechMarket._getTechTileStack(stackIndex)
    if techTileStack.topCard then

        local innerContinuation = Helper.createContinuation("TechMarket._doAcquireTech#inner")
        innerContinuation.doAfter(function (success)
            if success and color and PlayBoard.grantTechTile(color, techTileStack.topCard) then
                TechCard.applyBuyEffect(color, techTileStack.topCard)
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
            if PlayBoard.isHuman(color) then
                TechMarket._buyTech(stackIndex, color).doAfter(innerContinuation.run)
            else
                innerContinuation.run(true)
            end
        else
            printToAll(I18N("pruneTechCard", { card = Helper.getID(techTileStack.topCard) }), "Purple")
            MainBoard.trash(techTileStack.topCard)
            innerContinuation.run(true)
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
                Dialog.showOptionsAndCancelDialog(color, I18N("buyTechSelection"), Helper.mapValues(options, I18N), continuation, function (index)
                    if index > 0 then
                        continuation.run(index and TechMarket._doBuyTech(techTileStack, options[index], color))
                    else
                        continuation.run(false)
                    end
                end)
            else
                continuation.run(TechMarket._doBuyTech(techTileStack, options[1], color))
            end
        else
            Dialog.showConfirmOrCancelDialog(color, I18N("manuallyBuyTech"), continuation, function (confirmed)
                continuation.run(confirmed)
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
    origin:setAt('y', 1.86) -- ground level
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

--- In TechMarket for convenience, but it could also be in MainBoard.
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
