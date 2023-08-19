local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

local AcquireCard = Helper.createClass()

---
function AcquireCard.new(zone, snapPointTag, acquire)
    local acquireCard = Helper.createClassInstance(AcquireCard, {
        zone = zone,
        anchor = nil
    })

    local position = zone.getPosition() - Vector(0, 0.5, 0)
    Helper.createTransientAnchor("Slot anchor", position).doAfter(function (anchor)
        acquireCard.anchor = anchor

        local snapPoint = Helper.createRelativeSnapPointFromZone(anchor, zone, true, { snapPointTag })
        anchor.setSnapPoints({ snapPoint })

        if acquire then
            acquireCard:createButton(acquire)

            Helper.registerEventListener("locale", function ()
                anchor.clearButtons()
                acquireCard:createButton(acquire)
            end)

            acquireCard.updateButtonHeight = function (z, o)
                if z == zone then
                    anchor.clearButtons()
                    acquireCard:createButton(acquire)
                end
            end

            Helper.registerEventListener("objectEnterOrLeaveScriptingZone", acquireCard.updateButtonHeight)
        end
    end)

    return acquireCard
end

---
function AcquireCard:delete()
    Helper.unregisterEventListener("objectEnterOrLeaveScriptingZone", self.updateButtonHeight)
    self.anchor.clearButtons()
end

---
function AcquireCard.onObjectEnterScriptingZone(...)
    Helper.emitEvent("objectEnterOrLeaveScriptingZone", ...)
end

---
function AcquireCard.onObjectLeaveScriptingZone(...)
    Helper.emitEvent("objectEnterOrLeaveScriptingZone", ...)
end

---
function AcquireCard:createButton(acquire)
    local cardCount = Helper.getCardCount(Helper.getDeckOrCard(self.zone))
    local height = 0.7 + 0.1 + cardCount * 0.01
    Helper.createAreaButton(self.zone, self.anchor, height, I18N("acquireButton"), function (_, color, _)
        acquire(self, color)
    end)
end

return AcquireCard
