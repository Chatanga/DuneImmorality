local Helper = require("utils.Helper")

local Deck = {
    imperium = {
        -- starter without dune planet
        starter = { "http://cloud-3.steamusercontent.com/ugc/2093667512238503531/D25AA65312D89EB7CEED36D451618E731A674BED/", 4, 2 },
        -- dune planet
        starterDunePlanet = { "http://cloud-3.steamusercontent.com/ugc/2029469358268102690/98F5861E28F3167495D3F2890879072BF3A84E60/", 2, 2 },
        -- base without foldspace, nor liasion, nor the spice must flow, but with Jessica of Arrakis and Duncan Loyal Blade
        imperium = { "http://cloud-3.steamusercontent.com/ugc/2027233408244872967/CC2D301CA075930201B3883D82F4C6E1A0837273/", 10, 7 },
        imperiumFoldedSpace = { "http://cloud-3.steamusercontent.com/ugc/2029469358268101016/AE481C2ED19B085E2669F22420FD282982FD11A9/", 3, 2 },
        imperiumArrakisLiasion = { "http://cloud-3.steamusercontent.com/ugc/2029469358268100070/D7411DB495E6EB13D6B64F5E46CCF69FF322039F/", 4, 2 },
        imperiumTheSpiceMustFlow = { "http://cloud-3.steamusercontent.com/ugc/2029469358268101681/B6E08F8328DB699C60A8F058E88AA6443BA2F716/", 5, 2 },
        -- new release card
        newImperium = { "http://cloud-3.steamusercontent.com/ugc/2027231506426140597/EED43686A0319F3C194702074F2D2B3E893642F7/", 1 , 1 },
        -- ix without control the spice, but with Boundless Ambition
        ixImperium = { "http://cloud-3.steamusercontent.com/ugc/2029469358268106254/C54BCAB79869547E728509123AC47EDB32E79BF5/", 6, 6 },
        ixImperiumControlTheSpice = { "http://cloud-3.steamusercontent.com/ugc/2029469358243272739/DD5ED3E5FD12F0A1C4F42750E766E83564248E07/", 1, 1 },
        -- tleilax without experimentation
        immortalityImperium = { "http://cloud-3.steamusercontent.com/ugc/2063250888850083256/142F50245296C2EE1F5ABAD8CE93982AC0592110/", 6, 5 },
        immortalityImperiumExperimentation = { "http://cloud-3.steamusercontent.com/ugc/2063250888850160556/BF6DF4E8EF5B8C8F5BB6952166C559694A61BA04/", 2, 2 },
        -- tleilax without reclaimed forces
        tleilaxResearch = { "http://cloud-3.steamusercontent.com/ugc/2063250888847571463/639814906915DFA557375A3F7963C9DE53301D57/", 4, 5 },
        -- reclaimed forces
        tleilaxResearchReclaimedForces = { "http://cloud-3.steamusercontent.com/ugc/2063250888847577276/60812AEA733FF5558BA9190E47CBD474EBF38C94/", 1, 1 },
    },
    intrigue = {
        intrigue = { "http://cloud-3.steamusercontent.com/ugc/2029469995670901713/13659DD01D152A8B8055B894B247CB1D254D3752/", 8, 5 },
        ixIntrigue = { "http://cloud-3.steamusercontent.com/ugc/2029469358271904511/3D33B3E59811CEDC64A53F104D31190E76676C64/", 5, 4 },
        immortalityIntrigue = { "http://cloud-3.steamusercontent.com/ugc/2063250888848685998/83BA634F05FC7A14933153A18B7AEF83E07E3C14/", 6, 3 },
    },
    conflict1 = {
        conflict = { "http://cloud-3.steamusercontent.com/ugc/1892102591130036834/F1C0913A589ADB0A0532DFB8FAA7E9D7942CF6CB/", 3, 2 },
    },
    conflict2 = {
        conflict = { "http://cloud-3.steamusercontent.com/ugc/1892102591130038927/B1CD3F41933A9DD44522934B5F6CF3C5FF77A51C/", 6, 2 },
    },
    conflict3 = {
        conflict = { "http://cloud-3.steamusercontent.com/ugc/1892102591130041563/F1BEAE6266E75B7A2F5DE511DB4FEB25A2CD486B/", 3, 2 },
    },
    hagal = {
        hagal = { "http://cloud-3.steamusercontent.com/ugc/2093667512242251793/66020C11E4FEA2D22744020D27465DCC2BB02BBE/", 7, 2 },
        hagal_wealth = { "http://cloud-3.steamusercontent.com/ugc/2093667512242255699/46014D79D2E1D2F68F4BF5740A0A9E1FED6E540D/", 1, 1 },
        hagal_arrakeen2p = { "http://cloud-3.steamusercontent.com/ugc/2093667512242249369/8C2F363EFD82AB1A80A01A3E527E6A4ACE369643/", 1, 1 },
        ixHagal_dreadnought1p = { "http://cloud-3.steamusercontent.com/ugc/2093667512242248109/5E6323692811F0530FB83FAE286162BDF6010E47/", 1, 1, Vector(0.88, 1, 0.83) },
        ixHagal_dreadnought2p = { "http://cloud-3.steamusercontent.com/ugc/2093667512242250123/1A8E52049F9853C42DA1D0A2E26AF50F7B503773/", 1, 1, Vector(0.9, 1, 0.83) },
        ixHagal_techNegogiation1p = { "http://cloud-3.steamusercontent.com/ugc/2093667512242251059/5A6FB1D7F4148F22FEF453500A6627132379BD6B/", 1, 1, Vector(0.9, 1, 0.83) },
        ixHagal_interstellarShipping = { "http://cloud-3.steamusercontent.com/ugc/2093667512242253195/E595B3E111F6E8A0C057C99FF03BB18FFA1327B7/", 1, 1, Vector(0.9, 1, 0.83) },
        ixHagal_foldspaceAndInterstellarShipping = { "http://cloud-3.steamusercontent.com/ugc/2093667512242255101/D7FAA1F3EB842A0EB4A2966F134EB58ACD966AFC/", 1, 1, Vector(0.9, 1, 0.83) },
        ixHagal_smugglingAndInterstellarShipping = { "http://cloud-3.steamusercontent.com/ugc/2093667512242252529/978923957A87E0CB3DFAA25DF543FD863DA1EC95/", 1, 1, Vector(0.9, 1, 0.83) },
        imortalityHagal = { "http://cloud-3.steamusercontent.com/ugc/2093667512242256335/36ABA3AD7A540FF6960527C1E77565F10BB2C6CB/", 2, 2 },
        hagal_churn = { "http://cloud-3.steamusercontent.com/ugc/2093667512242246852/43CA7B78F12F01CED26D1B57D3E62CAC912D846C/", 1, 1 },
    },
    tech = {
        windtraps = { "http://cloud-3.steamusercontent.com/ugc/1825651231292473674/1357A12AE8B805DDA4B35054C7A042EB60ED8D93/", 1, 1 },
        flagship = { "http://cloud-3.steamusercontent.com/ugc/1825651231292476487/3D450BD068CF618EB58032CA790EC8CFB512C6ED/", 1, 1 },
        sonicSnoopers = { "http://cloud-3.steamusercontent.com/ugc/1825651231292477186/735DAD89216E331EE1461EEBC94E579B3F65D898/", 1, 1 },
        artillery = { "http://cloud-3.steamusercontent.com/ugc/1825651231292477913/1DD4BAFBF228984A2AE7D7A04C6BD98E5817CB75/", 1, 1 },
        troopTransports = { "http://cloud-3.steamusercontent.com/ugc/1825651231292478564/5F8994647E6BE9B8DFE12775816BA8634DBEF803/", 1, 1 },
        spySatellites = { "http://cloud-3.steamusercontent.com/ugc/1825651231292479218/A4A7827D2C9E2D084FEF39864C901F858DBAC7A0/", 1, 1 },
        invasionShips = { "http://cloud-3.steamusercontent.com/ugc/1825651231292479844/CA3C07205ECEFC22C759E350C47B58052D1CB3EC/", 1, 1 },
        chaumurky = { "http://cloud-3.steamusercontent.com/ugc/1825651231292480787/CC1342B27E230372F8A10A0BD35ADF796F0FF6A5/", 1, 1 },
        detonationDevices = { "http://cloud-3.steamusercontent.com/ugc/1825651231292481379/985702313B721E7343ED01C603AF5C8EFF43C2F4/", 1, 1 },
        spaceport = { "http://cloud-3.steamusercontent.com/ugc/1825651231292481965/A906AB650BF19DEA2E39F86F873940143C2CF814/", 1, 1 },
        minimicFilm = { "http://cloud-3.steamusercontent.com/ugc/1825651231292482559/74A896440084439B2C557D8651EB8125A64E85B1/", 1, 1 },
        holoprojectors = { "http://cloud-3.steamusercontent.com/ugc/1825651231292483128/89575580CD49633CE5473B76CDDFA1A0A2503030/", 1, 1 },
        memocorders = { "http://cloud-3.steamusercontent.com/ugc/1825651231292483644/2644950194120A67CDC6BF7019D951FCF605DBFF/", 1, 1 },
        disposalFacility = { "http://cloud-3.steamusercontent.com/ugc/1825651231292484234/57A51864E207970E7DCB9ACCAE68AFAE48F2CD61/", 1, 1 },
        holtzmanEngine = { "http://cloud-3.steamusercontent.com/ugc/1825651231292484883/B202AC36308C95EF1CA325DAE9318DCB6C5229EE/", 1, 1 },
        trainingDrones = { "http://cloud-3.steamusercontent.com/ugc/1825651231292485600/B877582FA7ECB542E046FB96EB8488D511DEDF1C/", 1, 1 },
        shuttleFleet = { "http://cloud-3.steamusercontent.com/ugc/1825651231292486244/9E39289A6CED8A977E8206E1B5FD1A14F4BA55F8/", 1, 1 },
        restrictedOrdnance = { "http://cloud-3.steamusercontent.com/ugc/1825651231292486891/1F4181A709E103B8807D6D6FBF3C6BA62A4C20F9/", 1, 1 },
    },
    leader = {
        yunaMoritani = { "http://cloud-3.steamusercontent.com/ugc/2029467636440254532/CDAED205706CD8E32700B8A56C9BD387C5D72696/", 1, 1 },
        hundroMoritani = { "http://cloud-3.steamusercontent.com/ugc/2029467636440287844/A64F2D77C6F482F31B12EC97C2DEEBBDF45AF3F9/", 1, 1 },
        memnonThorvald = { "http://cloud-3.steamusercontent.com/ugc/2029468089262094752/36DB26EE194B780C9C879C74FC634C15433CE06A/", 1, 1 },
        arianaThorvald = { "http://cloud-3.steamusercontent.com/ugc/2029467636440480689/3C1CA2B3506FB7AD8B1B40DB1414F7461F6974C8/", 1, 1 },
        ilesaEcaz = { "http://cloud-3.steamusercontent.com/ugc/2029468089262092469/7A0FCC4CA1D0CAF19C8066776DC23A9631000997/", 1, 1 },
        armandEcaz = { "http://cloud-3.steamusercontent.com/ugc/2029467636440253818/98401D1D00D15DB3512E48BBD63B9922EE17EF71/", 1, 1 },
        paulAtreides = { "http://cloud-3.steamusercontent.com/ugc/2029468089262095259/008429F21B2898E4C2982EC7FB1AF422FDD85E24/", 1, 1 },
        letoAtreides = { "http://cloud-3.steamusercontent.com/ugc/2029467636440402017/152B626A2D773B224CFFF878E35CEFDBB6F67505/", 1, 1 },
        tessiaVernius = { "http://cloud-3.steamusercontent.com/ugc/2029468089262093029/6C34345ADF23EBD567DE0EE662B4920906F721F0/", 1, 1 },
        rhomburVernius = { "http://cloud-3.steamusercontent.com/ugc/2029467636440274764/58A6CF3EB6EBDEAC4B5826C0D21408A3CC02E678/", 1, 1 },
        glossuRabban = { "http://cloud-3.steamusercontent.com/ugc/2029467636440364572/68A9DE7E06DA5857EE51ECB978E13E3921A15B1A/", 1, 1 },
        vladimirHarkonnen = { "http://cloud-3.steamusercontent.com/ugc/2029467636440341651/6F682C5E5C1ADE0B9B1B8FAC80B9525A6748C351/", 1, 1 },
        ilbanRichese = { "http://cloud-3.steamusercontent.com/ugc/2029467636440255083/F0F052CCAB7005F4D30879BF639AFACEDFF70A80/", 1, 1 },
        helenaRichese = { "http://cloud-3.steamusercontent.com/ugc/5095292505135062968/A069B3ECF1B4E9C42D2453E28EA13257F397B3F3/", 1, 1 },
    },
    fanmadeLeader = {
        abulurdHarkonnen = { "http://cloud-3.steamusercontent.com/ugc/2093667512248606082/40B8A2B4F6F5DA9A0C2D7738A3F5BFD925167438/", 1, 1 },
        xavierHarkonnen = { "http://cloud-3.steamusercontent.com/ugc/2093667512248605507/43E90624D39B5A904FF112BD5A0B7C3D8AA21502/", 1, 1 },
        feydRauthaHarkonnen = { "http://cloud-3.steamusercontent.com/ugc/2093667512248604892/D80761B2286A313A11939E3D45DEBCF24F7D30CC/", 1, 1 },
        hasimirFenring = { "http://cloud-3.steamusercontent.com/ugc/2093667512248604380/3657671646912D7026E790B8DE187B49975CBD0E/", 1, 1 },
        margotFenring = { "http://cloud-3.steamusercontent.com/ugc/2093667512248603361/1964022795283817F32D219C1C38050A9B5303AD/", 1, 1 },
        lietKynes = { "http://cloud-3.steamusercontent.com/ugc/2093667512248602889/DC956CB7ACBD2370DC3D86484765E413F36DBBFF/", 1, 1 },
        hwiNoree = { "http://cloud-3.steamusercontent.com/ugc/2093667512248602302/D3BB757794FCB5B9CF5D58798A697B354BD34EEA/", 1, 1 },
        metulli = { "http://cloud-3.steamusercontent.com/ugc/2093667512248601751/09663A73D24AF2DB6A9315D87C5953614C0B0F32/", 1, 1 },
        milesTeg = { "http://cloud-3.steamusercontent.com/ugc/2093667512248601229/299ECFBED3CD8F16774C5C69F8A957768CBBB66D/", 1, 1 },
        normaCenvas = { "http://cloud-3.steamusercontent.com/ugc/2093667512248600249/4E8FC979A8689926A3A02EA748F402E7D76570BA/", 1, 1 },
        irulanCorrino = { "http://cloud-3.steamusercontent.com/ugc/2093667512248599131/4C33FE97C3EFCABF776DF966B59D2AF15401D07E/", 1, 1 },
        wencisiaCorrino = { "http://cloud-3.steamusercontent.com/ugc/2093667512248598520/C3D5184AD0F809A3F1F38BB16096AF5DD4437FA5/", 1, 1 },
        vorianAtreides = { "http://cloud-3.steamusercontent.com/ugc/2093667512248597972/DFDB8318608D8F7B39273B40EBB4120FCEE56B3E/", 1, 1 },
        serenaButler = { "http://cloud-3.steamusercontent.com/ugc/2093667512248597448/C4934E0587D33E2F1BB051D746A7EB30D2A6DEA7/", 1, 1 },
        whitmoreBluud = { "http://cloud-3.steamusercontent.com/ugc/2093667512248595937/FEB8F943C50DFB711640347C6397243D71F9780A/", 1, 1 },
        executrixOrdos = { "http://cloud-3.steamusercontent.com/ugc/2093667512248595937/FEB8F943C50DFB711640347C6397243D71F9780A/", 1, 1 },
        torgTheYoung = { "http://cloud-3.steamusercontent.com/ugc/2093667512248594461/66DCBBE36459C57FD8F631D8576F2CF01DFDC092/", 1, 1 },
        twylwythWaff = { "http://cloud-3.steamusercontent.com/ugc/2093667512248593483/A7741DFFE841114BDDB8B6F8A2A57D2C59CDDEEB/", 1, 1 },
        scytale = { "http://cloud-3.steamusercontent.com/ugc/2093667512248593036/BFA284BBABA15A609401208F4D834FE916EA960E/", 1, 1 },
        stabanTuek = { "http://cloud-3.steamusercontent.com/ugc/2093667512248591569/1FCB42B17A8F7F711758BF5869CD3B7328E4542F/", 1, 1 },
        esmarTuek = { "http://cloud-3.steamusercontent.com/ugc/2093667512248590823/EDAF5084889AA22C19B915DFADDFEADAB97F440F/", 1, 1 },
        drisk = { "http://cloud-3.steamusercontent.com/ugc/2093667512248590010/2F2F3CF34B2737B7CAEF26433B3ECEE9FE41B3AF/", 1, 1 },
        arkhane = { "http://cloud-3.steamusercontent.com/ugc/2093667512248588940/43F98BF29B58C81D6C1FABDC6D166BC0ED122953/", 1, 1 },
    }
}

---
function Deck.load(loader, cards, category, customDeckName, startLuaIndex, cardNames)
    local desc = Deck[category][customDeckName]
    assert(desc, "No descriptor for: " .. category .. "." .. customDeckName)
    local functionName = Helper.toCamelCase("create", category, "CustomDeck")
    assert(loader[functionName], "No loader for: " .. functionName )
    local customDeck = loader[functionName](desc[1], desc[2], desc[3], desc[4])
    return loader.loadCustomDeck(cards, customDeck, startLuaIndex, cardNames)
end

---
function Deck.loadCustomDecks(loader)
    local cards = {
        imperium = {},
        special = {},
        tleilaxu = {},
        intrigue = {},
        conflict = {},
        hagal = {},
        tech = {},
        leaders = {}
    }

    Deck.load(loader, cards.imperium, "imperium", "starter", 1, {
        "seekAllies",
        "signetRing",
        "diplomacy",
        "reconnaissance",
        "convincingArgument", "",
        "dagger", "",
    })
    Deck.load(loader, cards.imperium, "imperium", "starterDunePlanet", 1, {
        "duneTheDesertPlanet",
    })
    Deck.load(loader, cards.imperium, "imperium", "imperium", 1, {
        "opulence",
        "firmGrip",
        "guildAmbassador",
        "guildBankers",
        "otherMemory",
        "ladyJessica",
        "jessicaOfArrakis",
        "kwisatzHaderach",
        "reverendMotherMohiam",
        "sietchReverendMother",
        "testOfHumanity",
        "lietKynes",
        "chani",
        "crysknife",
        "stilgar",
        "choamDirectorship",
        "duncanIdaho",
        "drYueh",
        "gurneyHalleck",
        "piterDeVries",
        "carryall",
        "thufirHawat",
        "beneGesseritSister", "", "",
        "powerPlay", "", "",
        "imperialSpy", "",
        "sardaukarInfantry", "",
        "sardaukarLegion", "",
        "guildAdministrator", "",
        "spiceSmugglers", "",
        "smugglersThopter", "",
        "spaceTravel", "",
        "beneGesseritInitiate", "",
        "theVoice", "",
        "geneManipulation", "",
        "missionariaProtectiva", "",
        "fremenCamp", "",
        "spiceHunter", "",
        "wormRiders", "",
        "feydakinDeathCommando", "",
        "shiftingAllegiances", "",
        "scout", "",
        "assassinationMission", "",
        "gunThopter", "",
        "arrakisRecruiter", "",
        "duncanLoyalBlade",
    })
    Deck.load(loader, cards.imperium, "imperium", "newImperium", 1, {
        "thumper"
    })
    Deck.load(loader, cards.imperium, "imperium", "ixImperium", 1, {
        "appropriate",
        "imperialBashar",
        "courtIntrigue",
        "fullScaleAssault",
        "imperialShockTrooper",
        "guildAccord",
        "guildChiefAdministrator",
        "ixGuildCompact",
        "landingRights",
        "esmarTuek",
        "embeddedAgent",
        "weirdingWay",
        "webOfPower",
        "spiceTrader",
        "desertAmbush",
        "satelliteBan",
        "jamis",
        "sayyadina",
        "shaiHulud",
        "boundlessAmbition",
        "bountyHunter",
        "choamDelegate",
        "waterPeddlersUnion",
        "localFence",
        "truthsayer", "",
        "inTheShadows", "",
        "freighterFleet", "",
        "ixianEngineer", "",
        "negotiatedWithdrawal", "",
        "treachery", "",
    })
    Deck.load(loader, cards.imperium, "imperium", "ixImperiumControlTheSpice", 1, {
        "controlTheSpice",
    })
    Deck.load(loader, cards.imperium, "imperium", "immortalityImperium", 1, {
        "beneTleilaxLab",
        "beneTleilaxResearcher",
        "blankSlate",
        "clandestineMeeting",
        "corruptSmuggler",
        "dissectingKit", "",
        "forHumanity",
        "highPriorityTravel",
        "imperiumCeremony",
        "interstellarConspiracy",
        "keysToPower",
        "lisanAlGaib",
        "longReach",
        "occupation",
        "organMerchants",
        "plannedCoupling",
        "replacementEyes",
        "sardaukarQuartermaster",
        "shadoutMapes",
        "showOfStrength",
        "spiritualFervor",
        "stillsuitManufacturer",
        "throneRoomPolitics",
        "tleilaxuMaster",
        "tleilaxuSurgeon",
        -- +4
    })
    Deck.load(loader, cards.imperium, "imperium", "immortalityImperiumExperimentation", 1, {
        "experimentation",
    })

    Deck.load(loader, cards.tleilaxu, "imperium", "tleilaxResearch", 1, {
        "beguilingPheromones",
        "chairdog",
        "contaminator",
        "corrinoGenes",
        "faceDancer",
        "faceDancerInitiate",
        "fromTheTanks",
        "ghola",
        "guildImpersonator",
        "industrialEspionage",
        "piterGeniusAdvisor",
        "scientificBreakthrough",
        "sligFarmer",
        "stitchedHorror",
        "subjectX137",
        "tleilaxuInfiltrator",
        "twistedMentat",
        "unnaturalReflexes",
        "usurp",
    })

    Deck.load(loader, cards.special, "imperium", "imperiumFoldedSpace", 1, {
        "foldspace",
        -- +5
    })
    Deck.load(loader, cards.special, "imperium", "imperiumArrakisLiasion", 1, {
        "arrakisLiaison",
        -- +7
    })
    Deck.load(loader, cards.special, "imperium", "imperiumTheSpiceMustFlow", 1, {
        "theSpiceMustFlow",
        -- +9
    })
    Deck.load(loader, cards.special, "imperium", "tleilaxResearchReclaimedForces", 11, {
        "reclaimedForces",
    })

    Deck.load(loader, cards.intrigue, "intrigue", "intrigue", 1, {
        "masterTactician", "", "",
        "privateArmy", "",
        "ambush","",
        "dispatchAnEnvoy", "",
        "poisonSnooper", "",
        "favoredSubject",
        "knowTheirWays",
        "secretOfTheSisterhood",
        "guildAuthorization",
        "stagedIncident",
        "theSleeperMustAwaken",
        "choamShares",
        "cornerTheMarket",
        "plansWithinPlans",
        "windfall",
        "waterPeedlersUnion",
        "councilorsDispensation",
        "doubleCross",
        "rapidMobilization",
        "reinforcements",
        "recruitmentMission",
        "charisma",
        "bypassProtocol",
        "infiltrate",
        "urgentMission",
        "calculatedHire",
        "binduSuspension",
        "waterOfLife",
        "refocus",
        "bribery",
        "toTheVictor",
        "demandRespect",
        "alliedArmada",
        "tiebreaker",
    })
    Deck.load(loader, cards.intrigue, "intrigue", "ixIntrigue", 1, {
        "diversion",
        "warChest",
        "advancedWeaponry",
        "secretForces",
        "grandConspiracy",
        "cull",
        "strategicPush",
        "blackmail",
        "machineCulture",
        "cannonTurrets",
        "expedite",
        "ixianProbe",
        "secondWave",
        "glimpseThePath",
        "finesse",
        "strongarm",
        "quidProQuo",
    })
    Deck.load(loader, cards.intrigue, "intrigue", "immortalityIntrigue", 1, {
        "breakthrough",
        "counterattack",
        "disguisedBureaucrat",
        "economicPositioning",
        "gruesomeSacrifice",
        "harvestCells",
        "illicitDealings",
        "shadowyBargain",
        "studyMelange",
        "tleilaxuPuppet",
        "viciousTalents",
        -- +4
    })

    Deck.load(loader, cards.conflict, "conflict1", "conflict", 1, {
        "skirmishA",
        "skirmishB",
        "skirmishC",
        "skirmishD",
        "skirmishE",
        "skirmishF"
    })
    Deck.load(loader, cards.conflict, "conflict2", "conflict", 1, {
        "desertPower",
        "raidStockpiles",
        "cloakAndDagger",
        "machinations",
        "sortThroughTheChaos",
        "terriblePurpose",
        "guildBankRaid",
        "siegeOfArrakeen",
        "siegeOfCarthag",
        "secureImperialBasin",
        "tradeMonopoly"
    })
    Deck.load(loader, cards.conflict, "conflict3", "conflict", 1, {
        "battleForImperialBasin",
        "grandVision",
        "battleForCarthag",
        "battleForArrakeen",
        "economicSupremacy"
    })

    Deck.load(loader, cards.hagal, "hagal", "hagal", 1, {
        "harvestSpice",
        "hardyWarriors",
        "stillsuits",
        "rallyTroops",
        "foldspace",
        "conspire",
        "selectiveBreeding",
        "secrets",
        "heighliner",
        "reshuffle",
        "arrakeen1p",
        "carthag",
        "hallOfOratory",
        "back"
    })
    Deck.load(loader, cards.hagal, "hagal", "hagal_wealth", 1, {
        "wealth"
    })
    Deck.load(loader, cards.hagal, "hagal", "hagal_arrakeen2p", 1, {
        "arrakeen2p"
    })
    Deck.load(loader, cards.hagal, "hagal", "ixHagal_dreadnought1p", 1, {
        "dreadnought1p"
    })
    Deck.load(loader, cards.hagal, "hagal", "ixHagal_dreadnought2p", 1, {
        "dreadnought2p"
    })
    Deck.load(loader, cards.hagal, "hagal", "ixHagal_techNegogiation1p", 1, {
        "techNegotiation"
    })
    Deck.load(loader, cards.hagal, "hagal", "ixHagal_interstellarShipping", 1, {
        "interstellarShipping"
    })
    Deck.load(loader, cards.hagal, "hagal", "ixHagal_foldspaceAndInterstellarShipping", 1, {
        "foldspaceAndInterstellarShipping"
    })
    Deck.load(loader, cards.hagal, "hagal", "ixHagal_smugglingAndInterstellarShipping", 1, {
        "smugglingAndInterstellarShipping"
    })
    Deck.load(loader, cards.hagal, "hagal", "imortalityHagal", 1, {
        "researchStation",
        "carthag1",
        "carthag2",
        "carthag3"
    })
    Deck.load(loader, cards.hagal, "hagal", "hagal_churn", 1, {
        "churn"
    })

    -- One tech per custom deck.
    for techName, _ in pairs(Deck.tech) do
        Deck.load(loader, cards.tech, "tech", techName, 1, { techName })
    end

    -- One leader per custom deck.
    for leaderName, _ in pairs(Deck.leader) do
        Deck.load(loader, cards.leaders, "leader", leaderName, 1, { leaderName })
    end

    -- One leader per custom deck.
    for leaderName, _ in pairs(Deck.fanmadeLeader) do
        Deck.load(loader, cards.leaders, "fanmadeLeader", leaderName, 1, { leaderName })
    end

    return cards
end

return Deck
