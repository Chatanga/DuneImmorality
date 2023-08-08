local Deck = {}

--[[
-- Tous les decks sont multi-instanciés.
customDecks.fr = {
    -- starter without dune planet
    starter = LocaleAssets.createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2029469358268121216/D25AA65312D89EB7CEED36D451618E731A674BED/", 4, 2),
    -- dune planet
    starterDunePlanet = LocaleAssets.createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2029469358268102690/98F5861E28F3167495D3F2890879072BF3A84E60/", 2, 2),
    -- base without foldspace, nor liasion, nor the spice must flow, but with Jessica of Arrakis and Duncan Loyal Blade
    imperium = LocaleAssets.createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2029469358268104070/CC2D301CA075930201B3883D82F4C6E1A0837273/", 10, 7),
    imperiumFoldedSpace = LocaleAssets.createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2029469358268101016/AE481C2ED19B085E2669F22420FD282982FD11A9/", 3, 2),
    imperiumArrakisLiasion = LocaleAssets.createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2029469358268100070/D7411DB495E6EB13D6B64F5E46CCF69FF322039F/", 4, 2),
    imperiumTheSpiceMustFlow = LocaleAssets.createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2029469358268101681/B6E08F8328DB699C60A8F058E88AA6443BA2F716/", 5, 2),
    intrigue = LocaleAssets.createIntrigueCustomDeck("http://cloud-3.steamusercontent.com/ugc/2029469995670901713/13659DD01D152A8B8055B894B247CB1D254D3752/", 8, 5),
    -- ix without control the spice, but with Boundless Ambition
    ixImperium = LocaleAssets.createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2029469358268106254/C54BCAB79869547E728509123AC47EDB32E79BF5/", 6, 6),
    ixImperiumControlTheSpice = LocaleAssets.createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2029469358243272739/DD5ED3E5FD12F0A1C4F42750E766E83564248E07/", 1, 1),
    ixIntrigue = LocaleAssets.createIntrigueCustomDeck("http://cloud-3.steamusercontent.com/ugc/2029469358271904511/3D33B3E59811CEDC64A53F104D31190E76676C64/", 5, 4),
    -- tleilax without experimentation
    teilaxImperium = LocaleAssets.createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2063250888850083256/142F50245296C2EE1F5ABAD8CE93982AC0592110/", 6, 5),
    teilaxImperiumExperimentation = LocaleAssets.createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2063250888850160556/BF6DF4E8EF5B8C8F5BB6952166C559694A61BA04/", 2, 2),
    -- tleilax without reclaimed forces
    teilaxResearch = LocaleAssets.createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2063250888847571463/639814906915DFA557375A3F7963C9DE53301D57/", 4, 5),
    -- reclaimed forces
    teilaxResearchReclaimedForces = LocaleAssets.createImperiumCustomDeck("http://cloud-3.steamusercontent.com/ugc/2063250888847577276/60812AEA733FF5558BA9190E47CBD474EBF38C94/", 1, 1),
    teilaxIntrigue = LocaleAssets.createIntrigueCustomDeck("http://cloud-3.steamusercontent.com/ugc/2063250888848685998/83BA634F05FC7A14933153A18B7AEF83E07E3C14/", 6, 3),
}
]]--

function Deck.loadCustomDecks(loader)
    assert(false, "TODO")
end

--[[
LocaleAssets.fr = {
    leaders = {
        yuna = "http://cloud-3.steamusercontent.com/ugc/2029467636440254532/CDAED205706CD8E32700B8A56C9BD387C5D72696/",
        hundro = "http://cloud-3.steamusercontent.com/ugc/2029467636440287844/A64F2D77C6F482F31B12EC97C2DEEBBDF45AF3F9/",
        memnon = "http://cloud-3.steamusercontent.com/ugc/2029468089262094752/36DB26EE194B780C9C879C74FC634C15433CE06A/",
        ariana = "http://cloud-3.steamusercontent.com/ugc/2029467636440480689/3C1CA2B3506FB7AD8B1B40DB1414F7461F6974C8/",
        ilesa = "http://cloud-3.steamusercontent.com/ugc/2029468089262092469/7A0FCC4CA1D0CAF19C8066776DC23A9631000997/",
        armand = "http://cloud-3.steamusercontent.com/ugc/2029467636440253818/98401D1D00D15DB3512E48BBD63B9922EE17EF71/",
        paul = "http://cloud-3.steamusercontent.com/ugc/2029468089262095259/008429F21B2898E4C2982EC7FB1AF422FDD85E24/",
        leto = "http://cloud-3.steamusercontent.com/ugc/2029467636440402017/152B626A2D773B224CFFF878E35CEFDBB6F67505/",
        tessia = "http://cloud-3.steamusercontent.com/ugc/2029468089262093029/6C34345ADF23EBD567DE0EE662B4920906F721F0/",
        rhombur = "http://cloud-3.steamusercontent.com/ugc/2029467636440274764/58A6CF3EB6EBDEAC4B5826C0D21408A3CC02E678/",
        rabban = "http://cloud-3.steamusercontent.com/ugc/2029467636440364572/68A9DE7E06DA5857EE51ECB978E13E3921A15B1A/",
        vladimir = "http://cloud-3.steamusercontent.com/ugc/2029467636440341651/6F682C5E5C1ADE0B9B1B8FAC80B9525A6748C351/",
        ilban = "http://cloud-3.steamusercontent.com/ugc/2029467636440255083/F0F052CCAB7005F4D30879BF639AFACEDFF70A80/",
        helena = "http://cloud-3.steamusercontent.com/ugc/5095292505135062968/A069B3ECF1B4E9C42D2453E28EA13257F397B3F3/",
    },
    books = {
        base = "http://cloud-3.steamusercontent.com/ugc/1824518181295638806/3CE976153C0C7A7C5816837734D1C89D1DD17A09/",
        faq = "http://cloud-3.steamusercontent.com/ugc/1822281124425591600/F81AB6FC61160924B9A9E4D829A02384CF09F5C1/",
        riseOfIx = "http://cloud-3.steamusercontent.com/ugc/1822280989496634217/C7ACC9E96C2C162A13761F3C7C285AB9CF6D1C96/",
        immortality = "http://cloud-3.steamusercontent.com/ugc/2063250888843830350/8542ECE0CBCE22F7B43D305B72718C7D689C1128/",
        blitz = nil
    },
    cards = {
        startDecks = {{deck = customDecks.fr.starter, luaIndexes = LocaleAssets.range(1, 8)}},
        duneTheDesertPlanetCards = {{deck = customDecks.fr.starterDunePlanet, luaIndexes = LocaleAssets.range(1, 2)}},
        foldspaceDeck = {{deck = customDecks.fr.imperiumFoldedSpace, luaIndexes = LocaleAssets.range(1, 6)}},
        arrakisLiaisonDeck = {{deck = customDecks.fr.imperiumArrakisLiasion, luaIndexes = LocaleAssets.range(1, 8)}},
        theSpiceMustFlowDeck = {{deck = customDecks.fr.imperiumTheSpiceMustFlow, luaIndexes = LocaleAssets.range(1, 10)}},
        baseImperiumDeck = {{deck = customDecks.fr.imperium, luaIndexes = LocaleAssets.range(1, 69)}},
        -- cardJessicaOfArrakis = {deck = customDecks.fr.imperium, luaIndex = 7},
        -- cardDuncanLoyalBlade = {deck = customDecks.fr.imperium, luaIndex = 69},
        ixImperiumDeck = {{deck = customDecks.fr.ixImperium, luaIndexes = LocaleAssets.range(1, 36)}},
        -- cardBoundlessAmbition = {deck = customDecks.fr.ixImperium, luaIndex = 20},
        immortalityImperiumDeck = {{deck = customDecks.fr.teilaxImperium, luaIndexes = LocaleAssets.range(1, 30)}},
        tleilaxuDeck = {{deck = customDecks.fr.teilaxResearch, luaIndexes = LocaleAssets.range(1, 19)}},
        -- cardPeterGeniusAdvisor = {deck = customDecks.fr.teilaxResearch, luaIndex = 11},
        reclaimedForcesCard = {deck = customDecks.fr.teilaxResearchReclaimedForces, luaIndex = 1},
        immortalityIntrigueDeck = {{deck = customDecks.fr.teilaxIntrigue, luaIndexes = LocaleAssets.range(1, 15)}},
        ixIntrigueDeck = {{deck = customDecks.fr.ixIntrigue, luaIndexes = LocaleAssets.range(1, 17)}},
        baseIntrigueDeck = {{deck = customDecks.fr.intrigue, luaIndexes = LocaleAssets.range(1, 40)}},
        controlTheSpiceCards = {deck = customDecks.fr.ixImperiumControlTheSpice, luaIndex = 1},
        experimentationCards = {{deck = customDecks.fr.teilaxImperiumExperimentation, luaIndexes = LocaleAssets.range(1, 2)}},
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
]]--

return Deck
