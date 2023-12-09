local Module = require("utils.Module")
local Helper = require("utils.Helper")
local AcquireCard = require("utils.AcquireCard")

local PlayBoard = Module.lazyRequire("PlayBoard")
local MainBoard = Module.lazyRequire("MainBoard")

local ChoamContractMarket = {
    -- Unused
    contract = {
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
    acquireCards = {},
    contractSlots = {},
}

---
function ChoamContractMarket.onLoad(state)
    --Helper.dumpFunction("ChoamContractMarket.onLoad(...)")

    Helper.append(ChoamContractMarket, Helper.resolveGUIDs(false, {
        contractBags = {
            en = "099d8b",
            fr = "fb05ac",
        }
    }))

    if state.settings then
        ChoamContractMarket._staticSetUp(state.settings)
    end
end

---
function ChoamContractMarket.setUp(settings)
    if settings.useContracts then
        ChoamContractMarket._staticSetUp(settings)

        Helper.registerEventListener("phaseStart", function (phaseName)
            if phaseName == "gameStart" then
                Helper.shuffleDeck(ChoamContractMarket.contractBag)
                Helper.onceShuffled(ChoamContractMarket.contractBag).doAfter(function ()
                    for i, _ in ipairs(ChoamContractMarket.contractSlots) do
                        ChoamContractMarket._replenish(i)
                    end
                end)
            end
        end)
    else
        ChoamContractMarket._tearDown()
    end
end

---
function ChoamContractMarket._staticSetUp(settings)
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
        local acquireCard = AcquireCard.new(zone, "Contract", callback, 0.3)
        table.insert(ChoamContractMarket.acquireCards, acquireCard)
    end
end

---
function ChoamContractMarket._tearDown()
    -- NOP
end

---
function ChoamContractMarket._processSnapPoints(settings)

    ChoamContractMarket.contractSlots = {}

    local net = {
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
    }

    MainBoard.collectSnapPointsEverywhere(settings, net)
end

---
function ChoamContractMarket._acquireContract1(_, color)
    ChoamContractMarket.acquireContract(1, color)
end

---
function ChoamContractMarket._acquireContract2(_, color)
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
    ChoamContractMarket.contractBag.takeObject({
        position = position,
        rotation = Vector(0, 180, 0),
        smooth = true,
    })
end

---
function ChoamContractMarket.takeAnySardaukarContract(position)
    --Helper.dumpFunction("ChoamContractMarket.takeAnySardaukarContract", position)
    for _, object in ipairs(ChoamContractMarket.contractBag.getObjects()) do
        assert(object.guid)
        if Helper.isElementOf("SardaukarContract",  object.tags) then
            ChoamContractMarket.contractBag.takeObject({
                position = position,
                rotation = Vector(0, 180, 0),
                guid = object.guid,
            })
            break
        end
    end
end

return ChoamContractMarket
