local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

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
        }
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
        }
    },
    special = {
        -- Base
        foldspace = 6,
        arrakisLiaison = 8,
        theSpiceMustFlow = 10,
        -- Immortality
        reclaimedForces = 1
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
            armandEcaz = 1,
            ilesaEcaz = 1,
        },
        ix = {
            rhomburVernius = 1,
            tessiaVernius = 1,
            yunaMoritani = 1,
            hundroMoritani = 1,
        },
        fanmade = {
            arkhane = {
                base = {
                    xavierHarkonnen = 1,
                    feydRauthaHarkonnen = 1,
                    hasimirFenring = 1,
                    margotFenring = 1,
                    lietKynes = 1,
                    hwiNoree = 1,
                    metulli = 1,
                    milesTeg = 1,
                    irulanCorrino = 1,
                    wencisiaCorrino = 1,
                    vorianAtreides = 1,
                    serenaButler = 1,
                    whitmoreBluud = 1,
                    executrixOrdos = 1,
                    scytale = 1,
                    stabanTuek = 1,
                    esmarTuek = 1,
                    drisk = 1,
                },
                ix = {
                    abulurdHarkonnen = 1,
                    arkhane = 1,
                    normaCenvas = 1,
                },
                immortality = {
                    torgTheYoung = 1,
                    twylwythWaff = 1,
                },
            },
            retienne = {
                base = {
                    helenaRichese = 1,
                    farok = 1,
                    ilbanRichese = 1,
                    jopatiKolona = 1,
                    letoAtreidesII = 1,
                    xavierHarkonnen = 1,
                    countFenring = 1,
                    drisq = 1,
                    executrix = 1,
                    dukeMutelli = 1,
                    isyanderTheTraitorShaiad = 1,
                    swormasterDinari = 1,
                    aliaAtreides = 1,
                    princessYunaMoritani = 1,
                    --horatioDelta = 1,
                    tessiaVernius = 1,
                    shaddamIV = 1,
                    captainOtto = 1,
                    princessWensicia = 1,
                    --horatioFive = 1,
                    drLietKynes = 1,
                    bannerjee = 1,
                    serenaButler = 1,
                    shaddamV = 1,
                    --sionaAtreides = 1,
                    edric = 1,
                    shimoon = 1,
                    anirulCorrino = 1,
                    uliet = 1,
                    pretresseIsyaraStShaiad = 1,
                    memnonThorvald = 1,
                    senatorOthn = 1,
                    vorianAtreides = 1,
                    whitmoreBludd = 1,
                    --almaMavisTaraza = 1,
                    senateurMaximilienZelevas = 1,
                    stabanTuek = 1,
                    dukeLetoAtreides = 1,
                    hwiNoree = 1,
                    darwiOdrade = 1,
                    ramalloTheSayyadina = 1,
                    glossuTheBeastRabban = 1,
                    --dukeJenhaestraDrevMeos = 1,
                    baronVladimirHarkonnen = 1,
                    paulAtreides = 1,
                    chatt = 1,
                    --horatioPrime = 1,
                    abulurdHarkonnen = 1,
                    milesTeg = 1,
                    capitainYelchinOrdara = 1,
                    ilesaEcaz = 1,
                    esmarTuek = 1,
                    countessArianaThorvald = 1,
                    albertoGinaztera = 1,
                    feydRautha = 1,
                    ladyMargotFenring = 1,
                    archdukeArmandEcaz = 1,
                },
                ix = {
                    abulurdRabban = 1,
                    generalKlevLagarin = 1,
                    koalTraytron = 1,
                    normaCenva = 1,
                    omniusPrime = 1,
                    princeRhomburVernius = 1,
                    tioHoltzman = 1,
                    viscountHundroMoritani = 1,
                },
                immortality = {
                    masterWaff = 1,
                    mirlat = 1,
                    scytale = 1,
                    torgTheYoung = 1,
                    torgTheYounger = 1,
                    tylwythWaff = 1,
                    masterBijaz = 1,
                    princessIrulan = 1,
                },
            }
        }
    }
}

local imperiumCardBack = "http://cloud-3.steamusercontent.com/ugc/2093667512238502565/C3DC7A02CF378129569B414967C9BE25097C6E77/"
local intrigueCardBack = "http://cloud-3.steamusercontent.com/ugc/2093667512238521846/D63B92C616541C84A7984026D757DB03E79532DD/"
local techCardBack = "http://cloud-3.steamusercontent.com/ugc/2093667512238531825/1EA614EC832B16BC94811A7FE793344057850409/"
local conflict1CardBack = "http://cloud-3.steamusercontent.com/ugc/2093667512238537179/0423ECA84C0D71CCB38EBD60DEAE641EE72D7933/"
local conflict2CardBack = "http://cloud-3.steamusercontent.com/ugc/2093667512238537448/3B3F54DF65F76F0850D0EC683602524806A11E49/"
local conflict3CardBack = "http://cloud-3.steamusercontent.com/ugc/2093667512238537046/9E194557E37B5C4CA74C7A77CBFB6B8A36043916/"
local hagalCardBack = "http://cloud-3.steamusercontent.com/ugc/2093668799785646965/26E28590801800D852F4BCA53E959AAFAAFC8FF3/"
local leaderCardBack = "http://cloud-3.steamusercontent.com/ugc/2093668799785645356/005244DAC0A29EE68CFF741FC06564969563E8CF/"
local fanmadeLeaderCardBack = "http://cloud-3.steamusercontent.com/ugc/2093668799785649802/4C75C9A8CA6B890A6178B4B22B0F994B2F663D33/"

local customDeckBaseId = 100

---
function Deck.onLoad(state)
    if state.settings then
        Deck._staticSetUp(state.settings)
    end
end

---
function Deck.setUp(settings)
    Deck._staticSetUp(settings)
end

---
function Deck._staticSetUp(settings)
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

---
function Deck.generateStarterDeck(deckZone, immortality, epic)
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
function Deck.generateStarterDiscard(discardZone, immortality, epic)
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
function Deck.generateImperiumDeck(deckZone, ix, immortality)
    assert(deckZone)
    local continuation = Helper.createContinuation("Deck.generateImperiumDeck")
    local contributions = Deck._mergeStandardContributionSets(Deck.imperium, ix, immortality)
    Deck._generateDeck("Imperium", deckZone.getPosition(), contributions, Deck.sources.imperium).doAfter(continuation.run)
    return continuation
end

---
function Deck.generateSpecialDeck(name, deckZone)
    assert(deckZone)
    local continuation = Helper.createContinuation("Deck.generateSpecialDeck")
    assert(name)
    assert(Deck.special[name])
    local contributions = { [name] = Deck.special[name] }
    Deck._generateDeck("Imperium", deckZone.getPosition(), contributions, Deck.sources.special).doAfter(function (deck)
        deck.flip()
        continuation.run(deck)
    end)
    return continuation
end

---
function Deck.generateTleilaxuDeck(deckZone)
    assert(deckZone)
    local continuation = Helper.createContinuation("Deck.generateTleilaxuDeck")
    Deck._generateDeck("Imperium", deckZone.getPosition(), Deck.tleilaxu, Deck.sources.tleilaxu).doAfter(continuation.run)
    return continuation
end

---
function Deck.generateIntrigueDeck(deckZone, ix, immortality)
    assert(deckZone)
    local continuation = Helper.createContinuation("Deck.generateIntrigueDeck")
    local contributions = Deck._mergeStandardContributionSets(Deck.intrigue, ix, immortality)
    Deck._generateDeck("Intrigue", deckZone.getPosition(), contributions, Deck.sources.intrigue).doAfter(continuation.run)
    return continuation
end

---
function Deck.generateTechDeck(deckZones)
    assert(deckZones)
    assert(#deckZones == 3)
    local continuation = Helper.createContinuation("Deck.generateTechDeck")

    local keys = Helper.getKeys(Deck.tech)
    Helper.shuffle(keys)

    local decks = {}

    local remaining = 0
    for i = 1, 3 do
        remaining = remaining + 1
        local part = {}
        for j = (i - 1) * 6 + 1, i * 6 do
            part[keys[j]] = Deck.tech[keys[j]]
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
function Deck.generateLeaderDeck(deckZone, ix, immortality, fanmadeLeaders)
    assert(deckZone)
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
    Deck._generateDeck("Leader", deckZone.getPosition(), contributions, Deck.sources.leaders).doAfter(continuation.run)
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
function Deck.createImperiumCustomDeck(faceUrl, width, height)
    return Deck._createCustomDeck(imperiumCardBack, faceUrl, width, height, Vector(1.05, 1, 1.05))
end

---
function Deck.createIntrigueCustomDeck(faceUrl, width, height)
    return Deck._createCustomDeck(intrigueCardBack, faceUrl, width, height, Vector(1, 1, 1))
end

---
function Deck.createTechCustomDeck(faceUrl, width, height)
    return Deck._createCustomDeck(techCardBack, faceUrl, width, height, Vector(0.55, 1, 0.55))
end

---
function Deck.createConflict1CustomDeck(faceUrl, width, height)
    return Deck._createCustomDeck(conflict1CardBack, faceUrl, width, height, Vector(1, 1, 1))
end

---
function Deck.createConflict2CustomDeck(faceUrl, width, height)
    return Deck._createCustomDeck(conflict2CardBack, faceUrl, width, height, Vector(1, 1, 1))
end

---
function Deck.createConflict3CustomDeck(faceUrl, width, height)
    return Deck._createCustomDeck(conflict3CardBack, faceUrl, width, height, Vector(1, 1, 1))
end

---
function Deck.createHagalCustomDeck(faceUrl, width, height, scale)
    return Deck._createCustomDeck(hagalCardBack, faceUrl, width, height, scale or Vector(0.83, 1, 0.83))
end

---
function Deck.createLeaderCustomDeck(faceUrl, width, height)
    return Deck._createCustomDeck(leaderCardBack, faceUrl, width, height, Vector(1.12, 1, 1.12))
end

---
function Deck.createFanmadeLeaderCustomDeck(faceUrl, width, height)
    return Deck._createCustomDeck(fanmadeLeaderCardBack, faceUrl, width, height, Vector(1.12, 1, 1.12))
end

---
function Deck._createCustomDeck(backUrl, faceUrl, width, height, scale)
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
