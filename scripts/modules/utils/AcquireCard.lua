local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

local AcquireCard = Helper.createClass(nil, {
    UPDATE_EVENT_NAME = "AcquireCard/objectEnterOrLeaveScriptingZone"
})

---
function AcquireCard.new(zone, tag, acquire, decalUrl)
    local acquireCard = Helper.createClassInstance(AcquireCard, {
        zone = zone,
        groundHeight = 0.65,
        cardHeight = 0.01,
        anchor = nil
    })

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

        if decalUrl then
            acquireCard:_setDecal(decalUrl)
        end
    end)

    return acquireCard
end

---
function AcquireCard:_setDecal(decalUrl)
    local scale = self.zone.getScale()
    self.anchor.setDecals({
        {
            name = "AcquireCard",
            url = decalUrl,
            position = Vector(0, 0.1, 0),
            rotation = { 90, 180, 0 },
            scale = Vector.scale(Vector(scale.x, scale.z, scale.y), 1.1),
        }
    })
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
    local count = 0
    for _, object in ipairs(self.zone.getObjects()) do
        local cardCount = Helper.getCardCount(object)
        if cardCount > 0 then
            count = count + cardCount
        else
            count = count + 1
        end
    end

    if count > 0 then
        local height = self.groundHeight + count * self.cardHeight
        local label = I18N("acquireButton") .. " (" .. tostring(count) .. ")"
        Helper.createExperimentalAreaButton(self.zone, self.anchor, height + 0.1, label, function (_, color)
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
