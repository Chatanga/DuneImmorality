local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")

local Intrigue = Module.lazyRequire("Intrigue")
local Resource = Module.lazyRequire("Resource")
local PlayBoard = Module.lazyRequire("PlayBoard")
local Utils = require("Utils")

local DynamicBonus = {}

---
function DynamicBonus.collectExtraBonuses(color, leader, extraBonuses)
    -- TODO
end

function DynamicBonus.addSpaceBonus(origin, bonuses)
    --[[
    local troops = Park.getObjects(PlayBoard.getSupplyPark("Yellow"))
    local controlMarkers = PlayBoard.getControlMarkerBag("Red").getObjects()
    local dreadnoughts = Park.getObjects(PlayBoard.getDreadnoughtPark("Green"))
    bonuses2 = {
        all = {
            "spice",
            "spice",
            "solari",
            "solari",
        },
        Yellow = {
            "solari",
            troops[1],
            troops[2],
        },
        Red = {
            "intrigue",
            --controlMarkers[1],
        },
        Green = {
            dreadnoughts[1],
        }
    }
    ]]--

    local realBonuses = {}

    local bonusContinuations = {}
    local i = 0
    for target, targetBonuses in pairs(bonuses) do
        realBonuses[target] = {}
        for _, targetBonus in ipairs(targetBonuses) do
            assert(targetBonus)
            local position = origin + Vector(i * 0.4, 0, 0)
            if Helper.isElementOf(targetBonus, { "spice", "solari" }) then
                if not bonusContinuations[targetBonus] then
                    bonusContinuations[targetBonus] = Helper.createContinuation()
                    local constructorName = Helper.toCamelCase("create",  targetBonus, "token")
                    DynamicBonus[constructorName](position).doAfter(function (bonusToken)
                        table.insert(realBonuses[target], bonusToken)
                        Helper.noPlay(bonusToken)
                        local bonus = Resource.new(bonusToken, nil, targetBonus, 1)
                        bonusContinuations[targetBonus].run(bonus)
                    end)
                    i = i + 1
                else
                    bonusContinuations[targetBonus].doAfter(function (bonus)
                        bonus:change(1)
                    end)
                end
            elseif targetBonus == "intrigue" then
                local spawnIntrigue = function (continuation)
                    Helper.moveCardFromZone(Intrigue.deckZone, position, nil, false, true).doAfter(function (card)
                        table.insert(realBonuses[target], card)
                        card.flip()
                        local scale = card.getScale()
                        scale:scale(0.2)
                        card.setScale(scale)
                        card.setPosition(position)
                        Helper.noPlay(card)
                        continuation.run()
                    end)
                end
                if bonusContinuations[targetBonus] then
                    bonusContinuations[targetBonus].doAfter(function ()
                        bonusContinuations[targetBonus] = Helper.createContinuation()
                        spawnIntrigue(bonusContinuations[targetBonus])
                    end)
                else
                    bonusContinuations[targetBonus] = Helper.createContinuation()
                    spawnIntrigue(bonusContinuations[targetBonus])
                end
                i = i + 1
            elseif type(targetBonus) == "string" then
                error("Unknown bonus type: " .. tostring(targetBonus))
            else
                table.insert(realBonuses[target], targetBonus)
                local scale = targetBonus.getScale()
                scale:scale(0.5)
                targetBonus.setScale(scale)
                targetBonus.setPosition(position)
                Helper.onceMotionless(targetBonus).doAfter(function ()
                    Helper.noPlay(targetBonus)
                end)
                i = i + 1
            end
        end
    end

    return realBonuses
end

---
function DynamicBonus.createSpiceToken(position)
    local data = {
        Name = "Custom_Token",
        Transform = {
            posX = 0,
            posY = 0,
            posZ = 0,
            rotX = 0.0,
            rotY = 180.0,
            rotZ = 0.0,
            scaleX = 0.5,
            scaleY = 1.0,
            scaleZ = 0.5
        },
        ColorDiffuse = {
            r = 1.0,
            g = 1.0,
            b = 1.0
        },
        LayoutGroupSortIndex = 0,
        Value = 0,
        Locked = true,
        Grid = true,
        Snap = true,
        IgnoreFoW = false,
        MeasureMovement = false,
        DragSelectable = true,
        Autoraise = true,
        Sticky = true,
        Tooltip = false,
        GridProjection = false,
        HideWhenFaceDown = false,
        Hands = false,
        CustomImage = {
            ImageURL = "http://cloud-3.steamusercontent.com/ugc/1771572672508102528/E7FD36CE3B3F6E6BF22E8ED1096644A381ECC426/",
            ImageSecondaryURL = "",
            ImageScalar = 1.0,
            WidthScale = 0.0,
            CustomToken = {
                Thickness = 0.1,
                MergeDistancePixels = 5.0,
                StandUp = false,
                Stackable = false
            }
        }
    }

    local continuation = Helper.createContinuation()
    spawnObjectData({
        data = data,
        position = position,
        scale = Vector(0.125, 0.25, 0.125),
        callback_function = continuation.run
    })

    return continuation
end

---
function DynamicBonus.createSolariToken(position)
    local data = {
        Name = "Custom_Token",
        Transform = {
            posX = -17.0,
            posY = 1.16176772,
            posZ = 14.5,
            rotX = 0.0,
            rotY = 180.0,
            rotZ = 0.0,
            scaleX = 0.5,
            scaleY = 1.0,
            scaleZ = 0.5
        },
        ColorDiffuse = {
            r = 1.0,
            g = 1.0,
            b = 1.0
        },
        LayoutGroupSortIndex = 0,
        Value = 0,
        Locked = true,
        Grid = true,
        Snap = true,
        IgnoreFoW = false,
        MeasureMovement = false,
        DragSelectable = true,
        Autoraise = true,
        Sticky = true,
        Tooltip = false,
        GridProjection = false,
        HideWhenFaceDown = false,
        Hands = false,
        CustomImage = {
            ImageURL = "http://cloud-3.steamusercontent.com/ugc/1771572672508112083/CB54F21A0AF3E4CBFF3EC93D5E40D432CF6BC856/",
            ImageSecondaryURL = "",
            ImageScalar = 1.0,
            WidthScale = 0.0,
            CustomToken = {
                Thickness = 0.1,
                MergeDistancePixels = 5.0,
                StandUp = false,
                Stackable = false
            }
        }
    }

    local continuation = Helper.createContinuation()
    spawnObjectData({
        data = data,
        position = position,
        scale = Vector(0.125, 0.25, 0.125),
        callback_function = continuation.run
    })

    return continuation
end

return DynamicBonus
