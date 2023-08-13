local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

local AcquireCard = {}

---
function AcquireCard.new(zone, snapPointTag, acquire)
    local acquireCard = Helper.newObject(AcquireCard, {
        zone = zone,
        anchor = nil
    })

    local p = zone.getPosition()
    -- FIXME Hardcoded height, use an existing parent anchor.
    p:setAt('y', 0.5)
    Helper.createTransientAnchor("Slot anchor", p).doAfter(function (anchor)
        acquireCard.anchor = anchor
        acquireCard.anchor.interactable = false

        local snapPoint = Helper.createRelativeSnapPointFromZone(anchor, zone, true, { snapPointTag })
        anchor.setSnapPoints({ snapPoint })

        if acquire then
            acquireCard:createButton(acquire)

            Helper.registerEventListener("locale", function ()
                anchor.clearButtons()
                acquireCard:createButton(acquire)
            end)

            local updateButtonHeight = function (z, o)
                if z == zone then
                    anchor.clearButtons()
                    acquireCard:createButton(acquire)
                end
            end

            Helper.registerEventListener("objectEnterOrLeaveScriptingZone", updateButtonHeight)
        end
    end)

    return acquireCard
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
    local callback = Helper.createGlobalCallback(function (_, color, _)
        acquire(self, color)
    end)
    self:createAbsoluteAcquireButton(callback)
end

---
function AcquireCard:createAbsoluteAcquireButton(action)
    local cardCount = Helper.getCardCount(Helper.getDeckOrCard(self.zone))

    local position = self.anchor.getPosition()
    position.y = position.y + cardCount * 0.01 + 0.25
    position.z = position.z

    local zoneScale = self.zone.getScale()

    local sizeFactor = 350 -- 500

    local parameters = {
        click_function = action,
        position = position,
        width = zoneScale.x * sizeFactor,
        height = zoneScale.z * sizeFactor,
        color = { 0, 0, 0, 0 },
        font_color = { 1, 1, 1, 100 },
        tooltip = I18N("acquireButton")
    }

    Helper.createAbsoluteButtonWithRoundness(self.anchor, 0.75, false, parameters)
end

return AcquireCard
