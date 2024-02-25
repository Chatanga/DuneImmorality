core = require("Core")

i18n = require("i18n")
require("locales")

constants = require("Constants")

worm = require("Worm")

helperModule = require("HelperModule")

localeAssets = require("localeAssets")

languages = {
    {locale='en', name = 'English'},
    {locale='fr', name = 'Français'}
}

GetDeckOrCard = helperModule.GetDeckOrCard
GetDeckOrCardFromGUID = helperModule.GetDeckOrCardFromGUID

position_marker = constants.first_player_positions

manigance = '2b2575'

conflictDeckLocation = core.getHardcodedPositionFromGUID('f9ea6b', -3.37652636, 0.725000858, -9.742931) + constants.someHeight

zone_intrigue = 'a377d8'
zone_imperium = constants.zone_deck_imperium
epic_cards = constants.epic_cards
-- conflictZone1 = "616984"
-- conflictZone2 = "7c9ceb"
-- conflictZone3 = "f9ea6b"
trashBin = '8d39ef'

baseGameManualPosition = {-7.677, 0, -14.917}
-- parameter to set
waitTimeUntilBanDelete = 5 -- How many seconds banned leaders are shown to black, and other player must wait
numberOfBan = 6 -- default number of ban
--
leaderChoices = {} -- Table key:player color, value: GUID of leader picked : to adjust initial leader starting ressources when hidden pick is over
playerOrderToPickHidingStates = {} -- Sequence of value to assign to hidingState in global: anti-clokwise starting from player before first player
hiddenPicksOrderSet = false
leadersBanned = false

minimum_value_ban = 1 -- for number of ban buttons: value when Rise of Ix is by default on
maximum_value_ban = 10

button_offset_y = 0 -- Set number. Value greater than or equal to 0. Defaults to 0.10.
button_width = 2000 -- Set number. Defaults to 450.
button_height = 300 -- Set number. Defaults to 300.
button_color = {0.25, 0.25, 0.25} -- Set number {Red,Green,Blue}. Value bitween 0.00 to 1.00. Defaults to {1.00,1.00,1.00] ("White").
text_color = {1.00, 1.00, 1.00} -- Set number {Red,Green,Blue}. Value bitween 0.00 to 1.00. Defaults to {0.25,0.25,0.25] ("Black").
text_size = 200 -- Set number. Defaults to 100.

tleilaxuCardCostByGUID = {}

_ = core.registerLoadablePart(function(saved_data)

    marker = constants.first_player_marker

    pos_starter_decks = {
        constants.getLandingPosition(constants.players.Red.drawDeck),
        constants.getLandingPosition(constants.players.Blue.drawDeck),
        constants.getLandingPosition(constants.players.Green.drawDeck),
        constants.getLandingPosition(constants.players.Yellow.drawDeck)
    }

    hotseat = {
        ["Blue"] = {obj = getObjectFromGUID("9eeccd"), pos = constants.players["Blue"].board.getPosition() + Vector(-13.5, 0.7, -1)},
        ["Red"] = {obj = getObjectFromGUID("895594"), pos = constants.players["Red"].board.getPosition() + Vector(-13.5, 0.7, -1)},
        ["Green"] = {obj = getObjectFromGUID("96aa58"), pos = constants.players["Green"].board.getPosition() + Vector(13.5, 0.7, -1)},
        ["Yellow"] = {obj = getObjectFromGUID("3d1b90"), pos = constants.players["Yellow"].board.getPosition() + Vector(13.5, 0.7, -1)}
    }

    trash = {
        ["Green"] = getObjectFromGUID("4060b5"),
        ["Blue"] = getObjectFromGUID("52a539"),
        ["Yellow"] = getObjectFromGUID("7d1e07"),
        ["Red"] = getObjectFromGUID("ea3fe1"),
        ["Everyone"] = getObjectFromGUID("ef8614")
    }
    hagal_rise_of_ix_2P = getObjectFromGUID("1f3751")
    hagal_2P = getObjectFromGUID("43a37f")
    hagal_rise_of_ix_1P = getObjectFromGUID("cb48b7")
    hagal_1P = getObjectFromGUID("2d887f")
    hagal_everytime_except_immortality_1P = getObjectFromGUID("d1ff61")
    hagal_immortality_1P = getObjectFromGUID("9f6ea8")
    hagal_rise_of_ix = getObjectFromGUID("dd0da1")
    hagal_without_rise_of_ix = getObjectFromGUID("72d430")

    dune_cards_decks_zone = {
        getObjectFromGUID("e23476"), getObjectFromGUID("355dc0"),
        getObjectFromGUID("d3521b"), getObjectFromGUID("7b2ba8")
    }

    councellor_bonus_bag = getObjectFromGUID("074f6d")
    -- "Four Players" VP
    FP1 = getObjectFromGUID('66444c')
    FP2 = getObjectFromGUID('4e8873')
    FP3 = getObjectFromGUID('a6c2e0')
    FP4 = getObjectFromGUID('311255')
    tech_tiles_en = getObjectFromGUID("cb766f")
    tech_tiles_fr = getObjectFromGUID("6116af")
    intrigue_ix = constants.intrigue_ix
    intrigue_immortality = constants.intrigue_immortality
    -- imperium_deck = getObjectFromGUID('71ec7e')
    imperium_deck_ix = constants.imperium_deck_ix
    imperium_deck_immortality = constants.imperium_deck_immortality
    -- tleilaxu_deck = constants.tleilaxu_deck
    reclaimed_forces = constants.reclaimed_forces
    bene_tleilax_zone = getObjectFromGUID('042b49')
    atomics = {'d5ff47', '0a22ec', '700023', '7e10a9'}
    experimentation_decks = {'ef9531', '45ce21', '2d935f', '8ed0cd'}
    research_station_immortality = getObjectFromGUID('54413c')
    intrigue_pos = constants.getLandingPositionFromGUID(constants.intrigue_base)
    imperium_pos = constants.getLandingPositionFromGUID(constants.imperium_deck)
    hagal1P_base = "54a2cb"
    hagal1P = getObjectFromGUID("6020d0")
    hagal2P_base = "1dd8a5"
    hagal2P = getObjectFromGUID("8f8cc1")
    conflictOne = getObjectFromGUID("616984")
    conflictTwo = getObjectFromGUID("7c9ceb")
    conflictThree = getObjectFromGUID("f9ea6b")
    epicgamebutton = getObjectFromGUID("f8480b")
    pos_trash = constants.pos_trash_lower

    hand_players = core.resolveGUIDs(false, {
        Green = "482f72",
        Blue = "e50f77",
        Yellow = "050f39",
        Red = "8a9816"
    })
    pion_reput = core.resolveGUIDs(false, {
        Emperor = {
            Red = 'acfcef',
            Blue = '426a23',
            Green = 'd7c9ba',
            Yellow = '489871'
        },
        Guild = {
            Red = 'be464e',
            Blue = '4069d8',
            Green = '89da7d',
            Yellow = '9d0075'
        },
        Bene = {
            Red = '713eae',
            Blue = '2a88a6',
            Green = '2dc980',
            Yellow = 'a3729e'
        },
        Fremen = {
            Red = '088f51',
            Blue = '0e6e41',
            Green = 'd390dc',
            Yellow = '77d7c8'
        }
    })

    leaderRandomizer = getObjectFromGUID("cf6ca1")

    self.interactable = false
    councellor_bonus_bag.interactable = false

    for _, player in pairs(constants.alivePlayers) do
        player.score_marker.interactable = false
    end

    for _, obj in pairs(getObjectFromGUID("e88cd0").getObjects()) do
        obj.setInvisibleTo({
            "Red", "Blue", "Green", "Yellow", "White", "Grey", "Brown", "Pink",
            "Purple", "Orange"
        })
    end

    setupDone = false

    -- Any reason to use integers instead of booleans?
    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        setupDone = loaded_data.setupDone
        tournament = loaded_data.tournament
        score_board = loaded_data.score_board
        numPlayers = loaded_data.numPlayers
        hotseat_mode = loaded_data.hotseat_mode
        rise_of_ix = loaded_data.rise_of_ix
        immortality = loaded_data.immortality
        tleilaxuCardCostByGUID = loaded_data.tleilaxuCardCostByGUID
    end

    if setupDone then

        local seated_players = getPlayersBasedOnHotseat()

        for _, color in pairs(seated_players) do
            for _, pions in pairs(pion_reput) do
                local pion = pions[color]
                if pion then
                    pion.setLock(true)
                    pion.interactable = false
                end
            end

            local player = constants.alivePlayers[color]
            if player then
                if immortality == 1 then
                    player.tleilaxuTokens.interactable = false
                    player.researchTokens.interactable = false
                end
                if rise_of_ix == 1 then
                    player.cargo.interactable = false
                end
            end
        end
    end

    if not setupDone or numPlayers > 2 then
        for _, obj in pairs(getObjectFromGUID("0e6313").getObjects()) do
            if obj.hasTag("AutomataStuff") then
                obj.setInvisibleTo({
                    "Red", "Blue", "Green", "Yellow", "White", "Grey", "Brown",
                    "Pink", "Purple", "Orange"
                })
            end
        end
    end

    if tournament == 1 then worm.firstStep() end

    if score_board == 1 then
        Wait.time(function() worm.setOpenScoreBoard() end, 3)
    end

    if not setupDone then

        tournament = 0
        score_board = 0

        epic_mode = 0
        rise_of_ix = 1
        immortality = 1
        blitz = 0
        black_market = 0
        hiddenPicks = 0 -- New: if hidden pick is by default on or off

        -----------------Hidden Picks Var section------------------------
        leaders = constants.leaders

        -- leaders will be manipulated a lot: storing GUID only is a must
        leadersGUID = {
            leaders.yuna.GUID, leaders.hundro.GUID, leaders.memnon.GUID,
            leaders.ariana.GUID, leaders.ilesa.GUID, leaders.armand.GUID,
            leaders.paul.GUID, leaders.leto.GUID, leaders.tessia.GUID,
            leaders.rhombur.GUID, leaders.rabban.GUID, leaders.vladimir.GUID,
            leaders.ilban.GUID, leaders.helena.GUID
        }

        leaderPositions = {}

        -- initial positions of leaders on the table starting with top left Yuna, from left to right -- used to replace leaders on the table after moving them
        for i, leaderGuid in ipairs(leadersGUID) do
            leaderPositions[i] = getObjectFromGUID(leaderGuid).getPosition()
        end

        activateSelectLanguageButtons()
        activateButtons()
        activateEpicMode()
        activateRiseOfIx()
        activateImmortality()
        activateBlitz()
        activateBlackMarket()
        activateHiddenPicks() -- New
        activateNumberOfBan() -- New
        activateTournament()
        activateScoreBoard()
    end

    selectLanguage()
end)

function onLocaleChange()
    self.clearButtons()
    activateAllButtons()
end

function updateSave()
    local data_to_save = {
        setupDone = setupDone,
        tournament = tournament,
        score_board = score_board,
        numPlayers = numPlayers,
        hotseat_mode = hotseat_mode,
        rise_of_ix = rise_of_ix,
        immortality = immortality,
        tleilaxuCardCostByGUID = tleilaxuCardCostByGUID
    }
    saved_data = JSON.encode(data_to_save)
    self.script_state = saved_data
end

-----------------Number of ban buttons section------------------------
function activateNumberOfBan()
    if hiddenPicks == 1 then
        valueButtonParameters = {
            index = #self.getButtons(), -- (Indexes start at 0 here.)
            click_function = 'noFunction', -- click_function is mandatory: used dummy fonction since nil wouldn't work
            function_owner = self,
            label = '',
            position = {3, 0.5, 2.25},
            width = button_height,
            height = button_height,
            color = "Brown",
            font_color = text_color,
            font_size = text_size,
            tooltip = i18n("hiddenPicksNumberBanishedTooltip")
        }
        self.createButton(valueButtonParameters)
        valueButtonParameters.label = tostring(numberOfBan)
        self.editButton(valueButtonParameters)
        plusOneButtonParameters = {
            click_function = 'addOne',
            function_owner = self,
            label = "+",
            position = {3.7, 0.5, 2.25},
            width = button_height,
            height = button_height,
            color = "Brown",
            font_color = text_color,
            font_size = text_size
        }
        self.createButton(plusOneButtonParameters)
        minusOneButtonParameters = {
            click_function = 'minusOne',
            function_owner = self,
            label = "-",
            position = {2.3, 0.5, 2.25},
            width = button_height,
            height = button_height,
            color = "Brown",
            font_color = text_color,
            font_size = text_size
        }
        self.createButton(minusOneButtonParameters)
        activateButtons()
    end
end
-----------------Number of ban buttons section------------------------
function noFunction() -- used to make button showing number of ban do nothing when clicked on
end

function addOne()
    numberOfBan = math.min(numberOfBan + 1, maximum_value_ban)
    updateValue()
end

function minusOne()
    numberOfBan = math.max(numberOfBan - 1, minimum_value_ban)
    updateValue()
end

function updateValue()
    valueButtonParameters.label = tostring(numberOfBan)
    self.editButton(valueButtonParameters)
end

function fromIntRGB(r, g, b)
    return Color(r / 255, g / 255, b / 255)
end

function selectLanguage()
    if true then
        return
    end

    for _, player in ipairs(Player.getPlayers()) do
        if player.host then
            local choices = {}
            for i, language in ipairs(languages) do
                choices[#choices + 1] = language.name
            end

            player.showOptionsDialog(
                "Select a language",
                choices,
                choices[1],
                function(_, index, player_color)
                    setLanguage(languages[index])
                end)

            break
        end
    end
end

function activateSelectLanguageButtons()
    for i, language in pairs(languages) do
        local prefix = "[   ] "
        if i18n.getLocale() == language.locale then
            prefix = "[✓] "
        end
        self.createButton({
            label = prefix .. language.name,
            click_function = "setLanguage" .. tostring(i),
            function_owner = self,
            position = {-12.75, 0.5, 5.5 + i},
            color = fromIntRGB(128, 77, 0),
            font_color = fromIntRGB(204, 153, 0),
            height = button_height * 1.2,
            width = button_width * 0.75,
            font_size = text_size * 1,
        })
    end
end

function setLanguage1()
    setLanguage(languages[1])
end

function setLanguage2()
    setLanguage(languages[2])
end

function setLanguage(language)
    --log("setLanguage: " .. language.name)
    i18n.setLocale(language.locale)
    localeAssets.load()
    core.callOnAllLoadedObjects("onLocaleChange")
end

-----------------End Number of ban buttons section------------------------
function activateButtons()
    self.createButton({
        label = "SETUP",
        click_function = "Presetup",
        function_owner = self,
        position = {0, 0.5, -1.4},
        color = {1.00, 1.00, 1.00},
        font_color = {0.25, 0.25, 0.25},
        height = button_height * 2,
        width = button_width,
        font_size = text_size * 2.5,
        rotation = {0, 0, 0}
    })

end

function activateEpicMode()
    if epic_mode == 1 then
        self.createButton({
            label = "EPIC MODE         [✓]",
            click_function = "EpicMode",
            function_owner = self,
            position = {0, 0.5, -0.35},
            color = {0.651, 0, 0},
            font_color = text_color,
            height = button_height,
            width = 1800,
            font_size = text_size,
            rotation = {0, 0, 0}
        })
    elseif epic_mode == 0 then
        self.createButton({
            label = "EPIC MODE         [   ]",
            click_function = "EpicMode",
            function_owner = self,
            position = {0, 0.5, -0.35},
            color = button_color,
            font_color = text_color,
            height = button_height,
            width = 1800,
            font_size = text_size,
            rotation = {0, 0, 0}
        })
    end
end

function activateRiseOfIx()
    if rise_of_ix == 1 then
        self.createButton({
            label = "RISE OF IX          [✓]",
            click_function = "RiseOfIx",
            function_owner = self,
            position = {0, 0.5, 0.95},
            color = "Green",
            font_color = text_color,
            height = button_height,
            width = 1800,
            font_size = text_size,
            rotation = {0, 0, 0}
        })
    elseif rise_of_ix == 0 then
        self.createButton({
            label = "RISE OF IX          [   ]",
            click_function = "RiseOfIx",
            function_owner = self,
            position = {0, 0.5, 0.95},
            color = button_color,
            font_color = text_color,
            height = button_height,
            width = 1800,
            font_size = text_size,
            rotation = {0, 0, 0}
        })
    end
end

function activateImmortality()
    if immortality == 1 then
        self.createButton({
            label = "IMMORTALITY    [✓]",
            click_function = "Immortality",
            function_owner = self,
            position = {0, 0.5, 1.6},
            color = "Purple",
            font_color = text_color,
            height = button_height,
            width = 1800,
            font_size = text_size,
            rotation = {0, 0, 0}
        })
    elseif immortality == 0 then
        self.createButton({
            label = "IMMORTALITY    [   ]",
            click_function = "Immortality",
            function_owner = self,
            position = {0, 0.5, 1.6},
            color = button_color,
            font_color = text_color,
            height = button_height,
            width = 1800,
            font_size = text_size,
            rotation = {0, 0, 0}
        })
    end
end

function activateBlitz()
    if blitz == 1 then
        self.createButton({
            label = "BLITZ                  [✓]",
            click_function = "Blitz",
            function_owner = self,
            position = {0, 0.5, 0.3},
            color = "Orange",
            font_color = "White",
            height = button_height,
            width = 1800,
            font_size = text_size,
            rotation = {0, 0, 0}
        })
    elseif blitz == 0 then
        self.createButton({
            label = "BLITZ                  [   ]",
            click_function = "Blitz",
            function_owner = self,
            position = {0, 0.5, 0.3},
            color = button_color,
            font_color = "White",
            height = button_height,
            width = 1800,
            font_size = text_size,
            rotation = {0, 0, 0}
        })
    end
end

function activateBlackMarket()
    if black_market == 0 then
        self.createButton({
            label = "BLACK MARKET [   ]",
            click_function = "BlackMarket",
            function_owner = self,
            position = {0, 0.5, 2.90},
            color = {0, 0, 0},
            font_color = "Grey",
            height = button_height,
            width = 1800,
            font_size = text_size,
            rotation = {0, 0, 0}
        })
    elseif black_market == 1 then
        self.createButton({
            label = "BLACK MARKET [✓]",
            click_function = "BlackMarket",
            function_owner = self,
            position = {0, 0.5, 2.90},
            color = {0, 0, 0},
            font_color = "Yellow",
            height = button_height,
            width = 1800,
            font_size = text_size,
            rotation = {0, 0, 0}
        })
    end
end

-----------------New section------------------------
function activateHiddenPicks()
    if hiddenPicks == 1 then
        self.createButton({
            label = "HIDDEN PICKS    [✓]",
            click_function = "HiddenPicks",
            function_owner = self,
            position = {0, 0.5, 2.25},
            color = "Brown",
            font_color = "White",
            height = button_height,
            width = 1800,
            font_size = text_size,
            rotation = {0, 0, 0},
            tooltip = i18n("hiddenPicksTooltip")
        })
    elseif hiddenPicks == 0 then
        self.createButton({
            label = "HIDDEN PICKS    [   ]",
            click_function = "HiddenPicks",
            function_owner = self,
            position = {0, 0.5, 2.25},
            color = button_color,
            font_color = "White",
            height = button_height,
            width = 1800,
            font_size = text_size,
            rotation = {0, 0, 0},
            tooltip = i18n("hiddenPicksTooltip")
        })
    end
end

function activateTournament()
    button = {
        ["click_function"] = "Tournament",
        ["function_owner"] = self,
        ["position"] = {0, 0.5, 3.50},
        ["color"] = {0, 0, 0},
        ["height"] = button_height,
        ["width"] = 1800,
        ["font_size"] = text_size
    }
    if tournament == 1 then
        button["label"] = "TOURNAMENT   [✓]"
        button["font_color"] = "Orange"
    else
        button["label"] = "TOURNAMENT   [   ]"
        button["font_color"] = "Grey"
    end
    self.createButton(button)
end

function Tournament()
    self.clearButtons()
    if tournament == 0 then
        epic_mode = 0
        blitz = 0
        rise_of_ix = 1
        immortality = 0
        hiddenPicks = 1
        black_market = 0
        tournament = 1
    else
        tournament = 0
    end
    activateAllButtons()
end

function activateScoreBoard()
    button = {
        ["click_function"] = "ScoreBoard",
        ["function_owner"] = self,
        ["position"] = {0, 0.5, 4.15},
        ["color"] = {0, 0, 0},
        ["height"] = button_height,
        ["width"] = 1800,
        ["font_size"] = text_size,
        ["tooltip"] = i18n("scoreBoardTooltip")
    }
    if score_board == 1 then
        button["label"] = "SCOREBOARD    [✓]"
        button["font_color"] = "Blue"
    else
        button["label"] = "SCOREBOARD    [   ]"
        button["font_color"] = "Grey"
    end
    self.createButton(button)
end

function ScoreBoard()
    self.clearButtons()
    if score_board == 0 then
        score_board = 1
    else
        score_board = 0
    end
    activateAllButtons()
end

-----------------End section------------------------

function activateAllButtons()
    activateSelectLanguageButtons()
    activateButtons()
    activateEpicMode()
    activateRiseOfIx()
    activateImmortality()
    activateBlitz()
    activateBlackMarket()
    activateHiddenPicks() -- New
    activateNumberOfBan() -- New
    activateTournament()
    activateScoreBoard()
end

function EpicMode()
    self.clearButtons()
    -- activateButtons()
    if epic_mode == 0 then
        epic_mode = 1
        rise_of_ix = 1
        blitz = 0
    else
        epic_mode = 0
    end
    activateAllButtons()
end

function RiseOfIx()
    self.clearButtons()
    -- activateButtons()
    if rise_of_ix == 0 then
        rise_of_ix = 1
        minimum_value_ban = 1 -- New: adjust number of ban since there is less leaders in base game
        maximum_value_ban = 10 -- New
        numberOfBan = math.ceil(2 * numberOfBan) -- New
    else
        rise_of_ix = 0
        epic_mode = 0
        minimum_value_ban = 1 -- New
        maximum_value_ban = 4 -- New
        numberOfBan = math.floor(numberOfBan / 2.6) + 1 -- janky formula: conversion between # of ban base game vs rise of ix
    end
    activateAllButtons()
end

function Immortality()
    self.clearButtons()
    -- activateButtons()
    if immortality == 0 then
        immortality = 1
    else
        immortality = 0
    end
    activateAllButtons()
end

function Blitz()
    self.clearButtons()
    -- activateButtons()
    if blitz == 0 then
        blitz = 1
        epic_mode = 0
    else
        blitz = 0
    end
    activateAllButtons()
end

function BlackMarket()
    self.clearButtons()
    -- activateButtons()
    if black_market == 0 then
        black_market = 1
    else
        black_market = 0
    end
    activateAllButtons()
end

function HiddenPicks()
    self.clearButtons()
    -- activateButtons()
    if hiddenPicks == 0 then
        hiddenPicks = 1
    else
        hiddenPicks = 0
    end
    activateAllButtons()
end

numPlayers = nil
hotseat_mode = false

function Presetup(_, color)
    local players = getSeatedPlayers()
    for _, color in pairs(players) do
        if color ~= "Red" and color ~= "Green" and color ~= "Blue" and color ~=
            "Yellow" then
            broadcastToAll(i18n("notSeated"), "White")
            return 1
        end
    end
    if #players == 1 then

        Player[color].showOptionsDialog(i18n("soloHotseat"),
                                        {"Solo", "Hotseat"}, "Solo",
                                        function(text, index, player_color)
            if text == "Hotseat" then
                hotseat_mode = true
                numPlayers = 4
                local couleurs = {"Red", "Blue", "Green", "Yellow"}
                for _, color in ipairs(couleurs) do
                    hotseat[color].obj.setPosition(hotseat[color].pos)
                    hotseat[color].obj.setRotation({0, 0, 0})
                    hotseat[color].obj.setInvisibleTo({})
                end

            elseif text == "Solo" then
                numPlayers = 1
            end
            updateSave()
            Setup()
        end)
    else
        numPlayers = #players
        updateSave()
        Setup()
    end
end

function Setup()
    Global.call("resetRound")

    assert(numPlayers ~= nil)
    if numPlayers < 3 and blitz == 1 then
        broadcastToAll(i18n("notBlitz"), "White")
        return 1
    end
    self.clearButtons()

    for color, _ in pairs(constants.players) do
        helperModule.landTroopsFromOrbit(color, 3)
    end

    if immortality == 0 and epic_mode == 0 then
        for i, zone in ipairs(dune_cards_decks_zone) do
            for _, obj in ipairs(zone.getObjects()) do
                if obj.type == "Deck" or obj.type == "Card" then
                    obj.flip()
                    obj.setPositionSmooth(pos_starter_decks[i], false, false)
                end
            end
        end
    end
    -- Setup Hagal
    local pos_hagal = {10.85, 3, 45.99}
    if numPlayers < 3 then
        for _, obj in pairs(getObjectFromGUID("0e6313").getObjects()) do
            obj.setInvisibleTo({})
        end
    end
    if numPlayers == 2 then
        hagal_2P.setPosition(pos_hagal)
        hagal_everytime_except_immortality_1P.setPosition(pos_hagal)
        if rise_of_ix == 0 then
            hagal_without_rise_of_ix.setPosition(pos_hagal)
        else
            hagal_rise_of_ix.setPosition(pos_hagal)
            hagal_rise_of_ix_2P.setPosition(pos_hagal)
        end
    elseif numPlayers == 1 then
        hagal_1P.setPosition(pos_hagal)
        if immortality == 1 then
            hagal_immortality_1P.setPosition(pos_hagal)
        else
            hagal_everytime_except_immortality_1P.setPosition(pos_hagal)
        end
        if rise_of_ix == 0 then
            hagal_without_rise_of_ix.setPosition(pos_hagal)
        else
            hagal_rise_of_ix.setPosition(pos_hagal)
            hagal_rise_of_ix_1P.setPosition(pos_hagal)
        end
    end

    if rise_of_ix == 0 then RemoveIxContent() end

    if rise_of_ix == 1 then
        getObjectFromGUID(intrigue_ix).setPosition(intrigue_pos)
        getObjectFromGUID(imperium_deck_ix).setPosition(imperium_pos)
        Wait.time(movetechdecks, 1)
    end

    if immortality == 0 then
        getObjectFromGUID(imperium_deck_immortality).destruct()
        getObjectFromGUID(intrigue_immortality).destruct()
        GetDeckOrCardFromGUID(constants.zone_deck_tleilaxu).destruct()
        getObjectFromGUID(reclaimed_forces).destruct()

        for _, obj in ipairs(bene_tleilax_zone.getObjects()) do
            if obj.hasTag("BT Board") then obj.destruct() end
        end
        for _, ref in ipairs(atomics) do
            getObjectFromGUID(ref).destruct()
        end
        for _, ref in ipairs(experimentation_decks) do
            getObjectFromGUID(ref).destruct()
        end
        research_station_immortality.destruct()
        -- destroy acquire buttons of tleilaxu row
        getObjectFromGUID(constants.buy7_guid).destruct()
        getObjectFromGUID(constants.buy8_guid).destruct()
    end

    if immortality == 1 then
        memorizeOrderedTleilaxuDeck()

        getObjectFromGUID(intrigue_immortality).setPosition(intrigue_pos)
        getObjectFromGUID(imperium_deck_immortality).setPosition(imperium_pos)
        local deck = GetDeckOrCardFromGUID(constants.zone_deck_tleilaxu)
        deck.shuffle()
        Wait.time(function()
            local params1 = {}
            params1.position = constants.tleilaxuRow[1].pos
            params1.rotation = {0.00, 180.00, 0.00}
            deck.takeObject(params1)
        end, 0.35)
        Wait.time(function()
            local params2 = {}
            params2.position = constants.tleilaxuRow[2].pos
            params2.rotation = {0.00, 180.00, 0.00}
            deck.takeObject(params2)
        end, 0.7)

        for _, zone in ipairs(dune_cards_decks_zone) do
            for _, obj in ipairs(zone.getObjects()) do
                if obj.type == "Deck" or obj.type == "Card" then
                    obj.destruct()
                end
            end
        end

        for i, ref in ipairs(experimentation_decks) do
            local otherDeck = getObjectFromGUID(ref)
            otherDeck.flip()
            otherDeck.setPositionSmooth(pos_starter_decks[i], false, false)
        end

        research_station_immortality.setPosition({-0.07, 0.59, -1.89})
        research_station_immortality.setLock(true)
        -- Need to keep immo station interactable else the GET button of the normal station under will mess with the GET button of the new station
        -- research_station_immortality.interactable = false
    end

    if blitz == 0 and epic_mode == 0 then setupConflits(4, 5, 1) end

    if epic_mode == 0 then
        for _, ref in ipairs(epic_cards) do
            getObjectFromGUID(ref).destruct()
        end
    end

    if epic_mode == 1 then setupEpic() end

    if blitz == 1 then BlitzSetup() end

    if hiddenPicks == 1 then
        if numPlayers > 2 then -- setPlayerHiddenLeaderPickOrder have not been generalized enough to allow 2 player bans

            if rise_of_ix == 0 then

                leadersGUID = {
                    leaders.memnon.GUID, leaders.ariana.GUID, leaders.paul.GUID,
                    leaders.leto.GUID, leaders.rabban.GUID,
                    leaders.vladimir.GUID, leaders.ilban.GUID,
                    leaders.helena.GUID
                }

                leaderPositions = {}

                for i, leaderGuid in ipairs(leadersGUID) do
                    leaderPositions[i] =
                        getObjectFromGUID(leaderGuid).getPosition()
                end
            end

            Wait.time(moveAllLeadersToRandomizer, 1) -- move leader to randomizer for dramatic effect
            Wait.time(banRandomLeaders, 4) -- show, pause, then remove from game random leaders
            Wait.condition(replaceLeaders, -- remaining leader are replaced at the table in random order
                           function()
                return hiddenPicksOrderSet and leadersBanned
            end)
        else
            broadcastToAll(i18n("notHiddenPicks"), "White")
            hiddenPicks = 0
        end
    else
        if tournament == 1 then worm.firstStep() end
    end

    if score_board == 1 then
        Wait.time(function() worm.setOpenScoreBoard() end, 3)
    end

    Wait.time(Commune, 3)
end

function Commune()

    destructMissingPlayers()
    assert(zone_intrigue)
    GetDeckOrCardFromGUID(zone_intrigue).shuffle()
    GetDeckOrCardFromGUID(zone_imperium).shuffle()
    GetDeckOrCardFromGUID('6d8a2e').shuffle()
    GetDeckOrCardFromGUID('e6cfee').shuffle()
    GetDeckOrCardFromGUID('907f66').shuffle()
    GetDeckOrCardFromGUID('4f08fc').shuffle()
    Wait.time(ImperiumDeal, 0.5)
    Wait.time(function()
        local firstConflictAnchor = getObjectFromGUID("cb0478")
        firstConflictAnchor.call("ConflictButton")
    end, 3)
    Wait.time(startPickPlayer, 2)
    Wait.time(function()
        setupDone = true
        updateSave()
    end, 5)
end

function startPickPlayer()
    getObjectFromGUID("d84873").setInvisibleTo({})

    startLuaCoroutine(self, 'pick_a_player')
end

function pick_a_player()
    local fullPlayerList = Player.getPlayers()
    local count = 0
    local playerList = {}
    if hotseat_mode then
        playerList = {
            {color = "Blue"}, {color = "Red"}, {color = "Green"},
            {color = "Yellow"}
        }
        count = 4
    else
        for _, player in pairs(fullPlayerList) do
            if player.color == "Blue" or player.color == "Red" or player.color ==
                "Green" or player.color == "Yellow" then
                count = count + 1
                table.insert(playerList, player)
            end
        end
    end

    if count == 0 then
        broadcastToAll(i18n("noPlayers"))
        getObjectFromGUID("d84873").editButton({click_function = 'start'})

    elseif count == 1 then
        broadcastToAll(i18n("useDices"))
        marker.unlock()
        getObjectFromGUID("d84873").destruct()

    else

        local randomNumber = math.random(count)
        for i = 1, 10 do -- Animation débile avec 2 boucles XD
            for index, player in ipairs(playerList) do
                getObjectFromGUID("d84873").editButton({color = player.color})
                wait(3)
            end
        end

        local firstPlayer = playerList[randomNumber]
        local fpColor = firstPlayer.color

        broadcastToAll(i18n('firstPlayerBeginning') .. fpColor .. '!', fpColor)
        if hotseat_mode then Player.getPlayers()[1].changeColor(fpColor) end

        -----------------New section------------------------
        if getObjectFromGUID("4a3e76").getVar("hiddenPicks") == 1 then -- New: First player info necessary to determine leader picks player order
            local colorToPass = {fpColor}
            getObjectFromGUID("4a3e76").call("setPlayerHiddenLeaderPickOrder",
                                             colorToPass)
        end
        -----------------End section------------------------
        if not hotseat_mode then
            Turns.enable = true
            Turns.pass_turns = false
            Turns.turn_color = fpColor
        end
        Global.call("resetRound")
        marker.setPositionSmooth(position_marker[firstPlayer.color], false,
                                 false)
        getObjectFromGUID("d84873").destruct()
    end
    return 1 -- return pour la coroutine
end

function wait(numFrames) for i = 1, numFrames, 1 do coroutine.yield(0) end end

-----------------Setup New functions------------------------

-- called from First Player Picker when set up button is clicked: to find player leader pick order from first player and number of player
function setPlayerHiddenLeaderPickOrder(colorPassed)
    local firstPlayerColor = colorPassed[1]
    local arrayOfColor = {"Green", "Red", "Blue", "Yellow"}
    local arrayOfHidingStates = {1, 2, 3, 4} -- all possible hiding states value during pick phase: see Global
    if numPlayers == 4 then
        local indexFirstToPick = (findAnElementIndexInArray(firstPlayerColor,
                                                            arrayOfColor) %
                                     numPlayers) + 1
        for hiddingState in
            cyclicIterator(indexFirstToPick, arrayOfHidingStates) do -- cyclic iterator use closure to iterate all element of array in order starting from anywhere
            table.insert(playerOrderToPickHidingStates, hiddingState)
        end
        hiddenPicksOrderSet = true
    elseif numPlayers == 3 then
        local missingColor = findMissingElements(arrayOfColor,
                                                 getPlayersBasedOnHotseat())[1]
        for i, color in ipairs(arrayOfColor) do
            if color == missingColor then
                table.remove(arrayOfHidingStates, i)
                table.remove(arrayOfColor, i)
            end
        end
        local indexFirstToPick = (findAnElementIndexInArray(firstPlayerColor,
                                                            arrayOfColor) %
                                     numPlayers) + 1
        for hiddingState in
            cyclicIterator(indexFirstToPick, arrayOfHidingStates) do
            table.insert(playerOrderToPickHidingStates, hiddingState)
        end
        hiddenPicksOrderSet = true
    end
end

--[[
    Not a big fan of this approach. Putting / removing a thing from a bag means
    its script will be reloaded and onLoad / onDestroy will be called. As such,
    only passive objects should be put in bags, not leaders with dedicated
    scripts.
]]--
function moveAllLeadersToRandomizer()
    local t = 0 -- similar to the function setting up tech on the board
    for _, leaderGUID in ipairs(leadersGUID) do
        Wait.time(function()
            leaderRandomizer.putObject(getObjectFromGUID(leaderGUID))
        end, t)
        t = t + 0.18
    end
    hidingStateToPass = {5} -- make leaders invisible to all but Black
    Global.call("setHidingState", hidingStateToPass)
end

function banRandomLeaders()
    broadcastToAll(i18n("hiddenPicksRemoving"):format(numberOfBan), "Orange")
    leaderRandomizer.shuffle()
    local leaderToDeleteTable = {} -- temp storing leader to move after banned showned leader are "destroyed"
    for i = 1, numberOfBan do
        local leaderToDelete = leaderRandomizer.takeObject({
            position = leaderPositions[i],
            rotation = {0, 180, 0},
            smooth = true
        })
        table.insert(leaderToDeleteTable, leaderToDelete)
        removeAnElementInArray(leaderToDelete.guid, leadersGUID) -- update available leader pool
    end

    for i = 1, numberOfBan do -- at first I tried to destroy leader, big mistake as it would make all my leader array nil
        destroyObject(leaderToDeleteTable[i]) -- then i tried storing only guid in leaders, still had errors. Then tried to move them in
        -- fakeDestroy(leaderToDeleteTable[i]) -- trash bag: turns out object in bags loses their GUID.Then, I tried to stack banned leader
    end -- and make them invisible, but black would still see them. Best solution was to stack them
    leadersBanned = true

    --[[Wait.time(function()
        for i = 1, numberOfBan do -- at first I tried to destroy leader, big mistake as it would make all my leader array nil
            destroyObject(leaderToDeleteTable[i])         --then i tried storing only guid in leaders, still had errors. Then tried to move them in
            -- fakeDestroy(leaderToDeleteTable[i]) -- trash bag: turns out object in bags loses their GUID.Then, I tried to stack banned leader
        end -- and make them invisible, but black would still see them. Best solution was to stack them
        leadersBanned = true
    end, -- inside the boardgame manual and lock them. Only asset thick enough to hide tiles. I call
              waitTimeUntilBanDelete -- this the "Hidden Assets" method :) Leader are sill loaded in memory, and GUID still exist.
    )]]
end

--[[function fakeDestroy(objectToDestroy)
    objectToDestroy.clearButtons()
    objectToDestroy.setPosition(baseGameManualPosition)
    objectToDestroy.locked = true
end]]

function replaceLeaders() -- called after ban phase and after player pick a leader
    local numberOfLeaderPicked = getLengthTable(leaderChoices)
    if numberOfLeaderPicked < numPlayers then -- increment hiding state from one
        hidingStateToPass = {
            playerOrderToPickHidingStates[numberOfLeaderPicked + 1]
        }
        Global.call("setHidingState", hidingStateToPass)
        local hidingStateToColorTable = {
            [1] = "Green",
            [2] = "Red",
            [3] = "Blue",
            [4] = "Yellow"
        }
        local color =
            hidingStateToColorTable[playerOrderToPickHidingStates[numberOfLeaderPicked +
                1]]
        broadcastToAll(i18n(color:lower()) .. i18n("hiddenPickingLeader"), color)
    else
        hidingStateToPass = {6} -- no more player to choose
        Global.call("setHidingState", hidingStateToPass)
        broadcastToAll(i18n("hiddenPickOver"))
        if tournament == 1 then worm.firstStep() end
    end
    leaderRandomizer.shuffle()
    for i = 1, #leadersGUID do
        leaderRandomizer.takeObject({
            position = leaderPositions[i],
            rotation = {0, 180, 0},
            smooth = true
        })
    end
end

function updateLeaderChoices(varPassed) -- called from the ClaimLeader in all standards Leaders: keep in memory leader picked
    removeAnElementInArray(varPassed.leaderSelectedGUID, leadersGUID) -- update available leader pool
    for _, leaderGUID in ipairs(leadersGUID) do -- put in randomizer+replace on the table between every leader picks: players still see cursor when other players pick
        local leader = getObjectFromGUID(leaderGUID)
        if leader then
            leaderRandomizer.putObject(leader)
        else
            log("Not reinjecting nil leader " .. leaderGUID)
            log(leadersGUID)
        end
    end
    leaderChoices[varPassed.playerColor] = varPassed.leaderSelectedGUID -- update leader choices
    replaceLeaders()
    assert(numPlayers ~= nil)
    if numPlayers == getLengthTable(leaderChoices) then -- when all player picked: claim chosen Leader if it was a normal game (without hiddenPicks)+make them now visible
        hiddenPicks = 0
        for color, leaderChoiceGUID in pairs(leaderChoices) do
            varToPass = {leaderChoiceGUID = leaderChoiceGUID, color = color}
            getObjectFromGUID(leaderChoiceGUID).call("claimLeaderCall",
                                                     varToPass)
        end
    end
end

----------Utiliy functions--------------

function getLengthTable(table) -- determine size of an unordered table (#Table always give 0)
    length = 0
    for _, element in pairs(table) do length = length + 1 end
    return length
end

function findAnElementIndexInArray(element, arrayOfElements) -- return index (or nil) of an element in an array (with distinct value)
    local elementOrder = {}
    for i, v in ipairs(arrayOfElements) do elementOrder[v] = i end
    return elementOrder[element]
end

function cyclicIterator(first, Array) -- iterator that cycles through an entire array starting from any index
    i = -1
    return function() -- see closure + make your own iterator
        i = i + 1
        if i < #Array then
            return Array[(i + first - 1) % (#Array) + 1]
        else
            return nil
        end
    end
end

function findMissingElements(Array, ArrayWithMissingElement) -- used to compare find missing player color in 3 player game
    local A = {}
    local MissingElements = {}
    for _, element in ipairs(ArrayWithMissingElement) do A[element] = true end
    for _, element in ipairs(Array) do
        if A[element] == nil then table.insert(MissingElements, element) end
    end
    return MissingElements
end

function removeAnElementInArray(elementToDelete, arrayOfElements)
    for i, element in ipairs(arrayOfElements) do
        if element == elementToDelete then
            table.remove(arrayOfElements, i)
            return arrayOfElements
        end
    end
end
-----------------End section------------------------

function BlitzSetup()
    setupConflits(4, 3, 0)
    Wait.time(function()
        GetDeckOrCardFromGUID(zone_intrigue).shuffle()
        GetDeckOrCardFromGUID(zone_imperium).shuffle()

        getObjectFromGUID("e597dc").call("incrementVal")
        getObjectFromGUID("e597dc").call("incrementVal")
        getObjectFromGUID("c5c4ef").call("incrementVal")
        getObjectFromGUID("c5c4ef").call("incrementVal")
        getObjectFromGUID("fa5236").call("incrementVal")
        getObjectFromGUID("fa5236").call("incrementVal")
        getObjectFromGUID("576ccd").call("incrementVal")
        getObjectFromGUID("576ccd").call("incrementVal")

        local players = getPlayersBasedOnHotseat()

        for _, col in pairs(players) do

            GetDeckOrCardFromGUID(zone_intrigue).deal(1, col)

            t = 0.1
            for i = 1, 7, 1 do
                Wait.time(function()
                    GetDeckOrCardFromGUID(zone_imperium).deal(1, col)
                end, t)
                t = t + 0.1
            end

            for i = 1, 11, 1 do
                Wait.time(function() trash[col].deal(1, col) end, 1.6)
            end
        end
    end, 2)
end

function RemoveIxContent()
    -- supprimer et remplacer
    conflictThree.takeObject({position = pos_trash, index = 4})
    conflictTwo.takeObject({position = pos_trash, index = 10})
    conflictOne.takeObject({position = pos_trash, index = 4})
    conflictOne.takeObject({position = pos_trash, index = 4})

    Wait.time(function()
        getObjectFromGUID(intrigue_ix).destruct()
        getObjectFromGUID(imperium_deck_ix).destruct()

        getObjectFromGUID(leaders.yuna.GUID).destruct()
        getObjectFromGUID(leaders.hundro.GUID).destruct()
        getObjectFromGUID(leaders.ilesa.GUID).destruct()
        getObjectFromGUID(leaders.armand.GUID).destruct()
        getObjectFromGUID(leaders.tessia.GUID).destruct()
        getObjectFromGUID(leaders.rhombur.GUID).destruct()

        -- snoopers
        getObjectFromGUID("a58ce8").destruct()
        getObjectFromGUID("857f74").destruct()
        getObjectFromGUID("bed196").destruct()
        getObjectFromGUID("b10897").destruct()

        getObjectFromGUID("a8f306").destruct()
        getObjectFromGUID("1a3c82").destruct()
        getObjectFromGUID("a15087").destruct()
        getObjectFromGUID("734250").destruct()
        getObjectFromGUID("82789e").destruct()
        getObjectFromGUID("60f208").destruct()
        getObjectFromGUID("5469fb").destruct()
        getObjectFromGUID("71a414").destruct()
        getObjectFromGUID("3371d8").destruct()
        getObjectFromGUID("4575f3").destruct()
        getObjectFromGUID("7b3fa2").destruct()
        getObjectFromGUID("73a68f").destruct()
        getObjectFromGUID("366237").destruct()
        tech_tiles_en.destruct()
        tech_tiles_fr.destruct()
        getObjectFromGUID("d75455").destruct()

        getObjectFromGUID("e9096d").destruct()
        getObjectFromGUID("68e424").destruct()
        getObjectFromGUID("34281d").destruct()
        getObjectFromGUID("8fa76f").destruct()

        getObjectFromGUID("a139cd").setState(2)

    end, 0.1)

end

function setupConflits(a, b, c)
    --log("--- setupConflits ---")
    conflictThree.shuffle()
    conflictTwo.shuffle()
    conflictOne.shuffle()
    nb_conflit_iii = GetDeckOrCardFromGUID("07e239").getQuantity()
    if a < nb_conflit_iii then
        for i = 1, a do
            conflictThree.takeObject({
                position = {conflictDeckLocation[1], 2, conflictDeckLocation[3]}
            })
        end
        destroyObject(conflictThree.remainder)
    end
    if blitz == 1 then
        Wait.time(function()
            trash["Everyone"].takeObject({
                position = {
                    conflictDeckLocation[1], 2.3, conflictDeckLocation[3]
                },
                rotation = {0, 180, 180},
                smooth = false,
                guid = manigance
            })
        end, 0.9)
    end
    Wait.time(function()
        conflictTwo.shuffle()
        for i = 1, b do
            conflictTwo.takeObject({
                position = {
                    conflictDeckLocation[1], 2.6, conflictDeckLocation[3]
                }
            })
        end
        destroyObject(conflictTwo)
    end, 1)
    Wait.time(function()
        conflictOne.shuffle()
        if c ~= 0 then
            for i = 1, c do
                conflictOne.takeObject({
                    position = {
                        conflictDeckLocation[1], 3.2, conflictDeckLocation[3]
                    }
                })
            end
        end
        destroyObject(conflictOne)
    end, 2)
end

function memorizeOrderedTleilaxuDeck()
    local tleilaxuCardCostByName = {
        beguiling_pheromones = 3,
        dogchair = 2,
        contaminator = 1,
        corrino_genes = 1,
        face_dancer = 2,
        face_dancer_initiate = 1,
        from_the_tanks = 2,
        ghola = 3,
        guild_impersonator = 2,
        industrial_espionage = 1,
        scientific_breakthrough = 3,
        slig_farmer = 2,
        stitched_horror = 3,
        subject_x_137 = 2,
        tleilaxu_infiltrator = 2,
        twisted_mentat = 4,
        unnatural_reflexes = 3,
        usurper = 4,
        piter_genius_advisor = 3
    }

    local currentLocale = i18n.getLocale()
    local resources = localeAssets[currentLocale]

    local deck = getObjectFromGUID(constants.tleilaxu_deck)
    for i, card in ipairs(deck.getObjects()) do
        local name = resources.tleilaxuOrderedCards[i]
        local cost = tleilaxuCardCostByName[name]
        tleilaxuCardCostByGUID[card.guid] = cost
    end
end

function getTleilaxuCardPrice(card)
    local guid = card.getGUID()
    local cost = tleilaxuCardCostByGUID[guid]
    if not cost then
        cost = 0
        log("No memorized Tleilaxu card for GUID " .. guid)
    end
    return cost
end

function setupEpic()
    setupConflits(5, 5, 0)
    replaceEpic()
end

function replaceEpic()

    if immortality == 0 then
        for i, zone in ipairs(dune_cards_decks_zone) do
            for _, obj in ipairs(zone.getObjects()) do
                if obj.type == "Deck" then
                    obj.takeObject({
                        position = pos_starter_decks[i],
                        smooth = false,
                        flip = true
                    })
                end
            end
        end

        -- Delete the only Dune card left wich is not a container anymore so could not delete it above

        Wait.time(function()
            for i, zone in ipairs(dune_cards_decks_zone) do
                for _, obj in ipairs(zone.getObjects()) do
                    if obj.type == "Card" then obj.destruct() end
                end
            end
        end, 0.5)

        for i, ref in ipairs(epic_cards) do
            local card = getObjectFromGUID(ref)
            card.flip()
            card.setPosition(pos_starter_decks[i])
        end
    else
        local i = 1
        for _, player in pairs(constants.players) do
            local card = getObjectFromGUID(epic_cards[i])
            card.setPosition(player.pos_discard)
            card.setInvisibleTo({})
            i = i + 1
        end
    end

    Wait.time(movetroops, 2)
    Wait.time(function()
        GetDeckOrCardFromGUID(zone_intrigue).shuffle()
        GetDeckOrCardFromGUID(zone_intrigue).deal(1)
    end, 5)
end

function movetroops()
    for color, _ in pairs(constants.players) do
        helperModule.landTroopsFromOrbit(color, 2)
    end
end

function movetechdecks()
    local techs = nil
    if i18n.getLocale() == 'en' then
        techs = tech_tiles_en
    elseif i18n.getLocale() == 'fr' then
        techs = tech_tiles_fr
    end
    techs.randomize()

    local centerPos = constants.getLandingPositionFromGUID(constants.ixPlanetBoard)
    local techSlotPos = {
        centerPos + Vector(1.69, 3.02, 2.35),
        centerPos + Vector(1.69, 3.02, 0.30),
        centerPos + Vector(1.69, 3.02, -1.75)
    }

    local t = 0
    for i = 1, 5, 1 do
        Wait.time(function()
          for j = 1, 3 do
              techs.takeObject({
                  position = techSlotPos[j],
                  rotation = {0, 180, 180}
              })
          end
        end, t)
        t = t + 0.25
    end
    Wait.time(function()
        for j = 1, 3 do
            techs.takeObject({
                position = techSlotPos[j],
                rotation = {0, 180, 0}
            })
        end
        destroyObject(tech_tiles_en)
        destroyObject(tech_tiles_fr)
    end, t)

    Wait.time(function()
        local ixPlanetBoard = getObjectFromGUID("d75455")
        ixPlanetBoard.call("createTechZones")
    end, 1)
end

function ImperiumDeal()
    local deck_imperium = GetDeckOrCardFromGUID(zone_imperium)
    deck_imperium.shuffle()

    for i = 1, 5 do
      Wait.time(function()
          deck_imperium.takeObject({
              position = constants.imperiumRow[i].pos,
              rotation = Vector(0, 180, 0)
          })
      end, i * 0.35)
    end

    if black_market == 1 then
        local blackMarketBoard = getObjectFromGUID("ab7ac5")
        blackMarketBoard.call("initBlackMarket")
    end
end

function destructMissingPlayers()
    local seated_players = getPlayersBasedOnHotseat()

    for _, color in pairs(seated_players) do
        for _, faction in pairs(pion_reput) do
            faction[color].setLock(true)
            faction[color].interactable = false
        end

        if immortality == 1 then
            constants.players[color].tleilaxuTokens.interactable = false
            constants.players[color].researchTokens.interactable = false
        end
        if rise_of_ix == 1 then constants.players[color].cargo.interactable = false end
    end

    if numPlayers < 4 then
        -- Destroy one by one to give time to the physic engine to stack the tokens nicely.
        chainDestruct({FP1, FP2, FP3, FP4})
    end

    for color, _ in pairs(hand_players) do
        if not hasValue(seated_players, color) then
            hand_players[color].destruct()
        end
    end

    if numPlayers > 2 then
        for color, player in pairs(constants.players) do
            if not hasValue(seated_players, color) then
                player.board.call("shutdown", {rise_of_ix, immortality})
                for _, pions in pairs(pion_reput) do
                    pions[color].destruct()
                end
            end
        end
    end
end

function chainDestruct(objects)
    assert(objects)
    local destroyLater = function()
        local object = objects[1]
        assert(object)
        object.destruct()
        table.remove(objects, 1)
        chainDestruct(objects)
    end
    if #objects > 0 then
        Wait.time(destroyLater, 0.5)
    end
end

function hasValue(tab, val)
    for _, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

function updateScores() if score_board == 1 then worm.updateScores() end end

function getPlayersBasedOnHotseat()
    local players = nil

    if hotseat_mode then
        -- TODO Of course not!
        players = {'Red', 'Blue', 'Green', 'Yellow'}
    else
        players = getSeatedPlayers()
    end

    return players

end

function createHighCouncilCard(parameters)
    return localeAssets.createHighCouncilCard(
        parameters.color,
        parameters.hasRestrictedOrdnance,
        parameters.position)
end

function createSeatOfPowerCard(parameters)
    return localeAssets.createSeatOfPowerCard(
        parameters.color,
        parameters.prestige,
        parameters.position)
end