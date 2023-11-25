local Module = require("utils.Module")
local Helper = require("utils.Helper")
local AcquireCard = require("utils.AcquireCard")

local PlayBoard = Module.lazyRequire("PlayBoard")

local ChoamContractMarket = {
    acquireCards = {},
    contractSlots = {},
}

---
function ChoamContractMarket.onLoad()
    Helper.append(ChoamContractMarket, Helper.resolveGUIDs(true, {
        contractBag = "099d8b",
    }))
end

---
function ChoamContractMarket.setUp(settings)
    if settings.useContracts then
        ChoamContractMarket._staticSetUp(settings)
    else
        ChoamContractMarket._tearDown()
    end
end

---
function ChoamContractMarket._staticSetUp(settings)
    ChoamContractMarket._processSnapPoints(settings)

    Helper.shuffleDeck(ChoamContractMarket.contractBag)
    Helper.onceShuffled(ChoamContractMarket.contractBag).doAfter(function ()
        for i, zone in ipairs(ChoamContractMarket.contractSlots) do
            local callback = PlayBoard.withLeader(ChoamContractMarket["_acquireContract" .. tostring(i)])
            local acquireCard = AcquireCard.new(zone, "Contract", callback, 0.1)
            table.insert(ChoamContractMarket.acquireCards, acquireCard)
            ChoamContractMarket._replenish(i)
        end
    end)
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

    -- Having changed the state is not enough.
    if settings.numberOfPlayers == 6 then
        Helper.collectSnapPoints(net, getObjectFromGUID("21cc52"))
    else
        Helper.collectSnapPoints(net, getObjectFromGUID("483a1a"))
    end
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

return ChoamContractMarket
