local Module = require("utils.Module")
local Helper = require("utils.Helper")
local AcquireCard = require("utils.AcquireCard")
local Park = require("utils.Park")
local I18N = require("utils.I18N")

local PlayBoard = Module.lazyRequire("PlayBoard")
local MainBoard = Module.lazyRequire("MainBoard")
local Commander = Module.lazyRequire("Commander")

local ChoamContractMarket = {
    contracts = {},
    ixContracts = {},
    acquireCards = {},
    contractSlots = {},
}

---
function ChoamContractMarket.onLoad(state)
    Helper.append(ChoamContractMarket, Helper.resolveGUIDs(false, {
        contractBags = {
            en = "099d8b",
            fr = "fb05ac",
        }
    }))

    ChoamContractMarket.contracts = {
        harvest3orMore = Helper.never(), -- MainBoard.isDesertSpace, -- x2
        harvest4orMore = Helper.never(), -- MainBoard.isDesertSpace,
        deliverSupplies = Helper.equal("deliverSupplies"),
        highCouncilWithSolaris = Helper.equal("highCouncil"),
        highCouncilWithInfluence = Helper.equal("highCouncil"),
        acquireTheSpiceMustFlow = Helper.never(),
        immediate = Helper.never(),
        researchStation = Helper.equal("researchStation"), -- with just solaris
        researchStationWithSpy = Helper.equal("researchStation"),
        espionage = Helper.equal("espionage"), -- x2
        heighlinerWithWater = Helper.equal("heighliner"),
        heighlinerWithTroops = Helper.equal("heighliner"),
        sardaukarWithCards = Helper.equal("sardaukar"),
        sardaukarWithRecall = Helper.equal("sardaukar"),
        spiceRefineryWithCards = Helper.equal("spiceRefinery"),
        spiceRefineryWithWater = Helper.equal("spiceRefinery"),
        arrakeenWithWater = Helper.equal("arrakeen"),
        arrakeenWithSpy = Helper.equal("arrakeen"),
    }

    ChoamContractMarket.ixContracts = {
        dreadnought = Helper.equal("dreadnought"),
        techNegotiation = Helper.equal("techNegotiation"),
        highCouncilWithTech = Helper.equal("highCouncil"),
        interstellarShipping = Helper.equal("interstellarShipping"),
        harvest3orMoreWithTech = Helper.never(), -- MainBoard.isDesertSpace,
        harvest4orMoreWithTech = Helper.never(), -- MainBoard.isDesertSpace,
        smuggling = Helper.equal("smuggling"),
        heighlinerWithTech = Helper.equal("heighliner"),
        espionageWithTech = Helper.equal("espionage"),
        secretsWithTech = Helper.equal("secrets"),
    }

    ChoamContractMarket.enabled = false
    if state.settings and state.settings.useContracts then
        ChoamContractMarket._transientSetUp(state.settings)
    end
end

---
function ChoamContractMarket.setUp(settings)
    if settings.useContracts then
        ChoamContractMarket._transientSetUp(settings)

        assert(ChoamContractMarket.contractBag, "No contract bag!")
        Helper.shuffleDeck(ChoamContractMarket.contractBag)
        Helper.onceShuffled(ChoamContractMarket.contractBag).doAfter(function ()

            local ixContratCountForEachPlayer = {}
            if settings.riseOfIx then
                for _, color in ipairs(PlayBoard.getActivePlayBoardColors(true)) do
                    if not Commander.isCommander(color) then
                        ixContratCountForEachPlayer[color] = 2
                    end
                end
            end

            local trashHeight = 1
            for _, object in ipairs(ChoamContractMarket.contractBag.getObjects()) do
                if Helper.isElementOf("IxContract", object.tags) then
                    local taken = false
                    for color, count in pairs(ixContratCountForEachPlayer) do
                        if count > 0 then
                            ixContratCountForEachPlayer[color] = count - 1
                            local emptySlots = Park.findEmptySlots(PlayBoard.getRevealCardPark(color))
                            ChoamContractMarket.contractBag.takeObject({
                                position = emptySlots[count],
                                rotation = Vector(0, 180, 0),
                                guid = object.guid,
                            })
                            taken = true
                            break
                        end
                    end
                    if not taken then
                        ChoamContractMarket.contractBag.takeObject({
                            position = getObjectFromGUID('ef8614').getPosition() + Vector(0, trashHeight * 0.5, 0),
                            rotation = Vector(0, 180, 0),
                            guid = object.guid,
                        })
                        trashHeight = trashHeight + 1
                    end
                end
            end

            for i, _ in ipairs(ChoamContractMarket.contractSlots) do
                ChoamContractMarket._replenish(i)
            end
        end)
    else
        ChoamContractMarket._tearDown()
    end
end

---
function ChoamContractMarket._transientSetUp(settings)
    ChoamContractMarket.enabled = true

    local barycenter = Vector(0, 0, 0)
    for language, bag in pairs(ChoamContractMarket.contractBags) do
        barycenter = barycenter + bag.getPosition()
        if language == settings.language then
            ChoamContractMarket.contractBag = bag
        else
            bag.destruct()
        end
    end
    barycenter = barycenter * (1.0 / #Helper.getKeys(ChoamContractMarket.contractBags))
    ChoamContractMarket.contractBag.setPosition(barycenter)
    ChoamContractMarket.contractBags = nil

    ChoamContractMarket._processSnapPoints(settings)

    for i, zone in ipairs(ChoamContractMarket.contractSlots) do
        local acquireCard = AcquireCard.new(zone, "Contract", PlayBoard.withLeader(function (_, color)
            local leader = PlayBoard.getLeader(color)
            leader.pickContract(color, i)
        end))
        acquireCard.groundHeight = acquireCard.groundHeight + 0.1
        acquireCard.cardHeight = 0.2
        table.insert(ChoamContractMarket.acquireCards, acquireCard)
    end

    Helper.registerEventListener("agentSent", function (color, spaceName)
        local parentSpaceName = MainBoard.findParentSpaceName(spaceName)
        local contracts = PlayBoard.getOpenContracts(color)
        for i, contract in ipairs(contracts) do
            local contractName = Helper.getID(contract)
            local contractLocator = ChoamContractMarket.contracts[contractName] or ChoamContractMarket.ixContracts[contractName]
            if contractLocator and contractLocator(parentSpaceName) then
                broadcastToAll(I18N("fulfilledContract", { contract = I18N(contractName) }), color)
            end
        end
    end)
end

---
function ChoamContractMarket._tearDown()
    for _, bag in pairs(ChoamContractMarket.contractBags) do
        bag.destruct()
    end
end

---
function ChoamContractMarket.isEnabled()
    return ChoamContractMarket.enabled
end

---
function ChoamContractMarket._processSnapPoints(settings)
    ChoamContractMarket.contractSlots = {}

    MainBoard.collectSnapPointsOnAllBoards(settings, {

        contract = function (name, position)
            local zone = spawnObject({
                type = 'ScriptingTrigger',
                position = position,
                scale = { 2.2, 1, 1.4 },
            })
            Helper.markAsTransient(zone)
            local indexInRow = tonumber(name:sub(5))
            if indexInRow then
                ChoamContractMarket.contractSlots[indexInRow] = zone
            end
        end,
    })
end

---
function ChoamContractMarket.acquireContract(indexInRow, color)
    local acquireCard = ChoamContractMarket.acquireCards[indexInRow]
    local objects = acquireCard.zone.getObjects()
    if #objects > 0 then
        local contract = objects[1]
        printToAll(I18N("acquireContract", { name = I18N(Helper.getID(contract)) }), color)
        PlayBoard.grantContractTile(color, contract, false)
        ChoamContractMarket._replenish(indexInRow)
        return true
    else
        return false
    end
end

---
function ChoamContractMarket._replenish(indexInRow)
    local acquireCard = ChoamContractMarket.acquireCards[indexInRow]
    local position = acquireCard.zone.getPosition()
    if ChoamContractMarket.contractBag.getQuantity() > 0 then
        ChoamContractMarket.contractBag.takeObject({
            position = position,
            rotation = Vector(0, 180, 0),
            smooth = true,
        })
    end
end

---
function ChoamContractMarket.takeAnySardaukarContract(position)

    for _, object in ipairs(ChoamContractMarket.contractBag.getObjects()) do
        assert(object.guid)
        if Helper.isElementOf("SardaukarContract", object.tags) then
            ChoamContractMarket.contractBag.takeObject({
                position = position,
                rotation = Vector(0, 180, 0),
                guid = object.guid,
            })
            return
        end
    end

    for indexInRow, acquireCard in ipairs(ChoamContractMarket.acquireCards) do
        for _, object in ipairs(acquireCard.zone.getObjects()) do
            if object.hasTag("Contract") and object.hasTag("SardaukarContract") then
                object.setPosition(position)
                ChoamContractMarket._replenish(indexInRow)
                return
            end
        end
    end
end

return ChoamContractMarket
