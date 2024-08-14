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
--local IntrigueCard = Module.lazyRequire("IntrigueCard")
local ConflictCard = Module.lazyRequire("ConflictCard")
local ScoreBoard = Module.lazyRequire("ScoreBoard")

local PlayBoard = Helper.createClass(nil, {
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
            dreadnoughtInitialPositions = {
                Helper.getHardcodedPositionFromGUID('1a3c82', -23.7000427, 2.199222, 19.3999958),
                Helper.getHardcodedPositionFromGUID('a8f306', -25.3000546, 2.199222, 19.4)
            },
            agents = {"7751c8", "afa978"},
            agentInitialPositions = {
                Helper.getHardcodedPositionFromGUID('7751c8', -19.15, 2.19722152, 21.7),
                Helper.getHardcodedPositionFromGUID('afa978', -17.65, 2.19722152, 21.7)
            },
            swordmaster = "ed3490",
            swordmasterBonusToken = "db91e0",
            spies = {
                "fdecae",
                "84d545",
                "e7a4ef",
            },
            spyInitialPositions = {
                Helper.getHardcodedPositionFromGUID('fdecae', -19.15, 2.52385259, 20.95),
                Helper.getHardcodedPositionFromGUID('84d545', -17.65, 2.52385259, 20.95),
                Helper.getHardcodedPositionFromGUID('e7a4ef', -16.15, 2.52385259, 20.95)
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
            trash = "ea3fe1",
            completedContractBag = "ce13d1",
            tleilaxToken = "2bfc39",
            tleilaxTokenInitalPosition = Helper.getHardcodedPositionFromGUID('2bfc39', 0.5429316, 1.882152, 22.0543556),
            researchToken = "39e0f3",
            researchTokenInitalPosition = Helper.getHardcodedPositionFromGUID('39e0f3', 0.369857281, 1.88465214, 18.2348137),
            freighter = "e9096d",
            firstPlayerMarkerZone = "781a03",
            firstPlayerInitialPosition = Helper.getHardcodedPositionFromGUID('781a03', -13.6, 2.7, 20.89) + Vector(0, -0.4, 0),
            endTurnButton = "895594",
            atomicsToken = "d5ff47",
            makerHook = "2a8414",
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
            dreadnoughtInitialPositions = {
                Helper.getHardcodedPositionFromGUID('82789e', -23.7000332, 2.199222, -19.0),
                Helper.getHardcodedPositionFromGUID('60f208', -25.3000374, 2.19922233, -19.0000019)
            },
            agents = {"64d013", "106d8b"},
            agentInitialPositions = {
                Helper.getHardcodedPositionFromGUID('64d013', -19.15, 2.19722152, -16.7),
                Helper.getHardcodedPositionFromGUID('106d8b', -17.65, 2.19722152, -16.7)
            },
            swordmaster = "a78ad7",
            swordmasterBonusToken = "28ec54",
            spies = {
                "7d7083",
                "e07c5c",
                "272ba1",
            },
            spyInitialPositions = {
                Helper.getHardcodedPositionFromGUID('7d7083', -19.15, 2.52385259, -17.45),
                Helper.getHardcodedPositionFromGUID('e07c5c', -17.65, 2.52385259, -17.45),
                Helper.getHardcodedPositionFromGUID('272ba1', -16.15, 2.52385259, -17.45)
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
            trash = "52a539",
            completedContractBag = "f67091",
            tleilaxToken = "96607f",
            tleilaxTokenInitalPosition = Helper.getHardcodedPositionFromGUID('96607f', 0.542550147, 1.884652, 22.75358),
            researchToken = "292658",
            researchTokenInitalPosition = Helper.getHardcodedPositionFromGUID('292658', 0.370049357, 1.882152, 18.9373875),
            freighter = "68e424",
            firstPlayerMarkerZone = "311c04",
            firstPlayerInitialPosition = Helper.getHardcodedPositionFromGUID('311c04', -13.6, 2.7, -17.49) + Vector(0, -0.4, 0),
            endTurnButton = "9eeccd",
            atomicsToken = "700023",
            makerHook = "7011f2",
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
            dreadnoughtInitialPositions = {
                Helper.getHardcodedPositionFromGUID('a15087', 23.6931, 2.19653678, 19.3967171),
                Helper.getHardcodedPositionFromGUID('734250', 25.2996445, 2.19653654, 19.3993263)
            },
            agents = {"bceb0e", "ee412b"},
            agentInitialPositions = {
                Helper.getHardcodedPositionFromGUID('bceb0e', 16.1, 2.194536, 21.7),
                Helper.getHardcodedPositionFromGUID('ee412b', 17.599762, 2.194536, 21.7)
            },
            swordmaster = "fb1629",
            swordmasterBonusToken = "f5bfa8",
            spies = {
                "ed1748",
                "795934",
                "8ca6ca",
            },
            spyInitialPositions = {
                Helper.getHardcodedPositionFromGUID('ed1748', 16.1, 2.521167, 20.95),
                Helper.getHardcodedPositionFromGUID('795934', 17.6, 2.521167, 20.95),
                Helper.getHardcodedPositionFromGUID('8ca6ca', 19.1, 2.521167, 20.95)
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
            trash = "4060b5",
            completedContractBag = "e48304",
            tleilaxToken = "63d39f",
            tleilaxTokenInitalPosition = Helper.getHardcodedPositionFromGUID('63d39f', 1.2458272, 1.8846519, 22.04864),
            researchToken = "658b17",
            researchTokenInitalPosition = Helper.getHardcodedPositionFromGUID('658b17', 0.3700056, 1.882152, 20.3406372),
            freighter = "34281d",
            firstPlayerMarkerZone = "ce7c68",
            firstPlayerInitialPosition = Helper.getHardcodedPositionFromGUID('ce7c68', 13.6, 2.7, 20.89) + Vector(0, -0.4, 0),
            endTurnButton = "96aa58",
            atomicsToken = "0a22ec",
            makerHook = "0492e6",
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
            dreadnoughtInitialPositions = {
                Helper.getHardcodedPositionFromGUID('5469fb', 23.6999512, 2.19653726, -19.0),
                Helper.getHardcodedPositionFromGUID('71a414', 25.29995, 2.19653654, -19.0000019)
            },
            agents = {"5068c8", "67b476"},
            agentInitialPositions = {
                Helper.getHardcodedPositionFromGUID('5068c8', 16.1, 2.194536, -16.7),
                Helper.getHardcodedPositionFromGUID('67b476', 17.6, 2.194536, -16.7)
            },
            swordmaster = "635c49",
            swordmasterBonusToken = "e160d9",
            spies = {
                "94ffec",
                "f59e0c",
                "4e66c4",
            },
            spyInitialPositions = {
                Helper.getHardcodedPositionFromGUID('94ffec', 16.1, 2.521167, -17.45),
                Helper.getHardcodedPositionFromGUID('f59e0c', 17.6, 2.521167, -17.45),
                Helper.getHardcodedPositionFromGUID('4e66c4', 19.1, 2.521167, -17.45)
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
            trash = "7d1e07",
            completedContractBag = "04d334",
            tleilaxToken = "d20bcf",
            tleilaxTokenInitalPosition = Helper.getHardcodedPositionFromGUID('d20bcf', 1.24723184, 1.884652, 22.7536983),
            researchToken = "8988cf",
            researchTokenInitalPosition = Helper.getHardcodedPositionFromGUID('8988cf', 0.370085269, 1.88215208, 19.6398125),
            freighter = "8fa76f",
            firstPlayerMarkerZone = "ba0c20",
            firstPlayerInitialPosition = Helper.getHardcodedPositionFromGUID('ba0c20', 13.6, 2.7, -17.49) + Vector(0, -0.4, 0),
            endTurnButton = "3d1b90",
            atomicsToken = "7e10a9",
            makerHook = "a07d90",
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
            agentInitialPositions = {
                Helper.getHardcodedPositionFromGUID('b9a4d2', -19.15, 2.19472766, 2.49999976),
                Helper.getHardcodedPositionFromGUID('2c1095', -17.6500015, 2.19472766, 2.49999976)
            },
            swordmaster = "c2a908",
            swordmasterBonusToken = "a456bf",
            spies = {
                "96bbc4",
                "040248",
                "bddedd",
            },
            spyInitialPositions = {
                Helper.getHardcodedPositionFromGUID('96bbc4', -19.15, 2.52385283, 1.75000143),
                Helper.getHardcodedPositionFromGUID('040248', -17.65, 2.52385354, 1.74999988),
                Helper.getHardcodedPositionFromGUID('bddedd', -16.15, 2.523853, 1.74999964)
            },
            councilToken = "ded786",
            scoreMarker = "201011",
            scoreMarkerInitialPosition = Helper.getHardcodedPositionFromGUID('201011', 10.3917294, 2.58932447, -14.09231),
            trash = "a4f139",
            completedContractBag = "98c18d",
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
            agentInitialPositions = {
                Helper.getHardcodedPositionFromGUID('10ca63', 16.1, 2.192042, 2.5),
                Helper.getHardcodedPositionFromGUID('fb1dd6', 17.6, 2.19204187, 2.5)
            },
            swordmaster = "a695f9",
            swordmasterBonusToken = "aa9a39",
            spies = {
                "e5b04d",
                "407c67",
                "a3d964",
            },
            spyInitialPositions = {
                Helper.getHardcodedPositionFromGUID('e5b04d', 16.1, 2.521167, 1.749999),
                Helper.getHardcodedPositionFromGUID('407c67', 17.6, 2.521168, 1.74999988),
                Helper.getHardcodedPositionFromGUID('a3d964', 19.1, 2.521168, 1.75000155)
            },
            councilToken = "8c6ba7",
            scoreMarker = "2ccf7f",
            scoreMarkerInitialPosition = Helper.getHardcodedPositionFromGUID('2ccf7f', 10.3914042, 2.789329, -14.0921068),
            trash = "556139",
            completedContractBag = "49dedf",
            firstPlayerMarkerZone = "7a8ea9",
            firstPlayerInitialPosition = Helper.getHardcodedPositionFromGUID('7a8ea9', 13.58, 2.7, 1.7) + Vector(0, -0.4, 0),
            endTurnButton = "eded7c",
            atomicsToken = "0a3ccb",
        },
    },
    playBoards = {},
    -- TODO Use the snappoints (swordmasterBonusTokenXxx) instead.
    swordmasterBonusPositions = {
        Red = Vector(-0.29, 1.79, -7.77),
        Blue = Vector(-0.29, 1.79, -12.35),
        Green = Vector(6.96, 1.79, -7.77),
        Yellow = Vector(6.96, 1.79, -12.35),
        White = Vector(3.33, 1.79, -12.35),
        Purple = Vector(3.33, 1.79, -7.77),
    }
})

---
function PlayBoard.rebuild()
    for _, color in ipairs({ "Green", "Yellow", "Blue", "Red", "White", "Purple" }) do
        local content = Helper.resolveGUIDs(true, PlayBoard.unresolvedContentByColor[color])

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
            return colorSwitch(Vector(12.75 + x, y, z), Vector(x, y, z))
        end

        local symmetric2 = function (x, y, z)
            local r = symmetric(-x, y, -z)
            return Vector(-r.x, r.y, -r.z)
        end
        local offseted2 = function (x, y, z)
            local r = offseted(-x, y, -z)
            return Vector(-r.x, r.y, -r.z)
        end

        local c1 = 0.5

        local objectGroups = {
            {
                board = Vector(0, 0, 0),
                colorband = Vector(0, 0, -0.55),
                fourPlayerVictoryToken = symmetric(-11.2, 0, 8.1),
            },
            {
                --[[
                spice = offseted(-8.4, 0, 4.5),
                solari = offseted(-4.4, 0, 4.5),
                water = offseted(-6.4, 0, 4),
                ]]
                spice = offseted(-8.4, 0, 4),
                solari = offseted(-6.4, 0, 4.5),
                water = offseted(-4.4, 0, 4),
                agents = {
                    origin = offseted(-7.9, 0, 6.5),
                    width = 3,
                    height = 1,
                    xOffset = Vector(1.5, 0, 0),
                },
                spies = {
                    origin = offseted(-7.9, 0, 5.75),
                    width = 3,
                    height = 1,
                    xOffset = Vector(1.5, 0, 0),
                },
            },
            {
                persuasion = symmetric(c1, 0, 0.2),
                strength = symmetric(c1, 0, 6),
                dreadnoughts = {
                    origin = symmetric(c1-0.8, 0, 4.2),
                    width = 2,
                    height = 1,
                    xOffset = symmetric(1.6, 0, 0),
                    yOffset = Vector(0, 0, 0),
                },
                councilToken = symmetric(1.35, 0, -0.6),
                controlMarkerBag = symmetric(c1, 0, 4),
                troops = {
                    origin = symmetric(c1-0.5, 0, 1.8),
                    width = 3,
                    height = 4,
                    xOffset = symmetric(0.5, 0, 0),
                    yOffset = Vector(0, 0, 0.5),
                },
            },
            {
                trash = symmetric(10, 0, 1),
                endTurnButton = symmetric(-2.4, 0, 6),
                atomicsToken = symmetric(10, 0, 3.4),
            },
        }

        local c0 = 1
        local positions = {
            Green = Vector(24, 2, 14.2 + c0),
            Yellow = Vector(24, 2, -24.2 + c0),
            Red = Vector(-24, 2, 14.2 + c0),
            Blue = Vector(-24, 2, -24.2 + c0),
            White = Vector(-24, 2, -5 + c0),
            Purple = Vector(24, 2, -5 + c0),
        }
        local position = positions[color]

        local offset = position - content.board.getPosition()

        for _, objects in ipairs(objectGroups) do
            for name, localOffset in pairs(objects) do
                local object = content[name]
                if object then
                    if type(object) == "table" then
                        assert(type(localOffset) == "table", name)
                        for j, item in ipairs(object) do
                            local newPosition = position + localOffset.origin
                            local x = (j - 1) % localOffset.width
                            local y = math.floor((j - 1) / localOffset.width)
                            newPosition = newPosition + localOffset.xOffset:copy():scale(x) + (localOffset.yOffset and localOffset.yOffset:copy():scale(y) or Vector(0, 0, 0))
                            newPosition.y = (item.getPosition() + offset).y + localOffset.origin.y
                            item.setPosition(newPosition)
                        end
                    else
                        local newPosition = position + localOffset
                        newPosition.y = (object.getPosition() + offset).y + localOffset.y
                        object.setPosition(newPosition)
                        object.setLock(true)
                    end
                end
            end
        end

        local handTransform = Player[color].getHandTransform()
        handTransform.position = handTransform.position + offset
        Player[color].setHandTransform(handTransform)

        local layoutGrid = function (width, height, f)
            local n = width * height
            for i = 1, n do
                local x = (i - 1) % width
                local y = math.floor((i - 1) / width)
                f(x, y)
            end
        end

        -- Coordinates in the object space (rotated by 180°).
        local decals = {
            {
                name = "Scoreboard",
                url = colorSwitch(
                    "https://steamusercontent-a.akamaihd.net/ugc/2042984690511948114/BD4C6DB374A73A3A1586E84DD94DD2459EB51782/",
                    "https://steamusercontent-a.akamaihd.net/ugc/2042984690511949009/00AEA6A9B03D893B1BF82EFF392448FD52B8C70E/"),
                position = symmetric2(1.4, 0.2, -8.1),
                rotation = { 90, 180, 0 },
                scale = { 21.56, 1.1, 1.1 },
            },
            {
                name = "First Player Token Slot",
                url = "https://steamusercontent-a.akamaihd.net/ugc/2042984592862631937/B2176FBF3640DC02A6840C8E0FB162057724DE41/",
                position = symmetric2(10.4, 0.2, -5.7),
                rotation = { 90, 180, 0 },
                scale = { 2, 2, 2 },
            },
            {
                name = "Deck Slot",
                url = "https://steamusercontent-a.akamaihd.net/ugc/2042984592862630696/9973F87497827C194B979D7410D0DD47E46305FA/",
                position = offseted2(10.4, 0.2, -1.5),
                rotation = { 90, 180, 0 },
                scale = { 2.4, 3.4, 3.4 },
            },
            {
                name = "Discard Slot",
                url = "https://steamusercontent-a.akamaihd.net/ugc/2042984592862631187/76205DFA6ECBC5F9C6B38BE95F42E6B5468B5999/",
                position = offseted2(2.4, 0.2, -1.5),
                rotation = { 90, 180, 0 },
                scale = { 2.4, 3.4, 3.4 },
            },
            {
                name = "Leader Slot",
                url = "https://steamusercontent-a.akamaihd.net/ugc/2042984592862632410/7882B2E68FF7767C67EE5C63C9D7CF17B405A5C3/",
                position = offseted2(6.4, 0.2, -1),
                rotation = { 90, 180, 0 },
                scale = { 5, 3.5, 3.5 },
            },
            {
                name = "MuadDib Objective Slot",
                url = "https://steamusercontent-a.akamaihd.net/ugc/2488878371134017159/52C4F6DEBC5F101B6663B833F1964BB9034A7C75/",
                position = symmetric2(-3.4, 0.2, 0),
                rotation = { 90, 180, 0 },
                scale = { 1.1, 1.1, 1.1 },
            },
            {
                name = "Crysknife Objective Slot",
                url = "https://steamusercontent-a.akamaihd.net/ugc/2488878371134016948/D455406509BD5D1C4387C102CBACC5BFB56FC59E/",
                position = symmetric2(-4.8, 0.2, 0),
                rotation = { 90, 180, 0 },
                scale = { 1.1, 1.1, 1.1 },
            },
            {
                name = "Ornithopter Objective Slot",
                url = "https://steamusercontent-a.akamaihd.net/ugc/2488878371134017299/E4E692FE0EF6AF7B51B5A31DAC5D0D7DC7859655/",
                position = symmetric2(-6.2, 0.2, 0),
                rotation = { 90, 180, 0 },
                scale = { 1.1, 1.1, 1.1 },
            },
            {
                name = "Joker Objective Slot",
                url = "https://steamusercontent-a.akamaihd.net/ugc/2285080980001125361/384109878E6ED179516CE638CE97167E12698A54/",
                position = symmetric2(-7.6, 0.2, 0),
                rotation = { 90, 180, 0 },
                scale = { 1, 1, 1 },
            },
        }

        layoutGrid(3, 1, function (x, y)
            table.insert(decals, {
                name = "Generic Slot",
                url = "https://steamusercontent-a.akamaihd.net/ugc/2042984592862621000/8C42D07B62ACE707EF3C206E9DFEA483821ECFD8/",
                position = offseted2(4.9 + x * 1.5, 0.2, -6.5),
                rotation = { 90, 0, 0 },
                scale = { 0.5, 0.5, 0.5 },
            })
        end)

        layoutGrid(3, 1, function (x, y)
            table.insert(decals,  {
                name = "Generic Slot",
                url = "https://steamusercontent-a.akamaihd.net/ugc/2042984592862621000/8C42D07B62ACE707EF3C206E9DFEA483821ECFD8/",
                position = offseted2(4.9 + x * 1.5, 0.2, -5.75),
                rotation = { 90, 0, 0 },
                scale = { 0.25, 0.25, 0.25 },
            })
        end)

        layoutGrid(2, 3, function (x, y)
            table.insert(decals, {
                name = "Tech Tile Slot",
                url = "https://steamusercontent-a.akamaihd.net/ugc/2042984592862632706/6A948CDC20774D0D4E5EA0EFF3E0D2C23F30FCC1/",
                position = symmetric2(-4 -3 * x, 0.2, -2 -2 * y),
                rotation = { 90, 0, 0 },
                scale = { 2.6, 1.8, 1.8 },
            })
        end)

        if content.dreadnoughts then
            layoutGrid(2, 1, function (x, y)
                table.insert(decals, {
                    name = "Generic Slot",
                    url = "https://steamusercontent-a.akamaihd.net/ugc/2042984592862621000/8C42D07B62ACE707EF3C206E9DFEA483821ECFD8/",
                    position = symmetric2(-1.3 + x * 1.6, 0.2, -4.2),
                    rotation = { 90, 0, 0 },
                    scale = { 0.5, 0.5, 0.5 },
                })
            end)
        end

        if false then
            layoutGrid(9, 2, function (x, y)
                table.insert(decals, {
                    name = "Intrigium",
                    url = "https://steamusercontent-a.akamaihd.net/ugc/2120690798716490121/DB0A29253195530F3A39D5AC737922A5B2338795/",
                    position = symmetric2(9.5 -2.5 * x, 0.2, 3.2 + 4 * y),
                    rotation = { 90, 180, 0 },
                    scale = { 2, 2, 2 },
                })
            end)
        else
            layoutGrid(6, 1, function (x, y)
                table.insert(decals, {
                    name = "Intrigium",
                    url = "https://steamusercontent-a.akamaihd.net/ugc/2120690798716490121/DB0A29253195530F3A39D5AC737922A5B2338795/",
                    position = symmetric2(9.5 -2.5 * x, 0.2, 3.2 + 4 * y),
                    rotation = { 90, 180, 0 },
                    scale = { 2, 2, 2 },
                })
            end)
        end

        content.board.setDecals(decals)
    end
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
        self.scorePark,
    }

    for _, park in ipairs(parks) do
        for _, slot in ipairs(park.slots) do
            slot.x = slot.x + offset.x
            slot.y = slot.y + offset.y
            slot.z = slot.z + offset.z
        end

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
            initialPositions = {
                dreadnoughtInitialPositions = playBoard.content.dreadnoughtInitialPositions,
                agentInitialPositions = playBoard.content.agentInitialPositions,
                spyInitialPositions = playBoard.content.spyInitialPositions,
                tleilaxTokenInitalPosition = playBoard.content.tleilaxTokenInitalPosition,
                researchTokenInitalPosition = playBoard.content.researchTokenInitalPosition,
                firstPlayerInitialPosition = playBoard.content.firstPlayerInitialPosition,
            },
        }
    end)
end

---
function PlayBoard.generatePosition(playBoard, operation, position)

    local colorSwitch = function (left, right)
        if PlayBoard.isLeft(playBoard.color) then
            return left
        else
            return right
        end
    end

    local p = playBoard.content.board.getPosition()
    if not operation then
        p = p + position
    elseif operation == "symmetric" then
        p = p + colorSwitch(Vector(-position.x, position.y, position.z), position)
    elseif operation == "offseted" then
        p = p + colorSwitch(Vector(12.75 + position.x, position.y, position.z), position)
    else
        assert("Unknow operation: " .. tostring(operation))
    end

    return p
end

---
function PlayBoard.createTransientZone(playBoard, operation, position, scale)
    local zone = spawnObject({
        type = 'ScriptingTrigger',
        position = PlayBoard.generatePosition(playBoard, operation, position),
        scale = { scale.x, scale.y, scale.z },
    })
    Helper.markAsTransient(zone)
    return zone
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

    playBoard.content.drawDeckZone = PlayBoard.createTransientZone(playBoard, "offseted", Vector(-10.4, 0.4, 1.5), Vector(2.3, 1, 3.3))
    playBoard.content.leaderZone = PlayBoard.createTransientZone(playBoard, "offseted", Vector(-6.4, 0.4, 1), Vector(5, 1, 3.5))
    playBoard.content.discardZone = PlayBoard.createTransientZone(playBoard, "offseted", Vector(-2.4, 0.4, 1.5), Vector(2.3, 1, 3.3))

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
                    playBoard.leader = Hagal.newRival(subState.leader)
                else
                    playBoard.leader = Leader.newLeader(subState.leader)
                    if Commander.isCommander(color) then
                        playBoard.leader = Commander.newCommander(color, playBoard.leader)
                    end
                end
                if playBoard.leader.transientSetUp then
                    playBoard.leader.transientSetUp(color, state.settings)
                end
            end
        end)

        if not Commander.isCommander(color) then
            playBoard.content.dreadnoughtInitialPositions = Helper.mapValues(subState.initialPositions.dreadnoughtInitialPositions, Helper.toVector)
        end
        playBoard.content.agentInitialPositions = Helper.mapValues(subState.initialPositions.agentInitialPositions, Helper.toVector)
        playBoard.content.spyInitialPositions = Helper.mapValues(subState.initialPositions.spyInitialPositions, Helper.toVector)
        playBoard.content.tleilaxTokenInitalPosition = Helper.toVector(subState.initialPositions.tleilaxTokenInitalPosition)
        playBoard.content.researchTokenInitalPosition = Helper.toVector(subState.initialPositions.researchTokenInitalPosition)
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
        table.insert(snapPoints, { position = playBoard:_newSymmetricBoardPosition(-3.4, 0.2, 0), rotation_snap = true, tags = { "MuadDibObjectiveToken" } })
        table.insert(snapPoints, { position = playBoard:_newSymmetricBoardPosition(-4.8, 0.2, 0), rotation_snap = true, tags = { "CrysknifeObjectiveToken" } })
        table.insert(snapPoints, { position = playBoard:_newSymmetricBoardPosition(-6.2, 0.2, 0), rotation_snap = true, tags = { "OrnithopterObjectiveToken" } })
        table.insert(snapPoints, { position = playBoard:_newSymmetricBoardPosition(-7.6, 0.2, 0), rotation_snap = true, tags = { "JokerObjectiveToken" } })
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
    playBoard.agentPark = playBoard:_createAgentPark(subState == nil)
    playBoard.spyPark = playBoard:_createSpyPark(subState == nil)
    if not Commander.isCommander(color) then
        playBoard.dreadnoughtPark = playBoard:_createDreadnoughtPark(subState == nil)
        playBoard.supplyPark = playBoard:_createSupplyPark(subState == nil)
    end
    playBoard:_generatePlayerScoreboardPositions()
    playBoard.scorePark = playBoard:_createPlayerScorePark()
    playBoard.techPark = playBoard:_createTechPark()

    Helper.registerEventListener("locale", function ()
        playBoard:_createButtons()
    end)

    return playBoard
end

---
function PlayBoard.setUp(settings, activeOpponents)
    local sequentialActions = {}

    for color, playBoard in pairs(PlayBoard.playBoards) do
        playBoard:_cleanUp(false, not settings.riseOfIx, not settings.immortality, settings.numberOfPlayers ~= 6)

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
            playBoard.opponent = activeOpponents[color]
            if playBoard.opponent ~= "rival" then
                playBoard.opponent = "human"
                if color == "White" then
                    Deck.generateMuadDibStarterDeck(playBoard.content.drawDeckZone).doAfter(Helper.shuffleDeck)
                elseif color == "Purple" then
                    Deck.generateEmperorStarterDeck(playBoard.content.drawDeckZone).doAfter(Helper.shuffleDeck)
                else
                    Deck.generateStarterDeck(playBoard.content.drawDeckZone, settings.immortality, settings.epicMode).doAfter(Helper.shuffleDeck)
                    Deck.generateStarterDiscard(playBoard.content.discardZone, settings.immortality, settings.epicMode)
                end
            else
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

            if TurnControl.getCurrentRound() == 1 then
                for _, playBoard in pairs(PlayBoard._getPlayBoards(true)) do
                    -- Force button creation now that we have all the information to create the Sandworm button.
                    playBoard:_createButtons()
                end
            end

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
                playBoard.leader.setUp(color, settings)
                playBoard.leader.prepare(color, settings)
                if Commander.isCommander(color) then
                    playBoard:_createAllySelector()
                end
            end
        elseif phase == "endgame" then
            MainBoard.getFirstPlayerMarker().destruct()
        end
        PlayBoard._setActivePlayer(nil, nil)
    end)

    Helper.registerEventListener("playerTurn", function (phase, color, refreshing)
        local playBoard = PlayBoard.getPlayBoard(color)

        if PlayBoard.isHuman(color) and not refreshing then
            -- FIXME To naive, won't work for multiple agents in a single turn (weirding way).
            playBoard.alreadyPlayedCards = Helper.filter(Park.getObjects(playBoard.agentCardPark), function (card)
                return Types.isImperiumCard(card) or Types.isIntrigueCard(card)
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
                    -- FIXME Find some way to push this into Leader.
                    elseif cardName == "signetRing" and PlayBoard.getLeader(color).name == "rhomburVernius" then
                        TechMarket.registerAcquireTechOption(color, "rhomburVerniusTechBuyOption", "spice", 0)
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

    for _, playBoard in pairs(PlayBoard._getPlayBoards()) do
        playBoard.content.completedContractBag.createButton({
            click_function = Helper.registerGlobalCallback(),
            label = "",
            position = Vector(0, 0.1, 1),
            width = 0,
            height = 0,
            font_size = 400,
            font_color = "White"
        })
        PlayBoard._updateBagCounts(playBoard.content.completedContractBag)
    end
end

---
function PlayBoard:_recall()
    local minimicFilm = PlayBoard.hasTech(self.color, "minimicFilm")
    local restrictedOrdnance = PlayBoard.hasTech(self.color, "restrictedOrdnance")
    local councilSeat = PlayBoard.hasHighCouncilSeat(self.color)
    local swordmasterBonus = TurnControl.getPlayerCount() == 6 and PlayBoard.hasSwordmaster(self.color)

    self.revealed = false
    self.persuasion:set((councilSeat and 2 or 0) + (minimicFilm and 1 or 0))
    self.strength:set(((restrictedOrdnance and councilSeat) and 4 or 0) + (swordmasterBonus and 2 or 0))

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
            card.setPosition(Reserve.foldspaceSlotZone.getPosition())
        elseif Helper.isElementOf(cardName, {"seekAllies", "emperorSeekAllies", "muadDibSeekAllies", "powerPlay", "treachery"}) then
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
    Helper.forEach(playedIntrigueCards, function (i, card)
        Intrigue.discard(card)
    end)

    -- Flip any used tech.
    for _, techTile in ipairs(Park.getObjects(self.techPark)) do
        if Types.isTech(techTile) and techTile.is_face_down then
            techTile.flip()
        end
    end
end

---
function PlayBoard._setActivePlayer(phase, color, refreshing)
    local indexedColors = { "Green", "Yellow", "Blue", "Red", "White", "Purple" }
    for i, otherColor in ipairs(indexedColors) do
        local playBoard = PlayBoard.playBoards[otherColor]
        if playBoard then
            local effectIndex = 0 -- black index (no color actually)
            if otherColor == color then
                effectIndex = i
                if playBoard.opponent == "rival" and not refreshing then
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
                end
            end
            playBoard.content.colorband.setColorTint(effectIndex > 0 and indexedColors[effectIndex] or "Black")
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
        font_color = Helper.concatTables(PlayBoard._getTextColor(self.color), { 100 })
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
        font_color = Helper.concatTables(PlayBoard._getTextColor(self.color), { 100 })
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
        accepted = false
    elseif phase == 'roundStart' then
        accepted = false
    elseif phase == 'playerTurns' then
        accepted = PlayBoard.couldSendAgentOrReveal(color)
    elseif phase == 'combat' then
        if Combat.isInCombat(color) and Combat.isFormalCombatPhaseEnabled() then
            accepted = PlayBoard.combatPassCountdown > 0 and not PlayBoard.isRival(color) and #PlayBoard._getPotentialCombatIntrigues(color) > 0
            PlayBoard.combatPassCountdown = PlayBoard.combatPassCountdown - 1
        end
    elseif phase == 'combatEnd' then
        if playBoard.lastPhase ~= phase then
            accepted = true
            -- Rival collect their reward their own way.
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

---
function PlayBoard.withLeader(action)
    return function (source, color, ...)
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
    end
end

---
function PlayBoard.collectReward(color)
    local conflictName = Combat.getCurrentConflictName()
    local rank = Combat.getRank(color).value
    local hasSandworms = Combat.hasSandworms(color)
    ConflictCard.collectReward(color, conflictName, rank, hasSandworms).doAfter(function ()
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
    end)
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
function PlayBoard:_createAgentCardPark()
    local origin = PlayBoard.generatePosition(self, "symmetric", Vector(-9.5, 0.2, -3.2))
    local step = PlayBoard.isLeft(self.color) and -2.5 or 2.5

    local slots = {}
    for i = 0, 5 do
        table.insert(slots, origin + Vector(i * step, 0, 0))
    end

    local park = Park.createCommonPark({ "Imperium", "Intrigue" }, slots, Vector(2.4, 0.5, 3.2), Vector(0, 180, 0), true)
    park.tagUnion = true
    park.smooth = false
    return park
end

---
function PlayBoard:_createRevealCardPark()
    local origin = PlayBoard.generatePosition(self, "symmetric", Vector(-9.5, 0.2, -3.2))
    local step = PlayBoard.isLeft(self.color) and -2.5 or 2.5

    local bottomSlots = {}
    for i = 0, 8 do
        table.insert(bottomSlots, origin + Vector(i * step, 0, -4))
    end
    local bottomZone = Park.createTransientBoundingZone(0, Vector(2.4, 0.5, 3.2), bottomSlots)
    local topSlots = {}
    for i = 8, 6, -1 do
        table.insert(topSlots, origin + Vector(i * step, 0, 0))
    end
    local topZone = Park.createTransientBoundingZone(0, Vector(2.4, 0.5, 3.2), topSlots)

    local slots = Helper.concatTables(bottomSlots, topSlots)

    local park = Park.createCommonPark({ "Imperium", "Intrigue" }, slots, nil, Vector(0, 180, 0), true, { bottomZone, topZone })
    park.tagUnion = true
    park.smooth = false
    return park
end

---
function PlayBoard:_createAgentPark(firstTime)
    -- Extrapolate the other positions (for the swordmaster)
    -- from the positions of the two existing agents.
    assert(#self.content.agentInitialPositions == 2)
    -- Copy does matter (since move update the positions).
    local p1 = self.content.agentInitialPositions[1]:copy()
    local p2 = self.content.agentInitialPositions[2]:copy()
    local slots = {
        p1,
        p2,
        p2 + (p2 - p1),
    }

    local park = Park.createCommonPark({ "Agent" }, slots, Vector(0.75, 3, 0.75))
    if firstTime then
        for i, agent in ipairs(self.content.agents) do
            agent.setPosition(slots[i])
        end
    end
    return park
end

---
function PlayBoard:_createSpyPark(firstTime)
    assert(#self.content.spyInitialPositions == 3)
    local slots = Helper.mapValues(self.content.spyInitialPositions, function (slot)
        return slot:copy()
    end)
    local park = Park.createCommonPark({ "Spy" }, slots, Vector(0.75, 1, 0.75))
    if firstTime then
        for i, spy in ipairs(self.content.spies) do
            spy.setPosition(slots[i])
        end
    end
    return park
end

---
function PlayBoard:_createDreadnoughtPark(firstTime)
    assert(#self.content.dreadnoughtInitialPositions == 2)
    local slots = Helper.mapValues(self.content.dreadnoughtInitialPositions, function (slot)
        return slot:copy()
    end)
    local park = Park.createCommonPark({ "Dreadnought" }, slots, Vector(1, 2, 1))
    if firstTime then
        for i, dreadnought in ipairs(self.content.dreadnoughts) do
            dreadnought.setPosition(self.content.dreadnoughtInitialPositions[i])
        end
    end
    return park
end

---
function PlayBoard:_createSupplyPark(firstTime)
    local origin = PlayBoard.generatePosition(self, "symmetric", Vector(0.5, 0, 2))

    local allSlots = {}
    local slots = {}
    for i = 1, 4 do
        for j = 1, 4 do
            local x = (i - 2.5) * 0.5
            local z = (j - 2.5) * 0.5
            local slot = Vector(x, 0.37, z):rotateOver('y', -45) + origin
            table.insert(allSlots, slot)
            if i > 2 or j > 2 then
                table.insert(slots, slot)
            end
        end
    end

    local supplyZone = Park.createTransientBoundingZone(45, Vector(0.5, 0.5, 0.5), allSlots)

    if firstTime then
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
function PlayBoard:_createTechPark()
    local origin = PlayBoard.generatePosition(self, "symmetric", Vector(-0.45, 0, 3.6))
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
                local slot = Vector(x, 0.5 * h - 0.3, z) + origin
                table.insert(slots, slot)
            end
        end
    end
    local park = Park.createCommonPark({ "Tech", "Contract" }, slots, Vector(3, 1, 2), nil)
    park.tagUnion = true
    return park
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

---
function PlayBoard:_createPlayerScorePark()
    local origin = self:_newSymmetricBoardPosition(-11.2, 0.41, -8.10) + self.content.board.getPosition()

    local direction = 1
    if PlayBoard.isLeft(self.color) then
        direction = -1
    end

    local slots = {}
    for i = 1, 18 do
        slots[i] = Vector(
            origin.x + (i - 1) * 1.075 * direction,
            origin.y,
            origin.z)
    end

    return Park.createCommonPark({ "VictoryPointToken" }, slots, Vector(1, 0.2, 1), Vector(0, 180, 0))
end

---
function PlayBoard:_updatePlayerScore()
    if self.content.scoreMarker then
        local rectifiedScore = self:getScore()
        rectifiedScore = rectifiedScore > 13 and rectifiedScore - 10 or rectifiedScore
        local scoreMarker = self.content.scoreMarker
        scoreMarker.setLock(false)
        scoreMarker.setPositionSmooth(self.scorePositions[rectifiedScore])
    end
end

---
function PlayBoard.onObjectEnterZone(zone, object)
    for color, playBoard in pairs(PlayBoard.playBoards) do
        if playBoard.opponent and playBoard.scorePark then
            if Helper.isElementOf(zone, Park.getZones(playBoard.scorePark)) then
                if Types.isVictoryPointToken(object) then
                    playBoard:_updatePlayerScore()
                end
            end
        end
    end
end

---
function PlayBoard.onObjectLeaveZone(zone, object)
    for _, playBoard in pairs(PlayBoard.playBoards) do
        if playBoard.opponent and playBoard.scorePark then
            if Helper.isElementOf(zone, Park.getZones(playBoard.scorePark)) then
                if Types.isVictoryPointToken(object) then
                    playBoard:_updatePlayerScore()
                end
            end
        end
    end
end

---
function PlayBoard:_tearDown()
    self:_cleanUp(true, true, true, true, true)
    PlayBoard.playBoards[self.color] = nil
end

---
function PlayBoard:_cleanUp(base, ix, immortality, teamMode, full)
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
function PlayBoard._getTextColor(color)
    local fontColor = { 0.9, 0.9, 0.9 }
    if color == "Green" or color == "Yellow" or color == "White" then
        fontColor = { 0.1, 0.1, 0.1 }
    end
    return fontColor
end

---
function PlayBoard:_createButtons()
    self:_clearButtons()

    local chromae = {
        Red = "Red",
        Blue = "Blue",
        Green = "Green",
        Yellow = "Yellow",
        White = "White",
        Purple = "Purple",
    }
    local chroma = chromae[self.color]

    local fontColor = PlayBoard._getTextColor(self.color)

    local board = self.content.board

    if TurnControl.getCurrentRound() > 0 then

        board.createButton({
            click_function = self:_createExclusiveCallback(function (_, _, altClick)
                if PlayBoard.hasMakerHook(self.color) then
                    Combat.callSandworm(self.color, altClick and -1 or 1)
                else
                    -- TODO Confirmation popup?
                    Combat.callSandworm(self.color, altClick and -1 or 1)
                end
            end),
            label = I18N("sandwormButton"),
            position = self:_newSymmetricBoardPosition(-2.4, 0.2, 4),
            rotation = self:_newSymmetricBoardRotation(0, 0, 0),
            width = 700,
            height = 400,
            font_size = 120,
            color = chroma,
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
            color = chroma,
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
            color = chroma,
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
            font_color = chroma
        })

        board.createButton({
            click_function = self:_createExclusiveCallback(function ()
                if PlayBoard.isHuman(self.color) then
                    self:onRevealHand()
                end
            end),
            label = I18N("revealHandButton"),
            position = self:_newSymmetricBoardPosition(-11.3, 0.2, -7.3),
            rotation = self:_newSymmetricBoardRotation(0, -90, 0),
            width = 1600,
            height = 320,
            font_size = 280,
            color = chroma,
            font_color = fontColor
        })

        self:_createNukeButton()
    end
end

---
function PlayBoard.onObjectDrop(color, object)
    local objectiveTags = {
        "MuadDibObjectiveToken",
        "CrysknifeObjectiveToken",
        "OrnithopterObjectiveToken",
        "JokerObjectiveToken",
    }
    for _, objectiveTag in ipairs(objectiveTags) do
        if object.hasTag(objectiveTag) then
            PlayBoard._convertObjectiveTokenPairsIntoVictoryPoints(object)
            break
        end
    end
end

---
function PlayBoard._convertObjectiveTokenPairsIntoVictoryPoints(object)
    local tagToName = {
        MuadDibObjectiveToken = "muadDibVictoryPoint",
        OrnithopterObjectiveToken = "ornithopterVictoryPoint",
        CrysknifeObjectiveToken = "crysknifeVictoryPoint",
        JokerObjectiveToken = "jokerVictoryPoint",
    }
    local objectiveTag = object.getTags()[1]
    for color, playBoard in pairs(PlayBoard.playBoards) do
        local board = playBoard.content.board
        for _, snapPoint in ipairs(board.getSnapPoints()) do
            if Helper.isElementOf(objectiveTag, snapPoint.tags) then
                local absoluteSnapPointPosition = board.positionToWorld(snapPoint.position)
                local d = Vector.sqrDistance(object.getPosition(), absoluteSnapPointPosition)
                if d < 1.5 then
                    local leader = PlayBoard.getLeader(color)
                    if not leader then
                        return
                    end

                    local radius = 0.5
                    local hits = Physics.cast({
                        origin = absoluteSnapPointPosition,
                        direction = Vector(0, 1, 0),
                        type = 2,
                        size = Vector(radius, radius, radius),
                        max_distance = 2,
                    })

                    local hitTokens = Helper.filter(Helper.mapValues(hits, Helper.field("hit_object")), function (hitObject)
                        return hitObject.hasTag(objectiveTag)
                    end)

                    while #hitTokens >= 2 do
                        for _ = 1, 2 do
                            hitTokens[1].destruct()
                            table.remove(hitTokens, 1)
                        end
                        leader.gainVictoryPoint(color, tagToName[objectiveTag], 1)
                    end

                    break
                end
            end
        end
    end
end

---
function PlayBoard.onObjectEnterContainer(container, object)
    PlayBoard._updateBagCounts(container)
end

---
function PlayBoard.onObjectLeaveContainer(container, object)
    PlayBoard._updateBagCounts(container)
end

---
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

---
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

---
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
    local origin = PlayBoard.getPlayBoard(self.color):_newSymmetricBoardPosition(-2, 0.2, -6.5)

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
        assert(card)
        if Types.isImperiumCard(card) then
            --[[
                We leave the cards with a choice (not an option) in the player's hand to simplify
                things and make clear to the player that the card must be manually revealed.
            ]]
            return not Helper.isElementOf(Helper.getID(card), {
                "beneGesseritSister",
                "undercoverAsset",
                "desertPower"
            })
        else
            return false
        end
    end

    local revealedCards = Helper.filter(Player[self.color].getHandObjects(), properCard)
    local alreadyRevealedCards = Helper.filter(Park.getObjects(self.revealCardPark), properCard)
    local allRevealedCards = Helper.concatTables(revealedCards, alreadyRevealedCards)

    -- FIXME The agent could have been removed (e.g. Kwisatz Haderach)
    local techNegotiation = MainBoard.hasAgentInSpace("techNegotiation", self.color)
    local assemblyHall = MainBoard.hasAgentInSpace("assemblyHall", self.color)

    local minimicFilm = PlayBoard.hasTech(self.color, "minimicFilm")
    local restrictedOrdnance = PlayBoard.hasTech(self.color, "restrictedOrdnance")
    local councilSeat = PlayBoard.hasHighCouncilSeat(self.color)
    local artillery = PlayBoard.hasTech(self.color, "artillery")
    local swordmasterBonus = TurnControl.getPlayerCount() == 6 and PlayBoard.hasSwordmaster(self.color)

    local intrigueCardContributions = {}
    local imperiumCardContributions = {}
    if IntrigueCard then
        intrigueCardContributions = IntrigueCard.evaluatePlot(self.color, playedIntrigues, allRevealedCards, artillery)
    end
    imperiumCardContributions = ImperiumCard.evaluateReveal(self.color, playedCards, allRevealedCards, artillery)

    self.persuasion:set(
        (intrigueCardContributions.persuasion or 0) +
        (imperiumCardContributions.persuasion or 0) +
        (techNegotiation and 1 or 0) +
        (assemblyHall and 1 or 0) +
        (councilSeat and 2 or 0) +
        (minimicFilm and 1 or 0))

    self.strength:set(
        (imperiumCardContributions.strength or 0) +
        ((restrictedOrdnance and councilSeat) and 4 or 0) +
        (swordmasterBonus and 2 or 0))

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
        assert(leaderCard.hasTag("RivalLeader"))
        playBoard.leader = Hagal.newRival(Helper.getID(leaderCard))
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
        Helper.noPhysics(leaderCard)
        playBoard:_createButtons()
    end)

    return continuation
end

---
function PlayBoard.findLeaderCard(color)
    local leaderZone = PlayBoard.getContent(color).leaderZone
    for _, object in ipairs(leaderZone.getObjects(true)) do
        if object.hasTag("Leader") or object.hasTag("RivalLeader") then
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
function PlayBoard.getSpyPark(color)
    return PlayBoard.getPlayBoard(color).spyPark
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
    if self.scorePark then
        for _, object in ipairs(Park.getObjects(self.scorePark)) do
            if Types.isVictoryPointToken(object) then
                score = score + 1
            end
        end
    else
        log("Missing score park for player " .. self.color)
    end
    return score
end

---
function PlayBoard.grantTechTile(color, techTile)
    return Park.putObject(techTile, PlayBoard.getPlayBoard(color).techPark)
end

---
function PlayBoard.grantContractTile(color, contractTile)
    return Park.putObject(contractTile, PlayBoard.getPlayBoard(color).techPark)
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
    local token = PlayBoard._getCouncilToken(color)
    for _, zone in ipairs(Park.getZones(MainBoard.getHighCouncilSeatPark())) do
        if Helper.contains(zone, token) then
            return true
        end
    end
    return false
end

---
function PlayBoard.takeHighCouncilSeat(color)
    local token = PlayBoard._getCouncilToken(color)
    if not PlayBoard.hasHighCouncilSeat(color) then
        if Park.putObject(token, MainBoard.getHighCouncilSeatPark()) then
            Helper.clearButtons(token)
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
function PlayBoard.hasMakerHook(color)
    local content = PlayBoard.getContent(color)
    if content.makerHook then
        local d = content.makerHook.getPosition():distance(Combat.getMakerHookPosition(color))
        return d < 1
    else
        return false
    end
end

---
function PlayBoard.canTakeMakerHook(color)
    local normalOrAllyColor = color
    if TurnControl.getPlayerCount() == 6 and Commander.isCommander(color) then
        normalOrAllyColor = Commander.getActivatedAlly(color)
    end

    return not PlayBoard.hasMakerHook(normalOrAllyColor) and (TurnControl.getPlayerCount() < 6 or Commander.isTeamMuabDib(normalOrAllyColor))
end

---
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
                assert(Commander.isTeamMuabDib(normalOrAllyColor))
                local otherAllyColor = Commander.getOtherAlly(normalOrAllyColor)
                assert(otherAllyColor ~= normalOrAllyColor)
                if not PlayBoard.hasMakerHook(otherAllyColor) then
                    local leader = PlayBoard.getLeader(otherAllyColor)
                    leader.takeMakerHook(otherAllyColor)
                end
            end
        end)
        return true
    end
    return false
end

---
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

---
function PlayBoard.recruitSwordmaster(color)
    local playBoard = PlayBoard.getPlayBoard(color)
    if playBoard.content.swordmaster and Park.putObject(playBoard.content.swordmaster, PlayBoard.getAgentPark(color)) then
        if TurnControl.getPlayerCount() == 6 then
            playBoard.content.swordmasterBonusToken.setPosition(PlayBoard.swordmasterBonusPositions[color] + Vector(0, -0.15, 0))
            Helper.noPhysics(playBoard.content.swordmasterBonusToken)
            playBoard.strength:change(2)
        end
        Helper.emitEvent("swordmasterTaken", color)
        return true
    else
        return false
    end
end

---
function PlayBoard.destroySwordmaster(color)
    local playBoard = PlayBoard.getPlayBoard(color)
    if playBoard.content.swordmaster then
        --playBoard:trash(playBoard.content.swordmaster)
        playBoard.content.swordmaster.destruct()
        playBoard.content.swordmaster = nil
    end
end

---
function PlayBoard._getCouncilToken(color)
    local content = PlayBoard.getContent(color)
    return content.councilToken
end

---
function PlayBoard._getMakerHook(color)
    local content = PlayBoard.getContent(color)
    return content.makerHook
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
function PlayBoard.giveObjectiveCardFromZone(color, zone)
    Types.assertIsPlayerColor(color)
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

---
function PlayBoard.gainObjective(color, objective)
    return Combat.gainObjective(color, objective).doAfter(PlayBoard._convertObjectiveTokenPairsIntoVictoryPoints)
end

---
function PlayBoard.getObjectiveStackPosition(color, objective)
    local tag = Helper.toPascalCase(objective, "ObjectiveToken")
    local board = PlayBoard.getPlayBoard(color).content.board
    for _, snapPoint in ipairs(board.getSnapPoints()) do
        if Helper.isElementOf(tag, snapPoint.tags) then
            return board.positionToWorld(snapPoint.position)
        end
    end
    error(tag)
    return nil
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
            return Types.isIntrigueCard(card) -- and IntrigueCard.isCombatCard(card)
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
        return self:_newBoardPosition(12.75 + x, y, z)
    else
        return self:_newBoardPosition(x, y, z)
    end
end

---
function PlayBoard:_newBoardPosition(x, y, z)
    return Vector(x, y, -z)
end

--- Relative to the board, not a commander.
function PlayBoard.isLeft(color)
    return color == "Red" or color == "White" or color == "Blue"
end

--- Relative to the board, not a commander.
function PlayBoard.isRight(color)
    return color == "Green" or color == "Purple" or color == "Yellow"
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
    voiceToken.setPositionSmooth(position + Vector(0, 1, -1.8))
    return true
end

return PlayBoard
