local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")
local I18N = require("utils.I18N")
local Set = require("utils.Set")
local Dialog = require("utils.Dialog")

local Resource = Module.lazyRequire("Resource")
local TleilaxuResearch = Module.lazyRequire("TleilaxuResearch")
local TurnControl = Module.lazyRequire("TurnControl")
local Types = Module.lazyRequire("Types")
local Deck = Module.lazyRequire("Deck")
local MainBoard = Module.lazyRequire("MainBoard")
local Hagal = Module.lazyRequire("Hagal")
local Leader = Module.lazyRequire("Leader")
local Combat = Module.lazyRequire("Combat")
local Intrigue = Module.lazyRequire("Intrigue")
local Reserve = Module.lazyRequire("Reserve")
local TechMarket = Module.lazyRequire("TechMarket")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")
local IntrigueCard = Module.lazyRequire("IntrigueCard")
local ImperiumCard = Module.lazyRequire("ImperiumCard")
local ConflictCard = Module.lazyRequire("ConflictCard")
local Action = Module.lazyRequire("Action")
local Rival = Module.lazyRequire("Rival")

local PlayBoard = Helper.createClass(nil, {
    ALL_RESOURCE_NAMES = { "spice", "water", "solari", "persuasion", "strength" },
    -- Temporary structure (set to nil *after* loading).
    unresolvedContentByColor = {
        Red = {
            board = "adcd28",
            colorband = "ecc723",
            spice = "3074d4",
            solari = "576ccd",
            water = "692c4d",
            persuasion = "72be72",
            strength = "3f6645",
            leaderZone = "66cdbb",
            dreadnoughts = {"1a3c82", "a8f306"},
            dreadnoughtPositions = {
                Helper.getHardcodedPositionFromGUID('1a3c82', -26.300087, 1.1126014, 18.6999569),
                Helper.getHardcodedPositionFromGUID('a8f306', -28.7001171, 1.11260128, 18.6999683)
            },
            agents = {"7751c8", "afa978"},
            agentPositions = {
                Helper.getHardcodedPositionFromGUID('7751c8', -17.0, 1.11060047, 20.3),
                Helper.getHardcodedPositionFromGUID('afa978', -18.3, 1.11060047, 20.3)
            },
            swordmaster = "ed3490",
            councilToken = "f19a48",
            fourPlayerVictoryToken = "a6c2e0",
            fourPlayerVictoryTokenInitialPosition = Helper.getHardcodedPositionFromGUID('a6c2e0', -13.0, 1.31223142, 21.85),
            scoreMarker = "175a0a",
            scoreMarkerInitialPosition = Helper.getHardcodedPositionFromGUID('175a0a', 10.3999805, 1.16369891, -14.000104),
            controlMarkerBag = '61453d',
            troops = {
                "8b2acc",
                "6c2b85",
                "81763a",
                "fd5673",
                "8bb1e6",
                "1bbf1c",
                "0fa955",
                "465c38",
                "4fd2dd",
                "488161",
                "5cfef7",
                "af7cd0"
            },
            forceMarker = '2d1d17',
            drawDeckZone = "4f08fc",
            discardZone = "e07493",
            trash = "ea3fe1",
            tleilaxToken = "2bfc39",
            tleilaxTokenInitalPosition = Helper.getHardcodedPositionFromGUID('2bfc39', 0.54461664, 0.877500236, 22.0549927),
            researchToken = "39e0f3",
            researchTokenInitalPosition = Helper.getHardcodedPositionFromGUID('39e0f3', 0.369999915, 0.880000353, 18.2351761),
            freighter = "e9096d",
            leaderPos = Helper.getHardcodedPositionFromGUID('66cdbb', -19.0, 1.25, 17.5),
            firstPlayerInitialPosition = Helper.getHardcodedPositionFromGUID('346e0d', -14.0, 1.5, 19.7) + Vector(0, -0.4, 0),
            endTurnButton = "895594",
            atomicsToken = "d5ff47",
        },
        Blue = {
            board = "77ca63",
            colorband = "46abc5",
            spice = "9cc286",
            solari = "fa5236",
            water = "0afaeb",
            persuasion = "8cb9be",
            strength = "aa3bb9",
            leaderZone = "681774",
            dreadnoughts = {"82789e", "60f208"},
            dreadnoughtPositions = {
                Helper.getHardcodedPositionFromGUID('82789e', -26.3001251, 1.11260128, -4.3000555),
                Helper.getHardcodedPositionFromGUID('60f208', -28.7001362, 1.11260128, -4.300068)
            },
            agents = {"64d013", "106d8b"},
            agentPositions = {
                Helper.getHardcodedPositionFromGUID('64d013', -17.0, 1.11060059, -2.70000482),
                Helper.getHardcodedPositionFromGUID('106d8b', -18.3, 1.11060035, -2.7)
            },
            swordmaster = "a78ad7",
            councilToken = "f5b14a",
            fourPlayerVictoryToken = "311255",
            fourPlayerVictoryTokenInitialPosition = Helper.getHardcodedPositionFromGUID('311255', -13.0, 1.11223137, -1.1499995),
            scoreMarker = "7fa9a7",
            scoreMarkerInitialPosition = Helper.getHardcodedPositionFromGUID('7fa9a7', 10.4000244, 1.363665, -14.0000944),
            controlMarkerBag = '8627e0',
            troops = {
                "2a5276",
                "f2c21f",
                "5fba3c",
                "bc6e74",
                "f60d9c",
                "f65e5d",
                "46c1c6",
                "49afee",
                "1bbc16",
                "98e3a6",
                "bb23cc",
                "694553"
            },
            forceMarker = 'f22e20',
            drawDeckZone = "907f66",
            discardZone = "26bf8b",
            trash = "52a539",
            tleilaxToken = "96607f",
            tleilaxTokenInitalPosition = Helper.getHardcodedPositionFromGUID('96607f', 0.544616938, 0.8800002, 22.75),
            researchToken = "292658",
            researchTokenInitalPosition = Helper.getHardcodedPositionFromGUID('292658', 0.369999766, 0.8775002, 18.9369965),
            freighter = "68e424",
            leaderPos = Helper.getHardcodedPositionFromGUID('681774', -19.0, 1.25506675, -5.5),
            firstPlayerInitialPosition = Helper.getHardcodedPositionFromGUID('1fc559', -14.0, 1.501278, -3.3) + Vector(0, -0.4, 0),
            endTurnButton = "9eeccd",
            atomicsToken = "700023",
        },
        Green = {
            board = "0bbae1",
            colorband = "c1aea4",
            spice = "22478f",
            solari = "e597dc",
            water = "fa9522",
            persuasion = "ac97c5",
            strength = "d880f7",
            leaderZone = "cf1486",
            dreadnoughts = {"a15087", "734250"},
            dreadnoughtPositions = {
                Helper.getHardcodedPositionFromGUID('a15087', 26.2999134, 1.112601, 18.6999683),
                Helper.getHardcodedPositionFromGUID('734250', 28.6998959, 1.11260128, 18.69996)
            },
            agents = {"66ae45", "bceb0e"},
            agentPositions = {
                Helper.getHardcodedPositionFromGUID('66ae45', 17.0, 1.11060047, 20.2999935),
                Helper.getHardcodedPositionFromGUID('bceb0e', 18.3, 1.11060047, 20.3)
            },
            swordmaster = "fb1629",
            councilToken = "a0028d",
            fourPlayerVictoryToken = "66444c",
            fourPlayerVictoryTokenInitialPosition = Helper.getHardcodedPositionFromGUID('66444c', 13.0, 1.3122313, 21.85),
            scoreMarker = "7bae32",
            scoreMarkerInitialPosition = Helper.getHardcodedPositionFromGUID('7bae32', 10.3998375, 0.9637382, -13.9999037),
            controlMarkerBag = 'ad6b92',
            troops = {
                "167fd4",
                "60c92d",
                "b614cc",
                "f433eb",
                "08be0c",
                "b48887",
                "8e22cc",
                "866a9c",
                "060aee",
                "86396c",
                "b5e9ae",
                "fc9c62"
            },
            forceMarker = 'a1a9a7',
            drawDeckZone = "6d8a2e",
            discardZone = "2298aa",
            trash = "4060b5",
            tleilaxToken = "63d39f",
            tleilaxTokenInitalPosition = Helper.getHardcodedPositionFromGUID('63d39f', 1.24461615, 0.8800001, 22.05),
            researchToken = "658b17",
            researchTokenInitalPosition = Helper.getHardcodedPositionFromGUID('658b17', 0.369999856, 0.877500236, 20.34),
            freighter = "34281d",
            leaderPos = Helper.getHardcodedPositionFromGUID('cf1486', 19.0, 1.18726385, 17.5),
            firstPlayerInitialPosition = Helper.getHardcodedPositionFromGUID('59523d', 14.0, 1.45146358, 19.7) + Vector(0, -0.4, 0),
            endTurnButton = "96aa58",
            atomicsToken = "0a22ec",
        },
        Yellow = {
            board = "fdd5f9",
            colorband = "8523f2",
            spice = "78fb8a",
            solari = "c5c4ef",
            water = "f217d0",
            persuasion = "aa79bf",
            strength = "6f007c",
            leaderZone = "a677e0",
            dreadnoughts = {"5469fb", "71a414"},
            dreadnoughtPositions = {
                Helper.getHardcodedPositionFromGUID('5469fb', 26.29987, 1.11260128, -4.30003),
                Helper.getHardcodedPositionFromGUID('71a414', 28.699873, 1.11260128, -4.30005455)
            },
            agents = {"5068c8", "67b476"},
            agentPositions = {
                Helper.getHardcodedPositionFromGUID('5068c8', 17.0, 1.11060047, -2.70000386),
                Helper.getHardcodedPositionFromGUID('67b476', 18.3, 1.11060047, -2.699999)
            },
            swordmaster = "635c49",
            councilToken = "1be491",
            fourPlayerVictoryToken = "4e8873",
            fourPlayerVictoryTokenInitialPosition = Helper.getHardcodedPositionFromGUID('4e8873', 13.0, 1.31223142, -1.14999926),
            scoreMarker = "f9ac91",
            scoreMarkerInitialPosition = Helper.getHardcodedPositionFromGUID('f9ac91', 10.4006586, 0.763735, -13.9985342),
            controlMarkerBag = 'b92a4c',
            troops = {
                "fbf8d2",
                "7c5b7b",
                "4d0dbf",
                "ef6da2",
                "d01e0b",
                "9b55e4",
                "ef9008",
                "734b6e",
                "4f4199",
                "1f5949",
                "3dc7ff",
                "b5d32e"
            },
            forceMarker = 'c2dd31',
            drawDeckZone = "e6cfee",
            discardZone = "6bb3b6",
            trash = "7d1e07",
            tleilaxToken = "d20bcf",
            tleilaxTokenInitalPosition = Helper.getHardcodedPositionFromGUID('d20bcf', 1.24461651, 0.880000234, 22.75),
            researchToken = "8988cf",
            researchTokenInitalPosition = Helper.getHardcodedPositionFromGUID('8988cf', 0.369999975, 0.877500236, 19.6394081),
            freighter = "8fa76f",
            leaderPos = Helper.getHardcodedPositionFromGUID('a677e0', 19.0, 1.17902148, -5.5),
            firstPlayerInitialPosition = Helper.getHardcodedPositionFromGUID('e9a44c', 14.0, 1.44851, -3.3) + Vector(0, -0.4, 0),
            endTurnButton = "3d1b90",
            atomicsToken = "7e10a9",
        }
    },
    playBoards = {},
    nextPlayer = nil,
    occupationCooldown = {},
})

---
function PlayBoard.onLoad(state)
    for color, unresolvedContent in pairs(PlayBoard.unresolvedContentByColor) do
        local alive = true
        local subState = nil
        if state.PlayBoard then
            subState = state.PlayBoard[color]
            alive = subState ~= nil
        end
        if alive then
            PlayBoard.playBoards[color] = PlayBoard.new(color, unresolvedContent, state, subState)
        end
    end
    PlayBoard.unresolvedContentByColor = nil

    if state.settings then
        PlayBoard._transientSetUp(state.settings)
    end
end

---
function PlayBoard.onSave(state)
    state.PlayBoard = Helper.map(PlayBoard.playBoards, function (color, playBoard)
        local resourceValues = {}
        for _, resourceName in ipairs(PlayBoard.ALL_RESOURCE_NAMES) do
            if playBoard[resourceName] then
                resourceValues[resourceName] = playBoard[resourceName]:get()
            end
        end
        return {
            opponent = playBoard.opponent,
            resources = resourceValues,
            leader = playBoard.leader and playBoard.leader.name,
            lastPhase = playBoard.lastPhase,
            revealed = playBoard.revealed,
        }
    end)
end

---
function PlayBoard.new(color, unresolvedContent, state, subState)
    local playBoard = Helper.createClassInstance(PlayBoard, {
        color = color,
        score = 0,
        scorePositions = {},
    })
    playBoard.content = Helper.resolveGUIDs(false, unresolvedContent)

    Helper.noPhysicsNorPlay(
        playBoard.content.board,
        playBoard.content.colorband,
        playBoard.content.endTurnButton)

    if subState then
        playBoard.opponent = subState.opponent

        playBoard.lastPhase = subState.lastPhase
        playBoard.revealed = subState.revealed

        -- Zones can't be queried right now.
        Helper.onceFramesPassed(1).doAfter(function ()
            playBoard.leaderCard = Helper.getDeckOrCard(playBoard.content.leaderZone)
            if playBoard.leaderCard then
                if playBoard.opponent == "rival" then
                    playBoard.leader = Rival.newRival(color, subState.leader)
                else
                    playBoard.leader = Leader.newLeader(subState.leader)
                end
                if playBoard.leader.transientSetUp then
                    playBoard.leader.transientSetUp(color, state.settings)
                end
            end
        end)
    else
        Helper.noPlay(
            playBoard.content.freighter,
            playBoard.content.tleilaxToken,
            playBoard.content.researchToken
        )
        Helper.noPhysicsNorPlay(
            playBoard.content.councilToken,
            playBoard.content.scoreMarker,
            playBoard.content.forceMarker
        )
    end

    playBoard.content.board.interactable = false
    playBoard.content.endTurnButton.interactable = false

    -- FIXME Why this offset? In particular, why the Z component introduces an asymmetry?
    local offset = Vector(0, 0.55, 5.1)
    local centerPosition = playBoard.content.board.getPosition() + offset

    for _, resourceName in ipairs(PlayBoard.ALL_RESOURCE_NAMES) do
        local token = playBoard.content[resourceName]
        local value = subState and subState.resources[resourceName] or 0
        playBoard[resourceName] = Resource.new(token, color, resourceName, value)
    end

    Helper.createTransientAnchor("InstructionTextAnchor", playBoard.content.board.getPosition() + playBoard:_newSymmetricBoardPosition(12, -0.5, -8)).doAfter(function (anchor)
        playBoard.instructionTextAnchor = anchor
    end)

    local startup = not subState
    playBoard.agentCardPark = playBoard:_createAgentCardPark(Vector(0, 0, 4))
    playBoard.revealCardPark = playBoard:_createAgentCardPark(Vector(0, 0, 0))
    playBoard.agentPark = playBoard:_createAgentPark(unresolvedContent.agentPositions, startup)
    playBoard.dreadnoughtPark = playBoard:_createDreadnoughtPark(unresolvedContent.dreadnoughtPositions, startup)
    playBoard.supplyPark = playBoard:_createSupplyPark(centerPosition, startup)
    playBoard:_generatePlayerScoreboardPositions()
    playBoard.scorePark = playBoard:_createPlayerScorePark()
    playBoard.techPark = playBoard:_createTechPark(centerPosition)

    Helper.registerEventListener("locale", function ()
        playBoard:_createButtons()
    end)

    return playBoard
end

---
function PlayBoard.setUp(settings, activeOpponents)
    for color, playBoard in pairs(PlayBoard.playBoards) do
        playBoard:_cleanUp(false, not settings.riseOfIx, not settings.immortality)
        if activeOpponents[color] then
            playBoard.opponent = activeOpponents[color]
            if playBoard.opponent ~= "rival" then
                playBoard.opponent = "human"
                Deck.generateStarterDeck(playBoard.content.drawDeckZone, settings.immortality, settings.epicMode).doAfter(Helper.shuffleDeck)
                Deck.generateStarterDiscard(playBoard.content.discardZone, settings.immortality, settings.epicMode)
            else
                if Hagal.getRivalCount() == 1 then
                    playBoard.content.scoreMarker.destruct()
                    playBoard.content.scoreMarker = nil
                end
            end

            if settings.numberOfPlayers < 4 or settings.goTo11 then
                playBoard.content.fourPlayerVictoryToken.destruct()
                playBoard.content.fourPlayerVictoryToken = nil
            end

            playBoard:_createButtons()

            playBoard:updatePlayerScore()
        else
            playBoard:_tearDown()
        end
    end

    PlayBoard._transientSetUp(settings)
end

---
function PlayBoard._transientSetUp(settings)
    -- I don't like it, but at least things are now explicit.
    Helper.registerEventListener("loaded", function (moduleName)
        if moduleName == "TurnControl" then
            for _, playBoard in pairs(PlayBoard._getPlayBoards(true)) do
                playBoard:_createButtons()
            end
        end
    end)

    Helper.registerEventListener("phaseStart", function (phase, firstPlayer)
        if phase == "leaderSelection" or phase == "roundStart" then
            local playBoard = PlayBoard.getPlayBoard(firstPlayer)
            MainBoard.getFirstPlayerMarker().setPositionSmooth(playBoard.content.firstPlayerInitialPosition, false, false)
        end

        if phase == "roundStart" then
            for color, playBoard in pairs(PlayBoard._getPlayBoards()) do
                if playBoard.opponent ~= "rival" then
                    local cardAmount = PlayBoard.hasTech(color, "holtzmanEngine") and 6 or 5
                    playBoard:drawCards(cardAmount)
                end
                if PlayBoard.hasTech(color, "shuttleFleet") then
                    playBoard.leader.resources(color, "solari", 2)
                end
            end
        end

        if phase == "recall" then
            for _, playBoard in pairs(PlayBoard._getPlayBoards()) do
                playBoard:_recall()
            end
        end
    end)

    Helper.registerEventListener("phaseEnd", function (phase)
        if phase == "leaderSelection" then
            for color, playBoard in pairs(PlayBoard._getPlayBoards()) do
                playBoard.leader.setUp(color, settings)
                playBoard.leader.prepare(color, settings)
            end
        elseif phase == "endgame" then
            MainBoard.getFirstPlayerMarker().destruct()
        end
        for _, playBoard in pairs(PlayBoard._getPlayBoards()) do
            assert(playBoard.instructionTextAnchor)
            Helper.clearButtons(playBoard.instructionTextAnchor)
        end
        PlayBoard._setActivePlayer(nil, nil)
    end)

    Helper.registerEventListener("playerTurn", function (phase, color, refreshing)
        local playBoard = PlayBoard.getPlayBoard(color)

        PlayBoard.occupationCooldown = {}

        if PlayBoard.isHuman(color) and not refreshing then
            -- FIXME To naive, won't work for multiple agents in a single turn (weirding way).
            -- FIXME Cards put down too early (hidden).
            playBoard.alreadyPlayedCards = Helper.filter(Park.getObjects(playBoard.agentCardPark), function (card)
                return (Types.isImperiumCard(card) or Types.isIntrigueCard(card)) and not card.is_face_down
            end)
        end

        for otherColor, otherPlayBoard in pairs(PlayBoard._getPlayBoards()) do
            if PlayBoard.isHuman(otherColor) then
                local instruction = (playBoard.leader or Action).instruct(phase, color == otherColor) or "-"
                if otherPlayBoard.instructionTextAnchor then
                    Helper.clearButtons(otherPlayBoard.instructionTextAnchor)
                    Helper.createAbsoluteButtonWithRoundness(otherPlayBoard.instructionTextAnchor, 1, {
                        click_function = Helper.registerGlobalCallback(),
                        label = instruction,
                        position = otherPlayBoard.instructionTextAnchor.getPosition() + Vector(0, 0.5, 0),
                        width = 0,
                        height = 0,
                        font_size = 200,
                        scale = Vector(1, 1, 1),
                        color = { 0, 0, 0, 0.90 },
                        font_color = Color.fromString("White")
                    })
                end
            end
        end

        if phase == "combatEnd" then
            -- Hagal has it own listener to do more things.
            if PlayBoard.isHuman(color) then
                PlayBoard.collectReward(color)
            end
        end

        PlayBoard._setActivePlayer(phase, color, refreshing)
    end)

    Helper.registerEventListener("combatUpdate", function (forces)
        PlayBoard.combatPassCountdown = Helper.count(forces, function (_, v)
            return v > 0
        end)
    end)

    Helper.registerEventListener("agentSent", function (color, spaceName)
        if PlayBoard.isHuman(color) then
            -- Do it after the clean up done in TechMarket.
            Helper.onceFramesPassed(1).doAfter(function ()
                local cards = PlayBoard.getCardsPlayedThisTurn(color)
                for _, card in ipairs(cards) do
                    local cardName = Helper.getID(card)
                    if cardName == "appropriate" then
                        if InfluenceTrack.hasFriendship(color, "emperor") then
                            TechMarket.registerAcquireTechOption(color, cardName .. "TechBuyOption", "solari", 0)
                        end
                    elseif cardName == "ixianEngineer" then
                        TechMarket.registerAcquireTechOption(color, cardName .. "TechBuyOption", "spice", 0)
                    elseif cardName == "machineCulture" then
                        TechMarket.registerAcquireTechOption(color, cardName .. "TechBuyOption", "spice", 0)
                    end
                end
            end)
        end
    end)

    Helper.registerEventListener("influence", function (faction, color, newRank)
        if PlayBoard.isHuman(color) then
            local cards = PlayBoard.getCardsPlayedThisTurn(color)
            for _, card in ipairs(cards) do
                local cardName = Helper.getID(card)
                if cardName == "appropriate" then
                    if InfluenceTrack.hasFriendship(color, "emperor") then
                        TechMarket.registerAcquireTechOption(color, cardName .. "TechBuyOption", "solari", 0)
                    end
                end
            end
        end
    end)
end

---
function PlayBoard:_recall()
    local minimicFilm = PlayBoard.hasTech(self.color, "minimicFilm")
    local restrictedOrdnance = PlayBoard.hasTech(self.color, "restrictedOrdnance")
    local councilSeat = PlayBoard.hasHighCouncilSeat(self.color)

    self.revealed = false
    self.persuasion:set((councilSeat and 2 or 0) + (minimicFilm and 1 or 0))
    self.strength:set((restrictedOrdnance and councilSeat) and 4 or 0)

    self:_createButtons()

    local stackHeight = 0
    local nextDiscardPosition = function ()
        stackHeight = stackHeight + 1
        return self.content.discardZone.getPosition() + Vector(0, stackHeight * 0.5, 0)
    end

    -- Send all played cards to the discard, save those which shouldn't.
    Helper.forEach(Helper.filter(Park.getObjects(self.agentCardPark), Types.isImperiumCard), function (_, card)
        local cardName = Helper.getID(card)
        if cardName == "foldspace" then
            Reserve.recycleFoldspaceCard(card)
        elseif Helper.isElementOf(cardName, {"seekAllies", "powerPlay", "treachery"}) then
            MainBoard.trash(card)
        else
            card.setPosition(nextDiscardPosition())
        end
    end)

    -- Send all revealed cards to the discard.
    Helper.forEach(Helper.filter(Park.getObjects(self.revealCardPark), Types.isImperiumCard), function (i, card)
        card.setPosition(nextDiscardPosition())
    end)

    -- Send all played intrigues to their discard.
    local playedIntrigueCards = Helper.concatTables(
        Helper.filter(Park.getObjects(self.agentCardPark), Types.isIntrigueCard),
        Helper.filter(Park.getObjects(self.revealCardPark), Types.isIntrigueCard)
    )
    Helper.forEach(playedIntrigueCards, function (i, card)
        Intrigue.discard(card)
    end)

    -- Flip any used tech.
    for _, techTile in ipairs(Park.getObjects(self.techPark)) do
        if techTile.hasTag("Tech") and techTile.is_face_down then
            techTile.flip()
        end
    end
end

---
function PlayBoard._setActivePlayer(phase, color, refreshing)
    local indexedColors = { "Green", "Yellow", "Blue", "Red" }
    local finalColors = {
        Color(9 / 255, 194 / 255, 0 / 255),
        Color(255 / 255, 247 / 255, 0 / 255),
        Color(31 / 255, 135 / 255, 255 / 255),
        Color(237 / 255, 0 / 255, 0 / 255),
    }
    for i, otherColor in ipairs(indexedColors) do
        local playBoard = PlayBoard.playBoards[otherColor]
        if playBoard then
            local effectIndex = 0 -- black index (no color actually)
            if otherColor == color then
                effectIndex = i
                if playBoard.opponent == "rival" and not refreshing then
                    Hagal.activate(phase, color)
                end
            end
            playBoard.content.colorband.setColorTint(effectIndex > 0 and finalColors[effectIndex] or "Black")
        end
    end

    if phase ~= "leaderSelection" then
        PlayBoard._updateControlButtons()
    end
end

---
function PlayBoard._updateControlButtons()
    for color, playBoard  in pairs(PlayBoard._getPlayBoards()) do
        if color == TurnControl.getCurrentPlayer() then
            local player = Helper.findPlayerByColor(color)
            if player and player.seated then
                playBoard:_createEndOfTurnButton()
            else
                playBoard:_createTakePlaceButton()
            end
        elseif TurnControl.isHotSeatEnabled() then
            playBoard:_createTakePlaceButton()
        else
            Helper.clearButtons(playBoard.content.endTurnButton)
        end
    end
end

---
function PlayBoard.createEndOfTurnButton(color)
    PlayBoard.playBoards[color]:_createEndOfTurnButton()
end

---
function PlayBoard:_createEndOfTurnButton()
    Helper.clearButtons(self.content.endTurnButton)
    local action = function ()
        self.content.endTurnButton.AssetBundle.playTriggerEffect(0)
        TurnControl.endOfTurn()
        Helper.clearButtons(self.content.endTurnButton)
    end
    local callback = self:_createExclusiveCallback(action)
    self.content.endTurnButton.createButton({
        click_function = callback,
        position = Vector(0, 0.6, 0),
        label = I18N("endTurn"),
        width = 1500,
        height = 1500,
        color = { 0, 0, 0, 0 },
        font_size = 450,
        font_color = Helper.concatTables(self:_getFontColor(), { 100 })
    })
end

---
function PlayBoard:_createTakePlaceButton()
    Helper.clearButtons(self.content.endTurnButton)
    self.content.endTurnButton.createButton({
        click_function = self:_createSharedCallback(function (_, color, _)
            self.content.endTurnButton.AssetBundle.playTriggerEffect(0)
            local player = Helper.findPlayerByColor(color)
            if player then
                player.changeColor(self.color)
                Helper.onceFramesPassed(1).doAfter(PlayBoard._updateControlButtons)
            end
        end),
        position = Vector(0, 0.6, 0),
        label = I18N("takePlace"),
        width = 1500,
        height = 1500,
        color = { 0, 0, 0, 0 },
        font_size = 450,
        font_color = Helper.concatTables(self:_getFontColor(), { 100 })
    })
end

---
function PlayBoard.acceptTurn(phase, color)
    assert(color)
    local playBoard = PlayBoard.getPlayBoard(color)
    local accepted = false

    if phase == 'leaderSelection' then
        accepted = playBoard.leader == nil
    elseif phase == 'gameStart' then
        accepted = playBoard.lastPhase ~= phase and playBoard.leader.instruct(phase, color)
    elseif phase == 'roundStart' then
        accepted = playBoard.lastPhase ~= phase and playBoard.leader.instruct(phase, color)
    elseif phase == 'arrakeenScouts' then
        -- TODO We need something more elaborate.
        accepted = true
    elseif phase == 'playerTurns' then
        accepted = PlayBoard.couldSendAgentOrReveal(color)
        if accepted and Hagal.getRivalCount() == 1 and PlayBoard.isRival(color) then
            accepted = not PlayBoard.playBoards[TurnControl.getFirstPlayer()].revealed
        end
    elseif phase == 'combat' then
        if Combat.isInCombat(color) and Combat.isFormalCombatPhaseEnabled() then
            Helper.dump(color, "->", PlayBoard.combatPassCountdown, "/", #PlayBoard._getPotentialCombatIntrigues(color))
            accepted = PlayBoard.combatPassCountdown > 0 and not PlayBoard.isRival(color) and #PlayBoard._getPotentialCombatIntrigues(color) > 0
            PlayBoard.combatPassCountdown = PlayBoard.combatPassCountdown - 1
        end
    elseif phase == 'combatEnd' then
        accepted = playBoard.lastPhase ~= phase and Combat.getRank(color) ~= nil
    elseif phase == 'makers' then
        accepted = false
    elseif phase == 'recall' then
        accepted = false
    elseif phase == 'endgame' then
        accepted = playBoard.lastPhase ~= phase
    else
        accepted = playBoard.lastPhase ~= phase
    end

    playBoard.lastPhase = phase
    return accepted
end

---
function PlayBoard.withLeader(action)
    return function (source, color, ...)
        local leader = PlayBoard.getLeader(color)
        if leader then
            -- Replace the source by the leader.
            action(leader, color, ...)
        else
            Dialog.broadcastToColor(I18N('noLeader'), color, "Purple")
        end
    end
end

---
function PlayBoard.collectReward(color)
    local conflictName = Combat.getCurrentConflictName()
    local rank = Combat.getRank(color).value
    ConflictCard.collectReward(color, conflictName, rank)
    if rank == 1 then
        local leader = PlayBoard.getLeader(color)
        if PlayBoard.hasTech(color, "windtraps") then
            leader.resources(color, "water", 1)
        end

        local dreadnoughts = Combat.getDreadnoughtsInConflict(color)
        if #dreadnoughts > 0 then
            Dialog.showInfoDialog(color, I18N("dreadnoughtMandatoryOccupation"))
        end
    end
end

---
function PlayBoard.getPlayBoard(color)
    assert(color)
    assert(#Helper.getKeys(PlayBoard.playBoards) > 0, "No playBoard at all: too soon!")
    local playBoard = PlayBoard.playBoards[color]
    assert(playBoard, "No playBoard for color " .. tostring(color))
    return playBoard
end

---
function PlayBoard._getPlayBoards(filterOutRival)
    assert(#Helper.getKeys(PlayBoard.playBoards) > 0, "No playBoard at all: too soon!")
    local filteredPlayBoards = {}
    for color, playBoard in pairs(PlayBoard.playBoards) do
        if playBoard.opponent and (not filterOutRival or playBoard.opponent ~= "rival") then
            filteredPlayBoards[color] = playBoard
        end
    end
    assert(#Helper.getKeys(filteredPlayBoards) > 0, "No playBoard at all in the end: still too soon! (Lazy PlayBoard setUp?)")
    return filteredPlayBoards
end

---
function PlayBoard.getActivePlayBoardColors(filterOutRival)
    return Helper.getKeys(PlayBoard._getPlayBoards(filterOutRival))
end

---
function PlayBoard._getBoard(color)
    return PlayBoard.getContent(color).board
end

---
function PlayBoard:_createAgentCardPark(globalOffset)
    local offsets = {
        Red = Vector(13, 0.69, -5),
        Blue = Vector(13, 0.69, -5),
        Green = Vector(-13, 0.69, -5),
        Yellow = Vector(-13, 0.69, -5)
    }
    local step = 0
    if PlayBoard.isRight(self.color) then
        step = 2.5
    end
    if PlayBoard.isLeft(self.color) then
        step = -2.5
    end
    local origin = self.content.board.getPosition() + offsets[self.color] + globalOffset

    local slots = {}
    for i = 0, 11 do
        table.insert(slots, origin + Vector(i * step, 0, 0))
    end

    local park = Park.createCommonPark({ "Imperium", "Intrigue" }, slots, Vector(2.4, 0.5, 3.2), Vector(0, 180, 0))
    park.tagUnion = true
    park.smooth = false
    return park
end

---
function PlayBoard:_createAgentPark(agentPositions, startup)
    -- Extrapolate two other positions (for the swordmaster and the mentat)
    -- from the positions of the two existing agents.
    assert(#agentPositions == 2)
    local p1 = agentPositions[1]
    local p2 = agentPositions[2]
    local slots = {
        p1,
        p2,
        p2 + (p2 - p1),
        p2 + (p2 - p1) * 2
    }

    local park = Park.createCommonPark({ self.color, "Agent" }, slots, Vector(1, 3, 0.5))
    if startup then
        for i, agent in ipairs(self.content.agents) do
            agent.setPosition(slots[i])
        end
    end
    return park
end

---
function PlayBoard:_createDreadnoughtPark(dreadnoughtPositions, startup)
    local park = Park.createCommonPark({ self.color, "Dreadnought" }, dreadnoughtPositions, Vector(1, 3, 0.5))
    if startup then
        for i, dreadnought in ipairs(self.content.dreadnoughts) do
            dreadnought.setPosition(dreadnoughtPositions[i])
        end
    end
    return park
end

---
function PlayBoard:_createSupplyPark(centerPosition, startup)
    local allSlots = {}
    local slots = {}
    for i = 1, 4 do
        for j = 1, 4 do
            local x = (i - 2.5) * 0.5
            local z = (j - 2.5) * 0.5
            local slot = Vector(x, 0.29, z):rotateOver('y', -45) + centerPosition
            table.insert(allSlots, slot)
            if i < 3 or j < 3 then
                table.insert(slots, slot)
            end
        end
    end

    local supplyZone = Park.createTransientBoundingZone(45, Vector(0.4, 0.35, 0.4), allSlots)

    if startup then
        for i, troop in ipairs(self.content.troops) do
            troop.setLock(true)
            troop.setPosition(slots[i])
            troop.setRotation(Vector(0, 45, 0))
        end
    end

    return Park.createPark(
        "Supply" .. self.color,
        slots,
        Vector(0, -45, 0),
        { supplyZone },
        { "Troop", self.color },
        nil,
        true,
        true)
end

---
function PlayBoard:_createTechPark(centerPosition)
    local color = self.color
    local slots = {}
    for h = 1, 3 do
        for i = 1, 2 do
            for j = 3, 1, -1 do
                local x = (i - 1.5) * 3 + 6
                if PlayBoard.isLeft(color) then
                    x = -x
                end
                local z = (j - 2) * 2 + 0.4
                local slot = Vector(x, 0.5 * h, z) + centerPosition
                table.insert(slots, slot)
            end
        end
    end
    return Park.createCommonPark({ "Tech" }, slots, Vector(3, 1, 2), Vector(0, 180, 0))
end

---
function PlayBoard:_generatePlayerScoreboardPositions()
    assert(self.content.scoreMarker, self.color .. ": no score marker!")
    local origin = self.content.scoreMarkerInitialPosition

    -- Avoid collision between markers by giving a different height to each.
    local heights = {
        Green = 1,
        Yellow = 1.5,
        Blue = 2,
        Red = 2.5,
    }

    self.scorePositions = {}
    for i = 0, 14 do
        self.scorePositions[i] = {
            origin.x,
            1 + heights[self.color],
            origin.z + i * 1.165
        }
    end
end

---
function PlayBoard:_createPlayerScorePark()
    local origin = self.content.fourPlayerVictoryTokenInitialPosition

    local direction = 1
    if PlayBoard.isLeft(self.color) then
        direction = -1
    end

    local slots = {}
    for i = 1, 18 do
        slots[i] = Vector(
            origin.x + (i - 1) * 1.092 * direction,
            origin.y,
            origin.z)
    end

    return Park.createCommonPark({ "VictoryPointToken" }, slots, Vector(1, 0.2, 1), Vector(0, 180, 0))
end

---
function PlayBoard:updatePlayerScore()
    if self.content.scoreMarker then
        local rectifiedScore = self:getScore()
        rectifiedScore = rectifiedScore > 13 and rectifiedScore - 10 or rectifiedScore
        local scoreMarker = self.content.scoreMarker
        scoreMarker.setLock(false)
        scoreMarker.setPositionSmooth(self.scorePositions[rectifiedScore])
    end
end

---
function PlayBoard.onObjectEnterScriptingZone(zone, object)
    for color, playBoard in pairs(PlayBoard.playBoards) do
        if playBoard.opponent then
            if Helper.isElementOf(zone, playBoard.scorePark.zones) then
                if Types.isVictoryPointToken(object) then
                    playBoard:updatePlayerScore()
                    local controlableSpace = MainBoard.findControlableSpaceFromConflictName(Helper.getID(object))
                    if controlableSpace and not PlayBoard.occupationCooldown[controlableSpace] then
                        MainBoard.occupy(controlableSpace, color)
                        PlayBoard.occupationCooldown[controlableSpace] = color
                    end
                end
            elseif Helper.isElementOf(zone, playBoard.agentPark.zones) then
                if Types.isMentat(object) then
                    object.addTag(color)
                    object.setColorTint(playBoard.content.swordmaster.getColorTint())
                end
            end
        end
    end
end

---
function PlayBoard.onObjectLeaveScriptingZone(zone, object)
    for _, playBoard in pairs(PlayBoard.playBoards) do
        if playBoard.opponent then
            if Helper.isElementOf(zone, playBoard.scorePark.zones) then
                if Types.isVictoryPointToken(object) then
                    playBoard:updatePlayerScore()
                end
            end
        end
    end
end

---
function PlayBoard:_tearDown()
    self:_cleanUp(true, true, true, true)
    PlayBoard.playBoards[self.color] = nil
end

---
function PlayBoard:_cleanUp(base, ix, immortality, full)
    local content = self.content

    local toBeRemoved = {}

    local collect = function (childName)
        local child = content[childName]
        if child then
            if type(child) == "table" then
                for _, leafChild in ipairs(child) do
                    table.insert(toBeRemoved, leafChild)
                end
            else
                table.insert(toBeRemoved, child)
            end
            content[childName] = nil
        end
    end

    if base then
        collect("swordmaster")
        collect("councilToken")
        collect("scoreMarker")
        collect("controlMarkerBag")
        collect("forceMarker")
        collect("endTurnButton")
        collect("fourPlayerVictoryToken")
        collect("agents")
        collect("troops")
        collect("spice")
        collect("solari")
        collect("water")
        collect("strength")
        collect("persuasion")
        collect("trash")
    end

    if ix then
        collect("dreadnoughts")
        collect("freighter")
        collect("atomicsToken")
    end

    if immortality then
        collect("tleilaxToken")
        collect("researchToken")
    end

    for _, object in ipairs(toBeRemoved) do
        if toBeRemoved then
            object.interactable = true
            object.destruct()
        end
    end

    for _, object in ipairs(toBeRemoved) do
        assert(object)
        object.interactable = true
        object.destruct()
    end

    if full then
        self:_clearButtons()
    end

    for _, object in ipairs(toBeRemoved) do
        assert(object)
        object.interactable = true
        object.destruct()
    end

    content = {}
end

---
function PlayBoard.findBoardColor(board)
    for color, _ in pairs(PlayBoard.playBoards) do
        if PlayBoard._getBoard(color) == board then
            return color
        end
    end
    return nil
end

---
function PlayBoard:_createExclusiveCallback(innerCallback)
    return Helper.registerGlobalCallback(function (object, color, altClick)
        if self.color == color or PlayBoard.isRival(self.color) or TurnControl.isHotSeatEnabled() then
            if not self.buttonsDisabled then
                self.buttonsDisabled = true
                Helper.onceTimeElapsed(0.5).doAfter(function ()
                    self.buttonsDisabled = false
                end)
                innerCallback(object, self.color, altClick)
            end
        else
            Dialog.broadcastToColor(I18N('noTouch'), color, "Purple")
        end
    end)
end

---
function PlayBoard:_createSharedCallback(innerCallback)
    return Helper.registerGlobalCallback(function (object, color, altClick)
        local legitimateColors = Helper.mapValues(
            TurnControl.getLegitimatePlayers(self.color),
            Helper.field("color"))
        if Helper.isElementOf(color, legitimateColors) then
            if not self.buttonsDisabled then
                self.buttonsDisabled = true
                Helper.onceTimeElapsed(0.5).doAfter(function ()
                    self.buttonsDisabled = false
                end)
                innerCallback(object, color, altClick)
            end
        else
            Dialog.broadcastToColor(I18N('noTouch'), color, "Purple")
        end
    end)
end

---
function PlayBoard:_clearButtons()
    Helper.clearButtons(self.content.board)
    if self.content.atomicsToken then
        Helper.clearButtons(self.content.atomicsToken)
    end
end

---
function PlayBoard:_getFontColor()
    return self.color == 'Yellow' and { 0.1, 0.1, 0.1 } or { 0.9, 0.9, 0.9 }
end

---
function PlayBoard:_createButtons()
    self:_clearButtons()

    local fontColor = self:_getFontColor()

    local board = self.content.board

    if self.opponent and PlayBoard.isHuman(self.color) then
        board.createButton({
            click_function = self:_createExclusiveCallback(function ()
                self:drawCards(1)
            end),
            label = I18N("drawOneCardButton"),
            position = self:_newOffsetedBoardPosition(-13.5, 0, 2.6),
            width = 1100,
            height = 250,
            font_size = 150,
            color = self.color,
            font_color = fontColor
        })

        board.createButton({
            click_function = self:_createExclusiveCallback(function ()
                self:_resetDiscard()
            end),
            label = I18N("resetDiscardButton"),
            position = self:_newOffsetedBoardPosition(-3.5, 0, 2.6),
            width = 1400,
            height = 250,
            font_size = 150,
            color = self.color,
            font_color = fontColor
        })

        board.createButton({
            click_function = Helper.registerGlobalCallback(),
            label = I18N("agentTurn"),
            position = self:_newSymmetricBoardPosition(-14.8, 0, -1),
            rotation = self:_newSymmetricBoardRotation(0, -90, 0),
            width = 0,
            height = 0,
            font_size = 280,
            color = { 0, 0, 0, 1 },
            font_color = self.color
        })

        board.createButton({
            click_function = self:_createExclusiveCallback(function ()
                if PlayBoard.isHuman(self.color) then
                    self:onRevealHand()
                end
            end),
            label = I18N("revealHandButton"),
            position = self:_newSymmetricBoardPosition(-14.8, 0, -5),
            rotation = self:_newSymmetricBoardRotation(0, -90, 0),
            width = 1600,
            height = 320,
            font_size = 280,
            color = self.color,
            font_color = fontColor
        })

        self:_createNukeButton()
    end
end

---
function PlayBoard:_createNukeButton()
    if self.content.atomicsToken then
        self.content.atomicsToken.createButton({
            click_function = self:_createExclusiveCallback(function ()
                if PlayBoard.isHuman(self.color) then
                    self:_nukeConfirm()
                end
            end),
            tooltip = I18N('atomics'),
            position = Vector(0, 0, 0),
            width = 700,
            height = 700,
            scale = Vector(3, 3, 3),
            font_size = 300,
            font_color = {1, 1, 1, 100},
            color = {0, 0, 0, 0}
        })
    end
end

---
function PlayBoard:onRevealHand()
    local currentPlayer = TurnControl.getCurrentPlayer()
    if currentPlayer and currentPlayer ~= self.color then
        Dialog.broadcastToColor(I18N("revealNotTurn"), self.color, "Pink")
    else
        if not self.revealed and self:stillHavePlayableAgents() then
            self:tryRevealHandEarly()
        else
            self:revealHand()
        end
    end
end

---
function PlayBoard:tryRevealHandEarly()
    local origin = PlayBoard.getPlayBoard(self.color):_newSymmetricBoardPosition(-8, 0, -4.5)

    local board = self.content.board

    local indexHolder = {}

    local function reset()
        Helper.removeButtons(board, Helper.getValues(indexHolder))
    end

    indexHolder.messageButtonIndex = Helper.createButton(board, {
        click_function = Helper.registerGlobalCallback(),
        label = I18N("revealEarlyConfirm"),
        position = origin,
        width = 0,
        height = 0,
        scale = {0.5, 0.5, 0.5},
        font_size = 500,
        font_color = self.color,
        color = {0, 0, 0, 1}
    })

    indexHolder.validateButtonIndex = Helper.createButton(board, {
        click_function = self:_createExclusiveCallback(function ()
            reset()
            self:revealHand()
        end),
        label = I18N('yes'),
        position = origin + Vector(-1, 0, 1),
        width = 1000,
        height = 600,
        scale = {0.5, 0.5, 0.5},
        font_size = 500,
        font_color = {1, 1, 1},
        color = "Green"
    })

    indexHolder.cancelButtonIndex = Helper.createButton(board, {
        click_function = self:_createExclusiveCallback(reset),
        label = I18N('no'),
        position = origin + Vector(1, 0, 1),
        width = 1000,
        height = 600,
        scale = {0.5, 0.5, 0.5},
        font_size = 500,
        font_color = {1, 1, 1},
        color = "Red"
    })
end

---
function PlayBoard:revealHand()
    local playedIntrigues = Helper.filter(Park.getObjects(self.agentCardPark), Types.isIntrigueCard)
    local playedCards = Helper.filter(Park.getObjects(self.agentCardPark), Types.isImperiumCard)

    local properCard = function (card)
        --[[
            We leave the sister card in the player's hand to simplify things and
            make clear to the player that the card must be manually revealed.
        ]]
        assert(card)
        return Types.isImperiumCard(card) and Helper.getID(card) ~= "beneGesseritSister"
    end

    local revealedCards = Helper.filter(Player[self.color].getHandObjects(), properCard)
    local alreadyRevealedCards = Helper.filter(Park.getObjects(self.revealCardPark), properCard)
    local allRevealedCards = Helper.concatTables(revealedCards, alreadyRevealedCards)

    -- FIXME The agent could have been removed (e.g. Kwisatz Haderach)
    local techNegotiation = MainBoard.hasAgentInSpace("techNegotiation", self.color)
    local hallOfOratory = MainBoard.hasAgentInSpace("hallOfOratory", self.color)

    local minimicFilm = PlayBoard.hasTech(self.color, "minimicFilm")
    local restrictedOrdnance = PlayBoard.hasTech(self.color, "restrictedOrdnance")
    local councilSeat = PlayBoard.hasHighCouncilSeat(self.color)
    local artillery = PlayBoard.hasTech(self.color, "artillery")

    local intrigueCardContributions = IntrigueCard.evaluatePlot(self.color, playedIntrigues, allRevealedCards, artillery)
    local imperiumCardContributions = ImperiumCard.evaluateReveal(self.color, playedCards, allRevealedCards, artillery)

    self.persuasion:set(
        (intrigueCardContributions.persuasion or 0) +
        (imperiumCardContributions.persuasion or 0) +
        (techNegotiation and 1 or 0) +
        (hallOfOratory and 1 or 0) +
        (councilSeat and 2 or 0) +
        (minimicFilm and 1 or 0))

    self.strength:set(
        (imperiumCardContributions.strength or 0) +
        ((restrictedOrdnance and councilSeat) and 4 or 0))

    if false then
        self.leader.troops(self.color, "supply", "tanks",
            imperiumCardContributions.specimens or 0)
    end

    Park.putObjects(revealedCards, self.revealCardPark)

    Helper.emitEvent("reveal", self.color)

    self.revealed = true
end

---
function PlayBoard:stillHavePlayableAgents()
    return #Park.getObjects(self.agentPark) > 0
end

---
function PlayBoard.getCardsPlayedThisTurn(color)
    local playBoard = PlayBoard.getPlayBoard(color)

    local playedCards = Helper.filter(Park.getObjects(playBoard.agentCardPark), function (card)
        return Types.isImperiumCard(card) or Types.isIntrigueCard(card)
    end)

    return (Set.newFromList(playedCards) - Set.newFromList(playBoard.alreadyPlayedCards or {})):toList()
end

---
function PlayBoard.hasPlayedThisTurn(color, cardName)
    for _, card in ipairs(PlayBoard.getCardsPlayedThisTurn(color)) do
        if Helper.getID(card) == cardName then
            return true
        end
    end
    return false
end

---
function PlayBoard.couldSendAgentOrReveal(color)
    local playBoard = PlayBoard.getPlayBoard(color)
    if playBoard.opponent == "rival" then
        return playBoard:stillHavePlayableAgents()
    else
        return not playBoard.revealed
    end
end

---
function PlayBoard:tryToDrawCards(count)
    local continuation = Helper.createContinuation("PlayBoard:tryToDrawCards")

    if not self.drawCardsCoalescentQueue then

        local function coalesce(c1, c2)
            return {
                parameteredContinuations = Helper.concatTables(c1.parameteredContinuations, c2.parameteredContinuations),
                count = c1.count + c2.count
            }
        end

        local function handle(c)
            local runAllContinuations = function (_)
                for _, parameteredContinuation in ipairs(c.parameteredContinuations) do
                    parameteredContinuation.continuation.run(parameteredContinuation.parameter)
                end
            end

            if c.count > 0 then
                self:_tryToDrawCards(c.count).doAfter(runAllContinuations)
            else
                runAllContinuations(0)
            end
        end

        self.drawCardsCoalescentQueue = Helper.createCoalescentQueue(1, coalesce, handle)
    end

    self.drawCardsCoalescentQueue.submit({
        parameteredContinuations = { { continuation = continuation, parameter = count } },
        count = count
    })

    return continuation
end

---
function PlayBoard:_tryToDrawCards(count)
    local continuation = Helper.createContinuation("PlayBoard:_tryToDrawCards")

    local content = self.content
    local deck = Helper.getDeckOrCard(content.drawDeckZone)
    local discard = Helper.getDeckOrCard(content.discardZone)

    local needDiscardReset = Helper.getCardCount(deck) < count
    local availableCardCount = Helper.getCardCount(deck) + Helper.getCardCount(discard)
    local notEnoughCards = availableCardCount < count

    if availableCardCount == 0 then
        continuation.run(0)
    elseif needDiscardReset or notEnoughCards then
        local leaderName = PlayBoard.getLeaderName(self.color)
        broadcastToAll(I18N("isDecidingToDraw", { leader = leaderName }), "Pink")
        local maxCount = math.min(count, availableCardCount)
        Dialog.showYesOrNoDialog(
            self.color,
            I18N("warningBeforeDraw", { count = count, maxCount = maxCount }),
            continuation,
            function (confirmed)
                if confirmed then
                    self:drawCards(count).doAfter(continuation.run)
                else
                    continuation.run(0)
                end
            end)
    else
        self:drawCards(count).doAfter(continuation.run)
    end

    return continuation
end

---
function PlayBoard:drawCards(count)
    Types.assertIsInteger(count)

    local continuation = Helper.createContinuation("PlayBoard:drawCards")

    local deckOrCard = Helper.getDeckOrCard(self.content.drawDeckZone)
    local drawableCardCount = Helper.getCardCount(deckOrCard)

    local dealCardCount = math.min(count, drawableCardCount)
    -- The getCardCount function is ok with nil arg, but we add a check for the sake of VS Code.
    if deckOrCard and dealCardCount > 0 then
        deckOrCard.deal(dealCardCount, self.color)
    end

    -- Dealing cards take an unknown amout of time.
    Helper.onceTimeElapsed(0.5).doAfter(function ()
        local remainingCardToDrawCount = count - dealCardCount
        if remainingCardToDrawCount > 0 then
            self:_resetDiscard().doAfter(function ()
                self:drawCards(remainingCardToDrawCount).doAfter(function (dealOfOtherCardCount)
                    continuation.run(dealCardCount + dealOfOtherCardCount)
                end)
            end)
        else
            continuation.run(dealCardCount)
        end
    end)

    return continuation
end

---
function PlayBoard:_resetDiscard()
    local continuation = Helper.createContinuation("PlayBoard:_resetDiscard")
    local discard = Helper.getDeckOrCard(self.content.discardZone)
    if discard then
        discard.setRotationSmooth({0, 180, 180}, false, false)
        discard.setPositionSmooth(self.content.drawDeckZone.getPosition() + Vector(0, 1, 0), false, true)
        Helper.onceOneDeck(self.content.drawDeckZone).doAfter(function ()
            local replenishedDeckOrCard = Helper.getDeckOrCard(self.content.drawDeckZone)
            assert(replenishedDeckOrCard)
            if replenishedDeckOrCard.type == "Deck" then
                Helper.shuffleDeck(replenishedDeckOrCard)
                Helper.onceShuffled(replenishedDeckOrCard).doAfter(continuation.run)
            else
                continuation.run(replenishedDeckOrCard)
            end
        end)
    else
        continuation.cancel()
    end
    return continuation
end

---
function PlayBoard:_nukeConfirm()
    local token = self.content.atomicsToken
    Helper.clearButtons(token)

    local function reset()
        Helper.clearButtons(token)
        self:_createNukeButton()
    end

    Helper.createButton(token, {
        click_function = Helper.registerGlobalCallback(),
        label = I18N("atomicsConfirm"),
        position = Vector(0, 0, 3.5),
        width = 0,
        height = 0,
        scale = Vector(3, 3, 3),
        font_size = 260,
        font_color = {1, 0, 0, 100},
        color = {0, 0, 0, 0}
    })

    Helper.createButton(token, {
        click_function = self:_createExclusiveCallback(function ()
            reset()
            self.leader.atomics(self.color)
            self.content.atomicsToken.destruct()
            self.content.atomicsToken = nil
        end),
        label = I18N('yes'),
        position = Vector(-5, 0, 0),
        width = 550,
        height = 350,
        scale = Vector(3, 3, 3),
        font_size = 300,
        font_color = {1, 1, 1},
        color = "Green"
    })

    Helper.createButton(token, {
        click_function = self:_createExclusiveCallback(function ()
            reset()
        end),
        label = I18N('no'),
        position = Vector(5, 0, 0),
        width = 550,
        height = 350,
        scale = Vector(3, 3, 3),
        font_size = 300,
        font_color = {1, 1, 1},
        color = "Red"
    })
end

---
function PlayBoard._getPlayerTextColors(color)

    local background = {0, 0, 0, 1}
    local foreground = {1, 1, 1, 1}

    if color == 'Green' then
        background = {0.192, 0.701, 0.168, 1}
        foreground = {0.7804, 0.7804, 0.7804, 1}
    elseif color == 'Yellow' then
        background = {0.9058, 0.898, 0.1725, 1}
        foreground = {0, 0, 0, 1}
    elseif color == 'Blue' then
        background = {0.118, 0.53, 1, 1}
        foreground = {0.7804, 0.7804, 0.7804, 1}
    elseif color == 'Red' then
        background =  {0.856, 0.1, 0.094, 1}
        foreground = {0.7804, 0.7804, 0.7804, 1}
    end

    return {
        bg = background,
        fg = foreground
    }
end

---
function PlayBoard.isRival(color)
    local playerBoard = PlayBoard.getPlayBoard(color)
    return playerBoard.opponent == "rival"
end

---
function PlayBoard.isHuman(color)
    local playerBoard = PlayBoard.getPlayBoard(color)
    return playerBoard.opponent ~= "rival"
end

---
function PlayBoard.setLeader(color, leaderCard)
    Types.assertIsPlayerColor(color)
    assert(leaderCard)

    local playBoard = PlayBoard.getPlayBoard(color)
    if playBoard.opponent == "rival" then
        if Hagal.getRivalCount() == 1 then
            playBoard.leader = Rival.newRival(color)
        elseif Hagal.isLeaderCompatible(leaderCard) then
            playBoard.leader = Rival.newRival(color, Helper.getID(leaderCard))
        else
            log("Not a leader compatible with a rival: " .. Helper.getID(leaderCard))
            return nil
        end
    else
        playBoard.leader = Leader.newLeader(Helper.getID(leaderCard))
    end

    assert(playBoard.leader)
    local position = playBoard.content.leaderZone.getPosition()
    leaderCard.setPosition(position)
    playBoard.leaderCard = leaderCard

    local continuation = Helper.onceMotionless(leaderCard)

    continuation.doAfter(function ()
        -- Do not lock the Hagal deck.
        if playBoard.opponent ~= "rival" or Hagal.getRivalCount() > 1 then
            Helper.noPhysics(leaderCard)
        end
        playBoard:_createButtons()
    end)

    return continuation
end

---
function PlayBoard.findLeaderCard(color)
    local leaderZone = PlayBoard.getContent(color).leaderZone
    for _, object in ipairs(leaderZone.getObjects()) do
        if object.hasTag("Leader") or object.hasTag("Hagal") then
            return object
        end
    end
    return nil
end

---
function PlayBoard.getLeader(color)
    return PlayBoard.getPlayBoard(color).leader
end

---
function PlayBoard.getLeaderName(color)
    local leaderCard = PlayBoard.findLeaderCard(color)
    return leaderCard and leaderCard.getName() or "?"
end

---
function PlayBoard.getContent(color)
    local playBoard = PlayBoard.getPlayBoard(color)
    assert(playBoard, "Unknow player color: " .. tostring(color))
    return playBoard.content
end

---
function PlayBoard.getAgentCardPark(color)
    return PlayBoard.getPlayBoard(color).agentCardPark
end

---
function PlayBoard.getRevealCardPark(color)
    return PlayBoard.getPlayBoard(color).revealCardPark
end

---
function PlayBoard.getAgentPark(color)
    return PlayBoard.getPlayBoard(color).agentPark
end

---
function PlayBoard.getDreadnoughtPark(color)
    return PlayBoard.getPlayBoard(color).dreadnoughtPark
end

---
function PlayBoard.getSupplyPark(color)
    return PlayBoard.getPlayBoard(color).supplyPark
end

---
function PlayBoard.getTechPark(color)
    return PlayBoard.getPlayBoard(color).techPark
end

---
function PlayBoard.getScorePark(color)
    return PlayBoard.getPlayBoard(color).scorePark
end

---
function PlayBoard:getScore()
    local score = 0
    if not PlayBoard.isRival(self.color) or Hagal.getRivalCount() == 2 then
        for _, object in ipairs(Park.getObjects(self.scorePark)) do
            if Types.isVictoryPointToken(object) then
                score = score + 1
            end
        end
    end
    return score
end

---
function PlayBoard.grantTechTile(color, techTile)
    return Park.putObject(techTile, PlayBoard.getPlayBoard(color).techPark)
end

---
function PlayBoard.getScoreTokens(color)
    return Park.getObjects(PlayBoard.getPlayBoard(color).scorePark)
end

---
function PlayBoard.grantScoreToken(color, token)
    token.setInvisibleTo({})
    return Park.putObject(token, PlayBoard.getPlayBoard(color).scorePark)
end

---
function PlayBoard.grantScoreTokenFromBag(color, tokenBag, count)
    return Park.putObjectFromBag(tokenBag, PlayBoard.getPlayBoard(color).scorePark, count)
end

---
function PlayBoard.hasTech(color, techName)
    return PlayBoard.getTech(color, techName) ~= nil
end

---
function PlayBoard.getTech(color, techName)
    local techs = Park.getObjects(PlayBoard.getPlayBoard(color).techPark)
    for _, tech in ipairs(techs) do
        if Helper.getID(tech) == techName then
            return tech
        end
    end
    return nil
end

---
function PlayBoard.useTech(color, techName)
    local tech = PlayBoard.getTech(color, techName)
    if tech and not tech.is_face_down then
        tech.flip()
        return true
    else
        return false
    end
end

---
function PlayBoard.hasHighCouncilSeat(color)
    local token = PlayBoard.getCouncilToken(color)
    for _, zone in ipairs(Park.getZones(MainBoard.getHighCouncilSeatPark())) do
        if Helper.contains(zone, token) then
            return true
        end
    end
    return false
end

---
function PlayBoard.takeHighCouncilSeat(color)
    local token = PlayBoard.getCouncilToken(color)
    if not PlayBoard.hasHighCouncilSeat(color) then
        if Park.putObject(token, MainBoard.getHighCouncilSeatPark()) then
            token.interactable = true
            local playBoard = PlayBoard.getPlayBoard(color)
            playBoard.persuasion:change(2)
            if PlayBoard.hasTech(color, "restrictedOrdnance") then
                playBoard.strength:change(4)
            end
            Helper.emitEvent("highCouncilSeatTaken", color)
            return true
        end
    end
    return false
end

---
function PlayBoard.hasSwordmaster(color)
    local agents = Park.getObjects(PlayBoard.getAgentPark(color))
    return Helper.isElementOf(PlayBoard.getSwordmaster(color), agents)
end

---
function PlayBoard.recruitSwordmaster(color)
    return Park.putObject(PlayBoard.getSwordmaster(color), PlayBoard.getAgentPark(color))
end

---
function PlayBoard.getSwordmaster(color)
    local content = PlayBoard.getContent(color)
    return content.swordmaster
end

---
function PlayBoard.getCouncilToken(color)
    local content = PlayBoard.getContent(color)
    return content.councilToken
end

---
function PlayBoard.getResource(color, resourceName)
    Types.assertIsResourceName(resourceName)
    return PlayBoard.getPlayBoard(color)[resourceName]
end

---
function PlayBoard.giveCard(color, card, isTleilaxuCard)
    Types.assertIsPlayerColor(color)
    assert(card)

    local content = PlayBoard.getContent(color)
    assert(content)

    -- Acquire the card (not smoothly to avoid being grabbed by a player hand zone).
    card.setPosition(content.discardZone.getPosition())
    printToAll(I18N(isTleilaxuCard and "acquireTleilaxuCard" or "acquireImperiumCard", { card = I18N(Helper.getID(card)) }), color)
    ImperiumCard.applyAcquireEffect(color, card)

    -- Move it on the top of the content deck if possible and wanted.
    if (isTleilaxuCard and TleilaxuResearch.hasReachedOneHelix(color)) or PlayBoard.hasTech(color, "spaceport") then
        Dialog.showYesOrNoDialog(
            color,
            I18N("dialogCardAbove"),
            nil,
            function (confirmed)
                if confirmed then
                    Helper.moveCardFromZone(content.discardZone, content.drawDeckZone.getPosition(), Vector(0, 180, 180))
                end
            end)
    end
end

---
function PlayBoard.giveCardFromZone(color, zone, isTleilaxuCard)
    Types.assertIsPlayerColor(color)

    local content = PlayBoard.getContent(color)
    assert(content)

    -- Acquire the card (not smoothly to avoid being grabbed by a player hand zone).
    Helper.moveCardFromZone(zone, content.discardZone.getPosition()).doAfter(function (card)
        assert(card)
        local cardName = I18N(Helper.getID(card))
        printToAll(I18N(isTleilaxuCard and "acquireTleilaxuCard" or "acquireImperiumCard", { card = cardName }), color)
        ImperiumCard.applyAcquireEffect(color, card)
    end)

    -- Move it on the top of the player deck if possible and wanted.
    if (isTleilaxuCard and TleilaxuResearch.hasReachedOneHelix(color)) or PlayBoard.hasTech(color, "spaceport") then
        Dialog.showYesOrNoDialog(
            color,
            I18N("dialogCardAbove"),
            nil,
            function (confirmed)
                if confirmed then
                    Helper.moveCardFromZone(content.discardZone, content.drawDeckZone.getPosition() + Vector(0, 1, 0), Vector(0, 180, 180))
                end
            end)
    end
end

---
function PlayBoard.getDrawDeck(color)
    local playBoard = PlayBoard.getPlayBoard(color)
    local deckOrCard = Helper.getDeckOrCard(playBoard.content.drawDeckZone)
    return deckOrCard
end

---
function PlayBoard.getDiscard(color)
    local playBoard = PlayBoard.getPlayBoard(color)
    local deckOrCard = Helper.getDeckOrCard(playBoard.content.discardZone)
    return deckOrCard
end

---
function PlayBoard.getHandedCards(color)
    return Helper.filter(Player[color].getHandObjects(), Types.isImperiumCard)
end

---
function PlayBoard.getDiscardedCards(color)
    local playBoard = PlayBoard.getPlayBoard(color)
    local deckOrCard = Helper.getDeckOrCard(playBoard.content.discardZone)
    return Helper.getCards(deckOrCard)
end

---
function PlayBoard.getDiscardedCardCount(color)
    local playBoard = PlayBoard.getPlayBoard(color)
    local deckOrCard = Helper.getDeckOrCard(playBoard.content.discardZone)
    return Helper.getCardCount(deckOrCard)
end

--- Anything trashed (and filtering is hard considering the content is not spawned).
function PlayBoard.getTrashedCards(color)
    local playBoard = PlayBoard.getPlayBoard(color)
    return playBoard.content.trash.getObjects()
end

---
function PlayBoard.getIntrigues(color)
    return Helper.filter(Player[color].getHandObjects(), Types.isIntrigueCard)
end

---
function PlayBoard._getPotentialCombatIntrigues(color)
    local predicate
    if Hagal.getRivalCount() == 2 then
        predicate = function (card)
            return Types.isIntrigueCard(card) and IntrigueCard.isCombatCard(card)
        end
    else
        predicate = Types.isIntrigueCard
    end
    return Helper.filter(Player[color].getHandObjects(), predicate)
end

---
function PlayBoard.getAquiredDreadnoughtCount(color)
    local park = PlayBoard.getPlayBoard(color).dreadnoughtPark
    return #Park.findEmptySlots(park)
end

---
function PlayBoard.getControlMarkerBag(color)
    local content = PlayBoard.getContent(color)
    assert(content)
    return content.controlMarkerBag
end

---
function PlayBoard:_newSymmetricBoardPosition(x, y, z)
    if PlayBoard.isLeft(self.color) then
        return self:_newBoardPosition(-x, y, z)
    else
        return self:_newBoardPosition(x, y, z)
    end
end

---
function PlayBoard:_newSymmetricBoardRotation(x, y, z)
    if PlayBoard.isLeft(self.color) then
        return self:_newBoardPosition(x, -y, z)
    else
        return self:_newBoardPosition(x, y, z)
    end
end

---
function PlayBoard:_newOffsetedBoardPosition(x, y, z)
    if PlayBoard.isLeft(self.color) then
        return self:_newBoardPosition(17 + x, y, z)
    else
        return self:_newBoardPosition(x, y, z)
    end
end

---
function PlayBoard:_newBoardPosition(x, y, z)
    return Vector(x, y + 0.7, -z)
end

function PlayBoard.isLeft(color)
    return color == "Red" or color == "Blue"
end

function PlayBoard.isRight(color)
    return color == "Green" or color == "Yellow"
end

---
function PlayBoard:trash(object)
    self.trashQueue = self.trashQueue or Helper.createSpaceQueue()
    self.trashQueue.submit(function (height)
        object.interactable = true
        object.setLock(false)
        object.setPosition(self.content.trash.getPosition() + Vector(0, 1 + height * 0.5, 0))
    end)
end

---
function PlayBoard.isInside(color, object)
    local position = object.getPosition()
    local center = PlayBoard.getPlayBoard(color).content.board.getPosition()
    local offset = position - center
    return math.abs(offset.x) < 12 and math.abs(offset.z) < 10
end

---
function PlayBoard.getHandOrientedPosition(color)
    -- Add an offset to put the card on the left side of the player's hand.
    local handTransform = Player[color].getHandTransform()
    local position = handTransform.position
    if handTransform.rotation == Vector(0, 0, 0) then
        position = position + Vector(-5, 0, 0)
    else
        position = position + Vector(0, 0, -5)
    end
    local rotation = handTransform.rotation + Vector(0, 180, 0)
    return {
        position = position,
        rotation = rotation
    }
end

---
function PlayBoard.acquireVoice(color, voiceToken)
    Types.assertIsPlayerColor(color)
    assert(voiceToken)
    local position = PlayBoard.getPlayBoard(color).content.firstPlayerInitialPosition
    voiceToken.setPositionSmooth(position + Vector(0, 1, -2.8))
    return true
end

return PlayBoard
