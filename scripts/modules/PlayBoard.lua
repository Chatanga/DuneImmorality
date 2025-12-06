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
local Commander = Module.lazyRequire("Commander")
local ConflictCard = Module.lazyRequire("ConflictCard")
local ScoreBoard = Module.lazyRequire("ScoreBoard")
local Action = Module.lazyRequire("Action")
local SardaukarCommander = Module.lazyRequire("SardaukarCommander")
local SardaukarCommanderSkillCard = Module.lazyRequire("SardaukarCommanderSkillCard")
local TechCard = Module.lazyRequire("TechCard")
local Board = Module.lazyRequire("Board")
local Rival = Module.lazyRequire("Rival")

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
---@field spyPark Park
---@field sardaukarCommanderSkillPark Park
---@field dreadnoughtPark Park
---@field supplyPark Park
---@field instructionTextAnchor Object
---@field persuasion Resource
---@field strength Resource
---@field swordmasterBonusPositions table<PlayerColor, Vector>
local PlayBoard = Helper.createClass(nil, {
    OFFSET = 12.75,
    ALL_COLORS = { "Green", "Yellow", "Blue", "Red", "White", "Purple" },
    ALL_RESOURCE_NAMES = { "spice", "water", "solari", "strength", "persuasion" },
    -- Temporary structure (set to nil *after* loading).
    unresolvedContentByColor = {
        Red = {
            board = "d47b92",
            supportBoard = "7c5bb0",
            colorband = "643f4d",
            spice = "3074d4",
            solari = "576ccd",
            water = "692c4d",
            persuasion = "7eb590",
            strength = "3f6645",
            dreadnoughts = {"1a3c82", "a8f306"},
            agents = {"7751c8", "afa978"},
            swordmaster = "ed3490",
            swordmasterBonusToken = "db91e0",
            spies = {
                "fdecae",
                "84d545",
                "e7a4ef",
            },
            councilToken = "f19a48",
            fourPlayerVictoryToken = "a6c2e0",
            scoreMarker = "175a0a",
            scoreMarkerInitialPosition = Helper.getHardcodedPositionFromGUID('175a0a', 10.3903551, 2.19088173, -14.0911646),
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
            trash = "b3a73b",
            completedContractBag = "07cc68",
            tleilaxToken = "2bfc39",
            tleilaxTokenInitalPosition = Helper.getHardcodedPositionFromGUID('2bfc39', 0.542931, 1.882152, 22.0543556),
            researchToken = "39e0f3",
            researchTokenInitalPosition = Helper.getHardcodedPositionFromGUID('39e0f3', 0.3698573, 1.884652, 18.2348137),
            freighter = "9ec642",
            firstPlayerMarkerZone = "781a03",
            firstPlayerInitialPosition = Helper.getHardcodedPositionFromGUID('781a03', -13.6, 2.7, 20.89) + Vector(0, -0.4, 0),
            endTurnButton = "895594",
            atomicsToken = "d5ff47",
            makerHook = "2a8414",
            sardaukarMarker = "b8337b",
        },
        Blue = {
            board = "f23836",
            supportBoard = "3d9589",
            colorband = "bca124",
            spice = "9cc286",
            solari = "fa5236",
            water = "0afaeb",
            persuasion = "d1fed4",
            strength = "aa3bb9",
            dreadnoughts = {"82789e", "60f208"},
            agents = {"64d013", "106d8b"},
            swordmaster = "a78ad7",
            swordmasterBonusToken = "28ec54",
            spies = {
                "7d7083",
                "e07c5c",
                "272ba1",
            },
            councilToken = "f5b14a",
            fourPlayerVictoryToken = "311255",
            scoreMarker = "7fa9a7",
            scoreMarkerInitialPosition = Helper.getHardcodedPositionFromGUID('7fa9a7', 10.3909073, 2.3901546, -14.090991),
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
            trash = "7c9aab",
            completedContractBag = "431016",
            tleilaxToken = "96607f",
            tleilaxTokenInitalPosition = Helper.getHardcodedPositionFromGUID('96607f', 0.5425502, 1.8846519, 22.75358),
            researchToken = "292658",
            researchTokenInitalPosition = Helper.getHardcodedPositionFromGUID('292658', 0.370049417, 1.88215184, 18.9373875),
            freighter = "9b1fe4",
            firstPlayerMarkerZone = "311c04",
            firstPlayerInitialPosition = Helper.getHardcodedPositionFromGUID('311c04', -13.6, 2.7, -17.49) + Vector(0, -0.4, 0),
            endTurnButton = "9eeccd",
            atomicsToken = "700023",
            makerHook = "7011f2",
            sardaukarMarker = "20842d",
        },
        Green = {
            board = "2facfd",
            supportBoard = "8a1a96",
            colorband = "a138eb",
            spice = "22478f",
            solari = "e597dc",
            water = "fa9522",
            persuasion = "aa79bf",
            strength = "d880f7",
            dreadnoughts = {"a15087", "734250"},
            agents = {"bceb0e", "ee412b"},
            swordmaster = "fb1629",
            swordmasterBonusToken = "f5bfa8",
            spies = {
                "ed1748",
                "795934",
                "8ca6ca",
            },
            councilToken = "a0028d",
            fourPlayerVictoryToken = "66444c",
            scoreMarker = "7bae32",
            scoreMarkerInitialPosition = Helper.getHardcodedPositionFromGUID('7bae32', 10.3895054, 1.99093008, -14.0924873),
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
            trash = "480d28",
            completedContractBag = "9e66be",
            tleilaxToken = "63d39f",
            tleilaxTokenInitalPosition = Helper.getHardcodedPositionFromGUID('63d39f', 1.24582732, 1.88465178, 22.04864),
            researchToken = "658b17",
            researchTokenInitalPosition = Helper.getHardcodedPositionFromGUID('658b17', 0.370005637, 1.882152, 20.3406372),
            freighter = "704034",
            firstPlayerMarkerZone = "ce7c68",
            firstPlayerInitialPosition = Helper.getHardcodedPositionFromGUID('ce7c68', 13.6, 2.7, 20.89) + Vector(0, -0.4, 0),
            endTurnButton = "96aa58",
            atomicsToken = "0a22ec",
            makerHook = "0492e6",
            sardaukarMarker = "dd6996",
        },
        Yellow = {
            board = "13b6cb",
            supportBoard = "da264a",
            colorband = "9232e7",
            spice = "78fb8a",
            solari = "c5c4ef",
            water = "f217d0",
            persuasion = "c04d4e",
            strength = "6f007c",
            dreadnoughts = {"5469fb", "71a414"},
            agents = {"5068c8", "67b476"},
            swordmaster = "635c49",
            swordmasterBonusToken = "e160d9",
            spies = {
                "94ffec",
                "f59e0c",
                "4e66c4",
            },
            councilToken = "1be491",
            fourPlayerVictoryToken = "4e8873",
            scoreMarker = "f9ac91",
            scoreMarkerInitialPosition = Helper.getHardcodedPositionFromGUID('f9ac91', 10.3904238, 1.79251623, -14.090271),
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
            trash = "913f29",
            completedContractBag = "eb459d",
            tleilaxToken = "d20bcf",
            tleilaxTokenInitalPosition = Helper.getHardcodedPositionFromGUID('d20bcf', 1.2472322, 1.8846519, 22.7536983),
            researchToken = "8988cf",
            researchTokenInitalPosition = Helper.getHardcodedPositionFromGUID('8988cf', 0.3700852, 1.882152, 19.6398125),
            freighter = "521923",
            firstPlayerMarkerZone = "ba0c20",
            firstPlayerInitialPosition = Helper.getHardcodedPositionFromGUID('ba0c20', 13.6, 2.7, -17.49) + Vector(0, -0.4, 0),
            endTurnButton = "3d1b90",
            atomicsToken = "7e10a9",
            makerHook = "a07d90",
            sardaukarMarker = "25f3f2",
        },
        White = {
            board = "4ad196",
            colorband = "6d455c",
            spice = "9d593f",
            solari = "5a16bb",
            water = "830a1a",
            persuasion = "57a567",
            strength = "a18dca",
            agents = {"b9a4d2", "2c1095"},
            swordmaster = "c2a908",
            swordmasterBonusToken = "a456bf",
            spies = {
                "96bbc4",
                "040248",
                "bddedd",
            },
            councilToken = "ded786",
            scoreMarker = "201011",
            scoreMarkerInitialPosition = Helper.getHardcodedPositionFromGUID('201011', 10.3917294, 2.58932447, -14.09231),
            trash = "aebead",
            completedContractBag = "9c9f7a",
            firstPlayerMarkerZone = "f4c962",
            firstPlayerInitialPosition = Helper.getHardcodedPositionFromGUID('f4c962', -13.6, 2.7, 1.7) + Vector(0, -0.4, 0),
            endTurnButton = "8d70a4",
            atomicsToken = "a20687",
        },
        Purple = {
            board = "dc05a6",
            colorband = "1434c7",
            spice = "2c9946",
            solari = "43d234",
            water = "c72ecc",
            persuasion = "ab28ea",
            strength = "50f36d",
            agents = {"10ca63", "fb1dd6"},
            swordmaster = "a695f9",
            swordmasterBonusToken = "aa9a39",
            spies = {
                "e5b04d",
                "407c67",
                "a3d964",
            },
            councilToken = "8c6ba7",
            scoreMarker = "2ccf7f",
            scoreMarkerInitialPosition = Helper.getHardcodedPositionFromGUID('2ccf7f', 10.3914042, 2.789329, -14.0921068),
            trash = "bb5961",
            completedContractBag = "240112",
            firstPlayerMarkerZone = "7a8ea9",
            firstPlayerInitialPosition = Helper.getHardcodedPositionFromGUID('7a8ea9', 13.58, 2.7, 1.7) + Vector(0, -0.4, 0),
            endTurnButton = "eded7c",
            atomicsToken = "0a3ccb",
        },
    },
    playBoards = {},
    -- TODO Use the snap points (swordmasterBonusTokenXxx) instead.
    swordmasterBonusPositions = {
        Red = Vector(-0.29, 1.79, -7.77),
        Blue = Vector(-0.29, 1.79, -12.35),
        Green = Vector(6.96, 1.79, -7.77),
        Yellow = Vector(6.96, 1.79, -12.35),
        White = Vector(3.33, 1.79, -12.35),
        Purple = Vector(3.33, 1.79, -7.77),
    }
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
        local spySlots = extractSlotOffsets(pseudoPlayboard:_createSpyPark())
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
            colorband = Vector(0, 0, -0.55),
            fourPlayerVictoryToken = playerScoreSlots[1],
            spice = offseted(-8.4, 0, 4),
            solari = offseted(-6.4, 0, 4.5),
            water = offseted(-4.4, 0, 4),
            agents = agentSlots,
            spies = spySlots,
            persuasion = symmetric(0.5, 0, 0.2),
            strength = symmetric(0.5, 0, 6),
            dreadnoughts = dreadnoughtSlots,
            councilToken = symmetric(-0.5, 0, -0.6),
            controlMarkerBag = symmetric(0.5, 0, 4),
            troops = troopSlots,
            completedContractBag = symmetric(10, -0.05, 6.2),
            makerHook = symmetric(1.85, 0, 2 + (PlayBoard.isTop(color) and 0.7 or -0.7)),
            sardaukarMarker = symmetric(1.8, 0, -0.6),
            trash = symmetric(10, -0.05, 1),
            endTurnButton = symmetric(-2.4, 0, 6),
            atomicsToken = symmetric(10, 0, 3.4),
        }

        local centerOffset = 1
        local boardPositions = {
            Green = Vector(24, 2, 14.2 + centerOffset),
            Yellow = Vector(24, 2, -24.2 + centerOffset),
            Red = Vector(-24, 2, 14.2 + centerOffset),
            Blue = Vector(-24, 2, -24.2 + centerOffset),
            White = Vector(-24, 2, -5 + centerOffset),
            Purple = Vector(24, 2, -5 + centerOffset),
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

        local decalHeight = 0.19

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
                    "https://steamusercontent-a.akamaihd.net/ugc/28805470175239303/D9DC4354D5C11448C6A65AA8124CCE7637B07FCB/",
                    "https://steamusercontent-a.akamaihd.net/ugc/28805470175239157/D7A62A0EDAFA86212F7C537376701E0BEC4F4D2A/"),
                position = symmetric(3.2, decalHeight, -8.1),
                rotation = { 90, 180, 0 },
                scale = { 17.96, 1.1, 1 },
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

        if Helper.isElementOf(color, { "Green", "Yellow", "Blue", "Red" }) then
            decals = Helper.concatTables(decals, {
                {
                    name = "MuadDib Objective Slot",
                    url = "https://steamusercontent-a.akamaihd.net/ugc/2502404390141305375/52C4F6DEBC5F101B6663B833F1964BB9034A7C75/",
                    position = symmetric(-7.4, decalHeight, -8.15),
                    rotation = { 90, 180, 0 },
                    scale = { 0.95, 0.95, 1 },
                },
                {
                    name = "Crysknife Objective Slot",
                    url = "https://steamusercontent-a.akamaihd.net/ugc/2502404390141304988/D455406509BD5D1C4387C102CBACC5BFB56FC59E/",
                    position = symmetric(-8.6, decalHeight, -8.15),
                    rotation = { 90, 180, 0 },
                    scale = { 0.95, 0.95, 1 },
                },
                {
                    name = "Ornithopter Objective Slot",
                    url = "https://steamusercontent-a.akamaihd.net/ugc/2502404390141304687/E4E692FE0EF6AF7B51B5A31DAC5D0D7DC7859655/",
                    position = symmetric(-9.8, decalHeight, -8.15),
                    rotation = { 90, 180, 0 },
                    scale = { 0.95, 0.95, 1 },
                },
                {
                    name = "Joker Objective Slot",
                    url = "https://steamusercontent-a.akamaihd.net/ugc/2502404390141304458/384109878E6ED179516CE638CE97167E12698A54/",
                    position = symmetric(-11, decalHeight, -8.15),
                    rotation = { 90, 180, 0 },
                    scale = { 0.95, 0.95, 1 },
                },
            })
        end

        for _, slot in ipairs(agentSlots) do
            table.insert(decals, {
                name = "Generic Slot",
                url = "https://steamusercontent-a.akamaihd.net/ugc/2502404390141334991/8C42D07B62ACE707EF3C206E9DFEA483821ECFD8/",
                position = offsetToLocalDecal(slot),
                rotation = { 90, 0, 0 },
                scale = { 0.5, 0.5, 1 },
            })
        end

        for _, slot in ipairs(spySlots) do
            table.insert(decals, {
                name = "Generic Slot",
                url = "https://steamusercontent-a.akamaihd.net/ugc/2502404390141334991/8C42D07B62ACE707EF3C206E9DFEA483821ECFD8/",
                position = offsetToLocalDecal(slot),
                rotation = { 90, 0, 0 },
                scale = { 0.25, 0.25, 1 },
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

        if Helper.isElementOf(color, { "Green", "Yellow", "Blue", "Red" }) then
            for _, slot in ipairs(sardaukarCommanderSkillSlots) do
                table.insert(decals, {
                    name = "Sardaukar Slot",
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

---
---@param position Vector
function PlayBoard:moveAt(position, isRelative, horizontalHandLayout)
    local toBeMoved = Helper.shallowCopy(self.content)
    local offset = isRelative and position or (position - toBeMoved.board.getPosition())

    local exceptions = {
        "swordmaster",
        "scoreMarker",
        "forceMarker",
        "tleilaxToken",
        "tleilaxTokenInitalPosition",
        "researchToken",
        "researchTokenInitalPosition",
        "freighter",
    }
    for _, exception in ipairs(exceptions) do
        toBeMoved[exception] = nil
    end

    toBeMoved.drawDeck = self.content.drawDeckZone and Helper.getDeckOrCard(self.content.drawDeckZone) or nil
    toBeMoved.discard = self.content.discardZone and Helper.getDeckOrCard(self.content.discardZone) or nil

    local smooth = false
    local move = smooth and "setPositionSmooth" or "setPosition"

    Helper.forEachRecursively(toBeMoved, function (name, object)
        assert(tostring(object) ~= "null", name)
        if name ~= "supportBoard" then
            if object.getPosition then
                object[move](object.getPosition() + offset)
            elseif object.x then
                object.x = object.x + offset.x
                object.y = object.y + offset.y
                object.z = object.z + offset.z
            end
        end
    end)

    local parks = {
        self.agentCardPark,
        self.revealCardPark,
        self.agentPark,
        self.spyPark,
        self.dreadnoughtPark,
        self.supplyPark,
        self.techPark,
        self.sardaukarCommanderSkillPark,
        self.sardaukarCommanderPark,
        self.scorePark,
    }

    for _, park in ipairs(parks) do
        Park.move(park, offset)

        for _, zone in ipairs(Park.getZones(park)) do
            zone[move](zone.getPosition() + offset)
        end
        if park.anchor then
            park.anchor[move](park.anchor.getPosition() + offset)
        end
    end

    -- Not reliable, only done for the old vertical layout which doesn't have alternate zones.
    if not horizontalHandLayout then
        PlayBoard.tq = PlayBoard.tq or Helper.createTemporalQueue(0.25)
        PlayBoard.tq.submit(function ()
            local handTransform = Player[self.color].getHandTransform()
            handTransform.position = handTransform.position + offset
            if horizontalHandLayout then
                handTransform.position = handTransform.position + self:_newSymmetricBoardPosition(-15, 0, 11.95)
                handTransform.scale = Vector(25, 5, 4)
                handTransform.rotation = Vector(0, 0, 0)
            end
            Player[self.color].setHandTransform(handTransform)
        end)
    end
end

---
function PlayBoard:_pruneHandsInExcess(color, horizontalHandLayout)
    local rgba = Color.fromString(color)
    rgba.a = 0
    for _, hand in ipairs(Hands.getHands()) do
        if hand.getColorTint() == rgba then
            local horizontal = math.abs(hand.getRotation().y) < 1
            if horizontal ~= horizontalHandLayout then
                hand.destruct()
            end
        end
    end
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
            leaderName = playBoard.leader and playBoard.leader.name or nil,
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
    return self:createTransientZone("offseted", Vector(-10.4, 0.4, 1.5), Vector(2.3, 1, 3.3))
end

---@return Zone
function PlayBoard:_createLeaderZone()
    return self:createTransientZone("offseted", Vector(-6.4, 0.4, 1), Vector(5, 1, 3.5))
end

---@return Zone
function PlayBoard:_createDiscardZone()
    return self:createTransientZone("offseted", Vector(-2.4, 0.4, 1.5), Vector(2.3, 1, 3.3))
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
                assert(subState.leaderName)
                if playBoard.opponent == "rival" then
                    playBoard.leader = Rival.newRival(subState.leaderName)
                else
                    playBoard.leader = Leader.newLeader(subState.leaderName)
                    if Commander.isCommander(color) then
                        playBoard.leader = Commander.newCommander(color, playBoard.leader)
                    end
                end
                if playBoard.leader.transientSetUp then
                    playBoard.leader.transientSetUp(color, state.settings)
                end
            end
        end)

        playBoard.content.firstPlayerInitialPosition = Helper.toVector(subState.initialPositions.firstPlayerInitialPosition)

        if Commander.isCommander(color) then
            playBoard:_createAllySelector()
        end
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

    if not Commander.isCommander(color) then
        local decalToSnap = {
            ["MuadDib Objective Slot"] = "MuadDibObjectiveToken",
            ["Crysknife Objective Slot"] = "CrysknifeObjectiveToken",
            ["Ornithopter Objective Slot"] = "OrnithopterObjectiveToken",
            ["Joker Objective Slot"] = "JokerObjectiveToken",
        }

        for _, decal in pairs(playBoard.content.board.getDecals()) do
            local tag = decalToSnap[decal.name]
            if tag then
                table.insert(snapPoints, {
                    position = decal.position,
                    rotation_snap = true,
                    tags = { tag }
                })
            end
        end
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
    playBoard.spyPark = playBoard:_createSpyPark()
    if not Commander.isCommander(color) then
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
        playBoard:_cleanUp(false, not settings.ix, not settings.immortality, not settings.bloodlines, settings.numberOfPlayers ~= 6)

        PlayBoard:_pruneHandsInExcess(playBoard.color, settings.numberOfPlayers <= 4 and settings.horizontalHandLayout)

        if settings.numberOfPlayers <= 4 then
            local offsets
            if settings.horizontalHandLayout then
                offsets = {
                    Green = Vector(0, 0, -7.25),
                    Yellow = Vector(0, 0, 7.25),
                    Red = Vector(0, 0, -7.25),
                    Blue = Vector(0, 0, 7.25),
                }
            else
                offsets = {
                    Green = Vector(0, 0, -9.25),
                    Yellow = Vector(0, 0, 9.25),
                    Red = Vector(0, 0, -9.25),
                    Blue = Vector(0, 0, 9.25),
                }
            end
            local offset = offsets[color]
            if offset then
                playBoard:moveAt(offset, true, settings.horizontalHandLayout)
            end
        end

        if activeOpponents[color] then
            if activeOpponents[color] ~= "rival" then
                playBoard.opponent = "human"
                if color == "White" then
                    Deck.generateMuadDibStarterDeck(playBoard.content.drawDeckZone).doAfter(Helper.shuffleDeck)
                elseif color == "Purple" then
                    Deck.generateEmperorStarterDeck(playBoard.content.drawDeckZone).doAfter(Helper.shuffleDeck)
                else
                    Deck.generateStarterDeck(playBoard.content.drawDeckZone, settings).doAfter(Helper.shuffleDeck)
                    Deck.generateStarterDiscard(playBoard.content.discardZone, settings)
                end
            else
                playBoard.opponent = "rival"
                if settings.immortality and not Commander.isCommander(color) then
                    playBoard.content.researchToken.destruct()
                    playBoard.content.researchToken = nil
                end
            end

            if not Commander.isCommander(color) then
                if settings.numberOfPlayers ~= 4 or settings.goTo11 then
                    playBoard.content.fourPlayerVictoryToken.destruct()
                    playBoard.content.fourPlayerVictoryToken = nil
                end
                if settings.numberOfPlayers == 6 then
                    if Commander.isTeamShaddam(color) then
                        playBoard.content.makerHook.destruct()
                        playBoard.content.makerHook = nil
                    end
                    table.insert(sequentialActions, Helper.partialApply(ScoreBoard.gainVictoryPoint, color, "ally", 1))
                end
                if settings.numberOfPlayers == 6 or not settings.horizontalHandLayout then
                    -- Support boards are hidden rectangles used to elevate the hand zones in 4 players configuration.
                    -- Two of them are partially blocking mouse picking on the bottom Commander selector buttons in 6
                    -- players configuration however.
                    playBoard.content.supportBoard.destruct()
                    playBoard.content.supportBoard = nil
                end
            else
                table.insert(sequentialActions, 1, Helper.partialApply(ScoreBoard.gainVictoryPoint, color, "commander", 4))
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

            if TurnControl.getCurrentRound() == 1 then
                for _, playBoard in pairs(PlayBoard._getPlayBoards(true)) do
                    -- Force button creation now that we have all the information to create the Sandworm button.
                    playBoard:_createButtons()
                end
            end

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
                playBoard.leader.doSetUp(color, settings)
                playBoard.leader.prepare(color, settings)
                if Commander.isCommander(color) then
                    playBoard:_createAllySelector()
                end
            end
        elseif phase == "endgame" then
            MainBoard.getFirstPlayerMarker().destruct()
        end

        for color, playBoard in pairs(PlayBoard._getPlayBoards(true)) do
            -- When informal, the combat phase ends automatically, leaving the players in limbo until they press the "reclaim rewards" button.
            if false and phase == "combat" and not Combat.isFormalCombatPhaseEnabled() then
                playBoard:_updateInstructionLabel(color, I18N("combatInstruction"))
            else
                playBoard:_updateInstructionLabel(color, nil)
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

        if phase == "playerTurns" and Commander.isCommander(color) then
            local sides = {}
            for _, agent in ipairs(Park.getObjects(PlayBoard.getAgentPark(color))) do
                if agent.hasTag("left") then
                    sides.left = true
                end
                if agent.hasTag("right") then
                    sides.right = true
                end
            end
            if #Helper.getKeys(sides) == 1 then
                Commander.setActivatedAlly(color, sides.left and Commander.getLeftSeatedAlly(color) or Commander.getRightSeatedAlly(color))
            else
                Commander.setActivatedAlly(color, nil)
            end
        end
        for otherColor, otherPlayBoard in pairs(PlayBoard._getPlayBoards(true)) do
            local instruction = (playBoard.leader or Action).instruct(phase, color == otherColor) or "-"
            otherPlayBoard:_updateInstructionLabel(otherColor, instruction)
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
        playBoard.content.completedContractBag.createButton({
            click_function = Helper.registerGlobalCallback(),
            label = "",
            position = Vector(0, 0.05, 2),
            width = 0,
            height = 0,
            font_size = 800,
            font_color = "White"
        })
        PlayBoard._updateBagCounts(playBoard.content.completedContractBag)

        if settings.bloodlines and not Commander.isCommander(color) and not PlayBoard.isRival(color) then
            SardaukarCommander.createSardaukarCommanderRecruitmentButton(playBoard.content.sardaukarMarker, false, PlayBoard.withLeader(function (leader, playerColor, _)
                if playerColor == color then
                    leader.recruitSardaukarCommander(color)
                else
                    Dialog.broadcastToColor(I18N('noTouch'), color, "Purple")
                end
            end))
        end

        local instructionTextAnchorPosition = playBoard.content.board.getPosition() + playBoard:_newSymmetricBoardPosition(8, -0.5, 3.5)
        Helper.createTransientAnchor("instructionTextAnchor", instructionTextAnchorPosition).doAfter(function (anchor)
            playBoard.instructionTextAnchor = anchor
        end)
    end
end

---@param color PlayerColor
---@param instruction? string
function PlayBoard:_updateInstructionLabel(color, instruction)
    assert(self.instructionTextAnchor, color .. " has no instruction text anchor!")
    assert(not Helper.isNil(self.instructionTextAnchor), color .. " has no more instruction text anchor!")
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
    for color, playBoard in pairs(PlayBoard._getPlayBoards(true)) do
        playBoard:_updateInstructionLabel(color, I18N("combatInstruction"))
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
            self:trash(card)
        elseif Helper.isElementOf(cardName, {"seekAllies", "emperorSeekAllies", "muadDibSeekAllies", "powerPlay", "treachery", "dangerousRhetoric"}) then
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
            else
                -- As stated in the rule, reset swords after a reveal for non-combatants.
                if  not refreshing
                    and TurnControl.getPlayerCount() == 6
                    and not Commander.isCommander(otherColor)
                    and playBoard.revealed
                    and not Combat.isInCombat(otherColor)
                then
                    playBoard.strength:set(0)
                    playBoard.strength:clearBaseValueContributions()
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
                if not Commander.isCommander(color) or Commander.getActivatedAlly(color) then
                    -- Replace the source by the leader.
                    action(leader, color, ...)
                else
                    Dialog.broadcastToColor(I18N('noAlly'), color, "Purple")
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
    local hasAnySandworm = Combat.hasAnySandworm(color)
    ConflictCard.collectReward(color, conflictName, rank, hasAnySandworm).doAfter(function ()
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
    local origin = self:_generateAbsolutePosition("symmetric", Vector(-3.5, 0.2, -3.2))
    local spacing = PlayBoard.isLeft(self.color) and -2.5 or 2.5
    local slots = Park.createMatrixOfSlots(origin, Vector(6, 1, 1), Vector(spacing, 0, 0))
    local park = Park.createCommonPark({ "Imperium", "Intrigue", "Navigation" }, slots, Vector(2.4, 0.5, 3.2), Vector(0, 180, 0), true)
    park.tagUnion = true
    park.smooth = false
    return park
end

---@return Park
function PlayBoard:_createRevealCardPark()
    local origin = self:_generateAbsolutePosition("symmetric", Vector(0.25, 0.2, -7.3))
    local spacing = PlayBoard.isLeft(self.color) and -2.5 or 2.5
    local slots = Park.createMatrixOfSlots(origin, Vector(9, 1, 1), Vector(spacing, 0, 0))
    local zone = Park.createTransientBoundingZone(0, Vector(2.4, 0.5, 3.2), slots)
    local park = Park.createCommonPark({ "Imperium", "Intrigue", "Navigation" }, slots, nil, Vector(0, 180, 0), true, { zone })
    park.tagUnion = true
    park.smooth = false
    return park
end

---@return Park
function PlayBoard:_createAgentPark()
    local origin = self:_generateAbsolutePosition("symmetric", Vector(-6.4, 0, 6.6))
    local spacing = PlayBoard.isLeft(self.color) and -1.5 or 1.5
    local slots = Park.createMatrixOfSlots(origin, Vector(3, 1, 1), Vector(spacing, 0, 0))
    local park = Park.createCommonPark({ "Agent", self.color }, slots, Vector(0.75, 3, 0.75))
    park.locked = true
    return park
end

---@return Park
function PlayBoard:_createSpyPark()
    local origin = self:_generateAbsolutePosition("symmetric", Vector(-6.4, 0.33, 5.8))
    local spacing = PlayBoard.isLeft(self.color) and -1.5 or 1.5
    local slots = Park.createMatrixOfSlots(origin, Vector(3, 1, 1), Vector(spacing, 0, 0))
    local park = Park.createCommonPark({ "Spy", self.color }, slots, Vector(0.75, 1, 0.75))
    return park
end

---@return Park
function PlayBoard:_createDreadnoughtPark()
    local origin = self:_generateAbsolutePosition("symmetric", Vector(0.5, 0, 4))
    local spacing = PlayBoard.isLeft(self.color) and -2 or 2
    local slots = Park.createMatrixOfSlots(origin, Vector(2, 1, 1), Vector(spacing, 0, 0))
    return Park.createCommonPark({ "Dreadnought", self.color }, slots, Vector(1, 2, 1))
end

---@return Park
function PlayBoard:_createSupplyPark()
    local origin = self:_generateAbsolutePosition("symmetric", Vector(0.5, 0.18, 2))
    local diamond = Park.createDiamondOfSlots(origin, 4, 0.5, 315)
    local supplyZone = Park.createTransientBoundingZone(45, Vector(0.75, 0.75, 0.75), diamond.allSlots)
    local park = Park.createCommonPark({ "Troop", self.color }, diamond.slots, nil, Vector(0, -45, 0), true, { supplyZone })
    --park.tagUnion = true
    park.smooth = true
    return park
end

---@param layerCount integer
function PlayBoard:_createSardaukarCommanderSkillPark(layerCount)
    local origin = self:_generateAbsolutePosition("symmetric", Vector(5.5, 0, 0.2))
    local spacing = PlayBoard.isLeft(self.color) and -1.8 or 1.8
    local slots = Park.createMatrixOfSlots(origin, Vector(3, layerCount or 1, 1), Vector(spacing, 0.5, 0))
    return Park.createCommonPark({ "SardaukarCommanderSkill" }, slots, Vector(2, 1, 2.5))
end

---@param layerCount integer
function PlayBoard:_createSardaukarCommanderPark(layerCount)
    local origin = self:_generateAbsolutePosition("symmetric", Vector(5.5, 0.25, 0.2))
    local spacing = PlayBoard.isLeft(self.color) and -1.75 or 1.75
    local slots = Park.createMatrixOfSlots(origin, Vector(3, layerCount or 1, 1), Vector(spacing, 0.5, 0))
    return Park.createCommonPark({ "SardaukarCommander", self.color }, slots, Vector(0.75, 0.75, 0.75))
end

---@param layerCount integer
function PlayBoard:_createTechPark(layerCount)
    local origin = self:_generateAbsolutePosition("symmetric", Vector(5.5, 0, 4.4))
    local spacing = PlayBoard.isLeft(self.color) and -3 or 3
    local slots = Park.createMatrixOfSlots(origin, Vector(2, layerCount or 1, 3), Vector(spacing, 0.5, 2))
    local park = Park.createCommonPark({ "Tech", "Contract" }, slots, Vector(3, 1, 2))
    park.tagUnion = true
    return park
end

function PlayBoard:_createPlayerScorePark()
    local origin = self:_generateAbsolutePosition("symmetric", Vector(-3.72, 0, 8.10))
    local width = 15
    local spacing = (PlayBoard.isLeft(self.color) and -1 or 1) * 1.071
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
        White = 3,
        Purple = 3.5,
    }

    self.scorePositions = {}
    for i = 0, 14 do
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
    self:_cleanUp(true, true, true, true, true, true)
    PlayBoard.playBoards[self.color] = nil
end

---@param base boolean
---@param ix boolean
---@param immortality boolean
---@param bloodlines boolean
---@param teamMode boolean
---@param full? boolean
function PlayBoard:_cleanUp(base, ix, immortality, bloodlines, teamMode, full)
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
        collect("completedContractBag")

        collect("agents")
        collect("swordmaster")
        collect("swordmasterBonusToken")
        collect("spies")

        if not Commander.isCommander(self.color) then
            collect("controlMarkerBag")
            collect("forceMarker")
            collect("fourPlayerVictoryToken")
            collect("troops")
            collect("makerHook")
        end
    end

    if teamMode then
        collect("swordmasterBonusToken")
    end

    if ix then
        if not Commander.isCommander(self.color) then
            collect("dreadnoughts")
            collect("freighter")
        end
    end

    if immortality then
        if not Commander.isCommander(self.color) then
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

        if Commander.isCommander(self.color) then
            collect("board")
            collect("colorband")

            local parkNames = {
                "agentCardPark",
                "revealCardPark",
                "agentPark",
                "spyPark",
                "techPark",
                "sardaukarCommanderSkillPark",
                "scorePark",
            }

            for _, parkName in ipairs(parkNames) do
                local park = self[parkName]
                self[parkName] = nil
                if park then
                    table.insert(toBeRemoved, park.anchor)
                    for _, zone in ipairs(Park.getZones(park)) do
                        table.insert(toBeRemoved, zone)
                    end
                end
            end

            local handTransform = Player[self.color].getHandTransform()
            if handTransform then
                for _, hand in ipairs(Hands.getHands()) do
                    if hand.getPosition() == handTransform.position then
                        hand.destruct()
                        break
                    end
                end
            end

            -- Only remove the commander's influence tokens since they are on their own boards.
            for _, object in ipairs(getObjects()) do
                if object.hasTag("InfluenceTokens") and object.hasTag(self.color) then
                    table.insert(toBeRemoved, object)
                end
            end
        end
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

    if TurnControl.getCurrentRound() > 0 then

        board.createButton({
            click_function = self:_createExclusiveCallback(function (_, _, altClick)
                if PlayBoard.hasMakerHook(self.color) then
                    Combat.callSandworm(self.color, altClick and -1 or 1)
                else
                    Combat.callSandworm(self.color, altClick and -1 or 1)
                end
            end),
            label = I18N("sandwormButton"),
            position = self:_newSymmetricBoardPosition(-2.4, 0.2, 4),
            rotation = self:_newSymmetricBoardRotation(0, 0, 0),
            width = 700,
            height = 400,
            font_size = 120,
            color = self.color,
            font_color = fontColor
        })

        if not PlayBoard.hasHighCouncilSeat(self.color) then
            Helper.clearButtons(self.content.councilToken)
            if PlayBoard.isHuman(self.color) then
                self.content.councilToken.createButton({
                    click_function = self:_createExclusiveCallback(function ()
                        Dialog.showConfirmDialog(
                            self.color,
                            I18N("takeHighCouncilSeatByForceConfirm"),
                            function ()
                                local leader = PlayBoard.getLeader(self.color)
                                leader.takeHighCouncilSeat(self.color)
                            end)
                    end),
                    position = Vector(0, 0, 0),
                    tooltip = I18N("takeHighCouncilSeatByForce"),
                    width = 1500,
                    height = 1500,
                    color = { 0, 0, 0, 0 },
                })
            end
        end
    end

    if PlayBoard.isHuman(self.color) then
        board.createButton({
            click_function = self:_createExclusiveCallback(function ()
                self:drawCards(1)
            end),
            label = I18N("drawOneCardButton"),
            position = self:_newOffsetedBoardPosition(-10.4, 0.2, -0.6),
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
            position = self:_newOffsetedBoardPosition(-2.4, 0.2, -0.6),
            width = 1400,
            height = 250,
            font_size = 150,
            color = self.color,
            font_color = fontColor
        })

        board.createButton({
            click_function = Helper.registerGlobalCallback(),
            label = I18N("agentTurn"),
            position = self:_newSymmetricBoardPosition(-11.3, 0.2, -3.3),
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
            position = self:_newSymmetricBoardPosition(-11.3, 0.2, -7.3),
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

function PlayBoard.onObjectDrop(color, object)
    local objectiveTags = {
        "MuadDibObjectiveToken",
        "CrysknifeObjectiveToken",
        "OrnithopterObjectiveToken",
        --"JokerObjectiveToken",
    }
    for _, objectiveTag in ipairs(objectiveTags) do
        if object.hasTag(objectiveTag) then
            PlayBoard._convertObjectiveTokenPairsIntoVictoryPoints(object)
            break
        end
    end
end

function PlayBoard._convertObjectiveTokenPairsIntoVictoryPoints(object)
    if PlayBoard.conversionCooldown then
        return
    else
        PlayBoard.conversionCooldown = true
        Helper.onceFramesPassed(1).doAfter(function ()
            PlayBoard.conversionCooldown = false
        end)
    end

    local tagToName = {
        MuadDibObjectiveToken = "muadDibVictoryPoint",
        OrnithopterObjectiveToken = "ornithopterVictoryPoint",
        CrysknifeObjectiveToken = "crysknifeVictoryPoint",
        --JokerObjectiveToken = "jokerVictoryPoint",
    }
    local objectiveTag = object.getTags()[1]
    if tagToName[objectiveTag] then
        for color, playBoard in pairs(PlayBoard.playBoards) do
            local board = playBoard.content.board
            for _, snapPoint in ipairs(board.getSnapPoints()) do
                if Helper.isElementOf(objectiveTag, snapPoint.tags) then
                    local absoluteSnapPointPosition = board.positionToWorld(snapPoint.position)
                    local d = Vector.sqrDistance(object.getPosition(), absoluteSnapPointPosition)
                    if d < 1.5 then
                        local leader = PlayBoard.getLeader(color)
                        if leader then
                            local hitTokens = PlayBoard.collectObjectiveTokens(absoluteSnapPointPosition, objectiveTag)
                            while #hitTokens >= 2 do
                                for _ = 1, 2 do
                                    hitTokens[1].destruct()
                                    table.remove(hitTokens, 1)
                                end
                                leader.gainVictoryPoint(color, tagToName[objectiveTag], 1)
                            end
                        end
                        break
                    end
                end
            end
        end
    end
end

function PlayBoard.collectObjectiveTokens(position, objectiveTag)
    local radius = 0.5
    local hits = Physics.cast({
        origin = position,
        direction = Vector(0, 1, 0),
        type = 2,
        size = Vector(radius, radius, radius),
        max_distance = 2,
    })

    return Helper.filter(Helper.mapValues(hits, Helper.field("hit_object")), function (hitObject)
        return hitObject.hasTag(objectiveTag)
    end)
end

--- The global event handler 'onObjectEnterContainer' automatically calls every
--- '<Module>.onObjectEnterContainer' function thanks to 'Module.registerModuleRedirections'
--- (see asyncOnLoad in Global.-1.lua).
function PlayBoard.onObjectEnterContainer(container, object)
    PlayBoard._updateBagCounts(container)

    if object.type == "Card" then
        for color, playBoard in pairs(PlayBoard._getPlayBoards()) do
            if container == playBoard.content.trash then
                -- The dump function actually accepts any number of arguments and is able to format each of them.
                -- Since everything is a string here, simply concatenating things produces the same output (save the additional spaces).
                --Helper.dump("The card '" .. Helper.getID(object) .. "'has been trashed in the " .. color .. "trash.")
                Reserve.redirectUntrashableCards(container, object)
            end
        end
    end
end

function PlayBoard.onObjectLeaveContainer(container, object)
    PlayBoard._updateBagCounts(container)
end

function PlayBoard.getOpenContracts(color)
    local contracts = {}
    local playBoard = PlayBoard.getPlayBoard(color)
    for _, contractTile in ipairs(Park.getObjects(playBoard.techPark)) do
        if Types.isContract(contractTile) and not contractTile.is_face_down then
            table.insert(contracts, contractTile)
        end
    end
    return contracts
end

function PlayBoard._updateBagCounts(container)
    for _, playBoard in pairs(PlayBoard.playBoards) do
        if playBoard.opponent ~= "rival" then
            if container == playBoard.content.completedContractBag then
                local count = #Helper.filter(container.getObjects(), function (element)
                    return element.tags and Helper.isElementOf("Contract", element.tags)
                end)
                playBoard.content.completedContractBag.editButton({
                    index = 0,
                    label = tostring(count),
                })
            end
        end
    end
end

function PlayBoard.getCompletedContractCount(color)
    local playBoard = PlayBoard.getPlayBoard(color)
    if playBoard.opponent ~= "rival" then
        local objets = playBoard.content.completedContractBag.getObjects()
        return #Helper.filter(objets, function (element)
            return element.tags and Helper.isElementOf("Contract", element.tags)
        end)
    end
    return 0
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
    local origin = PlayBoard.getPlayBoard(self.color):_newSymmetricBoardPosition(-2, 0.2, -6.5)

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
                We leave the cards with a choice (not an option) in the player's hand to simplify
                things and make clear to the player that the card must be manually revealed.
            ]]
            local choiceOfferingCards = {
                "beneGesseritSister",
                "undercoverAsset",
                "desertPower",
            }
            if brutal then
                choiceOfferingCards = Helper.concatTables(choiceOfferingCards, {
                    "deliveryAgreement",
                    "priorityContracts",
                })
                if not PlayBoard.hasHighCouncilSeat(self.color) then
                    table.insert(choiceOfferingCards, "corrinthCity")
                end
            end
            return not Helper.isElementOf(Helper.getID(card), choiceOfferingCards)
        else
            return false
        end
    end

    local revealedCards = Helper.filter(Player[self.color].getHandObjects(), properCard)
    local alreadyRevealedCards = Helper.filter(Park.getObjects(self.revealCardPark), properCard)
    local allRevealedCards = Helper.concatTables(revealedCards, alreadyRevealedCards)

    self:_refreshStaticContributions(false)

    local imperiumCardContributions = ImperiumCard.evaluateReveal(self.color, playedCards, allRevealedCards)
    --Helper.dump("imperiumCardContributions:", imperiumCardContributions)

    local correctedImperiumCardContributions = {}
    for _, resourceName in ipairs({"persuasion", "strength"}) do
        correctedImperiumCardContributions[resourceName] = (imperiumCardContributions[resourceName] or 0) + self[resourceName]:getBaseValue()
    end
    --Helper.dump("correctedImperiumCardContributions:", correctedImperiumCardContributions)

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
        local assemblyHall = MainBoard.hasAgentInSpace("assemblyHall", self.color)
        self.persuasion:setBaseValueContribution("assemblyHall", assemblyHall and 1 or 0)
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

function PlayBoard:_createAllySelector()
    assert(Commander.isCommander(self.color))

    local p = self.content.board.getPosition() + self:_newSymmetricBoardPosition(0.5, 0, -3)
    Helper.createTransientAnchor(self.color .. "AllySelector", p).doAfter(function (anchor)

        Helper.createAbsoluteButtonWithRoundness(anchor, 1, {
            click_function = Helper.registerGlobalCallback(),
            label = I18N("activatedAlly"),
            position = anchor.getPosition() + Vector(0, 0.2, 0),
            width = 0,
            height = 0,
            font_size = 120,
            font_color = {0, 0, 0, 100},
            color = {0, 0, 0, 0}
        })

        for i, allyColor in ipairs(Commander.getAllies(self.color)) do
            Helper.createAbsoluteButtonWithRoundness(anchor, 1, {
                click_function = self:_createExclusiveCallback(function ()
                    Commander.setActivatedAlly(self.color, allyColor)
                end),
                label = Helper.chopName(PlayBoard.getLeaderName(allyColor), 2),
                position = anchor.getPosition() + Vector(0, 0.2, (i - 1.5) * 1.5),
                width = 1600,
                height = 300,
                font_size = 150,
                font_color = PlayBoard._getTextColor(allyColor),
                color = Color.fromString("Grey")
            })
        end

        local onAllyChange = function (color, allyColor)
            if color == self.color then
                for i, otherAllyColor in ipairs(Commander.getAllies(self.color)) do
                    anchor.editButton({
                        index = i,
                        color = Color.fromString(otherAllyColor == allyColor and allyColor or "Grey"),
                    })
                end
            end
        end

        Helper.registerEventListener("selectAlly", onAllyChange)
        onAllyChange(self.color, Commander.getActivatedAlly(self.color))
    end)
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
        assert(leaderCard.hasTag("RivalLeader"))
        playBoard.leader = Rival.newRival(Helper.getID(leaderCard))
    else
        assert(leaderCard.hasTag("Leader"))
        playBoard.leader = Leader.newLeader(Helper.getID(leaderCard))
        if Commander.isCommander(color) then
            playBoard.leader = Commander.newCommander(color, playBoard.leader)
        end
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
    -- Ignore the tag here, as some leaders temporarily set their zone tags.
    for _, object in ipairs(leaderZone.getObjects(true)) do
        if object.hasTag("Leader") or object.hasTag("RivalLeader") then
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
function PlayBoard.getSpyPark(color)
    return PlayBoard.getPlayBoard(color).spyPark
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
    if true then
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
---@param contractTile string
---@return boolean
function PlayBoard.grantContractTile(color, contractTile)
    return Park.putObject(contractTile, PlayBoard.getPlayBoard(color).techPark)
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
function PlayBoard.hasMakerHook(color)
    local content = PlayBoard.getContent(color)
    if content.makerHook then
        local d = content.makerHook.getPosition():distance(Combat.getMakerHookPosition(color))
        return d < 1
    else
        return false
    end
end

---@param color PlayerColor
---@return boolean
function PlayBoard.canTakeMakerHook(color)
    local normalOrAllyColor = color
    if TurnControl.getPlayerCount() == 6 and Commander.isCommander(color) then
        normalOrAllyColor = Commander.getActivatedAlly(color)
    end

    return not PlayBoard.hasMakerHook(normalOrAllyColor) and (TurnControl.getPlayerCount() < 6 or Commander.isTeamMuadDib(normalOrAllyColor))
end

---@param color PlayerColor
---@return boolean
function PlayBoard.takeMakerHook(color)
    if PlayBoard.canTakeMakerHook(color) then
        local normalOrAllyColor = color
        if TurnControl.getPlayerCount() == 6 and Commander.isCommander(color) then
            normalOrAllyColor = Commander.getActivatedAlly(color)
        end

        local makerHook = PlayBoard._getMakerHook(normalOrAllyColor)
        makerHook.setPositionSmooth(Combat.getMakerHookPosition(normalOrAllyColor))
        Helper.onceMotionless(makerHook).doAfter(function ()
            Helper.noPlay(makerHook)
            Helper.emitEvent("makerHookTaken", normalOrAllyColor)
            PlayBoard.getPlayBoard(normalOrAllyColor):_createButtons()

            if TurnControl.getPlayerCount() == 6 then
                assert(Commander.isTeamMuadDib(normalOrAllyColor))
                local otherAllyColor = Commander.getOtherAlly(normalOrAllyColor)
                if otherAllyColor then
                    assert(otherAllyColor ~= normalOrAllyColor)
                    if not PlayBoard.hasMakerHook(otherAllyColor) then
                        local leader = PlayBoard.getLeader(otherAllyColor)
                        leader.takeMakerHook(otherAllyColor)
                    end
                end                    
            end
        end)
        return true
    end
    return false
end

---@param color PlayerColor
---@return boolean
function PlayBoard.hasSwordmaster(color)
    local content = PlayBoard.getContent(color)
    if TurnControl.getPlayerCount() == 6 then
        return content.swordmasterBonusToken
            and content.swordmasterBonusToken.getPosition():distance(PlayBoard.swordmasterBonusPositions[color]) < 1
    else
        return PlayBoard.isInside(color, content.swordmaster)
            or MainBoard.isInside(content.swordmaster)
            or TechMarket.isInside(content.swordmaster)
    end
end

---@param color PlayerColor
---@return boolean
function PlayBoard.recruitSwordmaster(color)
    local playBoard = PlayBoard.getPlayBoard(color)
    if playBoard.content.swordmaster and Park.putObject(playBoard.content.swordmaster, PlayBoard.getAgentPark(color)) then
        if TurnControl.getPlayerCount() == 6 then
            playBoard.content.swordmasterBonusToken.setPosition(PlayBoard.swordmasterBonusPositions[color] + Vector(0, -0.15, 0))
            Helper.noPhysics(playBoard.content.swordmasterBonusToken)
            playBoard.strength:setBaseValueContribution("swordmaster", 2)
        end
        Helper.emitEvent("swordmasterTaken", color)
        return true
    else
        return false
    end
end

---@param color PlayerColor
function PlayBoard.destroySwordmaster(color)
    local playBoard = PlayBoard.getPlayBoard(color)
    if playBoard.content.swordmaster then
        --playBoard:trash(playBoard.content.swordmaster)
        playBoard.content.swordmaster.destruct()
        playBoard.content.swordmaster = nil
    end
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
---@return Object
function PlayBoard._getMakerHook(color)
    local content = PlayBoard.getContent(color)
    return content.makerHook
end

---
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
---@param zone Zone
---@return Continuation
function PlayBoard.giveObjectiveCardFromZone(color, zone)
    assert(Types.isPlayerColor(color))
    local content = PlayBoard.getContent(color)
    assert(content)
    local firstSlot = Park.findEmptySlots(PlayBoard.getAgentCardPark(color))[1]
    local continuation = Helper.moveCardFromZone(zone, firstSlot + Vector(0, 1, 0), nil, false, true)
    continuation.doAfter(function (card)
        local cardName = Helper.getID(card)
        assert(cardName)
        local cardToObjective = {
            muadDibFirstPlayer = "muadDib",
            muadDib4to6p = "muadDib",
            crysknife4to6p = "crysknife",
            crysknife = "crysknife",
            ornithopter1to3p = "ornithopter",
        }
        local objective = cardToObjective[cardName]
        assert(objective, cardName)
        Combat.gainObjective(color, objective)

        Helper.onceTimeElapsed(2).doAfter(function ()
            PlayBoard.getPlayBoard(color):trash(card)
        end)
    end)
    return continuation
end

---@param color PlayerColor
---@param objective string
---@param ignoreExisting? boolean
function PlayBoard.gainObjective(color, objective, ignoreExisting)
    return Combat.gainObjective(color, objective, ignoreExisting).doAfter(PlayBoard._convertObjectiveTokenPairsIntoVictoryPoints)
end

---@param color PlayerColor
---@param objective string
---@return Vector?
function PlayBoard.getObjectiveStackPosition(color, objective)
    local tag = Helper.concatAsPascalCase(objective, "ObjectiveToken")
    local board = PlayBoard.getPlayBoard(color).content.board
    for _, snapPoint in ipairs(board.getSnapPoints()) do
        if Helper.isElementOf(tag, snapPoint.tags) then
            return board.positionToWorld(snapPoint.position)
        end
    end
    error(tag)
    return nil
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

---@param color PlayerColor
---@return boolean
function PlayBoard.isTop(color)
    return color == "Red" or color == "Green"
end

---@param color PlayerColor
---@return boolean
function PlayBoard.isBottom(color)
    return color == "Blue" or color == "Yellow"
end

--- Relative to the board, not a commander.
---@param color PlayerColor
---@return boolean
function PlayBoard.isLeft(color)
    return color == "Red" or color == "White" or color == "Blue"
end

--- Relative to the board, not a commander.
---@param color PlayerColor
---@return boolean
function PlayBoard.isRight(color)
    return color == "Green" or color == "Purple" or color == "Yellow"
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
