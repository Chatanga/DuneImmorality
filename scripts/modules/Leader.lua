local Module = require("utils.Module")
local Helper = require("utils.Helper")

local Action = Module.lazyRequire("Action")
local MainBoard = Module.lazyRequire("MainBoard")
local ImperiumRow = Module.lazyRequire("ImperiumRow")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")
local Combat = Module.lazyRequire("Combat")

local Leader = Helper.createClass(Action)

---
function Leader.getLeader(name)
    local LeaderClass = Leader[name]
    assert(LeaderClass, "Unknown leader: " .. tostring(name))
    return Helper.createClassInstance(LeaderClass)
end

Leader.vladimirHarkonnen = Helper.createClass(Leader, {

    setUp = function (color, epic)
        Action.setUp(color, epic)

        --- Masterstroke
        local position = Player[color].getHandTransform().position
        local tokenBag = getObjectFromGUID('f89231')
        local tokenCount = #tokenBag.getObjects()
        for _ = 1, tokenCount do
            tokenBag.takeObject({
                position = position,
                callback_function = function (token)
                    token.flip()
                end
            })
        end
        Wait.frames(function ()
            tokenBag.destruct()
        end, 1)
    end,

    tearDown = function()
        local tokenBag = getObjectFromGUID('f89231')
        tokenBag.destruct()
    end,

    instruct = function (phase, color)
        -- Masterstroke
        if phase == "gameStart" then
            return "Secretly choose 2 Factions."
        end
    end,

    --- Scheme
    signetRing = function (color)
        return Action.resource(color, "solari", -1) and Action.drawIntrigues(color, 1)
    end,
})

Leader.glossuRabban = Helper.createClass(Leader, {

    --- Arrakis fiefdom
    setUp = function (color, epic)
        Action.setUp(color, epic)
        Action.resource(color, "spice", 1)
        Action.resource(color, "solari", 1)
    end,

    --- Brutality
    signetRing = function (color)
        return Action.troops(color, "supply", "garrison", InfluenceTrack.hasAnyAlliance(color) and 2 or 1)
    end
})

Leader.ilbanRichese = Helper.createClass(Leader, {

    --- Manufacturing
    signetRing = function (color)
        Action.resource(color, "solari", 1)
    end,

    --- Ruthless negotiator
    resource = function (color, resourceName, amount)
        local success = Action.resource(color, resourceName, amount)
        if success and amount < 0 and Action.checkContext({ phase = "playerTurns", color = color, space = MainBoard.isLandsraadSpace }) then
            Action.drawImperiumCards(color, 1)
        end
        return success
    end,
})

Leader.helenaRichese = Helper.createClass(Leader, {

    --- Manipulate
    acquireReservedImperiumCard = function (color, resourceName, amount)
        return ImperiumRow.acquireReservedImperiumCard(color)
    end,

    --- Eyes everywhere
    sendAgent = function (color, spaceName)
        -- TODO Manage accesses
        local force = MainBoard.isLandsraadSpace(spaceName) or MainBoard.isSpiceTradeSpace(spaceName)
        return Action.sendAgent(color, spaceName)
    end,
})

Leader.letoAtreides = Helper.createClass(Leader, {

    --- Landsraad popularity
    resource = function (color, resourceName, amount)
        local finalAmount = amount
        if resourceName == "solari" and amount < 0 and Action.checkContext({ phase = "playerTurns", color = color, space = MainBoard.isLandsraadSpace }) then
            finalAmount = amount + 1
        end
        return Action.resource(color, resourceName, finalAmount)
    end,
})

Leader.paulAtreides = Helper.createClass(Leader, {

    --- Prescience
    setUp = function (color, epic)
        Action.setUp(color, epic)
        -- TODO Add prescience button
    end,

    --- Discipline
    signetRing = function (color)
        return Action.drawImperiumCards(color, 1)
    end,
})

Leader.arianaThorvald = Helper.createClass(Leader, {

    --- Hidden reservoir
    signetRing = function (color)
        return Action.resource(color, "water", 1)
    end,

    --- Spice addict
    sendAgent = function (color, spaceName)
        if Action.sendAgent(color, spaceName) then
            if MainBoard.isDesertSpace(spaceName) then
                Action.resource(color, "spice", -1)
                Action.drawImperiumCards(color, 1)
            end
            return true
        else
            return false
        end
    end,
})

Leader.memnonThorvald = Helper.createClass(Leader, {

    --- Connections
    sendAgent = function (color, spaceName)
        if Action.sendAgent(color, spaceName) then
            if spaceName == "highCouncil" then
                Action.influence(color, nil, 1)
            end
            return true
        else
            return false
        end
    end,

    --- Spice hoard
    signetRing = function (color, spaceName)
        return Action.resource(color, "spice", 1)
    end,
})

Leader.ilesaEcaz = Helper.createClass(Leader, {

    --- Guild contacts
    signetRing = function (color)
        return Action.resource(color, "solari", -1) and Action.acquireFoldspaceCard(color)
    end,

    instruct = function (phase, color)
        --- One step ahead
        if phase == "roundStart" then
            if Action.context.color == color then
                return "Set aside a card\nfrom your hand."
            else
                return "Wait for Ilesa Ecaz\nto set aside a card\nfrom her hand."
            end
        else
            return Leader.instruct(phase, color)
        end
    end,
})

Leader.rhomburVernius = Helper.createClass(Leader, {

    --- Heavy lasgun cannons
    setUp = function (color, epic)
        Action.setUp(color, epic)
        Combat.setDreadnoughtStrength(color, 4)
    end
})

Leader.tessiaVernius = Helper.createClass(Leader, {

    setUp = function (color, epic)
        Action.setUp(color, epic)

        local getAveragePosition = function (spaceNames)
            local p = Vector(0, 0, 0)
            local count = 0
            for _, spaceName in ipairs(spaceNames) do
                p = p + MainBoard.spaces[spaceName].zone.getPosition()
                count = count + 1
            end
            return p * (1 / count)
        end

        local snoopers = {
            { guid = "a58ce8", position = getAveragePosition({ "conspire", "wealth" })},
            { guid = "857f74", position = getAveragePosition({ "heighliner", "foldspace" })},
            { guid = "bed196", position = getAveragePosition({ "selectiveBreeding", "secrets" })},
            { guid = "b10897", position = getAveragePosition({ "hardyWarriors", "stillsuits" })},
        }

        for _, snooper in ipairs(snoopers) do
            local object = getObjectFromGUID(snooper.guid)
            object.setPositionSmooth(snooper.position, false, false)
            object.setRotationSmooth(Vector(0, 90, 0))
        end
    end,

    tearDown = function ()
        local snoopers = {
            "a58ce8",
            "857f74",
            "bed196",
            "b10897",
        }

        for _, guid in ipairs(snoopers) do
            local object = getObjectFromGUID(guid)
            object.destruct()
        end
    end,

    --- Duplicity
    signetRing = function (color)
        Action.influence(color, nil, -1)
        Action.influence(color, nil, 1)
    end,
})

Leader.yunaMoritani = Helper.createClass(Leader, {

    ---
    signetRing = function (color)
        return Action.resource(color, "solari", -7)
            and Action.influence(color, nil, 1)
            and Action.troop(color, "supply", "garrison", 1)
            and Action.resource(color, "spice", 1)
    end,

    --- Smuggling operation
    setUp = function (color, epic)
        Action.setUp(color, epic)
        Action.resource(color, "water", -1)
    end,
})

Leader.yunaMoritani = Helper.createClass(Leader, {

    -- Final delivery
    resource = function (color, resourceName, amount)
        local finalAmount = amount
        if resourceName == "solari" and amount > 0 and Action.checkContext({ phase = "playerTurns", color = color }) then
            finalAmount = amount + 1
        end
        return Action.resource(color, resourceName, finalAmount)
    end,
})

Leader.hundroMoritani = Helper.createClass(Leader, {

    --- Intelligence
    setUp = function (color, epic)
        Action.setUp(color, epic)
        Wait.frames(function ()
            Action.drawIntrigues(color, 2)
        end, 1)
    end,

    instruct = function (phase, color)
        -- Intelligence
        if phase == "gameStart" then
            return "Keep one intrigue and put the other on top of the intrigue deck."
        end
    end,

    --- Couriers
    signetRing = function (color)
        return Action.resource(color, "spice", 1)
            and Action.cargo(color, nil, 1)
    end
})

return Leader
