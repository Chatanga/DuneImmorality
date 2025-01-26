local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

---@class AcquireCard
---@field UPDATE_EVENT_NAME string
---@field CARD_HEIGHT number
---@field anchor Object
---@field zone Zone
---@field groundHeight number
---@field acquire fun(acquireCard: AcquireCard, color: PlayerColor)
local AcquireCard = Helper.createClass(nil, {
    UPDATE_EVENT_NAME = "AcquireCard/objectEnterOrLeaveScriptingZone",
    CARD_HEIGHT = 0.01
})

--[[
    Create a dynamic anchored button with a decal and a snap point for a deck
    in a given zone.

    If no callback is provided, no button is created. The decals is optional too
    and only the snap point will be created if both the callback and the decal
    are not provided.

    If created, the button is dynamic and its location is changed to match the
    top of the deck (see AcquireCard.CARD_HEIGHT) and its tooltip will display
    the card count. In case the deck is missing, the button is simply hidden and
    adding one or more cards in the zone will make it reappears.

    Finally, if the callback returns a continuation, the button will be disabled
    until its end.
]]
---@param zone table The zone where the deck is located.
---@param groundHeight integer The absolute coordinate Y where the deck lies.
---@param tag string A required tag for the deck.
---@param acquire? fun(acquireCard: AcquireCard, color: PlayerColor) A callback called when the button is pressed.
---@param decalUrl? string An URL for a decal to decorate the deck location.
---@return AcquireCard The created AquireCard (useful to help the callback know who has called it).
function AcquireCard.new(zone, groundHeight, tag, acquire, decalUrl)
    assert(zone)
    assert(groundHeight)
    assert(tag)

    local acquireCard = Helper.createClassInstance(AcquireCard, {
        zone = zone,
        groundHeight = groundHeight,
        anchor = nil,
        cardCount = 0,
        acquire = acquire,
    })

    zone.setTags({ tag })

    local position = Helper.onGround(zone.getPosition(), groundHeight)
    Helper.createTransientAnchor("AcquireCard", position - Vector(0, 0.5, 0)).doAfter(function (anchor)
        acquireCard.anchor = anchor

        local snapPoint = {
            position =  anchor.positionToLocal(position),
            rotation_snap = true,
            tags = { tag }
        }
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

function AcquireCard:_updateButton()
    self:_createButton()
end

---@param decalUrl string
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

---@param zone Zone
---@param object Object
function AcquireCard.onObjectEnterZone(zone, object)
    if Helper.isNil(zone) or Helper.isNil(object) then
        return
    end
    Helper.emitEvent(AcquireCard.UPDATE_EVENT_NAME, zone, object)
end

---@param zone Zone
---@param object Object
function AcquireCard.onObjectLeaveZone(zone, object)
    if Helper.isNil(zone) or Helper.isNil(object) then
        return
    end
    Helper.emitEvent(AcquireCard.UPDATE_EVENT_NAME, zone, object)
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
            local height = self.groundHeight + 0.1 + count * AcquireCard.CARD_HEIGHT
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
                    -- The acquisition may not involve a smooth move
                    -- (i.e. with a corresponding onObjectLeaveZone event).
                    self:_updateButton()
                end
            end)
        end
    end
end

return AcquireCard
