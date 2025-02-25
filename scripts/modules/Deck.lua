local Module = require("utils.Module")
local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

local Locale = Module.lazyRequire("Locale")

local Deck = {
    decals = {
        corrinoAcquireCard = "https://steamusercontent-a.akamaihd.net/ugc/2502404390141304246/9E9986D0F348F5D23A16745A271FFD28958651FB/",
        genericAcquireCard = "https://steamusercontent-a.akamaihd.net/ugc/2502404390141305713/5F7C572489E5E03F3230B012DA0E01A84EDAABF8/",
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
            }
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
        fanmade = {
            arkhane = {
                base = {
                    ak_xavierHarkonnen = 1,
                    ak_feydRauthaHarkonnen = 1,
                    ak_hasimirFenring = 1,
                    ak_margotFenring = 1,
                    ak_lietKynes = 1,
                    ak_hwiNoree = 1,
                    ak_metulli = 1,
                    ak_milesTeg = 1,
                    ak_irulanCorrino = 1,
                    ak_wencisiaCorrino = 1,
                    ak_vorianAtreides = 1,
                    ak_serenaButler = 1,
                    ak_whitmoreBluud = 1,
                    ak_executrixOrdos = 1,
                    ak_scytale = 1,
                    ak_stabanTuek = 1,
                    ak_esmarTuek = 1,
                    ak_drisk = 1,
                },
                ix = {
                    ak_abulurdHarkonnen = 1,
                    ak_arkhane = 1,
                    ak_normaCenvas = 1,
                },
                immortality = {
                    ak_torgTheYoung = 1,
                    ak_twylwythWaff = 1,
                },
            },
            retienne = {
                base = {
                    rt_helenaRichese = 1,
                    rt_farok = 1,
                    rt_ilbanRichese = 1,
                    rt_jopatiKolona = 1,
                    rt_letoAtreidesII = 1,
                    rt_xavierHarkonnen = 1,
                    rt_countFenring = 1,
                    rt_drisq = 1,
                    rt_executrix = 1,
                    rt_dukeMutelli = 1,
                    rt_isyanderTheTraitorShaiad = 1,
                    rt_swormasterDinari = 1,
                    rt_aliaAtreides = 1,
                    rt_princessYunaMoritani = 1,
                    --rt_horatioDelta = 1,
                    rt_tessiaVernius = 1,
                    rt_shaddamIV = 1,
                    rt_captainOtto = 1,
                    rt_princessWensicia = 1,
                    --rt_horatioFive = 1,
                    rt_drLietKynes = 1,
                    rt_bannerjee = 1,
                    rt_serenaButler = 1,
                    rt_shaddamV = 1,
                    --rt_sionaAtreides = 1,
                    rt_edric = 1,
                    rt_shimoon = 1,
                    rt_anirulCorrino = 1,
                    rt_uliet = 1,
                    rt_pretresseIsyaraStShaiad = 1,
                    rt_memnonThorvald = 1,
                    rt_senatorOthn = 1,
                    rt_vorianAtreides = 1,
                    rt_whitmoreBludd = 1,
                    --rt_almaMavisTaraza = 1,
                    rt_senateurMaximilienZelevas = 1,
                    rt_stabanTuek = 1,
                    rt_dukeLetoAtreides = 1,
                    rt_hwiNoree = 1,
                    rt_darwiOdrade = 1,
                    rt_ramalloTheSayyadina = 1,
                    rt_glossuTheBeastRabban = 1,
                    --rt_dukeJenhaestraDrevMeos = 1,
                    rt_baronVladimirHarkonnen = 1,
                    rt_paulAtreides = 1,
                    rt_chatt = 1,
                    --rt_horatioPrime = 1,
                    rt_abulurdHarkonnen = 1,
                    rt_milesTeg = 1,
                    rt_capitainYelchinOrdara = 1,
                    rt_ilesaEcaz = 1,
                    rt_esmarTuek = 1,
                    rt_countessArianaThorvald = 1,
                    rt_albertoGinaztera = 1,
                    rt_feydRautha = 1,
                    rt_ladyMargotFenring = 1,
                    rt_archdukeArmandEcaz = 1,
                },
                ix = {
                    rt_abulurdRabban = 1,
                    rt_generalKlevLagarin = 1,
                    rt_koalTraytron = 1,
                    rt_normaCenva = 1,
                    rt_omniusPrime = 1,
                    rt_princeRhomburVernius = 1,
                    rt_tioHoltzman = 1,
                    rt_viscountHundroMoritani = 1,
                },
                immortality = {
                    rt_masterWaff = 1,
                    rt_mirlat = 1,
                    rt_scytale = 1,
                    rt_torgTheYoung = 1,
                    rt_torgTheYounger = 1,
                    rt_tylwythWaff = 1,
                    rt_masterBijaz = 1,
                    rt_princessIrulan = 1,
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
    }
}

---
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
        end
    end)
end

---
function Deck.onLoad()
    Deck.prebuildZones = Helper.resolveGUIDs(true, {
        en = "cf9923",
        fr = "95b3db",
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
function Deck.generateImperiumDeck(deckZone, ix, immortality)
    assert(deckZone)
    assert(deckZone.getPosition)
    local continuation = Helper.createContinuation("Deck.generateImperiumDeck")
    local contributions = Deck._mergeStandardContributionSets(Deck.imperium, ix, immortality)
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
function Deck.generateIntrigueDeck(deckZone, ix, immortality)
    assert(deckZone)
    assert(deckZone.getPosition)
    local continuation = Helper.createContinuation("Deck.generateIntrigueDeck")
    local contributions = Deck._mergeStandardContributionSets(Deck.intrigue, ix, immortality)
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
function Deck.generateConflictDeck(deckZone, ix, epic)
    assert(deckZone)
    assert(deckZone.getPosition)
    local continuation = Helper.createContinuation("Deck.generateConflictDeck")

    local cardCounts = epic and { 0, 5, 5 } or { 1, 5, 4 }

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
function Deck.generateLeaderDeck(deckZone, ix, immortality, fanmadeLeaders)
    assert(deckZone)
    assert(deckZone.getPosition)
    local continuation = Helper.createContinuation("Deck.generateLeaderDeck")
    local contributions = Deck._mergeStandardContributionSets(Deck.leaders, ix, immortality)
    if fanmadeLeaders then
        local locale = I18N.getLocale()
        if locale == 'fr' then
            contributions = Deck._mergeContributionSets({ contributions, Deck._mergeStandardContributionSets(Deck.leaders.fanmade.arkhane, ix, immortality) })
        elseif locale == 'en' then
            contributions = Deck._mergeStandardContributionSets(Deck.leaders.fanmade.retienne, ix, immortality)
        end
    end
    Deck._generateDeck("Leader", deckZone, contributions, Deck.sources.leaders).doAfter(continuation.run)
    return continuation
end

---
function Deck._mergeStandardContributionSets(root, ix, immortality)
    local contributionSets = { root.base }
    if ix then
        table.insert(contributionSets, root.ix)
    end
    if immortality then
        table.insert(contributionSets, root.immortality)
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
        Deck.imperium.base,
        Deck.imperium.ix,
        Deck.imperium.immortality,
    }
    local contributions = Deck._mergeContributionSets(contributionSets, true)
    Deck._generateDynamicDeckWithTwoBackCards("Imperium", deckPosition, contributions, Deck.sources.imperium)
end

---
function Deck._prebuildSpecialDeck(deckPosition)
    local contributionSets = {
        Deck.special.base,
        Deck.special.immortality,
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
        Deck.intrigue.base,
        Deck.intrigue.ix,
        Deck.intrigue.immortality,
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
        for _, extension in ipairs({ "base", "ix", "immortality" }) do
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
        Deck.leaders.base,
        Deck.leaders.ix,
    }
    local contributions = Deck._mergeContributionSets(contributionSets, true)

    local locale = I18N.getLocale()
    if locale == 'fr' then
        contributions = Deck._mergeContributionSets({ contributions, Deck._mergeStandardContributionSets(Deck.leaders.fanmade.arkhane, true, true) })
    elseif locale == 'en' then
        contributions = Deck._mergeContributionSets({ contributions, Deck._mergeStandardContributionSets(Deck.leaders.fanmade.retienne, true, true) })
    end

    Deck._generateDynamicDeckWithTwoBackCards("Leader", deckPosition, contributions, Deck.sources.leaders)
end

---
function Deck._prebuildArrakeenScoutDeck(deckPosition)
    local contributionSets = {
        Deck.arrakeenScouts.committee,
        Deck.arrakeenScouts.auction,
        Deck.arrakeenScouts.event,
        Deck.arrakeenScouts.mission,
        Deck.arrakeenScouts.sale,
    }
    local contributions = Deck._mergeContributionSets(contributionSets, true)
    Deck._generateDynamicDeckWithTwoBackCards("ArrakeenScouts", deckPosition, contributions, Deck.sources.arrakeenScouts)
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
        if source then
            for _ = 1, cardinality do
                local firstGuid = source.instances[1]
                table.remove(source.instances, 1)
                if source.deck then
                    source.deck.takeObject({
                        guid = firstGuid,
                        -- Stacking is needed to preserve input order.
                        position = deckZone.getPosition() + Vector(0, 1 + cardCount * (spacing or 0.1), 0),
                        smooth = false,
                    })
                    cardCount = cardCount + 1
                else
                    error("Should not happen! Source deck is not properly generated.")
                end
            end
        else
            error("No source for card '" .. deckType .. "." .. name .. "'")
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
function Deck.createFanmadeLeaderCustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(Deck.backs.fanmadeLeaderCardBack, faceUrl, width, height, Vector(1.12, 1, 1.12))
end

---
function Deck.createArrakeenScoutsCustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(Deck.backs.arrakeenScoutsCardBack, faceUrl, width, height, Vector(0.5, 1, 0.5))
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
