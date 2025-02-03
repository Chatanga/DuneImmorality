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
local Deck = Module.lazyRequire("Deck")
local TechMarket = Module.lazyRequire("TechMarket")
local Intrigue = Module.lazyRequire("Intrigue")
local Types = Module.lazyRequire("Types")
local Board = Module.lazyRequire("Board")
local TurnControl = Module.lazyRequire("TurnControl")
local HagalCard = Module.lazyRequire("HagalCard")

---@class Leader: Action
---@field name string
local Leader = Helper.createClass(Action)

---@param name string
---@return Leader
function Leader.newLeader(name)
    local LeaderClass = Leader[name]
    if not LeaderClass then
        -- Fanmade leader?
        LeaderClass = Helper.createClass(Leader, {})
    end
    LeaderClass.name = name
    return Helper.createClassInstance(LeaderClass)
end

---@param anchors? Option[]
---@param color PlayerColor
---@param name string
---@param tooltip string
---@param action fun(color: PlayerColor, anchor: Object)
function Leader._createRightCardButton(anchors, color, name, tooltip, action)
    Leader._createCardButton(anchors, color, name, tooltip, Vector(1.35, 0, -1.3), action)
end

---@param anchors? Option[]
---@param color PlayerColor
---@param name string
---@param tooltip string
---@param action fun(color: PlayerColor, anchor: Object)
function Leader._createLeftCardButton(anchors, color, name, tooltip, action)
    Leader._createCardButton(anchors, color, name, tooltip, Vector(-1, 0, -1.3), action)
end

---@param anchors? Option[]
---@param color PlayerColor
---@param name string
---@param tooltip string
---@param offset Vector
---@param action fun(color: PlayerColor, anchor: Object)
function Leader._createCardButton(anchors, color, name, tooltip, offset, action)
    local leaderCard = PlayBoard.findLeaderCard(color)
    if leaderCard then
        local origin = leaderCard.getPosition() + offset
        Helper.createTransientAnchor(name, origin + Vector(0, -0.5, 0)).doAfter(function (anchor)
            if anchors then
                table.insert(anchors, anchor)
            end
            local y = (anchor.getPosition() + offset).y
            Helper.createSizedAreaButton(1000, 380, anchor, 0, 0, origin.y + 0.1, tooltip, function (_, otherColor)
                if otherColor == color then
                    action(color, anchor)
                else
                    Dialog.broadcastToColor(I18N("noTouch"), otherColor, "Purple")
                end
            end)
        end)
    end
end

---@param color PlayerColor
---@param settings Settings
function Leader.transientSetUp(color, settings)
    -- NOP
end

Leader.vladimirHarkonnen = Helper.createClass(Leader, {

    doSetUp = function (color, settings)
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

    -- Masterstroke
    instruct = function (phase, isActivePlayer)
        if phase == "gameStart" then
            if isActivePlayer then
                return I18N("gameStartActiveInstructionForVladimirHarkonnen")
            else
                return I18N("gameStartInactiveInstructionForVladimirHarkonnen")
            end
        else
            return Leader.instruct(phase, isActivePlayer)
        end
    end,

    --- Scheme
    signetRing = function (color)
        local leader = PlayBoard.getLeader(color)
        return leader.resources(color, "solari", -1) and leader.drawIntrigues(color, 1)
    end
})

Leader.glossuRabban = Helper.createClass(Leader, {

    doSetUp = function (color, settings)
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

    doSetUp = function (color, settings)
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
            and Action.checkContext({ phase = "playerTurns", color = color, agentDestination = Helper.isNotNil })
        then
            local leader = PlayBoard.getLeader(color)
            leader.drawImperiumCards(color, 1)
        end
        return success
    end
})

Leader.helenaRichese = Helper.createClass(Leader, {

    --- Eyes everywhere
    sendAgent = function (color, spaceName)
        -- We don't care since it's simpler to let the player apply the rules.
        --local force = MainBoard.isLandsraadSpace(spaceName) or MainBoard.isSpiceTradeSpace(spaceName)
        return Action.sendAgent(color, spaceName)
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
        local finalAmount = Action.bargain(color, resourceName, amount)
        local toLandsraadSpace = function (agentDestination)
            return agentDestination and MainBoard.isLandsraadSpace(agentDestination.space)
        end
        if resourceName == "solari" and Action.checkContext({ phase = "playerTurns", color = color, agentDestination = toLandsraadSpace }) then
            finalAmount = math.max(0, amount - 1)
        end
        return finalAmount
    end,

    resources = function (color, resourceName, amount)
        return Action.resources(color, resourceName, -Leader.letoAtreides.bargain(color, resourceName, -amount))
    end,

    --- Prudent Diplomacy (only automated for a rival)
    signetRing = function (color)

        ---@return Faction[]
        local getPotentialFactions = function ()
            local potentialFactions = {}
            for _, faction in ipairs({ "emperor", "spacingGuild", "beneGesserit", "fremen" }) do
                local ownInfluence = InfluenceTrack.getInfluence(faction, color)
                if ownInfluence < 6 then
                    local possible = false
                    for _, otherColor in ipairs(PlayBoard.getActivePlayBoardColors()) do
                        if otherColor ~= color then
                            if InfluenceTrack.getInfluence(faction, otherColor) > ownInfluence then
                                possible = true
                                break
                            end
                        end
                    end
                    if possible then
                        table.insert(potentialFactions, faction)
                    end
                end
            end
            return potentialFactions
        end

        local leader = PlayBoard.getLeader(color)
        if PlayBoard.getResource(color, "spice"):get() >= 1 then
            local potentialFactions = getPotentialFactions()
            if #potentialFactions > 0 then
                leader.resources(color, "spice", -1)
                ---@cast leader Rival
                leader.influence(color, potentialFactions, 1)
                return true
            end
        end
        return false
    end
})

Leader.paulAtreides = Helper.createClass(Leader, {

    doSetUp = function (color, settings)
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
                ---@class cardOrDeck Deck
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

    doSetUp = function (color, settings)
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
    sendAgent = function (color, spaceName)
        local oldSpiceStock = PlayBoard.getResource(color, "spice"):get()
        local continuation = Action.sendAgent(color, spaceName)
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

    doSetUp = function (color, settings)
        Leader.memnonThorvald.transientSetUp(color, settings)
    end,

    transientSetUp = function (color, settings)
        Leader._createRightCardButton(nil, color, "SpiceHoardAnchor", I18N("spiceHoardTooltip"), Leader.memnonThorvald.signetRing)
    end,

    --- Connections
    sendAgent = function (color, spaceName)
        local continuation = Action.sendAgent(color, spaceName)
        continuation.doAfter(function ()
            if spaceName == "highCouncil" then
                local leader = PlayBoard.getLeader(color)
                leader.influence(color, nil, 1)
            end
        end)
        return continuation
    end,

    --- Spice hoard
    signetRing = function (color)
        local leader = PlayBoard.getLeader(color)
        return leader.resources(color, "spice", 1)
    end
})

Leader.armandEcaz = Helper.createClass(Leader, {
})

Leader.ilesaEcaz = Helper.createClass(Leader, {

    doSetUp = function (color, settings)
        Leader.ilesaEcaz.transientSetUp(color, settings)
    end,

    transientSetUp = function (color, settings)
        Leader._createRightCardButton(nil, color, "GuildContactsAnchor", I18N("guildContactsTooltip"), Leader.ilesaEcaz.signetRing)
    end,

    --- Guild contacts
    signetRing = function (color)
        local leader = PlayBoard.getLeader(color)
        return leader.resources(color, "solari", -1) and Action.acquireFoldspace(color)
    end,

    --- One step ahead
    instruct = function (phase, isActivePlayer)
        if phase == "roundStart" then
            if isActivePlayer then
                return I18N("gameStartActiveInstructionForIlesaEcaz")
            else
                return I18N("gameStartInactiveInstructionForIlesaEcaz")
            end
        else
            return Leader.instruct(phase, isActivePlayer)
        end
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
    end,

    --- Guild contacts (only automated for a rival)
    signetRing = function (color)
        TechMarket.registerAcquireTechOption(color, "rhomburVerniusTechBuyOption", "spice", 0)
        local leader = PlayBoard.getLeader(color)
        if not leader.acquireTech(color, nil) then
            leader.troops(color, "supply", "negotiation", 1)
        end
        return true
    end
})

Leader.tessiaVernius = Helper.createClass(Leader, {

    doSetUp = function (color, settings)
        Leader.tessiaVernius.transientSetUp(color, settings)
    end,

    transientSetUp = function (color, settings)
        local leaderCard = PlayBoard.findLeaderCard(color)
        if leaderCard then
            local snapPoints = {}
            for i = 1, 4 do
                local p = leaderCard.getPosition() + Vector(i / 4 - 2, 0, 1.4 - i / 2)
                table.insert(snapPoints, {
                    position = leaderCard.positionToLocal(p),
                    tags = { "Snooper" }
                })
            end
            leaderCard.setSnapPoints(snapPoints)
        end
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

    doSetUp = function (color, settings)
        Leader.yunaMoritani.transientSetUp(color, settings)
    end,

    transientSetUp = function (color, settings)
        Leader._createRightCardButton(nil, color, "FinalDeliveryAnchor", I18N("finalDeliveryTooltip"), Leader.yunaMoritani.signetRing)
    end,

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
            and leader.troops(color, "supply", "garrison", 1)
            and leader.resources(color, "spice", 1)
    end
})

Leader.hundroMoritani = Helper.createClass(Leader, {

    --- Intelligence
    prepare = function (color, settings)
        Action.prepare(color, settings)
        Helper.onceFramesPassed(1).doAfter(function ()
            -- We don't send it to the player hand to avoid any confusion with the epic mode intrigue.
            local emptySlots = Park.findEmptySlots(PlayBoard.getAgentCardPark(color))
            Intrigue.moveIntrigues({ emptySlots[1], emptySlots[2] })
        end)
    end,

    --- Intelligence
    instruct = function (phase, isActivePlayer)
        if phase == "gameStart" then
            if isActivePlayer then
                return I18N("gameStartActiveInstructionForHundroMoritani")
            else
                return I18N("gameStartInactiveInstructionForHundroMoritani")
            end
        else
            return Leader.instruct(phase, isActivePlayer)
        end
    end,

    --- Couriers (only automated for a rival)
    signetRing = function (color)
        local leader = PlayBoard.getLeader(color)
        return leader.resources(color, "spice", -1) and leader.shipments(color, 1)
    end
})

Leader.chani = Helper.createClass(Leader, {

    doSetUp = function (color, settings)
        local snapPoints = {}
        Leader.chani.positions = {}
        for i = 11, 1, -1 do
            local position = Vector(i * 0.175 - 1.125, 0, 0.61)
            table.insert(Leader.chani.positions, position)
            table.insert(snapPoints, {
                position = position,
                tags = { "FedaykinManeuverMarker" },
            })
        end

        local leaderCard = PlayBoard.findLeaderCard(color)
        if leaderCard then
            leaderCard.setSnapPoints(snapPoints)
        end

        Leader.chani.transientSetUp(color, settings)
    end,

    --- Fedaykin Maneuver & Tactician
    transientSetUp = function (color, settings)
        Leader._createRightCardButton(nil, color, "FedaykinManeuverAnchor", I18N("fedaykinManeuverTooltip"), Leader.chani.signetRing)

        Helper.registerEventListener("phaseStart", function (phase)
            if phase == "combatEnd" then
                local count = Combat.getUnitCounts(function (object)
                    return Types.isTroop(object) or Types.isSardaukarCommander(object)
                end)[color]
                if count > 0 then
                    local markers = getObjectsWithTag("FedaykinManeuverMarker")
                    assert(#markers == 1)
                    local marker = markers[1]
                    local markerPosition = marker.getPosition()
                    local leaderCard = PlayBoard.findLeaderCard(color)
                    if leaderCard then
                        local snapPoints = leaderCard.getSnapPoints()
                        local slots = {}
                        for _, snapPoint in ipairs(snapPoints) do
                            local slot = leaderCard.positionToWorld(snapPoint.position)
                            slot.y = markerPosition.y
                            table.insert(slots, slot)
                        end
                        for markerPositionIndex, slot in ipairs(slots) do
                            if Vector.sqrDistance(slot, markerPosition) < 0.1 then
                                local leader = PlayBoard.getLeader(color)
                                local startIndex = settings.numberOfPlayers == 6 and 1 or 3
                                Action.log(I18N("chaniBeingTactical", { count = count, what = I18N.agree(count, "troop") }), color)
                                Helper.repeatMovingAction(marker, count, function ()
                                    markerPositionIndex = markerPositionIndex >= 11 and startIndex or markerPositionIndex + 1
                                    marker.setPositionSmooth(slots[markerPositionIndex] + Vector(0, 0.25, 0))
                                    if markerPositionIndex == 6 then
                                        leader.resources(color, "spice", 1)
                                    elseif markerPositionIndex == 11 then
                                        leader.resources(color, "water", 1)
                                    end
                                end)
                                break
                            end
                        end
                    end
                end
            end
        end)
    end,

    --- Lead the Way
    signetRing = function (color)
        local leader = PlayBoard.getLeader(color)
        return InfluenceTrack.hasFriendship(color, "fremen")
            and leader.resources(color, "water", -1)
            and leader.drawImperiumCards(color, 2, true)
    end,

    --- Tactician
    prepare = function (color, settings)
        Action.prepare(color, settings)
        local leaderCard = PlayBoard.findLeaderCard(color)
        if leaderCard then
            local startIndex = settings.numberOfPlayers == 6 and 1 or 3
            local marker = getObjectFromGUID("505c31").clone({
                position = leaderCard.positionToWorld(Leader.chani.positions[startIndex]) + Vector(0, 0.5, 0)
            })
            marker.setInvisibleTo({})
            marker.setTags({ "FedaykinManeuverMarker" })
        end
    end
})

Leader.duncanIdaho = Helper.createClass(Leader, {

    --- Into the Fray
    doSetUp = function (color, settings)
        for _, agent in ipairs(getObjectsWithTag("Agent")) do
            if agent.hasTag(color) then
                agent.addTag("Unit")
            end
        end
    end,

    --- Ginaz Swordmaster
    bargain = function (color, resourceName, amount)
        Helper.dumpFunction("bargain", color, resourceName, amount)
        local finalAmount = Action.bargain(color, resourceName, amount)
        local toSwordmasterSpace = function (agentDestination)
            return agentDestination and agentDestination.space == "swordmaster"
        end
        if resourceName == "solari" and Action.checkContext({ phase = "playerTurns", color = color, agentDestination = toSwordmasterSpace }) then
            finalAmount = math.max(0, amount - 2)
        end
        return finalAmount
    end,

    resources = function (color, resourceName, amount)
        return Action.resources(color, resourceName, -Leader.duncanIdaho.bargain(color, resourceName, -amount))
    end
})

Leader.esmarTuek = Helper.createClass(Leader, {

    doSetUp = function (color, settings)
        Leader.esmarTuek.transientSetUp(color, settings)
    end,

    --- Tuek's Sietch
    transientSetUp = function (color, settings)
        Helper.registerEventListener("agentSent", function (otherColor, spaceName)
            if spaceName == "tuekSietch" then
                local leader = PlayBoard.getLeader(color)
                if color == otherColor then
                    Action.log(I18N("tuekGainSolariFromAlly"), color)
                    leader.resources(color, "solari", 1)
                else
                    Action.log(I18N("tuekDrawIntrigueFromOpponent"), color)
                    leader.drawIntrigues(color, 1)
                end
            end
        end)
    end,

    prepare = function (color, settings)
        Action.prepare(color, settings)
        MainBoard.processTuekSnapPoints(settings)
    end,

    --- Smuggle Spice (only automated for a rival)
    signetRing = function (color)
        local leader = PlayBoard.getLeader(color)
        local best = HagalCard.findHarvestableSpace(color, true)
        if best.desertSpace and best.spiceBonus > 0 then
            MainBoard.getSpiceBonus(best.desertSpace):change(-1)
            leader.resources(color, "spice", 1)
            return true
        else
            return false
        end
    end
})

Leader.piterDeVries = Helper.createClass(Leader, {

    doSetUp = function (color, settings)
        local content = PlayBoard.getPlayBoard(color).content
        local zone = content.leaderZone
        -- Temporary tag to avoid counting the leader card.
        zone.addTag("Intrigue")
        Deck.generateTwistedIntrigueDeck(zone).doAfter(function (deck)
            Helper.shuffleDeck(deck)
            Helper.onceShuffled(deck).doAfter(function ()
                local cardCount = Helper.getCardCount(deck)
                Helper.repeatChainedAction(cardCount, function ()
                    local continuation = Helper.createContinuation("Leader.piterDeVries.doSetUp")
                    Helper.moveCardFromZone(zone, content.trash.getPosition() + Vector(0, 1, 0), nil, false, false).doAfter(function (card)
                        Helper.onceSwallowedUp(card).doAfter(continuation.run)
                    end)
                    return continuation
                end).doAfter(function ()
                    zone.removeTag("Intrigue")
                end)
            end)
        end)

        Leader.piterDeVries.transientSetUp(color, settings)
    end,

    --- Twisted Genius
    transientSetUp = function (color, settings)
        Helper.registerEventListener("phaseStart", function (phase)
            if phase == "roundStart" then
                if PlayBoard.giveIntrigueFromTrash(color) then
                    return true
                else
                    Dialog.broadcastToColor(I18N("noAvailableTwistedIntrigues"), color, "Purple")
                    return false
                end
            end
        end)

        Leader._createRightCardButton(nil, color, "HarkonnenAdvisorAnchor", I18N("harkonnenAdvisorTooltip"), Leader.piterDeVries.signetRing)
    end,

    --- Harkonnen Advisor
    signetRing = function (color)
        local leader = PlayBoard.getLeader(color)
        return leader.troops(color, "supply", "garrison", 1)
    end
})

Leader.yrkoon = Helper.createClass(Leader, {

    bags = {
        "7e56d8",
        "686021",
        "cfd6d1",
        "5f9264",
    },

    doSetUp = function (color, settings)
        local content = PlayBoard.getPlayBoard(color).content
        local zone = content.leaderZone
        -- Temporary tag to avoid counting the leader card.
        zone.addTag("Navigation")
        Deck.generateNavigationDeck(zone).doAfter(function (deck)
            zone.removeTag("Navigation")
            Helper.shuffleDeck(deck)
            deck.setPosition(deck.getPosition() + Vector(0, 0, 0.25))

            for i = 1, 4 do
                local bag = getObjectFromGUID(Leader.yrkoon.bags[i])
                local p = zone.getPosition() + Vector(i * 1.2 - 3, 0, -1.5)
                p:setAt('y', Board.onPlayBoard(0))
                bag.setPosition(p)
                bag.setInvisibleTo({})
                Helper.noPhysics(bag)

                local ranks = { "first", "second", "third", "fourth" }
                bag.createButton({
                    click_function = Helper.registerGlobalCallback(function ()
                        bag.Container.search(color, 1)
                    end),
                    position = Vector(0, 0.6, 0),
                    tooltip = I18N("lookAt", { rank = I18N(ranks[i]) }),
                    width = 500,
                    height = 500,
                    color = Helper.AREA_BUTTON_COLOR,
                    hover_color = { 0.7, 0.7, 0.7, 0.7 },
                    press_color = { 0.5, 1, 0.5, 0.4 },
                    font_color = { 1, 1, 1, 100 },
                })
            end
        end)

        Leader.yrkoon.transientSetUp(color, settings)
    end,

    -- Plot Course
    instruct = function (phase, isActivePlayer)
        if phase == "gameStart" then
            if isActivePlayer then
                return I18N("gameStartActiveInstructionForYrkoon")
            else
                return I18N("gameStartInactiveInstructionForYrkoon")
            end
        else
            return Leader.instruct(phase, isActivePlayer)
        end
    end,

    --- Hungry for Spice & Plot Course
    transientSetUp = function (color, settings)
        Helper.registerEventListener("playerTurn", function (phaseName, otherColor)
            -- We don't check that otherColor == color because the rules don't say that the turn must be Y'rkoon's.
            if phaseName == "playerTurns" then
                Leader.yrkoon.baseSpice = PlayBoard.getResource(color, "spice"):get()
            else
                Leader.yrkoon.baseSpice = nil
            end
        end)
        Helper.registerEventListener("spiceValueChanged", function (otherColor, newValue)
            if Leader.yrkoon.baseSpice and otherColor == color and TurnControl.getCurrentPhase() == "playerTurns" then
                if newValue - Leader.yrkoon.baseSpice >= 3 then
                    local leader = PlayBoard.getLeader(color)
                    Action.log(I18N("hungryForSpiceAbility"), color)
                    leader.drawImperiumCards(color, 1)
                    Leader.yrkoon.baseSpice = nil
                end
            end
        end)
        Helper.registerEventListener("influence", function (faction, otherColor, newRank, oldRank)
            if otherColor == color and newRank >= 2 and oldRank < 2 then
                Helper.dump("draw next navigation card")
                for i = 1, 4 do
                    local bag = getObjectFromGUID(Leader.yrkoon.bags[i])
                    if PlayBoard.giveNavigationFromBag(color, bag) then
                        return
                    end
                end
            end
        end)
    end,

    --- Strange Form
    prepare = function (color, settings)
        Action.prepare(color, settings)
        local leader = PlayBoard.getLeader(color)
        leader.resources(color, "water", -1)

        local drawDeck = PlayBoard.getDrawDeck(color)
        if drawDeck then
            for i, card in ipairs(Helper.getCards(drawDeck)) do
                if Helper.getID(card) == "signetRing" then
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
    end,
})

Leader.kotaOdax = Helper.createClass(Leader, {

    doSetUp = function (color, settings)
        Leader.kotaOdax.transientSetUp(color, settings)
    end,

    transientSetUp = function (color, settings)
        Helper.registerEventListener("playerTurn", function (phaseName, otherColor)
            if phaseName == "gameStart" and otherColor == color then
                local options = {}
                for index = 1, 3 do
                    local stackIndex = 4 - index
                    local cardName = TechMarket.getBottomCardDetails(stackIndex)
                    if cardName then
                        table.insert(options, {
                            name = cardName,
                            url = Deck.getCardUrlByName("tech", cardName),
                        })
                    end
                end
                Dialog.showTechOptionsDialog(color, I18N("kotaOdaxChoice"), options, function (index)
                    local stackIndex = 4 - math.max(1, index) -- Select the first option on cancellation.
                    local content = PlayBoard.getPlayBoard(color).content
                    local zone = content.leaderZone
                    TechMarket.grapBottomCard(stackIndex, zone.getPosition())
                    TurnControl.endOfTurn()
                end)
            end
        end)
    end,

    instruct = function (phase, isActivePlayer)
        if phase == "gameStart" then
            if isActivePlayer then
                return I18N("gameStartActiveInstructionForKotaOdax")
            else
                return I18N("gameStartInactiveInstructionForKotaOdax")
            end
        else
            return Leader.instruct(phase, isActivePlayer)
        end
    end,
})

return Leader
