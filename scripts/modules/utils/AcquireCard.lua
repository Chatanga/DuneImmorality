local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

local AcquireCard = Helper.createClass(nil, {
    UPDATE_EVENT_NAME = "AcquireCard/objectEnterOrLeaveScriptingZone",
})

---
function AcquireCard.new(zone, tag, acquire, decalUrl)
    local acquireCard = Helper.createClassInstance(AcquireCard, {
        zone = zone,
        groundHeight = 1.65,
        cardHeight = 0.01,
        anchor = nil,
        cardCount = -1,
        acquire = acquire,
    })

    zone.addTag(tag)

    local position = zone.getPosition() - Vector(0, 0.5, 0)
    Helper.createTransientAnchor("AcquireCard", position).doAfter(function (anchor)
        acquireCard.anchor = anchor

        local snapPoint = Helper.createRelativeSnapPointFromZone(anchor, zone, true, { tag })
        anchor.setSnapPoints({ snapPoint })

        if acquire then
            acquireCard:_updateButton()

            Helper.registerEventListener("locale", function ()
                acquireCard:_updateButton()
            end)

            Helper.registerEventListener(AcquireCard.UPDATE_EVENT_NAME, function (otherZone)
                if otherZone == zone then
                    acquireCard:_updateButton()
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
function AcquireCard:_updateButton()
    if false then
        if not self.updateCoalescentQueue then

            local function coalesce(_, _)
                return true
            end

            local function handle(_)
                self:_createButton()
            end

            self.updateCoalescentQueue = Helper.createCoalescentQueue("acquire", 0.5, coalesce, handle)
        end
        self.updateCoalescentQueue.submit(true)
    else
        self:_createButton()
    end
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
function AcquireCard.onObjectEnterZone(...)
    Helper.emitEvent(AcquireCard.UPDATE_EVENT_NAME, ...)
end

---
function AcquireCard.onObjectLeaveZone(...)
    Helper.emitEvent(AcquireCard.UPDATE_EVENT_NAME, ...)
end

function AcquireCard:_createButton()
    local count = 0
    for _, object in ipairs(self.zone.getObjects()) do
        local cardCount = Helper.getCardCount(object)
        count = count + math.max(1, cardCount)
    end

    if self.cardCount ~= count then
        Helper.clearButtons(self.anchor)
        self.cardCount = count
        if count > 0 then
            local height = self.groundHeight + count * self.cardHeight
            local label = I18N("acquireButton") .. " (" .. tostring(count) .. ")"
            Helper.createExperimentalAreaButton(self.zone, self.anchor, height, label, function (_, color)
                if not self.disabled then
                    local continuation = self.acquire(self, color)
                    if continuation then
                        self.disabled = true
                        continuation.doAfter(function ()
                            self.disabled = false
                        end)
                    end
                    -- The acquisition may not involve a smooth move.
                    self:_updateButton()
                end
            end)
        end
    end
end

return AcquireCard
