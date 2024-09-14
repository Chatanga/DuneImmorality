local Module = require("utils.Module")
local Helper = require("utils.Helper")
local I18N = require("utils.I18N")
local Dialog = require("utils.Dialog")
local Park = require("utils.Park")

local Action = Module.lazyRequire("Action")
local MainBoard = Module.lazyRequire("MainBoard")
local ImperiumRow = Module.lazyRequire("ImperiumRow")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")
local PlayBoard = Module.lazyRequire("PlayBoard")
local Combat = Module.lazyRequire("Combat")
local ChoamContractMarket = Module.lazyRequire("ChoamContractMarket")
local Deck = Module.lazyRequire("Deck")
local TechMarket = Module.lazyRequire("TechMarket")

local Leader = Helper.createClass(Action)

---
function Leader.newLeader(name)
    local LeaderClass = Leader[name]
    assert(LeaderClass, "Unknown leader: " .. tostring(name))
    LeaderClass.name = name
    return Helper.createClassInstance(LeaderClass)
end

---

function Leader._createRightCardButton(anchors, color, name, tooltip, action)
    Leader._createCardButton(anchors, color, name, tooltip, Vector(1.35, 0.6, -1.3), action)
end

function Leader._createLeftCardButton(anchors, color, name, tooltip, action)
    Leader._createCardButton(anchors, color, name, tooltip, Vector(-1, 0.6, -1.3), action)
end

function Leader._createCardButton(anchors, color, name, tooltip, offset, action)
    local leaderCard = PlayBoard.findLeaderCard(color)
    Helper.createTransientAnchor(name, leaderCard.getPosition() + Vector(0, -0.5, 0)).doAfter(function (anchor)
        if anchors then
            table.insert(anchors, anchor)
        end
        Helper.createAbsoluteButtonWithRoundness(anchor, 1, {
            click_function = Helper.registerGlobalCallback(function (_, otherColor)
                if otherColor == color then
                    action(color, anchor)
                else
                    Dialog.broadcastToColor(I18N("noTouch"), otherColor, "Purple")
                end
            end),
            position = anchor.getPosition() + offset,
            width = 1000,
            height = 380,
            scale = Vector(1, 1, 1),
            color = { 0, 0, 0, 0 },
            font_color = { 0, 0, 0, 100 },
            tooltip = tooltip,
        })
    end)
end

Leader.vladimirHarkonnen = Helper.createClass(Leader, {

    setUp = function (color, settings)
        Leader.vladimirHarkonnen.transientSetUp(color, settings)
    end,

    transientSetUp = function (color, settings)
        Leader._createRightCardButton(nil, color, "SchemeAnchor", I18N("schemeTooltip"), Leader.vladimirHarkonnen.signetRing)
    end,

    --- Masterstroke
    prepare = function (color, settings)
        Action.prepare(color, settings)

        local position = Player[color].getHandTransform().position
        local tokenBag = getObjectFromGUID('f89231')
        local tokenCount = #tokenBag.getObjects()
        for _ = 1, tokenCount do
            tokenBag.takeObject({
                position = position,
                smooth = false, -- To avoid hand interception.
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

    setUp = function (color, settings)
        Leader.glossuRabban.transientSetUp(color, settings)
    end,

    transientSetUp = function (color, settings)
        Leader._createRightCardButton(nil, color, "BrutalityAnchor", I18N("brutalityTooltip"), Leader.glossuRabban.signetRing)
    end,

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

    setUp = function (color, settings)
        Leader.ilbanRichese.transientSetUp(color, settings)
    end,

    transientSetUp = function (color, settings)
        Leader._createRightCardButton(nil, color, "ManufacturingAnchor", I18N("manufacturingTooltip"), Leader.ilbanRichese.signetRing)
    end,

    --- Manufacturing
    signetRing = function (color)
        local leader = PlayBoard.getLeader(color)
        return leader.resources(color, "solari", 1)
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
        -- We don't care since it's simpler to let the player apply the rules.
        --local parentSpaceName = MainBoard.findParentSpaceName(spaceName)
        --local force = MainBoard.isLandsraadSpace(parentSpaceName) or MainBoard.isSpiceTradeSpace(parentSpaceName)
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
        if resourceName == "solari" and amount > 0 and Action.checkContext({ phase = "playerTurns", color = color, space = MainBoard.isLandsraadSpace }) then
            finalAmount = amount - 1
        end
        return finalAmount
    end,

    resources = function (color, resourceName, amount)
        return Action.resources(color, resourceName, -Leader.letoAtreides.bargain(color, resourceName, -amount))
    end,
})

Leader.paulAtreides = Helper.createClass(Leader, {

    setUp = function (color, settings)
        Leader.paulAtreides.transientSetUp(color, settings)
    end,

    --- Prescience
    transientSetUp = function (color, settings)

        local prescience = function (_)
            local cardOrDeck = PlayBoard.getDrawDeck(color)
            if cardOrDeck == nil then
                Dialog.broadcastToColor(I18N("prescienceVoid"), color, "Purple")
            elseif cardOrDeck.type == "Card" then
                --broadcastToAll(I18N("prescienceUsed"), color)
                Dialog.broadcastToColor(I18N("prescienceManual"), color, "Purple")
            else
                cardOrDeck.Container.search(color, 1)
                --broadcastToAll(I18N("prescienceUsed"), color)
            end
        end

        Leader._createLeftCardButton(nil, color, "PrescienceAnchor", I18N("prescienceTooltip"), prescience)
        Leader._createRightCardButton(nil, color, "DisciplineAnchor", I18N("disciplineTooltip"), Leader.paulAtreides.signetRing)
    end,

    --- Discipline
    signetRing = function (color)
        local leader = PlayBoard.getLeader(color)
        return leader.drawImperiumCards(color, 1, true)
    end
})

Leader.arianaThorvald = Helper.createClass(Leader, {

    setUp = function (color, settings)
        Leader.arianaThorvald.transientSetUp(color, settings)
    end,

    --- Prescience
    transientSetUp = function (color, settings)
        Leader._createRightCardButton(nil, color, "HiddenReservoirAnchor", I18N("hiddenReservoirTooltip"), Leader.arianaThorvald.signetRing)
    end,

    --- Hidden reservoir
    signetRing = function (color)
        local leader = PlayBoard.getLeader(color)
        return leader.resources(color, "water", 1)
    end,

    --- Spice addict
    sendAgent = function (color, spaceName, recallSpy)
        local oldSpiceStock = PlayBoard.getResource(color, "spice"):get()
        local continuation = Action.sendAgent(color, spaceName, recallSpy)
        continuation.doAfter(function ()
            local newSpiceStock = PlayBoard.getResource(color, "spice"):get()
            if MainBoard.isDesertSpace(MainBoard.findParentSpaceName(spaceName)) and newSpiceStock > oldSpiceStock then
                local leader = PlayBoard.getLeader(color)
                leader.resources(color, "spice", -1)
                leader.drawImperiumCards(color, 1)
            end
        end)
        return continuation
    end
})

Leader.memnonThorvald = Helper.createClass(Leader, {

    setUp = function (color, settings)
        Leader.memnonThorvald.transientSetUp(color, settings)
    end,

    transientSetUp = function (color, settings)
        Leader._createRightCardButton(nil, color, "SpiceHoardAnchor", I18N("spiceHoardTooltip"), Leader.memnonThorvald.signetRing)
    end,

    --- Connections
    sendAgent = function (color, spaceName, recallSpy)
        local continuation = Action.sendAgent(color, spaceName, recallSpy)
        continuation.doAfter(function ()
            if spaceName == "highCouncil" then
                local leader = PlayBoard.getLeader(color)
                leader.influence(color, nil, 1)
            end
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
        Leader.ilesaEcaz.transientSetUp(color, settings)
    end,

    transientSetUp = function (color, settings)
        local zone = PlayBoard.getPlayBoard(color).content.leaderZone
        -- Temporary tag to avoid counting the leader card.
        zone.addTag("Imperium")
        Deck.generateSpecialDeck(zone, "legacy", "foldspace").doAfter(function (deck)
            zone.removeTag("Imperium")
            deck.flip()
        end)
        -- TODO Add a specific place for Foldspace cards in Uprising.
        -- Leader._createRightCardButton(nil, color, "GuildContactsAnchor", I18N("guildContactsTooltip"), Leader.ilesaEcaz.signetRing)
    end,

    --- Guild contacts (disabled)
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
    end,

    --- Guild contacts
    sendAgent = function (color, spaceName)
        local continuation = Action.sendAgent(color, spaceName)
        continuation.doAfter(function ()
            if PlayBoard.hasPlayedThisTurn(color, "signetRing") or PlayBoard.hasPlayedThisTurn(color, "boundlessAmbition") then
                TechMarket.registerAcquireTechOption(color, "rhomburVerniusTechBuyOption", "spice", 0)
            end
        end)
        return continuation
    end
})

Leader.tessiaVernius = Helper.createClass(Leader, {

    setUp = function (color, settings)
        Leader.tessiaVernius.transientSetUp(color, settings)
    end,

    transientSetUp = function (color, settings)
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
            local noFriendshipBefore = not InfluenceTrack.hasFriendship(color, faction)
            local continuation = Action.influence(color, faction, amount)
            continuation.doAfter(function ()
                local friendshipAfter = InfluenceTrack.hasFriendship(color, faction)
                if noFriendshipBefore and friendshipAfter then
                    InfluenceTrack.recallSnooper(faction, color)
                end
            end)
            return continuation
        else
            return Action.influence(color, faction, amount)
        end
    end,

    --- Duplicity (not used)
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

    --- Final delivery (not used)
    signetRing = function (color)
        local leader = PlayBoard.getLeader(color)
        return leader.resources(color, "solari", -7)
            and leader.influence(color, nil, 1)
            and leader.troops(color, "supply", "garrison", 1)
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

    --- Couriers (not used)
    signetRing = function (color)
        local leader = PlayBoard.getLeader(color)
        return leader.resources(color, "spice", -1) and leader.shipments(color, 1)
    end
})

Leader.stabanTuek = Helper.createClass(Leader, {

    -- Smuggle spice
    setUp = function (color, settings)
        Leader.stabanTuek.transientSetUp(color, settings)
    end,

    transientSetUp = function (color, settings)
        Helper.registerEventListener("agentSent", function (otherColor, spaceName)
            local parentSpaceName = MainBoard.findParentSpaceName(spaceName)
            if otherColor ~= color and MainBoard.isDesertSpace(parentSpaceName) and MainBoard.isSpying(parentSpaceName, color) then
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

    setUp = function (color, settings)
        Leader.amberMetulli.transientSetUp(color, settings)
    end,

    transientSetUp = function (color, settings)
        Leader._createRightCardButton(nil, color, "FillCoffersAnchor", I18N("fillCoffersTooltip"), Leader.amberMetulli.signetRing)
    end,

    --- Fill Coffers
    signetRing = function (color)
        local leader = PlayBoard.getLeader(color)
        if InfluenceTrack.hasAnyAlliance(color) then
            leader.resources(color, "spice", 1)
        end
        leader.resources(color, "solari", 1)
        return true
    end
})

Leader.gurneyHalleck = Helper.createClass(Leader, {

    setUp = function (color, settings)
        Leader.gurneyHalleck.transientSetUp(color, settings)
    end,

    --- Always smiling
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
        Leader._createRightCardButton(nil, color, "WarmasterAnchor", I18N("warmasterTooltip"), Leader.gurneyHalleck.signetRing)
    end,

    --- Warmaster
    signetRing = function (color)
        local leader = PlayBoard.getLeader(color)
        return leader.troops(color, "supply", "garrison", 1)
    end
})

Leader.margotFenring = Helper.createClass(Leader, {

    --- Loyalty
    influence = function (color, faction, amount)
        if faction == "beneGesserit" then
            local noFriendshipBefore = not InfluenceTrack.hasFriendship(color, faction)
            local continuation = Action.influence(color, faction, amount)
            continuation.doAfter(function (...)
                local friendshipAfter = InfluenceTrack.hasFriendship(color, faction)
                if noFriendshipBefore and friendshipAfter then
                    local leader = PlayBoard.getLeader(color)
                    Action.log(I18N("loyalty"), color)
                    leader.resources(color, "spice", 2)
                end
            end)
            return continuation
        else
            return Action.influence(color, faction, amount)
        end
    end
})

Leader.irulanCorrino = Helper.createClass(Leader, {

    --- Imperial Birthright
    influence = function (color, faction, amount)
        if Helper.isElementOf(faction, { "emperor", "greatHouses" }) then
            local noFriendshipBefore = not InfluenceTrack.hasFriendship(color, faction)
            local continuation = Action.influence(color, faction, amount)
            continuation.doAfter(function ()
                local friendshipAfter = InfluenceTrack.hasFriendship(color, faction)
                if noFriendshipBefore and friendshipAfter then
                    local leader = PlayBoard.getLeader(color)
                    Action.log(I18N("imperialBirthright"), color)
                    leader.drawIntrigues(color, 1)
                end
            end)
            return continuation
        else
            return Action.influence(color, faction, amount)
        end
    end
})

Leader.jessica = Helper.createClass(Leader, {

    setUp = function (color, settings)
        Leader.jessica.transientSetUp(color, settings)
    end,

    --- Other memories
    transientSetUp = function (color, settings)
        local leaderCard = PlayBoard.findLeaderCard(color)

        Leader.jessica.otherMemoriesPark = MainBoard.createOtherMemoriesPark(color)

        local otherMemories = function ()
            Leader.jessica.name = "reverendMotherJessica"
            leaderCard.setGMNotes(Leader.jessica.name)
            leaderCard.setName(I18N(Leader.jessica.name))
            leaderCard.setRotation(Vector(0, 180, 180))
            broadcastToAll(I18N("otherMemoriesUsed"), color)
            local count = Park.transfert(12, Leader.jessica.otherMemoriesPark, PlayBoard.getSupplyPark(color))
            Action.drawImperiumCards(color, count, true)
        end

        if leaderCard.getGMNotes() ~= "reverendMotherJessica" then
            local anchors = {}

            Leader._createLeftCardButton(anchors, color, "OtherMemoriesAnchor", I18N("otherMemoriesTooltip"), function ()
                Dialog.showYesOrNoDialog(color, I18N("confirmOtherMemories"), nil, function (confirmed)
                    if confirmed then
                        otherMemories()
                        for _, anchor in ipairs(anchors) do
                            anchor.destruct()
                        end
                    end
                end)
            end)

            Leader._createRightCardButton(nil, color, "SpiceAgonyAnchor", I18N("spiceAgonyTooltip"), Leader.jessica.signetRing)
        else
            Leader._createRightCardButton(nil, color, "WaterOfLifeAnchor", I18N("waterOfLifeTooltip"), Leader.jessica.signetRing)
        end
   end,

    --- Spice Agony / Water of Life
    signetRing = function (color)
        local leaderCard = PlayBoard.findLeaderCard(color)
        if leaderCard.getGMNotes() ~= "reverendMotherJessica" then
            if Action.resources(color, "spice", -1) then
                Action.drawIntrigues(color, 1)
                local count = Park.transfert(1, PlayBoard.getSupplyPark(color), Leader.jessica.otherMemoriesPark)
                Action.log(I18N("transfer", {
                    count = count,
                    what = I18N.agree(count, "troop"),
                    from = I18N("supplyPark"),
                    to = I18N("otherMemoriesPark"),
                }), color)
                return true
            else
                return false
            end
        else
            return Action.resources(color, "spice", -1) and Action.resources(color, "water", 1)
        end
    end
})

Leader.reverendMotherJessica = Leader.jessica

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

    --- Unpredictable foe
    setUp = function (color, settings)
        Leader.muadDib.transientSetUp(color, settings)
    end,

    transientSetUp = function (color, settings)
        Helper.registerEventListener("reveal", function (otherColor)
            if color == otherColor and PlayBoard.couldSendAgentOrReveal(color) and Combat.hasSandworms(color) then
                local leader = PlayBoard.getLeader(color)
                Action.log(I18N("muadDibBeingUnpredictable"), color)
                leader.drawIntrigues(color, 1)
            end
        end)
        Leader._createRightCardButton(nil, color, "LeadTheWayAnchor", I18N("leadTheWayTooltip"), Leader.muadDib.signetRing)
    end,

    --- Lead the Way
    signetRing = function (color)
        local leaderCard = PlayBoard.findLeaderCard(color)
        return Action.drawImperiumCards(color, 1, true)
    end,

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
