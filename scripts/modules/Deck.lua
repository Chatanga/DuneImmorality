local Module = require("utils.Module")
local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

local Locale = Module.lazyRequire("Locale")

local Deck = {
    sources = {},
    starter = {
        -- per player arity
        base = {
            duneTheDesertPlanet = 2,
            seekAllies = 1,
            signetRing = 1,
            diplomacy = 1,
            reconnaissance = 1,
            convincingArgument = 2,
            dagger = 2,
        },
        epic = {
            controlTheSpice = 1,
        },
        immortality = {
            duneTheDesertPlanet = Helper.ERASE,
            experimentation = 2,
        },
        emperor = {
            emperorConvincingArgument = 1,
            emperorCorrinoMight = 1,
            emperorCriticalShipments = 1,
            emperorDemandResults = 1,
            emperorDevastatingAssault = 1,
            emperorImperialOrnithopter = 2,
            emperorSignetRing = 1,
            emperorSeekAllies = 1,
            emperorImperialTent = 1,
        },
        muadDib = {
            muadDibCommandRespect = 1,
            muadDibConvincingArgument = 1,
            muadDibDemandAttention = 1,
            muadDibDesertCall = 1,
            muadDibLimitedLandsraadAccess = 2,
            muadDibSeekAllies = 1,
            muadDibUsul = 1,
            muadDibThreatenSpiceProduction = 1,
            muadDibSignetRing = 1,
        },
    },
    imperium = {
        base = {
            jessicaOfArrakis = 1, -- release promo
            sardaukarLegion = 2,
            drYueh = 1,
            assassinationMission = 2,
            sardaukarInfantry = 2,
            beneGesseritInitiate = 2,
            guildAdministrator = 2,
            theVoice = 2,
            scout = 2,
            imperialSpy = 2,
            beneGesseritSister = 3,
            missionariaProtectiva = 2, -- First released fixed in Rise of Ix
            spiceHunter = 2,
            spiceSmugglers = 2,
            feydakinDeathCommando = 2,
            geneManipulation = 2,
            guildBankers = 1,
            choamDirectorship = 1,
            crysknife = 1,
            chani = 1,
            spaceTravel = 2,
            duncanIdaho = 1,
            shiftingAllegiances = 2,
            kwisatzHaderach = 1,
            sietchReverendMother = 1,
            arrakisRecruiter = 2,
            firmGrip = 1,
            smugglersThopter = 2,
            carryall = 1,
            gunThopter = 2,
            guildAmbassador = 1,
            testOfHumanity = 1,
            fremenCamp = 2,
            opulence = 1,
            ladyJessica = 1,
            stilgar = 1,
            piterDeVries = 1,
            gurneyHalleck = 1,
            thufirHawat = 1,
            otherMemory = 1,
            lietKynes = 1,
            wormRiders = 2,
            reverendMotherMohiam = 1,
            powerPlay = 3,
            duncanLoyalBlade = 1, -- Deluxe upgrade pack release promo
            thumper = 1, -- New realease promo
        },
        ix = {
            boundlessAmbition = 1, -- Rise of Ix release promo
            guildChiefAdministrator = 1,
            guildAccord = 1,
            localFence = 1,
            shaiHulud = 1,
            ixGuildCompact = 1,
            choamDelegate = 1,
            bountyHunter = 1,
            embeddedAgent = 1,
            esmarTuek = 1,
            courtIntrigue = 1,
            sayyadina = 1,
            imperialShockTrooper = 1,
            appropriate = 1,
            desertAmbush = 1,
            inTheShadows = 2,
            satelliteBan = 1,
            freighterFleet = 2,
            imperialBashar = 1,
            jamis = 1,
            landingRights = 1,
            waterPeddlersUnion = 1,
            treachery = 2,
            truthsayer = 2,
            spiceTrader = 1,
            ixianEngineer = 2,
            webOfPower = 1,
            weirdingWay = 1,
            negotiatedWithdrawal = 2,
            fullScaleAssault = 1,
        },
        immortality = {
            beneTleilaxLab = 1,
            beneTleilaxResearcher = 1,
            blankSlate = 1,
            clandestineMeeting = 1,
            corruptSmuggler = 1,
            dissectingKit = 2,
            forHumanity = 1,
            highPriorityTravel = 2,
            imperiumCeremony = 1,
            interstellarConspiracy = 1,
            keysToPower = 1,
            lisanAlGaib = 1,
            longReach = 1,
            occupation = 1,
            organMerchants = 1,
            plannedCoupling = 2,
            replacementEyes = 1,
            sardaukarQuartermaster = 1,
            shadoutMapes = 1,
            showOfStrength = 1,
            spiritualFervor = 2,
            stillsuitManufacturer = 1,
            throneRoomPolitics = 1,
            tleilaxuMaster = 2,
            tleilaxuSurgeon = 1,
        },
        uprising = {
            unswervingLoyalty = 2,
            spaceTimeFolding = 1,
            weirdingWoman = 2,
            sardaukarSoldier = 1,
            smugglerHarvester = 2,
            makerKeeper = 2,
            reliableInformant = 1,
            hiddenMissive = 1,
            wheelsWithinWheels = 1,
            fedaykinStilltent = 1,
            imperialSpymaster = 1,
            spyNetwork = 1,
            desertSurvival = 2,
            undercoverAsset = 1,
            beneGesseritOperative = 2,
            maulaPistol = 2,
            thumper = 1,
            nothernWatermaster = 1,
            covertOperation = 1,
            doubleAgent = 2,
            guildEnvoy = 1,
            rebelSupplier = 2,
            calculusOfPower = 2,
            guildSpy = 1,
            dangerousRhetoric = 1,
            branchingPath = 1,
            ecologicalTestingStation = 1,
            theBeastSpoils = 1,
            smugglerHaven = 1,
            shishakli = 1,
            paracompass = 1,
            sardaukarCoordination = 2,
            truthtrance = 2,
            publicSpectable = 2,
            southernElders = 1,
            treadInDarkness = 2,
            spacingGuildFavor = 2,
            capturedMentat = 1,
            subversiveAdvisor = 1,
            leadership = 1,
            inHighPlaces = 1,
            strikeFleet = 1,
            trecherousManeuver = 1,
            chaniCleverTactician = 1,
            junctionHeadquarters = 1,
            corrinthCity = 1,
            stilgarTheDevoted = 1,
            desertPower = 1,
            arrakisRevolt = 1,
            priceIsNoObject = 1,
            longLiveTheFighters = 1,
            overthrow = 1,
            steersman = 1,
        },
        uprisingContract = {
            cargoRunner = 1,
            deliveryAgreement = 1,
            priorityContracts = 1,
            interstellarTrade = 1,
        },
    },
    special = {
        base = {
            foldspace = 6,
            arrakisLiaison = 8,
            theSpiceMustFlow = 10,
        },
        immortality = {
            reclaimedForces = 1,
        },
        uprising = {
            prepareTheWay = 8,
            theSpiceMustFlowNew = 10,
        },
    },
    tleilaxu = {
        piterGeniusAdvisor = 1, -- Immortality release promo
        beguilingPheromones = 1,
        chairdog = 1,
        contaminator = 1,
        corrinoGenes = 1,
        faceDancer = 1,
        faceDancerInitiate = 1,
        fromTheTanks = 1,
        ghola = 1,
        guildImpersonator = 1,
        industrialEspionage = 1,
        scientificBreakthrough = 1,
        sligFarmer = 1,
        stitchedHorror = 1,
        subjectX137 = 1,
        tleilaxuInfiltrator = 1,
        twistedMentat = 1,
        unnaturalReflexes = 1,
        usurp = 1
    },
    intrigue = {
        base = {
            bribery = 1,
            refocus = 1,
            ambush = 2,
            alliedArmada = 1,
            favoredSubject = 1,
            demandRespect = 1,
            poisonSnooper = 2,
            guildAuthorization = 1,
            dispatchAnEnvoy = 1,
            infiltrate = 1,
            knowTheirWays = 1,
            masterTactician = 3,
            plansWithinPlans = 1,
            privateArmy = 2,
            doubleCross = 1,
            councilorsDispensation = 2,
            cornerTheMarket = 1,
            charisma = 1,
            calculatedHire = 1,
            choamShares = 1,
            bypassProtocol = 1,
            recruitmentMission = 1,
            reinforcements = 1,
            binduSuspension = 1,
            secretOfTheSisterhood = 1,
            rapidMobilization = 1,
            stagedIncident = 1,
            theSleeperMustAwaken = 1,
            tiebreaker = 1,
            toTheVictor = 1,
            waterPeedlersUnion = 1,
            windfall = 1,
            waterOfLife = 1,
            urgentMission = 1,
        },
        ix = {
            diversion = 1,
            warChest = 1,
            advancedWeaponry = 1,
            secretForces = 1,
            grandConspiracy = 1,
            cull = 1,
            strategicPush = 1,
            blackmail = 1,
            machineCulture = 1,
            cannonTurrets = 1,
            expedite = 1,
            ixianProbe = 1,
            secondWave = 1,
            glimpseThePath = 1,
            finesse = 1,
            strongarm = 1,
            quidProQuo = 1,
        },
        immortality = {
            breakthrough = 1,
            counterattack = 1,
            disguisedBureaucrat = 1,
            economicPositioning = 1,
            gruesomeSacrifice = 2,
            harvestCells = 2,
            illicitDealings = 2,
            shadowyBargain = 1,
            studyMelange = 1,
            tleilaxuPuppet = 1,
            viciousTalents = 2,
        },
        uprising = {
            sietchRitual = 1,
            mercenaries = 1,
            councilorAmbition = 1,
            strategicStockpiling = 1,
            detonation = 2,
            departForArrakis = 1,
            cunning = 1,
            opportunism = 1,
            changeAllegiances = 1,
            specialMission = 2,
            unexpectedAllies = 1,
            callToArms = 1,
            buyAccess = 1,
            imperiumPolitics = 1,
            shaddamFavor = 1,
            intelligenceReport =1,
            manipulate = 1,
            distraction = 2,
            marketOpportunity = 1,
            goToGround = 1,
            contingencyPlan = 3,
            inspireAwe = 1,
            findWeakness = 1,
            spiceIsPower = 1,
            devour = 1,
            impress = 1,
            springTheTrap = 1,
            weirdingCombat = 1,
            tacticalOption = 1,
            questionableMethods = 1,
            desertMouse = 1,
            ornithopter = 1,
            crysknife = 1,
            shadowAlliance = 1,
            secureSpiceTrade = 1,
        },
        uprisingContract = {
            leverage = 1,
            backedByChoam = 1,
            reachAgreement = 1,
            choamProfits = 1,
        }
    },
    conflict = {
        level1 = {
            base = {
                skirmishA = 1,
                skirmishB = 1,
                skirmishC = 1,
                skirmishD = 1,
            },
            ix = {
                skirmishE = 1,
                skirmishF = 1,
            },
            uprising = {
                skirmishG = 1,
                skirmishH = 1,
                skirmishI = 1,
            },
        },
        level2 = {
            base = {
                desertPower = 1,
                raidStockpiles = 1,
                cloakAndDagger = 1,
                machinations = 1,
                sortThroughTheChaos = 1,
                terriblePurpose = 1,
                guildBankRaid = 1,
                siegeOfArrakeen = 1,
                siegeOfCarthag = 1,
                secureImperialBasin = 1,
            },
            ix = {
                tradeMonopoly = 1,
            },
            uprising = {
                choamSecurity = 1,
                spiceFreighters = 1,
                siegeOfArrakeenNew = 1,
                seizeSpiceRefinery = 1,
                testOfLoyalty = 1,
                shadowContest = 1,
                secureImperialBasinNew = 1,
                protectTheSietches = 1,
                tradeDispute = 1,
            },
        },
        level3 = {
            base = {
                battleForImperialBasin = 1,
                grandVision = 1,
                battleForCarthag = 1,
                battleForArrakeen = 1,
            },
            ix = {
                economicSupremacy = 1,
            },
            uprising = {
                propaganda = 1,
                battleForImperialBasinNew = 1,
                battleForArrakeenNew = 1,
                battleForSpiceRefinery = 1,
            }
        },
    },
    hagal = {
        base = {
            other = {
                -- FIXME
                churn = 2,
            },
            core = {
                conspire = 2,
                wealth = 1,
                heighliner = 1,
                foldspace = 2,
                selectiveBreeding = 2,
                secrets = 1,
                hardyWarriors = 1,
                stillsuits = 2,
                rallyTroops = 2,
                hallOfOratory = 2,
                carthag = 3,
                harvestSpice = 5,
            },
            solo = {
                arrakeen1p = 3,
            },
            twoPlayers = {
                reshuffle = 1,
                arrakeen2p = 3,
            }
        },
        ix = {
            core = {
                rallyTroops = Helper.ERASE,
                hallOfOratory = Helper.ERASE,
                interstellarShipping = 1,
                foldspaceAndInterstellarShipping = 1,
                smugglingAndInterstellarShipping = 1,
            },
            solo = {
                techNegotiation = 2,
                dreadnought1p = 2,
            },
            twoPlayers = {
                dreadnought2p = 2,
            }
        },
        immortality = {
            core = {},
            solo = {
                researchStation = 1,
                carthag = Helper.ERASE,
                carthag1 = 1,
                carthag2 = 1,
                carthag3 = 1,
            },
            twoPlayers = {}
        }
    },
    tech = {
        ix = {
            spaceport = 1,
            restrictedOrdnance = 1,
            artillery = 1,
            disposalFacility = 1,
            holoprojectors = 1,
            minimicFilm = 1,
            windtraps = 1,
            detonationDevices = 1,
            memocorders = 1,
            flagship = 1,
            shuttleFleet = 1,
            spySatellites = 1,
            chaumurky = 1,
            sonicSnoopers = 1,
            trainingDrones = 1,
            troopTransports = 1,
            holtzmanEngine = 1,
            invasionShips = 1,
        },
    },
    leaders = {
        base = {
            vladimirHarkonnen = 1,
            glossuRabban = 1,
            ilbanRichese = 1,
            helenaRichese = 1,
            letoAtreides = 1,
            paulAtreides = 1,
            arianaThorvald = 1,
            memnonThorvald = 1,
        },
        ix = {
            armandEcaz = 1,
            ilesaEcaz = 1,
            rhomburVernius = 1,
            tessiaVernius = 1,
            yunaMoritani = 1,
            hundroMoritani = 1,
        },
        uprising = {
            stabanTuek = 1,
            amberMetulli = 1,
            gurneyHalleck = 1,
            margotFenring = 1,
            irulanCorrino = 1,
            jessicaAtreides = 1,
            feydRauthaHarkonnen = 1,
            shaddamCorrino = 1,
            muadDib = 1,
        },
        uprisingAlt = {
            reverendMotherJessica = 1,
        }
    },
}

local imperiumCardBack = "http://cloud-3.steamusercontent.com/ugc/2093667512238502565/C3DC7A02CF378129569B414967C9BE25097C6E77/"
local intrigueCardBack = "http://cloud-3.steamusercontent.com/ugc/2093667512238521846/D63B92C616541C84A7984026D757DB03E79532DD/"
local techCardBack = "http://cloud-3.steamusercontent.com/ugc/2093667512238531825/1EA614EC832B16BC94811A7FE793344057850409/"
local conflict1CardBack = "http://cloud-3.steamusercontent.com/ugc/2093667512238537179/0423ECA84C0D71CCB38EBD60DEAE641EE72D7933/"
local conflict2CardBack = "http://cloud-3.steamusercontent.com/ugc/2093667512238537448/3B3F54DF65F76F0850D0EC683602524806A11E49/"
local conflict3CardBack = "http://cloud-3.steamusercontent.com/ugc/2093667512238537046/9E194557E37B5C4CA74C7A77CBFB6B8A36043916/"
local objectiveCardBack = "http://cloud-3.steamusercontent.com/ugc/2220898342999519816/02A61DC439DF213EA61A8CCEC1F545F4D369F2E8/"
local hagalCardBack = "http://cloud-3.steamusercontent.com/ugc/2093668799785646965/26E28590801800D852F4BCA53E959AAFAAFC8FF3/"
local leaderCardBack = "http://cloud-3.steamusercontent.com/ugc/2093668799785645356/005244DAC0A29EE68CFF741FC06564969563E8CF/"

local customDeckBaseId = 100

---
function Deck.rebuildPreloadAreas()
    Locale.onLoad()
    local allSupports = {
        en = require("en.Deck"),
        fr = require("fr.Deck"),
    }

    for _, guid in ipairs({ "a5a2e6", "db4507" }) do
        local zone = getObjectFromGUID(guid)
        assert(zone)
        for _, object in ipairs(zone.getObjects()) do
            if object.type == "Deck" then
                object.destruct()
            end
        end
    end

    Helper.onceFramesPassed(1).doAfter(function ()
        for language, _ in pairs(allSupports) do
            I18N.setLocale(language)

            local support = allSupports[language]
            local sources = support.loadCustomDecks(Deck)

            local areas = getObjectsWithTag("deckPreloadArea" .. language)
            assert(#areas == 1)
            local origin = areas[1].getPosition()

            for i, category in ipairs({
                "objective",
                "imperium",
                "special",
                "tleilaxu",
                "intrigue",
                "conflict",
                "hagal",
                "tech",
                "leaders",
            }) do
                local contributions = {}
                local categorySources = {}
                Helper.forEach(sources[category], function (card, customDeck)
                    contributions[card] = 1
                    categorySources[card] = customDeck
                end)

                Deck._generateDeck("Imperium", origin + Vector(0, 0, 4 * i - 20), contributions, categorySources).doAfter(function (deck)
                    deck.setInvisibleTo(Player.getColors())
                    Helper.dump("Loaded", language, "/", category)
                end)
            end
        end
    end)
end

---
function Deck.onLoad()
    for _, guid in ipairs({ "a5a2e6", "db4507" }) do
        local zone = getObjectFromGUID(guid)
        if zone then
            for _, object in ipairs(zone.getObjects()) do
                object.setInvisibleTo(Player.getColors())
            end
        end
    end
end

---
function Deck.setUp(settings)
    --Helper.dumpFunction("Deck.setUp")
    local support

    if settings.language == "en" then
        support = require("en.Deck")
    elseif settings.language == "fr" then
        support = require("fr.Deck")
        -- Change main boards textures (4P/6P) after some time.
        if settings.language == "fr" then
            Wait.time(Deck._mutateMainBoards, 10)
        end
    else
        error("Unsupported language: " .. settings.language)
    end

    Deck.sources = support.loadCustomDecks(Deck)
end

---
function Deck._mutateMainBoards()
    local boards = {
        board4P = { guid = "483a1a", url = "http://cloud-3.steamusercontent.com/ugc/2305342013587677822/8DBDCE4796B52A64AE78D5F95A1CD0B87A87F66D/" },
        board6P = { guid = "21cc52", url = "http://cloud-3.steamusercontent.com/ugc/2305342013587679397/718503B8558D419B491BF1624D72BCF13941A8F5/" },
    }

    for name, boardInfo in pairs(boards) do
        local board = getObjectFromGUID(boardInfo.guid)
        if board then
            --Helper.dump("Mutating board " .. name)
            local parameters = board.getCustomObject()
            parameters.image = boardInfo.url
            board.setCustomObject(parameters)
            board.reload()
        end
    end
end

---
function Deck.generateObjectiveDeck(deckZone, cardNames)
    --Helper.dump("generateObjectiveDeck")
    assert(deckZone)
    local continuation = Helper.createContinuation("Deck.generateObjectiveDeck")
    Deck._generateDeck("Objective", deckZone.getPosition(), cardNames, Deck.sources.objective).doAfter(continuation.run)
    return continuation
end

---
function Deck.generateStarterDeck(deckZone, immortality, epic)
    --Helper.dump("generateStarterDeck")
    assert(deckZone)
    local continuation = Helper.createContinuation("Deck.generateStarterDeck")
    local contributionSets = { Deck.starter.base }
    if immortality then
        table.insert(contributionSets, Deck.starter.immortality)
    end
    local contributions = Deck._mergeContributionSets(contributionSets)
    if not immortality and epic then
        contributions["duneTheDesertPlanet"] = 1
        contributions["controlTheSpice"] = 1
    end
    Deck._generateDeck("Imperium", deckZone.getPosition(), contributions, Deck.sources.imperium).doAfter(continuation.run)
    return continuation
end

---
function Deck.generateEmperorStarterDeck(deckZone)
    --Helper.dump("generateEmperorStarterDeck")
    assert(deckZone)
    local continuation = Helper.createContinuation("Deck.generateEmperorStarterDeck")
    local contributionSets = { Deck.starter.emperor }
    local contributions = Deck._mergeContributionSets(contributionSets)
    Deck._generateDeck("Imperium", deckZone.getPosition(), contributions, Deck.sources.imperium).doAfter(continuation.run)
    return continuation
end

---
function Deck.generateMuadDibStarterDeck(deckZone)
    --Helper.dump("generateMuadDibStarterDeck")
    assert(deckZone)
    local continuation = Helper.createContinuation("Deck.generateMuadDibStarterDeck")
    local contributionSets = { Deck.starter.muadDib }
    local contributions = Deck._mergeContributionSets(contributionSets)
    Deck._generateDeck("Imperium", deckZone.getPosition(), contributions, Deck.sources.imperium).doAfter(continuation.run)
    return continuation
end

---
function Deck.generateStarterDiscard(discardZone, immortality, epic)
    --Helper.dump("generateStarterDiscard")
    assert(discardZone)
    local continuation = Helper.createContinuation("Deck.generateStarterDiscard")
    if immortality and epic then
        Deck._generateDeck("Imperium", discardZone.getPosition(), Deck.starter.epic, Deck.sources.imperium).doAfter(function (deck)
            deck.flip()
            continuation.run(deck)
        end)
    else
        continuation.cancel()
    end
    return continuation
end

---
function Deck.generateImperiumDeck(deckZone, contracts, ix, immortality)
    --Helper.dump("generateImperiumDeck")
    assert(deckZone)
    local continuation = Helper.createContinuation("Deck.generateImperiumDeck")
    local contributions = Deck._mergeStandardContributionSets(Deck.imperium, ix, immortality)
    if contracts then
        contributions = Deck._mergeContributionSets({ contributions, Deck.imperium.uprisingContract })
    end
    Deck._generateDeck("Imperium", deckZone.getPosition(), contributions, Deck.sources.imperium).doAfter(continuation.run)
    return continuation
end

---
function Deck.generateSpecialDeck(parent, name, deckZone)
    --Helper.dump("generateSpecialDeck")
    assert(deckZone, name)
    local continuation = Helper.createContinuation("Deck.generateSpecialDeck")
    assert(name)
    assert(Deck.special[parent][name], name)
    local contributions = { [name] = Deck.special[parent][name] }
    Deck._generateDeck("Imperium", deckZone.getPosition(), contributions, Deck.sources.special).doAfter(function (deck)
        deck.flip()
        continuation.run(deck)
    end)
    return continuation
end

---
function Deck.generateTleilaxuDeck(deckZone)
    --Helper.dump("generateTleilaxuDeck")
    assert(deckZone)
    local continuation = Helper.createContinuation("Deck.generateTleilaxuDeck")
    Deck._generateDeck("Imperium", deckZone.getPosition(), Deck.tleilaxu, Deck.sources.tleilaxu).doAfter(continuation.run)
    return continuation
end

---
function Deck.generateIntrigueDeck(deckZone, contracts, ix, immortality)
    --Helper.dump("generateIntrigueDeck")
    assert(deckZone)
    local continuation = Helper.createContinuation("Deck.generateIntrigueDeck")
    local contributions = Deck._mergeStandardContributionSets(Deck.intrigue, ix, immortality)
    if contracts then
        contributions = Deck._mergeContributionSets({ contributions, Deck.intrigue.uprisingContract })
    end
    Deck._generateDeck("Intrigue", deckZone.getPosition(), contributions, Deck.sources.intrigue).doAfter(continuation.run)
    return continuation
end

---
function Deck.generateTechDeck(deckZones)
    --Helper.dump("generateTechDeck")
    assert(deckZones)
    assert(#deckZones == 3)
    local continuation = Helper.createContinuation("Deck.generateTechDeck")

    local keys = Helper.getKeys(Deck.tech.ix)
    Helper.shuffle(keys)

    local decks = {}

    local remaining = 0
    for i = 1, 3 do
        remaining = remaining + 1
        local part = {}
        for j = (i - 1) * 6 + 1, i * 6 do
            part[keys[j]] = Deck.tech.ix[keys[j]]
        end
        local deckZone = deckZones[i]
        Deck._generateDeck("Tech", deckZone.getPosition(), part, Deck.sources.tech).doAfter(function (deck)
            local above = deckZone.getPosition() + Vector(0, 1, 0)
            Helper.moveCardFromZone(deckZone, above, nil, true, true)
            table.insert(decks, deck)
            remaining = remaining - 1
            if remaining == 0 then
                continuation.run(decks)
            end
        end)
    end

    return continuation
end

--
function Deck.generateConflictDeck(deckZone, ix, epic)
    --Helper.dump("generateConflictDeck")
    assert(deckZone)
    local continuation = Helper.createContinuation("Deck.generateConflictDeck")

    local cardCounts = epic and { 0, 5, 5 } or { 1, 5, 4 }

    local contributions = {}
    for level = 1, 3 do
        local cardCount = cardCounts[level]
        if cardCount > 0 then
            local levelContributions = Deck._mergeStandardContributionSets(Deck.conflict["level" .. tostring(level)], ix, false)
            local cardNames = Helper.getKeys(levelContributions)
            Helper.shuffle(cardNames)
            for i = 1, cardCounts[level] do
                contributions[cardNames[i]] = 1
            end
        end
    end

    local position = deckZone.getPosition() + Vector(0, 1, 0)
    Deck._generateDeck("Conflict", position, contributions, Deck.sources.conflict).doAfter(continuation.run)

    return continuation
end

---
function Deck.generateHagalDeck(deckZone, ix, immortality, playerCount)
    --Helper.dump("generateHagalDeck")
    assert(deckZone)
    assert(playerCount == 1 or playerCount == 2)
    local continuation = Helper.createContinuation("Deck.generateHagalDeck")

    local contributionSetNames = { "base" }
    if ix then
        table.insert(contributionSetNames, "ix")
    end
    if immortality then
        table.insert(contributionSetNames, "immortality")
    end

    local contributionSets = {}
    for _, contributionSetName in ipairs(contributionSetNames) do
        local root = Deck.hagal[contributionSetName]
        table.insert(contributionSets, root.core)
        if playerCount == 1 then
            table.insert(contributionSets, root.solo)
        elseif playerCount == 2 then
            table.insert(contributionSets, root.twoPlayers)
        end
    end

    local contributions = Deck._mergeContributionSets(contributionSets)
    Deck._generateDeck("Hagal", deckZone.getPosition(), contributions, Deck.sources.hagal).doAfter(continuation.run)
    return continuation
end

---
function Deck.generateLeaderDeck(deckZone, contracts, ix, immortality, fanmadeLeaders)
    --Helper.dump("generateLeaderDeck")
    assert(deckZone)
    local continuation = Helper.createContinuation("Deck.generateLeaderDeck")
    local contributions = Deck._mergeStandardContributionSets(Deck.leaders, ix, immortality)
    if not contracts then
        contributions.shaddamCorrino = nil
    end
    if fanmadeLeaders then
        local locale = I18N.getLocale()
        if locale == 'fr' then
            contributions = Deck._mergeContributionSets({ contributions, Deck._mergeStandardContributionSets(Deck.leaders.fanmade.arkhane, ix, immortality) })
        elseif locale == 'en' then
            contributions = Deck._mergeStandardContributionSets(Deck.leaders.fanmade.retienne, ix, immortality)
        end
    end
    Deck._generateDeck("Leader", deckZone.getPosition(), contributions, Deck.sources.leaders).doAfter(continuation.run)
    return continuation
end

---
function Deck.generateSingleLeaderDeck(position, leaderName)
    --Helper.dump("generateSingleLeaderDeck")
    local continuation = Helper.createContinuation("Deck.generateSingleLeaderDeck")
    local contributions = { [leaderName] = 1 }
    Deck._generateDeck("Leader", position, contributions, Deck.sources.leaders).doAfter(continuation.run)
    return continuation
end

---
function Deck._mergeStandardContributionSets(root, ix, immortality)
    local contributionSets = { root.uprising }
    if ix then
        table.insert(contributionSets, root.ix)
    end
    if immortality then
        table.insert(contributionSets, root.immortality)
    end
    return Deck._mergeContributionSets(contributionSets)
end

---
function Deck._mergeContributionSets(contributionSets)
    local contributions = {}
    for _, contributionSet in ipairs(contributionSets) do
        for name, arity in pairs(contributionSet) do
            local currentArity
            if arity == Helper.ERASE then
                currentArity = nil
            else
                currentArity = contributions[name]
                if currentArity then
                    currentArity = currentArity + arity
                else
                    currentArity = arity
                end
            end
            contributions[name] = currentArity
        end
    end
    return contributions
end

--- Load part of a "custom deck" (an image made of tiled cards) into a named card
--- collection. Only the cards listed in cardNames are added.
--- The startLuaIndex could be greater than 1 to skip the first cards, whereas
--- empty names ("") allows to skip intermediate cards.
---@param cards any The set where to add the namec cards.
---@param customDeck any A custom deck (API struct) as returned by Deck.createImperiumCustomDeck.
---@param startLuaIndex any The Lua start index for the card names.
---@param cardNames any An list of card names matching those in the custon deck.
function Deck.loadCustomDeck(cards, customDeck, startLuaIndex, cardNames)
    --Helper.dumpFunction("Deck.loadCustomDeck", cards, customDeck, startLuaIndex, cardNames)
    assert(cards)
    assert(customDeck)
    assert(startLuaIndex and startLuaIndex > 0)
    assert(cardNames)
    for i, name in ipairs(cardNames) do
        if name ~= "" then
            cards[name] = { customDeck = customDeck, luaIndex = startLuaIndex + i - 1 }
        end
    end
end

---
function Deck._generateCardData(customDeck, customDeckId, cardId)
    assert(customDeck, "customDeck")
    assert(customDeckId, "customDeckId")
    assert(cardId, "cardId")

    assert(customDeck.__scale)

    -- We do not provide a missleading GUID!
    local data = {
        Name = "Card",
        Transform = {
            posX = 0,
            posY = 0,
            posZ = 0,
            rotX = 0,
            rotY = 0,
            rotZ = 0,
            scaleX = customDeck.__scale.x,
            scaleY = customDeck.__scale.y,
            scaleZ = customDeck.__scale.z
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
        Tags = {},
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
        Tooltip = false,
        GridProjection = false,
        HideWhenFaceDown = true,
        Hands = true,
        CardID = cardId,
        SidewaysCard = false,
        CustomDeck = {
            [tostring(customDeckId)] = customDeck
        }
    }

    return data
end

---
function Deck._generateDeck(deckName, position, contributions, sources)
    assert(deckName)
    assert(position)
    assert(contributions)
    assert(sources)

    local data = {
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
        Tags = { deckName },
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

    local knownCustomDecks = {}

    for name, cardinality in pairs(contributions) do
        local source = sources[name]
        if source then
            local customDeckId = knownCustomDecks[source.customDeck]
            if not customDeckId then
                customDeckId = Deck._nextCustomDeckId()
                data.CustomDeck[tostring(customDeckId)] = source.customDeck
                data.Transform.scaleX = source.customDeck.__scale.x
                data.Transform.scaleY = source.customDeck.__scale.y
                data.Transform.scaleZ = source.customDeck.__scale.z
                knownCustomDecks[source.customDeck] = customDeckId
            end

            for _ = 1, cardinality do
                local index = source.luaIndex - 1
                local cardId = tostring(customDeckId * 100 + index)
                table.insert(data.DeckIDs, tostring(cardId))
                local cardData = Deck._generateCardData(source.customDeck, customDeckId, cardId)
                cardData.Tags = { deckName }
                cardData.Nickname = I18N(name)
                cardData.GMNotes = name
                table.insert(data.ContainedObjects, cardData)
            end
        else
            error("No source for card '" .. name .. "'")
        end
    end

    local continuation = Helper.createContinuation("Deck._generateDeck")

    local spawnParameters = {
        data = #data.ContainedObjects == 1 and data.ContainedObjects[1] or data,
        position = position,
        rotation = Vector(0, 180, 180),
        callback_function = continuation.run
    }

    spawnObjectData(spawnParameters)

    if deckName == "Hagal" then
        --log(spawnParameters.data)
    end

    return continuation
end

---
function Deck._nextCustomDeckId()
    customDeckBaseId = customDeckBaseId + 1
    return customDeckBaseId
end

---
function Deck.createObjectiveCustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(objectiveCardBack, faceUrl, width, height, Vector(1, 1, 1))
end

---
function Deck.createImperiumCustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(imperiumCardBack, faceUrl, width, height, Vector(1.05, 1, 1.05))
end

---
function Deck.createIntrigueCustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(intrigueCardBack, faceUrl, width, height, Vector(1, 1, 1))
end

---
function Deck.createTechCustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(techCardBack, faceUrl, width, height, Vector(0.55, 1, 0.55))
end

---
function Deck.createConflict1CustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(conflict1CardBack, faceUrl, width, height, Vector(1, 1, 1))
end

---
function Deck.createConflict2CustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(conflict2CardBack, faceUrl, width, height, Vector(1, 1, 1))
end

---
function Deck.createConflict3CustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(conflict3CardBack, faceUrl, width, height, Vector(1, 1, 1))
end

---
function Deck.createHagalCustomDeck(faceUrl, width, height, scale)
    return Deck.createCustomDeck(hagalCardBack, faceUrl, width, height, scale or Vector(0.83, 1, 0.83))
end

---
function Deck.createLeaderCustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(leaderCardBack, faceUrl, width, height, Vector(1.12, 1, 1.12))
end

---
function Deck.createCustomDeck(backUrl, faceUrl, width, height, scale)
    assert(backUrl)
    assert(faceUrl)
    assert(width)
    assert(height)
    assert(scale)
    return {
        FaceURL = faceUrl,
        BackURL = backUrl,
        NumWidth = width,
        NumHeight = height,
        BackIsHidden = true,
        UniqueBack = false,
        Type = 0,
        __scale = scale
    }
end

return Deck
