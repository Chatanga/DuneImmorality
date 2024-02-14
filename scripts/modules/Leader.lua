local Module = require("utils.Module")
local Helper = require("utils.Helper")
local I18N = require("utils.I18N")
local Dialog = require("utils.Dialog")

local Action = Module.lazyRequire("Action")
local MainBoard = Module.lazyRequire("MainBoard")
local ImperiumRow = Module.lazyRequire("ImperiumRow")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")
local PlayBoard = Module.lazyRequire("PlayBoard")
local Combat = Module.lazyRequire("Combat")
local ChoamContractMarket = Module.lazyRequire("ChoamContractMarket")
local Deck = Module.lazyRequire("Deck")

local Leader = Helper.createClass(Action)

---
function Leader.newLeader(name)
    local LeaderClass = Leader[name]
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

    tearDown = function ()
        local tokenBag = getObjectFromGUID('f89231')
        tokenBag.destruct()
    end,

    --- Scheme
    signetRing = function (color)
        local leader = PlayBoard.getLeader(color)
        return leader.resources(color, "solari", -1) and Action.drawIntrigues(color, 1)
    end
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
        if success
        and resourceName == "solari"
        and amount < 0
        and Action.checkContext({ phase = "playerTurns", color = color, space = MainBoard.isLandsraadSpace }) then
            local leader = PlayBoard.getLeader(color)
            leader.drawImperiumCards(color, 1)
        end
        return success
    end
})

Leader.helenaRichese = Helper.createClass(Leader, {

    --- Eyes everywhere
    sendAgent = function (color, spaceName, recallSpy)
        -- TODO Manage accesses
        local force = MainBoard.isLandsraadSpace(spaceName) or MainBoard.isSpiceTradeSpace(spaceName)
        return Action.sendAgent(color, spaceName, recallSpy)
    end,

    --- Manipulate
    acquireImperiumCard = function (color, indexInRow)
        local leader = PlayBoard.getLeader(color)
        if Action.checkContext({ phase = "playerTurns", color = color }) and PlayBoard.couldSendAgentOrReveal(color) then
            return leader.reserveImperiumCard(color, indexInRow)
        else
            return Action.acquireImperiumCard(color, indexInRow)
        end
    end,

    --- Manipulate
    acquireReservedImperiumCard = function (color)
        --- Be nice.
        if false then
            if Action.checkContext({ phase = "playerTurns", color = color }) and not PlayBoard.couldSendAgentOrReveal(color) then
                return ImperiumRow.acquireReservedImperiumCard(color)
            else
                return Action.acquireReservedImperiumCard(color)
            end
        else
            return ImperiumRow.acquireReservedImperiumCard(color)
        end
    end
})

Leader.letoAtreides = Helper.createClass(Leader, {

    --- Landsraad popularity
    bargain = function (color, resourceName, amount)
        local finalAmount = amount
        if resourceName == "solari" and amount < 0 and Action.checkContext({ phase = "playerTurns", color = color, space = MainBoard.isLandsraadSpace }) then
            finalAmount = amount + 1
        end
        return finalAmount
    end
})

Leader.paulAtreides = Helper.createClass(Leader, {

    --- Prescience
    setUp = function (color, settings)
        Leader.paulAtreides.transientSetUp(color, settings)
    end,

    --- Prescience
    transientSetUp = function (color, settings)
        local prescience = function (_, otherColor)
            if otherColor == color then
                local cardOrDeck = PlayBoard.getDrawDeck(color)
                if cardOrDeck == nil then
                    Dialog.broadcastToColor(I18N("prescienceVoid"), color, "White")
                elseif cardOrDeck.type == "Card" then
                    --broadcastToAll(I18N("prescienceUsed"), color)
                    Dialog.broadcastToColor(I18N("prescienceManual"), color, "White")
                else
                    cardOrDeck.Container.search(color, 1)
                    --broadcastToAll(I18N("prescienceUsed"), color)
                end
            else
                Dialog.broadcastToColor(I18N("noTouch"), otherColor, "White")
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
                font_color = Color.fromString("Purple"),
                tooltip = I18N("prescienceTooltip"),
            })
        end)
    end,

    --- Discipline
    signetRing = function (color)
        local leader = PlayBoard.getLeader(color)
        return leader.drawImperiumCards(color, 1)
    end
})

Leader.arianaThorvald = Helper.createClass(Leader, {

    --- Hidden reservoir
    signetRing = function (color)
        local leader = PlayBoard.getLeader(color)
        return leader.resources(color, "water", 1)
    end,

    --- Spice addict
    sendAgent = function (color, spaceName, recallSpy)
        local continuation = Helper.createContinuation("Leader.arianaThorvald.sendAgent")
        Action.sendAgent(color, spaceName, recallSpy).doAfter(function ()
            if MainBoard.isDesertSpace(spaceName) then
                local leader = PlayBoard.getLeader(color)
                leader.resources(color, "spice", -1)
                leader.drawImperiumCards(color, 1)
            end
            continuation.run()
        end)
        return continuation
    end
})

Leader.memnonThorvald = Helper.createClass(Leader, {

    --- Connections
    sendAgent = function (color, spaceName, recallSpy)
        local continuation = Helper.createContinuation("Leader.memnonThorvald.sendAgent")
        Action.sendAgent(color, spaceName, recallSpy).doAfter(function ()
            if spaceName == "highCouncil" then
                local leader = PlayBoard.getLeader(color)
                leader.influence(color, nil, 1)
            end
            continuation.run()
        end)
        return continuation
    end,

    --- Spice hoard
    signetRing = function (color, spaceName)
        local leader = PlayBoard.getLeader(color)
        return leader.resources(color, "spice", 1)
    end
})

Leader.armandEcaz = Helper.createClass(Leader, {
})

Leader.ilesaEcaz = Helper.createClass(Leader, {

    setUp = function (color, settings)
        local zone = PlayBoard.getPlayBoard(color).content.leaderZone
        -- Temporary tag to avoid counting the leader card.
        zone.addTag("Imperium")
        Deck.generateSpecialDeck(zone, "legacy", "foldspace").doAfter(function (deck)
            zone.removeTag("Imperium")
            deck.flip()
        end)
    end,

    --- Guild contacts
    signetRing = function (color)
        local leader = PlayBoard.getLeader(color)
        return leader.resources(color, "solari", -1) and Action.acquireFoldspace(color)
    end
})

Leader.rhomburVernius = Helper.createClass(Leader, {

    --- Heavy lasgun cannons
    prepare = function (color, settings)
        Action.prepare(color, settings)
        Combat.setDreadnoughtStrength(color, 4)
    end
})

Leader.tessiaVernius = Helper.createClass(Leader, {

    setUp = function (color, settings)
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

    --- Careful observation
    prepare = function (color, settings)
        Action.prepare(color, settings)
        InfluenceTrack.setUpSnoopers()
    end,

    tearDown = function ()
        InfluenceTrack.tearDownSnoopers()
    end,

    --- Careful observation
    influence = function (color, faction, amount)
        if faction then
            local continuation = Helper.createContinuation("Leader.tessiaVernius.influence")
            local noFriendshipBefore = not InfluenceTrack.hasFriendship(color, faction)
            Action.influence(color, faction, amount).doAfter(function (...)
                local friendshipAfter = InfluenceTrack.hasFriendship(color, faction)
                if noFriendshipBefore and friendshipAfter then
                    InfluenceTrack.recallSnooper(faction, color)
                end
                continuation.run(...)
            end)
            return continuation
        else
            return Action.influence(color, faction, amount)
        end
    end,

    --- Duplicity
    signetRing = function (color)
        local leader = PlayBoard.getLeader(color)
        leader.influence(color, nil, -1)
        leader.influence(color, nil, 1)
    end
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
        return Action.resources(color, resourceName, finalAmount)
    end,

    --- Final delivery
    signetRing = function (color)
        local leader = PlayBoard.getLeader(color)
        return leader.resources(color, "solari", -7)
            and leader.influence(color, nil, 1)
            and leader.troop(color, "supply", "garrison", 1)
            and leader.resources(color, "spice", 1)
    end
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

    --- Couriers
    signetRing = function (color)
        local leader = PlayBoard.getLeader(color)
        return leader.resources(color, "spice", -1)
            and leader.shipments(color, 1)
    end
})

Leader.stabanTuek = Helper.createClass(Leader, {

    -- Smuggle spice
    setUp = function (color, settings)
        Leader.stabanTuek.transientSetUp(color, settings)
    end,

    transientSetUp = function (color, settings)
        Helper.registerEventListener("agentSent", function (otherColor, spaceName)
            if otherColor ~= color and MainBoard.isDesertSpace(spaceName) and MainBoard.isSpying(spaceName, color) then
                Action.log(I18N("stabanSpiceSmuggling"), color)
                local leader = PlayBoard.getLeader(color)
                leader.resources(color, "spice", 1)
            end
        end)
    end,

    --- Limited allies
    prepare = function (color, settings)
        Action.prepare(color, settings)
        local drawDeck = PlayBoard.getDrawDeck(color)
        if drawDeck then
            for i, card in ipairs(drawDeck.getObjects()) do
                if Helper.getID(card) == "diplomacy" then
                    drawDeck.takeObject({
                        index = i - 1,
                        flip = true,
                        position = Vector(drawDeck.getPosition() + Vector(0, 1, 0)),
                        callback_function = function (livingCard)
                            PlayBoard.getPlayBoard(color):trash(livingCard)
                        end
                    })
                    break
                end
            end
        end
    end
})

Leader.amberMetulli = Helper.createClass(Leader, {
})

Leader.gurneyHalleck = Helper.createClass(Leader, {

    --- Always smiling
    setUp = function (color, settings)
        Leader.gurneyHalleck.transientSetUp(color, settings)
    end,

    transientSetUp = function (color, settings)
        Helper.registerEventListener("reveal", function (otherColor)
            if color == otherColor then
                local threshold = settings.numberOfPlayers == 6 and 10 or 6
                if Combat.calculateCombatForce(color) >= threshold then
                    Action.log(I18N("gurneySmile"), color)
                    local leader = PlayBoard.getLeader(color)
                    leader.resources(color, "persuasion", 1)
                end
            end
        end)
    end
})

Leader.margotFenring = Helper.createClass(Leader, {

    --- Loyalty
    influence = function (color, faction, amount)
        if faction == "beneGesserit" then
            local continuation = Helper.createContinuation("Leader.margotFenring.influence")
            local noFriendshipBefore = not InfluenceTrack.hasFriendship(color, faction)
            Action.influence(color, faction, amount).doAfter(function (...)
                local friendshipAfter = InfluenceTrack.hasFriendship(color, faction)
                if noFriendshipBefore and friendshipAfter then
                    local leader = PlayBoard.getLeader(color)
                    Action.log(I18N("loyalty"), color)
                    leader.resources(color, "spice", 2)
                end
                continuation.run(...)
            end)
            return continuation
        else
            return Action.influence(color, faction, amount)
        end
    end
})

Leader.irulanCorrino = Helper.createClass(Leader, {

    --- Imperial Bitchright
    influence = function (color, faction, amount)
        if Helper.isElementOf(faction, { "emperor", "greatHouses" }) then
            local continuation = Helper.createContinuation("Leader.irulanCorrino.influence")
            local noFriendshipBefore = not InfluenceTrack.hasFriendship(color, faction)
            Action.influence(color, faction, amount).doAfter(function (...)
                local friendshipAfter = InfluenceTrack.hasFriendship(color, faction)
                if noFriendshipBefore and friendshipAfter then
                    local leader = PlayBoard.getLeader(color)
                    Action.log(I18N("imperialBirthright"), color)
                    leader.drawIntrigues(color, 1)
                end
                continuation.run(...)
            end)
            return continuation
        else
            return Action.influence(color, faction, amount)
        end
    end
})

-- FIXME Just "Jessica" actually.
Leader.jessica = Helper.createClass(Leader, {

    --- Other memories
    setUp = function (color, settings)
        Leader.jessica.transientSetUp(color, settings)
    end,

    transientSetUp = function (color, settings)
        local leaderCard = PlayBoard.findLeaderCard(color)

        local otherMemories = function ()
            Leader.jessica.name = "reverendMotherJessica"
            leaderCard.setGMNotes(Leader.jessica.name)
            leaderCard.setName(I18N(Leader.jessica.name))
            leaderCard.setRotation(Vector(0, 180, 180))
            broadcastToAll(I18N("otherMemoriesUsed"), color)
        end

        Helper.createTransientAnchor("OtherMemoriesAnchor", leaderCard.getPosition() + Vector(0, -0.5, 0)).doAfter(function (anchor)
            Helper.createAbsoluteButtonWithRoundness(anchor, 1, false, {
                click_function = Helper.registerGlobalCallback(function (_, otherColor)
                    if otherColor == color then
                        otherMemories()
                        anchor.destruct()
                    else
                        Dialog.broadcastToColor(I18N("noTouch"), otherColor, "White")
                    end
                end),
                label = I18N("otherMemoriesButton"),
                position = anchor.getPosition() + Vector(0, 0.6, -1.8),
                width = 1000,
                height = 200,
                font_size = 120,
                scale = Vector(1, 1, 1),
                color = { 0, 0, 0, 1 },
                font_color = Color.fromString("Purple"),
                tooltip = I18N("otherMemoriesTooltip"),
            })
        end)
   end
})

Leader.feydRauthaHarkonnen = Helper.createClass(Leader, {

    positions = {
        Vector(0.1, 0, 0.55),
        Vector(-0.15, 0, 0.4),
        Vector(-0.15, 0, 0.7),
        Vector(-0.4, 0, 0.55),
        Vector(-0.65, 0, 0.4),
        Vector(-0.55, 0, 0.7),
        Vector(-0.75, 0, 0.7),
        Vector(-0.95, 0, 0.55),
    },

    setUp = function (color, settings)
        local snapPoints = {}
        for _, position in ipairs(Leader.feydRauthaHarkonnen.positions) do
            table.insert(snapPoints, {
                position = position,
                tags = { "FeydRauthaTrainingMarker" },
            })
        end

        local leaderCard = PlayBoard.findLeaderCard(color)
        leaderCard.setSnapPoints(snapPoints)
    end,

    --- Devious training
    prepare = function (color, settings)
        Action.prepare(color, settings)

        local leaderCard = PlayBoard.findLeaderCard(color)
        local marker = getObjectFromGUID("505c31")
        marker.setPosition(leaderCard.positionToWorld(Leader.feydRauthaHarkonnen.positions[1]) + Vector(0, 0.5, 0))
        marker.setInvisibleTo({})
    end
})

Leader.shaddamCorrino = Helper.createClass(Leader, {

    prepare = function (color, settings, asCommander)
        if not asCommander then
            Action.prepare(color, settings)
        else
            Action.resources(color, "water", 1)
            if settings.epicMode then
                Action.drawIntrigues(color, 1)
            end
        end

        --- Sardaukar commander
        local leaderCard = PlayBoard.findLeaderCard(color)
        local position = leaderCard.getPosition()
        ChoamContractMarket.takeAnySardaukarContract(position + Vector(-1.2, 1, 0))
        ChoamContractMarket.takeAnySardaukarContract(position + Vector(1.2, 1, 0))
    end
})

Leader.muadDib = Helper.createClass(Leader, {

    prepare = function (color, settings, asCommander)
        if not asCommander then
            Action.prepare(color, settings)
        else
            Action.resources(color, "water", 1)
            if settings.epicMode then
                Action.drawIntrigues(color, 1)
            end
        end
    end
})

return Leader
