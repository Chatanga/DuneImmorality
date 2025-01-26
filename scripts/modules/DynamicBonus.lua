local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")

local Intrigue = Module.lazyRequire("Intrigue")
local Resource = Module.lazyRequire("Resource")
local Combat = Module.lazyRequire("Combat")
local TleilaxuResearch = Module.lazyRequire("TleilaxuResearch")
local MainBoard = Module.lazyRequire("MainBoard")

local DynamicBonus = {}

function DynamicBonus.createSpaceBonus(origin, bonuses, extraBonuses)
    if not DynamicBonus.tq then
        DynamicBonus.tq = Helper.createTemporalQueue()
    end

    local total = 0
    for _, targetBonuses in pairs(bonuses) do
        for category, description in pairs(targetBonuses) do
            if Helper.isElementOf(category, { "spice", "solari" }) then
                total = total + 1
            elseif category == "intrigue" then
                assert(description > 0)
                total = total + description
            elseif Helper.isElementOf(category, { "combatTroop", "garrisonTroop", "tankTroop", "combatDreadnought", "controlMarker" })  then
                total = total + #description
            else
                error("Unknown bonus type: " .. tostring(category))
            end
        end
    end

    local function toPosition(i)
        return origin + Vector((i - total / 2) * 0.5, 1, 0)
    end

    local i = 1
    for target, targetBonuses in pairs(bonuses) do
        extraBonuses[target] = {}
        for category, description in pairs(targetBonuses) do
            extraBonuses[target][category] = {}

            if Helper.isElementOf(category, { "spice", "solari" }) then
                assert(description > 0)
                local position = toPosition(i)
                DynamicBonus.tq.submit(function ()
                    local constructorName = Helper.toCamelCase("_create",  category, "token")
                    DynamicBonus[constructorName](position).doAfter(function (bonusToken)
                        Helper.onceMotionless(bonusToken).doAfter(function ()
                            Helper.noPlay(bonusToken)
                            local bonus = Resource.new(bonusToken, nil, category, 0, description)
                            table.insert(extraBonuses[target][category], bonus)
                        end)
                    end)
                end)
                i = i + 1

            elseif category == "intrigue" then
                assert(description > 0)
                for _ = 1, description do
                    local position = toPosition(i)
                    DynamicBonus.tq.submit(function ()
                        Helper.moveCardFromZone(Intrigue.deckZone, position, nil, false, true).doAfter(function (card)
                            table.insert(extraBonuses[target][category], card)
                            card.flip()
                            card.setScale(card.getScale():scale(0.2))
                            Helper.noPlay(card)
                        end)
                    end)
                    i = i + 1
                end

            elseif Helper.isElementOf(category, { "combatTroop", "garrisonTroop", "tankTroop", "combatDreadnought", "controlMarker" })  then
                for _, item in ipairs(description) do
                    local position = toPosition(i)
                    DynamicBonus.tq.submit(function ()
                        table.insert(extraBonuses[target][category], item)
                        item.setScale(item.getScale():scale(0.5))
                        item.setPosition(position)
                        Helper.onceMotionless(item).doAfter(function ()
                            Helper.noPlay(item)
                        end)
                    end)
                    i = i + 1
                end

            else
                error("Unknown bonus type: " .. tostring(category))
            end
        end
    end

    return extraBonuses
end

function DynamicBonus.collectExtraBonuses(color, leader, extraBonuses)
    for _, target in ipairs({ "all", color }) do
        local targetBonuses = extraBonuses[target]
        if targetBonuses then
            local newTargetBonuses = DynamicBonus._collectTargetBonuses(color, leader, targetBonuses)
            extraBonuses[target] = newTargetBonuses
        end
    end
end

function DynamicBonus._collectTargetBonuses(color, leader, targetBonuses)
    local intrigueAlreadyTaken = false
    local remainingTargetBonuses = {}
    for category, items in pairs(targetBonuses) do
        local remainingItems = {}
        for _, item in ipairs(items) do
            if Helper.isElementOf(category, { "spice", "solari" }) then
                leader.resources(color, category, item:get())
                item.token.destruct()

            elseif category == "intrigue" then
                if not intrigueAlreadyTaken then
                    Helper.physicsAndPlay(item)
                    -- Add an offset to put the card on the left side of the player's hand.
                    local position = Player[color].getHandTransform().position + Vector(-7.5, 0, 0)
                    item.setPosition(position)
                    item.setScale(item.getScale():scale(5))
                    item.flip()
                    intrigueAlreadyTaken = true
                else
                    table.insert(remainingItems, item)
                    break
                end

            elseif Helper.isElementOf(category, { "combatTroop", "garrisonTroop", "tankTroop", "combatDreadnought" })  then
                Helper.physicsAndPlay(item)
                local toPark
                if category == "combatTroop" or category == "combatDreadnought" then
                    toPark = Combat.getBattlegroundPark(color)
                elseif category == "garrisonTroop" then
                    toPark = Combat.getGarrisonPark(color)
                elseif category == "tankTroop" then
                    toPark = TleilaxuResearch.getTankPark(color)
                end
                Park.putObject(item, toPark)
                item.setScale(item.getScale():scale(2))

            elseif category == "controlMarker"  then
                Helper.physicsAndPlay(item)

                local p = Vector(0, 0, 0)
                for _, zoneName in ipairs({ "imperialBasinBannerZone", "arrakeenBannerZone", "carthagBannerZone" }) do
                    p = p + MainBoard.banners[zoneName].getPosition()
                end
                p:scale(1/3)
                item.setPosition(p)
                item.setScale(item.getScale():scale(2))
            else
                error("Unknown bonus type: " .. tostring(category))
            end
        end
        if #remainingItems > 0 then
            remainingTargetBonuses[category] = remainingItems
        end
    end
    return #Helper.getKeys(remainingTargetBonuses) > 0 and remainingTargetBonuses or nil
end

function DynamicBonus.createSpiceToken(position)
    local data = {
        Name = "Custom_Token",
        Transform = {
            posX = 0,
            posY = 0,
            posZ = 0,
            rotX = 0,
            rotY = 180,
            rotZ = 0,
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
        Locked = false,
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
            ImageURL = "https://steamusercontent-a.akamaihd.net/ugc/2502404390141340823/E7FD36CE3B3F6E6BF22E8ED1096644A381ECC426/",
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

    local continuation = Helper.createContinuation("DynamicBonus._createSpiceToken")
    spawnObjectData({
        data = data,
        position = position,
        scale = Vector(0.125, 0.25, 0.125),
        callback_function = continuation.run
    })

    return continuation
end

function DynamicBonus.createSolariToken(position)
    local data = {
        Name = "Custom_Token",
        Transform = {
            posX = 0,
            posY = 0,
            posZ = 0,
            rotX = 0,
            rotY = 180,
            rotZ = 0,
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
        Locked = false,
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
            ImageURL = "https://steamusercontent-a.akamaihd.net/ugc/2502404390141340069/CB54F21A0AF3E4CBFF3EC93D5E40D432CF6BC856/",
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

    local continuation = Helper.createContinuation("DynamicBonus._createSolariToken")
    spawnObjectData({
        data = data,
        position = position,
        scale = Vector(0.125, 0.25, 0.125),
        callback_function = continuation.run
    })

    return continuation
end

return DynamicBonus
