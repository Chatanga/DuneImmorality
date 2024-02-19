local constants = {}

core = require("Core")

constants.someHeight = Vector(0, 0.3, 0)

-- Une position « légèrement » en dessus de manière à laisser faire la gravité
-- et d’éviter d’envoyer, par exemple, une carte invisible juste en dessous d’un
-- paquet qui sera donc ajouté à la carte et deviendra à son tour invisible…
function constants.getLandingPositionFromGUID(anchorGUID)
    local anchor = getObjectFromGUID(anchorGUID)
    if anchor then
        return constants.getLandingPosition(anchor)
    else
        log("[getLandingPositionFromGUID] Unknown GUID: " .. tostring(anchorGUID))
        return Vector(0, 0, 0)
    end
end

function constants.getLandingPosition(anchor)
    if anchor then
        return anchor.getPosition() + constants.someHeight
    else
        return Vector(0, 0, 0)
    end
end

-- Don't store object references for these objects which can be reloaded / mutated on locale change.
constants.cardsFoldspace = "014161"
constants.cardsLiaison = "7d34c9"
constants.cardsTSMF = "8de6d5"
constants.cardsBaseImperium = "99d41d"
constants.imperium_deck = "99d41d"
constants.imperium_deck_ix = "58c4c3"
constants.imperium_deck_immortality = "88b666"
constants.tleilaxu_deck = "dcad54"
constants.reclaimed_forces = "3c772c"
constants.intrigue_immortality = "a5dbab"
constants.intrigue_ix = "afa5e5"
constants.intrigue_base = "77d25d"
constants.epic_cards = {'7ae7f5', 'fbaf9f', '497c84', '30b760'}
constants.starter_decks = {"014c6a", "b8e747", "0c5e03", "a76b37"}
constants.dune_decks = {"8c99a3", "af840c", "44069d", "85fb54"}
constants.experimentation_decks = {"ef9531", "45ce21", "2d935f", "8ed0cd"}

constants.leaderPos = {
    Yellow = core.getHardcodedPositionFromGUID('a677e0', 19.0, 1.17902148, -5.5),
    Green = core.getHardcodedPositionFromGUID('cf1486', 19.0, 1.18726385, 17.5),
    Blue = core.getHardcodedPositionFromGUID('681774', -19.0, 1.25506675, -5.5),
    Red = core.getHardcodedPositionFromGUID('66cdbb', -19.0, 1.25, 17.5)
}

-- Don't store object references for these objects which can be reloaded / mutated on locale change.
constants.leaders = {
    yuna = {GUID = "0b6322"},
    hundro = {GUID = "6e3714"},
    memnon = {GUID = "d9daed"},
    ariana = {GUID = "4d862a"},
    ilesa = {GUID = "158da6"},
    armand = {GUID = "796f0a"},
    paul = {GUID = "2df658"},
    leto = {GUID = "9b6cdc"},
    tessia = {GUID = "1839fa"},
    rhombur = {GUID = "691ca6"},
    rabban = {GUID = "4cf050"},
    vladimir = {GUID = "98cae8"},
    ilban = {GUID = "78551e"},
    helena = {GUID = "5a8a9a"}
}

-- Don't store object references for these objects which can be reloaded / mutated on locale change.
constants.books = {
    base = "6ec3b0",
    faq = "86033d",
    riseOfIx = "57bf60",
    immortality = "537207",
    blitz = nil
}

--[[
    Temporary structure (set to nil after loading). On loading, two mirrors of
    this structure are created with the GUIDs resolved:
    - constants.players
    - constants.alivePlayers
]]--
constants.unresolvedPlayers = {
    Red = {
        board = "adcd28",
        spice = "3074d4",
        solari = "576ccd",
        water = "692c4d",
        leader_zone = "66cdbb",
        dreadnoughts = {"1a3c82", "a8f306"},
        dreadnought_positions = {
            core.getHardcodedPositionFromGUID('1a3c82', -26.3, 1.11258292, 18.69998),
            core.getHardcodedPositionFromGUID('a8f306', -28.7000046, 1.11258316, 18.69998)
        },
        agents = {"7751c8", "afa978"},
        agent_positions = {
            core.getHardcodedPositionFromGUID('7751c8', -17.0, 1.11060059, 20.3),
            core.getHardcodedPositionFromGUID('afa978', -18.3, 1.11060059, 20.3)
        },
        swordmaster = "ed3490",
        council_token = "f19a48",
        council_zone = core.getHardcodedPositionFromGUID('074f6d', -0.0310453977, 0.588213563, 5.520437) + Vector(-1.54, 1, 0),
        council_bonus_zone = core.getHardcodedPositionFromGUID('f19a48', -27.5, 1.23473155, 20.0) + Vector(0, 0.05, 0),
        vanilla_council_zone = core.getHardcodedPositionFromGUID('074f6d', -0.0310453977, 0.588213563, 5.520437) + Vector(-1.73, 1, 0),
        vp_4_players_token = "a6c2e0",
        vp_4_players_token_initial_position = core.getHardcodedPositionFromGUID('a6c2e0', -13.0, 1.31223142, 21.85),
        score_marker = "4feaca",
        score_marker_initial_position = core.getHardcodedPositionFromGUID('4feaca', 10.3334379, 0.77999717, -12.9315357),
        flag_bag = '61453d',
        troops = {
            "fd5673",
            "81763a",
            "6c2b85",
            "8b2acc",
            "8bb1e6",
            "26904f",
            "d1787e",
            "af7cd0",
            "1bbf1c",
            "1fb4ed",
            "0fa955",
            "465c38"
        },
        marker_combat = '2d1d17',
        pos_discard = core.getHardcodedPositionFromGUID('e07493', -14.0, 1.79567933, 16.5) + constants.someHeight,
        drawDeck = "b8e747",
        drawDeckZone = "4f08fc",
        discardZone = "e07493",
        trash = "ea3fe1",
        techZone = '9555b8',
        pass_turn_anchors = "0e9fa2",
        tleilaxuTokens = "2bfc39",
        tleilaxuTokens_inital_position = core.getHardcodedPositionFromGUID('2bfc39', 0.376108617, 0.87810266, 20.6450424),
        researchTokens = "39e0f3",
        researchTokens_inital_position = core.getHardcodedPositionFromGUID('39e0f3', 0.173057914, 0.8806028, 16.8245316),
        cargo = "e9096d",
        zone_player = "2b7781",
        playZone = "cd9716"
    },
    Blue = {
        board = "77ca63",
        spice = "9cc286",
        solari = "fa5236",
        water = "0afaeb",
        leader_zone = "681774",
        dreadnoughts = {"82789e", "60f208"},
        dreadnought_positions = {
            core.getHardcodedPositionFromGUID('82789e', -26.3000088, 1.11258292, -4.30001831),
            core.getHardcodedPositionFromGUID('60f208', -28.7000084, 1.11258316, -4.30003548)
        },
        agents = {"64d013", "106d8b"},
        agent_positions = {
            core.getHardcodedPositionFromGUID('64d013', -17.0, 1.11060059, -2.7),
            core.getHardcodedPositionFromGUID('106d8b', -18.3, 1.11060059, -2.7)
        },
        swordmaster = "a78ad7",
        council_token = "f5b14a",
        council_zone = core.getHardcodedPositionFromGUID('074f6d', -0.0310453977, 0.588213563, 5.520437) + Vector(-0.81, 1, 0),
        council_bonus_zone = core.getHardcodedPositionFromGUID('f5b14a', -27.5, 1.23473155, -3.00000048) + Vector(0, 0.05, 0),
        vanilla_council_zone = core.getHardcodedPositionFromGUID('074f6d', -0.0310453977, 0.588213563, 5.520437) + Vector(-1.00, 1, 0),
        vp_4_players_token = "311255",
        vp_4_players_token_initial_position = core.getHardcodedPositionFromGUID('311255', -13.0, 1.11223137, -1.14999962),
        score_marker = "1b1e76",
        score_marker_initial_position = core.getHardcodedPositionFromGUID('1b1e76', 10.33238, 0.97952795, -12.9301462),
        flag_bag = '8627e0',
        troops = {
            "bc6e74",
            "5fba3c",
            "f2c21f",
            "2a5276",
            "f60d9c",
            "949f2d",
            "0e57c9",
            "694553",
            "f65e5d",
            "c64616",
            "46c1c6",
            "49afee"
        },
        marker_combat = 'f22e20',
        pos_discard = core.getHardcodedPositionFromGUID('26bf8b', -14.0, 1.86566067, -6.5) + constants.someHeight,
        drawDeck = "a76b37",
        drawDeckZone = "907f66",
        discardZone = "26bf8b",
        trash = "52a539",
        techZone = '2d3346',
        pass_turn_anchors = "643f32",
        tleilaxuTokens = "96607f",
        tleilaxuTokens_inital_position = core.getHardcodedPositionFromGUID('96607f', 0.358834058, 0.8806026, 21.36463),
        researchTokens = "292658",
        researchTokens_inital_position = core.getHardcodedPositionFromGUID('292658', 0.193223014, 0.8781026, 17.5218124),
        cargo = "68e424",
        zone_player = "621cc4",
        playZone = "f20a74"
    },
    Green = {
        board = "0bbae1",
        spice = "22478f",
        solari = "e597dc",
        water = "fa9522",
        leader_zone = "cf1486",
        dreadnoughts = {"a15087", "734250"},
        dreadnought_positions = {
            core.getHardcodedPositionFromGUID('a15087', 26.2999954, 1.11258316, 18.6999836),
            core.getHardcodedPositionFromGUID('734250', 28.6999989, 1.11258316, 18.6999645)
        },
        agents = {"66ae45", "bceb0e"},
        agent_positions = {
            core.getHardcodedPositionFromGUID('66ae45', 17.0, 1.11060059, 20.3),
            core.getHardcodedPositionFromGUID('bceb0e', 18.3, 1.11060059, 20.3)
        },
        swordmaster = "fb1629",
        council_token = "a0028d",
        council_zone = core.getHardcodedPositionFromGUID('074f6d', -0.0310453977, 0.588213563, 5.520437) + Vector(0.83, 1, 0),
        council_bonus_zone = core.getHardcodedPositionFromGUID('a0028d', 27.5, 1.23473155, 20.0) + Vector(0, 0.05, 0),
        vanilla_council_zone = core.getHardcodedPositionFromGUID('074f6d', -0.0310453977, 0.588213563, 5.520437) + Vector(0.66, 1, 0),
        vp_4_players_token = "66444c",
        vp_4_players_token_initial_position = core.getHardcodedPositionFromGUID('66444c', 13.0, 1.31223154, 21.85),
        score_marker = "76039f",
        score_marker_initial_position = core.getHardcodedPositionFromGUID('76039f', 10.337841, 1.17953253, -12.9312315),
        flag_bag = 'ad6b92',
        troops = {
            "f433eb",
            "b614cc",
            "60c92d",
            "167fd4",
            "08be0c",
            "a67287",
            "2852e1",
            "fc9c62",
            "b48887",
            "2b1cf8",
            "8e22cc",
            "866a9c"
        },
        marker_combat = 'a1a9a7',
        pos_discard = core.getHardcodedPositionFromGUID('2298aa', 24.0, 1.70515823, 16.5) + constants.someHeight,
        drawDeck = "0c5e03",
        drawDeckZone = "6d8a2e",
        discardZone = "2298aa",
        trash = "4060b5",
        techZone = '546163',
        pass_turn_anchors = "65876d",
        tleilaxuTokens = "63d39f",
        tleilaxuTokens_inital_position = core.getHardcodedPositionFromGUID('63d39f', 1.07565093, 0.880602539, 20.6561527),
        researchTokens = "658b17",
        researchTokens_inital_position = core.getHardcodedPositionFromGUID('658b17', 0.184157684, 0.87810266, 18.91703),
        cargo = "34281d",
        zone_player = "111023",
        playZone = "890115"
    },
    Yellow = {
        board = "fdd5f9",
        spice = "78fb8a",
        solari = "c5c4ef",
        water = "f217d0",
        leader_zone = "a677e0",
        dreadnoughts = {"5469fb", "71a414"},
        dreadnought_positions = {
            core.getHardcodedPositionFromGUID('5469fb', 26.29999, 1.11258328, -4.299999),
            core.getHardcodedPositionFromGUID('71a414', 28.6999969, 1.11258316, -4.30002546)
        },
        agents = {"5068c8", "67b476"},
        agent_positions = {
            core.getHardcodedPositionFromGUID('5068c8', 17.0, 1.11060059, -2.7),
            core.getHardcodedPositionFromGUID('67b476', 18.3, 1.11060035, -2.7)
        },
        swordmaster = "635c49",
        council_token = "1be491",
        council_zone = core.getHardcodedPositionFromGUID('074f6d', -0.0310453977, 0.588213563, 5.520437) + Vector(1.60, 1, 0),
        council_bonus_zone = core.getHardcodedPositionFromGUID('1be491', 27.5, 1.23473155, -2.999998) + Vector(0, 0.05, 0),
        vanilla_council_zone = core.getHardcodedPositionFromGUID('074f6d', -0.0310453977, 0.588213563, 5.520437) + Vector(1.37, 1, 0),
        vp_4_players_token = "4e8873",
        vp_4_players_token_initial_position = core.getHardcodedPositionFromGUID('4e8873', 13.0, 1.31223142, -1.14999938),
        score_marker = "20bbd1",
        score_marker_initial_position = core.getHardcodedPositionFromGUID('20bbd1', 10.3093843, 1.37934494, -12.9432421),
        flag_bag = 'b92a4c',
        troops = {
            "ef6da2",
            "4d0dbf",
            "7c5b7b",
            "fbf8d2",
            "d01e0b",
            "79cbf1",
            "96d089",
            "b5d32e",
            "9b55e4",
            "fd7fc7",
            "ef9008",
            "734b6e"
        },
        marker_combat = 'c2dd31',
        pos_discard = core.getHardcodedPositionFromGUID('6bb3b6', 24.0, 1.66282058, -6.5) + constants.someHeight,
        drawDeck = "014c6a",
        drawDeckZone = "e6cfee",
        discardZone = "6bb3b6",
        trash = "7d1e07",
        techZone = '3d705e',
        pass_turn_anchors = "65876d",
        tleilaxuTokens = "d20bcf",
        tleilaxuTokens_inital_position = core.getHardcodedPositionFromGUID('d20bcf', 1.0899967, 0.880602658, 21.3422337),
        researchTokens = "8988cf",
        researchTokens_inital_position = core.getHardcodedPositionFromGUID('8988cf', 0.189716741, 0.8781027, 18.22235),
        cargo = "8fa76f",
        zone_player = "20859b",
        playZone = "ae1ef8"
    }
}

constants.pos_trash_lower = core.getHardcodedPositionFromGUID('ef8614', 2.0719285, 0.646084964, -20.6404324) + constants.someHeight

constants.first_player_marker = nil

constants.first_player_positions =  {
    Red = core.getHardcodedPositionFromGUID('346e0d', -14.0, 1.5, 19.7) + Vector(0, -0.4, 0),
    Blue = core.getHardcodedPositionFromGUID('1fc559', -14.0, 1.501278, -3.3) + Vector(0, -0.4, 0),
    Green = core.getHardcodedPositionFromGUID('59523d', 14.0, 1.45146358, 19.7) + Vector(0, -0.4, 0),
    Yellow = core.getHardcodedPositionFromGUID('e9a44c', 14.0, 1.44851, -3.3) + Vector(0, -0.4, 0)
}

constants.zone_deck_imperium = '8bd982'

constants.zone_deck_tleilaxu = '14b2ca'

constants.ixPlanetBoard = 'd75455'

constants.imperiumRow = {
    {zoneGuid = '3de1d0', pos = core.getHardcodedPositionFromGUID('38ffc0', -7.249982, 0.37, 8.870052) + constants.someHeight},
    {zoneGuid = '356e2c', pos = core.getHardcodedPositionFromGUID('21b287', -4.749954, 0.37, 8.869976) + constants.someHeight},
    {zoneGuid = '7edbb3', pos = core.getHardcodedPositionFromGUID('0a5f50', -2.24990153, 0.37, 8.870014) + constants.someHeight},
    {zoneGuid = '641974', pos = core.getHardcodedPositionFromGUID('ded672', 0.250105143, 0.37, 8.870017) + constants.someHeight},
    {zoneGuid = 'c6dbed', pos = core.getHardcodedPositionFromGUID('ad2a82', 2.732831, 0.37, 8.870062) + constants.someHeight}
}

constants.tleilaxuRow = {
    {zoneGuid = 'e5ba35', pos = core.getHardcodedPositionFromGUID('439df9', -7.58550072, 0.5361512, 16.0389957) + constants.someHeight},
    {zoneGuid = '1e5a32', pos = core.getHardcodedPositionFromGUID('363f98', -5.04514647, 0.513785, 16.0400372) + constants.someHeight}
}

constants.buy7_guid = '439df9'
constants.buy8_guid = '363f98'

constants.maker_initial_position = core.getHardcodedPositionFromGUID('fb41e2', -4.08300161, 0.721966565, -12.01027)

-- TODO Use the anchor instead of the token itself.
-- "Makers & Recall anchor": "120026",
-- "Makers & Recall": "fb41e2",
constants.marker_positions = {
    round_start = constants.maker_initial_position,
    player_turns = constants.maker_initial_position + Vector(0, 0, -0.64),
    combat = constants.maker_initial_position + Vector(0, 0, -0.64 * 2),
    makers = constants.maker_initial_position + Vector(0, 0, -0.64 * 3),
    recall = constants.maker_initial_position + Vector(0, 0, -0.64 * 4)
}

constants.turnOrder = {
    Green = 'Yellow',
    Yellow = 'Blue',
    Blue = 'Red',
    Red = 'Green',
}

_ = core.registerLoadablePart(function(_)
    constants.first_player_marker = getObjectFromGUID("1f5576")

    constants.players = {}
    -- Do not confuse alive players with active players. Without restoring a save,
    -- all players stay alive.
    constants.alivePlayers = {}

    for color, unresolvedPlayer in pairs(constants.unresolvedPlayers) do
        -- Too many objects could be legitimately missing in the middle of a
        -- game, event for alive players, so we simply disable the unresolved
        -- GUID reporting.
        local player = core.resolveGUIDs(false, unresolvedPlayer)
        constants.players[color] = player
    -- Not having a swordmaster anymore is a sure sign that a player has
        -- been shutdown.
        local alive = getObjectFromGUID(unresolvedPlayer.swordmaster) ~= nil
        if alive then
            constants.alivePlayers[color] = player
        end
    end
    constants.unresolvedPlayers = nil

    -- Extrapolate two other positions (for the swordmaster and the mentat)
    -- from the positions of the two existing agents.
    for _, player in pairs(constants.players) do
        assert(#player.agent_positions == 2)
        local p1 = player.agent_positions[1]
        local p2 = player.agent_positions[2]
        player.agent_positions[3] = p2 + (p2 - p1)
        player.agent_positions[4] = p2 + (p2 - p1) * 2
    end
end)

return constants
