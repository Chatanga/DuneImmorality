local Module = require("utils.Module")
local Helper = require("utils.Helper")

local Action = Module.lazyRequire("Action")
local MainBoard = Module.lazyRequire("MainBoard")
local ImperiumRow = Module.lazyRequire("ImperiumRow")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")
local Combat = Module.lazyRequire("Combat")
local PlayBoard = Module.lazyRequire("PlayBoard")

local Leader = Helper.createClass(Action)

---
function Leader.newLeader(name)
    local LeaderClass = Leader[name]
    if not LeaderClass then
        -- Fanmade leader?
        LeaderClass = Helper.createClass(Leader, {})
    end
    assert(LeaderClass or name ~= "Hagal", "Active player must not choose the Green seat in test mode.")
    assert(LeaderClass, "Unknown leader: " .. tostring(name))
    LeaderClass.name = name
    return Helper.createClassInstance(LeaderClass)
end

Leader.vladimirHarkonnen = Helper.createClass(Leader, {

    --- Masterstroke
    prepare = function (color, settings)
        Action.prepare(color, settings)

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

    -- Masterstroke
    instruct = function (phase, isActivePlayer)
        if phase == "gameStart" then
            if isActivePlayer then
                return "Secretly choose 2 Factions."
            else
                return "Wait for vladimir Harkonnen\nto secretly choose\nits two factions."
            end
        else
            return Leader.instruct(phase, isActivePlayer)
        end
    end,

    --- Scheme
    signetRing = function (color)
        return Action.resources(color, "solari", -1) and Action.drawIntrigues(color, 1)
    end,
})

Leader.glossuRabban = Helper.createClass(Leader, {

    --- Arrakis fiefdom
    prepare = function (color, settings)
        Action.prepare(color, settings)
        Action.resources(color, "spice", 1)
        Action.resources(color, "solari", 1)
    end,

    --- Brutality
    signetRing = function (color)
        return Action.troops(color, "supply", "garrison", InfluenceTrack.hasAnyAlliance(color) and 2 or 1)
    end
})

Leader.ilbanRichese = Helper.createClass(Leader, {

    --- Manufacturing
    signetRing = function (color)
        Action.resources(color, "solari", 1)
    end,

    --- Ruthless negotiator
    resources = function (color, resourceName, amount)
        local success = Action.resources(color, resourceName, amount)
        log(success)
        log(Action.context)
        log(Action.checkContext({ phase = "playerTurns", color = color, space = MainBoard.isLandsraadSpace }))
        if success and amount < 0 and Action.checkContext({ phase = "playerTurns", color = color, space = MainBoard.isLandsraadSpace }) then
            Action.drawImperiumCards(color, 1)
        end
        return success
    end,
})

Leader.helenaRichese = Helper.createClass(Leader, {

    --- Eyes everywhere
    sendAgent = function (color, spaceName)
        -- TODO Manage accesses
        local force = MainBoard.isLandsraadSpace(spaceName) or MainBoard.isSpiceTradeSpace(spaceName)
        return Action.sendAgent(color, spaceName)
    end,

    --- Manipulate
    acquireImperiumCard = function (color, indexInRow)
        if Action.checkContext({ phase = "playerTurns", color = color }) and PlayBoard.couldSendAgentOrReveal(color) then
            return Action.reserveImperiumCard(color, indexInRow)
        else
            return Action.acquireImperiumCard(color, indexInRow)
        end
    end,

    --- Manipulate
    acquireReservedImperiumCard = function (color)
        if Action.checkContext({ phase = "playerTurns", color = color }) and not PlayBoard.couldSendAgentOrReveal(color) then
            return ImperiumRow.acquireReservedImperiumCard(color)
        else
            return Action.acquireReservedImperiumCard(color)
        end
    end
})

Leader.letoAtreides = Helper.createClass(Leader, {

    --- Landsraad popularity
    resources = function (color, resourceName, amount)
        local finalAmount = amount
        if resourceName == "solari" and amount < 0 and Action.checkContext({ phase = "playerTurns", color = color, space = MainBoard.isLandsraadSpace }) then
            finalAmount = amount + 1
        end
        return Action.resources(color, resourceName, finalAmount)
    end,
})

-- TODO Add a prescience button.
Leader.paulAtreides = Helper.createClass(Leader, {

    --- Prescience
    prepare = function (color, settings)
        Action.prepare(color, settings)
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
        return Action.resources(color, "water", 1)
    end,

    --- Spice addict
    sendAgent = function (color, spaceName)
        local continuation = Helper.createContinuation()
        Action.sendAgent(color, spaceName).doAfter(function (success)
            if success and MainBoard.isDesertSpace(spaceName) then
                Action.resources(color, "spice", -1)
                Action.drawImperiumCards(color, 1)
            end
            continuation.run(success)
        end)
        return continuation
    end,
})

Leader.memnonThorvald = Helper.createClass(Leader, {

    --- Connections
    sendAgent = function (color, spaceName)
        local continuation = Helper.createContinuation()
        Action.sendAgent(color, spaceName).doAfter(function (success)
            if success and spaceName == "highCouncil" then
                Action.influence(color, nil, 1)
            end
            continuation.run(success)
        end)
        return continuation
    end,

    --- Spice hoard
    signetRing = function (color, spaceName)
        return Action.resources(color, "spice", 1)
    end,
})

Leader.armandEcaz = Helper.createClass(Leader, {
})

Leader.ilesaEcaz = Helper.createClass(Leader, {

    --- Guild contacts
    signetRing = function (color)
        return Action.resources(color, "solari", -1) and Action.acquireFoldspace(color)
    end,

    --- One step ahead
    instruct = function (phase, isActivePlayer)
        if phase == "roundStart" then
            if isActivePlayer then
                return "Set aside a card\nfrom your hand."
            else
                return "Wait for Ilesa Ecaz\nto set aside a card\nfrom her hand."
            end
        else
            return Leader.instruct(phase, isActivePlayer)
        end
    end,
})

Leader.rhomburVernius = Helper.createClass(Leader, {

    --- Heavy lasgun cannons
    prepare = function (color, settings)
        Action.prepare(color, settings)
        Combat.setDreadnoughtStrength(color, 4)
    end
})

-- TODO Add automatic snooper recall.
Leader.tessiaVernius = Helper.createClass(Leader, {

    --- Careful observation
    prepare = function (color, settings)
        Action.prepare(color, settings)

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

    --- Smuggling operation
    prepare = function (color, settings)
        Action.prepare(color, settings)
        Action.resources(color, "water", -1)
    end,

    --- Smuggling operation
    resources = function (color, resourceName, amount)
        local finalAmount = amount
        if resourceName == "solari" and amount > 0 and Action.checkContext({ phase = "playerTurns", color = color }) then
            finalAmount = amount + 1
        end
        return Action.resources(color, resourceName, finalAmount)
    end,

    --- Final delivery
    signetRing = function (color)
        return Action.resources(color, "solari", -7)
            and Action.influence(color, nil, 1)
            and Action.troop(color, "supply", "garrison", 1)
            and Action.resources(color, "spice", 1)
    end,
})

Leader.hundroMoritani = Helper.createClass(Leader, {

    --- Intelligence
    prepare = function (color, settings)
        Action.prepare(color, settings)
        Wait.frames(function ()
            Action.drawIntrigues(color, 2)
        end, 1)
    end,

    --- Intelligence
    instruct = function (phase, isActivePlayer)
        if phase == "gameStart" then
            if isActivePlayer then
                return "Keep one intrigue\nand put the other\non top of the intrigue deck."
            else
                return "Wait for Hundro Moritani\nto choose between\nits two intrigues."
            end
        else
            return Leader.instruct(phase, isActivePlayer)
        end
    end,

    --- Couriers
    signetRing = function (color)
        return Action.resources(color, "spice", 1)
            and Action.shipments(color, 1)
    end
})

return Leader
