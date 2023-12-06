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
local Intrigue = Module.lazyRequire("Intrigue")
local Reserve = Module.lazyRequire("Reserve")
local TechMarket = Module.lazyRequire("TechMarket")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")

--[[
    MakerHook

    "0492e6",
    "a07d90",
    "7011f2",
    "2a8414",

    Swordmaster bonuses

    Red     db91e0
    Green   f5bfa8
    Yellow  e160d9
    Brown   aa9a39
    Blue    28ec54
    Teal    a456bf
]]

local PlayBoard = Helper.createClass(nil, {
    ALL_RESOURCE_NAMES = { "spice", "water", "solari", "strength", "persuasion" },
    -- Temporary structure (set to nil *after* loading).
    unresolvedContentByColor = {
        Red = {
            board = "d47b92",
            colorband = "643f4d",
            spice = "3074d4",
            solari = "576ccd",
            water = "692c4d",
            persuasion = "7eb590",
            strength = "3f6645",
            dreadnoughts = {"1a3c82", "a8f306"},
            dreadnoughtInitialPositions = {
                Helper.getHardcodedPositionFromGUID('1a3c82', -23.7000713, 1.19922233, 19.39999),
                Helper.getHardcodedPositionFromGUID('a8f306', -25.30008, 1.19922233, 19.4)
            },
            agents = {"7751c8", "afa978"},
            agentInitialPositions = {
                Helper.getHardcodedPositionFromGUID('7751c8', -19.15, 1.19722152, 21.7),
                Helper.getHardcodedPositionFromGUID('afa978', -17.65, 1.19722152, 21.7)
            },
            swordmaster = "ed3490",
            swordmasterInitialPosition = Helper.getHardcodedPositionFromGUID('ed3490', -2.8040576, 0.590892, 26.5912743),
            spies = {
                "fdecae",
                "84d545",
                "e7a4ef",
            },
            spyInitialPositions = {
                Helper.getHardcodedPositionFromGUID('fdecae', -19.15, 1.52385247, 20.95),
                Helper.getHardcodedPositionFromGUID('84d545', -17.65, 1.52385259, 20.95),
                Helper.getHardcodedPositionFromGUID('e7a4ef', -16.1439533, 1.52385259, 20.94916)
            },
            councilToken = "f19a48",
            fourPlayerVictoryToken = "a6c2e0",
            scoreMarker = "4feaca",
            scoreMarkerInitialPosition = Helper.getHardcodedPositionFromGUID('4feaca', 10.3918591, 1.187121, -14.003993),
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
            tleilaxTokenInitalPosition = Helper.getHardcodedPositionFromGUID('2bfc39', 0.542932, 0.882152, 22.0543556),
            researchToken = "39e0f3",
            researchTokenInitalPosition = Helper.getHardcodedPositionFromGUID('39e0f3', 0.3698573, 0.884652138, 18.2348137),
            freighter = "e9096d",
            firstPlayerMarkerZone = "781a03",
            firstPlayerInitialPosition = Helper.getHardcodedPositionFromGUID('781a03', -13.6, 1.7, 20.89) + Vector(0, -0.4, 0),
            startEndTurnButton = "895594",
            atomicsToken = "d5ff47",
            makerHook = "2a8414",
        },
        Blue = {
            board = "f23836",
            colorband = "bca124",
            spice = "9cc286",
            solari = "fa5236",
            water = "0afaeb",
            persuasion = "d1fed4",
            strength = "aa3bb9",
            dreadnoughts = {"82789e", "60f208"},
            dreadnoughtInitialPositions = {
                Helper.getHardcodedPositionFromGUID('82789e', -23.7000732, 1.19922233, -19.0000114),
                Helper.getHardcodedPositionFromGUID('60f208', -25.300066, 1.19922256, -19.0000038)
            },
            agents = {"64d013", "106d8b"},
            agentInitialPositions = {
                Helper.getHardcodedPositionFromGUID('64d013', -19.15, 1.19722152, -16.7),
                Helper.getHardcodedPositionFromGUID('106d8b', -17.65, 1.19722152, -16.7)
            },
            swordmaster = "a78ad7",
            swordmasterInitialPosition = Helper.getHardcodedPositionFromGUID('a78ad7', -1.80386221, 0.5908921, 26.5916252),
            spies = {
                "7d7083",
                "e07c5c",
                "272ba1",
            },
            spyInitialPositions = {
                Helper.getHardcodedPositionFromGUID('7d7083', -19.15, 1.52385259, -17.45),
                Helper.getHardcodedPositionFromGUID('e07c5c', -17.65, 1.52385247, -17.45),
                Helper.getHardcodedPositionFromGUID('272ba1', -16.15, 1.52385259, -17.45)
            },
            councilToken = "f5b14a",
            fourPlayerVictoryToken = "311255",
            scoreMarker = "1b1e76",
            scoreMarkerInitialPosition = Helper.getHardcodedPositionFromGUID('1b1e76', 10.3927994, 1.38680148, -13.9921741),
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
            tleilaxTokenInitalPosition = Helper.getHardcodedPositionFromGUID('96607f', 0.542550445, 0.884651959, 22.75358),
            researchToken = "292658",
            researchTokenInitalPosition = Helper.getHardcodedPositionFromGUID('292658', 0.370049477, 0.882151961, 18.9373875),
            freighter = "68e424",
            firstPlayerMarkerZone = "311c04",
            firstPlayerInitialPosition = Helper.getHardcodedPositionFromGUID('311c04', -13.6, 1.7, -17.49) + Vector(0, -0.4, 0),
            startEndTurnButton = "9eeccd",
            atomicsToken = "700023",
            makerHook = "7011f2",
        },
        Green = {
            board = "2facfd",
            colorband = "a138eb",
            spice = "22478f",
            solari = "e597dc",
            water = "fa9522",
            persuasion = "aa79bf",
            strength = "d880f7",
            dreadnoughts = {"a15087", "734250"},
            dreadnoughtInitialPositions = {
                Helper.getHardcodedPositionFromGUID('a15087', 23.6999054, 1.19653678, 19.3999863),
                Helper.getHardcodedPositionFromGUID('734250', 25.299921, 1.19653678, 19.39999)
            },
            agents = {"bceb0e", "ee412b"},
            agentInitialPositions = {
                Helper.getHardcodedPositionFromGUID('bceb0e', 16.1, 1.19453585, 21.7),
                Helper.getHardcodedPositionFromGUID('ee412b', 17.6, 1.194536, 21.7)
            },
            swordmaster = "fb1629",
            swordmasterInitialPosition = Helper.getHardcodedPositionFromGUID('fb1629', 0.178526521, 0.5908921, 26.5916252),
            spies = {
                "ed1748",
                "795934",
                "8ca6ca",
            },
            spyInitialPositions = {
                Helper.getHardcodedPositionFromGUID('ed1748', 16.1, 1.521167, 20.95),
                Helper.getHardcodedPositionFromGUID('795934', 17.6, 1.521167, 20.95),
                Helper.getHardcodedPositionFromGUID('8ca6ca', 19.1, 1.521167, 20.95)
            },
            councilToken = "a0028d",
            fourPlayerVictoryToken = "66444c",
            scoreMarker = "76039f",
            scoreMarkerInitialPosition = Helper.getHardcodedPositionFromGUID('76039f', 10.3982086, 0.988654137, -14.00608),
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
            tleilaxTokenInitalPosition = Helper.getHardcodedPositionFromGUID('63d39f', 1.24582708, 0.8846519, 22.04864),
            researchToken = "658b17",
            researchTokenInitalPosition = Helper.getHardcodedPositionFromGUID('658b17', 0.370006, 0.882152, 20.3406372),
            freighter = "34281d",
            firstPlayerMarkerZone = "ce7c68",
            firstPlayerInitialPosition = Helper.getHardcodedPositionFromGUID('ce7c68', 13.6, 1.7, 20.89) + Vector(0, -0.4, 0),
            startEndTurnButton = "96aa58",
            atomicsToken = "0a22ec",
            makerHook = "0492e6",
        },
        Yellow = {
            board = "13b6cb",
            colorband = "9232e7",
            spice = "78fb8a",
            solari = "c5c4ef",
            water = "f217d0",
            persuasion = "c04d4e",
            strength = "6f007c",
            dreadnoughts = {"5469fb", "71a414"},
            dreadnoughtInitialPositions = {
                Helper.getHardcodedPositionFromGUID('5469fb', 23.6999054, 1.1965369, -19.00001),
                Helper.getHardcodedPositionFromGUID('71a414', 25.2999725, 1.19653666, -19.0000038)
            },
            agents = {"5068c8", "67b476"},
            agentInitialPositions = {
                Helper.getHardcodedPositionFromGUID('5068c8', 16.1, 1.194536, -16.7),
                Helper.getHardcodedPositionFromGUID('67b476', 17.6, 1.194536, -16.7)
            },
            swordmaster = "635c49",
            swordmasterInitialPosition = Helper.getHardcodedPositionFromGUID('635c49', -0.804006, 0.5908919, 26.5916328),
            spies = {
                "94ffec",
                "f59e0c",
                "4e66c4",
            },
            spyInitialPositions = {
                Helper.getHardcodedPositionFromGUID('94ffec', 16.1, 1.52116692, -17.45),
                Helper.getHardcodedPositionFromGUID('f59e0c', 17.6, 1.521167, -17.45),
                Helper.getHardcodedPositionFromGUID('4e66c4', 19.1, 1.521167, -17.45)
            },
            councilToken = "1be491",
            fourPlayerVictoryToken = "4e8873",
            scoreMarker = "20bbd1",
            scoreMarkerInitialPosition = Helper.getHardcodedPositionFromGUID('20bbd1', 10.3969374, 0.789412558, -14.0009308),
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
            tleilaxTokenInitalPosition = Helper.getHardcodedPositionFromGUID('d20bcf', 1.24723184, 0.884652, 22.7536983),
            researchToken = "8988cf",
            researchTokenInitalPosition = Helper.getHardcodedPositionFromGUID('8988cf', 0.370085239, 0.8821521, 19.6398125),
            freighter = "8fa76f",
            firstPlayerMarkerZone = "ba0c20",
            firstPlayerInitialPosition = Helper.getHardcodedPositionFromGUID('ba0c20', 13.6, 1.7, -17.49) + Vector(0, -0.4, 0),
            startEndTurnButton = "3d1b90",
            atomicsToken = "7e10a9",
            makerHook = "a07d90",
        },
        Teal = {
            board = "4ad196",
            colorband = "6d455c",
            spice = "9d593f",
            solari = "5a16bb",
            water = "830a1a",
            persuasion = "57a567",
            agents = {"fb2522", "14a2ac"},
            agentInitialPositions = {
                Helper.getHardcodedPositionFromGUID('fb2522', -19.15, 1.29885256, 2.50000024),
                Helper.getHardcodedPositionFromGUID('14a2ac', -17.65, 1.29885256, 2.5)
            },
            swordmaster = "83a527",
            swordmasterInitialPosition = Helper.getHardcodedPositionFromGUID('83a527', -2.30385923, 0.692523241, 27.6080017),
            spies = {
                "96bbc4",
                "040248",
                "bddedd",
            },
            spyInitialPositions = {
                Helper.getHardcodedPositionFromGUID('96bbc4', -19.1500015, 1.52385342, 1.75000119),
                Helper.getHardcodedPositionFromGUID('040248', -17.65, 1.52385342, 1.7500006),
                Helper.getHardcodedPositionFromGUID('bddedd', -16.15, 1.52385342, 1.75000107)
            },
            councilToken = "ded786",
            scoreMarker = "974cdf",
            scoreMarkerInitialPosition = Helper.getHardcodedPositionFromGUID('974cdf', 10.39122, 1.58687711, -13.9933825),
            trash = "a4f139",
            completedContractBag = "98c18d",
            firstPlayerMarkerZone = "f4c962",
            firstPlayerInitialPosition = Helper.getHardcodedPositionFromGUID('f4c962', -13.6, 1.7, 1.7) + Vector(0, -0.4, 0),
            startEndTurnButton = "8d70a4",
            atomicsToken = "a20687",
        },
        Brown = {
            board = "dc05a6",
            colorband = "1434c7",
            spice = "2c9946",
            solari = "43d234",
            water = "c72ecc",
            persuasion = "ab28ea",
            agents = {"0ad113", "d23b8f"},
            agentInitialPositions = {
                Helper.getHardcodedPositionFromGUID('0ad113', 16.1, 1.296167, 2.50000024),
                Helper.getHardcodedPositionFromGUID('d23b8f', 17.6, 1.29616714, 2.5)
            },
            swordmaster = "cc393c",
            swordmasterInitialPosition = Helper.getHardcodedPositionFromGUID('cc393c', -0.303858429, 0.692523241, 27.6080017),
            spies = {
                "e5b04d",
                "407c67",
                "a3d964",
            },
            spyInitialPositions = {
                Helper.getHardcodedPositionFromGUID('e5b04d', 16.1, 1.521167, 1.74999976),
                Helper.getHardcodedPositionFromGUID('407c67', 17.6, 1.52116787, 1.74999833),
                Helper.getHardcodedPositionFromGUID('a3d964', 19.1, 1.521168, 1.7500025)
            },
            councilToken = "8c6ba7",
            scoreMarker = "612a60",
            scoreMarkerInitialPosition = Helper.getHardcodedPositionFromGUID('612a60', 10.3914452, 1.78653038, -13.994525),
            trash = "556139",
            completedContractBag = "49dedf",
            firstPlayerMarkerZone = "7a8ea9",
            firstPlayerInitialPosition = Helper.getHardcodedPositionFromGUID('7a8ea9', 13.58, 1.7, 1.7) + Vector(0, -0.4, 0),
            startEndTurnButton = "eded7c",
            atomicsToken = "0a3ccb",
        },
    },
    playBoards = {}
})

---
function PlayBoard.rebuild()
    for _, color in ipairs({ "Green", "Yellow", "Blue", "Red", "Teal", "Brown" }) do
        local content = Helper.resolveGUIDs(true, PlayBoard.unresolvedContentByColor[color])

        local colorSwitch = function (left, right)
            if PlayBoard._isLeft(color) then
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
                startEndTurnButton = symmetric(-2.4, 0, 6),
                atomicsToken = symmetric(10, 0, 4),
            },
        }

        local c0 = 1
        local positions = {
            Green = Vector(24, 1, 14.2 + c0),
            Yellow = Vector(24, 1, -24.2 + c0),
            Red = Vector(-24, 1, 14.2 + c0),
            Blue = Vector(-24, 1, -24.2 + c0),
            Teal = Vector(-24, 1, -5 + c0),
            Brown = Vector(24, 1, -5 + c0),
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
                    "http://cloud-3.steamusercontent.com/ugc/2042984690511948114/BD4C6DB374A73A3A1586E84DD94DD2459EB51782/",
                    "http://cloud-3.steamusercontent.com/ugc/2042984690511949009/00AEA6A9B03D893B1BF82EFF392448FD52B8C70E/"),
                position = symmetric2(1.4, 0.2, -8.1),
                rotation = { 90, 180, 0 },
                scale = { 21.56, 1.1, 1.1 },
            },
            {
                name = "First Player Token Slot",
                url = "http://cloud-3.steamusercontent.com/ugc/2042984592862631937/B2176FBF3640DC02A6840C8E0FB162057724DE41/",
                position = symmetric2(10.4, 0.2, -5.7),
                rotation = { 90, 180, 0 },
                scale = { 2, 2, 2 },
            },
            {
                name = "Deck Slot",
                url = "http://cloud-3.steamusercontent.com/ugc/2042984592862630696/9973F87497827C194B979D7410D0DD47E46305FA/",
                position = offseted2(10.4, 0.2, -1.5),
                rotation = { 90, 180, 0 },
                scale = { 2.4, 3.4, 3.4 },
            },
            {
                name = "Discard Slot",
                url = "http://cloud-3.steamusercontent.com/ugc/2042984592862631187/76205DFA6ECBC5F9C6B38BE95F42E6B5468B5999/",
                position = offseted2(2.4, 0.2, -1.5),
                rotation = { 90, 180, 0 },
                scale = { 2.4, 3.4, 3.4 },
            },
            {
                name = "Leader Slot",
                url = "http://cloud-3.steamusercontent.com/ugc/2042984592862632410/7882B2E68FF7767C67EE5C63C9D7CF17B405A5C3/",
                position = offseted2(6.4, 0.2, -1),
                rotation = { 90, 180, 0 },
                scale = { 5, 3.5, 3.5 },
            },
            {
                name = "MuadDib Objective Slot",
                url = "http://cloud-3.steamusercontent.com/ugc/2285077174179797415/D172CF392A59D3596816D630A26AC2AED60B8796/",
                position = symmetric2(-3.4, 0.2, 0),
                rotation = { 90, 180, 0 },
                scale = { 1.1, 1.1, 1.1 },
            },
            {
                name = "Krys Objective Slot",
                url = "http://cloud-3.steamusercontent.com/ugc/2285077174179797013/7D1043073C71821322CA599EA4B8D5B4AA7C34F3/",
                position = symmetric2(-4.8, 0.2, 0),
                rotation = { 90, 180, 0 },
                scale = { 1.1, 1.1, 1.1 },
            },
            {
                name = "Ornithopter Objective Slot",
                url = "http://cloud-3.steamusercontent.com/ugc/2285077174179797729/D5C773ACE09B761D4A49751DB9ADB15E404C2FBE/",
                position = symmetric2(-6.2, 0.2, 0),
                rotation = { 90, 180, 0 },
                scale = { 1.1, 1.1, 1.1 },
            },
            --[[
            {
                name = "Joker Objective Slot",
                url = "",
                position = symmetric2(-7.6, 0.2, 0),
                rotation = { 90, 180, 0 },
                scale = { 1, 1, 1 },
            },
            ]]
        }

        layoutGrid(3, 1, function (x, y)
            table.insert(decals, {
                name = "Generic Slot",
                url = "http://cloud-3.steamusercontent.com/ugc/2042984592862621000/8C42D07B62ACE707EF3C206E9DFEA483821ECFD8/",
                position = offseted2(4.9 + x * 1.5, 0.2, -6.5),
                rotation = { 90, 0, 0 },
                scale = { 0.5, 0.5, 0.5 },
            })
        end)

        layoutGrid(3, 1, function (x, y)
            table.insert(decals,  {
                name = "Generic Slot",
                url = "http://cloud-3.steamusercontent.com/ugc/2042984592862621000/8C42D07B62ACE707EF3C206E9DFEA483821ECFD8/",
                position = offseted2(4.9 + x * 1.5, 0.2, -5.75),
                rotation = { 90, 0, 0 },
                scale = { 0.25, 0.25, 0.25 },
            })
        end)

        layoutGrid(2, 3, function (x, y)
            table.insert(decals, {
                name = "Tech Tile Slot",
                url = "http://cloud-3.steamusercontent.com/ugc/2042984592862632706/6A948CDC20774D0D4E5EA0EFF3E0D2C23F30FCC1/",
                position = symmetric2(-4 -3 * x, 0.2, -2 -2 * y),
                rotation = { 90, 0, 0 },
                scale = { 2.6, 1.8, 1.8 },
            })
        end)

        if content.dreadnoughts then
            layoutGrid(2, 1, function (x, y)
                table.insert(decals, {
                    name = "Generic Slot",
                    url = "http://cloud-3.steamusercontent.com/ugc/2042984592862621000/8C42D07B62ACE707EF3C206E9DFEA483821ECFD8/",
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
                    url = "http://cloud-3.steamusercontent.com/ugc/2120690798716490121/DB0A29253195530F3A39D5AC737922A5B2338795/",
                    position = symmetric2(9.5 -2.5 * x, 0.2, 3.2 + 4 * y),
                    rotation = { 90, 180, 0 },
                    scale = { 2, 2, 2 },
                })
            end)
        else
            layoutGrid(6, 1, function (x, y)
                table.insert(decals, {
                    name = "Intrigium",
                    url = "http://cloud-3.steamusercontent.com/ugc/2120690798716490121/DB0A29253195530F3A39D5AC737922A5B2338795/",
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
function PlayBoard:moveAt(position, isRelative)
    --Helper.dumpFunction("PlayBoard:moveAt", position, isRelative)

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

    local smooth = true
    local move = smooth and "setPositionSmooth" or "setPosition"

    Helper.forEachRecursively(toBeMoved, function (name, object)
        assert(tostring(object) ~= "null", name)
        if object.getPosition then
            object[move](object.getPosition() + offset)
        elseif object.x then
            object.x = object.x + offset.x
            object.y = object.y + offset.y
            object.z = object.z + offset.z
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

    local handTransform = Player[self.color].getHandTransform()
    handTransform.position = handTransform.position + offset
    Player[self.color].setHandTransform(handTransform)
end

---
function PlayBoard.onLoad(state)
    --Helper.dumpFunction("PlayBoard.onLoad(...)")

    for color, unresolvedContent in pairs(PlayBoard.unresolvedContentByColor) do
        local alive = true
        local subState = nil
        if state.PlayBoard then
            subState = state.PlayBoard[color]
            alive = subState ~= nil
        end
        if alive then
            PlayBoard.playBoards[color] = PlayBoard.new(color, unresolvedContent, subState)
        end
    end
    PlayBoard.unresolvedContentByColor = nil

    if state.settings then
        PlayBoard._staticSetUp(state.settings)
    end
end

---
function PlayBoard.onSave(state)
    --Helper.dumpFunction("PlayBoard.onSave")
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
            --alreadyPlayedCards = playBoard.alreadyPlayedCards,
            revealed = playBoard.revealed,
            initialPositions = {
                dreadnoughtInitialPositions = playBoard.content.dreadnoughtInitialPositions,
                agentInitialPositions = playBoard.content.agentInitialPositions,
                swordmasterInitialPosition = playBoard.content.swordmasterInitialPosition,
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
        if PlayBoard._isLeft(playBoard.color) then
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
function PlayBoard.new(color, unresolvedContent, subState)
    local playBoard = Helper.createClassInstance(PlayBoard, {
        color = color,
        score = 0,
        scorePositions = {},
    })
    playBoard.content = Helper.resolveGUIDs(false, unresolvedContent)

    Helper.noPhysicsNorPlay(
        playBoard.content.board,
        playBoard.content.colorband,
        playBoard.content.startEndTurnButton)

    playBoard.content.drawDeckZone = PlayBoard.createTransientZone(playBoard, "offseted", Vector(-10.4, 0.4, 1.5), Vector(2.3, 1, 3.3))
    playBoard.content.leaderZone = PlayBoard.createTransientZone(playBoard, "offseted", Vector(-6.4, 0.4, 1), Vector(5, 1, 3.5))
    playBoard.content.discardZone = PlayBoard.createTransientZone(playBoard, "offseted", Vector(-2.4, 0.4, 1.5), Vector(2.3, 1, 3.3))

    if subState then
        playBoard.opponent = subState.opponent

        playBoard.lastPhase = subState.lastPhase
        --playBoard.alreadyPlayedCards = subState.alreadyPlayedCards
        playBoard.revealed = subState.revealed

        -- Zones can't be queried right now (creation order matters?).
        Helper.onceFramesPassed(1).doAfter(function ()
            playBoard.leaderCard = Helper.getDeckOrCard(playBoard.content.leaderZone)
            assert(playBoard.leaderCard)
            if playBoard.opponent == "rival" then
                if Hagal.getRivalCount() == 1 then
                    playBoard.leader = Hagal.newRival(color)
                else
                    playBoard.leader = Hagal.newRival(color, Leader.newLeader(subState.leader))
                end
            else
                playBoard.leader = Leader.newLeader(subState.leader)
            end
        end)

        playBoard.content.dreadnoughtInitialPositions = Helper.mapValues(subState.initialPositions.dreadnoughtInitialPositions, Helper.toVector)
        playBoard.content.agentInitialPositions = Helper.mapValues(subState.initialPositions.agentInitialPositions, Helper.toVector)
        playBoard.content.swordmasterInitialPosition = Helper.toVector(subState.initialPositions.swordmasterInitialPosition)
        playBoard.content.spyInitialPositions = Helper.mapValues(subState.initialPositions.spyInitialPositions, Helper.toVector)
        playBoard.content.tleilaxTokenInitalPosition = Helper.toVector(subState.initialPositions.tleilaxTokenInitalPosition)
        playBoard.content.researchTokenInitalPosition = Helper.toVector(subState.initialPositions.researchTokenInitalPosition)
        playBoard.content.firstPlayerInitialPosition = Helper.toVector(subState.initialPositions.firstPlayerInitialPosition)
    else
        Helper.noPlay(
            playBoard.content.councilToken,
            playBoard.content.freighter,
            playBoard.content.tleilaxToken,
            playBoard.content.researchToken)
        Helper.noPhysicsNorPlay(
            playBoard.content.scoreMarker,
            playBoard.content.forceMarker)
    end

    local snapZones = {
        firstPlayerMarkerZone = { "FirstPlayerMarker" },
        drawDeckZone = { "Imperium" },
        leaderZone = { "Leader" },
        discardZone = { "Imperium" },
    }
    local snapPoints = {}
    for name, tags in pairs(snapZones) do
        local snapPoint = Helper.createRelativeSnapPointFromZone(playBoard.content.board, playBoard.content[name], true, tags)
        table.insert(snapPoints, snapPoint)
    end

    table.insert(snapPoints, { position = playBoard:_newSymmetricBoardPosition(-3.4, 0.2, 0), rotation_snap = true, tags = { "MuadDibObjectiveToken" } })
    table.insert(snapPoints, { position = playBoard:_newSymmetricBoardPosition(-4.8, 0.2, 0), rotation_snap = true, tags = { "KrysObjectiveToken" } })
    table.insert(snapPoints, { position = playBoard:_newSymmetricBoardPosition(-6.2, 0.2, 0), rotation_snap = true, tags = { "OrnithopterObjectiveToken" } })

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
    if not PlayBoard.isCommander(color) then
        playBoard.dreadnoughtPark = playBoard:_createDreadnoughtPark(subState == nil)
        playBoard.supplyPark = playBoard:_createSupplyPark(subState == nil)
    end
    playBoard:_generatePlayerScoreboardPositions()
    playBoard.scorePark = playBoard:_createPlayerScorePark()
    playBoard.techPark = playBoard:_createTechPark()

    playBoard:_createButtons(true)

    Helper.registerEventListener("locale", function ()
        playBoard:_createButtons(true)
    end)

    return playBoard
end

---
function PlayBoard.setUp(settings, activeOpponents)
    for color, playBoard in pairs(PlayBoard.playBoards) do
        playBoard:_cleanUp(false, not settings.riseOfIx, not settings.immortality)
        if activeOpponents[color] then
            playBoard.opponent = activeOpponents[color]
            if type(playBoard.opponent) ~= "string" then
                playBoard.opponent = playBoard.opponent.color
            end
            if playBoard.opponent ~= "rival" then
                if color == "Teal" then
                    Deck.generateMuadDibStarterDeck(playBoard.content.drawDeckZone).doAfter(Helper.shuffleDeck)
                elseif color == "Brown" then
                    Deck.generateEmperorStarterDeck(playBoard.content.drawDeckZone).doAfter(Helper.shuffleDeck)
                else
                    Deck.generateStarterDeck(playBoard.content.drawDeckZone, settings.immortality, settings.epicMode).doAfter(Helper.shuffleDeck)
                    Deck.generateStarterDiscard(playBoard.content.discardZone, settings.immortality, settings.epicMode)
                end
            else
                if settings.riseOfIx and not PlayBoard.isCommander(color) then
                    playBoard.content.researchToken.destruct()
                    playBoard.content.researchToken = nil
                end
                if Hagal.getRivalCount() == 1 then
                    playBoard.content.scoreMarker.destruct()
                    playBoard.content.scoreMarker = nil
                end
            end

            if settings.numberOfPlayers < 4 then
                playBoard.content.fourPlayerVictoryToken.destruct()
                playBoard.content.fourPlayerVictoryToken = nil
            end

            playBoard:_updatePlayerScore()
        else
            playBoard:_tearDown()
        end

        if settings.numberOfPlayers <= 4 then
            Helper.onceTimeElapsed(1).doAfter(function ()
                local offsets = {
                    Green = Vector(0, 0, -9.5),
                    Yellow = Vector(0, 0, 9.5),
                    Red = Vector(0, 0, -9.5),
                    Blue = Vector(0, 0, 9.5),
                }
                local offset = offsets[color]
                if offset then
                    playBoard:moveAt(offset, true)
                end
            end)
        end
    end

    PlayBoard._staticSetUp(settings)
end

---
function PlayBoard._staticSetUp(settings)

    Helper.registerEventListener("phaseStart", function (phase, firstPlayer)

        if phase == "leaderSelection" or phase == "roundStart" then
            local playBoard = PlayBoard.getPlayBoard(firstPlayer)
            MainBoard.getFirstPlayerMarker().setPositionSmooth(playBoard.content.firstPlayerInitialPosition, false, false)
        end

        -- There is no "gameStart" in Uprising
        if phase == "roundStart" and TurnControl.getCurrentRound() == 1 then
            for _, playBoard in pairs(PlayBoard._getPlayBoards()) do
                if playBoard.opponent ~= "rival" then
                    -- Force button creation now that we have all the information to create the Sandworm button.
                    playBoard:_createButtons()
                end
            end
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
            MainBoard.getFirstPlayerMarker().destruct()
        end
        PlayBoard._setActivePlayer(nil, nil)
    end)

    Helper.registerEventListener("playerTurns", function (phase, color)
        --Helper.dumpFunction("PlayBoard.turnCallback", phase, color)
        local playBoard = PlayBoard.getPlayBoard(color)

        for otherColor, otherPlayBoard in pairs(PlayBoard._getPlayBoards()) do
            if PlayBoard.isHuman(otherColor) then
                -- FIXME To naive, won't work for multiple agents in a single turn (weirding way).
                playBoard.alreadyPlayedCards = Helper.filter(Park.getObjects(playBoard.agentCardPark), function (card)
                    return Types.isImperiumCard(card) or Types.isIntrigueCard(card)
                end)
            end
        end

        if phase == "combatEnd" then
            -- Hagal has it own listener to do more things.
            if PlayBoard.isHuman(color) then
                PlayBoard.collectReward(color)
            end
        end

        PlayBoard._setActivePlayer(phase, color)
    end)

    Helper.registerEventListener("combatUpdate", function (forces)
        PlayBoard.combatPassCountdown = Helper.count(forces, function (_, v)
            return v > 0
        end)
    end)

    Helper.registerEventListener("agentSent", function (color, spaceName)
        Helper.dump("PlayBoard.isHuman(", color, ") =", PlayBoard.isHuman(color))
        if PlayBoard.isHuman(color) then
            -- Do it after the clean up done in TechMarket.
            Helper.onceFramesPassed(1).doAfter(function ()
                local cards = PlayBoard._getCardsPlayedThisTurn(color)
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
            local cards = PlayBoard._getCardsPlayedThisTurn(color)
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
    if not PlayBoard.isCommander(self.color) then
        self.strength:set((restrictedOrdnance and councilSeat) and 4 or 0)
    end

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
    Helper.forEach(playedIntrigueCards, function (i, card)
        card.setPosition(Intrigue.discardZone.getPosition())
    end)

    -- Flip any used tech.
    for _, techTile in ipairs(Park.getObjects(self.techPark)) do
        if techTile.hasTag("Tech") and techTile.is_face_down then
            techTile.flip()
        end
    end
end

---
function PlayBoard._setActivePlayer(phase, color)
    local indexedColors = { "Green", "Yellow", "Blue", "Red", "Teal", "Brown" }
    for i, otherColor in ipairs(indexedColors) do
        local playBoard = PlayBoard.playBoards[otherColor]
        if playBoard then
            local effectIndex = 0 -- black index (no color actually)
            if otherColor == color then
                effectIndex = i
                if playBoard.opponent == "rival" then
                    Hagal.activate(phase, color)
                else
                    if phase ~= "leaderSelection" then
                        playBoard:_createEndOfTurnButton()
                    end
                    PlayBoard._movePlayerIfNeeded(color)
                end
            else
                Helper.clearButtons(playBoard.content.startEndTurnButton)
            end
            -- FIXME Trigger effects are too unreliable for guest players.
            --[[
            local board = playBoard.content.board
            board.AssetBundle.playTriggerEffect(effectIndex)
            ]]
            playBoard.content.colorband.setColorTint(effectIndex > 0 and indexedColors[effectIndex] or "Black")
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
        Helper.onceFramesPassed(1).doAfter(function ()
            Helper.dump(hostPlayer.color, "-> puppet")
            local playBoard = PlayBoard.getPlayBoard(hostPlayer.color)
            if playBoard then
                PlayBoard.getPlayBoard(hostPlayer.color).opponent = "puppet"
                Helper.dump(hostPlayer.color, "->", color)
                PlayBoard.getPlayBoard(color).opponent = hostPlayer.color
                hostPlayer.changeColor(color)
            else
                error("Wrong player color!")
            end
        end)
    else
        Turns.turn_color = color
    end
end

---
function PlayBoard.createEndOfTurnButton(color)
    PlayBoard.playBoards[color]:_createEndOfTurnButton()
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
        label = I18N("endOfTurn"),
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
    Helper.dump("PlayBoard.acceptTurn", phase, color, playBoard.lastPhase)
    local accepted = false

    if phase == 'leaderSelection' then
        accepted = playBoard.leader == nil
    elseif phase == 'playerTurns' then
        if Hagal.getRivalCount() == 1 and PlayBoard.isRival(color) then
            accepted = not PlayBoard.playBoards[TurnControl.getFirstPlayer()].revealed
        else
            accepted = PlayBoard.couldSendAgentOrReveal(color)
        end
    elseif phase == 'combat' then
        --[[
        if Combat.isInCombat(color) then
            accepted = PlayBoard.combatPassCountdown > 0 and not PlayBoard.isRival(color) and #PlayBoard.getIntrigues(color) > 0
            PlayBoard.combatPassCountdown = PlayBoard.combatPassCountdown - 1
        end
        ]]
        accepted = false
    elseif phase == 'combatEnd' then
        -- TODO Player is victorious and the combat provided a reward (auto?) or
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
function PlayBoard.withLeader(action)
    return function (source, color, ...)
        local leader = PlayBoard.getLeader(color)
        if leader then
            -- Replace the source by the leader.
            action(leader, color, ...)
        else
            broadcastToColor(I18N('noLeader'), color, "Purple")
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

        --Helper.dump(color, "has", #dreadnoughts, "dreadnought(s)")
        if #dreadnoughts > 0 then
            Player[color].showInfoDialog(I18N("dreadnoughtMandatoryOccupation"))
        end
    end
end

---
function PlayBoard.getPlayBoard(color)
    assert(color)
    assert(#Helper.getKeys(PlayBoard.playBoards) > 0, "No playBoard at all: too soon!")
    local playBoard = PlayBoard.playBoards[color]
    --assert(playBoard, "No playBoard for color " .. tostring(color))
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
    local step = PlayBoard._isLeft(self.color) and -2.5 or 2.5

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
    local step = PlayBoard._isLeft(self.color) and -2.5 or 2.5

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

    --local park = Park.createCommonPark({ self.color, "Agent" }, slots, Vector(0.75, 3, 0.75))
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
    --local park = Park.createCommonPark({ self.color, "Spy" }, slots, Vector(0.75, 1, 0.75))
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
    --local park = Park.createCommonPark({ self.color, "Dreadnought" }, self.content.dreadnoughtInitialPositions, Vector(1, 3, 0.5))
    local park = Park.createCommonPark({ "Dreadnought" }, self.content.dreadnoughtInitialPositions, Vector(1, 3, 0.5))
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

    local supplyZone = Park.createTransientBoundingZone(45, Vector(0.4, 0.35, 0.4), allSlots)

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
    for i = 1, 2 do
        for j = 3, 1, -1 do
            local x = (i - 1.5) * 3 + 6
            if PlayBoard._isLeft(color) then
                x = -x
            end
                local z = (j - 2) * 2 + 0.4
            local slot = Vector(x, 0.5, z) + origin
            table.insert(slots, slot)
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
        Teal = 3,
        Brown = 3.5,
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
    local origin = self:_newSymmetricBoardPosition(-11.2, 0.41, -8.10) + self.content.board.getPosition()

    local direction = 1
    if PlayBoard._isLeft(self.color) then
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
function PlayBoard:_updatePlayerScore()
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
    for color, playBoard in pairs(PlayBoard.playBoards) do
        if playBoard.opponent and playBoard.scorePark then
            if Helper.isElementOf(zone, Park.getZones(playBoard.scorePark)) then
                if Types.isVictoryPointToken(object) then
                    playBoard:_updatePlayerScore()
                    --[[
                    local controlableSpace = MainBoard.findControlableSpace(object)
                    if controlableSpace then
                        MainBoard.occupy(controlableSpace, color)
                    end
                    ]]
                end
            end
        end
    end
end

---
function PlayBoard.onObjectLeaveScriptingZone(zone, object)
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
        collect("councilToken")
        collect("scoreMarker")
        collect("startEndTurnButton")
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
        collect("spies")

        if not PlayBoard.isCommander(self.color) then
            collect("controlMarkerBag")
            collect("forceMarker")
            collect("fourPlayerVictoryToken") -- TODO Add to commander
            collect("troops")
            collect("makerHook")
        end
    end

    if ix then
        if not PlayBoard.isCommander(self.color) then
            collect("dreadnoughts")
            collect("freighter")
        end
        collect("atomicsToken")
    end

    if immortality then
        if not PlayBoard.isCommander(self.color) then
            collect("tleilaxToken")
            collect("researchToken")
        end
    end

    if full then
        self:_clearButtons()

        if PlayBoard.isCommander(self.color) then
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

            -- TODO Get rid of the hand zone instead.
            local handTransform = Player[self.color].getHandTransform()
            handTransform.position = handTransform.position + self:_newSymmetricBoardPosition(50, 0, 0)
            Player[self.color].setHandTransform(handTransform)

            -- Safe?
            for i, hand in ipairs(Hands.getHands()) do
                if hand.getPosition() == Player[self.color].getHandTransform().position then
                    hand.destruct()
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
        if self.color == color or PlayBoard.isRival(self.color) then
            if not self.buttonsDisabled then
                self.buttonsDisabled = true
                Helper.onceTimeElapsed(0.5).doAfter(function ()
                    self.buttonsDisabled = false
                end)
                innerCallback(object, color, altClick)
            end
        else
            broadcastToColor(I18N('noTouch'), color, "Purple")
        end
    end)
end

---
function PlayBoard:getFontColor()
    local fontColor = { 0.9, 0.9, 0.9 }
    if self.color == "Green" or self.color == "Yellow" or self.color == "Teal" then
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
function PlayBoard:_createButtons(skipSandwormButton)
    self:_clearButtons()

    local colors = {
        Red = "Red",
        Blue = "Blue",
        Green = "Green",
        Yellow = "Yellow",
        Teal = Color(99 / 255, 158 / 255, 158 / 255),
        Brown = Color(106 / 255, 103 / 255, 97 / 255),
    }
    local chroma = colors[self.color]

    Color.Teal:set(0.75, 1, 0.25)

    local fontColor = self:getFontColor()

    local board = self.content.board

    if PlayBoard.playBoards then
        if not skipSandwormButton and (#Helper.getKeys(PlayBoard.playBoards) < 6 or PlayBoard.isTeamMuabDib(self.color)) then
            board.createButton({
                click_function = self:_createExclusiveCallback(function (_, _, altClick)
                    local battlegroundPark = Combat.getBattlegroundPark()
                    if altClick then
                        for _, object in ipairs(Park.getObjects(battlegroundPark)) do
                            if Types.isSandworm(object, self.color) then
                                object.destruct()
                                break
                            end
                        end
                    else
                        local sandworm = getObjectFromGUID("14b25e").clone({ position = Park.getPosition(battlegroundPark) - Vector(0, 20, 0) })
                        sandworm.addTag("Sandworm")
                        sandworm.addTag(self.color)
                        sandworm.setRotation(Vector(0, math.random(360), 0))
                        sandworm.setScale(sandworm.getScale():copy():scale(1/1.5))
                        sandworm.setColorTint(self.content.agents[1].getColorTint())
                        Park.putObject(sandworm, battlegroundPark)
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
        end
    end

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

    if false then
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
            color = chroma,
            font_color = fontColor
        })
    end

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

    self.content.completedContractBag.createButton({
        click_function = Helper.registerGlobalCallback(),
        label = "",
        position = Vector(0, 0.1, 1),
        width = 0,
        height = 0,
        font_size = 400,
        font_color = "White"
    })
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
    local origin = PlayBoard.getPlayBoard(self.color):_newSymmetricBoardPosition(-2, 0.2, -6.5)

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
        assert(card)
        return Types.isImperiumCard(card) and Helper.getID(card) ~= "beneGesseritSister"
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

    local intrigueCardContributions = IntrigueCard and IntrigueCard.evaluatePlot(self.color, playedIntrigues, allRevealedCards, artillery) or {}
    local imperiumCardContributions = ImperiumCard and ImperiumCard.evaluateReveal(self.color, playedCards, allRevealedCards, artillery) or {}

    self.persuasion:set(
        (intrigueCardContributions.persuasion or 0) +
        (imperiumCardContributions.persuasion or 0) +
        (techNegotiation and 1 or 0) +
        (assemblyHall and 1 or 0) +
        (councilSeat and 2 or 0) +
        (minimicFilm and 1 or 0))

    if not PlayBoard.isCommander(self.color) then
        self.strength:set(
            (imperiumCardContributions.strength or 0) +
            ((restrictedOrdnance and councilSeat) and 4 or 0))
    end

    Park.putObjects(revealedCards, self.revealCardPark)

    self.revealed = true
end

---
function PlayBoard:stillHavePlayableAgents()
    return #Park.getObjects(self.agentPark) > 0
end

---
function PlayBoard._getCardsPlayedThisTurn(color)
    local playBoard = PlayBoard.getPlayBoard(color)

    local playedCards = Helper.filter(Park.getObjects(playBoard.agentCardPark), function (card)
        return Types.isImperiumCard(card) or Types.isIntrigueCard(card)
    end)

    return (Set.newFromList(playedCards) - Set.newFromList(playBoard.alreadyPlayedCards or {})):toList()
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
    -- The getCardCount function is ok with nil arg, but we add a check for the sake of VS Code.
    if deckOrCard and dealCardCount > 0 then
        deckOrCard.deal(dealCardCount, self.color)
        -- FIXME Should be in Action.
        printToAll(I18N("drawObjects", { amount = dealCardCount, object = I18N.agree(dealCardCount, "imperiumCard") }), self.color)
    end

    remainingCardToDrawCount = remainingCardToDrawCount - dealCardCount

    -- Dealing cards take an unknown amout of time.
    Helper.onceTimeElapsed(0.5).doAfter(function ()
        if remainingCardToDrawCount > 0 then
            self:_resetDiscard().doAfter(function()
                self:drawCards(remainingCardToDrawCount)
            end)
        end
    end)
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
function PlayBoard.isCommander(color)
    return color == "Brown" or color == "Teal"
end

---
function PlayBoard.isAllied(color)
    return not PlayBoard.isCommander(color)
end

---
function PlayBoard.isTeamEmperor(color)
    return color == "Red" or color == "Red" or color == "Brown"
end

---
function PlayBoard.isTeamMuabDib(color)
    return color == "Green" or color == "Yellow" or color == "Teal"
end

---
function PlayBoard.setLeader(color, leaderCard)
    Types.assertIsPlayerColor(color)
    assert(leaderCard)

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

    -- Do not lock the Hagal deck.
    if playBoard.opponent ~= "rival" or Hagal.getRivalCount() > 1 then
        Helper.onceMotionless(leaderCard).doAfter(function ()
            Helper.noPhysics(leaderCard)
        end)
    end

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
    return PlayBoard.getPlayBoard(color).leader
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
    if not PlayBoard.isRival(self.color) or Hagal.getRivalCount() == 2 then
        if self.scorePark then
            for _, object in ipairs(Park.getObjects(self.scorePark)) do
                if Types.isVictoryPointToken(object) then
                    score = score + 1
                end
            end
        else
            log("Missing score park for player " .. self.color)
        end
    end
    return score
end

---
function PlayBoard.grantTechTile(color, techTile)
    Park.putObject(techTile, PlayBoard.getPlayBoard(color).techPark)
end

---
function PlayBoard.grantContractTile(color, contractTile)
    Park.putObject(contractTile, PlayBoard.getPlayBoard(color).techPark)
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
    for _, zone in ipairs(Park.getZones(MainBoard.getHighCouncilSeatPark())) do
        local token = PlayBoard.getCouncilToken(color)
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
    local content = PlayBoard.getContent(color)
    Helper.dump(content.swordmaster.getPosition(), "-", content.swordmasterInitialPosition, "=", content.swordmaster.getPosition():distance(content.swordmasterInitialPosition))
    return content.swordmaster.getPosition():distance(content.swordmasterInitialPosition) > 10
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
    if ImperiumCard then
        ImperiumCard.applyAcquireEffect(color, card)
    end

    -- Move it on the top of the content deck if possible and wanted.
    if (isTleilaxuCard and TleilaxuResearch.hasReachedOneHelix(color)) or PlayBoard.hasTech(color, "spaceport") then
        Player[color].showConfirmDialog(
            I18N("dialogCardAbove"),
            function(_)
                Helper.moveCardFromZone(content.discardZone, content.drawDeckZone.getPosition(), Vector(0, 180, 180))
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
        if ImperiumCard then
            ImperiumCard.applyAcquireEffect(color, card)
        end
    end)

    -- Move it on the top of the player deck if possible and wanted.
    if (isTleilaxuCard and TleilaxuResearch.hasReachedOneHelix(color)) or PlayBoard.hasTech(color, "spaceport") then
        Player[color].showConfirmDialog(
            I18N("dialogCardAbove"),
            function(_)
                Helper.moveCardFromZone(content.discardZone, content.drawDeckZone.getPosition() + Vector(0, 1, 0), Vector(0, 180, 180))
            end)
    end
end

---
function PlayBoard.giveObjectiveCardFromZone(color, zone)
    --Helper.dumpFunction("PlayBoard.giveObjectiveCardFromZone")
    Types.assertIsPlayerColor(color)
    local content = PlayBoard.getContent(color)
    assert(content)
    if true then
        local firstSlot = Park.findEmptySlots(PlayBoard.getAgentCardPark(color))[1]
        return Helper.moveCardFromZone(zone, firstSlot + Vector(0, 1, 0), nil, false, true)
    else
        return Helper.moveCardFromZone(zone, content.discardZone.getPosition() + Vector(0, 1, 0), nil, false, true)
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
    if PlayBoard._isLeft(self.color) then
        return self:_newBoardPosition(-x, y, z)
    else
        return self:_newBoardPosition(x, y, z)
    end
end

---
function PlayBoard:_newSymmetricBoardRotation(x, y, z)
    if PlayBoard._isLeft(self.color) then
        return self:_newBoardPosition(x, -y, z)
    else
        return self:_newBoardPosition(x, y, z)
    end
end

---
function PlayBoard:_newOffsetedBoardPosition(x, y, z)
    if PlayBoard._isLeft(self.color) then
        return self:_newBoardPosition(12.75 + x, y, z)
    else
        return self:_newBoardPosition(x, y, z)
    end
end

---
function PlayBoard:_newBoardPosition(x, y, z)
    return Vector(x, y, -z)
end

---
function PlayBoard._isLeft(color)
    return color == "Red" or color == "Teal" or color == "Blue"
end

---
function PlayBoard._isRight(color)
    return color == "Green" or color == "Brown" or color == "Yellow"
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

return PlayBoard
