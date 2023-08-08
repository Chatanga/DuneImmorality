local Helper = require("utils.Helper")

local Deck = {
    imperium = {
        -- starter with dune the desert planet
        starter = { "http://cloud-3.steamusercontent.com/ugc/2029469358243413427/BF3BA9C253ED953533B90D94DD56D0BAD4021B3C/", 4, 2 },
        -- base with foldspace, liasion, and the spice must flow
        imperium = { "http://cloud-3.steamusercontent.com/ugc/2029469358243390859/6F98BCE051343A3D07D58D6BC62A8FCA2C9AAE1A/", 8, 6 },
        -- new release card
        newImperium = { "http://cloud-3.steamusercontent.com/ugc/2027231506426140597/EED43686A0319F3C194702074F2D2B3E893642F7/", 1 , 1 },
        -- ix with control the spice
        ixImperium = { "http://cloud-3.steamusercontent.com/ugc/2029469358243344265/9DFCC56F20D09D60CF2B9D9050CB9640176F71B6/", 7, 5 },
        -- tleilax with experimentation
        immortalityImperium = { "http://cloud-3.steamusercontent.com/ugc/2042987130216749349/E758512421B5CB27BBA228EF5F1880A7F3DC564D/", 6, 5 },
        -- tleilax with reclaimed forces
        tleilaxResearch = { "http://cloud-3.steamusercontent.com/ugc/2029469358268075509/D9BD273651404E7DE7F0E22B36F2D426D82B07A8/", 4, 5 },
    },
    intrigue = {
        intrigue = { "http://cloud-3.steamusercontent.com/ugc/1892102433196338695/A63AE0E1069DA1279FDA3A5DE6A0E073F45FC8EF/", 7, 5 },
        ixIntrigue = { "http://cloud-3.steamusercontent.com/ugc/1892102433196442624/CE27F1B6D4D455A2D00D6E13FABEB72E6B9F05F1/", 5, 4 },
        immortalityIntrigue = { "http://cloud-3.steamusercontent.com/ugc/1892101972249341287/9FED90CD510F26618717CEB63FDA744CE916C6BA/", 6, 2 },
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
        hagal = { "http://cloud-3.steamusercontent.com/ugc/1701781845339075332/677B5A5C2EECAF60962F6002D7320601EB4E49AA/", 7, 2 },
        hagal_wealth = { "http://cloud-3.steamusercontent.com/ugc/1670239430231972899/4E94083423F0DD9F5B0A4E72BAC4A60328175163/", 1, 1 },
        hagal_arrakeen2p = { "http://cloud-3.steamusercontent.com/ugc/1670239430231975770/CAE72AEA7F428DB102776EBFD022458D58673955/", 1, 1 },
        ixHagal_dreadnought1p = { "http://cloud-3.steamusercontent.com/ugc/1833531164457147776/CC2DD2C8267024F457F281E0ECCBBE97DA75C6C0/", 1, 1 },
        ixHagal_dreadnought2p = { "http://cloud-3.steamusercontent.com/ugc/1833531164457143084/A92B5F8751A12CC7D42688E5C8B00A64D62FDDAB/", 1, 1 },
        ixHagal_techNegogiation1p = { "http://cloud-3.steamusercontent.com/ugc/1833531164457150040/2551267D6FE07F1742E239316376FF840CD7E711/", 1, 1 },
        ixHagal_interstellarShipping = { "http://cloud-3.steamusercontent.com/ugc/1833531164457161185/7B73BB94440A5E5F4032C692B58DAFFD759DBF98/", 1, 1 },
        ixHagal_foldspaceAndInterstellarShipping = { "http://cloud-3.steamusercontent.com/ugc/1833531164457148228/4F6C09B50E63B47E3F40BB9B605729DC67C3E458/", 1, 1 },
        ixHagal_smugglingAndInterstellarShipping = { "http://cloud-3.steamusercontent.com/ugc/1833531164457148962/352C9C2F86BCE0E8832CA2265D0C2A4829D11A14/", 1, 1 },
        imortalityHagal = { "http://cloud-3.steamusercontent.com/ugc/1974296545160677305/AA0F8C9CAE3E11C28EE4379FA045FF11DDD03C38/", 2, 2 },
        hagal_churn = { "http://cloud-3.steamusercontent.com/ugc/1759187425912025810/E59D268A3103235748A7CEE2535ED0BF97D61A9A/", 1, 1 },
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
        vladimirHarkonnen = { "http://cloud-3.steamusercontent.com/ugc/1892102433196216494/B5899377296C2BFAC0CF48E18AA3773AA8E998DE/", 1, 1 },
        glossuRabban = { "http://cloud-3.steamusercontent.com/ugc/1892102433196250329/DCF40F0D8C34B14180DC33B369DCC8AA4FD3FB55/", 1, 1 },
        ilbanRichese = { "http://cloud-3.steamusercontent.com/ugc/1892102433196246857/15624E52D08F594943A4A6332CBD68B2A1645441/", 1, 1 },
        helenaRichese = { "http://cloud-3.steamusercontent.com/ugc/1892102433196235077/63750F22F1DFBA9D9544587C0B2B8D65E157EC00/", 1, 1 },
        letoAtreides = { "http://cloud-3.steamusercontent.com/ugc/1892102433196254910/8CBD932BE474529D6C14A3AA8C01BD8503EBEBC6/", 1, 1 },
        paulAtreides = { "http://cloud-3.steamusercontent.com/ugc/1892102433196251690/F597DBF1EB750EA14EA03F231D0EBCF07212A5AC/", 1, 1 },
        arianaThorvald = { "http://cloud-3.steamusercontent.com/ugc/1892102433196206152/2A9043877494A7174A32770C39147FAE941A39A2/", 1, 1 },
        memnonThorvald = { "http://cloud-3.steamusercontent.com/ugc/1892102433196237593/8431F61C545067A4EADC017E6295CB249A2BD813/", 1, 1 },
        armandEcaz = { "http://cloud-3.steamusercontent.com/ugc/1892102433196276383/310C6B6E85920F9FC1A94896A335D34C3CFA6C15/", 1, 1 },
        ilesaEcaz = { "http://cloud-3.steamusercontent.com/ugc/1892102433196278257/94B1575474BEEF1F1E0FE0860051932398F47CA5/", 1, 1 },
        rhomburVernius = { "http://cloud-3.steamusercontent.com/ugc/1892102433196279801/0C06A30D74BD774D9B4F968C00AEC8C0817D4C77/", 1, 1 },
        tessiaVernius = { "http://cloud-3.steamusercontent.com/ugc/1892102433196279035/29817122A32B50C285EE07E0DAC32FDE9A237CEC/", 1, 1 },
        yunaMoritani = { "http://cloud-3.steamusercontent.com/ugc/1892102433196277499/FA54B129B168169E3D58BA61536FCC0BB5AB7D34/", 1, 1 },
        hundroMoritani = { "http://cloud-3.steamusercontent.com/ugc/1892102433196275601/6A89778D9C4BB8AC07FE503D48A4483D13DF6E5B/", 1, 1 },
        -- Fanmade
        metulli = { "file:///home/sadalsuud/Personnel/Productions/Code/Maison/DuneImperiumTTS/resources/preserved/Leaders fan made/09663a73d24af2db6a9315d87c5953614c0b0f32.jpeg", 1, 1 }, -- Duke? Not count Flambert Mutelli?
        hasimirFenring = { "file:///home/sadalsuud/Personnel/Productions/Code/Maison/DuneImperiumTTS/resources/preserved/Leaders fan made/3657671646912d7026e790b8de187b49975cbd0e.jpeg", 1, 1 },
        scytale = { "file:///home/sadalsuud/Personnel/Productions/Code/Maison/DuneImperiumTTS/resources/preserved/Leaders fan made/bfa284bbaba15a609401208f4d834fe916ea960e.jpeg", 1, 1 },
        torgTheYoung = { "file:///home/sadalsuud/Personnel/Productions/Code/Maison/DuneImperiumTTS/resources/preserved/Leaders fan made/66dcbbe36459c57fd8f631d8576f2cf01dfdc092.jpeg", 1, 1 },
        margotFenring = { "file:///home/sadalsuud/Personnel/Productions/Code/Maison/DuneImperiumTTS/resources/preserved/Leaders fan made/1964022795283817f32d219c1c38050a9b5303ad.jpeg", 1, 1 },
        feydRauthaHarkonnen = { "file:///home/sadalsuud/Personnel/Productions/Code/Maison/DuneImperiumTTS/resources/preserved/Leaders fan made/d80761b2286a313a11939e3d45debcf24f7d30cc.jpeg", 1, 1 },
        stabanTuek = { "file:///home/sadalsuud/Personnel/Productions/Code/Maison/DuneImperiumTTS/resources/preserved/Leaders fan made/1fcb42b17a8f7f711758bf5869cd3b7328e4542f.jpeg", 1, 1 },
        tylwythWaff = { "file:///home/sadalsuud/Personnel/Productions/Code/Maison/DuneImperiumTTS/resources/preserved/Leaders fan made/a7741dffe841114bddb8b6f8a2a57d2c59cddeeb.jpeg", 1, 1 },
        serenaButler = { "file:///home/sadalsuud/Personnel/Productions/Code/Maison/DuneImperiumTTS/resources/preserved/Leaders fan made/c4934e0587d33e2f1bb051d746a7eb30d2a6dea7.jpeg", 1, 1 },
        lietKynes = { "file:///home/sadalsuud/Personnel/Productions/Code/Maison/DuneImperiumTTS/resources/preserved/Leaders fan made/dc956cb7acbd2370dc3d86484765e413f36dbbff.jpeg", 1, 1 },
        arkhane = { "file:///home/sadalsuud/Personnel/Productions/Code/Maison/DuneImperiumTTS/resources/preserved/Leaders fan made/43f98bf29b58c81d6c1fabdc6d166bc0ed122953.jpeg", 1, 1 },
        wensiciaCorrino = { "file:///home/sadalsuud/Personnel/Productions/Code/Maison/DuneImperiumTTS/resources/preserved/Leaders fan made/c3d5184ad0f809a3f1f38bb16096af5dd4437fa5.jpeg", 1, 1 },
        irulanCorrino = { "file:///home/sadalsuud/Personnel/Productions/Code/Maison/DuneImperiumTTS/resources/preserved/Leaders fan made/4c33fe97c3efcabf776df966b59d2af15401d07e.jpeg", 1, 1 },
        hwiNoree = { "file:///home/sadalsuud/Personnel/Productions/Code/Maison/DuneImperiumTTS/resources/preserved/Leaders fan made/d3bb757794fcb5b9cf5d58798a697b354bd34eea.jpeg", 1, 1 },
        whitmoreBlund = { "file:///home/sadalsuud/Personnel/Productions/Code/Maison/DuneImperiumTTS/resources/preserved/Leaders fan made/feb8f943c50dfb711640347c6397243d71f9780a.jpeg", 1, 1 },
        drisq = { "file:///home/sadalsuud/Personnel/Productions/Code/Maison/DuneImperiumTTS/resources/preserved/Leaders fan made/2f2f3cf34b2737b7caef26433b3ecee9fe41b3af.jpeg", 1, 1 },
        executrix = { "file:///home/sadalsuud/Personnel/Productions/Code/Maison/DuneImperiumTTS/resources/preserved/Leaders fan made/69c591c92ed7fba903ecdad9c2ccc2b99ebbc5b0.jpeg", 1, 1 },
        milesTeg = { "file:///home/sadalsuud/Personnel/Productions/Code/Maison/DuneImperiumTTS/resources/preserved/Leaders fan made/299ecfbed3cd8f16774c5c69f8a957768cbbb66d.jpeg", 1, 1 },
        esmarTuek = { "file:///home/sadalsuud/Personnel/Productions/Code/Maison/DuneImperiumTTS/resources/preserved/Leaders fan made/edaf5084889aa22c19b915dfaddfeadab97f440f.jpeg", 1, 1 },
        abuldurHarkonnen = { "file:///home/sadalsuud/Personnel/Productions/Code/Maison/DuneImperiumTTS/resources/preserved/Leaders fan made/40b8a2b4f6f5da9a0c2d7738a3f5bfd925167438.jpeg", 1, 1 },
        normaCenva = { "file:///home/sadalsuud/Personnel/Productions/Code/Maison/DuneImperiumTTS/resources/preserved/Leaders fan made/4e8fc979a8689926a3a02ea748f402e7d76570ba.jpeg", 1, 1 },
        vorianAtreides = { "file:///home/sadalsuud/Personnel/Productions/Code/Maison/DuneImperiumTTS/resources/preserved/Leaders fan made/dfdb8318608d8f7b39273b40ebb4120fcee56b3e.jpeg", 1, 1 },
        xavierHarkonnen = { "file:///home/sadalsuud/Personnel/Productions/Code/Maison/DuneImperiumTTS/resources/preserved/Leaders fan made/43e90624d39b5a904ff112bd5a0b7c3d8aa21502.jpeg", 1, 1 },
    }
}

---
function Deck.load(loader, cards, category, customDeckName, startLuaIndex, cardNames)
    local desc = Deck[category][customDeckName]
    local functioName = Helper.toCamelCase("create", category, "CustomDeck")
    local customDeck = loader[functioName](desc[1], desc[2], desc[3])
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
        "duneTheDesertPlanet",
        "dagger",
        "reconnaissance",
        "convincingArgument",
        "seekAllies",
        "signetRing",
        "diplomacy"
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
        "feydakinDeathCommando",
        "geneManipulation",
        "guildBankers",
        "choamDirectorship",
        "crysknife",
        "chani",
        "spaceTravel",
        "duncanIdaho",
        "shiftinAllegiances",
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
        "powerPlay"
    })
    Deck.load(loader, cards.imperium, "imperium", "newImperium", 1, {
        "thumper"
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
        "blankState",
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
        "sardaukarQuatermaster",
        "shadoutMapes",
        "showOfStrength",
        "spiritualFervor",
        "stillsuitManufacturer",
        "throneRoomPolitics",
        "tleilaxuMaster",
        "tleilaxuSurgeon"
    })
    Deck.load(loader, cards.special, "imperium", "imperium", 5, {
        "foldspace",
        "arrakisLiaison",
        "theSpiceMustFlow",
    })
    Deck.load(loader, cards.special, "imperium", "tleilaxResearch", 11, {
        "reclaimedForces",
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
        "tleilaxuInflitrator",
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
        "masterTacitian",
        "planWithinPlans",
        "privateArmy",
        "doubleCross",
        "concilorsDispensiation",
        "cornerTheMarket",
        "charisma",
        "calculatedHire",
        "choamShare",
        "bypassProtocol",
        "recruitmentMission",
        "reinforcements",
        "binduSuspension",
        "secretOfTheSiterhood",
        "rapidMobilization",
        "stagedIncident",
        "theSleeperMustAwaken",
        "tiebreaker",
        "toTheVictor",
        "waterPeedelsUnion",
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
        "economySupremacy"
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

    return cards
end

return Deck
