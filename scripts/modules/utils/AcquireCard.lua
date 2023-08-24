local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

local AcquireCard = Helper.createClass(nil, {
    UPDATE_EVENT_NAME = "AcquireCard/objectEnterOrLeaveScriptingZone"
})

---
function AcquireCard.new(zone, snapPointTag, acquire)
    local acquireCard = Helper.createClassInstance(AcquireCard, {
        zone = zone,
        anchor = nil,
        _updateButtonHeight = nil
    })

    local position = zone.getPosition() - Vector(0, 0.5, 0)
    Helper.createTransientAnchor("AcquireCard", position).doAfter(function (anchor)
        acquireCard.anchor = anchor

        local snapPoint = Helper.createRelativeSnapPointFromZone(anchor, zone, true, { snapPointTag })
        anchor.setSnapPoints({ snapPoint })

        if acquire then
            acquireCard:_createButton(acquire)

            Helper.registerEventListener("locale", function ()
                anchor.clearButtons()
                acquireCard:_createButton(acquire)
            end)

            acquireCard._updateButtonHeight = function (otherZone)
                if otherZone == zone then
                    anchor.clearButtons()
                    acquireCard:_createButton(acquire)
                end
            end

            Helper.registerEventListener(AcquireCard.UPDATE_EVENT_NAME, acquireCard._updateButtonHeight)
        end
    end)

    return acquireCard
end

---
function AcquireCard:delete()
    Helper.unregisterEventListener(AcquireCard.UPDATE_EVENT_NAME, self._updateButtonHeight)
    self.anchor.clearButtons()
end

---
function AcquireCard.onObjectEnterScriptingZone(...)
    Helper.emitEvent(AcquireCard.UPDATE_EVENT_NAME, ...)
end

---
function AcquireCard.onObjectLeaveScriptingZone(...)
    Helper.emitEvent(AcquireCard.UPDATE_EVENT_NAME, ...)
end

---
function AcquireCard:_createButton(acquire)
    if self.callbackName then
        Helper.unregisterGlobalCallback(self.callbackName)
        self.callbackName = nil
    end
    local cardCount = Helper.getCardCount(Helper.getDeckOrCard(self.zone))
    if cardCount > 0 then
        local height = 0.7 + 0.1 + cardCount * 0.01
        self.callbackName = Helper.createAreaButton(self.zone, self.anchor, height, I18N("acquireButton"), function (_, color)
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
