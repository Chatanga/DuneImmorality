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
local ImperiumCard = Module.lazyRequire("ImperiumCard")
local ConflictCard = Module.lazyRequire("ConflictCard")
local Action = Module.lazyRequire("Action")
local Rival = Module.lazyRequire("Rival")
local SardaukarCommander = Module.lazyRequire("SardaukarCommander")
local SardaukarCommanderSkillCard = Module.lazyRequire("SardaukarCommanderSkillCard")
local TechCard = Module.lazyRequire("TechCard")
local Board = Module.lazyRequire("Board")

---@class PlayBoard
---@field playBoards table<PlayerColor, PlayBoard>
---@field OFFSET number
---@field ALL_COLORS PlayerColor[]
---@field ALL_RESOURCE_NAMES ResourceName[]
---@field opponent string
---@field leader Leader
---@field leaderCard DeckOrCard
---@field lastPhase string
---@field revealed boolean
---@field content table
---@field color PlayerColor
---@field tq table
---@field alreadyPlayedCards Card[]
---@field agentCardPark Park
---@field revealCardPark Park
---@field techPark Park
---@field scorePark Park
---@field sardaukarCommanderPark Park
---@field agentPark Park
---@field sardaukarCommanderSkillPark Park
---@field dreadnoughtPark Park
---@field supplyPark Park
---@field instructionTextAnchor Object
---@field persuasion Resource
---@field strength Resource
local PlayBoard = Helper.createClass(nil, {
    OFFSET = 17,
    ALL_COLORS = { "Green", "Yellow", "Blue", "Red" },
    ALL_RESOURCE_NAMES = { "spice", "water", "solari", "strength", "persuasion" },
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
            dreadnoughts = {"1a3c82", "a8f306"},
            agents = {"7751c8", "afa978"},
            swordmaster = "ed3490",
            councilToken = "f19a48",
            fourPlayerVictoryToken = "a6c2e0",
            scoreMarker = "175a0a",
            scoreMarkerInitialPosition = Helper.getHardcodedPositionFromGUID('175a0a', 10.4, 2.22279859, -14.0),
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
            trash = "ea3fe1",
            tleilaxToken = "2bfc39",
            tleilaxTokenInitalPosition = Helper.getHardcodedPositionFromGUID('2bfc39', 0.5446171, 1.8775003, 22.0549927),
            researchToken = "39e0f3",
            researchTokenInitalPosition = Helper.getHardcodedPositionFromGUID('39e0f3', 0.369999915, 1.88000035, 18.2351761),
            freighter = "e672c6",
            firstPlayerMarkerZone = "346e0d",
            firstPlayerInitialPosition = Helper.getHardcodedPositionFromGUID('346e0d', -14.0, 2.5, 19.7) + Vector(0, -0.4, 0),
            endTurnButton = "895594",
            atomicsToken = "d5ff47",
            sardaukarMarker = "b8337b",
        },
        Blue = {
            board = "77ca63",
            colorband = "46abc5",
            spice = "9cc286",
            solari = "fa5236",
            water = "0afaeb",
            persuasion = "8cb9be",
            strength = "aa3bb9",
            dreadnoughts = {"82789e", "60f208"},
            agents = {"64d013", "106d8b"},
            swordmaster = "a78ad7",
            councilToken = "f5b14a",
            fourPlayerVictoryToken = "311255",
            scoreMarker = "7fa9a7",
            scoreMarkerInitialPosition = Helper.getHardcodedPositionFromGUID('7fa9a7', 10.4, 2.42279887, -14.0),
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
            trash = "52a539",
            tleilaxToken = "96607f",
            tleilaxTokenInitalPosition = Helper.getHardcodedPositionFromGUID('96607f', 0.544616759, 1.88000023, 22.75),
            researchToken = "292658",
            researchTokenInitalPosition = Helper.getHardcodedPositionFromGUID('292658', 0.369999975, 1.87750018, 18.9369965),
            freighter = "e4a2dd",
            firstPlayerMarkerZone = "1fc559",
            firstPlayerInitialPosition = Helper.getHardcodedPositionFromGUID('1fc559', -14.0, 2.501278, -3.3) + Vector(0, -0.4, 0),
            endTurnButton = "9eeccd",
            atomicsToken = "700023",
            sardaukarMarker = "20842d",
        },
        Green = {
            board = "0bbae1",
            colorband = "c1aea4",
            spice = "22478f",
            solari = "e597dc",
            water = "fa9522",
            persuasion = "ac97c5",
            strength = "d880f7",
            dreadnoughts = {"a15087", "734250"},
            agents = {"66ae45", "bceb0e"},
            swordmaster = "fb1629",
            councilToken = "a0028d",
            fourPlayerVictoryToken = "66444c",
            scoreMarker = "7bae32",
            scoreMarkerInitialPosition = Helper.getHardcodedPositionFromGUID('7bae32', 10.4, 2.022798, -14.0),
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
            trash = "4060b5",
            tleilaxToken = "63d39f",
            tleilaxTokenInitalPosition = Helper.getHardcodedPositionFromGUID('63d39f', 1.24461627, 1.88000011, 22.05),
            researchToken = "658b17",
            researchTokenInitalPosition = Helper.getHardcodedPositionFromGUID('658b17', 0.369999349, 1.8775003, 20.34),
            freighter = "e89b34",
            firstPlayerMarkerZone = "59523d",
            firstPlayerInitialPosition = Helper.getHardcodedPositionFromGUID('59523d', 14.0, 2.45146346, 19.7) + Vector(0, -0.4, 0),
            endTurnButton = "96aa58",
            atomicsToken = "0a22ec",
            sardaukarMarker = "dd6996",
        },
        Yellow = {
            board = "fdd5f9",
            colorband = "8523f2",
            spice = "78fb8a",
            solari = "c5c4ef",
            water = "f217d0",
            persuasion = "aa79bf",
            strength = "6f007c",
            dreadnoughts = {"5469fb", "71a414"},
            agents = {"5068c8", "67b476"},
            swordmaster = "635c49",
            councilToken = "1be491",
            fourPlayerVictoryToken = "4e8873",
            scoreMarker = "f9ac91",
            scoreMarkerInitialPosition = Helper.getHardcodedPositionFromGUID('f9ac91', 10.4, 1.82279789, -14.0),
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
            trash = "7d1e07",
            tleilaxToken = "d20bcf",
            tleilaxTokenInitalPosition = Helper.getHardcodedPositionFromGUID('d20bcf', 1.24461651, 1.88000023, 22.75),
            researchToken = "8988cf",
            researchTokenInitalPosition = Helper.getHardcodedPositionFromGUID('8988cf', 0.370001018, 1.8775003, 19.6394081),
            freighter = "a7d445",
            firstPlayerMarkerZone = "e9a44c",
            firstPlayerInitialPosition = Helper.getHardcodedPositionFromGUID('e9a44c', 14.0, 2.44851, -3.3) + Vector(0, -0.4, 0),
            endTurnButton = "3d1b90",
            atomicsToken = "7e10a9",
            sardaukarMarker = "25f3f2",
        }
    },
    playBoards = {}
})

function PlayBoard.rebuild()
    for _, color in ipairs(PlayBoard.ALL_COLORS) do
        local content = Helper.resolveGUIDs(true, PlayBoard.unresolvedContentByColor[color])

        local pseudoPlayboard = Helper.createClassInstance(PlayBoard, {
            color = color,
            content = content,
        })

        --[[
        Some wording:
        - An 'offset' is relative to the board center in the word space (not in the board local space).
        - A 'position' is an absolute position.
        - A 'localPosition' is an position relative to the board center in the board space (rotated by 180°).
        ]]

        local extractSlotOffsets = function (park)
            return Helper.mapValues(park.slots, function (p)
                return p - content.board.getPosition()
            end)
        end

        local extractCenterOffset = function (zone)
            local center = zone.getPosition() - content.board.getPosition()
            zone.destruct()
            return center
        end

        local colorSwitch = function (left, right)
            if PlayBoard.isLeft(color) then
                return left
            else
                return right
            end
        end

        local symmetric = function (x, y, z)
            return colorSwitch(Vector(-x, y, z), Vector(x, y, z))
        end

        local offseted = function (x, y, z)
            return colorSwitch(Vector(PlayBoard.OFFSET + x, y, z), Vector(x, y, z))
        end

        local agentSlots = extractSlotOffsets(pseudoPlayboard:_createAgentPark())
        local dreadnoughtSlots = extractSlotOffsets(pseudoPlayboard:_createDreadnoughtPark())
        local troopSlots = extractSlotOffsets(pseudoPlayboard:_createSupplyPark())
        local techSlots = extractSlotOffsets(pseudoPlayboard:_createTechPark())
        local sardaukarCommanderSkillSlots = extractSlotOffsets(pseudoPlayboard:_createSardaukarCommanderSkillPark())
        local agentCardSlots = extractSlotOffsets(pseudoPlayboard:_createAgentCardPark())
        local playerScoreSlots = extractSlotOffsets(pseudoPlayboard:_createPlayerScorePark())

        local drawDeck = extractCenterOffset(pseudoPlayboard:_createDrawDeckZone())
        local leader = extractCenterOffset(pseudoPlayboard:_createLeaderZone())
        local discard = extractCenterOffset(pseudoPlayboard:_createDiscardZone())

        -- 'objectOffsets[something]' contains the offset for the item(s) 'PlayBoard.unresolvedContentByColor[color][something]'
        local objectOffsets = {
            board = Vector(0, 0, 0),
            colorband = Vector(0, 0, 0),
            fourPlayerVictoryToken = playerScoreSlots[1],
            spice = offseted(-10.4, 0, 3),
            water = offseted(-8.4, 0, 2.5),
            solari = offseted(-6.4, 0, 3),
            agents = agentSlots,
            persuasion = symmetric(-13.5, 0, -9),
            strength = symmetric(-10.5, 0, -9),
            dreadnoughts = dreadnoughtSlots,
            councilToken = symmetric(0, 0, 8.5),
            controlMarkerBag = symmetric(0, 0, 6.1),
            troops = troopSlots,
            sardaukarMarker = symmetric(0, 0, 2.5),
            trash = symmetric(12.1, 0, 5),
            endTurnButton = symmetric(-3.3, 0, 8.25),
            atomicsToken = symmetric(12.1, 0, 1.9),
        }

        local boardPositions = {
            Green = Vector(27.5, 1.45, 11.5),
            Yellow = Vector(27.5, 1.45, -11.5),
            Red = Vector(-27.5, 1.45, 11.5),
            Blue = Vector(-27.5, 1.45, -11.5),
        }
        local boardPosition = boardPositions[color]
        local offset = boardPosition - content.board.getPosition()
        assert(offset:magnitude() < 0.1)

        local relocate = function (object, localOffset)
            local newPosition = boardPosition + localOffset
            newPosition.y = object.getPosition().y
            object.setPosition(newPosition)
            object.setLock(true)
        end

        for name, localOffset in pairs(objectOffsets) do
            local object = content[name]
            if object then
                if type(object) == "table" then
                    assert(type(localOffset) == "table", name)
                    for i, item in ipairs(object) do
                        relocate(item, localOffset[i])
                        if item.hasTag("troop") then
                            item.setRotation(Vector(0, -45, 0))
                        end
                    end
                else
                    relocate(object, localOffset)
                end
            end
        end

        local handTransform = Player[color].getHandTransform()
        handTransform.position = handTransform.position + offset
        Player[color].setHandTransform(handTransform)

        local decalHeight = 0.68 -- 0.19 with Uprising?!

        local positionToLocalDecal = function (p)
            local localPosition = content.board.positionToLocal(p)
            localPosition:setAt('y', decalHeight)
            return localPosition
        end

        local offsetToLocalDecal = function (p)
            local localPosition = content.board.positionToLocal(p + content.board.getPosition())
            localPosition:setAt('y', decalHeight)
            return localPosition
        end

        -- Decal coordinates are in the board space (rotated by 180°).
        local decals = {
            {
                name = "Scoreboard",
                url = colorSwitch(
                    "https://steamusercontent-a.akamaihd.net/ugc/2502404390141335512/BD4C6DB374A73A3A1586E84DD94DD2459EB51782/",
                    "https://steamusercontent-a.akamaihd.net/ugc/2502404390141335805/00AEA6A9B03D893B1BF82EFF392448FD52B8C70E/"),
                position = symmetric(4.5, decalHeight, -10.35),
                rotation = { 90, 180, 0 },
                scale = { 22, 1.1, 1 },
            },
            {
                name = "First Player Token Slot",
                url = "https://steamusercontent-a.akamaihd.net/ugc/2502404390141336231/B2176FBF3640DC02A6840C8E0FB162057724DE41/",
                position = positionToLocalDecal(content.firstPlayerInitialPosition),
                rotation = { 90, 180, 0 },
                scale = { 2, 2, 1 },
            },
            {
                name = "Draw Deck Slot",
                url = "https://steamusercontent-a.akamaihd.net/ugc/2502404390141335305/9973F87497827C194B979D7410D0DD47E46305FA/",
                position = offsetToLocalDecal(drawDeck),
                rotation = { 90, 180, 0 },
                scale = { 2.4, 3.4, 1 },
            },
            {
                name = "Discard Slot",
                url = "https://steamusercontent-a.akamaihd.net/ugc/2502404390141335224/76205DFA6ECBC5F9C6B38BE95F42E6B5468B5999/",
                position = offsetToLocalDecal(discard),
                rotation = { 90, 180, 0 },
                scale = { 2.4, 3.4, 1 },
            },
            {
                name = "Leader Slot",
                url = "https://steamusercontent-a.akamaihd.net/ugc/2502404390141335398/7882B2E68FF7767C67EE5C63C9D7CF17B405A5C3/",
                position = offsetToLocalDecal(leader),
                rotation = { 90, 180, 0 },
                scale = { 5, 3.5, 1 },
            },
        }

        for _, slot in ipairs(agentSlots) do
            table.insert(decals, {
                name = "Generic Slot",
                url = "https://steamusercontent-a.akamaihd.net/ugc/2502404390141334991/8C42D07B62ACE707EF3C206E9DFEA483821ECFD8/",
                position = offsetToLocalDecal(slot),
                rotation = { 90, 0, 0 },
                scale = { 0.5, 0.5, 1 },
            })
        end

        for _, slot in ipairs(techSlots) do
            table.insert(decals, {
                name = "Tech Tile Slot",
                url = "https://steamusercontent-a.akamaihd.net/ugc/2502404390141336300/6A948CDC20774D0D4E5EA0EFF3E0D2C23F30FCC1/",
                position = offsetToLocalDecal(slot),
                rotation = { 90, 0, 0 },
                scale = { 2.6, 1.8, 1 },
            })
        end

        if true then
            for _, slot in ipairs(sardaukarCommanderSkillSlots) do
                table.insert(decals, {
                    name = "Generic Slot",
                    url = "https://steamusercontent-a.akamaihd.net/ugc/2502404390141334991/8C42D07B62ACE707EF3C206E9DFEA483821ECFD8/",
                    position = offsetToLocalDecal(slot),
                    rotation = { 90, 0, 0 },
                    scale = { 0.45, 0.45, 1 },
                })
            end
        end

        if content.dreadnoughts then
            for _, slot in ipairs(dreadnoughtSlots) do
                table.insert(decals, {
                    name = "Generic Slot",
                    url = "https://steamusercontent-a.akamaihd.net/ugc/2502404390141334991/8C42D07B62ACE707EF3C206E9DFEA483821ECFD8/",
                    position = offsetToLocalDecal(slot),
                    rotation = { 90, 0, 0 },
                    scale = { 0.5, 0.5, 1 },
                })
            end
        end

        for _, slot in ipairs(agentCardSlots) do
            table.insert(decals, {
                name = "Intrigium",
                url = "https://steamusercontent-a.akamaihd.net/ugc/2120690798716490121/DB0A29253195530F3A39D5AC737922A5B2338795/",
                position = offsetToLocalDecal(slot),
                rotation = { 90, 180, 0 },
                scale = { 2, 2, 1 },
            })
        end

        content.board.setDecals(decals)
    end

    -- Some cleaning of transient objects created by parks and zones.
    Helper.onceFramesPassed(1).doAfter(function ()
        --Helper.destroyTransientObjects()
    end)
end

---@param state table
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

    if state.settings and state.PlayBoard then
        PlayBoard._transientSetUp(state.settings)
    end
end

---@param state table
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
            initialPositions = {
                firstPlayerInitialPosition = playBoard.content.firstPlayerInitialPosition,
            },
        }
    end)
end

---@param operation "symmetric"|"offseted"
---@param position Vector
---@param scale Vector
---@return Zone
function PlayBoard:createTransientZone(operation, position, scale)
    local zone = spawnObject({
        type = 'ScriptingTrigger',
        position = self:_generateAbsolutePosition(operation, position),
        scale = { scale.x, scale.y, scale.z },
    })
    Helper.markAsTransient(zone)
    return zone
end

---@return Zone
function PlayBoard:_createDrawDeckZone()
    return self:createTransientZone("offseted", Vector(-13.5, 0.4, 4.75), Vector(2.3, 1, 3.3))
end

---@return Zone
function PlayBoard:_createLeaderZone()
    return self:createTransientZone("offseted", Vector(-8.5, 0.4, 6), Vector(5, 1, 3.5))
end

---@return Zone
function PlayBoard:_createDiscardZone()
    return self:createTransientZone("offseted", Vector(-3.5, 0.4, 4.75), Vector(2.3, 1, 3.3))
end

---@param color PlayerColor
---@param unresolvedContent table
---@param state table
---@param subState? table
---@return PlayBoard
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

    playBoard.content.drawDeckZone = playBoard:_createDrawDeckZone()
    playBoard.content.leaderZone = playBoard:_createLeaderZone()
    playBoard.content.discardZone = playBoard:_createDiscardZone()

    if subState then
        playBoard.opponent = subState.opponent
        playBoard.lastPhase = subState.lastPhase
        playBoard.revealed = subState.revealed

        -- Zones can't be queried right now.
        Helper.onceFramesPassed(1).doAfter(function ()
            playBoard.leaderCard = Helper.getDeckOrCard(playBoard.content.leaderZone)
            if playBoard.leaderCard then
                assert(subState.leader)
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

        playBoard.content.firstPlayerInitialPosition = Helper.toVector(subState.initialPositions.firstPlayerInitialPosition)
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

    local snapZones = {
        firstPlayerMarkerZone = { "FirstPlayerMarker" },
        drawDeckZone = { "Imperium" },
        leaderZone = { "Leader", "RivalLeader" },
        discardZone = { "Imperium" },
    }
    local snapPoints = {}
    for name, tags in pairs(snapZones) do
        local snapPoint = Helper.createRelativeSnapPointFromZone(playBoard.content.board, playBoard.content[name], true, tags)
        table.insert(snapPoints, snapPoint)
    end

    playBoard.content.board.setSnapPoints(snapPoints)

    for _, resourceName in ipairs(PlayBoard.ALL_RESOURCE_NAMES) do
        local token = playBoard.content[resourceName]
        if token then
            local value = subState and subState.resources[resourceName] or 0
            playBoard[resourceName] = Resource.new(token, color, resourceName, value)
        end
    end

    playBoard.agentCardPark = playBoard:_createAgentCardPark()
    playBoard.revealCardPark = playBoard:_createRevealCardPark()
    playBoard.agentPark = playBoard:_createAgentPark()
    if true then
        playBoard.dreadnoughtPark = playBoard:_createDreadnoughtPark()
        playBoard.supplyPark = playBoard:_createSupplyPark()
        playBoard.sardaukarCommanderSkillPark = playBoard:_createSardaukarCommanderSkillPark(3)
        playBoard.sardaukarCommanderPark = playBoard:_createSardaukarCommanderPark(3)
    end
    playBoard:_generatePlayerScoreTrackPositions()
    playBoard.scorePark = playBoard:_createPlayerScorePark()
    playBoard.techPark = playBoard:_createTechPark(3)

    Helper.registerEventListener("locale", function ()
        playBoard:_createButtons()
    end)

    return playBoard
end

---@param settings Settings
---@param activeOpponents table<PlayerColor, ActiveOpponent>
---@return Continuation?
function PlayBoard.setUp(settings, activeOpponents)
    local sequentialActions = {}

    for color, playBoard in pairs(PlayBoard.playBoards) do
        playBoard:_cleanUp(false, not settings.ix, not settings.immortality, not settings.bloodlines)
        if activeOpponents[color] then
            if activeOpponents[color] == "rival" then
                playBoard.opponent = "rival"
                if Hagal.getRivalCount() == 1 then
                    playBoard.content.scoreMarker.destruct()
                    playBoard.content.scoreMarker = nil
                end
                playBoard.content.sardaukarMarker.destruct()
                playBoard.content.sardaukarMarker = nil
            else
                playBoard.opponent = "human"
                Deck.generateStarterDeck(playBoard.content.drawDeckZone, settings).doAfter(Helper.shuffleDeck)
                Deck.generateStarterDiscard(playBoard.content.discardZone, settings)
            end

            if true then
                if settings.numberOfPlayers < 4 or settings.goTo11 then
                    playBoard.content.fourPlayerVictoryToken.destruct()
                    playBoard.content.fourPlayerVictoryToken = nil
                end
            end

            playBoard:_createButtons()

            Helper.onceFramesPassed(1).doAfter(function ()
                playBoard:_updatePlayerScore()
            end)
        else
            playBoard:_tearDown()
        end
    end

    -- The score track for VP tokens is fragile and doesn't handle too well the
    -- token collisions happening when multiples scores are updated at the same
    -- time.
    Helper.repeatChainedAction(#sequentialActions, function ()
        sequentialActions[1]()
        table.remove(sequentialActions, 1)
        return Helper.onceTimeElapsed(1)
    end)

    PlayBoard._transientSetUp(settings)

    if PlayBoard.tq then
        local continuation = Helper.createContinuation("PlayBoard.setUp")
        PlayBoard.tq.submit(continuation.run)
        return continuation
    else
        return nil
    end
end

---@param settings Settings
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
            for color, playBoard in pairs(PlayBoard._getPlayBoards(true)) do
                local cardAmount = PlayBoard.hasTech(color, "holtzmanEngine") and 6 or 5
                playBoard:drawCards(cardAmount)
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
                playBoard.leader.doSetUp(color, settings)
                playBoard.leader.prepare(color, settings)
            end
        elseif phase == "endgame" then
            MainBoard.getFirstPlayerMarker().destruct()
        end

        for _, playBoard in pairs(PlayBoard._getPlayBoards(true)) do
            -- When informal, the combat phase ends automatically, leaving the players in limbo until they press the "reclaim rewards" button.
            if false and phase == "combat" and not Combat.isFormalCombatPhaseEnabled() then
                playBoard:_updateInstructionLabel(I18N("combatInstruction"))
            else
                playBoard:_updateInstructionLabel(nil)
            end
        end

        PlayBoard._setActivePlayer(nil, nil)
    end)

    Helper.registerEventListener("playerTurn", function (phase, color, refreshing)
        local playBoard = PlayBoard.getPlayBoard(color)

        if PlayBoard.isHuman(color) and not refreshing then
            -- FIXME To naive, won't work for multiple agents in a single turn (e.g. Weirding Way).
            playBoard.alreadyPlayedCards = Helper.filter(Park.getObjects(playBoard.agentCardPark), function (card)
                return (Types.isImperiumCard(card) or Types.isIntrigueCard(card)) and not card.is_face_down
            end)
        end

        for otherColor, otherPlayBoard in pairs(PlayBoard._getPlayBoards(true)) do
            local instruction = (playBoard.leader or Action).instruct(phase, color == otherColor) or "-"
            otherPlayBoard:_updateInstructionLabel(instruction)
        end

        PlayBoard._setActivePlayer(phase, color, refreshing)
    end)

    Helper.registerEventListener("combatUpdate", function (forces)
        PlayBoard.combatPassCountdown = Helper.count(forces, function (color, v)
            return not PlayBoard.isRival(color) and v > 0
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

    for color, playBoard in pairs(PlayBoard._getPlayBoards(true)) do
        if settings.bloodlines then
            SardaukarCommander.createSardaukarCommanderRecruitmentButton(playBoard.content.sardaukarMarker, false, PlayBoard.withLeader(function (leader, playerColor, _)
                if playerColor == color then
                    leader.recruitSardaukarCommander(color)
                else
                    Dialog.broadcastToColor(I18N('noTouch'), color, "Purple")
                end
            end))
        end

        local instructionTextAnchorPosition = playBoard.content.board.getPosition() + playBoard:_newSymmetricBoardPosition(12, -0.5, -8)
        Helper.createTransientAnchor("instructionTextAnchor", instructionTextAnchorPosition).doAfter(function (anchor)
            playBoard.instructionTextAnchor = anchor
        end)
    end
end

---@param instruction? string
function PlayBoard:_updateInstructionLabel(instruction)
    local position = self.instructionTextAnchor.getPosition()
    position:setAt('y', Board.onPlayBoard(0.1))
    if self.instructionTextAnchor then
        Helper.clearButtons(self.instructionTextAnchor)
        if instruction then
            Helper.createAbsoluteButtonWithRoundness(self.instructionTextAnchor, 1, {
                click_function = Helper.registerGlobalCallback(),
                label = instruction,
                position = position,
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

function PlayBoard.setGeneralCombatInstruction()
    for _, playBoard in pairs(PlayBoard._getPlayBoards(true)) do
        playBoard:_updateInstructionLabel(I18N("combatInstruction"))
    end
end

function PlayBoard:_recall()
    self.revealed = false

    -- Wait for the removal of the agents.
    Helper.onceTimeElapsed(1).doAfter(function ()
        self.persuasion:set(0)
        self.strength:set(0)
        self:_refreshStaticContributions(true)
    end)

    self:_createButtons()

    local stackHeight = 0
    local nextDiscardPosition = function ()
        stackHeight = stackHeight + 1
        return self.content.discardZone.getPosition() + Vector(0, stackHeight * 0.5, 0)
    end

    -- Send all played cards to the discard, save those which shouldn't.
    Helper.forEach(Helper.filter(Park.getObjects(self.agentCardPark), Types.isImperiumCard), function (_, card)
        ---@cast card Card
        local cardName = Helper.getID(card)
        if cardName == "foldspace" then
            Reserve.recycleFoldspaceCard(card)
        elseif Helper.isElementOf(cardName, {"seekAllies", "powerPlay", "treachery"}) then
            self:trash(card)
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
    ---@cast playedIntrigueCards Card[]
    Helper.forEach(playedIntrigueCards, function (i, card)
        Intrigue.discard(card)
    end)

    -- Send all played navigation cards to the trash.
    local playedNavigationCards = Helper.concatTables(
        Helper.filter(Park.getObjects(self.agentCardPark), Types.isNavigationCard),
        Helper.filter(Park.getObjects(self.revealCardPark), Types.isNavigationCard)
    )
    Helper.forEach(playedNavigationCards, function (i, card)
        self:trash(card)
    end)

    -- Flip any used tech.
    for _, techTile in ipairs(Park.getObjects(self.techPark)) do
        if Types.isTech(techTile) and techTile.is_face_down then
            techTile.flip()
        end
    end
end

---@param phase? Phase
---@param color? PlayerColor
---@param refreshing? boolean
function PlayBoard._setActivePlayer(phase, color, refreshing)
    for _, otherColor in ipairs(PlayBoard.ALL_COLORS) do
        local playBoard = PlayBoard.playBoards[otherColor]
        if playBoard then
            local bandColor = "Black"
            if color and otherColor == color then
                bandColor = color
                if phase and playBoard.opponent == "rival" and not refreshing then
                    Hagal.activate(phase, color)
                end
            end
            playBoard.content.colorband.setColorTint(bandColor)
        end
    end

    if phase ~= "leaderSelection" then
        PlayBoard._updateControlButtons()
    end
end

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

---@param color PlayerColor
function PlayBoard.createEndOfTurnButton(color)
    PlayBoard.playBoards[color]:_createEndOfTurnButton()
end

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
        font_color = Helper.concatTables(PlayBoard._getTextColor(self.color), { 100 })
    })
end

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
        font_color = Helper.concatTables(PlayBoard._getTextColor(self.color), { 100 })
    })
end

---@param phase Phase
---@param color PlayerColor
---@return boolean
function PlayBoard.acceptTurn(phase, color)
    assert(color)
    local playBoard = PlayBoard.getPlayBoard(color)
    local accepted = false

    if phase == 'leaderSelection' then
        accepted = playBoard.leader == nil
    elseif phase == 'gameStart' then
        accepted = playBoard.lastPhase ~= phase and playBoard.leader.instruct(phase, true) ~= nil
    elseif phase == 'roundStart' then
        accepted = playBoard.lastPhase ~= phase and playBoard.leader.instruct(phase, true) ~= nil
    elseif phase == 'arrakeenScouts' then
        -- TODO We need something more elaborate.
        accepted = true
    elseif phase == 'playerTurns' then
        accepted = PlayBoard.couldSendAgentOrReveal(color)
        -- Specific to the base game in 2P mode.
        if accepted and Hagal.getRivalCount() == 1 and PlayBoard.isRival(color) then
            accepted = not PlayBoard.playBoards[TurnControl.getFirstPlayer()].revealed
        end
    elseif phase == 'combat' then
        if Combat.isInCombat(color) and Combat.isFormalCombatPhaseEnabled() then
            accepted = PlayBoard.combatPassCountdown > 0 and not PlayBoard.isRival(color) and #PlayBoard._getPotentialCombatIntrigues(color) > 0
            PlayBoard.combatPassCountdown = PlayBoard.combatPassCountdown - 1
        end
    elseif phase == 'combatEnd' then
        if playBoard.lastPhase ~= phase then
            accepted = true
            -- Rival collect their reward their own way.
            -- Note: why not doing this in a playerTurn listener?
            if PlayBoard.isHuman(color) then
                Helper.onceFramesPassed(1).doAfter(Helper.partialApply(PlayBoard.collectReward, color))
            end
        else
            return false
        end
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

---@param action fun(leader: Leader, color:PlayerColor, altClick:boolean)
---@return ClickFunction
function PlayBoard.withLeader(action)
    return function (_, color, ...)
        local validPlayer = Helper.isElementOf(color, PlayBoard.getActivePlayBoardColors())
        if validPlayer then
            local leader = PlayBoard.getLeader(color)
            if leader then
                if true then
                    -- Replace the source by the leader.
                    action(leader, color, ...)
                end
            else
                Dialog.broadcastToColor(I18N('noLeader'), color, "Purple")
            end
        else
            Dialog.broadcastToColor(I18N('noTouch'), color, "Purple")
        end
    end
end

---@param color PlayerColor
function PlayBoard.collectReward(color)
    local conflictName = Combat.getCurrentConflictName()
    local rank = Combat.getRank(color).value
    ConflictCard.collectReward(color, conflictName, rank).doAfter(function ()
        if rank == 1 then
            local leader = PlayBoard.getLeader(color)
            if PlayBoard.hasTech(color, "windtraps") then
                leader.resources(color, "water", 1)
            end
            if PlayBoard.hasTech(color, "planetaryArray") then
                leader.drawImperiumCards(color, 1)
            end

            local dreadnoughts = Combat.getDreadnoughtsInConflict(color)
            if #dreadnoughts > 0 then
                Dialog.showInfoDialog(color, I18N("dreadnoughtMandatoryOccupation"))
            end
        end
    end)
end

---@param color PlayerColor
function PlayBoard.getPlayBoard(color)
    assert(color)
    assert(#Helper.getKeys(PlayBoard.playBoards) > 0, "No playBoard at all: too soon!")
    local playBoard = PlayBoard.playBoards[color]
    assert(playBoard, "No playBoard for color " .. tostring(color))
    return playBoard
end

---@param filterOutRival? boolean
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

---@param filterOutRival? boolean
function PlayBoard.getActivePlayBoardColors(filterOutRival)
    return Helper.getKeys(PlayBoard._getPlayBoards(filterOutRival))
end

---@param color PlayerColor
function PlayBoard._getBoard(color)
    return PlayBoard.getContent(color).board
end

---@param operation? "symmetric"|"offseted" An optional geometric operation to apply to the offset.
---@param offset Vector An relative position, not to the board center, but its center on top.
---@return Vector
function PlayBoard:_generateAbsolutePosition(operation, offset)

    local colorSwitch = function (left, right)
        if PlayBoard.isLeft(self.color) then
            return left
        else
            return right
        end
    end

    local p = self.content.board.getPosition()
    p = p + Vector(0, Board.onPlayBoard(-p.y), 0)

    if not operation then
        p = p + offset
    elseif operation == "symmetric" then
        p = p + colorSwitch(Vector(-offset.x, offset.y, offset.z), offset)
    elseif operation == "offseted" then
        p = p + colorSwitch(Vector(PlayBoard.OFFSET + offset.x, offset.y, offset.z), offset)
    else
        error("Unknow operation: " .. tostring(operation))
    end

    return p
end

function PlayBoard:_createAgentCardPark()
    local origin = self:_generateAbsolutePosition("symmetric", Vector(0.5, 0, -1))
    local spacing = PlayBoard.isLeft(self.color) and -2.5 or 2.5
    local slots = Park.createMatrixOfSlots(origin, Vector(12, 1, 1), Vector(spacing, 0, 0))
    local park = Park.createCommonPark({ "Imperium", "Intrigue", "Navigation" }, slots, Vector(2.4, 0.5, 3.2), Vector(0, 180, 0), true)
    park.tagUnion = true
    park.smooth = false
    return park
end

---@return Park
function PlayBoard:_createRevealCardPark()
    local origin = self:_generateAbsolutePosition("symmetric", Vector(0.5, 0, -5))
    local spacing = PlayBoard.isLeft(self.color) and -2.5 or 2.5
    local slots = Park.createMatrixOfSlots(origin, Vector(12, 1, 1), Vector(spacing, 0, 0))
    local zone = Park.createTransientBoundingZone(0, Vector(2.4, 0.5, 3.2), slots)
    local park = Park.createCommonPark({ "Imperium", "Intrigue", "Navigation" }, slots, nil, Vector(0, 180, 0), true, { zone })
    park.tagUnion = true
    park.smooth = false
    return park
end

---@return Park
function PlayBoard:_createAgentPark()
    local origin = self:_generateAbsolutePosition("symmetric", Vector(-8.4, 0, 8.5))
    local spacing = PlayBoard.isLeft(self.color) and -1 or 1
    local slots = Park.createMatrixOfSlots(origin, Vector(4, 1, 1), Vector(spacing, 0, 0))
    local park = Park.createCommonPark({ "Agent", self.color }, slots, Vector(0.75, 3, 0.75))
    park.locked = true
    return park
end

---@return Park
function PlayBoard:_createDreadnoughtPark()
    local origin = self:_generateAbsolutePosition("symmetric", Vector(0, 0, 7.5))
    local spacing = PlayBoard.isLeft(self.color) and -2 or 2
    local slots = Park.createMatrixOfSlots(origin, Vector(2, 1, 1), Vector(spacing, 0, 0))
    return Park.createCommonPark({ "Dreadnought", self.color }, slots, Vector(1, 2, 1))
end

---@return Park
function PlayBoard:_createSupplyPark()
    local origin = self:_generateAbsolutePosition("symmetric", Vector(0, 0, 5.1))
    local diamond = Park.createDiamondOfSlots(origin, 4, 0.5)
    local supplyZone = Park.createTransientBoundingZone(45, Vector(0.75, 0.75, 0.75), diamond.allSlots)
    local park = Park.createCommonPark({ "Troop", self.color }, diamond.slots, nil, Vector(0, -45, 0), true, { supplyZone })
    --park.tagUnion = true
    park.smooth = true
    return park
end

---@param layerCount integer
function PlayBoard:_createSardaukarCommanderSkillPark(layerCount)
    local origin = self:_generateAbsolutePosition("symmetric", Vector(5.5, 0, 2.3))
    local spacing = PlayBoard.isLeft(self.color) and -1.75 or 1.75
    local slots = Park.createMatrixOfSlots(origin, Vector(3, layerCount or 1, 1), Vector(spacing, 0.5, 0))
    return Park.createCommonPark({ "SardaukarCommanderSkill" }, slots, Vector(2, 1, 2.5))
end

---@param layerCount integer
function PlayBoard:_createSardaukarCommanderPark(layerCount)
    local origin = self:_generateAbsolutePosition("symmetric", Vector(5.5, 0.25, 2.2))
    local spacing = PlayBoard.isLeft(self.color) and -1.75 or 1.75
    local slots = Park.createMatrixOfSlots(origin, Vector(3, layerCount or 1, 1), Vector(spacing, 0.5, 0))
    return Park.createCommonPark({ "SardaukarCommander", self.color }, slots, Vector(0.75, 0.75, 0.75))
end

---@param layerCount integer
function PlayBoard:_createTechPark(layerCount)
    local origin = self:_generateAbsolutePosition("symmetric", Vector(5.5, 0, 6.5))
    local spacing = PlayBoard.isLeft(self.color) and -3 or 3
    local slots = Park.createMatrixOfSlots(origin, Vector(2, layerCount or 1, 3), Vector(spacing, 0.5, 2))
    local park = Park.createCommonPark({ "Tech" }, slots, Vector(3, 1, 2))
    park.tagUnion = true
    return park
end

function PlayBoard:_createPlayerScorePark()
    local origin = self:_generateAbsolutePosition("symmetric", Vector(-5.2, 0, 10.35))
    local spacing = PlayBoard.isLeft(self.color) and -1.092 or 1.092
    local width = 18
    local slots = Park.createMatrixOfSlots(origin, Vector(width, 1, 1), Vector(spacing, 0, 0))
    return Park.createCommonPark({ "VictoryPointToken" }, slots, Vector(1, 1, 1), Vector(0, 180, 0))
end

--- The shared score track on the main board.
function PlayBoard:_generatePlayerScoreTrackPositions()
    if not self.content.scoreMarker then
        -- Rival in 2P mode has no score marker.
        return
    end
    local origin = self.content.scoreMarkerInitialPosition

    -- Avoid collision between markers by giving a different height to each.
    local heights = {
        Green = 1,
        Yellow = 1.5,
        Blue = 2,
        Red = 2.5,
    }

    self.scorePositions = {}
    for i = 0, 17 do
        self.scorePositions[i] = {
            origin.x,
            3 + heights[self.color],
            origin.z + i * 1.185
        }
    end
end

function PlayBoard:_updatePlayerScore()
    local scoreMarker = self.content.scoreMarker
    if scoreMarker then
        assert(self.scorePositions and #self.scorePositions > 0, self.color)
        local rectifiedScore = self:getScore()
        rectifiedScore = rectifiedScore > 13 and rectifiedScore - 10 or rectifiedScore
        scoreMarker.setLock(false)
        scoreMarker.setPositionSmooth(self.scorePositions[rectifiedScore])
    end
end

function PlayBoard:_updateSardaukarCommanderRecruitmentButton()
    if self.content.sardaukarMarker then
        local recruitableSardaukarCommanders = Park.getObjects(self.sardaukarCommanderPark)
        SardaukarCommander.setAvailable(self.content.sardaukarMarker, #recruitableSardaukarCommanders > 0)
    end
end

---@param zone Zone
---@param object Object
function PlayBoard.onObjectEnterZone(zone, object)
    if Helper.isNil(zone) or Helper.isNil(object) then
        return
    end
    PlayBoard._onObjectMovingAround(zone, object)

    for color, playBoard in pairs(PlayBoard.playBoards) do
        if playBoard.opponent then
            if Helper.isElementOf(zone, playBoard.scorePark.zones) then
                if Types.isVictoryPointToken(object) then
                    local controlableSpace = Combat.findControlableSpaceFromConflictName(Helper.getID(object))
                    PlayBoard.occupationCooldown = PlayBoard.occupationCooldown or {}
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

---@param zone Zone
---@param object Object
function PlayBoard.onObjectLeaveZone(zone, object)
    if Helper.isNil(zone) or Helper.isNil(object) then
        return
    end
    PlayBoard._onObjectMovingAround(zone, object)
end

---@param zone Zone
---@param object Object
function PlayBoard._onObjectMovingAround(zone, object)
    for color, playBoard in pairs(PlayBoard.playBoards) do
        if playBoard.opponent then
            if playBoard.scorePark and Helper.isElementOf(zone, Park.getZones(playBoard.scorePark)) and Types.isVictoryPointToken(object) then
                playBoard:_updatePlayerScore()
            end
            if playBoard.techPark and Helper.isElementOf(zone, Park.getZones(playBoard.techPark)) and Types.isTech(object) then
                TechMarket.setContributions(color)
            end
            if playBoard.sardaukarCommanderPark and Helper.isElementOf(zone, Park.getZones(playBoard.sardaukarCommanderPark)) and Types.isSardaukarCommander(object) then
                playBoard:_updateSardaukarCommanderRecruitmentButton()
            end
        end
    end
end

function PlayBoard:_tearDown()
    self:_cleanUp(true, true, true, true, true)
    PlayBoard.playBoards[self.color] = nil
end

---@param base boolean
---@param ix boolean
---@param immortality boolean
---@param bloodlines boolean
---@param full? boolean
function PlayBoard:_cleanUp(base, ix, immortality, bloodlines, full)
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
        collect("councilToken")
        collect("scoreMarker")
        collect("endTurnButton")
        collect("drawDeckZone")
        collect("leaderZone")
        collect("discardZone")
        collect("firstPlayerMarkerZone")

        collect("spice")
        collect("solari")
        collect("water")
        collect("strength")
        collect("persuasion")
        collect("trash")

        collect("agents")
        collect("swordmaster")

        if true then
            collect("controlMarkerBag")
            collect("forceMarker")
            collect("fourPlayerVictoryToken")
            collect("troops")
        end
    end

    if ix then
        if true then
            collect("dreadnoughts")
            collect("freighter")
        end
    end

    if immortality then
        if true then
            collect("tleilaxToken")
            collect("researchToken")
        end
        collect("atomicsToken")
    end

    if bloodlines then
        collect("sardaukarMarker")
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

---@param board Object
---@return PlayerColor?
function PlayBoard.findBoardColor(board)
    for color, _ in pairs(PlayBoard.playBoards) do
        if PlayBoard._getBoard(color) == board then
            return color
        end
    end
    return nil
end

---@param innerCallback ClickFunction
function PlayBoard:_createExclusiveCallback(innerCallback)
    return Helper.registerGlobalCallback(function (object, color, altClick)
        if self.leader and self.color == color or PlayBoard.isRival(self.color) or TurnControl.isHotSeatEnabled() then
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

---@param innerCallback ClickFunction
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

function PlayBoard:_clearButtons()
    Helper.clearButtons(self.content.board)
    if self.content.atomicsToken then
        Helper.clearButtons(self.content.atomicsToken)
    end
end

---@param color PlayerColor
---@return number[] RGB triplet
function PlayBoard._getTextColor(color)
    local fontColor = { 0.9, 0.9, 0.9 }
    if color == "Green" or color == "Yellow" or color == "White" then
        fontColor = { 0.1, 0.1, 0.1 }
    end
    return fontColor
end

function PlayBoard:_createButtons()
    self:_clearButtons()

    local fontColor = PlayBoard._getTextColor(self.color)

    local board = self.content.board

    if PlayBoard.isHuman(self.color) then
        board.createButton({
            click_function = self:_createExclusiveCallback(function ()
                self:drawCards(1)
            end),
            label = I18N("drawOneCardButton"),
            position = self:_newOffsetedBoardPosition(-13.5, 0.67, 2.6),
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
            position = self:_newOffsetedBoardPosition(-3.5, 0.67, 2.6),
            width = 1400,
            height = 250,
            font_size = 150,
            color = self.color,
            font_color = fontColor
        })

        board.createButton({
            click_function = Helper.registerGlobalCallback(),
            label = I18N("agentTurn"),
            position = self:_newSymmetricBoardPosition(-14.8, 0.67, -1),
            rotation = self:_newSymmetricBoardRotation(0, -90, 0),
            width = 0,
            height = 0,
            font_size = 280,
            color = { 0, 0, 0, 1 },
            font_color = self.color
        })

        board.createButton({
            click_function = self:_createExclusiveCallback(function (_, _, altClick)
                if PlayBoard.isHuman(self.color) and not self.revealing then
                    self:onRevealHand(altClick)
                end
            end),
            label = I18N("revealHandButton"),
            position = self:_newSymmetricBoardPosition(-14.8, 0.67, -5),
            rotation = self:_newSymmetricBoardRotation(0, -90, 0),
            width = 1600,
            height = 320,
            font_size = 280,
            color = self.color,
            font_color = fontColor,
            tooltip = I18N("revealHandTooltip")
        })

        self:_createNukeButton()
    end
end

function PlayBoard:_createNukeButton()
    if self.content.atomicsToken then
        self.content.atomicsToken.createButton({
            click_function = self:_createExclusiveCallback(function ()
                if PlayBoard.isHuman(self.color) then
                    self:_nukeConfirm()
                end
            end),
            tooltip = I18N('atomics'),
            position = Vector(0, 0.67, 0),
            width = 700,
            height = 700,
            scale = Vector(3, 3, 3),
            font_size = 300,
            font_color = {1, 1, 1, 100},
            color = {0, 0, 0, 0}
        })
    end
end

---@param brutal boolean
function PlayBoard:onRevealHand(brutal)
    local currentPlayer = TurnControl.getCurrentPlayer()
    if currentPlayer and currentPlayer ~= self.color then
        Dialog.broadcastToColor(I18N("revealNotTurn"), self.color, "Pink")
    else
        if not self.revealed and self:stillHavePlayableAgents() then
            self:tryRevealHandEarly(brutal)
        else
            self:revealHand(brutal)
        end
    end
end

---@param brutal boolean
function PlayBoard:tryRevealHandEarly(brutal)
    local origin = PlayBoard.getPlayBoard(self.color):_newSymmetricBoardPosition(-8, 0.67, -4.5)

    local board = self.content.board

    local indexHolder = {}

    local function reset()
        self.revealing = false
        Helper.removeButtons(board, Helper.getValues(indexHolder))
    end

    self.revealing = true

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
            self:revealHand(brutal)
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

---@param brutal boolean
function PlayBoard:revealHand(brutal)
    PlayBoard._onceCardParkSpread(self.agentCardPark).doAfter(function ()
        PlayBoard._onceCardParkSpread(self.revealCardPark).doAfter(function ()
            self:_revealHand(brutal)
        end)
    end)
end

---@param brutal boolean
function PlayBoard:_revealHand(brutal)
    local playedCards = Helper.filter(Park.getObjects(self.agentCardPark), Types.isImperiumCard)

    local properCard = function (card)
        assert(card)
        if Types.isImperiumCard(card) then
            --[[
                We leave the sister card in the player's hand to simplify things and
                make clear to the player that the card must be manually revealed.
            ]]
            return Types.isImperiumCard(card) and Helper.getID(card) ~= "beneGesseritSister"
        else
            return false
        end
    end

    local revealedCards = Helper.filter(Player[self.color].getHandObjects(), properCard)
    local alreadyRevealedCards = Helper.filter(Park.getObjects(self.revealCardPark), properCard)
    local allRevealedCards = Helper.concatTables(revealedCards, alreadyRevealedCards)

    local imperiumCardContributions = ImperiumCard.evaluateReveal(self.color, playedCards, allRevealedCards)
    --Helper.dump("imperiumCardContributions:", imperiumCardContributions)
    local techCardContributions = TechCard.evaluatePostReveal(self.color, imperiumCardContributions)
    --Helper.dump("techCardContributions:", techCardContributions)

    local sardaukarCommanderSkillCardContributions
    if Combat.hasAnySardaukarCommander(self.color) then
        local skillCardNames = PlayBoard.getAllCommanderSkillNames(self.color)
        sardaukarCommanderSkillCardContributions = SardaukarCommanderSkillCard.evaluateReveal(self.color, skillCardNames)
    else
        sardaukarCommanderSkillCardContributions = {}
    end
    --Helper.dump("sardaukarCommanderSkillCardContributions:", sardaukarCommanderSkillCardContributions)

    local contributions = {}
    for _, set in ipairs({ imperiumCardContributions, techCardContributions, sardaukarCommanderSkillCardContributions }) do
        for k, v in pairs(set) do
            contributions[k] = (contributions[k] or 0) + v
        end
    end

    self.persuasion:set(contributions.persuasion or 0)
    self.strength:set(contributions.strength or 0)
    self:_refreshStaticContributions(false)

    if brutal and not self.revealed then
        for _, resourceName in ipairs({ "spice", "solari", "water" }) do
            local amount = contributions[resourceName]
            if amount then
                self.leader.resources(self.color, resourceName, amount)
            end
        end

        local intrigues = contributions.intrigues
        if intrigues then
            self.leader.drawIntrigues(self.color, intrigues)
        end

        local sendTroops = function (category, to)
            local amount = contributions[category] or 0
            if amount > 0 then
                self.leader.troops(self.color, "supply", to, amount)
            end
        end

        sendTroops("troops", "garrison")
        sendTroops("fighters", "combat")
        sendTroops("negotiators", "negotiation")
        sendTroops("specimens", "tanks")
    end

    Park.putObjects(revealedCards, self.revealCardPark)

    Helper.emitEvent("reveal", self.color)

    self.revealed = true
end

---@param park Park
---@return Continuation
function PlayBoard._onceCardParkSpread(park)
    local continuation = Helper.createContinuation("PlayBoard.spreadCardPark")
    local count = 0

    local next = function ()
        if count == 0 then
            Helper.onceFramesPassed(1).doAfter(continuation.run)
        end
    end

    local freeSlots = Park.findEmptySlots(park)

    for _, object in ipairs(Park.getObjects(park)) do
        if object.type == "Deck" then
            local cardCound = Helper.getCardCount(object)
            for _ = 2, cardCound do
                if count >= #freeSlots then
                    break
                end
                count = count + 1
                local p = freeSlots[count]
                local parameters = {
                    position = freeSlots[count],
                    smooth = false,
                    -- It matters that the target position is not directly a deck or card.
                    -- Otherwise, the taken card won't be created and the callback won't be
                    -- called.
                    callback_function = function ()
                        count = count - 1
                        next()
                    end
                }
                object.takeObject(parameters)
            end
        end
    end

    next()

    return continuation
end

---@param reconsiderSpaces boolean
function PlayBoard:_refreshStaticContributions(reconsiderSpaces)
    TechMarket.setContributions(self.color)

    local councilSeat = PlayBoard.hasHighCouncilSeat(self.color)
    self.persuasion:setBaseValueContribution("highCouncilSeat", councilSeat and 2 or 0)

    if reconsiderSpaces then
        -- FIXME The agent could have been removed in some cases (e.g. Kwisatz Haderach).
        local techNegotiation = MainBoard.hasAgentInSpace("techNegotiation", self.color)
        self.persuasion:setBaseValueContribution("techNegotiation", techNegotiation and 1 or 0)

        -- FIXME The agent could have been removed in some cases (e.g. Kwisatz Haderach).
        local hallOfOratory = MainBoard.hasAgentInSpace("hallOfOratory", self.color)
        self.persuasion:setBaseValueContribution("hallOfOratory", hallOfOratory and 1 or 0)
    end

    --local swordmasterBonus = TurnControl.getPlayerCount() == 6 and PlayBoard.hasSwordmaster(self.color)
    --self.strength:setBaseValueContribution("swordmaster", swordmasterBonus and 2 or 0)
end

---@return boolean
function PlayBoard:stillHavePlayableAgents()
    return #Park.getObjects(self.agentPark) > 0
end

---@param color PlayerColor
---@return Card[]
function PlayBoard.getCardsPlayedThisTurn(color)
    local playBoard = PlayBoard.getPlayBoard(color)

    local playedCards = Helper.filter(Park.getObjects(playBoard.agentCardPark), function (card)
        return Types.isImperiumCard(card) or Types.isIntrigueCard(card)
    end)

    return (Set.newFromList(playedCards) - Set.newFromList(playBoard.alreadyPlayedCards or {})):toList()
end

---@param color PlayerColor
---@param cardName string
---@return boolean
function PlayBoard.hasPlayedThisTurn(color, cardName)
    for _, card in ipairs(PlayBoard.getCardsPlayedThisTurn(color)) do
        if Helper.getID(card) == cardName then
            return true
        end
    end
    return false
end

---@param color PlayerColor
---@return boolean
function PlayBoard.couldSendAgentOrReveal(color)
    local playBoard = PlayBoard.getPlayBoard(color)
    if playBoard.opponent == "rival" then
        return playBoard:stillHavePlayableAgents()
    else
        return not playBoard.revealed
    end
end

---@param count integer
---@return Continuation
function PlayBoard:tryToDrawCards(count)
    local continuation = Helper.createContinuation("PlayBoard:tryToDrawCards")

    if not self.drawCardsCoalescentQueue then

        local function coalesce(c1, decalHeight)
            return {
                parameteredContinuations = Helper.concatTables(c1.parameteredContinuations, decalHeight.parameteredContinuations),
                count = c1.count + decalHeight.count
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

        self.drawCardsCoalescentQueue = Helper.createCoalescentQueue("draw", 1, coalesce, handle)
    end

    self.drawCardsCoalescentQueue.submit({
        parameteredContinuations = { { continuation = continuation, parameter = count } },
        count = count
    })

    return continuation
end

---@param count integer
---@return Continuation
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

---@param count integer
---@return Continuation
function PlayBoard:drawCards(count)
    local continuation = Helper.createContinuation("PlayBoard:drawCards")

    local deckOrCard = Helper.getDeckOrCard(self.content.drawDeckZone)
    local drawableCardCount = Helper.getCardCount(deckOrCard)

    local dealCardCount = math.min(count, drawableCardCount)
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

---@return Continuation
function PlayBoard:_resetDiscard()
    local continuation = Helper.createContinuation("PlayBoard:_resetDiscard")
    local discard = Helper.getDeckOrCard(self.content.discardZone)
    if discard then
        discard.setRotationSmooth(Vector(0, 180, 180), false, false)
        discard.setPositionSmooth(self.content.drawDeckZone.getPosition() + Vector(0, 1, 0), false, true)
        Helper.onceOneDeck(self.content.drawDeckZone).doAfter(function ()
            local replenishedDeckOrCard = Helper.getDeckOrCard(self.content.drawDeckZone)
            assert(replenishedDeckOrCard)
            if replenishedDeckOrCard.type == "Deck" then
                ---@cast replenishedDeckOrCard Deck
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
        position = Vector(0, 0.67, 3.5),
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
        position = Vector(-5, 0.67, 0),
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
        position = Vector(5, 0.67, 0),
        width = 550,
        height = 350,
        scale = Vector(3, 3, 3),
        font_size = 300,
        font_color = {1, 1, 1},
        color = "Red"
    })
end

---@param color PlayerColor
---@return boolean
function PlayBoard.isRival(color)
    local playerBoard = PlayBoard.getPlayBoard(color)
    return playerBoard.opponent == "rival"
end

---@param color PlayerColor
---@return boolean
function PlayBoard.isHuman(color)
    local playerBoard = PlayBoard.getPlayBoard(color)
    return playerBoard.opponent ~= "rival"
end

---@param color PlayerColor
---@param leaderCard DeckOrCard
---@return Continuation?
function PlayBoard.setLeader(color, leaderCard)
    assert(Types.isPlayerColor(color))
    assert(leaderCard)

    local playBoard = PlayBoard.getPlayBoard(color)
    if playBoard.opponent == "rival" then
        if Hagal.getRivalCount() == 1 then
            assert(leaderCard.type == "Deck")
            playBoard.leader = Rival.newRival(color)
        else
            assert(leaderCard.type == "Card")
            ---@cast leaderCard Card
            if Hagal.isLeaderCompatible(leaderCard) then
                playBoard.leader = Rival.newRival(color, Helper.getID(leaderCard))
            else
                log("Not a leader compatible with a rival: " .. Helper.getID(leaderCard))
                return nil
            end
        end
    else
        assert(leaderCard.hasTag("Leader"))
        playBoard.leader = Leader.newLeader(Helper.getID(leaderCard))
    end

    assert(playBoard.leader)
    local position = playBoard.content.leaderZone.getPosition()
    leaderCard.setPosition(position)
    playBoard.leaderCard = leaderCard

    local continuation = Helper.onceMotionless(leaderCard)

    continuation.doAfter(function ()
        -- Do not lock the Hagal deck in 2P.
        if playBoard.opponent ~= "rival" or Hagal.getRivalCount() > 1 then
            Helper.noPhysics(leaderCard)
        end
        playBoard:_createButtons()
    end)

    return continuation
end

--- Useful to find the leader card before the setup.
---@param color PlayerColor
---@return Card?
function PlayBoard.findLeaderCard(color)
    local leaderZone = PlayBoard.getContent(color).leaderZone
    for _, object in ipairs(leaderZone.getObjects()) do
        if object.hasTag("Leader") or object.hasTag("Hagal") then
            return object
        end
    end
    return nil
end

---@param color PlayerColor
---@return Leader
function PlayBoard.getLeader(color)
    return PlayBoard.getPlayBoard(color).leader
end

---@param color PlayerColor
---@return string
function PlayBoard.getLeaderName(color)
    local leaderCard = PlayBoard.findLeaderCard(color)
    return leaderCard and leaderCard.getName() or "?"
end

---TODO Encapsulate.
---@param color PlayerColor
---@return table
function PlayBoard.getContent(color)
    local playBoard = PlayBoard.getPlayBoard(color)
    assert(playBoard, "Unknow player color: " .. tostring(color))
    return playBoard.content
end

---@param color PlayerColor
---@return Park
function PlayBoard.getAgentCardPark(color)
    return PlayBoard.getPlayBoard(color).agentCardPark
end

---@param color PlayerColor
---@return Park
function PlayBoard.getRevealCardPark(color)
    return PlayBoard.getPlayBoard(color).revealCardPark
end

---@param color PlayerColor
---@return Park
function PlayBoard.getAgentPark(color)
    return PlayBoard.getPlayBoard(color).agentPark
end

---@param color PlayerColor
---@return Park
function PlayBoard.getDreadnoughtPark(color)
    return PlayBoard.getPlayBoard(color).dreadnoughtPark
end

---@param color PlayerColor
---@return Park
function PlayBoard.getSupplyPark(color)
    return PlayBoard.getPlayBoard(color).supplyPark
end

---@param color PlayerColor
---@return Park
function PlayBoard.getSardaukarCommanderPark(color)
    return PlayBoard.getPlayBoard(color).sardaukarCommanderPark
end

---@param color PlayerColor
---@return Park
function PlayBoard.getTechPark(color)
    return PlayBoard.getPlayBoard(color).techPark
end

---@param color PlayerColor
---@return Park
function PlayBoard.getScorePark(color)
    return PlayBoard.getPlayBoard(color).scorePark
end

---@return integer
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

---@param color PlayerColor
---@param techTile Card
---@return boolean
function PlayBoard.grantTechTile(color, techTile)
    return Park.putObject(techTile, PlayBoard.getPlayBoard(color).techPark)
end

---@param color PlayerColor
---@param card Card
---@return boolean
function PlayBoard.grantSardaukarCommanderSkillCard(color, card)
    return Park.putObject(card, PlayBoard.getPlayBoard(color).sardaukarCommanderSkillPark)
end

---@param color PlayerColor
---@return Object[]
function PlayBoard.getScoreTokens(color)
    return Park.getObjects(PlayBoard.getPlayBoard(color).scorePark)
end

---@param color PlayerColor
---@param token Object
---@return boolean
function PlayBoard.grantScoreToken(color, token)
    token.setInvisibleTo({})
    return Park.putObject(token, PlayBoard.getPlayBoard(color).scorePark)
end

---@param color PlayerColor
---@param tokenBag Bag
---@param count? integer
---@return boolean
function PlayBoard.grantScoreTokenFromBag(color, tokenBag, count)
    return Park.putObjectFromBag(tokenBag, PlayBoard.getPlayBoard(color).scorePark, count)
end

---@param color PlayerColor
---@param techName string
---@return boolean
function PlayBoard.hasTech(color, techName)
    return PlayBoard.getTech(color, techName) ~= nil
end

---@param color PlayerColor
---@param techName string
---@return table?
function PlayBoard.getTech(color, techName)
    local techs = Park.getObjects(PlayBoard.getPlayBoard(color).techPark)
    for _, tech in ipairs(techs) do
        if Helper.getID(tech) == techName then
            return tech
        end
    end
    return nil
end

---@param color PlayerColor
---@return Card[]
function PlayBoard.getAllTechs(color)
    local objects = Park.getObjects(PlayBoard.getPlayBoard(color).techPark)
    local techTiles = Helper.filter(objects, Types.isTech)
    return techTiles
end

---@param color PlayerColor
---@return string[]
function PlayBoard.getAllCommanderSkillNames(color)
    local objects = Park.getObjects(PlayBoard.getPlayBoard(color).sardaukarCommanderSkillPark)
    return Helper.getAllCardNames(Helper.filter(objects, Types.isSardaukarCommanderSkillCard))
end

---@param color PlayerColor
---@param techName string
---@return boolean
function PlayBoard.useTech(color, techName)
    local tech = PlayBoard.getTech(color, techName)
    if tech and not tech.is_face_down then
        tech.flip()
        return true
    else
        return false
    end
end

---@param color PlayerColor
---@return boolean
function PlayBoard.hasHighCouncilSeat(color)
    local token = PlayBoard.getCouncilToken(color)
    for _, zone in ipairs(Park.getZones(MainBoard.getHighCouncilSeatPark())) do
        if Helper.contains(zone, token) then
            return true
        end
    end
    return false
end

---@param color PlayerColor
---@return boolean
function PlayBoard.takeHighCouncilSeat(color)
    local token = PlayBoard.getCouncilToken(color)
    if not PlayBoard.hasHighCouncilSeat(color) then
        if Park.putObject(token, MainBoard.getHighCouncilSeatPark()) then
            Helper.clearButtons(token)
            token.interactable = true
            local playBoard = PlayBoard.getPlayBoard(color)
            playBoard.persuasion:setBaseValueContribution("highCouncilSeat", 2)
            Helper.emitEvent("highCouncilSeatTaken", color)
            return true
        end
    end
    return false
end

---@param color PlayerColor
---@return boolean
function PlayBoard.hasSwordmaster(color)
    local swordmaster = PlayBoard.getSwordmaster(color)
    return swordmaster and (MainBoard.isInside(swordmaster) or PlayBoard.isInside(color, swordmaster))
end

---@param color PlayerColor
---@return boolean
function PlayBoard.recruitSwordmaster(color)
    return Park.putObject(PlayBoard.getSwordmaster(color), PlayBoard.getAgentPark(color))
end

---@param color PlayerColor
---@return Object
function PlayBoard.getSwordmaster(color)
    local content = PlayBoard.getContent(color)
    return content.swordmaster
end

---@param color PlayerColor
---@return boolean
function PlayBoard.recruitSardaukarCommander(color)
    local garrison = Combat.getGarrisonPark(color)
    local sardaukarReserve = PlayBoard.getSardaukarCommanderPark(color)
    if not Park.isEmpty(sardaukarReserve) then
        local leader = PlayBoard.getLeader(color)
        if leader.resources(color, "solari", PlayBoard.hasTech(color, "sardaukarHighCommand") and -1 or -2) then
            return Park.transfer(1, sardaukarReserve, garrison) == 1
        else
            Dialog.broadcastToColor(I18N('notEnoughSolarisToRecruitSardaukarCommander'), color, "Purple")
        end
    end
    return false
end

---@param color PlayerColor
---@return Object
function PlayBoard.getCouncilToken(color)
    local content = PlayBoard.getContent(color)
    return content.councilToken
end

---@param color PlayerColor
---@param resourceName ResourceName
---@return Resource
function PlayBoard.getResource(color, resourceName)
    assert(Types.isResourceName(resourceName))
    return PlayBoard.getPlayBoard(color)[resourceName]
end

---@param color PlayerColor
---@param card Card
---@param isTleilaxuCard boolean
function PlayBoard.giveCard(color, card, isTleilaxuCard)
    assert(Types.isPlayerColor(color))
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

---@param color PlayerColor
---@param zone Zone
---@param isTleilaxuCard? boolean
function PlayBoard.giveCardFromZone(color, zone, isTleilaxuCard)
    assert(Types.isPlayerColor(color))

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

---@param color PlayerColor
---@param cardName string
---@return boolean
function PlayBoard.giveCardFromTrash(color, cardName)
    local content = PlayBoard.getContent(color)
    return PlayBoard._giveFromTrash(color, content.discardZone.getPosition(), nil, function (object)
        return Helper.getID(object) == cardName
    end)
end

---@param color PlayerColor
---@return boolean
function PlayBoard.giveIntrigueFromTrash(color)
    local orientedPosition = PlayBoard.getHandOrientedPosition(color)
    local success = PlayBoard._giveFromTrash(color, orientedPosition.position, orientedPosition.rotation, function (object)
        return Helper.isElementOf("Intrigue", object.tags)
    end)
    if success then
        Intrigue.onIntrigueTaken(color)
    end
    return success
end

---@param color PlayerColor
---@param position Vector
---@param rotation? Vector
---@param predicate fun(object: DeadObject): boolean
---@return boolean
function PlayBoard._giveFromTrash(color, position, rotation, predicate)
    assert(Types.isPlayerColor(color))
    local content = PlayBoard.getContent(color)
    assert(content)
    return PlayBoard._giveFromBag(color, position, rotation, content.trash, predicate, function(card)
        printToAll(I18N("acquireImperiumCard", { card = I18N(Helper.getID(card)) }), color)
    end)
end

---@param color PlayerColor
---@param bag Bag
---@return boolean
function PlayBoard.giveNavigationFromBag(color, bag)
    local orientedPosition = PlayBoard.getHandOrientedPosition(color)
    return PlayBoard._giveFromBag(color, orientedPosition.position, orientedPosition.rotation, bag, function (object)
        return Helper.isElementOf("Navigation", object.tags)
    end)
end

---@param color PlayerColor
---@param position Vector
---@param rotation? Vector
---@param bag Bag
---@param predicate fun(object: DeadObject): boolean
---@param callback? function
---@return boolean
function PlayBoard._giveFromBag(color, position, rotation, bag, predicate, callback)
    assert(Types.isPlayerColor(color))

    local content = PlayBoard.getContent(color)
    assert(content)

    for _, object in ipairs(bag.getObjects()) do
        if predicate(object) then
            local parameters = {
                guid = object.guid,
                position = position,
                rotation = rotation,
                smooth = false,
                callback_function = callback
            }
            bag.takeObject(parameters)
            return true
        end
    end

    return false
end

---@param color PlayerColor
---@return DeckOrCard?
function PlayBoard.getDrawDeck(color)
    local playBoard = PlayBoard.getPlayBoard(color)
    local deckOrCard = Helper.getDeckOrCard(playBoard.content.drawDeckZone)
    return deckOrCard
end

---@param color PlayerColor
---@return DeckOrCard?
function PlayBoard.getDiscard(color)
    local playBoard = PlayBoard.getPlayBoard(color)
    local deckOrCard = Helper.getDeckOrCard(playBoard.content.discardZone)
    return deckOrCard
end

---@param color PlayerColor
---@return Card[]
function PlayBoard.getHandedCards(color)
    return Helper.filter(Player[color].getHandObjects(), Types.isImperiumCard)
end

---@param color PlayerColor
---@return (Card|DeadObject)[]
function PlayBoard.getDiscardedCards(color)
    local playBoard = PlayBoard.getPlayBoard(color)
    local deckOrCard = Helper.getDeckOrCard(playBoard.content.discardZone)
    return Helper.getCards(deckOrCard)
end

---@param color PlayerColor
---@return integer
function PlayBoard.getDiscardedCardCount(color)
    local playBoard = PlayBoard.getPlayBoard(color)
    local deckOrCard = Helper.getDeckOrCard(playBoard.content.discardZone)
    return Helper.getCardCount(deckOrCard)
end

--- Anything trashed (and filtering is hard considering the content is not spawned).
---@param color PlayerColor
---@return Object[]
function PlayBoard.getTrashedObjects(color)
    local playBoard = PlayBoard.getPlayBoard(color)
    return playBoard.content.trash.getObjects()
end

---@param color PlayerColor
---@return Card[]
function PlayBoard.getIntrigues(color)
    return Helper.filter(Player[color].getHandObjects(), Types.isIntrigueCard)
end

---@param color PlayerColor
---@return Card[]
function PlayBoard._getPotentialCombatIntrigues(color)
    local predicate
    if Hagal.getRivalCount() == 2 then
        predicate = function (card)
            return Types.isIntrigueCard(card) -- and IntrigueCard.isCombatCard(card)
        end
    else
        predicate = Types.isIntrigueCard
    end
    return Helper.filter(Player[color].getHandObjects(), predicate)
end

---@param color PlayerColor
---@return integer
function PlayBoard.getAquiredDreadnoughtCount(color)
    local park = PlayBoard.getPlayBoard(color).dreadnoughtPark
    return #Park.findEmptySlots(park)
end

---@param color PlayerColor
---@return Bag
function PlayBoard.getControlMarkerBag(color)
    local content = PlayBoard.getContent(color)
    assert(content)
    return content.controlMarkerBag
end

---@param x number
---@param y number
---@param z number
---@return Vector
function PlayBoard:_newSymmetricBoardPosition(x, y, z)
    if PlayBoard.isLeft(self.color) then
        return self:_newBoardPosition(-x, y, z)
    else
        return self:_newBoardPosition(x, y, z)
    end
end

---@param x number
---@param y number
---@param z number
---@return Vector
function PlayBoard:_newSymmetricBoardRotation(x, y, z)
    if PlayBoard.isLeft(self.color) then
        return self:_newBoardPosition(x, -y, z)
    else
        return self:_newBoardPosition(x, y, z)
    end
end

---@param x number
---@param y number
---@param z number
---@return Vector
function PlayBoard:_newOffsetedBoardPosition(x, y, z)
    if PlayBoard.isLeft(self.color) then
        return self:_newBoardPosition(PlayBoard.OFFSET + x, y, z)
    else
        return self:_newBoardPosition(x, y, z)
    end
end

---@param x number
---@param y number
---@param z number
---@return Vector
function PlayBoard:_newBoardPosition(x, y, z)
    return Vector(x, y, -z)
end

--- Relative to the board, not a commander.
---@param color PlayerColor
---@return boolean
function PlayBoard.isLeft(color)
    return color == "Red" or color == "Blue"
end

--- Relative to the board, not a commander.
---@param color PlayerColor
---@return boolean
function PlayBoard.isRight(color)
    return color == "Green" or color == "Yellow"
end

---@param object Object
function PlayBoard:trash(object)
    self.trashQueue = self.trashQueue or Helper.createSpaceQueue()
    self.trashQueue.submit(function (height)
        object.interactable = true
        object.setLock(false)
        object.setPosition(self.content.trash.getPosition() + Vector(0, 1 + height * 0.5, 0))
    end)
end

---@param color PlayerColor
---@param object Object
---@return boolean
function PlayBoard.isInside(color, object)
    local position = object.getPosition()
    local center = PlayBoard.getPlayBoard(color).content.board.getPosition()
    local offset = position - center
    return math.abs(offset.x) < 12 and math.abs(offset.z) < 10
end

---@param color PlayerColor
---@return { position: Vector, rotation: Vector }
function PlayBoard.getHandOrientedPosition(color)
    -- Add an offset to put the card on the left side of the player's hand.
    local handTransform = Player[color].getHandTransform()
    local position = handTransform.position
    if handTransform.rotation == Vector(0, 0, 0) then
        position = position + Vector(-12.5, 0, 0)
    elseif handTransform.rotation == Vector(0, 270, 0) then
        position = position + Vector(0, 0, -8.5)
    elseif handTransform.rotation == Vector(0, 90, 0) then
        position = position + Vector(0, 0, 8.5)
    else
        -- Should not happen.
        position = position + Vector(0, 0, 0)
    end
    local rotation = handTransform.rotation + Vector(0, 180, 0)
    return {
        position = position,
        rotation = rotation
    }
end

---@param color PlayerColor
---@param voiceToken Object
---@return boolean
function PlayBoard.acquireVoice(color, voiceToken)
    assert(Types.isPlayerColor(color))
    assert(voiceToken)
    local position = PlayBoard.getPlayBoard(color).content.firstPlayerInitialPosition
    voiceToken.setPositionSmooth(position + Vector(0, 1, -1.8))
    return true
end

return PlayBoard
