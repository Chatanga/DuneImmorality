local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")
local I18N = require("utils.I18N")
local Set = require("utils.Set")

local Resource = Module.lazyRequire("Resource")
local TleilaxuResearch = Module.lazyRequire("TleilaxuResearch")
local TurnControl = Module.lazyRequire("TurnControl")
local Types = Module.lazyRequire("Types")
local Deck = Module.lazyRequire("Deck")
local MainBoard = Module.lazyRequire("MainBoard")
local Hagal = Module.lazyRequire("Hagal")
local Leader = Module.lazyRequire("Leader")
local Combat = Module.lazyRequire("Combat")
local ImperiumCard = Module.lazyRequire("ImperiumCard")
local IntrigueCard = Module.lazyRequire("IntrigueCard")
local Intrigue = Module.lazyRequire("Intrigue")
local Reserve = Module.lazyRequire("Reserve")
local Action = Module.lazyRequire("Action")
local Music = Module.lazyRequire("Music")
local ConflictCard = Module.lazyRequire("ConflictCard")

local PlayBoard = Helper.createClass(nil, {
    ALL_RESOURCE_NAMES = { "spice", "water", "solari", "persuasion", "strength" },
    -- Temporary structure (set to nil *after* loading).
    unresolvedContentByColor = {
        Red = {
            board = "adcd28",
            spice = "3074d4",
            solari = "576ccd",
            water = "692c4d",
            persuasion = "72be72",
            strength = "3f6645",
            leaderZone = "66cdbb",
            dreadnoughts = {"1a3c82", "a8f306"},
            dreadnoughtPositions = {
                Helper.getHardcodedPositionFromGUID('1a3c82', -26.3000584, 1.11260116, 18.6999588),
                Helper.getHardcodedPositionFromGUID('a8f306', -28.7000713, 1.112601, 18.6999741)
            },
            agents = {"7751c8", "afa978"},
            agentPositions = {
                Helper.getHardcodedPositionFromGUID('7751c8', -17.0, 1.11060035, 20.3),
                Helper.getHardcodedPositionFromGUID('afa978', -18.3, 1.11060059, 20.3)
            },
            swordmaster = "ed3490",
            councilToken = "f19a48",
            fourPlayerVictoryToken = "a6c2e0",
            fourPlayerVictoryTokenInitialPosition = Helper.getHardcodedPositionFromGUID('a6c2e0', -13.0, 1.3122313, 21.85),
            scoreMarker = "4feaca",
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
            researchTokenInitalPosition = Helper.getHardcodedPositionFromGUID('39e0f3', 0.37, 0.880000353, 18.2351761),
            freighter = "e9096d",
            leaderPos = Helper.getHardcodedPositionFromGUID('66cdbb', -19.0, 1.25, 17.5),
            firstPlayerPosition = Helper.getHardcodedPositionFromGUID('346e0d', -14.0, 1.5, 19.7) + Vector(0, -0.4, 0),
            startEndTurnButton = "895594",
            atomicsToken = "d5ff47",
        },
        Blue = {
            board = "77ca63",
            spice = "9cc286",
            solari = "fa5236",
            water = "0afaeb",
            persuasion = "8cb9be",
            strength = "aa3bb9",
            leaderZone = "681774",
            dreadnoughts = {"82789e", "60f208"},
            dreadnoughtPositions = {
                Helper.getHardcodedPositionFromGUID('82789e', -26.3000774, 1.11260116, -4.300044),
                Helper.getHardcodedPositionFromGUID('60f208', -28.7000885, 1.11260128, -4.30005646)
            },
            agents = {"64d013", "106d8b"},
            agentPositions = {
                Helper.getHardcodedPositionFromGUID('64d013', -17.0, 1.11060047, -2.70000482),
                Helper.getHardcodedPositionFromGUID('106d8b', -18.3, 1.11060035, -2.7)
            },
            swordmaster = "a78ad7",
            councilToken = "f5b14a",
            fourPlayerVictoryToken = "311255",
            fourPlayerVictoryTokenInitialPosition = Helper.getHardcodedPositionFromGUID('311255', -13.0, 1.11223137, -1.1499995),
            scoreMarker = "1b1e76",
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
            tleilaxTokenInitalPosition = Helper.getHardcodedPositionFromGUID('96607f', 0.5446168, 0.8800002, 22.75),
            researchToken = "292658",
            researchTokenInitalPosition = Helper.getHardcodedPositionFromGUID('292658', 0.37, 0.8775002, 18.9369965),
            freighter = "68e424",
            leaderPos = Helper.getHardcodedPositionFromGUID('681774', -19.0, 1.25506675, -5.5),
            firstPlayerPosition = Helper.getHardcodedPositionFromGUID('1fc559', -14.0, 1.501278, -3.3) + Vector(0, -0.4, 0),
            startEndTurnButton = "9eeccd",
            atomicsToken = "700023",
        },
        Green = {
            board = "0bbae1",
            spice = "22478f",
            solari = "e597dc",
            water = "fa9522",
            persuasion = "ac97c5",
            strength = "d880f7",
            leaderZone = "cf1486",
            dreadnoughts = {"a15087", "734250"},
            dreadnoughtPositions = {
                Helper.getHardcodedPositionFromGUID('a15087', 26.2999535, 1.112601, 18.6999741),
                Helper.getHardcodedPositionFromGUID('734250', 28.69994, 1.112601, 18.69996)
            },
            agents = {"66ae45", "bceb0e"},
            agentPositions = {
                Helper.getHardcodedPositionFromGUID('66ae45', 17.0, 1.11060059, 20.2999935),
                Helper.getHardcodedPositionFromGUID('bceb0e', 18.3, 1.11060047, 20.3)
            },
            swordmaster = "fb1629",
            councilToken = "a0028d",
            fourPlayerVictoryToken = "66444c",
            fourPlayerVictoryTokenInitialPosition = Helper.getHardcodedPositionFromGUID('66444c', 13.0, 1.31223154, 21.85),
            scoreMarker = "76039f",
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
            tleilaxTokenInitalPosition = Helper.getHardcodedPositionFromGUID('63d39f', 1.24461639, 0.8800001, 22.05),
            researchToken = "658b17",
            researchTokenInitalPosition = Helper.getHardcodedPositionFromGUID('658b17', 0.369999945, 0.877500236, 20.34),
            freighter = "34281d",
            leaderPos = Helper.getHardcodedPositionFromGUID('cf1486', 19.0, 1.18726385, 17.5),
            firstPlayerPosition = Helper.getHardcodedPositionFromGUID('59523d', 14.0, 1.45146358, 19.7) + Vector(0, -0.4, 0),
            startEndTurnButton = "96aa58",
            atomicsToken = "0a22ec",
        },
        Yellow = {
            board = "fdd5f9",
            spice = "78fb8a",
            solari = "c5c4ef",
            water = "f217d0",
            persuasion = "aa79bf",
            strength = "6f007c",
            leaderZone = "a677e0",
            dreadnoughts = {"5469fb", "71a414"},
            dreadnoughtPositions = {
                Helper.getHardcodedPositionFromGUID('5469fb', 26.2999172, 1.11260128, -4.300019),
                Helper.getHardcodedPositionFromGUID('71a414', 28.69992, 1.11260116, -4.300043)
            },
            agents = {"5068c8", "67b476"},
            agentPositions = {
                Helper.getHardcodedPositionFromGUID('5068c8', 17.0, 1.11060047, -2.70000386),
                Helper.getHardcodedPositionFromGUID('67b476', 18.3, 1.11060047, -2.699999)
            },
            swordmaster = "635c49",
            councilToken = "1be491",
            fourPlayerVictoryToken = "4e8873",
            fourPlayerVictoryTokenInitialPosition = Helper.getHardcodedPositionFromGUID('4e8873', 13.0, 1.3122313, -1.14999926),
            scoreMarker = "20bbd1",
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
            firstPlayerPosition = Helper.getHardcodedPositionFromGUID('e9a44c', 14.0, 1.44851, -3.3) + Vector(0, -0.4, 0),
            startEndTurnButton = "3d1b90",
            atomicsToken = "7e10a9",
        }
    },
    playboards = {},
    nextPlayer = nil
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
            PlayBoard.playboards[color] = PlayBoard.new(color, unresolvedContent, subState)
        end
    end
    PlayBoard.unresolvedContentByColor = nil

    if state.settings then
        PlayBoard._staticSetUp(state.settings)
    end
end

---
function PlayBoard.onSave(state)
    state.PlayBoard =
        Helper.map(PlayBoard.playboards, function (color, playBoard)
            local resourceValues = {}
            for _, resourceName in ipairs(PlayBoard.ALL_RESOURCE_NAMES) do
                resourceValues[resourceName] = playBoard[resourceName]:get()
            end
            return resourceValues
        end)
end

---
function PlayBoard.new(color, unresolvedContent, subState)
    local playBoard = Helper.createClassInstance(PlayBoard, {
        color = color,
        score = 0,
        scorePositions = {},
    })
    playBoard.content = Helper.resolveGUIDs(true, unresolvedContent)

    playBoard.content.board.interactable = false
    playBoard.content.startEndTurnButton.interactable = false

    --if not subState then
        Helper.noPlay(
            playBoard.content.councilToken,
            playBoard.content.freighter,
            playBoard.content.tleilaxToken,
            playBoard.content.researchToken
        )
        Helper.noPhysicsNorPlay(
            playBoard.content.scoreMarker,
            playBoard.content.forceMarker
        )
    --end

    -- FIXME Why this offset? In particular, why the Z component introduces an asymmetry?
    local offset = Vector(0, 0.55, 5.1)
    local centerPosition = playBoard.content.board.getPosition() + offset

    for _, resourceName in ipairs(PlayBoard.ALL_RESOURCE_NAMES) do
        local token = playBoard.content[resourceName]
        local value = subState and subState[resourceName] or 0
        playBoard[resourceName] = Resource.new(token, color, resourceName, value)
    end

    Helper.createTransientAnchor("InstructionTextAnchor", playBoard.content.board.getPosition() + playBoard:_newSymmetricBoardPosition(12, -0.5, -8)).doAfter(function (anchor)
        playBoard.instructionTextAnchor = anchor
    end)

    playBoard.agentCardPark = playBoard:_createCardPark(Vector(0, 0, 4))
    playBoard.revealCardPark = playBoard:_createCardPark(Vector(0, 0, 0))
    playBoard.agentPark = playBoard:_createAgentPark(unresolvedContent.agentPositions)
    playBoard.dreadnoughtPark = playBoard:_createDreadnoughtPark(unresolvedContent.dreadnoughtPositions)
    playBoard.supplyPark = playBoard:_createSupplyPark(centerPosition)
    playBoard.techPark = playBoard:_createTechPark(centerPosition)
    playBoard:_generatePlayerScoreboardPositions()
    playBoard.scorePark = playBoard:_createPlayerScorePark()

    playBoard:_createButtons()

    Helper.registerEventListener("locale", function ()
        playBoard:_createButtons()
    end)

    return playBoard
end

---
function PlayBoard.setUp(settings, activeOpponents)
    for color, playBoard in pairs(PlayBoard.playboards) do
        playBoard:_cleanUp(false, not settings.riseOfIx, not settings.immortality)
        if activeOpponents[color] then
            playBoard.opponent = activeOpponents[color]
            if playBoard.opponent ~= "rival" then
                Deck.generateStarterDeck(playBoard.content.drawDeckZone, settings.immortality, settings.epicMode).doAfter(function (deck)
                    Helper.shuffleDeck(deck)
                end)
                Deck.generateStarterDiscard(playBoard.content.discardZone, settings.immortality, settings.epicMode)
            else
                playBoard.content.researchToken.destruct()
                playBoard.content.researchToken = nil
                if Hagal.getRivalCount() == 1 then
                    playBoard.content.scoreMarker.destruct()
                    playBoard.content.scoreMarker = nil
                end
            end

            if settings.numberOfPlayers < 4 then
                playBoard.content.fourPlayerVictoryToken.destruct()
                playBoard.content.fourPlayerVictoryToken = nil
            end

            playBoard:updatePlayerScore()
        else
            playBoard:_tearDown()
        end
    end

    PlayBoard._staticSetUp(settings)
end

---
function PlayBoard._staticSetUp(settings)
    Helper.registerEventListener("phaseStart", function (phase, firstPlayer)
        if phase == "leaderSelection" or phase == "roundStart" then
            local playBoard = PlayBoard.getPlayBoard(firstPlayer)
            MainBoard.getFirstPlayerMarker().setPositionSmooth(playBoard.content.firstPlayerPosition, false, false)
        end

        if phase == "roundStart" then
            for color, playBoard in pairs(PlayBoard._getPlayBoards()) do
                if playBoard.opponent ~= "rival" then
                    local cardAmount = PlayBoard.hasTech(color, "holtzmanEngine") and 6 or 5
                    playBoard:drawCards(cardAmount)

                    if PlayBoard.hasTech(color, "shuttleFleet") then
                        playBoard.leader.resources(color, "solari", 2)
                    end
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
                playBoard.leader.prepare(color, settings)
            end
        elseif phase == "endgame" then
            PlayBoard._setActivePlayer(nil, nil)
            MainBoard.getFirstPlayerMarker().destruct()
        end
        for _, playBoard in pairs(PlayBoard._getPlayBoards()) do
            Helper.clearButtons(playBoard.instructionTextAnchor)
        end
    end)

    Helper.registerEventListener("playerTurns", function (phase, color)
        --Helper.dumpFunction("PlayBoard.turnCallback", phase, color)
        local playBoard = PlayBoard.getPlayBoard(color)

        for otherColor, otherPlayBoard in pairs(PlayBoard._getPlayBoards()) do
            if PlayBoard.isHuman(otherColor) then
                local instruction = (playBoard.leader or Action).instruct(phase, color == otherColor) or "-"
                if otherPlayBoard.instructionTextAnchor then
                    Helper.clearButtons(otherPlayBoard.instructionTextAnchor)
                    Helper.createAbsoluteButtonWithRoundness(otherPlayBoard.instructionTextAnchor, 1, false, {
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

                playBoard.alreadyPlayedCards = Helper.filter(Park.getObjects(playBoard.agentCardPark), function (card)
                    return Types.isImperiumCard(card) or Types.isIntrigueCard(card)
                end)
            end
        end

        if phase == "combatEnd" then
            PlayBoard.collectReward(color)
        end

        PlayBoard._setActivePlayer(phase, color)
        Music.play("turn")
    end)

    Helper.registerEventListener("combatUpdate", function (forces)
        PlayBoard.combatPassCountdown = #Helper.getKeys(forces)
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

    -- Send all played cards to the discard, save those which shouldn't.
    Helper.forEach(Helper.filter(Park.getObjects(self.agentCardPark), Types.isImperiumCard), function (_, card)
        local cardName = Helper.getID(card)
        if cardName == "foldspace" then
            card.setPositionSmooth(Reserve.foldspaceSlotZone.getPosition())
        elseif Helper.isElementOf(cardName, {"seekAllies", "powerPlay", "treachery"}) then
            card.setPositionSmooth(self.content.trash.getPosition() + Vector(0, 1, 0))
        else
            card.setPositionSmooth(self.content.discardZone.getPosition())
        end
    end)

    -- Send all revealed cards to the discard.
    Helper.forEach(Helper.filter(Park.getObjects(self.revealCardPark), Types.isImperiumCard), function (i, card)
        card.setPositionSmooth(self.content.discardZone.getPosition() + Vector(0, i * 0.5, 0))
    end)

    -- Send all played intrigues to their discard.
    local playedIntrigueCards = Helper.concatTables(
        Helper.filter(Park.getObjects(self.agentCardPark), Types.isIntrigueCard),
        Helper.filter(Park.getObjects(self.revealCardPark), Types.isIntrigueCard)
    )
    Helper.forEach(playedIntrigueCards, function (i, card)
        card.setPositionSmooth(Intrigue.discardZone.getPosition())
    end)

    -- Flip any used tech.
    for _, techTile in ipairs(Park.getObjects(self.techPark)) do
        if techTile.is_face_down then
            techTile.flip()
        end
    end
end

---
function PlayBoard._setActivePlayer(phase, color)
    local indexedColors = {"Green", "Yellow", "Blue", "Red"}
    for i, otherColor in ipairs(indexedColors) do
        local playBoard = PlayBoard.playboards[otherColor]
        if playBoard then
            local effectIndex = 0 -- black index (no color actually)
            if otherColor == color then
                effectIndex = i
                if playBoard.opponent == "rival" then
                    Hagal.activate(phase, color)
                else
                    if phase ~= "leaderSelection" and phase ~= "arrakeenScouts" then
                        playBoard:_createEndOfTurnButton()
                    end
                    PlayBoard._movePlayerIfNeeded(color)
                end
            else
                Helper.clearButtons(playBoard.content.startEndTurnButton)
            end
            local board = playBoard.content.board
            board.AssetBundle.playTriggerEffect(effectIndex)
        end
    end
end

--- Hotseat (FIXME Unreliable with randomization?)
function PlayBoard._movePlayerIfNeeded(color)
    local hostPlayer = nil
    for _, player in ipairs(Player.getPlayers()) do
        if player.color == color then
            return
        elseif player.host then
            hostPlayer = player
        end
    end
    if hostPlayer then
        PlayBoard.getPlayBoard(hostPlayer.color).opponent = "puppet"
        PlayBoard.getPlayBoard(color).opponent = hostPlayer
        Helper.onceFramesPassed(1).doAfter(function ()
            hostPlayer.changeColor(color)
        end)
    end
end

function PlayBoard.createEndOfTurnButton(color)
    PlayBoard.playboards[color]:_createEndOfTurnButton()
end

---
function PlayBoard:_createEndOfTurnButton()
    Helper.clearButtons(self.content.startEndTurnButton)
    self.content.startEndTurnButton.createButton({
        click_function = self:_createExclusiveCallback(function ()
            self.content.startEndTurnButton.AssetBundle.playTriggerEffect(0)
            TurnControl.endOfTurn()
        end),
        position = Vector(0, 0.6, 0),
        label = "End\nof\nTurn",
        width = 1500,
        height = 1500,
        color = { 0, 0, 0, 0 },
        font_size = 450,
        font_color = Helper.concatTables(self:getFontColor(), { 100 })
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
        if Hagal.getRivalCount() == 1 and PlayBoard.isRival(color) then
            accepted = not PlayBoard.playboards[TurnControl.getFirstPlayer()].revealed
        else
            accepted = PlayBoard.couldSendAgentOrReveal(color)
        end
    elseif phase == 'combat' then
        if Combat.isInCombat(color) then
            PlayBoard.combatPassCountdown = PlayBoard.combatPassCountdown - 1
            accepted = PlayBoard.combatPassCountdown > 0 and not PlayBoard.isRival(color) and #PlayBoard.getIntrigues(color) > 0
        end
    elseif phase == 'combatEnd' then
        -- TODO Player is victorious and the combat provied a reward (auto?) or
        -- a dreadnought needs to be placed or a combat card remains to be played.
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

        Helper.dump(color, "has", #dreadnoughts, "dreadnought(s)")
        if #dreadnoughts > 0 then
            Player[color].showInfoDialog(I18N("dreadnoughtMandatoryOccupation"))
        end
    end
end

---
function PlayBoard.getPlayBoard(color)
    assert(#Helper.getKeys(PlayBoard.playboards) > 0, "No playBoard at all: too soon!")
    local playBoard = PlayBoard.playboards[color]
    --assert(playBoard, "No playBoard for color " .. tostring(color))
    return playBoard
end

---
function PlayBoard._getPlayBoards(filterOutRival)
    assert(#Helper.getKeys(PlayBoard.playboards) > 0, "No playBoard at all: too soon!")
    local filteredPlayBoards = {}
    for color, playBoard in pairs(PlayBoard.playboards) do
        if playBoard.opponent and (not filterOutRival or playBoard.opponent ~= "rival") then
            filteredPlayBoards[color] = playBoard
        end
    end
    return filteredPlayBoards
end

---
function PlayBoard.getPlayBoardColors(filterOutRival)
    return Helper.getKeys(PlayBoard._getPlayBoards(filterOutRival))
end

---
function PlayBoard._getBoard(color)
    return PlayBoard.getContent(color).board
end

---
function PlayBoard:_createCardPark(globalOffset)
    local offsets = {
        Red = Vector(13, 0.69, -5),
        Blue = Vector(13, 0.69, -5),
        Green = Vector(-13, 0.69, -5),
        Yellow = Vector(-13, 0.69, -5)
    }
    local step = 0
    if self.color == "Yellow" or self.color == "Green" then
        step = 2.5
    end
    if self.color == "Red" or self.color == "Blue" then
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
function PlayBoard:_createAgentPark(agentPositions)
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
    for i, dreadnought in ipairs(self.content.agents) do
        dreadnought.setPosition(slots[i])
    end
    return park
end

---
function PlayBoard:_createDreadnoughtPark(dreadnoughtPositions)
    local park = Park.createCommonPark({ self.color, "Dreadnought" }, dreadnoughtPositions, Vector(1, 3, 0.5))
    for i, dreadnought in ipairs(self.content.dreadnoughts) do
        dreadnought.setPosition(dreadnoughtPositions[i])
    end
    return park
end

---
function PlayBoard:_createSupplyPark(centerPosition)
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

    local supplyZone = Park.createBoundingZone(45, Vector(0.4, 0.35, 0.4), allSlots)

    for i, troop in ipairs(self.content.troops) do
        troop.setLock(true)
        troop.setPosition(slots[i])
        troop.setRotation(Vector(0, 45, 0))
    end

    return Park.createPark(
        "Supply" .. self.color,
        slots,
        Vector(0, -45, 0),
        supplyZone,
        { "Troop", self.color },
        nil,
        true,
        true)
end

---
function PlayBoard:_createTechPark(centerPosition)
    local color = self.color
    local slots = {}
    for i = 1, 2 do
        for j = 3, 1, -1 do
            local x = (i - 1.5) * 3 + 6
            if color == "Red" or color == "Blue" then
                x = -x
            end
                local z = (j - 2) * 2 + 0.4
            local slot = Vector(x, 0.5, z) + centerPosition
            table.insert(slots, slot)
        end
    end
    return Park.createCommonPark({ "Tech" }, slots, Vector(3, 0.5, 2), Vector(0, 180, 0))
end

---
function PlayBoard:_generatePlayerScoreboardPositions()
    assert(self.content.scoreMarker, self.color .. ": no score marker!")
    local origin = self.content.scoreMarker.getPosition()

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
    if self.color == "Red" or  self.color == "Blue" then
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
        --local cappedScore = math.min(13, self:getScore())
        local rectifiedScore = self:getScore()
        rectifiedScore = rectifiedScore > 13 and rectifiedScore - 10 or rectifiedScore
        local scoreMarker = self.content.scoreMarker
        scoreMarker.setLock(false)
        scoreMarker.setPositionSmooth(self.scorePositions[rectifiedScore])
    end
end

---
function PlayBoard.onObjectEnterScriptingZone(zone, object)
    for color, playBoard in pairs(PlayBoard.playboards) do
        if playBoard.opponent then
            if zone == playBoard.scorePark.zone then
                if Types.isVictoryPointToken(object) then
                    playBoard:updatePlayerScore()
                    local controlableSpace = MainBoard.findControlableSpace(object)
                    if controlableSpace then
                        MainBoard.occupy(controlableSpace, color)
                    end
                end
            elseif zone == playBoard.agentPark.zone then
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
    for _, playBoard in pairs(PlayBoard.playboards) do
        if playBoard.opponent then
            if zone == playBoard.scorePark.zone then
                if Types.isVictoryPointToken(object) then
                    playBoard:updatePlayerScore()
                end
            end
        end
    end
end

---
function PlayBoard:_tearDown()
    self:_cleanUp(true, true, true)
    PlayBoard.playboards[self.color] = nil
end

---
function PlayBoard:_cleanUp(base, ix, immortality)
    local content = self.content

    local toBeRemoved = {}

    if base then
        Helper.addAll(toBeRemoved, {
            content.swordmaster,
            content.councilToken,
            content.scoreMarker,
            content.controlMarkerBag,
            content.forceMarker,
            content.startEndTurnButton,
            content.fourPlayerVictoryToken
        })
        Helper.addAll(toBeRemoved, content.agents)
        Helper.addAll(toBeRemoved, content.troops)
    end

    if ix then
        Helper.addAll(toBeRemoved, content.dreadnoughts)
        table.insert(toBeRemoved, content.controlMarkerBag)
        table.insert(toBeRemoved, content.freighter)
        table.insert(toBeRemoved, content.atomicsToken)
    end

    if immortality then
        table.insert(toBeRemoved, content.tleilaxToken)
        table.insert(toBeRemoved, content.researchToken)
    end

    for _, object in ipairs(toBeRemoved) do
        if toBeRemoved then
            object.interactable = true
            object.destruct()
        end
    end
end

---
function PlayBoard.findBoardColor(board)
    for color, _ in pairs(PlayBoard.playboards) do
        if PlayBoard._getBoard(color) == board then
            return color
        end
    end
    return nil
end

---
function PlayBoard:_createExclusiveCallback(innerCallback)
    return Helper.registerGlobalCallback(function (_, color, _)
        if self.color == color or PlayBoard.isRival(self.color) then
            if not self.buttonsDisabled then
                self.buttonsDisabled = true
                Helper.onceTimeElapsed(0.5).doAfter(function ()
                    self.buttonsDisabled = false
                end)
                innerCallback()
            end
        else
            broadcastToColor(I18N('noTouch'), color, "Purple")
        end
    end)
end

---
function PlayBoard:getFontColor()
    local fontColor = { 0.9, 0.9, 0.9 }
    if self.color == 'Yellow' then
        fontColor = { 0.1, 0.1, 0.1 }
    end
    return fontColor
end

function PlayBoard:_clearButtons()
    Helper.clearButtons(self.content.board)
    if self.content.atomicsToken then
        Helper.clearButtons(self.content.atomicsToken)
    end
end

---
function PlayBoard:_createButtons()
    self:_clearButtons()

    local fontColor = self:getFontColor()

    local board = self.content.board

    board.createButton({
        click_function = self:_createExclusiveCallback(function ()
            self:drawCards(1)
        end),
        label = I18N("drawOneCardButton"),
        position = self:_newOffsetedBoardPosition(-13.5, 0, 1.8),
        width = 1100,
        height = 250,
        font_size = 150,
        color = self.color,
        font_color = fontColor
    })

    board.createButton({
        click_function = self:_createExclusiveCallback(function ()
            -- Note: the Holtzman effect happens at the recall phase (drawing 5
            -- cards is not stricly done when a round starts.)
            self:drawCards(5)
        end),
        label = I18N("drawFiveCardsButton"),
        position = self:_newOffsetedBoardPosition(-13.5, 0, 2.6),
        width = 1400,
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
            self:onRevealHand()
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

---
function PlayBoard:_createNukeButton()
    if self.content.atomicsToken then
        self.content.atomicsToken.createButton({
            click_function = self:_createExclusiveCallback(function ()
                self:_nukeConfirm()
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
        broadcastToColor(I18N("revealNotTurn"), self.color, "Pink")
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

    local function _cleanUp()
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
            _cleanUp()
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
        click_function = self:_createExclusiveCallback(_cleanUp),
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

    Park.putObjects(revealedCards, self.revealCardPark)

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

    return Set.newFromList(playedCards) - Set.newFromList(playBoard.alreadyPlayedCards)
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
function PlayBoard:tryToDrawCards(count, message)
    local content = self.content
    local deck = Helper.getDeckOrCard(content.drawDeckZone)
    local discard = Helper.getDeckOrCard(content.discardZone)

    local needDiscardReset = Helper.getCardCount(deck) < count
    local availableCardCount = Helper.getCardCount(deck) + Helper.getCardCount(discard)
    local notEnoughCards = availableCardCount < count

    if needDiscardReset or notEnoughCards then
        local leaderName = PlayBoard.getLeaderName(self.color)
        broadcastToAll(I18N("isDecidingToDraw", { leader = leaderName }), "Pink")
        local maxCount = math.min(count, availableCardCount)
        Player[self.color].showConfirmDialog(
            I18N("warningBeforeDraw", { count = count, maxCount = maxCount }),
            function(_)
                if message then
                    broadcastToAll(message, self.color)
                end
                self:drawCards(count)
            end)
    else
        self:drawCards(count)
    end
end

---
function PlayBoard:drawCards(count)
    Types.assertIsInteger(count)
    local remainingCardToDrawCount = count

    local deckOrCard = Helper.getDeckOrCard(self.content.drawDeckZone)
    local drawableCardCount = Helper.getCardCount(deckOrCard)

    local dealCardCount = math.min(remainingCardToDrawCount, drawableCardCount)
    if dealCardCount > 0 then
        deckOrCard.deal(dealCardCount, self.color)
        -- FIXME Should be in Action.
        printToAll(I18N("drawObjects", { amount = dealCardCount, object = I18N.agree(dealCardCount, "imperiumCard") }), self.color)
    end

    remainingCardToDrawCount = remainingCardToDrawCount - dealCardCount

    if remainingCardToDrawCount > 0 then
        local reset = self:_resetDiscard()
        if reset then
            reset.doAfter(function()
                self:drawCards(remainingCardToDrawCount)
            end)
        end
    end
end

---
function PlayBoard:_resetDiscard()
    local discard = Helper.getDeckOrCard(self.content.discardZone)
    if discard then
        local continuation = Helper.createContinuation("PlayBoard:_resetDiscard")

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

        return continuation
    else
        return nil
    end
end

---
function PlayBoard:_nukeConfirm()
    local token = self.content.atomicsToken
    Helper.clearButtons(token)

    local function _cleanUp()
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
            _cleanUp()
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
            _cleanUp()
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
    local playBoard = PlayBoard.getPlayBoard(color)
    if playBoard.opponent == "rival" then
        if Hagal.getRivalCount() == 1 then
            playBoard.leader = Hagal.newRival(color)
        else
            if not Hagal.isLeaderCompatible(leaderCard) then
                log("Not a leader compatible with a rival: " .. Helper.getID(leaderCard))
                return false
            end
            playBoard.leader = Hagal.newRival(color, Leader.newLeader(Helper.getID(leaderCard)))
        end
    else
        playBoard.leader = Leader.newLeader(Helper.getID(leaderCard))
    end
    assert(playBoard.leader)
    local position = playBoard.content.leaderZone.getPosition()
    leaderCard.setPosition(position)
    playBoard.leaderCard = leaderCard
    Helper.noPlay(leaderCard)
    return true
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
    local leader = PlayBoard.getPlayBoard(color).leader
    if not leader then
        log(color .. " has no leader.")
    end
    return leader
end

---
function PlayBoard.getLeaderName(color)
    local leader = PlayBoard.findLeaderCard(color)
    return leader and leader.getName() or "?"
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
        for _, object in ipairs(self.scorePark.zone.getObjects()) do
            if Types.isVictoryPointToken(object) then
                score = score + 1
            end
        end
    end
    return score
end

---
function PlayBoard.grantTechTile(color, techTile)
    Park.putObject(techTile, PlayBoard.getPlayBoard(color).techPark)
end

---
function PlayBoard.getScoreTokens(color)
    return Park.getObjects(PlayBoard.getPlayBoard(color).scorePark)
end

---
function PlayBoard.grantScoreToken(color, token)
    Park.putObject(token, PlayBoard.getPlayBoard(color).scorePark)
end

---
function PlayBoard.grantScoreTokenFromBag(color, tokenBag)
    Park.putObjectFromBag(tokenBag, PlayBoard.getPlayBoard(color).scorePark)
end

---
function PlayBoard.hasTech(color, techName)
    return PlayBoard.getTech(color, techName) ~= nil
end

---
function PlayBoard.getTech(color, techName)
    local techs = PlayBoard.getPlayBoard(color).techPark.zone.getObjects()
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
    Helper.dumpFunction("PlayBoard.hasHighCouncilSeat", color)
    local zone = MainBoard.getHighCouncilSeatPark().zone
    local token = PlayBoard.getCouncilToken(color)
    return Helper.contains(zone, token)
end

---
function PlayBoard.takeHighCouncilSeat(color)
    local token = PlayBoard.getCouncilToken(color)
    if not PlayBoard.hasHighCouncilSeat(color) then
        if Park.putObject(token, MainBoard.getHighCouncilSeatPark()) then
            token.interactable = false
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
    return Helper.contains(PlayBoard.getAgentPark(color).zone, PlayBoard.getSwordmaster(color))
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
    local content = PlayBoard.getContent(color)
    assert(content)

    printToAll(I18N(isTleilaxuCard and "acquireTleilaxuCard" or "acquireImperiumCard", { card = I18N(Helper.getID(card)) }), color)

    -- Acquire the card (not smoothly to avoid being grabbed by a player hand zone).
    card.setPosition(content.discardZone.getPosition())

    -- Move it on the top of the content deck if possible and wanted.
    if (isTleilaxuCard and TleilaxuResearch.hasReachedOneHelix(color)) or PlayBoard.hasTech(color, "Spaceport") then
        Player[color].showConfirmDialog(
            I18N("dialogCardAbove"),
            function(_)
                Helper.moveCardFromZone(content.discardZone, content.drawDeckZone.getPosition(), Vector(0, 180, 180))
            end)
    end
end

---
function PlayBoard.giveCardFromZone(color, zone, isTleilaxuCard)
    local content = PlayBoard.getContent(color)
    assert(content)

    -- Acquire the card (not smoothly to avoid being grabbed by a player hand zone).
    Helper.moveCardFromZone(zone, content.discardZone.getPosition()).doAfter(function (card)
        local cardName = I18N(Helper.getID(card))
        printToAll(I18N(isTleilaxuCard and "acquireTleilaxuCard" or "acquireImperiumCard", { card = cardName }), color)
    end)

    -- Move it on the top of the player deck if possible and wanted.
    if (isTleilaxuCard and TleilaxuResearch.hasReachedOneHelix(color)) or PlayBoard.hasTech(color, "Spaceport") then
        Player[color].showConfirmDialog(
            I18N("dialogCardAbove"),
            function(_)
                Helper.moveCardFromZone(content.discardZone, content.drawDeckZone.getPosition(), Vector(0, 180, 180))
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
    if self.color == "Red" or self.color == "Blue" then
        return self:_newBoardPosition(-x, y, z)
    else
        return self:_newBoardPosition(x, y, z)
    end
end

---
function PlayBoard:_newSymmetricBoardRotation(x, y, z)
    if self.color == "Red" or self.color == "Blue" then
        return self:_newBoardPosition(x, -y, z)
    else
        return self:_newBoardPosition(x, y, z)
    end
end

---
function PlayBoard:_newOffsetedBoardPosition(x, y, z)
    if self.color == "Red" or self.color == "Blue" then
        return self:_newBoardPosition(17 + x, y, z)
    else
        return self:_newBoardPosition(x, y, z)
    end
end

---
function PlayBoard:_newBoardPosition(x, y, z)
    return Vector(x, y + 0.7, -z)
end

return PlayBoard
