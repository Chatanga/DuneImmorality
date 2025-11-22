local Module = require("utils.Module")
local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

local Locale = Module.lazyRequire("Locale")

local Deck = {
    decals = {
        corrinoAcquireCard = "https://steamusercontent-a.akamaihd.net/ugc/2502404390141304246/9E9986D0F348F5D23A16745A271FFD28958651FB/",
        genericAcquireCard = "https://steamusercontent-a.akamaihd.net/ugc/2502404390141305713/5F7C572489E5E03F3230B012DA0E01A84EDAABF8/",
        sardaukarAcquireCard = "https://steamusercontent-a.akamaihd.net/ugc/16046670112954493226/F677AA2397AB2A856597F63304AD4275FD3FF7E2/",
    },
    customDeckBaseId = 100,
    backs = {
        imperiumCardBack = "https://steamusercontent-a.akamaihd.net/ugc/2502404390141326342/C3DC7A02CF378129569B414967C9BE25097C6E77/",
        intrigueCardBack = "https://steamusercontent-a.akamaihd.net/ugc/2502404390141342007/D63B92C616541C84A7984026D757DB03E79532DD/",
        techCardBack = "https://steamusercontent-a.akamaihd.net/ugc/2502404390141363045/1EA614EC832B16BC94811A7FE793344057850409/",
        conflictCardBack = "https://steamusercontent-a.akamaihd.net/ugc/2502404390141365665/0423ECA84C0D71CCB38EBD60DEAE641EE72D7933/", -- a workaround
        conflict1CardBack = "https://steamusercontent-a.akamaihd.net/ugc/2502404390141365665/0423ECA84C0D71CCB38EBD60DEAE641EE72D7933/",
        conflict2CardBack = "https://steamusercontent-a.akamaihd.net/ugc/2502404390141365164/3B3F54DF65F76F0850D0EC683602524806A11E49/",
        conflict3CardBack = "https://steamusercontent-a.akamaihd.net/ugc/2502404390141365939/9E194557E37B5C4CA74C7A77CBFB6B8A36043916/",
        hagalCardBack = "https://steamusercontent-a.akamaihd.net/ugc/2502404390141333724/26E28590801800D852F4BCA53E959AAFAAFC8FF3/",
        leaderCardBack = "https://steamusercontent-a.akamaihd.net/ugc/2502404390141277039/005244DAC0A29EE68CFF741FC06564969563E8CF/",
        fanmadeLeaderCardBack = "https://steamusercontent-a.akamaihd.net/ugc/2502404390141366089/4C75C9A8CA6B890A6178B4B22B0F994B2F663D33/",
        arrakeenScoutsCardBack = "https://steamusercontent-a.akamaihd.net/ugc/2502404390141280256/DE94B7602EB41EEB68DE4907DF1369CBEF2ADD55/",
        navigationCardBack = "https://steamusercontent-a.akamaihd.net/ugc/11785911389932807807/DB25F5E9F1A59B4D113F8E5DA52C1100DEE53458/",
        sardaukarCommanderSkillCardBack = "https://steamusercontent-a.akamaihd.net/ugc/9769430335022447450/70DB33EE8471E049EBD158C6F60EC0482C2FAF08/",
    },
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
            missionariaProtectiva = 2, -- First release fixed in Rise of Ix
            spiceHunter = 2,
            spiceSmugglers = 2,
            fedaykinDeathCommando = 2,
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
            waterPeddler = 1,
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
        bloodlines = {
            bombast = 1,
            sandwalk = 2,
            disruptionTactics = 1,
            urgentShigawire = 2,
            commandCenter = 1,
            engineeredMiracle = 1,
            iBelieve = 1,
            litanyAgainstFear = 1,
            eliteForces = 1,
            fremenWarName = 1,
            sardaukarStandard = 1,
            quashRebellion = 2,
            southernFaith = 1,
            imperialThroneship = 1,
            possibleFutures = 1,
            ruthlessLeadership = 1,
            pivotalGambit = 1,
        },
        bloodlinesTech = {
            ixianAmbassador = 2,
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
            dispatchAnEnvoy = 2,
            infiltrate = 1,
            knowTheirWays = 1,
            masterTactician = 3,
            plansWithinPlans = 1,
            privateArmy = 2,
            doubleCross = 1,
            councilorsDispensation = 1,
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
            waterPeddlersUnion = 1,
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
        bloodlines = {
            adaptiveTactics = 1,
            desertSupport = 1,
            emperorInvitation = 1,
            honorGuard = 1,
            returnTheFavor = 1,
            sacredPools = 1,
            seizeProduction = 1,
            theStrongSurvive = 1,
            tenuousBound = 1,
            withdrawalAgreement = 1,
        },
        bloodlinesTech = {
            battlefieldResearch = 1,
            rapidEngineering = 1,
        },
        bloodlinesTwisted = {
            ambitious = 1,
            calculating = 1,
            controlled = 1,
            devious = 1,
            discerning = 1,
            insidious = 1,
            resourceful = 1,
            sadistic = 1,
            shrewd = 1,
            sinister = 1,
            unnatural = 1,
            withdrawn = 1,
        },
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
            }
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
        },
    },
    hagal = {
        base = {
            common = {
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
            common = {
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
            common = {},
            solo = {
                researchStation = 1,
                carthag = Helper.ERASE,
                carthag1 = 1,
                carthag2 = 1,
                carthag3 = 1,
            },
        },
        bloodlines = {
            common = {
                tuekSietch = 2,
            },
        },
        ixAmbassy = {
            solo = {
                acquireTech = 4,
            },
        },
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
        bloodlines = {
            trainingDepot = 1,
            geneLockedVault = 1,
            glowglobes = 1,
            planetaryArray = 1,
            servoReceivers = 1,
            deliveryBay = 1,
            plasteelBlades = 1,
            suspensorSuits = 1,
            rapidDropships = 1,
            selfDestroyingMessages = 1,
            navigationChamber = 1,
            sardaukarHighCommand = 1,
            forbiddenWeapons = 1,
            advancedDataAnalysis = 0,
            ornithopterFleet = 0,
            panopticon = 0,
            spyDrones = 0,
        },
        bloodlinesTech = {
            choamTransports = 0,
        }
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
        bloodlines = {
            chani = 1,
            duncanIdaho = 1,
            esmarTuek = 1,
            gaiusHelenMohiam = 0,
            hasimirFenring = 0,
            lietKynes = 0,
            piterDeVries = 1,
            yrkoon = 1,
            kotaOdax = 1,
        },
        fanmade = {
            arkhane = {
                base = {
                    arkhaneXavierHarkonnen = 1,
                    arkhaneFeydRauthaHarkonnen = 1,
                    arkhaneHasimirFenring = 1,
                    arkhaneMargotFenring = 1,
                    arkhaneLietKynes = 1,
                    arkhaneHwiNoree = 1,
                    arkhaneMetulli = 1,
                    arkhaneMilesTeg = 1,
                    arkhaneIrulanCorrino = 1,
                    arkhaneWencisiaCorrino = 1,
                    arkhaneVorianAtreides = 1,
                    arkhaneSerenaButler = 1,
                    arkhaneWhitmoreBluud = 1,
                    arkhaneExecutrixOrdos = 1,
                    arkhaneScytale = 1,
                    arkhaneStabanTuek = 1,
                    arkhaneEsmarTuek = 1,
                    arkhaneDrisk = 1,
                },
                ix = {
                    arkhaneAbulurdHarkonnen = 1,
                    arkhaneArkhane = 1,
                    arkhaneNormaCenvas = 1,
                },
                immortality = {
                    arkhaneTorgTheYoung = 1,
                    arkhaneTwylwythWaff = 1,
                },
            },
            retienne = {
                base = {
                    retienneHelenaRichese = 1,
                    retienneFarok = 1,
                    retienneIlbanRichese = 1,
                    retienneJopatiKolona = 1,
                    retienneLetoAtreidesII = 1,
                    retienneXavierHarkonnen = 1,
                    retienneCountFenring = 1,
                    retienneDrisq = 1,
                    retienneExecutrix = 1,
                    retienneDukeMutelli = 1,
                    retienneIsyanderTheTraitorShaiad = 1,
                    retienneSwormasterDinari = 1,
                    retienneAliaAtreides = 1,
                    retiennePrincessYunaMoritani = 1,
                    --retienneHoratioDelta = 1,
                    retienneTessiaVernius = 1,
                    retienneShaddamIV = 1,
                    retienneCaptainOtto = 1,
                    retiennePrincessWensicia = 1,
                    --retienneHoratioFive = 1,
                    retienneDrLietKynes = 1,
                    retienneBannerjee = 1,
                    retienneSerenaButler = 1,
                    retienneShaddamV = 1,
                    --retienneSionaAtreides = 1,
                    retienneEdric = 1,
                    retienneShimoon = 1,
                    retienneAnirulCorrino = 1,
                    retienneUliet = 1,
                    retiennePretresseIsyaraStShaiad = 1,
                    retienneMemnonThorvald = 1,
                    retienneSenatorOthn = 1,
                    retienneVorianAtreides = 1,
                    retienneWhitmoreBludd = 1,
                    --retienneAlmaMavisTaraza = 1,
                    retienneSenateurMaximilienZelevas = 1,
                    retienneStabanTuek = 1,
                    retienneDukeLetoAtreides = 1,
                    retienneHwiNoree = 1,
                    retienneDarwiOdrade = 1,
                    retienneRamalloTheSayyadina = 1,
                    retienneGlossuTheBeastRabban = 1,
                    --retienneDukeJenhaestraDrevMeos = 1,
                    retienneBaronVladimirHarkonnen = 1,
                    retiennePaulAtreides = 1,
                    retienneChatt = 1,
                    --retienneHoratioPrime = 1,
                    retienneAbulurdHarkonnen = 1,
                    retienneMilesTeg = 1,
                    retienneCapitainYelchinOrdara = 1,
                    retienneIlesaEcaz = 1,
                    retienneEsmarTuek = 1,
                    retienneCountessArianaThorvald = 1,
                    retienneAlbertoGinaztera = 1,
                    retienneFeydRautha = 1,
                    retienneLadyMargotFenring = 1,
                    retienneArchdukeArmandEcaz = 1,
                },
                ix = {
                    retienneAbulurdRabban = 1,
                    retienneGeneralKlevLagarin = 1,
                    retienneKoalTraytron = 1,
                    retienneNormaCenva = 1,
                    retienneOmniusPrime = 1,
                    retiennePrinceRhomburVernius = 1,
                    retienneTioHoltzman = 1,
                    retienneViscountHundroMoritani = 1,
                },
                immortality = {
                    retienneMasterWaff = 1,
                    retienneMirlat = 1,
                    retienneScytale = 1,
                    retienneTorgTheYoung = 1,
                    retienneTorgTheYounger = 1,
                    retienneTylwythWaff = 1,
                    retienneMasterBijaz = 1,
                    retiennePrincessIrulan = 1,
                },
            }
        }
    },
    arrakeenScouts = {
        committee = {
            --[[
            appropriations = 1,
            development = 1,
            information = 1,
            investigation = 1,
            joinForces = 1,
            politicalAffairs = 1,
            preparation = 1,
            relations = 1,
            supervision = 1,
            dataAnalysis = 1,
            developmentProject = 1,
            tleilaxuRelations = 1,
            ]]
        },
        auction = {
            mentat1 = 1,
            mentat2 = 1,
            mercenaries1 = 1,
            mercenaries2 = 1,
            treachery1 = 1,
            treachery2 = 1,
            toTheHighestBidder1 = 1,
            toTheHighestBidder2 = 1,
            competitiveStudy1 = 1,
            competitiveStudy2 = 1,
        },
        event = {
            changeOfPlans = 1,
            covertOperation = 1,
            covertOperationReward = 1,
            giftOfWater = 1,
            desertGift = 1,
            guildNegotiation = 1,
            intriguingGift = 1,
            testOfLoyalty = 1,
            beneGesseritTreachery = 1,
            emperorsTax = 1,
            fremenExchange = 1,
            politicalEquilibrium = 1,
            waterForSpiceSmugglers = 1,
            rotationgDoors = 1,
            secretsForSale = 1,
            noComingBack = 1,
            tapIntoSpiceReserves = 1,
            getBackInTheGoodGraces = 1,
            treachery = 1,
            newInnovations = 1,
            offWordOperation = 1,
            offWordOperationReward = 1,
            ceaseAndDesistRequest = 1,
        },
        mission = {
            secretsInTheDesert = 1,
            stationedSupport = 1,
            secretsInTheDesert_immortality = 1,
            stationedSupport_immortality = 1,
            geneticResearch = 1,
            guildManipulations = 1,
            spiceIncentive = 1,
            strongarmedAlliance = 1,
            saphoJuice = 1,
            spaceTravelDeal = 1,
            armedEscort = 1,
            secretStash = 1,
            stowaway = 1,
            backstageAgreement = 1,
            coordinationWithTheEmperor = 1,
            sponsoredResearch = 1,
            tleilaxuOffering = 1,
        },
        sale = {
            fremenMercenaries = 1,
            revealTheFuture = 1,
            sooSooSookWaterPeddlers = 1,
        }
    },
    navigation = {
        bloodlines = {
            solarisAndPermanentPersuasion = 1,
            spiceIfTrash = 1,
            waterThenSpiceIfSpacingGuildInfluence = 1,
            spiceOrInfluenceIfSolaris = 1,
            spiceOrTSMFIfWater = 1,
            spiceThenIntrigueIfAlliance = 1,
            influenceIfInfluence = 1,
            drawOrVpIfSpice = 1,
            troopOrMoreTroopIfSolaris = 1,
            spyOrIntrigueAndSpiceIfSpy = 0,
        }
    },
    sardaukarCommanderSkills = {
        bloodlines = {
            charismatic = 2,
            desperate = 2,
            fierce = 0,
            canny = 2,
            driven = 2,
            loyal = 2,
            hardy = 2,
        }
    },
}

function Deck.rebuildPreloadAreas()
    Locale.onLoad()
    local allSupports = {
        en = require("en.Deck"),
        fr = require("fr.Deck"),
    }

    Deck.prebuildZones = Helper.resolveGUIDs(true, {
        en = "cf9923",
        fr = "95b3db",
    })

    for _, prebuildZone in pairs(Deck.prebuildZones) do
        ---@cast prebuildZone Zone
        for _, object in ipairs(prebuildZone.getObjects()) do
            if object.type == "Deck" then
                object.destruct()
            end
        end
    end

    Helper.onceFramesPassed(1).doAfter(function ()
        for language, _ in pairs(allSupports) do
            I18N.setLocale(language)

            local support = allSupports[language]
            Deck.sources = support.loadCustomDecks(Deck)

            local areas = getObjectsWithTag("deckPreloadArea" .. language)
            assert(#areas == 1)
            local origin = areas[1].getPosition()

            local i = 0
            local getNextPosition = function ()
                local p = origin + Vector(math.floor(i / 9) * 4 - 2, 2, 4 * (i % 9) - 16)
                i = i + 1
                return p
            end

            Deck._prebuildStarterDeck(getNextPosition())
            Deck._prebuildImperiumDeck(getNextPosition())
            Deck._prebuildSpecialDeck(getNextPosition())
            Deck._prebuildTleilaxuDeck(getNextPosition())
            Deck._prebuildIntrigueDeck(getNextPosition())
            Deck._prebuildTechDeck(getNextPosition())
            Deck._prebuildConflictDeck(getNextPosition())
            Deck._prebuildHagalDeck(getNextPosition())
            Deck._prebuildLeaderDeck(getNextPosition())
            Deck._prebuildArrakeenScoutDeck(getNextPosition())
            Deck._prebuildNavigationDeck(getNextPosition())
            Deck._prebuildSardaukarCommanderSkillDeck(getNextPosition())
        end
    end)
end

function Deck.onLoad()
    Deck.prebuildZones = Helper.resolveGUIDs(true, {
        en = "cf9923",
        fr = "95b3db",
    })

    for _, prebuildZone in pairs(Deck.prebuildZones) do
        ---@cast prebuildZone Zone
        for _, object in ipairs(prebuildZone.getObjects()) do
            object.setInvisibleTo(Player.getColors())
        end
    end
end

---@param settings Settings
function Deck.setUp(settings)
    -- Not needed anymore since we are relying on prebuild decks now.
    -- (But deck sources are still needed in "rebuildPreloadAreas".)
    if false then
        local support

        if settings.language == "en" then
            support = require("en.Deck")
        elseif settings.language == "fr" then
            support = require("fr.Deck")
        else
            error("Unsupported language: " .. settings.language)
        end

        Deck.sources = support.loadCustomDecks(Deck)
    end
end

---@param name string
---@return string
function Deck.getAcquireCardDecalUrl(name)
    local decalUrl = Deck.decals[name .. "AcquireCard"]
    assert(decalUrl, name)
    return decalUrl
end

---@param deckZone Zone
---@param settings Settings
---@return Continuation
function Deck.generateStarterDeck(deckZone, settings)
    assert(deckZone)
    assert(deckZone.getPosition)
    local continuation = Helper.createContinuation("Deck.generateStarterDeck")
    local contributionSets = { Deck.starter.base }
    if settings.immortality then
        table.insert(contributionSets, Deck.starter.immortality)
    end
    local contributions = Deck._mergeContributionSets(contributionSets)
    if not settings.immortality and settings.epicMode then
        contributions["duneTheDesertPlanet"] = 1
        contributions["controlTheSpice"] = 1
    end
    Deck._generateDeck("Imperium", deckZone, contributions, Deck.sources.imperium).doAfter(continuation.run)
    return continuation
end

---@param deckZone Zone
---@param settings Settings
---@return Continuation
function Deck.generateStarterDiscard(deckZone, settings)
    assert(deckZone)
    assert(deckZone.getPosition)
    local continuation = Helper.createContinuation("Deck.generateStarterDiscard")
    if settings.immortality and settings.epicMode then
        Deck._generateDeck("Imperium", deckZone, Deck.starter.epic, Deck.sources.imperium).doAfter(function (deck)
            deck.flip()
            continuation.run(deck)
        end)
    else
        continuation.cancel()
    end
    return continuation
end

---@param deckZone Zone
---@param settings Settings
---@return Continuation
function Deck.generateImperiumDeck(deckZone, settings)
    assert(deckZone)
    assert(deckZone.getPosition)
    local continuation = Helper.createContinuation("Deck.generateImperiumDeck")
    local contributions = Deck._mergeStandardContributionSets(Deck.imperium, settings)
    if settings.ix or settings.ixAmbassy then
        contributions = Deck._mergeContributionSets({ contributions, Deck.imperium.bloodlinesTech })
    end
    Deck._generateDeck("Imperium", deckZone, contributions, Deck.sources.imperium).doAfter(continuation.run)
    return continuation
end

---@param deckZone Zone
---@param parent string
---@param name string
---@return Continuation
function Deck.generateSpecialDeck(deckZone, parent, name)
    assert(deckZone, name)
    assert(deckZone.getPosition)
    local continuation = Helper.createContinuation("Deck.generateSpecialDeck")
    assert(name)
    assert(Deck.special[parent][name], name)
    local contributions = { [name] = Deck.special[parent][name] }
    Deck._generateDeck("Imperium", deckZone, contributions, Deck.sources.special).doAfter(function (deck)
        deck.flip()
        Helper.onceMotionless(deck).doAfter(continuation.run)
    end)
    return continuation
end

---@param deckZone Zone
---@return Continuation
function Deck.generateTleilaxuDeck(deckZone)
    assert(deckZone)
    assert(deckZone.getPosition)
    local continuation = Helper.createContinuation("Deck.generateTleilaxuDeck")
    Deck._generateDeck("Imperium", deckZone, Deck.tleilaxu, Deck.sources.tleilaxu).doAfter(continuation.run)
    return continuation
end

---@param deckZone Zone
---@param settings Settings
---@return Continuation
function Deck.generateIntrigueDeck(deckZone, settings)
    assert(deckZone)
    assert(deckZone.getPosition)
    local continuation = Helper.createContinuation("Deck.generateIntrigueDeck")
    local contributions = Deck._mergeStandardContributionSets(Deck.intrigue, settings)
    Deck._generateDeck("Intrigue", deckZone, contributions, Deck.sources.intrigue).doAfter(continuation.run)
    return continuation
end

---@param deckZone Zone
---@return Continuation
function Deck.generateTwistedIntrigueDeck(deckZone)
    assert(deckZone)
    assert(deckZone.getPosition)
    local continuation = Helper.createContinuation("Deck.generateTwistedIntrigueDeck")
    Deck._generateDeck("Intrigue", deckZone, Deck.intrigue.bloodlinesTwisted, Deck.sources.intrigue).doAfter(continuation.run)
    return continuation
end

---@param deckZones Zone[]
---@param settings Settings
---@return Continuation
function Deck.generateTechDeck(deckZones, settings)
    assert(deckZones)
    assert(#deckZones == 3)
    local continuation = Helper.createContinuation("Deck.generateTechDeck")

    local keys = {}
    for _, category in ipairs({ 'ix', 'bloodlines' }) do
        if settings[category] then
            for key, card in pairs(Deck.tech[category]) do
                if card > 0 then
                    table.insert(keys, key)
                end
            end
        end
    end
    Helper.shuffle(keys)

    local decks = {}

    local remaining = 0
    local stackSize = math.ceil(#keys / 3)
    for i = 1, 3 do
        remaining = remaining + 1
        local contributions = {}
        for j = (i - 1) * stackSize + 1, math.min(#keys, i * stackSize) do
            contributions[keys[j]] = 1
        end
        local deckZone = deckZones[i]
        Deck._generateDeck("Tech", deckZone, contributions, Deck.sources.tech).doAfter(function (deck)
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

---@param deckZone Zone
---@param settings Settings
---@return Continuation
function Deck.generateConflictDeck(deckZone, settings)
    assert(deckZone)
    assert(deckZone.getPosition)
    local continuation = Helper.createContinuation("Deck.generateConflictDeck")

    local cardCounts = settings.epicMode and { 0, 5, 5 } or { 1, 5, 4 }

    local contributions = {}
    for level = 3, 1, -1 do
        local cardCount = cardCounts[level]
        if cardCount > 0 then
            local alteredSettings = Helper.shallowCopy(settings)
            alteredSettings.ix = alteredSettings.ix and level == 3
            local levelContributions = Deck._mergeStandardContributionSets(Deck.conflict["level" .. tostring(level)], alteredSettings)
            local cardNames = Helper.getKeys(levelContributions)
            assert(#cardNames >= cardCount, "Not enough level " .. tostring(level) .. " conflict cards!")
            Helper.shuffle(cardNames)
            for i = 1, cardCount do
                contributions[cardNames[i]] = 1
            end
        end
    end

    Deck._generateDeck("Conflict", deckZone, contributions, Deck.sources.conflict, 0.5).doAfter(continuation.run)

    return continuation
end

---@param deckZone Zone
---@param settings Settings
---@return Continuation
function Deck.generateHagalDeck(deckZone, settings)
    assert(deckZone)
    assert(deckZone.getPosition)
    assert(not settings.numberOfPlayers or settings.numberOfPlayers == 1 or settings.numberOfPlayers == 2)
    assert(not settings.ixAmbassy or settings.bloodlines)
    assert(not (settings.ix and settings.ixAmbassy))
    local continuation = Helper.createContinuation("Deck.generateHagalDeck")

    local contributionSetNames = { "base" }
    if settings.ix then
        table.insert(contributionSetNames, "ix")
    end
    if settings.immortality then
        table.insert(contributionSetNames, "immortality")
    end
    if settings.bloodlines then
        table.insert(contributionSetNames, "bloodlines")
    end
    if settings.ixAmbassy then
        table.insert(contributionSetNames, "ixAmbassy")
    end

    local contributionSets = {}
    for _, contributionSetName in ipairs(contributionSetNames) do
        local root = Deck.hagal[contributionSetName]
        table.insert(contributionSets, root.common or {})
        if not settings.numberOfPlayers or settings.numberOfPlayers == 1 then
            table.insert(contributionSets, root.solo or {})
        elseif not settings.numberOfPlayers or settings.numberOfPlayers == 2 then
            table.insert(contributionSets, root.twoPlayers or {})
        end
    end

    local contributions = Deck._mergeContributionSets(contributionSets)

    if settings.ix or not settings.ixAmbassy then
        contributions.acquireTech = nil
    end

    Deck._generateDeck("Hagal", deckZone, contributions, Deck.sources.hagal).doAfter(continuation.run)
    return continuation
end

---@param deckZone Zone
---@param settings Settings
---@return Continuation
function Deck.generateLeaderDeck(deckZone, settings)
    assert(deckZone)
    assert(deckZone.getPosition)
    local continuation = Helper.createContinuation("Deck.generateLeaderDeck")
    local contributions = Deck._mergeStandardContributionSets(Deck.leaders, settings)
    if settings.fanmadeLeaders then
        local locale = I18N.getLocale()
        if locale == 'fr' then
            contributions = Deck._mergeContributionSets({ contributions, Deck._mergeStandardContributionSets(Deck.leaders.fanmade.arkhane, settings) })
        elseif locale == 'en' then
            contributions = Deck._mergeStandardContributionSets(Deck.leaders.fanmade.retienne, settings)
        end
    end
    if not settings.ix and not settings.ixAmbassy then
        contributions.kotaOdax = nil
    end
    Deck._generateDeck("Leader", deckZone, contributions, Deck.sources.leaders).doAfter(continuation.run)
    return continuation
end

---@param deckZone Zone
---@return Continuation
function Deck.generateArrakeenScoutsDeck(deckZone)
    assert(deckZone)
    assert(deckZone.getPosition)
    local continuation = Helper.createContinuation("Deck.generateArrakeenScoutsDeck")
    local contributionSets = {
        Deck.arrakeenScouts.auction,
        Deck.arrakeenScouts.event,
        Deck.arrakeenScouts.mission,
        Deck.arrakeenScouts.sale,
    }
    local contributions = Deck._mergeContributionSets(contributionSets, true)
    Deck._generateDeck("ArrakeenScouts", deckZone, contributions, Deck.sources.arrakeenScouts).doAfter(continuation.run)
    return continuation
end

---@param deckZone Zone
---@param settings Settings
---@return Continuation
function Deck.generateNavigationDeck(deckZone, settings)
    assert(deckZone)
    assert(deckZone.getPosition)
    local continuation = Helper.createContinuation("Deck.generateNavigationDeck")
    local contributions = Deck._mergeStandardContributionSets(Deck.navigation, settings)
    Deck._generateDeck("Navigation", deckZone, contributions, Deck.sources.navigation).doAfter(continuation.run)
    return continuation
end

---@param deckZone Zone
---@param settings Settings
---@return Continuation
function Deck.generateSardaukarCommanderSkillDeck(deckZone, settings)
    assert(deckZone)
    assert(deckZone.getPosition)
    local continuation = Helper.createContinuation("Deck.generateSardaukarCommanderSkillDeck")
    local contributions = Deck._mergeStandardContributionSets(Deck.sardaukarCommanderSkills, settings)
    Deck._generateDeck("SardaukarCommanderSkill", deckZone, contributions, Deck.sources.sardaukarCommanderSkills).doAfter(continuation.run)
    return continuation
end

---@param root Tree<integer|string>
---@param settings Settings
---@return table<string, integer>
function Deck._mergeStandardContributionSets(root, settings)
    local contributionSets = { root.base }
    if settings.ix then
        table.insert(contributionSets, root.ix)
    end
    if settings.immortality then
        table.insert(contributionSets, root.immortality)
    end
    if settings.bloodlines then
        table.insert(contributionSets, root.bloodlines)
    end
    return Deck._mergeContributionSets(contributionSets)
end

---@param contributionSets table<string, table<string, integer>>
---@param ignoreErasure? boolean
---@return table<string, integer>
function Deck._mergeContributionSets(contributionSets, ignoreErasure)
    local contributions = {}
    for _, contributionSet in ipairs(contributionSets) do
        for name, arity in pairs(contributionSet) do
            local currentArity
            if arity == Helper.ERASE then
                if ignoreErasure then
                    currentArity = contributions[name]
                else
                    currentArity = nil
                end
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
--- Helper.ERASE allows to skip intermediate cards.
---@param cards table<string, { customDeck: table, luaIndex: integer }> any The set where to add the named cards.
---@param customDeck table A custom deck (API struct) as returned by Deck.createImperiumCustomDeck.
---@param startLuaIndex integer The Lua start index for the card names.
---@param cardNames string[] A list of card names matching those in the custon deck.
function Deck.loadCustomDeck(cards, customDeck, startLuaIndex, cardNames)
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

---@param customDeck table
---@param customDeckId integer
---@param cardId string
---@return table
function Deck._generateCardData(customDeck, customDeckId, cardId)
    assert(customDeck, "customDeck")
    assert(customDeckId, "customDeckId")
    assert(cardId, "cardId")

    assert(customDeck.__scale)

    Deck.nextGuid = (Deck.nextGuid or 665) + 1
    local guid = string.format("%06x", Deck.nextGuid)

    local data = {
        GUID = guid,
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

---@param deckType string
---@param deckZone Zone
---@param contributions table<string, integer>
---@param sources table<string, table>
---@param spacing? integer
---@return Continuation
function Deck._generateDeck(deckType, deckZone, contributions, sources, spacing)
    assert(deckZone.getPosition)
    return Deck._generateFromPrebuildDeck(deckType, deckZone, contributions, sources, spacing)
end

--- Add 2 back cards such as to always have a deck to take cards from.
---@param deckType string
---@param position Vector
---@param contributions table<string, integer>
---@param sources table<string, table>
---@return Continuation
function Deck._generateDynamicDeckWithTwoBackCards(deckType, position, contributions, sources)
    local contributions2 = Helper.shallowCopy(contributions)
    contributions2.back = 2
    local sources2 = Helper.shallowCopy(sources)
    local backUrl = Deck.backs[Helper.concatAsCamelCase(deckType, "CardBack")]
    assert(backUrl, deckType)
    local creator = Deck[Helper.concatAsCamelCase("create", deckType, "CustomDeck")]
    assert(creator, deckType)
    sources2.back = {
        customDeck = creator(backUrl, 1, 1),
        luaIndex = 1
    }
    return Deck._generateDynamicDeck(deckType, position, contributions2, sources2)
end

---@param deckType string
---@param position Vector
---@param contributions table<string, table>
---@param sources table<string, table>
---@return Continuation
function Deck._generateDynamicDeck(deckType, position, contributions, sources)
    assert(deckType)
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
        GMNotes = deckType,
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
        Tags = { deckType },
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
        if cardinality > 0 then
            local source = sources[name]
            if source then
                assert(source.customDeck, name)
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
                    cardData.Tags = { deckType }
                    cardData.Nickname = I18N(name)
                    cardData.GMNotes = name
                    table.insert(data.ContainedObjects, cardData)
                end
            else
                error("No source for card '" .. name .. "'")
            end
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

    return continuation
end

---@return integer
function Deck._nextCustomDeckId()
    Deck.customDeckBaseId = Deck.customDeckBaseId + 1
    return Deck.customDeckBaseId
end

---@param deckPosition Vector
function Deck._prebuildStarterDeck(deckPosition)
    local contributionSets = {
        Deck.starter.base,
        Deck.starter.epic,
        Deck.starter.immortality,
    }
    local contributions = Deck._mergeContributionSets(contributionSets, true)
    contributions = Helper.map(contributions, function (_, cardinality)
        return cardinality * 4
    end)
    Deck._generateDynamicDeckWithTwoBackCards("Imperium", deckPosition, contributions, Deck.sources.imperium)
end

---@param deckPosition Vector
function Deck._prebuildEmperorStarterDeck(deckPosition)
    Deck._generateDynamicDeckWithTwoBackCards("Imperium", deckPosition, Deck.starter.emperor, Deck.sources.imperium)
end

---@param deckPosition Vector
function Deck._prebuildMuadDibStarterDeck(deckPosition)
    Deck._generateDynamicDeckWithTwoBackCards("Imperium", deckPosition, Deck.starter.muadDib, Deck.sources.imperium)
end

---@param deckPosition Vector
function Deck._prebuildImperiumDeck(deckPosition)
    local contributionSets = {
        Deck.imperium.base,
        Deck.imperium.ix,
        Deck.imperium.immortality,
        Deck.imperium.bloodlines,
        Deck.imperium.bloodlinesTech,
    }
    local contributions = Deck._mergeContributionSets(contributionSets, true)
    Deck._generateDynamicDeckWithTwoBackCards("Imperium", deckPosition, contributions, Deck.sources.imperium)
end

---@param deckPosition Vector
function Deck._prebuildSpecialDeck(deckPosition)
    local contributionSets = {
        Deck.special.base,
        Deck.special.immortality,
    }
    local contributions = Deck._mergeContributionSets(contributionSets, true)
    Deck._generateDynamicDeckWithTwoBackCards("Imperium", deckPosition, contributions, Deck.sources.special)
end

---@param deckPosition Vector
function Deck._prebuildTleilaxuDeck(deckPosition)
    Deck._generateDynamicDeckWithTwoBackCards("Imperium", deckPosition, Deck.tleilaxu, Deck.sources.tleilaxu)
end

---@param deckPosition Vector
function Deck._prebuildIntrigueDeck(deckPosition)
    local contributionSets = {
        Deck.intrigue.base,
        Deck.intrigue.ix,
        Deck.intrigue.immortality,
        Deck.intrigue.bloodlines,
        Deck.intrigue.bloodlinesTech,
        Deck.intrigue.bloodlinesTwisted,
    }
    local contributions = Deck._mergeContributionSets(contributionSets, true)
    Deck._generateDynamicDeckWithTwoBackCards("Intrigue", deckPosition, contributions, Deck.sources.intrigue)
end

---@param deckPosition Vector
function Deck._prebuildTechDeck(deckPosition)
    local contributionSets = {
        Deck.tech.ix,
        Deck.tech.bloodlines,
        Deck.tech.bloodlinesTech,
    }
    local contributions = Deck._mergeContributionSets(contributionSets, true)
    Deck._generateDynamicDeckWithTwoBackCards("Tech", deckPosition, contributions, Deck.sources.tech)
end

---@param deckPosition Vector
function Deck._prebuildConflictDeck(deckPosition)
    local contributionSets = {}
    for i = 1, 3 do
        for _, extension in ipairs({ "base", "ix", "immortality", "bloodlines" }) do
            local level = "level" .. tostring(i)
            local contributionSet = Deck.conflict[level][extension]
            if contributionSet then
                table.insert(contributionSets, contributionSet)
            end
        end
    end
    local contributions = Deck._mergeContributionSets(contributionSets, true)
    Deck._generateDynamicDeckWithTwoBackCards("Conflict", deckPosition, contributions, Deck.sources.conflict)
end

---@param deckPosition Vector
function Deck._prebuildHagalDeck(deckPosition)
    local contributionSets = {}
    for _, extension in ipairs({ "base", "ix", "immortality", "bloodlines", "ixAmbassy" }) do
        for _, players in ipairs({ "common", "solo", "twoPlayers" }) do
            table.insert(contributionSets, Deck.hagal[extension][players] or {})
        end
    end
    local contributions = Deck._mergeContributionSets(contributionSets, true)
    Deck._generateDynamicDeckWithTwoBackCards("Hagal", deckPosition, contributions, Deck.sources.hagal)
end

---@param deckPosition Vector
function Deck._prebuildLeaderDeck(deckPosition)
    local contributionSets = {
        Deck.leaders.base,
        Deck.leaders.ix,
        Deck.leaders.bloodlines,
        Deck.leaders.bloodlinesTech,
    }

    local locale = I18N.getLocale()
    for _, extension in ipairs({ "base", "ix", "immortality" }) do
        if locale == 'fr' then
            table.insert(contributionSets, Deck.leaders.fanmade.arkhane[extension] or {})
        elseif locale == 'en' then
            table.insert(contributionSets, Deck.leaders.fanmade.retienne[extension] or {})
        end
    end

    local contributions = Deck._mergeContributionSets(contributionSets, true)

    Deck._generateDynamicDeckWithTwoBackCards("Leader", deckPosition, contributions, Deck.sources.leaders)
end

---@param deckPosition Vector
function Deck._prebuildArrakeenScoutDeck(deckPosition)
    local contributionSets = {
        Deck.arrakeenScouts.auction,
        Deck.arrakeenScouts.event,
        Deck.arrakeenScouts.mission,
        Deck.arrakeenScouts.sale,
    }
    local contributions = Deck._mergeContributionSets(contributionSets, true)
    Deck._generateDynamicDeckWithTwoBackCards("ArrakeenScouts", deckPosition, contributions, Deck.sources.arrakeenScouts)
end

---@param deckPosition Vector
function Deck._prebuildNavigationDeck(deckPosition)
    local contributionSets = {
        Deck.navigation.bloodlines,
    }
    local contributions = Deck._mergeContributionSets(contributionSets, true)
    Deck._generateDynamicDeckWithTwoBackCards("Navigation", deckPosition, contributions, Deck.sources.navigation)
end

---@param deckPosition Vector
function Deck._prebuildSardaukarCommanderSkillDeck(deckPosition)
    local contributionSets = {
        Deck.sardaukarCommanderSkills.bloodlines,
    }
    local contributions = Deck._mergeContributionSets(contributionSets, true)
    Deck._generateDynamicDeckWithTwoBackCards("SardaukarCommanderSkill", deckPosition, contributions, Deck.sources.sardaukarCommanderSkills)
end

---@param deckType string
---@param deckZone Zone
---@param contributions table<string, integer>
---@param _ unknown
---@param spacing? number
---@return Continuation
function Deck._generateFromPrebuildDeck(deckType, deckZone, contributions, _, spacing)
    assert(deckType)
    assert(deckZone)
    assert(#deckZone.getTags() == 0 or deckZone.hasTag(deckType),
        -- Curiously, the problem doesn't exist for dynamic decks.
        "Trying to generate a static deck in an incompatibly tagged zone will trigger the dreaded 'Unknown Error'.")
    assert(contributions)
    assert(#Helper.getKeys(contributions) > 0)

    local continuation = Helper.createContinuation("Deck._prebuildDeck")

    local sources = {}

    local prebuildZone = Deck.prebuildZones[I18N.getLocale()]
    ---@cast prebuildZone Zone
    Helper.withAllDecks(prebuildZone, function (deck)
        if Helper.getID(deck) == deckType then
            --Helper.dump(Helper.getID(deck), "==", deckType)
            for i, card in ipairs(deck.getObjects()) do
                local id = Helper.getID(card)
                --Helper.dump(i, "-", id)
                if sources[id] then
                    table.insert(sources[id].instances, card.guid)
                else
                    sources[id] = {
                        deck = deck,
                        instances = { card.guid }
                    }
                end
            end
        end
    end)

    local cardCount = 0
    for name, cardinality in pairs(contributions) do
        if cardinality > 0 then
            local source = sources[name]
            assert(source, "No source for card '" .. deckType .. "." .. name .. "'")
            for i = 1, math.ceil(cardinality) do
                local firstGuid = source.instances[1]
                assert(firstGuid, "Not enough instances of the card '" .. name .. "'")
                table.remove(source.instances, 1)
                assert(source.deck, "Should not happen! Source deck is not properly generated.")
                source.deck.takeObject({
                    guid = firstGuid,
                    -- Stacking is needed to preserve input order (but when it is needed?).
                    position = deckZone.getPosition() + Vector(0, 1 + cardCount * (spacing or 0.1), 0),
                    smooth = false,
                    callback_function = function (card)
                        if cardinality - i < 0 then
                            card.setTags(Helper.concatTables(card.getTags(), { "Unselected" }))
                        end
                    end
                })
                cardCount = cardCount + 1
            end
        end
    end
    assert(cardCount > 0)

    Wait.condition(function ()
        local deckOrCard = Helper.getDeckOrCard(deckZone)
        continuation.run(deckOrCard)
    end, function ()
        local deckOrCard = Helper.getDeckOrCard(deckZone)
        return deckOrCard ~= nil
            and not deckOrCard.spawning
            and Helper.getCardCount(deckOrCard) >= cardCount
    end)

    return continuation
end

---@param faceUrl string
---@param width number
---@param height number
---@return table
function Deck.createImperiumCustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(Deck.backs.imperiumCardBack, faceUrl, width, height, Vector(1.05, 1, 1.05))
end

---@param faceUrl string
---@param width number
---@param height number
---@return table
function Deck.createIntrigueCustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(Deck.backs.intrigueCardBack, faceUrl, width, height, Vector(1, 1, 1))
end

---@param faceUrl string
---@param width number
---@param height number
---@return table
function Deck.createTechCustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(Deck.backs.techCardBack, faceUrl, width, height, Vector(0.55, 1, 0.55))
end

---@param faceUrl string
---@param width number
---@param height number
---@return table
function Deck.createConflictCustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(Deck.backs.conflictCardBack, faceUrl, width, height, Vector(1, 1, 1))
end

---@param faceUrl string
---@param width number
---@param height number
---@return table
function Deck.createConflict1CustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(Deck.backs.conflict1CardBack, faceUrl, width, height, Vector(1, 1, 1))
end

---@param faceUrl string
---@param width number
---@param height number
---@return table
function Deck.createConflict2CustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(Deck.backs.conflict2CardBack, faceUrl, width, height, Vector(1, 1, 1))
end

---@param faceUrl string
---@param width number
---@param height number
---@return table
function Deck.createConflict3CustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(Deck.backs.conflict3CardBack, faceUrl, width, height, Vector(1, 1, 1))
end

---@param faceUrl string
---@param width number
---@param height number
---@return table
function Deck.createHagalCustomDeck(faceUrl, width, height, scale)
    return Deck.createCustomDeck(Deck.backs.hagalCardBack, faceUrl, width, height, scale or Vector(0.83, 1, 0.83))
end

---@param faceUrl string
---@param width number
---@param height number
---@return table
function Deck.createLeaderCustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(Deck.backs.leaderCardBack, faceUrl, width, height, Vector(1.12, 1, 1.12))
end

---@param faceUrl string
---@param width number
---@param height number
---@return table
function Deck.createFanmadeLeaderCustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(Deck.backs.fanmadeLeaderCardBack, faceUrl, width, height, Vector(1.12, 1, 1.12))
end

---@param faceUrl string
---@param width number
---@param height number
---@return table
function Deck.createArrakeenScoutsCustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(Deck.backs.arrakeenScoutsCardBack, faceUrl, width, height, Vector(0.5, 1, 0.5))
end

---@param faceUrl string
---@param width number
---@param height number
---@return table
function Deck.createNavigationCustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(Deck.backs.navigationCardBack, faceUrl, width, height, Vector(1.0, 1, 1.0))
end

---@param faceUrl string
---@param width number
---@param height number
---@return table
function Deck.createSardaukarCommanderSkillCustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(Deck.backs.sardaukarCommanderSkillCardBack, faceUrl, width, height, Vector(0.57, 1, 0.57))
end

---@param faceUrl string
---@param width number
---@param height number
---@return table
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

---@param category string
---@param name string
---@return string
function Deck.getCardUrlByName(category, name)
    local allSupports = {
        en = require("en.Deck"),
        fr = require("fr.Deck"),
    }
    local support = allSupports[I18N.getLocale()]
    Deck.sources = support.loadCustomDecks(Deck)
    local deck = Deck.sources[category]
    return deck[name].customDeck.FaceURL
end

return Deck
