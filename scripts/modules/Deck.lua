local Module = require("utils.Module")
local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

local Locale = Module.lazyRequire("Locale")

-- Merakon's House Blend -> https://boardgamegeek.com/thread/3213458/merakons-house-blend
local Deck = {
    decals = {
        corrinoAcquireCard = "https://steamusercontent-a.akamaihd.net/ugc/2286203878409177043/9E9986D0F348F5D23A16745A271FFD28958651FB/",
        genericAcquireCard = "https://steamusercontent-a.akamaihd.net/ugc/2286203878409243895/5F7C572489E5E03F3230B012DA0E01A84EDAABF8/",
    },
    customDeckBaseId = 100,
    backs = {
        imperiumCardBack = "https://steamusercontent-a.akamaihd.net/ugc/2093667512238502565/C3DC7A02CF378129569B414967C9BE25097C6E77/",
        intrigueCardBack = "https://steamusercontent-a.akamaihd.net/ugc/2093667512238521846/D63B92C616541C84A7984026D757DB03E79532DD/",
        techCardBack = "https://steamusercontent-a.akamaihd.net/ugc/2093667512238531825/1EA614EC832B16BC94811A7FE793344057850409/",
        conflictCardBack = "https://steamusercontent-a.akamaihd.net/ugc/2093667512238537179/0423ECA84C0D71CCB38EBD60DEAE641EE72D7933/", -- a workaround
        conflict1CardBack = "https://steamusercontent-a.akamaihd.net/ugc/2093667512238537179/0423ECA84C0D71CCB38EBD60DEAE641EE72D7933/",
        conflict2CardBack = "https://steamusercontent-a.akamaihd.net/ugc/2093667512238537448/3B3F54DF65F76F0850D0EC683602524806A11E49/",
        conflict3CardBack = "https://steamusercontent-a.akamaihd.net/ugc/2093667512238537046/9E194557E37B5C4CA74C7A77CBFB6B8A36043916/",
        objectiveCardBack = "https://steamusercontent-a.akamaihd.net/ugc/2488878371133398865/02A61DC439DF213EA61A8CCEC1F545F4D369F2E8/",
        hagalCardBack = "https://steamusercontent-a.akamaihd.net/ugc/2093668799785646965/26E28590801800D852F4BCA53E959AAFAAFC8FF3/",
        leaderCardBack = "https://steamusercontent-a.akamaihd.net/ugc/2093668799785645356/005244DAC0A29EE68CFF741FC06564969563E8CF/",
        rivalLeaderCardBack = "https://steamusercontent-a.akamaihd.net/ugc/2291837013341174770/EB5ECE9F5373F0B132E93CD5825B89E7F023E9A2/",
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
        legacy = {
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
        merakon = {
            -- Remove one copy of the following cards from the Uprising Imperium deck
            -- (Uprising comes with 2 each of these cards, so there's still 1 copy left after the removals):
            weirdingWoman = -1,
            desertSurvival = -1,
            makerKeeper = -1,
            beneGesseritOperative = -1,
            maulaPistol = -1,
            treadInDarkness = -1,
            -- Add the following cards:
            -- Legacy
            assassinationMission = 1,
            sardaukarInfantry = 1,
            missionariaProtectiva = 1,
            guildAdministrator = 1,
            imperialSpy = 1,
            spiceHunter = 1,
            spiceSmugglers = 1,
            theVoice = 1,
            beneGesseritSister = 1,
            crysknife = 1,
            fedaykinDeathCommando = 1,
            guildBankers = 1,
            spaceTravel = 1,
            otherMemory = 1,
            sietchReverendMother = 1,
            gunThopter = 1,
            powerPlay = 1,
            thufirHawat = 1,
            reverendMotherMohiam = 1,
            -- Ix
            waterPeddler = 1,
            truthsayer = 1,
            weirdingWay = 1,
            fremenCamp = 1,
            imperialBashar = 1,
            negotiatedWithdrawal = 1,
            spiceTrader = 1,
            esmarTuek = 1,
            satelliteBan = 1,
            treachery = 1,
            shaiHulud = 1,
            -- 93 Imperium cards total (69-6+30) (No counting promo cards I guess?)
        },
    },
    special = {
        legacy = {
            foldspace = 6,
        },
        immortality = {
            reclaimedForces = 1,
        },
        uprising = {
            prepareTheWay = 8,
            theSpiceMustFlow = 10,
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
        legacy = {
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
        },
        merakon = {
            -- No cuts from Uprising.
            -- Add the following cards (all from DI):
            alliedArmada = 1,
            binduSuspension = 1,
            bypassProtocol = 1,
            councilorsDispensation = 1,
            demandRespect = 1,
            dispatchAnEnvoy = 1,
            masterTactician = 1,
            plansWithinPlans = 1,
            poisonSnooper = 1,
            reinforcements = 1,
            stagedIncident = 1,
            tiebreaker = 1,
            -- 56 Intrigue cards total (44+12)
        },
    },
    conflict = {
        level1 = {
            uprising = {
                skirmishA = 1,
                skirmishB = 1,
                skirmishC = 1,
            },
        },
        level2 = {
            uprising = {
                choamSecurity = 1,
                spiceFreighters = 1,
                siegeOfArrakeen = 1,
                seizeSpiceRefinery = 1,
                testOfLoyalty = 1,
                shadowContest = 1,
                secureImperialBasin = 1,
                protectTheSietches = 1,
                tradeDispute = 1,
            },
        },
        level3 = {
            ix = {
                economicSupremacy = 1,
            },
            uprising = {
                propaganda = 1,
                battleForImperialBasin = 1,
                battleForArrakeen = 1,
                battleForSpiceRefinery = 1,
            }
        },
    },
    hagal = {
        base = {
            common = {
                --churn = 2,
                placeSpyYellow = 1,
                placeSpyBlue = 1,
                placeSpyGreen = 1,
                sardaukar = 2,
                dutifulService = 1,
                heighliner = 1,
                deliverSuppliesAndHeighliner = 2,
                espionage = 2,
                secrets = 1,
                desertTactics = 2,
                fremkit = 2,
                assemblyHall = 1,
                gatherSupport1 = 1, -- 1 troop
                gatherSupport2 = 1, -- 2 infl
                acceptContractAndShipping1 = 1,
                acceptContractAndShipping2 = 1, -- 3 infl
                researchStation = 2,
                spiceRefinery= 3,
                arrakeen = 2,
                sietchTabr = 3,
                haggaBasinAndImperialBasin = 4,
                deepDesert = 2,
            },
            solo = {},
            twoPlayers = {
                reshuffle = 1,
            }
        },
        ix = {
            common = {
                assemblyHall = Helper.ERASE,
                gatherSupport1 = Helper.ERASE,
                gatherSupport2 = Helper.ERASE,
                acceptContractAndShipping1 = Helper.ERASE,
                acceptContractAndShipping2 = Helper.ERASE,
                interstellarShipping = 1,
                deliverSuppliesAndInterstellarShipping = 1, -- ex foldspaceAndInterstellarShipping
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
                researchStationImmortality = 1,
                carthag = Helper.ERASE,
                tleilaxuBonus1 = 1, -- ex Carthag
                tleilaxuBonus2 = 1, -- ex Carthag
                tleilaxuBonus3 = 1, -- ex Carthag
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
        legacy = {
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
            jessica = 1,
            feydRauthaHarkonnen = 1,
            shaddamCorrino = 1,
            muadDib = 1,
        },
        merakon = {
            -- Legacy
            vladimirHarkonnen = 1,
            glossuRabban = 1,
            ilbanRichese = 1,
            arianaThorvald = 1,
            memnonThorvald = 1,
            armandEcaz = 1,
            ilesaEcaz = 1,
            -- Ix
            tessiaVernius = 1,
            yunaMoritani = 1,
        },
    },
    rivalLeaders = {
        uprising = {
            vladimirHarkonnen = 1,
            glossuRabban = 1,
            stabanTuek = 1,
            amberMetulli = 1,
            gurneyHalleck = 1,
            margotFenring = 1,
            irulanCorrino = 1,
            jessica = 1,
            feydRauthaHarkonnen = 1,
            muadDib = 1,
        },
    },
}

---
function Deck.rebuildPreloadAreas()
    Locale.onLoad()
    local allSupports = {
        en = require("en.Deck"),
        fr = require("fr.Deck"),
    }

    Deck.prebuildZones = Helper.resolveGUIDs(true, {
        en = "a5a2e6",
        fr = "db4507",
    })

    for _, prebuildZone in pairs(Deck.prebuildZones) do
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
            Deck._prebuildEmperorStarterDeck(getNextPosition())
            Deck._prebuildMuadDibStarterDeck(getNextPosition())
            Deck._prebuildImperiumDeck(getNextPosition())
            Deck._prebuildSpecialDeck(getNextPosition())
            Deck._prebuildTleilaxuDeck(getNextPosition())
            Deck._prebuildIntrigueDeck(getNextPosition())
            Deck._prebuildObjectiveDeck(getNextPosition())
            Deck._prebuildTechDeck(getNextPosition())
            Deck._prebuildConflictDeck(getNextPosition())
            Deck._prebuildHagalDeck(getNextPosition())
            Deck._prebuildLeaderDeck(getNextPosition())
            Deck._prebuildRivalLeaderDeck(getNextPosition())
        end
    end)
end

---
function Deck.onLoad()
    Deck.prebuildZones = Helper.resolveGUIDs(true, {
        en = "a5a2e6",
        fr = "db4507",
    })

    for _, prebuildZone in pairs(Deck.prebuildZones) do
        for _, object in ipairs(prebuildZone.getObjects()) do
            object.setInvisibleTo(Player.getColors())
        end
    end
end

---
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

function Deck.getAcquireCardDecalUrl(name)
    local decalUrl = Deck.decals[name .. "AcquireCard"]
    assert(decalUrl, name)
    return decalUrl
end

---
function Deck.generateObjectiveDeck(deckZone, cardNames)
    assert(deckZone)
    assert(deckZone.getPosition)
    local continuation = Helper.createContinuation("Deck.generateObjectiveDeck")
    Deck._generateDeck("Objective", deckZone, cardNames, Deck.sources.objective, 0.5).doAfter(continuation.run)
    return continuation
end

---
function Deck.generateStarterDeck(deckZone, immortality, epic)
    assert(deckZone)
    assert(deckZone.getPosition)
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
    Deck._generateDeck("Imperium", deckZone, contributions, Deck.sources.imperium).doAfter(continuation.run)
    return continuation
end

---
function Deck.generateEmperorStarterDeck(deckZone)
    assert(deckZone)
    assert(deckZone.getPosition)
    local continuation = Helper.createContinuation("Deck.generateEmperorStarterDeck")
    local contributionSets = { Deck.starter.emperor }
    local contributions = Deck._mergeContributionSets(contributionSets)
    Deck._generateDeck("Imperium", deckZone, contributions, Deck.sources.imperium).doAfter(continuation.run)
    return continuation
end

---
function Deck.generateMuadDibStarterDeck(deckZone)
    assert(deckZone)
    assert(deckZone.getPosition)
    local continuation = Helper.createContinuation("Deck.generateMuadDibStarterDeck")
    local contributionSets = { Deck.starter.muadDib }
    local contributions = Deck._mergeContributionSets(contributionSets)
    Deck._generateDeck("Imperium", deckZone, contributions, Deck.sources.imperium).doAfter(continuation.run)
    return continuation
end

---
function Deck.generateStarterDiscard(deckZone, immortality, epic)
    assert(deckZone)
    assert(deckZone.getPosition)
    local continuation = Helper.createContinuation("Deck.generateStarterDiscard")
    if immortality and epic then
        Deck._generateDeck("Imperium", deckZone, Deck.starter.epic, Deck.sources.imperium).doAfter(function (deck)
            deck.flip()
            continuation.run(deck)
        end)
    else
        continuation.cancel()
    end
    return continuation
end

---
function Deck.generateImperiumDeck(deckZone, contracts, ix, immortality, legacy, merakon)
    assert(deckZone)
    assert(deckZone.getPosition)
    local continuation = Helper.createContinuation("Deck.generateImperiumDeck")
    local contributions = Deck._mergeStandardContributionSets(Deck.imperium, ix, immortality, legacy, merakon)
    if contracts then
        contributions = Deck._mergeContributionSets({ contributions, Deck.imperium.uprisingContract })
    end
    Deck._generateDeck("Imperium", deckZone, contributions, Deck.sources.imperium).doAfter(continuation.run)
    return continuation
end

---
function Deck.generateSpecialDeck(deckZone, parent, name)
    assert(deckZone, name)
    assert(deckZone.getPosition)
    local continuation = Helper.createContinuation("Deck.generateSpecialDeck")
    assert(name)
    assert(Deck.special[parent][name], name)
    local contributions = { [name] = Deck.special[parent][name] }
    Deck._generateDeck("Imperium", deckZone, contributions, Deck.sources.special).doAfter(function (deck)
        deck.flip()
        continuation.run(deck)
    end)
    return continuation
end

---
function Deck.generateTleilaxuDeck(deckZone)
    assert(deckZone)
    assert(deckZone.getPosition)
    local continuation = Helper.createContinuation("Deck.generateTleilaxuDeck")
    Deck._generateDeck("Imperium", deckZone, Deck.tleilaxu, Deck.sources.tleilaxu).doAfter(continuation.run)
    return continuation
end

---
function Deck.generateIntrigueDeck(deckZone, contracts, ix, immortality, legacy, merakon)
    assert(deckZone)
    assert(deckZone.getPosition)
    local continuation = Helper.createContinuation("Deck.generateIntrigueDeck")
    local contributions = Deck._mergeStandardContributionSets(Deck.intrigue, ix, immortality, legacy, merakon)
    if contracts then
        contributions = Deck._mergeContributionSets({ contributions, Deck.intrigue.uprisingContract })
    end
    Deck._generateDeck("Intrigue", deckZone, contributions, Deck.sources.intrigue).doAfter(continuation.run)
    return continuation
end

---
function Deck.generateTechDeck(deckZones)
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
        local zone = deckZones[i]
        Deck._generateDeck("Tech", zone, part, Deck.sources.tech).doAfter(function (deck)
            local above = zone.getPosition() + Vector(0, 1, 0)
            Helper.moveCardFromZone(zone, above, nil, true, true)
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
function Deck.generateConflictDeck(deckZone, ix, epic, playerCount)
    assert(deckZone)
    assert(deckZone.getPosition)
    local continuation = Helper.createContinuation("Deck.generateConflictDeck")

    local cardCounts
    if playerCount == 6 then
        cardCounts = { 0, 5, 4 }
    elseif epic then
        cardCounts = { 0, 5, 5 }
    else
        cardCounts = { 1, 5, 4 }
    end

    local contributions = {}
    for level = 3, 1, -1 do
        local cardCount = cardCounts[level]
        if cardCount > 0 then
            local levelContributions = Deck._mergeStandardContributionSets(Deck.conflict["level" .. tostring(level)], ix and level == 3, false)
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

---
function Deck.generateHagalDeck(deckZone, ix, immortality, playerCount)
    assert(deckZone)
    assert(deckZone.getPosition)
    assert(not playerCount or playerCount == 1 or playerCount == 2)
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
        table.insert(contributionSets, root.common)
        if not playerCount or playerCount == 1 then
            table.insert(contributionSets, root.solo)
        elseif not playerCount or playerCount == 2 then
            table.insert(contributionSets, root.twoPlayers)
        end
    end

    local contributions = Deck._mergeContributionSets(contributionSets)
    Deck._generateDeck("Hagal", deckZone, contributions, Deck.sources.hagal).doAfter(continuation.run)
    return continuation
end

---
function Deck.generateLeaderDeck(deckZone, contracts, ix, immortality, legacy, merakon)
    assert(deckZone)
    assert(deckZone.getPosition)
    local continuation = Helper.createContinuation("Deck.generateLeaderDeck")
    local contributions = Deck._mergeStandardContributionSets(Deck.leaders, ix, immortality, legacy, merakon)
    if not contracts then
        contributions.shaddamCorrino = nil
    end
    Deck._generateDeck("Leader", deckZone, contributions, Deck.sources.leaders).doAfter(continuation.run)
    return continuation
end

---
function Deck.generateRivalLeaderDeck(deckZone, streamlined, ix, immortality, legacy)
    assert(deckZone)
    assert(deckZone.getPosition)
    local continuation = Helper.createContinuation("Deck.generateRivalLeaderDeck")
    local contributions = Deck._mergeStandardContributionSets(Deck.rivalLeaders, ix, immortality, legacy)
    for rival, _ in pairs(contributions) do
        local streamlinedRival = Helper.isElementOf(rival, { "amberMetulli", "glossuRabban" })
        if streamlined ~= streamlinedRival then
            contributions[rival] = nil
        end
    end
    Deck._generateDeck("RivalLeader", deckZone, contributions, Deck.sources.rivalLeaders).doAfter(continuation.run)
    return continuation
end

---
function Deck._mergeStandardContributionSets(root, ix, immortality, legacy, merakon)
    local contributionSets = { root.uprising }
    if merakon then
        table.insert(contributionSets, root.merakon)
    else
        if ix then
            table.insert(contributionSets, root.ix)
        end
        if immortality then
            table.insert(contributionSets, root.immortality)
        end
        if legacy then
            table.insert(contributionSets, root.legacy)
        end
    end
    return Deck._mergeContributionSets(contributionSets)
end

---
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
--- empty names ("") allows to skip intermediate cards.
---@param cards any The set where to add the namec cards.
---@param customDeck any A custom deck (API struct) as returned by Deck.createImperiumCustomDeck.
---@param startLuaIndex any The Lua start index for the card names.
---@param cardNames any An list of card names matching those in the custon deck.
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

---
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

---
function Deck._generateDeck(deckType, deckZone, contributions, sources, spacing)
    assert(deckZone.getPosition)
    return Deck._generateFromPrebuildDeck(deckType, deckZone, contributions, sources, spacing)
end

--- Add 2 back cards such as to always have a deck to take cards from.
function Deck._generateDynamicDeckWithTwoBackCards(deckType, position, contributions, sources)
    local contributions2 = Helper.shallowCopy(contributions)
    contributions2.back = 2
    local sources2 = Helper.shallowCopy(sources)
    local backUrl = Deck.backs[Helper.toCamelCase(deckType, "CardBack")]
    assert(backUrl, deckType)
    local creator = Deck[Helper.toCamelCase("create", deckType, "CustomDeck")]
    assert(creator, deckType)
    sources2.back = {
        customDeck = creator(backUrl, 1, 1),
        luaIndex = 1
    }
    return Deck._generateDynamicDeck(deckType, position, contributions2, sources2)
end

---
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

---
function Deck._nextCustomDeckId()
    Deck.customDeckBaseId = Deck.customDeckBaseId + 1
    return Deck.customDeckBaseId
end

---
function Deck._prebuildObjectiveDeck(deckPosition)
    local contributions = {
        muadDibFirstPlayer = 1,
        muadDib4to6p = 1,
        crysknife4to6p = 1,
        crysknife = 1,
        ornithopter1to3p = 1,
    }
    Deck._generateDynamicDeckWithTwoBackCards("Objective", deckPosition, contributions, Deck.sources.objective)
end

---
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

---
function Deck._prebuildEmperorStarterDeck(deckPosition)
    Deck._generateDynamicDeckWithTwoBackCards("Imperium", deckPosition, Deck.starter.emperor, Deck.sources.imperium)
end

---
function Deck._prebuildMuadDibStarterDeck(deckPosition)
    Deck._generateDynamicDeckWithTwoBackCards("Imperium", deckPosition, Deck.starter.muadDib, Deck.sources.imperium)
end

---
function Deck._prebuildImperiumDeck(deckPosition)
    local contributionSets = {
        Deck.imperium.legacy,
        Deck.imperium.ix,
        Deck.imperium.immortality,
        Deck.imperium.uprising,
        Deck.imperium.uprisingContract,
    }
    local contributions = Deck._mergeContributionSets(contributionSets, true)
    Deck._generateDynamicDeckWithTwoBackCards("Imperium", deckPosition, contributions, Deck.sources.imperium)
end

---
function Deck._prebuildSpecialDeck(deckPosition)
    local contributionSets = {
        Deck.special.legacy,
        Deck.special.immortality,
        Deck.special.uprising,
    }
    local contributions = Deck._mergeContributionSets(contributionSets, true)
    Deck._generateDynamicDeckWithTwoBackCards("Imperium", deckPosition, contributions, Deck.sources.special)
end

---
function Deck._prebuildTleilaxuDeck(deckPosition)
    Deck._generateDynamicDeckWithTwoBackCards("Imperium", deckPosition, Deck.tleilaxu, Deck.sources.tleilaxu)
end

---
function Deck._prebuildIntrigueDeck(deckPosition)
    local contributionSets = {
        Deck.intrigue.legacy,
        Deck.intrigue.ix,
        Deck.intrigue.immortality,
        Deck.intrigue.uprising,
        Deck.intrigue.uprisingContract,
    }
    local contributions = Deck._mergeContributionSets(contributionSets, true)
    Deck._generateDynamicDeckWithTwoBackCards("Intrigue", deckPosition, contributions, Deck.sources.intrigue)
end

---
function Deck._prebuildTechDeck(deckPosition)
    Deck._generateDynamicDeckWithTwoBackCards("Tech", deckPosition, Deck.tech.ix, Deck.sources.tech)
end

--
function Deck._prebuildConflictDeck(deckPosition)
    local contributionSets = {}
    for i = 1, 3 do
        for _, extension in ipairs({ "uprising", "ix", "immortality" }) do
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

---
function Deck._prebuildHagalDeck(deckPosition)
    local contributionSets = {}
    for _, extension in ipairs({ "base", "ix", "immortality" }) do
        for _, players in ipairs({ "common", "solo", "twoPlayers" }) do
            table.insert(contributionSets, Deck.hagal[extension][players])
        end
    end
    local contributions = Deck._mergeContributionSets(contributionSets, true)
    Deck._generateDynamicDeckWithTwoBackCards("Hagal", deckPosition, contributions, Deck.sources.hagal)
end

---
function Deck._prebuildLeaderDeck(deckPosition)
    local contributionSets = {
        Deck.leaders.legacy,
        Deck.leaders.ix,
        Deck.leaders.uprising,
    }
    local contributions = Deck._mergeContributionSets(contributionSets, true)
    Deck._generateDynamicDeckWithTwoBackCards("Leader", deckPosition, contributions, Deck.sources.leaders)
end

---
function Deck._prebuildRivalLeaderDeck(deckPosition)
    local contributionSets = {
        Deck.rivalLeaders.uprising,
    }
    local contributions = Deck._mergeContributionSets(contributionSets, true)
    Deck._generateDynamicDeckWithTwoBackCards("RivalLeader", deckPosition, contributions, Deck.sources.rivalLeaders)
end

---
function Deck._generateFromPrebuildDeck(deckType, deckZone, contributions, _, spacing)
    assert(deckType)
    assert(deckZone)
    assert(#deckZone.getTags() == 0 or deckZone.hasTag(deckType),
        -- Curiously, the problem doesn't exist for dynamic decks.
        "Trying to generate a static deck in an incompatibly tagged zone will trigger the dreaded 'Unknown Error'.")
    assert(contributions)

    local continuation = Helper.createContinuation("Deck._prebuildDeck")

    local sources = {}

    local prebuildZone = Deck.prebuildZones[I18N.getLocale()]
    for _, object in ipairs(prebuildZone.getObjects()) do
        if object.hasTag(deckType) then
            assert(object.type == "Deck")
            for _, card in ipairs(object.getObjects()) do
                local id = Helper.getID(card)
                if sources[id] then
                    table.insert(sources[id].instances, card.guid)
                else
                    sources[id] = {
                        deck = object,
                        instances = { card.guid }
                    }
                end
            end
        end
    end

    local cardCount = 0
    for name, cardinality in pairs(contributions) do
        local source = sources[name]
        assert(source, "No source for card '" .. deckType .. "." .. name .. "'")
        for _ = 1, cardinality do
            local firstGuid = source.instances[1]
            assert(firstGuid, "Not enough instances of the card '" .. name .. "'")
            table.remove(source.instances, 1)
            assert(source.deck, "Should not happen! Source deck is not properly generated.")
            source.deck.takeObject({
                guid = firstGuid,
                -- Stacking is needed to preserve input order.
                position = deckZone.getPosition() + Vector(0, 1 + cardCount * (spacing or 0.1), 0),
                smooth = false,
            })
            cardCount = cardCount + 1
        end
    end

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

---
function Deck.createObjectiveCustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(Deck.backs.objectiveCardBack, faceUrl, width, height, Vector(1, 1, 1))
end

---
function Deck.createImperiumCustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(Deck.backs.imperiumCardBack, faceUrl, width, height, Vector(1.05, 1, 1.05))
end

---
function Deck.createIntrigueCustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(Deck.backs.intrigueCardBack, faceUrl, width, height, Vector(1, 1, 1))
end

---
function Deck.createTechCustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(Deck.backs.techCardBack, faceUrl, width, height, Vector(0.55, 1, 0.55))
end

---
function Deck.createConflictCustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(Deck.backs.conflictCardBack, faceUrl, width, height, Vector(1, 1, 1))
end

---
function Deck.createConflict1CustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(Deck.backs.conflict1CardBack, faceUrl, width, height, Vector(1, 1, 1))
end

---
function Deck.createConflict2CustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(Deck.backs.conflict2CardBack, faceUrl, width, height, Vector(1, 1, 1))
end

---
function Deck.createConflict3CustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(Deck.backs.conflict3CardBack, faceUrl, width, height, Vector(1, 1, 1))
end

---
function Deck.createHagalCustomDeck(faceUrl, width, height, scale)
    return Deck.createCustomDeck(Deck.backs.hagalCardBack, faceUrl, width, height, scale or Vector(0.83, 1, 0.83))
end

---
function Deck.createLeaderCustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(Deck.backs.leaderCardBack, faceUrl, width, height, Vector(1.12, 1, 1.12))
end

---
function Deck.createRivalLeaderCustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(Deck.backs.rivalLeaderCardBack, faceUrl, width, height, Vector(1.05, 1, 1.05))
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
