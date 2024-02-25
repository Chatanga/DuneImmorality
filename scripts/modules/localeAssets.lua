local localeAssets = {}

local core = require("Core")

local constants = require("Constants")

local i18n = require("i18n")
require("locales")

local imperiumCardBack = "http://cloud-3.steamusercontent.com/ugc/2093667512238502565/C3DC7A02CF378129569B414967C9BE25097C6E77/"

local intrigueCardBack = "http://cloud-3.steamusercontent.com/ugc/2093667512238521846/D63B92C616541C84A7984026D757DB03E79532DD/"

local customDecks = {}

local customDeckBaseId = 0

function nextCustomDeckId()
    customDeckBaseId = customDeckBaseId + 1
    return customDeckBaseId
end

function createImperiumCustomDeck(faceUrl, width, height)
    return {
        FaceURL = faceUrl,
        BackURL = imperiumCardBack,
        NumWidth = width,
        NumHeight = height,
        BackIsHidden = true,
        UniqueBack = false,
        Type = 0
    }
end

function createIntrigueCustomDeck(faceUrl, width, height)
    return {
        FaceURL = faceUrl,
        BackURL = intrigueCardBack,
        NumWidth = width,
        NumHeight = height,
        BackIsHidden = true,
        UniqueBack = false,
        Type = 0
    }
end

function generateCardData(guid, card, customDeck, customDeckId, cardId)
    -- assert(guid, "guid")
    assert(customDeck, "customDeck")
    assert(customDeckId, "customDeckId")
    assert(cardId, "cardId")

    local tags = {}
    if card then
        tags = card.getTags()
    elseif customDeck.BackURL == imperiumCardBack then
        tags = {"Imperium"}
    elseif customDeck.BackURL == intrigueCardBack then
        tags = {"Intrigue"}
    end

    local data = {
        Name = "Card",
        Transform = {
            posX = 0,
            posY = 0,
            posZ = 0,
            rotX = 0,
            rotY = 0,
            rotZ = 0,
            scaleX = 1,
            scaleY = 1,
            scaleZ = 1
        },
        Nickname = "",
        Description = "",
        GMNotes = "",
        AltLookAngle = {
            x = 0.0,
            y = 0.0,
            z = 0.0
        },
        ColorDiffuse = {
            r = 0.713235259,
            g = 0.713235259,
            b = 0.713235259
        },
        Tags = tags,
        LayoutGroupSortIndex = 0,
        Value = 0,
        Locked = false,
        Grid = true,
        Snap = true,
        IgnoreFoW = false,
        MeasureMovement = false,
        DragSelectable = true,
        Autoraise = true,
        Sticky = true,
        Tooltip = true,
        GridProjection = false,
        HideWhenFaceDown = true,
        Hands = true,
        CardID = cardId,
        SidewaysCard = false,
        CustomDeck = {
            [tostring(customDeckId)] = customDeck
        }
    }

    if guid then
        -- Will create a clone with a type such as "Card(Clone)".
        data.GUID = guid
    end

    if card then
        data.Nickname = card.getName()
        data.Description = card.getDescription()
        data.GMNotes = card.getGMNotes()
    end

    return data
end

function reloadCard(guid, definition)
    local card = getObjectFromGUID(guid)
    assert(card, "No card with GUID " .. tostring(guid))
    assert(definition.NumWidth == 1 and definition.NumHeight == 1, "Cannot reload a single card from a whole deck!")

    local parameters = {
        face = definition.FaceURL,
        back = definition.BackURL
    }

    card.setCustomObject(parameters)
    card.reload()
end

function createCard(definition, position, whenCreated)
    local customDeck = definition.deck
    local index = definition.luaIndex - 1

    local customDeckId = nextCustomDeckId()
    local cardId = tostring(customDeckId * 100 + index)

    local data = generateCardData(nil, nil, customDeck, customDeckId, cardId)

    local spawnParameters = {
        data = data,
        position = position,
        rotation = {0, 180, 0},
        scale = {1.05, 1.00, 1.05},
        callback_function = whenCreated
    }

    spawnObjectData(spawnParameters)
end

function mutateCard(guid, definition, whenMutated)
    local card = getObjectFromGUID(guid)
    assert(card, "No card with GUID " .. tostring(guid))

    local customDeck = definition.deck
    local index = definition.luaIndex - 1

    local customDeckId = nextCustomDeckId()
    local cardId = tostring(customDeckId * 100 + index)

    local data = generateCardData(guid, card, customDeck, customDeckId, cardId)

    local spawnParameters = {
        data = data,
        position = card.getPosition(),
        rotation = card.getRotation(),
        scale = card.getScale(),
        callback_function = whenMutated
    }

    card.destruct()

    spawnObjectData(spawnParameters)
end

function mutateDeck(guid, contributions)
    local deck = getObjectFromGUID(guid)
    assert(deck, "No deck with GUID " .. tostring(guid))

    local cards = deck.getObjects()
    assert(cards, "No cards!")

    local data = {
        GUID = guid,
        Name = "Deck",
        Transform = {
            posX = 0,
            posY = 0,
            posZ = 0,
            rotX = 0,
            rotY = 0,
            rotZ = 0,
            scaleX = 1,
            scaleY = 1,
            scaleZ = 1
        },
        Nickname = deck.getName(),
        Description = "",
        GMNotes = "",
        AltLookAngle = {
            x = 0.0,
            y = 0.0,
            z = 0.0
        },
        ColorDiffuse = {
            r = 0.713235259,
            g = 0.713235259,
            b = 0.713235259
        },
        Tags = deck.getTags(),
        LayoutGroupSortIndex = 0,
        Value = 0,
        Locked = false,
        Grid = true,
        Snap = true,
        IgnoreFoW = false,
        MeasureMovement = false,
        DragSelectable = true,
        Autoraise = true,
        Sticky = true,
        Tooltip = true,
        GridProjection = false,
        HideWhenFaceDown = true,
        Hands = false,
        SidewaysCard = false,
        DeckIDs = {},
        CustomDeck = {},
        LuaScript = "",
        LuaScriptState = "",
        XmlUI = "",
        ContainedObjects = {}
    }

    local cardCount = 0
    for _, contribution in ipairs(contributions) do
        cardCount = cardCount + #contribution.luaIndexes
    end
    assert(cardCount == #cards, "Mutated deck " .. guid .. " has now " .. cardCount .. " cards instead of " .. #cards .. ".")

    cardCount = 0
    for _, contribution in ipairs(contributions) do
        local customDeckId = nextCustomDeckId()
        data.CustomDeck[tostring(customDeckId)] = contribution.deck

        for _, luaIndex in ipairs(contribution.luaIndexes) do
            cardCount = cardCount + 1
            local cardGuid = cards[cardCount].guid
            local index = luaIndex - 1
            local cardId = tostring(customDeckId * 100 + index)
            data.DeckIDs[#data.DeckIDs + 1] = tostring(cardId)
            local cardData = generateCardData(cardGuid, nil, contribution.deck, customDeckId, cardId)
            data.ContainedObjects[#data.ContainedObjects + 1] = cardData
        end
    end

    local spawnParameters = {
        data = data,
        position = deck.getPosition(),
        rotation = deck.getRotation(),
        scale = deck.getScale(),
        callback_function = function (newDeck)
            --log("New deck " .. deck.getGUID() .. " has " .. #newDeck.getObjects() .. " cards.")
        end
    }

    deck.destruct()

    spawnObjectData(spawnParameters)
end

function mututateBook(guid, url)
    local book = getObjectFromGUID(guid)
    assert(book, "No book with GUID " .. tostring(guid))

    local data = {
        GUID = book.getGUID(),
        Name = "Custom_PDF",
        Transform = {
            posX = 13.0,
            posY = 0.6125308,
            posZ = -29.0,
            rotX = 3.646483e-06,
            rotY = 179.999985,
            rotZ = -5.09549864e-06,
            scaleX = 1.09796119,
            scaleY = 1.0,
            scaleZ = 1.09796119
        },
        Nickname = "",
        Description = "",
        GMNotes = "",
        AltLookAngle = {
            x = 0.0,
            y = 0.0,
            z = 0.0
        },
        ColorDiffuse = {
            r = 1.0,
            g = 1.0,
            b = 1.0
        },
        LayoutGroupSortIndex = 0,
        Value = 0,
        Locked = true,
        Grid = true,
        Snap = true,
        IgnoreFoW = false,
        MeasureMovement = false,
        DragSelectable = true,
        Autoraise = true,
        Sticky = true,
        Tooltip = true,
        GridProjection = false,
        HideWhenFaceDown = false,
        Hands = false,
        CustomPDF = {
            PDFUrl = url,
            PDFPassword = "",
            PDFPage = 0,
            PDFPageOffset = 0
        },
        LuaScript = "",
        LuaScriptState = "",
        XmlUI = ""
    }

    local spawnParameters = {
        data = data,
        position = book.getPosition(),
        rotation = book.getRotation(),
        scale = book.getScale()
    }

    book.destruct()

    spawnObjectData(spawnParameters)
end

function localeAssets.getCurrentResources()
    local currentLocale = i18n.getLocale()
    --log("localeAssets.load() -> currentLocale = " .. tostring(currentLocale))

    -- TODO Replace with multiple localized assets.
    local turnSummarySheet = getObjectFromGUID("e43180")
    if currentLocale == 'fr' then
        turnSummarySheet.setRotation({0, 180, 180})
    else
        turnSummarySheet.setRotation({0, 180, 0})
    end

    local resources = localeAssets[currentLocale]
    if not resources then
        log("No asset for locale " .. currentLocale)
    end

    return resources
end

function localeAssets.load()
    local resources = localeAssets.getCurrentResources()
    if not resources then
        return
    end

    -- Books
    for bookName, bookGUID in pairs(constants.books) do
        if bookGUID then
            mututateBook(bookGUID, resources.books[bookName])
        end
    end

    -- Leaders tiles
    for leaderName, leader in pairs(constants.leaders) do
        local leaderTile = getObjectFromGUID(leader.GUID)
        if leaderTile then
            local params = {image = resources.leaders[leaderName]}
            leaderTile.setCustomObject(params)
            core.safeReload(leaderTile)
        else
            log("No leader tile with GUID " .. tostring(leader.GUID))
        end
    end

    -- Cards
    customDeckBaseId = 900

    for _, GUID in ipairs(constants.starter_decks) do
        mutateDeck(GUID, resources.cards.cardsStarterImperium)
    end

    for _, GUID in ipairs(constants.dune_decks) do
        mutateDeck(GUID, resources.cards.cardsDunePlanet)
    end

    mutateDeck(constants.cardsFoldspace, resources.cards.cardsFoldspace)
    mutateDeck(constants.cardsLiaison, resources.cards.cardsLiaison)
    mutateDeck(constants.cardsTSMF, resources.cards.cardsTSMF)
    mutateDeck(constants.cardsBaseImperium, resources.cards.cardsBaseImperium)
    mutateDeck(constants.imperium_deck_ix, resources.cards.cardsIxImperium)
    mutateDeck(constants.imperium_deck_immortality, resources.cards.cardsImmortalityImperium)

    mutateCard(constants.reclaimed_forces, resources.cards.cardReclaimedForces)

    for _, guidEpic in ipairs(constants.epic_cards) do
        mutateCard(guidEpic, resources.cards.cardControlTheSpice)
    end

    for _, GUID in ipairs(constants.experimentation_decks) do
        mutateDeck(GUID, resources.cards.cardsExperimentation)
    end

    mutateDeck(constants.tleilaxu_deck, resources.cards.cardsTleilaxu)

    mutateDeck(constants.intrigue_base, resources.cards.cardsBaseIntrigue)
    mutateDeck(constants.intrigue_ix, resources.cards.cardsIxIntrigue)
    mutateDeck(constants.intrigue_immortality, resources.cards.cardsImmortalityIntrigue)

    Wait.time(function()
        local hiddenZone = getObjectFromGUID("e88cd0")
        for _, obj in pairs(hiddenZone.getObjects()) do
            obj.setInvisibleTo({
                "Red", "Blue", "Green", "Yellow", "White", "Grey", "Brown",
                "Pink", "Purple", "Orange"
            })
        end
    end, 0.5)

end

function localeAssets.createSeatOfPowerCard(color, prestige, position)
    local resources = localeAssets.getCurrentResources()
    if not resources then
        return
    end

    local player = constants.players[color]

    for _, object in ipairs(player.playZone.getObjects()) do
        if object.hasTag("Special") then
            player.seatOfPowerCard = object
        end
    end

    if 0 < prestige and prestige <= 4 then
        local name = "cardSeatOfPower" .. tostring(prestige)
        if player.seatOfPowerCard then
            mutateCard(player.seatOfPowerCard.getGUID(), resources.cards[name], function (card)
                player.seatOfPowerCard = card
                --card.setTags({"Special"})
                card.setLock(true)
            end)
        else
            createCard(resources.cards[name], position, function (card)
                player.seatOfPowerCard = card
                card.setTags({"Special"})
                card.setLock(true)
            end)
        end
    elseif player.seatOfPowerCard then
        player.seatOfPowerCard.destruct()
        player.seatOfPowerCard = nil
    end
end

function range(first, last, gaps)
    local indexes = {}
    local isGap = {}
    if gaps then
        for _, i in ipairs(gaps) do
            isGap[i] = true
        end
    end
    for i = first, last do
        if not isGap[i] then
            indexes[#indexes + 1] = i
        end
    end
    return indexes
end

customDecks.en = {
    -- starter with dune planet
    starter = createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2093667512238504518/BF3BA9C253ED953533B90D94DD56D0BAD4021B3C/", 4, 2),
    -- base with foldspace, liasion, the spice must flow
    imperium = createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2093667512238501976/6F98BCE051343A3D07D58D6BC62A8FCA2C9AAE1A/", 8, 6),
    intrigue = createIntrigueCustomDeck("http://cloud-3.steamusercontent.com/ugc/2093667512238521425/A63AE0E1069DA1279FDA3A5DE6A0E073F45FC8EF/", 7, 5),
    -- ix with control the spice
    ixImperium = createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2093667512238502753/9DFCC56F20D09D60CF2B9D9050CB9640176F71B6/", 7, 5),
    ixIntrigue = createIntrigueCustomDeck("http://cloud-3.steamusercontent.com/ugc/2093667512238520522/CE27F1B6D4D455A2D00D6E13FABEB72E6B9F05F1/", 5, 4),
    -- tleilax with experimentation
    teilaxImperium = createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2093667512238503099/E758512421B5CB27BBA228EF5F1880A7F3DC564D/", 6, 5),
    -- tleilax with reclaimed forces
    teilaxResearch = createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2093667512238505265/D9BD273651404E7DE7F0E22B36F2D426D82B07A8/", 4, 5),
    teilaxIntrigue = createIntrigueCustomDeck("http://cloud-3.steamusercontent.com/ugc/2093667512238520324/9FED90CD510F26618717CEB63FDA744CE916C6BA/", 6, 2),
    -- special cards
    seatOfPowerDeck = createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2093667512238505419/E7E6E09C7D61392154D16277F3FEA3E4ADFCADAC/", 4, 1),
    thumperDeck = createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2027231506426140597/EED43686A0319F3C194702074F2D2B3E893642F7/", 1, 1)
}

localeAssets.en = {
    leaders = {
        yuna = "http://cloud-3.steamusercontent.com/ugc/2093667512238499982/FA54B129B168169E3D58BA61536FCC0BB5AB7D34/",
        hundro = "http://cloud-3.steamusercontent.com/ugc/2093667512238498857/6A89778D9C4BB8AC07FE503D48A4483D13DF6E5B/",
        memnon = "http://cloud-3.steamusercontent.com/ugc/2120691978822940968/8431F61C545067A4EADC017E6295CB249A2BD813/",
        ariana = "http://cloud-3.steamusercontent.com/ugc/2093667512238500886/2A9043877494A7174A32770C39147FAE941A39A2/",
        ilesa = "http://cloud-3.steamusercontent.com/ugc/2120691978822941275/94B1575474BEEF1F1E0FE0860051932398F47CA5/",
        armand = "http://cloud-3.steamusercontent.com/ugc/2093667512238498308/310C6B6E85920F9FC1A94896A335D34C3CFA6C15/",
        paul = "http://cloud-3.steamusercontent.com/ugc/2120691978822941103/F597DBF1EB750EA14EA03F231D0EBCF07212A5AC/",
        leto = "http://cloud-3.steamusercontent.com/ugc/2093667512238500319/8CBD932BE474529D6C14A3AA8C01BD8503EBEBC6/",
        tessia = "http://cloud-3.steamusercontent.com/ugc/2120691978822940841/29817122A32B50C285EE07E0DAC32FDE9A237CEC/",
        rhombur = "http://cloud-3.steamusercontent.com/ugc/2093667512238501024/0C06A30D74BD774D9B4F968C00AEC8C0817D4C77/",
        rabban = "http://cloud-3.steamusercontent.com/ugc/2093667512238498058/DCF40F0D8C34B14180DC33B369DCC8AA4FD3FB55/",
        vladimir = "http://cloud-3.steamusercontent.com/ugc/2093667512238499582/B5899377296C2BFAC0CF48E18AA3773AA8E998DE/",
        ilban = "http://cloud-3.steamusercontent.com/ugc/2120691978822940718/15624E52D08F594943A4A6332CBD68B2A1645441/",
        helena = "http://cloud-3.steamusercontent.com/ugc/2120691978822940558/63750F22F1DFBA9D9544587C0B2B8D65E157EC00/",
    },
    books = {
        base = "http://cloud-3.steamusercontent.com/ugc/2093667512238529711/6DC9056BCDF73234C2283CDABA688AEAD7F8D965/",
        faq = "http://cloud-3.steamusercontent.com/ugc/2120691978803955385/E7A19D5D6697389A853535BEFCBAC33C2B973492/",
        riseOfIx = "http://cloud-3.steamusercontent.com/ugc/2093667512238528798/F55C0BC54AD4F658FFF7A511D5740BF93A0CB19E/",
        immortality = "http://cloud-3.steamusercontent.com/ugc/2093667512238529000/DE61CF514A5C813C2E46CAA7C7FF76DDB3069641/",
        blitz = nil
    },
    cards = {
        cardsStarterImperium = {{deck = customDecks.en.starter, luaIndexes = {2, 2, 3, 4, 4, 5, 6, 7}}},
        cardsDunePlanet = {{deck = customDecks.en.starter, luaIndexes = {1, 1}}},
        cardsFoldspace = {{deck = customDecks.en.imperium, luaIndexes = {5, 5, 5, 5, 5, 5}}},
        cardsLiaison = {{deck = customDecks.en.imperium, luaIndexes = {6, 6, 6, 6, 6, 6, 6, 6}}},
        cardsTSMF = {{deck = customDecks.en.imperium, luaIndexes = {7, 7, 7, 7, 7, 7, 7, 7, 7, 7}}},
        cardsBaseImperium = {{deck = customDecks.en.imperium, luaIndexes = {
            1, 1, 2, 3, 3, 4, 4, 8, 8, 9, 9, 10, 10,
            11, 11, 12, 12, 13, 13, 13, 14, 14, 15, 15, 16, 16, 17, 17, 18, 18, 19, 20,
            21, 22, 23, 23, 23, 24, 25, 25, 26, 27, 28, 28, 29, 30, 30,
            32, 32, 33, 34, 35, 35, 36, 37, 38, 39, 40,
            41, 42, 43, 44, 44, 45, 46, 46, 46}},
            {deck = customDecks.en.ixImperium, luaIndexes = {31}},
            -- {deck = customDecks.en.ixImperium, luaIndexes = {32, 32}}, No need to add it, the one (32) in the main texture is already the fixed version.
            {deck = customDecks.en.ixImperium, luaIndexes = {34}},
            {deck = customDecks.en.thumperDeck, luaIndexes = {1}}
        },
        -- cardJessicaOfArrakis = {deck = customDecks.en.ixImperium, luaIndex = 31},
        -- cardDuncanLoyalBlade = {deck = customDecks.en.ixImperium, luaIndex = 34},
        cardsIxImperium = {{deck = customDecks.en.ixImperium, luaIndexes = {
            1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
            11, 12, 13, 14, 15, 16, 16, 17, 18, 18, 19, 20,
            21, 22, 23, 23, 24, 24, 25, 26, 26, 27, 28, 29, 29, 30
        }}},
        -- cardBoundlessAmbition = {deck = customDecks.en.ixImperium, luaIndex = 1},
        -- cardMissionariaProtectiva = {deck = customDecks.en.ixImperium, luaIndex = 32},
        cardsImmortalityImperium = {{deck = customDecks.en.teilaxImperium, luaIndexes = {
            1, 2, 3, 4, 5, 6, 6, 8, 9, 9, 10,
            11, 12, 13, 14, 15, 16, 17, 17, 18, 19, 20,
            21, 22, 22, 23, 24, 25, 25, 26
        }}},
        cardsTleilaxu = {{deck = customDecks.en.teilaxResearch, luaIndexes = {
            1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
            12, 13, 14, 15, 16, 17, 18, 19, 20
        }}},
        -- cardPeterGeniusAdvisor = {deck = customDecks.en.teilaxResearch, luaIndex = 20},
        cardReclaimedForces = {deck = customDecks.en.teilaxResearch, luaIndex = 11},
        cardsImmortalityIntrigue = {{deck = customDecks.en.teilaxIntrigue, luaIndexes = {
            1, 2, 3, 4, 5, 5, 6, 6, 7, 7, 8, 9, 10, 11, 11
        }}},
        cardsIxIntrigue = {{deck = customDecks.en.ixIntrigue, luaIndexes = {
            1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
            11, 12, 13, 14, 15, 16, 17
        }}},
        cardsBaseIntrigue = {{deck = customDecks.en.intrigue, luaIndexes = {
            1, 2, 3, 3, 4, 5, 6, 7, 7, 8, 9, 9, 10,
            11, 12, 12, 12, 13, 14, 14, 15, 16, 17, 18, 19, 20,
            21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
            31, 32, 33, 34
        }}},
        cardControlTheSpice = {deck = customDecks.en.ixImperium, luaIndex = 33},
        cardsExperimentation = {{deck = customDecks.en.teilaxImperium, luaIndexes = {7, 7}}},
        cardSeatOfPower1 = {deck = customDecks.en.seatOfPowerDeck, luaIndex = 1},
        cardSeatOfPower2 = {deck = customDecks.en.seatOfPowerDeck, luaIndex = 2},
        cardSeatOfPower3 = {deck = customDecks.en.seatOfPowerDeck, luaIndex = 3},
        cardSeatOfPower4 = {deck = customDecks.en.seatOfPowerDeck, luaIndex = 4}
    },
    tleilaxuOrderedCards = {
        "beguiling_pheromones",
        "dogchair",
        "contaminator",
        "corrino_genes",
        "face_dancer",
        "face_dancer_initiate",
        "from_the_tanks",
        "ghola",
        "guild_impersonator",
        "industrial_espionage",
        "scientific_breakthrough",
        "slig_farmer",
        "stitched_horror",
        "subject_x_137",
        "tleilaxu_infiltrator",
        "twisted_mentat",
        "unnatural_reflexes",
        "usurper",
        "piter_genius_advisor"
    }
}

-- Tous les decks sont multi-instanciés.
customDecks.fr = {
    -- starter without dune planet
    starter = createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2093667512238503531/D25AA65312D89EB7CEED36D451618E731A674BED/", 4, 2),
    -- dune planet
    starterDunePlanet = createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2093667512238502926/98F5861E28F3167495D3F2890879072BF3A84E60/", 2, 2),
    -- base without foldspace, nor liason, nor the spice must flow, but with Jessica of Arrakis and Duncan Loyal Blade
    imperium = createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2093667512238504179/CC2D301CA075930201B3883D82F4C6E1A0837273/", 10, 7),
    imperiumFoldedSpace = createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2093667512238503304/AE481C2ED19B085E2669F22420FD282982FD11A9/", 3, 2),
    imperiumArrakisLiasion = createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2093667512238504363/D7411DB495E6EB13D6B64F5E46CCF69FF322039F/", 4, 2),
    imperiumTheSpiceMustFlow = createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2093667512238504759/B6E08F8328DB699C60A8F058E88AA6443BA2F716/", 5, 2),
    intrigue = createIntrigueCustomDeck("http://cloud-3.steamusercontent.com/ugc/2093667512238521654/13659DD01D152A8B8055B894B247CB1D254D3752/", 8, 5),
    -- ix without control the spice, but with Boundless Ambition
    ixImperium = createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2093667512238503692/C54BCAB79869547E728509123AC47EDB32E79BF5/", 6, 6),
    ixImperiumControlTheSpice = createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2093667512238505114/DD5ED3E5FD12F0A1C4F42750E766E83564248E07/", 1, 1),
    ixIntrigue = createIntrigueCustomDeck("http://cloud-3.steamusercontent.com/ugc/2093667512238520112/3D33B3E59811CEDC64A53F104D31190E76676C64/", 5, 4),
    -- tleilax without experimentation
    teilaxImperium = createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2093667512238503969/142F50245296C2EE1F5ABAD8CE93982AC0592110/", 6, 5),
    teilaxImperiumExperimentation = createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2093667512238504928/BF6DF4E8EF5B8C8F5BB6952166C559694A61BA04/", 2, 2),
    -- tleilax without reclaimed forces, but with Piter, Genius Advisor
    teilaxResearch = createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2093667512238501306/639814906915DFA557375A3F7963C9DE53301D57/", 4, 5),
    -- reclaimed forces
    teilaxResearchReclaimedForces = createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2093667512238501804/60812AEA733FF5558BA9190E47CBD474EBF38C94/", 1, 1),
    teilaxIntrigue = createIntrigueCustomDeck("http://cloud-3.steamusercontent.com/ugc/2093667512238520919/83BA634F05FC7A14933153A18B7AEF83E07E3C14/", 6, 3),
    -- special cards
    seatOfPowerDeck = createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2093667512238501163/AE3985811F9E7436655ABCCC1664368BBFF7395C/", 4, 1)
}

localeAssets.fr = {
    leaders = {
        yuna = "http://cloud-3.steamusercontent.com/ugc/2093667512238500769/CDAED205706CD8E32700B8A56C9BD387C5D72696/",
        hundro = "http://cloud-3.steamusercontent.com/ugc/2093667512238499395/A64F2D77C6F482F31B12EC97C2DEEBBDF45AF3F9/",
        memnon = "http://cloud-3.steamusercontent.com/ugc/2093667512238496955/36DB26EE194B780C9C879C74FC634C15433CE06A/",
        ariana = "http://cloud-3.steamusercontent.com/ugc/2093667512238497102/3C1CA2B3506FB7AD8B1B40DB1414F7461F6974C8/",
        ilesa = "http://cloud-3.steamusercontent.com/ugc/2093667512238497232/7A0FCC4CA1D0CAF19C8066776DC23A9631000997/",
        armand = "http://cloud-3.steamusercontent.com/ugc/2093667512238498599/98401D1D00D15DB3512E48BBD63B9922EE17EF71/",
        paul = "http://cloud-3.steamusercontent.com/ugc/2093667512238499852/008429F21B2898E4C2982EC7FB1AF422FDD85E24/",
        leto = "http://cloud-3.steamusercontent.com/ugc/2093667512238500640/152B626A2D773B224CFFF878E35CEFDBB6F67505/",
        tessia = "http://cloud-3.steamusercontent.com/ugc/2093667512238499203/6C34345ADF23EBD567DE0EE662B4920906F721F0/",
        rhombur = "http://cloud-3.steamusercontent.com/ugc/2093667512238497351/58A6CF3EB6EBDEAC4B5826C0D21408A3CC02E678/",
        rabban = "http://cloud-3.steamusercontent.com/ugc/2093667512238498462/68A9DE7E06DA5857EE51ECB978E13E3921A15B1A/",
        vladimir = "http://cloud-3.steamusercontent.com/ugc/2093667512238497473/6F682C5E5C1ADE0B9B1B8FAC80B9525A6748C351/",
        ilban = "http://cloud-3.steamusercontent.com/ugc/2093667512238498742/F0F052CCAB7005F4D30879BF639AFACEDFF70A80/",
        helena = "http://cloud-3.steamusercontent.com/ugc/2093667512238499726/A069B3ECF1B4E9C42D2453E28EA13257F397B3F3/",
    },
    books = {
        base = "http://cloud-3.steamusercontent.com/ugc/2093667512238530720/3CE976153C0C7A7C5816837734D1C89D1DD17A09/",
        faq = "http://cloud-3.steamusercontent.com/ugc/2120691978803956085/F81AB6FC61160924B9A9E4D829A02384CF09F5C1/",
        riseOfIx = "http://cloud-3.steamusercontent.com/ugc/2093667512238529495/C7ACC9E96C2C162A13761F3C7C285AB9CF6D1C96/",
        immortality = "http://cloud-3.steamusercontent.com/ugc/2093667512238528611/8542ECE0CBCE22F7B43D305B72718C7D689C1128/",
        blitz = nil
    },
    cards = {
        cardsStarterImperium = {{deck = customDecks.fr.starter, luaIndexes = range(1, 8)}},
        cardsDunePlanet = {{deck = customDecks.fr.starterDunePlanet, luaIndexes = range(1, 2)}},
        cardsFoldspace = {{deck = customDecks.fr.imperiumFoldedSpace, luaIndexes = range(1, 6)}},
        cardsLiaison = {{deck = customDecks.fr.imperiumArrakisLiasion, luaIndexes = range(1, 8)}},
        cardsTSMF = {{deck = customDecks.fr.imperiumTheSpiceMustFlow, luaIndexes = range(1, 10)}},
        cardsBaseImperium = {
            {deck = customDecks.fr.imperium, luaIndexes = range(1, 69)},
            {deck = customDecks.en.thumperDeck, luaIndexes = {1}}},
        -- cardJessicaOfArrakis = {deck = customDecks.fr.imperium, luaIndex = 7},
        -- cardDuncanLoyalBlade = {deck = customDecks.fr.imperium, luaIndex = 69},
        cardsIxImperium = {{deck = customDecks.fr.ixImperium, luaIndexes = range(1, 36)}},
        -- cardBoundlessAmbition = {deck = customDecks.fr.ixImperium, luaIndex = 20},
        cardsImmortalityImperium = {{deck = customDecks.fr.teilaxImperium, luaIndexes = range(1, 30)}},
        cardsTleilaxu = {{deck = customDecks.fr.teilaxResearch, luaIndexes = range(1, 19)}},
        -- cardPeterGeniusAdvisor = {deck = customDecks.fr.teilaxResearch, luaIndex = 11},
        cardReclaimedForces = {deck = customDecks.fr.teilaxResearchReclaimedForces, luaIndex = 1},
        cardsImmortalityIntrigue = {{deck = customDecks.fr.teilaxIntrigue, luaIndexes = range(1, 15)}},
        cardsIxIntrigue = {{deck = customDecks.fr.ixIntrigue, luaIndexes = range(1, 17)}},
        cardsBaseIntrigue = {{deck = customDecks.fr.intrigue, luaIndexes = range(1, 40)}},
        cardControlTheSpice = {deck = customDecks.fr.ixImperiumControlTheSpice, luaIndex = 1},
        cardsExperimentation = {{deck = customDecks.fr.teilaxImperiumExperimentation, luaIndexes = range(1, 2)}},
        cardSeatOfPower1 = {deck = customDecks.fr.seatOfPowerDeck, luaIndex = 1},
        cardSeatOfPower2 = {deck = customDecks.fr.seatOfPowerDeck, luaIndex = 2},
        cardSeatOfPower3 = {deck = customDecks.fr.seatOfPowerDeck, luaIndex = 3},
        cardSeatOfPower4 = {deck = customDecks.fr.seatOfPowerDeck, luaIndex = 4}
    },
    tleilaxuOrderedCards = {
        "beguiling_pheromones",
        "dogchair",
        "contaminator",
        "corrino_genes",
        "face_dancer",
        "face_dancer_initiate",
        "from_the_tanks",
        "ghola",
        "guild_impersonator",
        "industrial_espionage",
        "piter_genius_advisor",
        "scientific_breakthrough",
        "slig_farmer",
        "stitched_horror",
        "subject_x_137",
        "tleilaxu_infiltrator",
        "twisted_mentat",
        "unnatural_reflexes",
        "usurper"
    }
}

return localeAssets