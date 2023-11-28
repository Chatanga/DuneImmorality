local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

local AcquireCard = Helper.createClass(nil, {
    UPDATE_EVENT_NAME = "AcquireCard/objectEnterOrLeaveScriptingZone"
})

---
function AcquireCard.new(zone, tag, acquire, cardHeight)
    local acquireCard = Helper.createClassInstance(AcquireCard, {
        zone = zone,
        cardHeight = cardHeight or 0.01,
        anchor = nil
    })

    --assert(#zone.getTags() == 0)
    zone.addTag(tag)

    local position = zone.getPosition() - Vector(0, 0.5, 0)
    Helper.createTransientAnchor("AcquireCard", position).doAfter(function (anchor)
        acquireCard.anchor = anchor

        local snapPoint = Helper.createRelativeSnapPointFromZone(anchor, zone, true, { tag })
        anchor.setSnapPoints({ snapPoint })

        if acquire then
            acquireCard:_createButton(acquire)

            Helper.registerEventListener("locale", function ()
                Helper.clearButtons(anchor)
                acquireCard:_createButton(acquire)
            end)

            Helper.registerEventListener(AcquireCard.UPDATE_EVENT_NAME, function (otherZone)
                if otherZone == zone then
                    Helper.clearButtons(anchor)
                    acquireCard:_createButton(acquire)
                end
            end)
        end
    end)

    return acquireCard
end

---
function AcquireCard:delete()
    Helper.clearButtons(self.anchor)
end

---
function AcquireCard.onObjectEnterScriptingZone(...)
    Helper.emitEvent(AcquireCard.UPDATE_EVENT_NAME, ...)
end

---
function AcquireCard.onObjectLeaveScriptingZone(...)
    Helper.emitEvent(AcquireCard.UPDATE_EVENT_NAME, ...)
end

function AcquireCard:_createButton(acquire)
    local cardCount = Helper.getCardCount(Helper.getDeckOrCard(self.zone))
    local objectCount = #self.zone.getObjects()
    local count = math.max(cardCount, objectCount)
    if count > 0 then
        local height = 0.7 + 0.1 + count * self.cardHeight
        local label = I18N("acquireButton") .. " (" .. tostring(count) .. ")"
        Helper.createAreaButton(self.zone, self.anchor, height, label, function (_, color)
            if not self.disabled then
                local continuation = acquire(self, color)
                if continuation then
                    self.disabled = true
                    continuation.doAfter(function ()
                        self.disabled = false
                    end)
                end
            end
        end)
    end
end

return AcquireCard
