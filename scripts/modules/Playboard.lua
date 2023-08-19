local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")
local I18N = require("utils.I18N")

local Resource = Module.lazyRequire("Resource")
local TleilaxuResearch = Module.lazyRequire("TleilaxuResearch")
local TurnControl = Module.lazyRequire("TurnControl")
local Utils = Module.lazyRequire("Utils")
local Deck = Module.lazyRequire("Deck")
local MainBoard = Module.lazyRequire("MainBoard")
local Hagal = Module.lazyRequire("Hagal")
local Leader = Module.lazyRequire("Leader")
local Combat = Module.lazyRequire("Combat")

local Playboard = Helper.createClass(nil, {
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
                Helper.getHardcodedPositionFromGUID('1a3c82', -26.3000431, 1.112601, 18.6999626),
                Helper.getHardcodedPositionFromGUID('a8f306', -28.7000542, 1.1126014, 18.6999741)
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
            scoreMarker = "4feaca",
            flagBag = '61453d',
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
            discardPosition = Helper.getHardcodedPositionFromGUID('e07493', -14.0, 1.5, 16.5) + Helper.someHeight,
            drawDeckZone = "4f08fc",
            discardZone = "e07493",
            trash = "ea3fe1",
            tleilaxToken = "2bfc39",
            tleilaxTokenInitalPosition = Helper.getHardcodedPositionFromGUID('2bfc39', 0.5446165, 0.877500236, 22.0549927),
            researchToken = "39e0f3",
            researchTokenInitalPosition = Helper.getHardcodedPositionFromGUID('39e0f3', 0.37, 0.88, 18.2351761),
            cargo = "e9096d",
            leaderPos = Helper.getHardcodedPositionFromGUID('66cdbb', -19.0, 1.25, 17.5),
            firstPlayerPosition = Helper.getHardcodedPositionFromGUID('346e0d', -14.0, 1.5, 19.7) + Vector(0, -0.4, 0),
            startEndTurnButton = "895594"
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
                Helper.getHardcodedPositionFromGUID('82789e', -26.30006, 1.11260116, -4.30004025),
                Helper.getHardcodedPositionFromGUID('60f208', -28.7000713, 1.11260128, -4.30005264)
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
            flagBag = '8627e0',
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
            discardPosition = Helper.getHardcodedPositionFromGUID('26bf8b', -14.0, 1.5, -6.5) + Helper.someHeight,
            drawDeckZone = "907f66",
            discardZone = "26bf8b",
            trash = "52a539",
            tleilaxToken = "96607f",
            tleilaxTokenInitalPosition = Helper.getHardcodedPositionFromGUID('96607f', 0.544616759, 0.8800002, 22.75),
            researchToken = "292658",
            researchTokenInitalPosition = Helper.getHardcodedPositionFromGUID('292658', 0.37, 0.8775002, 18.9369965),
            cargo = "68e424",
            leaderPos = Helper.getHardcodedPositionFromGUID('681774', -19.0, 1.25506675, -5.5),
            firstPlayerPosition = Helper.getHardcodedPositionFromGUID('1fc559', -14.0, 1.501278, -3.3) + Vector(0, -0.4, 0),
            startEndTurnButton = "9eeccd"
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
                Helper.getHardcodedPositionFromGUID('a15087', 26.2999687, 1.11260116, 18.6999722),
                Helper.getHardcodedPositionFromGUID('734250', 28.6999531, 1.11260128, 18.6999645)
            },
            agents = {"66ae45", "bceb0e"},
            agentPositions = {
                Helper.getHardcodedPositionFromGUID('66ae45', 17.0, 1.11060035, 20.2999935),
                Helper.getHardcodedPositionFromGUID('bceb0e', 18.3, 1.11060047, 20.3)
            },
            swordmaster = "fb1629",
            councilToken = "a0028d",
            fourPlayerVictoryToken = "66444c",
            fourPlayerVictoryTokenInitialPosition = Helper.getHardcodedPositionFromGUID('66444c', 13.0, 1.31223154, 21.85),
            scoreMarker = "76039f",
            flagBag = 'ad6b92',
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
            discardPosition = Helper.getHardcodedPositionFromGUID('2298aa', 24.0, 1.5, 16.5) + Helper.someHeight,
            drawDeckZone = "6d8a2e",
            discardZone = "2298aa",
            trash = "4060b5",
            tleilaxToken = "63d39f",
            tleilaxTokenInitalPosition = Helper.getHardcodedPositionFromGUID('63d39f', 1.24461639, 0.8800001, 22.05),
            researchToken = "658b17",
            researchTokenInitalPosition = Helper.getHardcodedPositionFromGUID('658b17', 0.37, 0.877500236, 20.34),
            cargo = "34281d",
            leaderPos = Helper.getHardcodedPositionFromGUID('cf1486', 19.0, 1.18726385, 17.5),
            firstPlayerPosition = Helper.getHardcodedPositionFromGUID('59523d', 14.0, 1.45146358, 19.7) + Vector(0, -0.4, 0),
            startEndTurnButton = "96aa58"
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
                Helper.getHardcodedPositionFromGUID('5469fb', 26.2999344, 1.11260128, -4.300015),
                Helper.getHardcodedPositionFromGUID('71a414', 28.6999378, 1.11260116, -4.30003929)
            },
            agents = {"5068c8", "67b476"},
            agentPositions = {
                Helper.getHardcodedPositionFromGUID('5068c8', 17.0, 1.11060047, -2.70000386),
                Helper.getHardcodedPositionFromGUID('67b476', 18.3, 1.11060047, -2.699999)
            },
            swordmaster = "635c49",
            councilToken = "1be491",
            fourPlayerVictoryToken = "4e8873",
            fourPlayerVictoryTokenInitialPosition = Helper.getHardcodedPositionFromGUID('4e8873', 13.0, 1.31223142, -1.14999938),
            scoreMarker = "20bbd1",
            flagBag = 'b92a4c',
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
            discardPosition = Helper.getHardcodedPositionFromGUID('6bb3b6', 24.0, 1.5, -6.5) + Helper.someHeight,
            drawDeckZone = "e6cfee",
            discardZone = "6bb3b6",
            trash = "7d1e07",
            tleilaxToken = "d20bcf",
            tleilaxTokenInitalPosition = Helper.getHardcodedPositionFromGUID('d20bcf', 1.24461651, 0.880000234, 22.75),
            researchToken = "8988cf",
            researchTokenInitalPosition = Helper.getHardcodedPositionFromGUID('8988cf', 0.37, 0.88, 19.6394081),
            cargo = "8fa76f",
            leaderPos = Helper.getHardcodedPositionFromGUID('a677e0', 19.0, 1.17902148, -5.5),
            firstPlayerPosition = Helper.getHardcodedPositionFromGUID('e9a44c', 14.0, 1.44851, -3.3) + Vector(0, -0.4, 0),
            startEndTurnButton = "3d1b90"
        }
    },
    playboards = {},
    nextPlayer = nil
})

---
function Playboard.onLoad(state)
    for color, unresolvedContent in pairs(Playboard.unresolvedContentByColor) do
        Playboard.playboards[color] = Playboard.new(color, unresolvedContent, state)
    end
    Playboard.unresolvedContentByColor = nil
end

---
function Playboard.new(color, unresolvedContent, state)
    --log("Playboard.new(" .. tostring(color) .. ", _, _)")

    local playboard = Helper.createClassInstance(Playboard, {
        color = color,
        content = nil,
        agentPark = nil,
        dreadnoughtPark = nil,
        supplyPark = nil,
        score = 0,
        scorePositions = {},
        scorePark = nil,
        techPark = nil,
        alive = true,
        state = Helper.createTable(state, "players", color)
    })

    if #playboard.state > 0 then
        playboard.alive = state.alive
    end

    if playboard.alive then
        playboard.content = Helper.resolveGUIDs(true, unresolvedContent)
    else
        log(color .. " player is not alive")
        return nil
    end

    local board = playboard.content.board
    board.interactable = false

    for _, itemName in ipairs({
        "councilToken",
        "cargo",
        "tleilaxToken",
        "researchToken",
    }) do
        local item = playboard.content[itemName]
        assert(item, "No " .. itemName .. " item")
        -- We want physics, but not player.
        item.setLock(false)
        item.interactable = false
    end

    for _, itemName in ipairs({
        "scoreMarker",
        "forceMarker",
    }) do
        local item = playboard.content[itemName]
        assert(item, "No " .. itemName .. " item")
        -- We don't want physics, nor player.
        item.setLock(true)
        item.interactable = false
    end

    -- FIXME Why this offset? In particular, why the Z component introduces an asymmetry?
    local offset = Vector(0, 0.55, 5.1)
    local centerPosition = board.getPosition() + offset

    for _, resourceName in ipairs({ "spice", "water", "solari", "persuasion", "strength" }) do
        local token = playboard.content[resourceName]
        playboard[resourceName] = Resource.new(token, color, resourceName, 0, state)
    end

    Helper.createTransientAnchor("instructionTextAnchor", board.getPosition() + playboard:newSymmetricBoardPosition(12, -0.5, -8)).doAfter(function (anchor)
        playboard.instructionTextAnchor = anchor
    end)

    playboard.revealPark = playboard:createRevealCardPark()
    playboard.agentPark = playboard:createAgentPark(unresolvedContent.agentPositions)
    playboard.dreadnoughtPark = playboard:createDreadnoughtPark(unresolvedContent.dreadnoughtPositions)
    playboard.supplyPark = playboard:createSupplyPark(centerPosition)
    playboard.techPark = playboard:createTechPark(centerPosition)
    playboard:generatePlayerScoreboardPositions()
    playboard.scorePark = playboard:createPlayerScoreboardPark()

    playboard:createButtons()
    playboard:updateState()

    Helper.registerEventListener("locale", function ()
        playboard:createButtons()
    end)

    return playboard
end

---
function Playboard.setUp(ix, immortality, epic, activeOpponents)
    for color, playboard in pairs(Playboard.playboards) do
        playboard:cleanUp(false, not ix, not immortality)
        playboard.opponent = activeOpponents[color]
        if playboard.opponent then
            if playboard.opponent ~= "rival" then
                Deck.generateStarterDeck(playboard.content.drawDeckZone, immortality, epic).doAfter(function (deck)
                    deck.shuffle()
                end)
                Deck.generateStarterDiscard(playboard.content.discardZone, immortality, epic)
            end
            playboard:updatePlayerScore()
        else
            playboard:shutdown()
        end
    end

    Helper.registerEventListener("phaseStart", function (phase, firstPlayer)
        if phase == "leaderSelection" or phase == "roundStart" then
            local playboard = Playboard.getPlayboard(firstPlayer)
            MainBoard.firstPlayerMarker.setPositionSmooth(playboard.content.firstPlayerPosition, false, false)
        end

        if phase == "roundStart" then
            for color, playboard in pairs(Playboard._getPlayboards()) do
                playboard.leader.drawImperiumCards(color, 5)
            end
            -- TODO Query acquired tech tiles for round start recurring effects.
        end

        if phase == "recall" then
            for color, playboard in pairs(Playboard._getPlayboards()) do
                playboard.revealed = false
                playboard.persuasion:set(Playboard.hasACouncilSeat(color) and 2 or 0)
                playboard.strength:set(0)
                -- TODO Query acquired tech tiles for specific persuasion / strength permanent effects.
            end
            -- TODO Send all played cards to the discard (general discard for intrigue cards).
            -- TODO Flip any used tech.
        end
    end)

    Helper.registerEventListener("phaseEnd", function (phase)
        if phase == "leaderSelection" then
            for color, playboard in pairs(Playboard._getPlayboards()) do
                playboard.leader.setUp(color, epic)
            end
        end
    end)

    Helper.registerEventListener("playerTurns", function (phase, color)
        local playboard = Playboard.getPlayboard(color)
        if playboard.leader then
            if false then
                local instruction = playboard.leader.instruct(phase, color)
                if instruction then
                    -- Wait for setActivePlayer to change the (hotseated) player if needed.
                    Wait.frames(function ()
                        local player = Helper.findPlayer(color)
                        assert(player, "No " .. tostring(color) .. " player!")
                        player.broadcast(instruction, Color.fromString("Pink"))
                    end, 1)
                end
            end

            for otherColor, otherPlayboard in pairs(Playboard._getPlayboards()) do
                if Playboard.isHuman(otherColor) then
                    local instruction = playboard.leader.instruct(phase, otherColor)
                    if instruction and otherPlayboard.instructionTextAnchor then
                        otherPlayboard.instructionTextAnchor.clearButtons()
                        Helper.createAbsoluteButtonWithRoundness(otherPlayboard.instructionTextAnchor, 1, false, {
                            click_function = "NOP",
                            label = instruction,
                            position = otherPlayboard.instructionTextAnchor.getPosition() + Vector(0, 0.5, 0),
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
        end

        Playboard.setActivePlayer(phase, color)

        MusicPlayer.setCurrentAudioclip({
            url = "http://cloud-3.steamusercontent.com/ugc/2027235268872374937/7FE5FD8B14ED882E57E302633A16534C04C18ECE/",
            title = "Next turn"
        })
    end)
end

---
function Playboard.setActivePlayer(phase, color)
    local indexedColors = {"Green", "Yellow", "Blue", "Red"}
    for i, otherColor in ipairs(indexedColors) do
        local playboard = Playboard.getPlayboard(otherColor)
        if playboard.opponent then
            local effectIndex = 0 -- black index (no color actually)
            if otherColor == color then
                effectIndex = i
                playboard.content.startEndTurnButton.interactable = true
                if playboard.opponent == "rival" then
                    Hagal.activate(phase, color, playboard)
                else
                    if phase ~= "leaderSelection" then
                        playboard:_createEndOfTurnButton()
                    end
                    Playboard._movePlayerIfNeeded(color)
                end
            else
                playboard.content.startEndTurnButton.interactable = false
                playboard.content.startEndTurnButton.clearButtons()
            end
            local board = playboard.content.board
            board.AssetBundle.playTriggerEffect(effectIndex)
        end
    end
end

--- Hotseat
function Playboard._movePlayerIfNeeded(color)
    local anyOtherPlayer = nil
    for _, player in ipairs(Player.getPlayers()) do
        if player.color == color then
            return
        else
            anyOtherPlayer = player
        end
    end
    if anyOtherPlayer then
        Playboard.getPlayboard(anyOtherPlayer.color).opponent = "puppet"
        Playboard.getPlayboard(color).opponent = anyOtherPlayer
        anyOtherPlayer.changeColor(color)
    end
end

---
function Playboard:_createEndOfTurnButton()
    self.content.startEndTurnButton.createButton({
        click_function = self:createExclusiveCallback("onEndOfTurn", function ()
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
function Playboard.acceptTurn(phase, color)
    local playboard = Playboard.getPlayboard(color)
    local accepted = false

    if phase == 'leaderSelection' then
        accepted = playboard.leader == nil
    elseif phase == 'gameStart' then
        accepted = playboard.lastPhase ~= phase and playboard.leader.instruct(phase, color)
    elseif phase == 'roundStart' then
        accepted = playboard.lastPhase ~= phase and playboard.leader.instruct(phase, color)
    elseif phase == 'playerTurns' then
        accepted = Playboard.couldSendAgentOrReveal(color)
    elseif phase == 'combat' then
        -- TODO Pass count < player in combat count.
        accepted = playboard.lastPhase ~= phase and Combat.isInCombat(color)
    elseif phase == 'combatEnd' then
        -- TODO Player is victorious and the combat provied a reward (auto?) or
        -- a dreadnought needs to be placed or a combat card remains to be played.
        accepted = playboard.lastPhase ~= phase and Combat.isInCombat(color)
    elseif phase == 'makers' then
        accepted = false
    elseif phase == 'recall' then
        accepted = false
    elseif phase == 'endgame' then
        -- TODO
        accepted = false
    else
        error("Unknown phase: " .. phase)
    end

    playboard.lastPhase = phase
    return accepted
end

---
function Playboard:updateState()
    -- Do *not* change self.state reference!
    self.state.alive = self.alive
end

---
function Playboard.getPlayboard(color)
    assert(#Helper.getKeys(Playboard.playboards) > 0, "No playboard at all: probably called in 'new'.")
    local playboard = Playboard.playboards[color]
    assert(playboard, "No playboard for color " .. tostring(color))
    return playboard
end

---
function Playboard._getPlayboards(filterOutRival)
    assert(#Helper.getKeys(Playboard.playboards) > 0, "No playboard at all: probably called in 'new'.")
    local filteredPlayboards = {}
    for color, playboard in pairs(Playboard.playboards) do
        if playboard.opponent and (not filterOutRival or playboard.opponent ~= "rival") then
            filteredPlayboards[color] = playboard
        end
    end
    return filteredPlayboards
end

---
function Playboard.getPlayboardColors(filterOutRival)
    return Helper.getKeys(Playboard._getPlayboards(filterOutRival))
end

---
function Playboard.getBoard(color)
    return Playboard.getContent(color).board
end

---
function Playboard:createRevealCardPark()
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
    local origin = self.content.board.getPosition() + offsets[self.color]

    local slots = {}
    for i = 0, 11 do
        table.insert(slots, origin + Vector(i * step, 0, 0))
    end

    local park = Park.createCommonPark({ "Imperium" }, slots, Vector(2.4, 0.5, 3.2), Vector(0, 180, 0))
    park.smooth = false
    return park
end

---
function Playboard:createAgentPark(agentPositions)
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
function Playboard:createDreadnoughtPark(dreadnoughtPositions)
    local park = Park.createCommonPark({ self.color, "Dreadnought" }, dreadnoughtPositions, Vector(1, 3, 0.5))
    for i, dreadnought in ipairs(self.content.dreadnoughts) do
        dreadnought.setPosition(dreadnoughtPositions[i])
    end
    return park
end

---
function Playboard:createSupplyPark(centerPosition)
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
function Playboard:createTechPark(centerPosition)
    local color = self.color
    local slots = {}
    for i = 1, 2 do
        for j = 3, 1, -1 do
            local x = (i - 1.5) * 3 + 6
            if color == "Red" or color == "Blue" then
                x = -x
            end
                local z = (j - 2) * 2 + 0.4
            local slot = Vector(x, 0.2, z) + centerPosition
            table.insert(slots, slot)
        end
    end

    return Park.createCommonPark({ "Tech" }, slots, Vector(3, 0.2, 2), Vector(0, 180, 0))
end

---
function Playboard:generatePlayerScoreboardPositions()
    local origin = self.content.scoreMarker.getPosition()

    -- Avoid collision between markers by giving a different height to each.
    local heights = {
        Green = 1,
        Yellow = 1.5,
        Blue = 2,
        Red = 2.5,
    }

    self.scorePositions = {}
    for i = 0, 12 do
        self.scorePositions[i] = {
            origin.x,
            1 + heights[self.color],
            origin.z + i * 1.165
        }
    end
end

---
function Playboard:createPlayerScoreboardPark()
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
function Playboard:updatePlayerScore()
    local cappedScore = math.min(14, self:getScore())
    local scoreMarker = self.content.scoreMarker
    scoreMarker.setLock(false)
    scoreMarker.setPositionSmooth(self.scorePositions[cappedScore])
end

---
function Playboard.onObjectEnterScriptingZone(zone, object)
    for color, playboard in pairs(Playboard.playboards) do
        if playboard.opponent then
            if zone == playboard.scorePark.zone then
                if Utils.isVictoryPointToken(object) then
                    playboard:updatePlayerScore()
                    local controlableSpace = MainBoard.findControlableSpace(object)
                    if controlableSpace then
                        MainBoard.occupy(controlableSpace, playboard.content.flagBag)
                    end
                end
            elseif zone == playboard.agentPark.zone then
                if Utils.isMentat(object) then
                    object.addTag(color)
                    object.setColorTint(playboard.content.swordmaster.getColorTint())
                end
            end
        end
    end
end

---
function Playboard.onObjectLeaveScriptingZone(zone, object)
    for _, playboard in pairs(Playboard.playboards) do
        if playboard.opponent then
            if zone == playboard.scorePark.zone then
                if Utils.isVictoryPointToken(object) then
                    playboard:updatePlayerScore()
                end
            end
        end
    end
end

---
function Playboard:shutdown()
    self.alive = false
    self:updateState()
    self:cleanUp(true, true, true)
end

---
function Playboard:cleanUp(base, ix, immortality)
    local content = self.content

    local toBeRemoved = {}

    if base then
        Helper.addAll(toBeRemoved, {
            content.swordmaster,
            content.councilToken,
            content.scoreMarker,
            content.flagBag,
            content.forceMarker,
            content.startEndTurnButton
        })
        Helper.addAll(toBeRemoved, content.agents)
        Helper.addAll(toBeRemoved, content.troops)
    end

    if ix then
        Helper.addAll(toBeRemoved, content.dreadnoughts)
        table.insert(toBeRemoved, content.flagBag)
        table.insert(toBeRemoved, content.cargo)
        -- TODO Add atomics.
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
function Playboard.findBoardColor(board)
    for color, _ in pairs(Playboard.playboards) do
        if Playboard.getBoard(color) == board then
            return color
        end
    end
    return nil
end

---
function Playboard:createExclusiveCallback(name, f)
    return Helper.createGlobalCallback(function (_, color, _)
        if self.color == color then
            -- Inhibit the buttons for a short time.
            self.content.board.clearButtons()
            Wait.time(function()
                self:createButtons()
            end, 0.3)

            f()
        else
            broadcastToColor(I18N('noTouch'), color, "Purple")
        end
    end)
end

---
function Playboard:createCallback(name, f)
    return Helper.createGlobalCallback(function (_, color, _)
        if self.color == color then
            f()
        else
            broadcastToColor(I18N('noTouch'), color, "Purple")
        end
    end)
end

---
function Playboard:getFontColor()
    local fontColor = { 0.9, 0.9, 0.9 }
    if self.color == 'Yellow' then
        fontColor = { 0.1, 0.1, 0.1 }
    end
    return fontColor
end

---
function Playboard:createButtons()
    local fontColor = self:getFontColor()

    local board = self.content.board

    board.createButton({
        click_function = self:createExclusiveCallback("onDrawOneCard", function ()
            self:drawCards(1)
        end),
        label = I18N("drawOneCardButton"),
        position = self:newOffsetedBoardPosition(-13.5, 0, 1.8),
        width = 1100,
        height = 250,
        font_size = 150,
        color = self.color,
        font_color = fontColor
    })

    board.createButton({
        click_function = self:createExclusiveCallback("onDrawFiveCards", function ()
            -- Note: the Holtzman effect happens at the recall phase (drawing 5
            -- cards is not stricly done when a round starts.)
            self:tryToDrawCards(5)
        end),
        label = I18N("drawFiveCardsButton"),
        position = self:newOffsetedBoardPosition(-13.5, 0, 2.6),
        width = 1400,
        height = 250,
        font_size = 150,
        color = self.color,
        font_color = fontColor
    })

    board.createButton({
        click_function = self:createExclusiveCallback("onResetDiscard", function ()
            self:resetDiscard()
        end),
        label = I18N("resetDiscardButton"),
        position = self:newOffsetedBoardPosition(-3.5, 0, 2.6),
        width = 1200,
        height = 250,
        font_size = 150,
        color = self.color,
        font_color = fontColor
    })

    -- function Playboard_onDoNothing(_, _, _) end
    board.createButton({
        click_function = "NOP",
        label = I18N("agentTurn"),
        position = self:newSymmetricBoardPosition(-14.8, 0, -1),
        rotation = self:newSymmetricBoardRotation(0, -90, 0),
        width = 0,
        height = 0,
        font_size = 280,
        color = { 0, 0, 0, 1 },
        font_color = self.color
    })

    board.createButton({
        click_function = self:createExclusiveCallback("onRevealHand", function ()
            self:onRevealHand()
        end),
        label = I18N("revealHandButton"),
        position = self:newSymmetricBoardPosition(-14.8, 0, -5),
        rotation = self:newSymmetricBoardRotation(0, -90, 0),
        width = 1600,
        height = 320,
        font_size = 280,
        color = self.color,
        font_color = fontColor
    })
end

---
function Playboard:onRevealHand()
    local currentPlayer = TurnControl.getCurrentPlayer()
    if currentPlayer and currentPlayer ~= self.color then
        broadcastToColor(I18N("revealNotTurn"), self.color, "Pink")
    elseif self:stillHavePlayableAgents() then
        self:tryRevealHandEarly()
    else
        self:revealHand()
    end
end

---
function Playboard.hasRevealed(color)
    return Playboard.getPlayboard(color).revealed
end

---
function Playboard:tryRevealHandEarly()
    if self.revealed then
        return
    end

    local origin = Playboard.getPlayboard(self.color):newSymmetricBoardPosition(-8, 0, -4.5)

    local board = self.content.board

    board.createButton({
        click_function = 'NOP',
        label = I18N("revealEarlyConfirm"),
        position = origin,
        width = 0,
        height = 0,
        scale = {0.5, 0.5, 0.5},
        font_size = 500,
        font_color = self.color,
        color = {0, 0, 0, 1}
    })
    board.createButton({
        click_function = self:createExclusiveCallback("onValidateReveal", function ()
            self:revealHand()
        end),
        label = I18N('yes'),
        position = origin + Vector(1, 0, 1),
        width = 1000,
        height = 600,
        scale = {0.5, 0.5, 0.5},
        font_size = 500,
        font_color = {1, 1, 1},
        color = "Green"
    })
    board.createButton({
        click_function = self:createExclusiveCallback("onCancelReveal", function ()
            self:resetDiscard()
        end),
        label = I18N('no'),
        position = origin + Vector(-1, 0, 1),
        width = 1000,
        height = 600,
        scale = {0.5, 0.5, 0.5},
        font_size = 500,
        font_color = {1, 1, 1},
        color = "Red"
    })
end

---
function Playboard:revealHand()
    local cards = Helper.filter(Player[self.color].getHandObjects(), function (card) return card.hasTag('Imperium') end)
    Park.putObjects(cards, self.revealPark)
    self.revealed = true
end

---
function Playboard:getRevealCardPosition(i)
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
    local p = self.content.board.getPosition() + offsets[self.color]
    return p + Vector(i * step, 0, 0)
end

---
function Playboard:stillHavePlayableAgents()
    return #Park.getObjects(self.agentPark) > 0
end

---
function Playboard.couldSendAgentOrReveal(color)
    local playboard = Playboard.getPlayboard(color)
    if playboard.opponent == "rival" then
        return playboard:stillHavePlayableAgents()
    else
        return not playboard.revealed
    end
end

---
function Playboard:tryToDrawCards(count, message)
    local content = self.content
    local deck = Helper.getDeckOrCard(content.drawDeckZone)
    local discard = Helper.getDeckOrCard(content.discardZone)

    local needDiscardReset = Helper.getCardCount(deck) < count
    local availableCardCount = Helper.getCardCount(deck) + Helper.getCardCount(discard)
    local notEnoughCards = availableCardCount < count

    if needDiscardReset or notEnoughCards then
        local leaderName = Playboard.getLeaderName(self.color)
        broadcastToAll(I18N("isDecidingToDraw"):format(leaderName), "Pink")
        local counter = I18N.translateCountable(count, "card", "cards")
        local maxCount = math.min(count, availableCardCount)
        local maxCountCounter = I18N.translateCountable(maxCount, "card", "cards")
        Player[self.color].showConfirmDialog(
            I18N("warningBeforeDraw"):format(count, counter, maxCount, maxCountCounter),
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
function Playboard:drawCards(count)
    Utils.assertIsInteger(count)
    local remainingCardToDrawCount = count

    local deckOrCard = Helper.getDeckOrCard(self.content.drawDeckZone)
    if deckOrCard then
        local drawableCardCount = Helper.getCardCount(deckOrCard)

        local dealCardCount = math.min(remainingCardToDrawCount, drawableCardCount)
        deckOrCard.deal(dealCardCount, self.color)

        remainingCardToDrawCount = remainingCardToDrawCount - dealCardCount

        if remainingCardToDrawCount > 0 then
            local reset = self:resetDiscard()
            if reset then
                reset.doAfter(function(_)
                    self:drawCards(remainingCardToDrawCount)
                end)
            end
        end
    end
end

---
function Playboard:resetDiscard()
    local content = self.content
    local discard = Helper.getDeckOrCard(content.discardZone)
    if discard then
        local continuation = Helper.createContinuation()

        discard.setRotationSmooth({0, 180, 180}, false, false)
        discard.setPositionSmooth(Helper.getLandingPosition(content.drawDeckZone), false, true)

        Wait.time(function() -- Once moved.
            local replenishedDeckOrCard = Helper.getDeckOrCard(content.drawDeckZone)
            assert(replenishedDeckOrCard)
            if replenishedDeckOrCard.type == "Deck" then
                replenishedDeckOrCard.shuffle()
                Wait.time(function () -- Once shuffled.
                    continuation.run(replenishedDeckOrCard)
                end, 1.5)
            else
                continuation.run(replenishedDeckOrCard)
            end
        end, 0.5)

        return continuation
    else
        return nil
    end
end

---
function Playboard.activateButtons()
    self.clearButtons()
    self.createButton({
        click_function = 'nukeConfirm',
        label = i18n('atomics'),
        function_owner = self,
        position = {0, 0.1, 0},
        rotation = {0, 0, 0},
        width = 700,
        height = 700,
        scale = Vector(3, 3, 3),
        font_size = 300,
        font_color = {1, 1, 1, 100},
        color = {0, 0, 0, 0}
    })
end

---
function Playboard.nukeConfirm(_, color)
    if self.hasTag(color) then
        self.clearButtons()
        self.createButton({
            click_function = 'doNothing',
            label = i18n("atomicsConfirm"),
            function_owner = self,
            position = {0, 0.2, -2},
            rotation = {0, 0, 0},
            width = 0,
            height = 0,
            scale = Vector(3, 3, 3),
            font_size = 300,
            font_color = {1, 0, 0, 100},
            color = {0, 0, 0, 0}
        })
        self.createButton({
            click_function = 'nukeImperiumRow',
            label = i18n('yes'),
            function_owner = self,
            position = {-4, 0.2, 1},
            rotation = {0, 0, 0},
            width = 500,
            height = 300,
            scale = Vector(3, 3, 3),
            font_size = 300,
            font_color = {1, 1, 1},
            color = "Green"
        })
        self.createButton({
            click_function = 'cancelChoice',
            label = i18n('no'),
            function_owner = self,
            position = {4, 0.2, 1},
            rotation = {0, 0, 0},
            width = 500,
            height = 300,
            scale = Vector(3, 3, 3),
            font_size = 300,
            font_color = {1, 1, 1},
            color = "Red"
        })
    else
        broadcastToColor(i18n("noTouch"), color, color)
    end
end

---
function Playboard.cancelChoice(_)
    activateButtons()
end

---
function Playboard.getPlayerTextColors(color)

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
function Playboard.hasPlayer(color)
    return Playboard.getContent(color) ~= nil
end

---
function Playboard.isRival(color)
    local playerboard = Playboard.getPlayboard(color)
    return playerboard.opponent == "rival"
end

---
function Playboard.isHuman(color)
    local playerboard = Playboard.getPlayboard(color)
    return playerboard.opponent ~= "rival"
end

---
function Playboard.setLeader(color, leaderCard)
    local playboard = Playboard.getPlayboard(color)
    if playboard.opponent == "rival" then
        if Hagal.getRivalCount() == 1 then
            playboard.leader = Hagal.getRival(nil)
        else
            if not Hagal.isLeaderCompatible(leaderCard) then
                log("Not a leader compatible with a rival: " .. leaderCard.getDescription())
                return false
            end
            playboard.leader = Hagal.newRival(Leader.getLeader(leaderCard.getDescription()))
        end
    else
        playboard.leader = Leader.getLeader(leaderCard.getDescription())
    end
    assert(playboard.leader)
    local position = playboard.content.leaderZone.getPosition()
    leaderCard.setPosition(position)
    playboard.leaderCard = leaderCard
    return true
end

---
function Playboard.findLeaderCard(color)
    local leaderZone = Playboard.getContent(color).leaderZone
    for _, object in ipairs(leaderZone.getObjects()) do
        if object.hasTag("Leader") or object.hasTag("Hagal") then
            return object
        end
    end
    return nil
end

---
function Playboard.getLeader(color)
    return Playboard.getPlayboard(color).leader
end

---
function Playboard.getLeaderName(color)
    local leader = Playboard.findLeaderCard(color)
    return leader and leader.getName() or "?"
end

---
function Playboard.getContent(color)
    local playboard = Playboard.getPlayboard(color)
    assert(playboard, "Unknow player color: " .. tostring(color))
    return playboard.content
end

---
function Playboard.getAgentPark(color)
    return Playboard.getPlayboard(color).agentPark
end

---
function Playboard.getDreadnoughtPark(color)
    return Playboard.getPlayboard(color).dreadnoughtPark
end

---
function Playboard.getSupplyPark(color)
    return Playboard.getPlayboard(color).supplyPark
end

---
function Playboard.getTechPark(color)
    return Playboard.getPlayboard(color).techPark
end

---
function Playboard.getScorePark(color)
    return Playboard.getPlayboard(color).scorePark
end

---
function Playboard:getScore()
    local score = 0
    for _, object in ipairs(self.scorePark.zone.getObjects()) do
        if Utils.isVictoryPointToken(object) then
            score = score + 1
        end
    end
    return score
end

---
function Playboard.grantTechTile(color, techTile)
    Park.putObject(techTile, Playboard.getPlayboard(color).techPark)
end

---
function Playboard.getScoreTokens(color)
    return Park.getObjects(Playboard.getPlayboard(color).scorePark)
end

---
function Playboard.grantScoreToken(color, token)
    Park.putObject(token, Playboard.getPlayboard(color).scorePark)
end

---
function Playboard.grantScoreTokenFromBag(color, tokenBag)
    Park.putObjectFromBag(tokenBag, Playboard.getPlayboard(color).scorePark)
end

---
function Playboard.hasTech(color, techName)
    local techs = Playboard.getPlayboard(color).techPark.zone.getObjects()
    for _, tech in ipairs(techs) do
        if tech.hasTag(techName) then
            return true
        end
    end
    return false
end

---
function Playboard.hasACouncilSeat(color)
    local zone = MainBoard.getHighCouncilSeatPark().zone
    local token = Playboard.getCouncilToken(color)
    return Helper.contains(zone, token)
end

---
function Playboard.takeHighCouncilSeat(color)
    local token = Playboard.getCouncilToken(color)
    if not Playboard.hasACouncilSeat(color) then
        if Park.putObject(token, MainBoard.getHighCouncilSeatPark()) then
            token.interactable = false
            local playboard = Playboard.getPlayboard(color)
            playboard.persuasion:change(2)
            if Playboard.hasTech(color, "restrictedOrdnance") then
                playboard.strength:change(4)
            end
            return true
        end
    end
    return false
end

---
function Playboard.hasSwordmaster(color)
    return Helper.contains(Playboard.getAgentPark(color).zone, Playboard.getSwordmaster(color))
end

---
function Playboard.recruitSwordmaster(color)
    return Park.putObject(Playboard.getSwordmaster(color), Playboard.getAgentPark(color))
end

---
function Playboard.getSwordmaster(color)
    local content = Playboard.getContent(color)
    return content.swordmaster
end

---
function Playboard.getCouncilToken(color)
    local content = Playboard.getContent(color)
    return content.councilToken
end

---
function Playboard.getResource(color, resourceName)
    Utils.assertIsResourceName(resourceName)
    return Playboard.getPlayboard(color)[resourceName]
end

---
function Playboard.payResource(color, resourceName, amount)
    Utils.assertIsResourceName(resourceName)
    local playerResource = Playboard.getContent(color)[resourceName]
    if playerResource.call("collectVal") < amount then
        broadcastToColor(I18N(Helper.toCamelCase("no", resourceName)), color, color)
        return false
    else
        Wait.time(function()
            playerResource.call("decrementVal")
        end, 0.35, amount)
        return true
    end
end

---
function Playboard.gainResource(color, resourceName, amount)
    Utils.assertIsResourceName(resourceName)
    local playerResource = Playboard.getContent(color)[resourceName]
    Wait.time(function()
        playerResource.call("incrementVal")
    end, 0.35, amount)
end

---
function Playboard.giveCard(color, card, isTleilaxuCard)
    local content = Playboard.getContent(color)
    assert(content)

    -- Acquire the card (not smoothly to avoid being grabbed by a player hand zone).
    card.setPosition(content.discardPosition)

    -- Move it on the top of the content deck if possible and wanted.
    if (isTleilaxuCard and TleilaxuResearch.hasReachedOneHelix(color)) or Playboard.hasTech(color, "Spaceport") then
        Player[color].showConfirmDialog(
            I18N("dialogCardAbove"),
            function(_)
                Helper.moveCardFromZone(content.discardZone, content.drawDeckZone.getPosition(), Vector(0, 180, 180), false)
            end)
    end
end

---
function Playboard.giveCardFromZone(color, zone, isTleilaxuCard)
    local content = Playboard.getContent(color)
    assert(content)

    -- Acquire the card (not smoothly to avoid being grabbed by a player hand zone).
    Helper.moveCardFromZone(zone, content.discardZone.getPosition(), nil, false)

    -- Move it on the top of the player deck if possible and wanted.
    if (isTleilaxuCard and TleilaxuResearch.hasReachedOneHelix(color)) or Playboard.hasTech(color, "Spaceport") then
        Player[color].showConfirmDialog(
            I18N("dialogCardAbove"),
            function(_)
                Helper.moveCardFromZone(content.discardZone, content.drawDeckZone.getPosition(), Vector(0, 180, 180), false)
            end)
    end
end

---
function Playboard.getIntrigues(color)
    local intrigues = {}
    for _, card in ipairs(Player[color].getHandObjects()) do
        if card.hasTag('Intrigue') then
            table.insert(intrigues, card)
        end
    end
    return intrigues
end

---
function Playboard.getCards(color)
    local intrigues = {}
    for _, card in ipairs(Player[color].getHandObjects().getObject()) do
        if card.hasTag('Imperium') then
            table.insert(intrigues, card)
        end
    end
    return intrigues
end

---
function Playboard:newSymmetricBoardPosition(x, y, z)
    if self.color == "Red" or self.color == "Blue" then
        return self:newBoardPosition(-x, y, z)
    else
        return self:newBoardPosition(x, y, z)
    end
end

---
function Playboard:newSymmetricBoardRotation(x, y, z)
    if self.color == "Red" or self.color == "Blue" then
        return self:newBoardPosition(x, -y, z)
    else
        return self:newBoardPosition(x, y, z)
    end
end

---
function Playboard:newOffsetedBoardPosition(x, y, z)
    if self.color == "Red" or self.color == "Blue" then
        return self:newBoardPosition(17 + x, y, z)
    else
        return self:newBoardPosition(x, y, z)
    end
end

---
function Playboard:newBoardPosition(x, y, z)
    return Vector(x, y + 0.7, -z)
end

return Playboard
