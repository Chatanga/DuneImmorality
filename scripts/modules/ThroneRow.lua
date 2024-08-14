local Module = require("utils.Module")
local Helper = require("utils.Helper")
local AcquireCard = require("utils.AcquireCard")
local I18N = require("utils.I18N")
local Dialog = require("utils.Dialog")

local Deck = Module.lazyRequire("Deck")
local PlayBoard = Module.lazyRequire("PlayBoard")
local Commander = Module.lazyRequire("Commander")
local ImperiumCard = Module.lazyRequire("ImperiumCard")

local ThroneRow = {}

---
function ThroneRow.onLoad(state)
    Helper.append(ThroneRow, Helper.resolveGUIDs(false, {
        slotZones = {
            '7cceb1',
            '3b00e1',
            'f03bec',
            '46e26a',
        }
    }))

    if state.settings and state.settings.numberOfPlayers == 6 then
        ThroneRow._transientSetUp()
    end
end

---
function ThroneRow.setUp(settings)
    if settings.numberOfPlayers == 6 then
        ThroneRow._transientSetUp()
    else
        ThroneRow._tearDown()
    end
end

---
function ThroneRow._transientSetUp()
    ThroneRow.acquireCards = {}
    for i, zone in ipairs(ThroneRow.slotZones) do
        local acquireCard = AcquireCard.new(zone, "Imperium", PlayBoard.withLeader(function (_, color)
            if Commander.isTeamShaddam(color) then
                PlayBoard.getLeader(color).acquireThroneCard(color, i)
            else
                Dialog.broadcastToColor(I18N('notShaddamTeam'), color, "Purple")
            end
        end), Deck.getAcquireCardDecalUrl("corrino"))
        table.insert(ThroneRow.acquireCards, acquireCard)
    end
end

---
function ThroneRow.onObjectEnterZone(zone, object)
    if ThroneRow.acquireCards then
        for _, acquireCard in ipairs(ThroneRow.acquireCards) do
            if acquireCard.zone == zone then
                if object.type == "Card" then
                    if ImperiumCard.isFactionCard(object, "fremen") then
                        broadcastToAll(I18N('notFremenCard'), "White")
                    end
                end
            end
        end
    end
end

---
function ThroneRow._tearDown()
    for _, slotZone in ipairs(ThroneRow.slotZones) do
        slotZone.destruct()
    end
end

---
function ThroneRow.acquireThroneCard(color, indexInRow)
    local acquireCard = ThroneRow.acquireCards[indexInRow]
    PlayBoard.giveCardFromZone(color, acquireCard.zone)
    return true
end

return ThroneRow
