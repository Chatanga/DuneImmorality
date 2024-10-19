local Helper = require("utils.Helper")

local Deck = {
    objective = {
        uprisingObjective = { "https://steamusercontent-a.akamaihd.net/ugc/2488878371133399226/F23014D780D16DDF23D8AF674BDEE3A9CB912F78/", 3, 2 },
    },
    imperium = {
        -- starter with dune the desert planet
        starter = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141325193/BF3BA9C253ED953533B90D94DD56D0BAD4021B3C/", 4, 2 },
        starterImperium_emperor = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141285880/767F540B36884449C0A833D2CF0A25E36651F9AE/", 5, 2 },
        starterImperium_muadDib = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141285600/E73DE11761FD6A911456F07E348ED58BC7B21638/", 5, 2 },
        -- base with foldspace, liasion, and the spice must flow
        imperium = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141326803/6F98BCE051343A3D07D58D6BC62A8FCA2C9AAE1A/", 8, 6 },
        -- ix with control the spice
        ixImperium = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141328204/9DFCC56F20D09D60CF2B9D9050CB9640176F71B6/", 7, 5 },
        -- tleilax with experimentation
        immortalityImperium = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141324694/E758512421B5CB27BBA228EF5F1880A7F3DC564D/", 6, 5 },
        -- tleilax with reclaimed forces
        tleilaxResearch = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141325643/D9BD273651404E7DE7F0E22B36F2D426D82B07A8/", 4, 5 },
        uprisingImperium = { "https://steamusercontent-a.akamaihd.net/ugc/2488878371133381992/B5E28000A80DBE32D234C01F31C208A435018954/", 10, 7 },
        uprisingImperium_contract = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141289270/C9C56A8015292829E5F4C65EFB0B3F78A19DCDB4/", 2, 2 },
        uprisingImperium_prepareTheWay = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141288931/3EFF528A17FA160E8C836BCE628875066C791E88/", 4, 2 },
        uprisingImperium_theSpiceMustFlow = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141288456/7EFF5F3E150A3F7E9F8B0DE21E42F42E2F8967D4/", 5, 2 },
    },
    intrigue = {
        intrigue = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141343483/A63AE0E1069DA1279FDA3A5DE6A0E073F45FC8EF/", 7, 5 },
        ixIntrigue = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141342567/CE27F1B6D4D455A2D00D6E13FABEB72E6B9F05F1/", 5, 4 },
        immortalityIntrigue = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141342411/9FED90CD510F26618717CEB63FDA744CE916C6BA/", 6, 2 },
        uprisingIntrigue = { "https://steamusercontent-a.akamaihd.net/ugc/2488878371133408513/800A1EDE8EE94FFC4E38A4D428A73701D6DB020F/", 10, 4 },
        uprisingIntrigue_contract = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141307183/4633F67F86EB0AFAE82F5C075A16FE2FF6E2AD96/", 2 , 2 },
    },
    conflict1 = {
        uprisingConflict = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141315234/658FE46691E92A3A5A67D11CB09BE85492BAFE87/", 2, 2 },
    },
    conflict2 = {
        uprisingConflict = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141314758/60D88BD461A98569E77321BAC643C6938DBB292E/", 5, 2 },
    },
    conflict3 = {
        conflict = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141365294/F1BEAE6266E75B7A2F5DE511DB4FEB25A2CD486B/", 3, 2 },
        uprisingConflict = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141315402/71EFAC5FF1CC15BC3BF35E613D956BE814964C41/", 2, 2 },
    },
    hagal = {
        base = { "https://steamusercontent-a.akamaihd.net/ugc/2291837013341414524/BB90DF7F9C97680FE16C4D91A1AF0871B2462CB9/", 5, 5 },
        reshuffle = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141333398/66020C11E4FEA2D22744020D27465DCC2BB02BBE/", 7, 2 },
        ix = { "https://steamusercontent-a.akamaihd.net/ugc/2291837013341435538/E181DED96F81A27405E57F0CF398575C20D73D12/", 2, 3 },
        immortality = { "https://steamusercontent-a.akamaihd.net/ugc/2291837013341433170/56E0015597F27AB50451E026A8BD95512FA1CE27/", 2, 2 },
    },
    tech = {
        windtraps = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141361499/1357A12AE8B805DDA4B35054C7A042EB60ED8D93/", 1, 1 },
        flagship = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141364750/3D450BD068CF618EB58032CA790EC8CFB512C6ED/", 1, 1 },
        sonicSnoopers = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141363495/735DAD89216E331EE1461EEBC94E579B3F65D898/", 1, 1 },
        artillery = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141362120/1DD4BAFBF228984A2AE7D7A04C6BD98E5817CB75/", 1, 1 },
        troopTransports = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141363152/5F8994647E6BE9B8DFE12775816BA8634DBEF803/", 1, 1 },
        spySatellites = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141363781/A4A7827D2C9E2D084FEF39864C901F858DBAC7A0/", 1, 1 },
        invasionShips = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141362661/CA3C07205ECEFC22C759E350C47B58052D1CB3EC/", 1, 1 },
        chaumurky = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141359974/CC1342B27E230372F8A10A0BD35ADF796F0FF6A5/", 1, 1 },
        detonationDevices = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141362350/985702313B721E7343ED01C603AF5C8EFF43C2F4/", 1, 1 },
        spaceport = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141362796/A906AB650BF19DEA2E39F86F873940143C2CF814/", 1, 1 },
        minimicFilm = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141360892/74A896440084439B2C557D8651EB8125A64E85B1/", 1, 1 },
        holoprojectors = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141360731/89575580CD49633CE5473B76CDDFA1A0A2503030/", 1, 1 },
        memocorders = { "https://steamusercontent-a.akamaihd.net/ugc/2488878371133863837/2644950194120A67CDC6BF7019D951FCF605DBFF/", 1, 1 },
        disposalFacility = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141361878/57A51864E207970E7DCB9ACCAE68AFAE48F2CD61/", 1, 1 },
        holtzmanEngine = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141361742/B202AC36308C95EF1CA325DAE9318DCB6C5229EE/", 1, 1 },
        trainingDrones = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141361140/B877582FA7ECB542E046FB96EB8488D511DEDF1C/", 1, 1 },
        shuttleFleet = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141364620/9E39289A6CED8A977E8206E1B5FD1A14F4BA55F8/", 1, 1 },
        restrictedOrdnance = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141360269/1F4181A709E103B8807D6D6FBF3C6BA62A4C20F9/", 1, 1 },
    },
    contract = {
        spiceRefineryWater = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141300304/7EA3323DDA7E60E1A8AB1119431D2D25187417F7/", 1, 1 },
        spiceRefineryCard = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141300927/78FB61B6A6BE119DEC9E93CC343BE1C199191E89/", 1, 1 },
        researchStationSpy = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141304020/9408609A985B7FFC43C43E0E791694870CB379C7/", 1, 1 },
        researchStationSolari = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141299628/C2F0768CD60F9944C16F128F307BA6F8107C0E93/", 1, 1 },
        arrakeenSpy = { "https://steamusercontent-a.akamaihd.net/ugc/2488878371133404029/4CB29CF8FC8D0BF9A5B575B3E05B31774E59F3CD/", 1, 1 },
        arrakeenWater = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141302127/926CFC63532C4D7BC6AA6B9151AFF0221A553B44/", 1, 1 },
        espionage = { "https://steamusercontent-a.akamaihd.net/ugc/2488878371133403318/35C1BFE9773F01181B1280C061914D7CE07BFE71/", 1, 1 },
        sardaukarRecall = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141301335/E5463C7FFA3426E57F5B07A0DE91602798170C69/", 1, 1 },
        sardaukarCard = { "https://steamusercontent-a.akamaihd.net/ugc/2488878371133404238/1711DFB19987B48883EF6B53E1CD62739D70E1A2/", 1, 1 },
        highCouncilSolari = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141301141/33A0566759303798910FF7F7C4414E09BDBBE037/", 1, 1 },
        highCouncilInfluence = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141301954/16A847D5CB4EB5E926D4404BB5F30BAF574558F5/", 1, 1 },
        immediate = { "https://steamusercontent-a.akamaihd.net/ugc/2488878371133402189/3D848E8CC39986DD283094AC31757997C097F4D7/", 1, 1 },
        heighlinerTroop = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141302477/348DAD4630FD7CD067043AFBC5ADCB91733D9D23/", 1, 1 },
        heighlinerWater = { "https://steamusercontent-a.akamaihd.net/ugc/2488878371133401717/5B022A86311D086273A90DBA7D53DC22DCA9C917/", 1, 1 },
        deliverSupplies = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141300498/B42F88CDC1519A7893668030B695338E7EA18391/", 1, 1 },
        acquire = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141302699/94ED4105E316EDD45B0202837A711FF3A99E7CFA/", 1, 1 },
        harvest = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141300124/832069DB1C4F8B9B328876E798D071FFD35F0173/", 1, 1 },
        harvestMore = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141301496/B564DA078EA0BE9D2A7AAA8FA4DF105D4AD82A17/", 1, 1 },
    },
    leader = {
        vladimirHarkonnen = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141316546/B5899377296C2BFAC0CF48E18AA3773AA8E998DE/", 1, 1 },
        glossuRabban = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141317845/DCF40F0D8C34B14180DC33B369DCC8AA4FD3FB55/", 1, 1 },
        ilbanRichese = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141316307/15624E52D08F594943A4A6332CBD68B2A1645441/", 1, 1 },
        helenaRichese = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141318952/63750F22F1DFBA9D9544587C0B2B8D65E157EC00/", 1, 1 },
        letoAtreides = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141318661/8CBD932BE474529D6C14A3AA8C01BD8503EBEBC6/", 1, 1 },
        paulAtreides = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141317535/F597DBF1EB750EA14EA03F231D0EBCF07212A5AC/", 1, 1 },
        arianaThorvald = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141320077/2A9043877494A7174A32770C39147FAE941A39A2/", 1, 1 },
        memnonThorvald = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141321067/8431F61C545067A4EADC017E6295CB249A2BD813/", 1, 1 },
        -- ix
        armandEcaz = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141320355/310C6B6E85920F9FC1A94896A335D34C3CFA6C15/", 1, 1 },
        ilesaEcaz = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141318208/94B1575474BEEF1F1E0FE0860051932398F47CA5/", 1, 1 },
        rhomburVernius = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141316909/0C06A30D74BD774D9B4F968C00AEC8C0817D4C77/", 1, 1 },
        tessiaVernius = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141319434/29817122A32B50C285EE07E0DAC32FDE9A237CEC/", 1, 1 },
        yunaMoritani = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141319867/FA54B129B168169E3D58BA61536FCC0BB5AB7D34/", 1, 1 },
        hundroMoritani = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141316031/6A89778D9C4BB8AC07FE503D48A4483D13DF6E5B/", 1, 1 },
        -- uprising
        stabanTuek = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141283441/E675A8B105716B01D7C1C086102CEBCE0756B4C7/", 1, 1 },
        amberMetulli = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141280903/E525FD044AB8D577752189B9094E795D1F4BC9D5/", 1, 1 },
        gurneyHalleck = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141283901/6F7B49241ECB5CB66B0C8F68F05B91DAA2D6E11E/", 1, 1 },
        margotFenring = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141282956/1A4453CC4C74E1F8B58C504243AD495B649DBB07/", 1, 1 },
        irulanCorrino = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141282774/EC550B921EFB707D338F5A45AB39609A9DFDE7BA/", 1, 1 },
        jessica = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141283120/1969BB59A8DD3C683E82A2D07D1C41BB2F175313/", 1, 1, Vector(1.12, 1, 1.12),
            "https://steamusercontent-a.akamaihd.net/ugc/2502404390141285197/3FA11CDE733EB59839FB85D0328588F28BE43D57/" },
        feydRauthaHarkonnen = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141282610/C6CC977066E02C55DFA870BF59D42A8DC21F6811/", 1, 1 },
        shaddamCorrino = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141285378/056063BC4E61922C15A7A45DD5093EA6EC04C354/", 1, 1 },
        muadDib = { "https://steamusercontent-a.akamaihd.net/ugc/2502404390141283595/202B5C036B90D32A408FE938AF0747BAF2DE7DFB/", 1, 1 },
    },
    rivalLeader = {
        uprising = { "https://steamusercontent-a.akamaihd.net/ugc/2291837013341168508/811BF7142774932C8C2FAD7C10BA104F8DAD4299/", 4, 3 },
    },
}

---
function Deck.load(loader, cards, category, customDeckName, startLuaIndex, cardNames)
    assert(Deck[category], "Unknown category: " .. tostring(category))
    local desc = Deck[category][customDeckName]
    assert(desc, "No descriptor for: " .. category .. "." .. customDeckName)
    local customDeck
    if desc[5] then
        customDeck = loader.createCustomDeck(desc[5], desc[1], desc[2], desc[3], desc[4])
    else
        local functionName = Helper.toCamelCase("create", category, "CustomDeck")
        assert(loader[functionName], "No loader for: " .. functionName )
        customDeck = loader[functionName](desc[1], desc[2], desc[3], desc[4])
    end
    return loader.loadCustomDeck(cards, customDeck, startLuaIndex, cardNames)
end

---
function Deck.loadWithSubCategory(loader, cards, category, subCategory, customDeckName, startLuaIndex, cardNames)
    assert(Deck[category], "No category: " .. category)
    assert(Deck[category][subCategory], "No sub category: " .. category .. "." .. subCategory)
    local desc = Deck[category][subCategory][customDeckName]
    assert(desc, "No descriptor for: " .. category .. "." .. customDeckName)
    local functionName = Helper.toCamelCase("create", category, "CustomDeck")
    assert(loader[functionName], "No loader for: " .. functionName )
    local customDeck = loader[functionName](desc[1], desc[2], desc[3], desc[4])
    return loader.loadCustomDeck(cards, customDeck, startLuaIndex, cardNames)
end

---
function Deck.loadCustomDecks(loader)
    local cards = {
        objective = {},
        imperium = {},
        special = {},
        tleilaxu = {},
        intrigue = {},
        conflict = {},
        hagal = {},
        tech = {},
        leaders = {},
        rivalLeaders = {},
    }

    Deck.load(loader, cards.objective, "objective", "uprisingObjective", 1, {
        "ornithopter1to3p",
        "muadDibFirstPlayer",
        "crysknife",
        "muadDib4to6p",
        "crysknife4to6p",
    })

    Deck.load(loader, cards.imperium, "imperium", "starter", 1, {
        "duneTheDesertPlanet",
        "dagger",
        "reconnaissance",
        "convincingArgument",
        "seekAllies",
        "signetRing",
        "diplomacy",
    })
    Deck.load(loader, cards.imperium, "imperium", "starterImperium_emperor", 1, {
        "emperorConvincingArgument",
        "emperorCorrinoMight",
        "emperorCriticalShipments",
        "emperorDemandResults",
        "emperorDevastatingAssault",
        "emperorImperialOrnithopter", "",
        "emperorSignetRing",
        "emperorSeekAllies",
        "emperorImperialTent",
    })
    Deck.load(loader, cards.imperium, "imperium", "starterImperium_muadDib", 1, {
        "muadDibCommandRespect",
        "muadDibConvincingArgument",
        "muadDibDemandAttention",
        "muadDibDesertCall",
        "muadDibLimitedLandsraadAccess", "",
        "muadDibSeekAllies",
        "muadDibUsul",
        "muadDibThreatenSpiceProduction",
        "muadDibSignetRing",
    })
    Deck.load(loader, cards.imperium, "imperium", "imperium", 1, {
        "sardaukarLegion",
        "drYueh",
        "assassinationMission",
        "sardaukarInfantry",
        "", -- foldspace
        "", -- arrakisLiaison
        "", -- theSpiceMustFlow
        "beneGesseritInitiate",
        "guildAdministrator",
        "theVoice",
        "scout",
        "imperialSpy",
        "beneGesseritSister",
        "missionariaProtectiva",
        "spiceHunter",
        "spiceSmugglers",
        "fedaykinDeathCommando",
        "geneManipulation",
        "guildBankers",
        "choamDirectorship",
        "crysknife",
        "chani",
        "spaceTravel",
        "duncanIdaho",
        "shiftingAllegiances",
        "kwisatzHaderach",
        "sietchReverendMother",
        "arrakisRecruiter",
        "firmGrip",
        "smugglersThopter",
        "carryall",
        "gunThopter",
        "guildAmbassador",
        "testOfHumanity",
        "fremenCamp",
        "opulence",
        "ladyJessica",
        "stilgar",
        "piterDeVries",
        "gurneyHalleck",
        "thufirHawat",
        "otherMemory",
        "lietKynes",
        "wormRiders",
        "reverendMotherMohiam",
        "powerPlay",
    })
    Deck.load(loader, cards.imperium, "imperium", "ixImperium", 1, {
        "boundlessAmbition",
        "guildChiefAdministrator",
        "guildAccord",
        "localFence",
        "shaiHulud",
        "ixGuildCompact",
        "choamDelegate",
        "bountyHunter",
        "embeddedAgent",
        "esmarTuek",
        "courtIntrigue",
        "sayyadina",
        "imperialShockTrooper",
        "appropriate",
        "desertAmbush",
        "inTheShadows",
        "satelliteBan",
        "freighterFleet",
        "imperialBashar",
        "jamis",
        "landingRights",
        "waterPeddler",
        "treachery",
        "truthsayer",
        "spiceTrader",
        "ixianEngineer",
        "webOfPower",
        "weirdingWay",
        "negotiatedWithdrawal",
        "fullScaleAssault",
        "jessicaOfArrakis",
        "missionariaProtectiva",
        "controlTheSpice",
        "duncanLoyalBlade"
    })
    Deck.load(loader, cards.imperium, "imperium", "immortalityImperium", 1, {
        "beneTleilaxLab",
        "beneTleilaxResearcher",
        "blankSlate",
        "clandestineMeeting",
        "corruptSmuggler",
        "dissectingKit",
        "experimentation",
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
        "tleilaxuSurgeon"
    })
    Deck.load(loader, cards.imperium, "imperium", "uprisingImperium", 1, {
        "unswervingLoyalty", "",
        "spaceTimeFolding",
        "weirdingWoman", "",
        "sardaukarSoldier",
        "smugglerHarvester", "",
        "makerKeeper", "",
        "reliableInformant",
        "hiddenMissive",
        "wheelsWithinWheels",
        "fedaykinStilltent",
        "imperialSpymaster",
        "spyNetwork",
        "desertSurvival", "",
        "undercoverAsset",
        "beneGesseritOperative", "",
        "maulaPistol", "",
        "thumper",
        "nothernWatermaster",
        "covertOperation",
        "doubleAgent", "",
        "guildEnvoy",
        "rebelSupplier", "",
        "calculusOfPower", "",
        "guildSpy",
        "dangerousRhetoric",
        "branchingPath",
        "ecologicalTestingStation",
        "theBeastSpoils",
        "smugglerHaven",
        "shishakli",
        "paracompass",
        "sardaukarCoordination", "",
        "truthtrance", "",
        "publicSpectable", "",
        "southernElders",
        "treadInDarkness", "",
        "spacingGuildFavor", "",
        "capturedMentat",
        "subversiveAdvisor",
        "leadership",
        "inHighPlaces",
        "strikeFleet",
        "trecherousManeuver",
        "chaniCleverTactician",
        "junctionHeadquarters",
        "corrinthCity",
        "stilgarTheDevoted",
        "desertPower",
        "arrakisRevolt",
        "priceIsNoObject",
        "longLiveTheFighters",
        "overthrow",
        "steersman",
    })
    Deck.load(loader, cards.imperium, "imperium", "uprisingImperium_contract", 1, {
        "cargoRunner",
        "deliveryAgreement",
        "priorityContracts",
        "interstellarTrade",
    })
    Deck.load(loader, cards.special, "imperium", "imperium", 5, {
        "foldspace",
    })
    Deck.load(loader, cards.special, "imperium", "tleilaxResearch", 11, {
        "reclaimedForces",
    })
    Deck.load(loader, cards.special, "imperium", "uprisingImperium_prepareTheWay", 8, {
        "prepareTheWay",
    })
    Deck.load(loader, cards.special, "imperium", "uprisingImperium_theSpiceMustFlow", 10, {
        "theSpiceMustFlow",
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
        "", -- Reclaimed Forces
        "scientificBreakthrough",
        "sligFarmer",
        "stitchedHorror",
        "subjectX137",
        "tleilaxuInfiltrator",
        "twistedMentat",
        "unnaturalReflexes",
        "usurp",
        "piterGeniusAdvisor"
    })

    Deck.load(loader, cards.intrigue, "intrigue", "intrigue", 1, {
        "bribery",
        "refocus",
        "ambush",
        "alliedArmada",
        "favoredSubject",
        "demandRespect",
        "poisonSnooper",
        "guildAuthorization",
        "dispatchAnEnvoy",
        "infiltrate",
        "knowTheirWays",
        "masterTactician",
        "plansWithinPlans",
        "privateArmy",
        "doubleCross",
        "councilorsDispensation",
        "cornerTheMarket",
        "charisma",
        "calculatedHire",
        "choamShares",
        "bypassProtocol",
        "recruitmentMission",
        "reinforcements",
        "binduSuspension",
        "secretOfTheSisterhood",
        "rapidMobilization",
        "stagedIncident",
        "theSleeperMustAwaken",
        "tiebreaker",
        "toTheVictor",
        "waterPeddlersUnion",
        "windfall",
        "waterOfLife",
        "urgentMission"
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
        "quidProQuo"
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
        "viciousTalents"
    })
    Deck.load(loader, cards.intrigue, "intrigue", "uprisingIntrigue", 1, {
        "sietchRitual",
        "mercenaries",
        "councilorAmbition",
        "strategicStockpiling",
        "detonation", "",
        "departForArrakis",
        "cunning",
        "opportunism",
        "changeAllegiances",
        "specialMission", "",
        "unexpectedAllies",
        "callToArms",
        "buyAccess",
        "imperiumPolitics",
        "shaddamFavor",
        "intelligenceReport",
        "manipulate",
        "distraction", "",
        "marketOpportunity",
        "goToGround",
        "contingencyPlan", "", "",
        "inspireAwe",
        "findWeakness",
        "spiceIsPower",
        "devour",
        "impress",
        "springTheTrap",
        "weirdingCombat",
        "tacticalOption",
        "questionableMethods",
        "desertMouse",
        "ornithopter",
        "crysknife",
        "shadowAlliance",
        "secureSpiceTrade",
    })
    Deck.load(loader, cards.intrigue, "intrigue", "uprisingIntrigue_contract", 1, {
        "leverage",
        "backedByChoam",
        "reachAgreement",
        "choamProfits",
    })

    Deck.load(loader, cards.conflict, "conflict1", "uprisingConflict", 1, {
        "skirmishA",
        "skirmishB",
        "skirmishC",
    })
    Deck.load(loader, cards.conflict, "conflict2", "uprisingConflict", 1, {
        "choamSecurity",
        "spiceFreighters",
        "siegeOfArrakeen",
        "seizeSpiceRefinery",
        "testOfLoyalty",
        "shadowContest",
        "secureImperialBasin",
        "protectTheSietches",
        "tradeDispute",
    })
    Deck.load(loader, cards.conflict, "conflict3", "conflict", 5, {
        "economicSupremacy",
    })
    Deck.load(loader, cards.conflict, "conflict3", "uprisingConflict", 1, {
        "propaganda",
        "battleForImperialBasin",
        "battleForArrakeen",
        "battleForSpiceRefinery",
    })

    Deck.load(loader, cards.hagal, "hagal", "base", 1, {
        "churn",
        "placeSpyYellow",
        "placeSpyBlue",
        "placeSpyGreen",
        "sardaukar",
        "dutifulService",
        "heighliner",
        "deliverSuppliesAndHeighliner",
        "espionage",
        "secrets",
        "desertTactics",
        "fremkit",
        "assemblyHall",
        "gatherSupport1",
        "gatherSupport2",
        "acceptContractAndShipping1",
        "acceptContractAndShipping2",
        "researchStation",
        "spiceRefinery",
        "arrakeen",
        "sietchTabr",
        "haggaBasinAndImperialBasin",
        "deepDesert",
    })
    Deck.load(loader, cards.hagal, "hagal", "reshuffle", 10, {
        "reshuffle"
    })
    Deck.load(loader, cards.hagal, "hagal", "ix", 1, {
        "interstellarShipping",
        "deliverSuppliesAndInterstellarShipping",
        "smugglingAndInterstellarShipping",
        "techNegotiation",
        "dreadnought1p",
        "dreadnought2p",
    })
    Deck.load(loader, cards.hagal, "hagal", "immortality", 1, {
        "researchStationImmortality",
        "tleilaxuBonus1",
        "tleilaxuBonus2",
        "tleilaxuBonus3",
    })

    -- One tech per custom deck.
    for techName, _ in pairs(Deck.tech) do
        Deck.load(loader, cards.tech, "tech", techName, 1, { techName })
    end

    -- One leader per custom deck.
    for leaderName, _ in pairs(Deck.leader) do
        Deck.load(loader, cards.leaders, "leader", leaderName, 1, { leaderName })
    end

    Deck.load(loader, cards.rivalLeaders, "rivalLeader", "uprising", 1, {
        "vladimirHarkonnen",
        "muadDib",
        "jessica",
        "feydRauthaHarkonnen",
        "margotFenring",
        "stabanTuek",
        "amberMetulli",
        "irulanCorrino",
        "gurneyHalleck",
        "glossuRabban",
    })

    return cards
end

return Deck
