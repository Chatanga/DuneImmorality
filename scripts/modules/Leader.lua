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
local TechMarket = Module.lazyRequire("TechMarket")

local Leader = Helper.createClass(Action)

---
function Leader.newLeader(name)
    local LeaderClass = Leader[name]
    if not LeaderClass then
        -- Fanmade leader?
        LeaderClass = Helper.createClass(Leader, {})
    end
    --assert(LeaderClass, "Unknown leader: " .. tostring(name))
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
        local finalAmount = amount
        if resourceName == "solari" and amount > 0 and Action.checkContext({ phase = "playerTurns", color = color, space = MainBoard.isLandsraadSpace }) then
            finalAmount = amount - 1
        end
        return finalAmount
    end,

    resources = function (color, resourceName, amount)
        return Action.resources(color, resourceName, -Leader.letoAtreides.bargain(color, resourceName, -amount))
    end,

    --- Prudent Diplomacy
    signetRing = function (color)

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
                leader.influence(color, potentialFactions, 1)
                return true
            end
        end
        return false
    end
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
            if MainBoard.isDesertSpace(spaceName) and newSpiceStock > oldSpiceStock then
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
    signetRing = function (color)
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

    --- Guild contacts (for a rival)
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

    setUp = function (color, settings)
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
            local leader = PlayBoard.getLeader(color)
            leader.drawIntrigues(color, 2)
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

    --- Couriers
    signetRing = function (color)
        local leader = PlayBoard.getLeader(color)
        return leader.resources(color, "spice", -1)
            and leader.shipments(color, 1)
    end
})

return Leader
