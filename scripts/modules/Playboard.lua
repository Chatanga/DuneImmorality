local Core = require("utils.Core")
local Helper = require("utils.Helper")
local Park = require("utils.Park")
local I18N = require("utils.I18N")

local Resource = Helper.lazyRequire("Resource")
local TleilaxuResearch = Helper.lazyRequire("TleilaxuResearch")
local TurnControl = Helper.lazyRequire("TurnControl")
local Utils = Helper.lazyRequire("Utils")
local Deck = Helper.lazyRequire("Deck")
local MainBoard = Helper.lazyRequire("MainBoard")
local Hagal = Helper.lazyRequire("Hagal")
local Combat = Helper.lazyRequire("Combat")
local Leader = Helper.lazyRequire("Leader")

local Playboard = {
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
                Core.getHardcodedPositionFromGUID('1a3c82', -26.300024, 1.112601, 18.6999645),
                Core.getHardcodedPositionFromGUID('a8f306', -28.700037, 1.112601, 18.699976)
            },
            agents = {"7751c8", "afa978"},
            agentPositions = {
                Core.getHardcodedPositionFromGUID('7751c8', -17.0, 1.11060047, 20.3),
                Core.getHardcodedPositionFromGUID('afa978', -18.3, 1.11060047, 20.3)
            },
            swordmaster = "ed3490",
            councilToken = "f19a48",
            fourPlayerVictoryToken = "a6c2e0",
            fourPlayerVictoryTokenInitialPosition = Core.getHardcodedPositionFromGUID('a6c2e0', -13.0, 1.31223142, 21.85),
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
            discardPosition = Core.getHardcodedPositionFromGUID('e07493', -14.0, 1.5, 16.5) + Helper.someHeight,
            drawDeckZone = "4f08fc",
            discardZone = "e07493",
            trash = "ea3fe1",
            tleilaxuToken = "2bfc39",
            tleilaxuTokenInitalPosition = Core.getHardcodedPositionFromGUID('2bfc39', 0.5446165, 0.877500236, 22.0549927),
            researchToken = "39e0f3",
            researchTokenInitalPosition = Core.getHardcodedPositionFromGUID('39e0f3', 0.37, 0.88, 18.2351761),
            cargo = "e9096d",
            leaderPos = Core.getHardcodedPositionFromGUID('66cdbb', -19.0, 1.25, 17.5),
            firstPlayerPosition = Core.getHardcodedPositionFromGUID('346e0d', -14.0, 1.5, 19.7) + Vector(0, -0.4, 0),
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
                Core.getHardcodedPositionFromGUID('82789e', -26.3000412, 1.112601, -4.300036),
                Core.getHardcodedPositionFromGUID('60f208', -28.7000523, 1.11260128, -4.300048)
            },
            agents = {"64d013", "106d8b"},
            agentPositions = {
                Core.getHardcodedPositionFromGUID('64d013', -17.0, 1.11060047, -2.70000482),
                Core.getHardcodedPositionFromGUID('106d8b', -18.3, 1.11060047, -2.7)
            },
            swordmaster = "a78ad7",
            councilToken = "f5b14a",
            fourPlayerVictoryToken = "311255",
            fourPlayerVictoryTokenInitialPosition = Core.getHardcodedPositionFromGUID('311255', -13.0, 1.11223137, -1.14999938),
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
            discardPosition = Core.getHardcodedPositionFromGUID('26bf8b', -14.0, 1.5, -6.5) + Helper.someHeight,
            drawDeckZone = "907f66",
            discardZone = "26bf8b",
            trash = "52a539",
            tleilaxuToken = "96607f",
            tleilaxuTokenInitalPosition = Core.getHardcodedPositionFromGUID('96607f', 0.544616759, 0.8800002, 22.75),
            researchToken = "292658",
            researchTokenInitalPosition = Core.getHardcodedPositionFromGUID('292658', 0.37, 0.8775002, 18.9369965),
            cargo = "68e424",
            leaderPos = Core.getHardcodedPositionFromGUID('681774', -19.0, 1.25506675, -5.5),
            firstPlayerPosition = Core.getHardcodedPositionFromGUID('1fc559', -14.0, 1.501278, -3.3) + Vector(0, -0.4, 0),
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
                Core.getHardcodedPositionFromGUID('a15087', 26.2999744, 1.112601, 18.6999722),
                Core.getHardcodedPositionFromGUID('734250', 28.69997, 1.11260116, 18.6999664)
            },
            agents = {"66ae45", "bceb0e"},
            agentPositions = {
                Core.getHardcodedPositionFromGUID('66ae45', 17.0, 1.11060035, 20.2999935),
                Core.getHardcodedPositionFromGUID('bceb0e', 18.3, 1.11060047, 20.3)
            },
            swordmaster = "fb1629",
            councilToken = "a0028d",
            fourPlayerVictoryToken = "66444c",
            fourPlayerVictoryTokenInitialPosition = Core.getHardcodedPositionFromGUID('66444c', 13.0, 1.31223142, 21.85),
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
            discardPosition = Core.getHardcodedPositionFromGUID('2298aa', 24.0, 1.5, 16.5) + Helper.someHeight,
            drawDeckZone = "6d8a2e",
            discardZone = "2298aa",
            trash = "4060b5",
            tleilaxuToken = "63d39f",
            tleilaxuTokenInitalPosition = Core.getHardcodedPositionFromGUID('63d39f', 1.24461639, 0.8800001, 22.05),
            researchToken = "658b17",
            researchTokenInitalPosition = Core.getHardcodedPositionFromGUID('658b17', 0.37, 0.877500236, 20.34),
            cargo = "34281d",
            leaderPos = Core.getHardcodedPositionFromGUID('cf1486', 19.0, 1.18726385, 17.5),
            firstPlayerPosition = Core.getHardcodedPositionFromGUID('59523d', 14.0, 1.45146358, 19.7) + Vector(0, -0.4, 0),
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
                Core.getHardcodedPositionFromGUID('5469fb', 26.2999554, 1.11260116, -4.30001163),
                Core.getHardcodedPositionFromGUID('71a414', 28.6999569, 1.11260128, -4.30003357)
            },
            agents = {"5068c8", "67b476"},
            agentPositions = {
                Core.getHardcodedPositionFromGUID('5068c8', 17.0, 1.11060035, -2.70000386),
                Core.getHardcodedPositionFromGUID('67b476', 18.3, 1.11060047, -2.699999)
            },
            swordmaster = "635c49",
            councilToken = "1be491",
            fourPlayerVictoryToken = "4e8873",
            fourPlayerVictoryTokenInitialPosition = Core.getHardcodedPositionFromGUID('4e8873', 13.0, 1.31223154, -1.14999938),
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
            discardPosition = Core.getHardcodedPositionFromGUID('6bb3b6', 24.0, 1.5, -6.5) + Helper.someHeight,
            drawDeckZone = "e6cfee",
            discardZone = "6bb3b6",
            trash = "7d1e07",
            tleilaxuToken = "d20bcf",
            tleilaxuTokenInitalPosition = Core.getHardcodedPositionFromGUID('d20bcf', 1.24461651, 0.880000234, 22.75),
            researchToken = "8988cf",
            researchTokenInitalPosition = Core.getHardcodedPositionFromGUID('8988cf', 0.37, 0.88, 19.6394081),
            cargo = "8fa76f",
            leaderPos = Core.getHardcodedPositionFromGUID('a677e0', 19.0, 1.17902148, -5.5),
            firstPlayerPosition = Core.getHardcodedPositionFromGUID('e9a44c', 14.0, 1.44851, -3.3) + Vector(0, -0.4, 0),
            startEndTurnButton = "3d1b90"
        }
    },
    playboards = {},
    nextPlayer = nil
}

function Playboard.onLoad(state)
    for color, unresolvedContent in pairs(Playboard.unresolvedContentByColor) do
        Playboard.playboards[color] = Playboard.new(color, unresolvedContent, state)
    end
    Playboard.unresolvedContentByColor = nil
end

---
function Playboard.new(color, unresolvedContent, state)
    --log("Playboard.new(" .. tostring(color) .. ", _, _)")

    local playboard = Helper.newObject(Playboard, {
        color = color,
        player = nil,
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
        playboard.content = Core.resolveGUIDs(true, unresolvedContent)
    else
        log(color .. " player is not alive")
        return nil
    end

    local board = playboard.content.board
    board.interactable = false

    -- FIXME Why this offset? In particular, why the Z component introduces an asymmetry?
    local offset = Vector(0, 0.55, 5.1)
    local centerPosition = board.getPosition() + offset

    for _, resourceName in ipairs({ "spice", "water", "solari", "persuasion", "strength" }) do
        local token = playboard.content[resourceName]
        playboard[resourceName] = Resource.new(token, color, resourceName, 0, state)
    end

    playboard.agentPark = playboard:createAgentPark(unresolvedContent.agentPositions)
    playboard.dreadnoughtPark = playboard:createDreadnoughtPark(unresolvedContent.dreadnoughtPositions)
    playboard.supplyPark = playboard:createSupplyPark(centerPosition)
    playboard.techPark = playboard:createTechPark(centerPosition)
    playboard:initPlayerScore()

    playboard:createButtons()
    playboard:updateState()

    Core.registerEventListener("locale", board.getGUID(), function ()
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
        else
            playboard:shutdown()
        end
    end

    Core.registerEventListener("phaseStart", "Playboard", function (phase, firstPlayer)
        if phase == "leaderSelection" or phase == "round" then
            local playboard = Playboard.playboards[firstPlayer]
            MainBoard.firstPlayerMarker.setPositionSmooth(playboard.content.firstPlayerPosition, false, false)
        end
    end)

    Core.registerEventListener("phaseTurn", "Playboard", function (phase, color)
        local indexedColors = {"Green", "Yellow", "Blue", "Red"}
        for i, otherColor in ipairs(indexedColors) do
            local playboard = Playboard.playboards[otherColor]
            if playboard.opponent then
                local effectIndex = 0 -- black index (no color actually)
                if otherColor == color then
                    effectIndex = i
                    playboard.content.startEndTurnButton.interactable = true
                    if playboard.opponent == "rival" then
                        Hagal.activate(phase, color, playboard)
                    else
                        if phase ~= "leaderSelection" then
                            playboard:createEndOfTurnButton()
                        end
                        Playboard.movePlayerIfNeeded(color)
                    end
                else
                    playboard.content.startEndTurnButton.interactable = false
                    playboard.content.startEndTurnButton.clearButtons()
                end
                local board = playboard.content.board
                board.AssetBundle.playTriggerEffect(effectIndex)
            end
        end

        MusicPlayer.setCurrentAudioclip({
            url = "http://cloud-3.steamusercontent.com/ugc/2027235268872374937/7FE5FD8B14ED882E57E302633A16534C04C18ECE/",
            title = "Next turn"
        })
    end)
end

---
function Playboard.movePlayerIfNeeded(color)
    local otherPlayers = {}
    for _, player in ipairs(Player.getPlayers()) do
        if player.color == color then
            return
        else
            table.insert(otherPlayers, player)
        end
    end
    if #otherPlayers == 1 then
        otherPlayers[1].changeColor(color)
    end
end

---
function Playboard:createEndOfTurnButton()
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
function Playboard:updateState()
    -- Do *not* change self.state reference!
    self.state.alive = self.alive
end

---
function Playboard.getPlayboardByColor(filterOutRival)
    local filteredPlayboards = {}
    for color, playboard in pairs(Playboard.playboards) do
        if playboard.opponent and (not filterOutRival or playboard.opponent ~= "rival") then
            filteredPlayboards[color] = playboard
        end
    end
    return filteredPlayboards
end

---
function Playboard.getBoard(color)
    return Playboard.getPlayer(color).board
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
            allSlots[#allSlots + 1] = slot
            if i < 3 or j < 3 then
                slots[#slots + 1] = slot
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
            slots[#slots + 1] = slot
        end
    end

    return Park.createCommonPark({ "Tech" }, slots, Vector(3, 0.2, 2), Vector(0, 180, 0))
end

---
function Playboard:initPlayerScore()
    self:generatePlayerScoreboardPositions()
    self:createPlayerScoreboardPark()
    self:updatePlayerScore()
end

---
function Playboard:generatePlayerScoreboardPositions()
    local origin = self.content.scoreMarker.getPosition()

    -- Avoid collision between markers by giving a different height to each.
    local h = 1
    for color, _ in pairs(Playboard.getPlayboardByColor()) do
        if color == self.color then
            break
        else
            h = h + 0.5
        end
    end

    self.scorePositions = {}
    for i = 1, 14 do
        self.scorePositions[i] = {
            origin.x,
            2.7 + h,
            origin.z + (i - 2) * 1.165
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
    for i = 0, 17 do
        slots[i + 1] = Vector(
            origin.x + i * 1.092 * direction,
            origin.y,
            origin.z)
    end

    self.scorePark = Park.createCommonPark({ "VictoryPointToken" }, slots, Vector(1, 0.2, 1), Vector(0, 180, 0))
end

---
function Playboard:updatePlayerScore()
    local zoneObjects = self.scorePark.zone.getObjects()
    local newScore = 0
    for _, object in ipairs(zoneObjects) do
        if object.getDescription() == "VP" then
            newScore = newScore + 1
        end
    end

    local vpIndex = math.min(14, newScore + 1)
    local scoreMarker = self.content.scoreMarker
    scoreMarker.setPositionSmooth(self.scorePositions[vpIndex])
    scoreMarker.setRotationSmooth({0, 0, 0}, false, false)

    if newScore ~= self.score then
        self.score = newScore
        local setup = getObjectFromGUID("4a3e76")
        setup.call("updateScores")
    end
end

---
function Playboard.onObjectEnterScriptingZone(zone, enterObject)
    if Playboard.alive then
        if zone.guid == Playboard.scorePark.zone.guid then
            local description = enterObject.getDescription()
            if description == "VP" then
                Playboard:updatePlayerScore()
            end
        end
    end
end

---
function Playboard.onObjectLeaveScriptingZone(zone, enterObject)
    if Playboard.alive then
        if zone.guid == Playboard.scorePark.zone.guid then
            local description = enterObject.getDescription()
            if description == "VP" then
                Playboard:updatePlayerScore()
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
    local player = self.content

    local toBeRemoved = {}

    if base then
        Helper.addAll(toBeRemoved, {
            player.swordmaster,
            player.councilToken,
            player.scoreMarker,
            player.flagBag,
            player.forceMarker,
            player.startEndTurnButton
        })
        Helper.addAll(toBeRemoved, player.agents)
        Helper.addAll(toBeRemoved, player.troops)
    end

    if ix then
        Helper.addAll(toBeRemoved, player.dreadnoughts)
        table.insert(toBeRemoved, player.flagBag)
        table.insert(toBeRemoved, player.cargo)
        -- TODO Add atomics.
    end

    if immortality then
        table.insert(toBeRemoved, player.tleilaxuToken)
        table.insert(toBeRemoved, player.researchToken)
    end

    for _, object in ipairs(toBeRemoved) do
        if toBeRemoved then
            object.interactable = true
            object.destruct()
        end
    end
end

---
function Playboard.onPlayerTurn(player, previousPlayer)
    if true then
        log("=== SKIP ===")
        return
    end
    --[[
        In some occasions, this method is called twice in the same frame. If so,
        only the first call to playTriggerEffect will be taken into account.
        It forces us to memorize the value and defer the call to only consider
        the last value received.
    ]]--
    Playboard.nextPlayer = player and player.color
    Wait.frames(function ()
        local indexedColors = {"Green", "Yellow", "Blue", "Red"}
        for i, color in ipairs(indexedColors) do
            local effectIndex = 0 -- black index (no color actually)
            if Playboard.nextPlayer == color then
                effectIndex = i
            end
            local board = Playboard.playboards[color].content.board
            board.AssetBundle.playTriggerEffect(effectIndex)
        end
        Playboard.nextPlayer = nil
    end)
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
    return Helper.wrapCallback({"Playboard", name, self.color}, function (_, color, _)
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
    return Helper.wrapCallback({"Playboard", name, self.color}, function (_, color, _)
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
    return Playboard.playboards[color].revealed
end

---
function Playboard:tryRevealHandEarly()
    if self.revealed then
        return
    end

    local origin = Playboard.playboards[self.color]:newSymmetricBoardPosition(-8, 0, -4.5)

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
    local i = 0
    for _, card in ipairs(Player[self.color].getHandObjects()) do
        if card.hasTag('Imperium') then
            local n = i
            Wait.time(function()
                card.setPosition(self:getRevealCardPosition(n))
            end, n * 0.25)
            i = i + 1
        end
    end

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
    local playboard = Playboard.playboards[color]
    if playboard.opponent == "rival" then
        return playboard:stillHavePlayableAgents()
    else
        return not playboard.revealed
    end
end

---
function Playboard.isInCombat(color)
    return not (Combat.getGarrisonPark(color).isEmpty() and Combat.getDreadnoughtPark(color).isEmpty())
end

---
function Playboard.isAgent(object, color)
    local name = object.getName()
    if name == color .. " Agent" or name == color .. " Swordmaster" then
        return true
    elseif object.getName() == "Mentat" then
        return object.getColorTint() == Playboard.getPlayer(color).swordmaster.getColorTint()
    end
end

---
function Playboard:tryToDrawCards(count, message)
    local player = self.content
    local deck = Helper.getDeckOrCard(player.drawDeckZone)
    local discard = Helper.getDeckOrCard(player.discardZone)

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
    local player = self.content
    local discard = Helper.getDeckOrCard(player.discardZone)
    if discard then
        local continuation = Helper.createContinuation()

        discard.setRotationSmooth({0, 180, 180}, false, false)
        discard.setPositionSmooth(Helper.getLandingPosition(player.drawDeckZone), false, true)

        Wait.time(function() -- Once moved.
            local replenishedDeckOrCard = Helper.getDeckOrCard(player.drawDeckZone)
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
        scale = {3, 3, 3},
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
            scale = {3, 3, 3},
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
            scale = {3, 3, 3},
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
            scale = {3, 3, 3},
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
    return Playboard.getPlayer(color) ~= nil
end

---
function Playboard.isRival(color)
    local playerboard = Playboard.playboards[color]
    return playerboard.opponent == "rival"
end

---
function Playboard.setLeader(color, leaderCard)
    local playboard = Playboard.playboards[color]
    if playboard.opponent == "rival" then
        if Hagal.getRivalCount() == 2 and not Hagal.isLeaderCompatible(leaderCard) then
            log("Not a leader compatible with a rival: " .. leaderCard.getDescription())
            return false
        end
    end
    playboard.leader = Leader.new(leaderCard)
    local position = playboard.content.leaderZone.getPosition()
    leaderCard.setPosition(position)
    return true
end

---
function Playboard.findLeader(color)
    local leaderZone = Playboard.getPlayer(color).leaderZone
    for _, object in ipairs(leaderZone.getObjects()) do
        if object.hasTag("Leader") or object.hasTag("Hagal") then
            return object
        end
    end
    return nil
end

---
function Playboard.getLeaderName(color)
    local leader = Playboard.findLeader(color)
    return leader and leader.getName() or "?"
end

---
function Playboard.is(color, leaderName)
    local leader = Playboard.findLeader(color)
    if leader then
        return leader.getDescription() == leaderName
    else
        return false
    end
end

---
function Playboard.getPlayer(color)
    local playboard = Playboard.playboards[color]
    assert(playboard, "Unknow player color: " .. tostring(color))
    return playboard.content
end

---
function Playboard.getAgentPark(color)
    return Playboard.playboards[color].agentPark
end

---
function Playboard.getDreadnoughtPark(color)
    return Playboard.playboards[color].dreadnoughtPark
end

---
function Playboard.getSupplyPark(color)
    return Playboard.playboards[color].supplyPark
end

---
function Playboard.getTechPark(color)
    return Playboard.playboards[color].techPark
end

---
function Playboard.getScorePark(color)
    return Playboard.playboards[color].scorePark
end

---
function Playboard.getScore(color)
    return Playboard.playboards[color].score
end

---
function Playboard.grantTechTile(color, techTile)
    Park.putObject(techTile, Playboard.playboards[color].techPark)
end

---
function Playboard.getScoreTokens(color)
    return Park.getObjects(Playboard.playboards[color].scorePark)
end

---
function Playboard.grantScoreToken(color, token)
    Park.putObject(token, Playboard.playboards[color].scorePark)
end

---
function Playboard.grantScoreTokenFromBag(color, tokenBag)
    Park.putObjectFromBag(tokenBag, Playboard.playboards[color].scorePark)
end

---
function Playboard.hasTech(color, techName)
    local techs = Playboard.playboards[color].techPark.zone.getObjects()
    for _, tech in ipairs(techs) do
        if tech.hasTag(techName) then
            return true
        end
    end
    return false
end

---
function Playboard.hasACouncilSeat(color)
    for _, object in ipairs(Constants.structure.main.councilZone.getObjects()) do
        if object.getName() == color .. " Councilor" then
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
    local player = Playboard.getPlayer(color)
    return player.swordmaster
end

---
function Playboard.getCouncilToken(color)
    local player = Playboard.getPlayer(color)
    return player.councilToken
end

---
function Playboard.getResource(color, resourceName)
    return Playboard.playboards[color][resourceName]
end

---
function Playboard.payResource(color, resourceName, amount)
    local playerResource = Playboard.getPlayer(color)[resourceName]
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
    local playerResource = Playboard.getPlayer(color)[resourceName]
    Wait.time(function()
        playerResource.call("incrementVal")
    end, 0.35, amount)
end

---
function Playboard.giveCard(color, card, isTleilaxuCard)
    local player = Playboard.getPlayer(color)
    assert(player)

    -- Acquire the card (not smoothly to avoid being grabbed by a player hand zone).
    card.setPosition(player.discardPosition)

    -- Move it on the top of the player deck if possible and wanted.
    if (isTleilaxuCard and TleilaxuResearch.hasReachedOneHelix(color)) or Playboard.hasTech(color, "Spaceport") then
        Player[color].showConfirmDialog(
            I18N("dialogCardAbove"),
            function(_)
                Helper.moveCardFromZone(player.discardZone, player.drawDeckZone.getPosition(), Vector(0, 180, 180), false)
            end)
    end
end

---
function Playboard.giveCardFromZone(color, zone, isTleilaxuCard)
    local player = Playboard.getPlayer(color)
    assert(player)

    -- Acquire the card (not smoothly to avoid being grabbed by a player hand zone).
    Helper.moveCardFromZone(zone, player.discardZone.getPosition(), nil, false)

    -- Move it on the top of the player deck if possible and wanted.
    if (isTleilaxuCard and TleilaxuResearch.hasReachedOneHelix(color)) or Playboard.hasTech(color, "Spaceport") then
        Player[color].showConfirmDialog(
            I18N("dialogCardAbove"),
            function(_)
                Helper.moveCardFromZone(player.discardZone, player.drawDeckZone.getPosition(), Vector(0, 180, 180), false)
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
