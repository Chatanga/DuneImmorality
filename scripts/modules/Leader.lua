local Module = require("utils.Module")
local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

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
        Helper.onceFramesPassed(1).doAfter(function ()
            tokenBag.destruct()
        end)
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
        local leader = PlayBoard.getLeader(color)
        return leader.resources(color, "solari", -1) and Action.drawIntrigues(color, 1)
    end,
})

Leader.glossuRabban = Helper.createClass(Leader, {

    --- Arrakis fiefdom
    prepare = function (color, settings)
        Action.prepare(color, settings)
        local leader = PlayBoard.getLeader(color)
        leader.resources(color, "spice", 1)
        leader.resources(color, "solari", 1)
    end,

    --- Brutality
    signetRing = function (color)
        local leader = PlayBoard.getLeader(color)
        return leader.troops(color, "supply", "garrison", InfluenceTrack.hasAnyAlliance(color) and 2 or 1)
    end
})

Leader.ilbanRichese = Helper.createClass(Leader, {

    --- Manufacturing
    signetRing = function (color)
        local leader = PlayBoard.getLeader(color)
        leader.resources(color, "solari", 1)
    end,

    --- Ruthless negotiator
    resources = function (color, resourceName, amount)
        local success = Action.resources(color, resourceName, amount)
        if success and amount < 0 and Action.checkContext({ phase = "playerTurns", color = color, space = MainBoard.isLandsraadSpace }) then
            local leader = PlayBoard.getLeader(color)
            leader.drawImperiumCards(color, 1)
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
        local leader = PlayBoard.getLeader(color)
        if Action.checkContext({ phase = "playerTurns", color = color }) and PlayBoard.couldSendAgentOrReveal(color) then
            return leader.reserveImperiumCard(color, indexInRow)
        else
            return leader.acquireImperiumCard(color, indexInRow)
        end
    end,

    --- Manipulate
    acquireReservedImperiumCard = function (color)
        if Action.checkContext({ phase = "playerTurns", color = color }) and not PlayBoard.couldSendAgentOrReveal(color) then
            return ImperiumRow.acquireReservedImperiumCard(color)
        else
            local leader = PlayBoard.getLeader(color)
            return leader.acquireReservedImperiumCard(color)
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
        local leader = PlayBoard.getLeader(color)
        return leader.resources(color, resourceName, finalAmount)
    end,
})

Leader.paulAtreides = Helper.createClass(Leader, {

    --- Prescience
    prepare = function (color, settings)
        Action.prepare(color, settings)

        local prescience = function (_, otherColor)
            if otherColor == color then
                local cardOrDeck = PlayBoard.getDrawDeck(color)
                if cardOrDeck == nil then
                    broadcastToColor(I18N("prescienceVoid"), color, "Purple")
                elseif cardOrDeck.type == "Card" then
                    --broadcastToAll(I18N("prescienceUsed"), color)
                    broadcastToColor(I18N("prescienceManual"), color, "Purple")
                else
                    cardOrDeck.Container.search(color, 1)
                    --broadcastToAll(I18N("prescienceUsed"), color)
                end
            else
                broadcastToColor(I18N("noTouch"), otherColor, otherColor)
            end
        end

        local leaderCard = PlayBoard.findLeaderCard(color)

        -- FIXME The leader card position is a bit weird.
        Helper.createTransientAnchor("PrescienceAnchor", leaderCard.getPosition() + Vector(0, -0.5, 0)).doAfter(function (anchor)
            Helper.createAbsoluteButtonWithRoundness(anchor, 1, false, {
                click_function = Helper.registerGlobalCallback(prescience),
                label = I18N("prescienceButton"),
                position = anchor.getPosition() + Vector(0, 0.55, -1.75),
                width = 1200,
                height = 280,
                font_size = 200,
                scale = Vector(1, 1, 1),
                color = { 0, 0, 0, 1 },
                font_color = Color.fromString("White"),
                tooltip = I18N("prescienceTooltip"),
            })
        end)
   end,

    --- Discipline
    signetRing = function (color)
        local leader = PlayBoard.getLeader(color)
        return leader.drawImperiumCards(color, 1)
    end,
})

Leader.arianaThorvald = Helper.createClass(Leader, {

    --- Hidden reservoir
    signetRing = function (color)
        local leader = PlayBoard.getLeader(color)
        return leader.resources(color, "water", 1)
    end,

    --- Spice addict
    sendAgent = function (color, spaceName)
        local continuation = Helper.createContinuation()
        Action.sendAgent(color, spaceName).doAfter(function (success)
            if success and MainBoard.isDesertSpace(spaceName) then
                local leader = PlayBoard.getLeader(color)
                leader.resources(color, "spice", -1)
                leader.drawImperiumCards(color, 1)
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
                local leader = PlayBoard.getLeader(color)
                leader.influence(color, nil, 1)
            end
            continuation.run(success)
        end)
        return continuation
    end,

    --- Spice hoard
    signetRing = function (color, spaceName)
        local leader = PlayBoard.getLeader(color)
        return leader.resources(color, "spice", 1)
    end,
})

Leader.armandEcaz = Helper.createClass(Leader, {
})

Leader.ilesaEcaz = Helper.createClass(Leader, {

    --- Guild contacts
    signetRing = function (color)
        local leader = PlayBoard.getLeader(color)
        return leader.resources(color, "solari", -1) and Action.acquireFoldspace(color)
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

Leader.tessiaVernius = Helper.createClass(Leader, {

    --- Careful observation
    prepare = function (color, settings)
        Action.prepare(color, settings)

        InfluenceTrack.setUpSnoopers()

        local leaderCard = PlayBoard.findLeaderCard(color)
        local snapPoints = {}
        for i = 1, 4 do
            local p = leaderCard.getPosition() + Vector(i / 4 - 2, 0, 1.4 - i / 2)
            table.insert(snapPoints, {
                position = leaderCard.positionToLocal(p),
                tags = { "Snooper" }
            })
        end
        leaderCard.setSnapPoints(snapPoints)
    end,

    tearDown = function ()
        InfluenceTrack.tearDownSnoopers()
    end,

    --- Careful observation
    influence = function (color, faction, amount)
        local noFriendshipBefore = not InfluenceTrack.hasFriendship(color, faction)
        local continuation = Helper.createContinuation()
        Action.influence(color, faction, amount).doAfter(function ()
            local friendshipAfter = InfluenceTrack.hasFriendship(color, faction)
            if noFriendshipBefore and friendshipAfter then
                InfluenceTrack.recallSnooper(faction, color)
            end
        end)
        return continuation
    end,

    --- Duplicity
    signetRing = function (color)
        local leader = PlayBoard.getLeader(color)
        leader.influence(color, nil, -1)
        leader.influence(color, nil, 1)
    end,

})

Leader.yunaMoritani = Helper.createClass(Leader, {

    --- Smuggling operation
    prepare = function (color, settings)
        Action.prepare(color, settings)
        local leader = PlayBoard.getLeader(color)
        leader.resources(color, "water", -1)
    end,

    --- Smuggling operation
    resources = function (color, resourceName, amount)
        local finalAmount = amount
        if resourceName == "solari" and amount > 0 and Action.checkContext({ phase = "playerTurns", color = color }) then
            finalAmount = amount + 1
        end
        local leader = PlayBoard.getLeader(color)
        return leader.resources(color, resourceName, finalAmount)
    end,

    --- Final delivery
    signetRing = function (color)
        local leader = PlayBoard.getLeader(color)
        return leader.resources(color, "solari", -7)
            and leader.influence(color, nil, 1)
            and leader.troop(color, "supply", "garrison", 1)
            and leader.resources(color, "spice", 1)
    end,
})

Leader.hundroMoritani = Helper.createClass(Leader, {

    --- Intelligence
    prepare = function (color, settings)
        Action.prepare(color, settings)
        Helper.onceFramesPassed(1).doAfter(function ()
            local leader = PlayBoard.getLeader(color)
            leader.drawIntrigues(color, 2)
        end)
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
        local leader = PlayBoard.getLeader(color)
        return leader.resources(color, "spice", -1)
            and leader.shipments(color, 1)
    end
})

return Leader
