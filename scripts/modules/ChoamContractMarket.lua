local Module = require("utils.Module")
local Helper = require("utils.Helper")
local AcquireCard = require("utils.AcquireCard")
local Park = require("utils.Park")

local PlayBoard = Module.lazyRequire("PlayBoard")
local MainBoard = Module.lazyRequire("MainBoard")
local Commander = Module.lazyRequire("Commander")

local ChoamContractMarket = {
    -- Unused
    -- http://cloud-3.steamusercontent.com/ugc/2190499045494153971/2F050419ADB34BC59FEBF5B5A483F9A315F41D8A/
    contracts = {
        harvest_1 = 1,
        harvest_2 = 1,
        harvest_3 = 1,
        harvest_4 = 1,
        deliverSupplies = 1,
        highCouncil_1 = 1,
        highCouncil_2 = 1,
        acquire = 1,
        immediate = 1,
        researchStation_1 = 1,
        researchStation_2 = 1,
        espionnage_1 = 1,
        espionnage_2 = 1,
        heighliner_1 = 1,
        heighliner_2 = 1,
        sardaukar_1 = 1,
        sardaukar_2 = 1,
        spiceRefinery_1 = 1,
        spiceRefinery_2 = 1,
        arrakeen_1 = 1,
        arrakeen_2 = 1,
    },
    -- Unused
    -- http://cloud-3.steamusercontent.com/ugc/2190499045495011713/25CD19C82AA59A349CAB24DCC69EAEDF7F5BED3E/
    ixContracts = {
        dreadnought = 1,
        techNegotiation = 1,
        highCouncil = 1,
        interstellarShipping = 1,
        harvest_1 = 1,
        harvest_2 = 1,
        smuggling = 1,
        heighliner = 1,
        espionage = 1,
        secrets = 1,
    },
    acquireCards = {},
    contractSlots = {},
}

---
function ChoamContractMarket.onLoad(state)
    --Helper.dumpFunction("ChoamContractMarket.onLoad")

    Helper.append(ChoamContractMarket, Helper.resolveGUIDs(false, {
        contractBags = {
            en = "099d8b",
            fr = "fb05ac",
        }
    }))

    if state.settings then
        ChoamContractMarket._transientSetUp(state.settings)
    end
end

---
function ChoamContractMarket.setUp(settings)
    if settings.useContracts then
        ChoamContractMarket._transientSetUp(settings)

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
        local callback = PlayBoard.withLeader(ChoamContractMarket["_acquireContract" .. tostring(i)])
        local acquireCard = AcquireCard.new(zone, "Contract", callback)
        acquireCard.groundHeight = acquireCard.groundHeight + 0.1
        acquireCard.cardHeight = 0.2
        table.insert(ChoamContractMarket.acquireCards, acquireCard)
    end
end

---
function ChoamContractMarket._tearDown()
    for _, bag in pairs(ChoamContractMarket.contractBags) do
        bag.destruct()
    end
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
function ChoamContractMarket._acquireContract1(_, color)
    -- TODO Introduce the usual indirection player -> action -> ChoamContractMarket.
    ChoamContractMarket.acquireContract(1, color)
end

---
function ChoamContractMarket._acquireContract2(_, color)
    -- TODO Introduce the usual indirection player -> action -> ChoamContractMarket.
    ChoamContractMarket.acquireContract(2, color)
end

---
function ChoamContractMarket.acquireContract(indexInRow, color)
    local acquireCard = ChoamContractMarket.acquireCards[indexInRow]
    local objects = acquireCard.zone.getObjects()
    if #objects > 0 then
        PlayBoard.grantContractTile(color, objects[1], false)
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
    --Helper.dumpFunction("ChoamContractMarket.takeAnySardaukarContract", position)

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
