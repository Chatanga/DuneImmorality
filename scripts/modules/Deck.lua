local Helper = require("utils.Helper")

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
            duneTheDesertPlanet = Helper.erase,
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
            shiftinAllegiances = 2,
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
            blankState = 1,
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
            sardaukarQuatermaster = 1,
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
        tleilaxuInflitrator = 1,
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
            masterTacitian = 3,
            planWithinPlans = 1,
            privateArmy = 2,
            doubleCross = 1,
            concilorsDispensiation = 2,
            cornerTheMarket = 1,
            charisma = 1,
            calculatedHire = 1,
            choamShare = 1,
            bypassProtocol = 1,
            recruitmentMission = 1,
            reinforcements = 1,
            binduSuspension = 1,
            secretOfTheSiterhood = 1,
            rapidMobilization = 1,
            stagedIncident = 1,
            theSleeperMustAwaken = 1,
            tiebreaker = 1,
            toTheVictor = 1,
            waterPeedelsUnion = 1,
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
                economySupremacy = 1,
            },
        },
    },
    hagal = {
        base = {
            core = {
                churn = 2,
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
                rallyTroops = Helper.erase,
                hallOfOratory = Helper.erase,
            },
            solo = {
                interstellarShipping = 1,
                foldspaceAndInterstellarShipping = 1,
                smugglingAndInterstellarShipping = 1,
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
                cathag = Helper.erase,
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
        -- With a Hagal mark:
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
        fanMade = {
            --[[
                maxK: https://boardgamegeek.com/thread/2899772/12-new-fan-made-house-leaders-play-them
                tylerBeck: https://boardgamegeek.com/thread/2963793/ideas-2-new-immortality-leaders
                alexPR: https://boardgamegeek.com/filepage/253799/26-fan-made-leaders (+ rework)
                arkhane: https://forum.cwowd.com/t/dune-imperium-personnages-fanmade/45175
            ]]--
            arkhane = {
                base = {
                    metulli = 1,
                    hasimirFenring = 1,
                    scytale = 1,
                    margotFenring = 1,
                    feydRauthaHarkonnen = 1,
                    serenaButler = 1,
                    lietKynes = 1,
                    wensiciaCorrino = 1,
                    irulanCorrino = 1,
                    hwiNoree = 1,
                    whitmoreBlund = 1,
                    drisq = 1,
                    executrix = 1,
                    milesTeg = 1,
                    esmarTuek = 1,
                    vorianAtreides = 1,
                },
                ix = {
                    xavierHarkonnen = 1,
                    normaCenva = 1,
                    abuldurHarkonnen = 1,
                    arkhane = 1,
                    stabanTuek = 1,
                },
                immortality = {
                    tylwythWaff = 1,
                    torgTheYoung = 1,
                }
            },
        },
    }
}

local imperiumCardBack = "http://cloud-3.steamusercontent.com/ugc/1892102433196500461/C3DC7A02CF378129569B414967C9BE25097C6E77/"
local intrigueCardBack = "http://cloud-3.steamusercontent.com/ugc/1892102433196339102/D63B92C616541C84A7984026D757DB03E79532DD/"
local techCardBack = "http://cloud-3.steamusercontent.com/ugc/1825650681921337946/F576092145EF665310845108C247CAE73985C23C/"
local conflict1CardBack = "http://cloud-3.steamusercontent.com/ugc/1892102591130037191/0423ECA84C0D71CCB38EBD60DEAE641EE72D7933/"
local conflict2CardBack = "http://cloud-3.steamusercontent.com/ugc/1892102591130039766/3B3F54DF65F76F0850D0EC683602524806A11E49/"
local conflict3CardBack = "http://cloud-3.steamusercontent.com/ugc/1892102591130041978/9E194557E37B5C4CA74C7A77CBFB6B8A36043916/"
local hagalCardBack = "http://cloud-3.steamusercontent.com/ugc/1670239430231973967/ACE7BA96F9E5F8218FA434192B90234FD9ED4E38/"
local leaderCardBack = "http://cloud-3.steamusercontent.com/ugc/2027235268872195913/005244DAC0A29EE68CFF741FC06564969563E8CF/"

local customDeckBaseId = 900

local en = require("en.Deck")
local fr = require("fr.Deck")

---
function Deck.onLoad(_)
    Deck.sources = en.loadCustomDecks(Deck)
end

---
function Deck.generateStarterDeck(deckZone, immortality, epic)
    assert(deckZone)
    local continuation = Helper.createContinuation()
    local contributionSets = { Deck.starter.base }
    if immortality then
        table.insert(contributionSets, Deck.starter.immortality)
    end
    local contributions = Deck.mergeContributionSets(contributionSets)
    if not immortality and epic then
        contributions["duneTheDesertPlanet"] = 1
        contributions["controlTheSpice"] = 1
    end
    Deck.generateDeck("Imperium", deckZone.getPosition(), contributions, Deck.sources.imperium).doAfter(continuation.run)
    return continuation
end

---
function Deck.generateStarterDiscard(discardZone, immortality, epic)
    assert(discardZone)
    local continuation = Helper.createContinuation()
    if immortality and epic then
        Deck.generateDeck("Imperium", discardZone.getPosition(), Deck.starter.epic, Deck.sources.imperium).doAfter(function (deck)
            deck.flip()
            continuation.run(deck)
        end)
    end
    return continuation
end

---
function Deck.generateImperiumDeck(deckZone, ix, immortality)
    assert(deckZone)
    local continuation = Helper.createContinuation()
    local contributions = Deck.mergeStandardContributionSets(Deck.imperium, ix, immortality)
    Deck.generateDeck("Imperium", deckZone.getPosition(), contributions, Deck.sources.imperium).doAfter(continuation.run)
    return continuation
end

---
function Deck.generateSpecialDeck(name, deckZone)
    assert(deckZone)
    local continuation = Helper.createContinuation()
    assert(name)
    assert(Deck.special[name])
    local contributions = { [name] = Deck.special[name] }
    Deck.generateDeck("Imperium", deckZone.getPosition(), contributions, Deck.sources.special).doAfter(function (deck)
        deck.flip()
        continuation.run(deck)
    end)
    return continuation
end

---
function Deck.generateTleilaxuDeck(deckZone)
    assert(deckZone)
    local continuation = Helper.createContinuation()
    Deck.generateDeck("Imperium", deckZone.getPosition(), Deck.tleilaxu, Deck.sources.tleilaxu).doAfter(continuation.run)
    return continuation
end

---
function Deck.generateIntrigueDeck(deckZone, ix, immortality)
    assert(deckZone)
    local continuation = Helper.createContinuation()
    local contributions = Deck.mergeStandardContributionSets(Deck.intrigue, ix, immortality)
    Deck.generateDeck("Intrigue", deckZone.getPosition(), contributions, Deck.sources.intrigue).doAfter(continuation.run)
    return continuation
end

---
function Deck.generateTechDeck(deckZones)
    assert(deckZones)
    assert(#deckZones == 3)
    local continuation = Helper.createContinuation()

    local keys = Helper.getKeys(Deck.tech)
    Helper.shuffle(keys)

    local remaining = 0
    for i = 1, 3 do
        remaining = remaining + 1
        local part = {}
        for j = (i - 1) * 6 + 1, i * 6 do
            part[keys[j]] = Deck.tech[keys[j]]
        end
        local deckZone = deckZones[i]
        Deck.generateDeck("Tech", deckZone.getPosition(), part, Deck.sources.tech).doAfter(function (deck)
            local above = deckZone.getPosition() + Vector(0, 1, 0)
            Helper.moveCardFromZone(deckZone, above, nil, true, true)

            remaining = remaining - 1
            if remaining == 0 then
                continuation.run()
            end
        end)
    end

    return continuation
end

--
function Deck.generateConflictDeck(deckZone, ix, epic)
    assert(deckZone)
    local continuation = Helper.createContinuation()

    local cardCounts = epic and { 0, 5, 5 } or { 1, 5, 4 }

    local contributions = {}
    for level = 1, 3 do
        local cardCount = cardCounts[level]
        if cardCount > 0 then
            local levelContributions = Deck.mergeStandardContributionSets(Deck.conflict["level" .. tostring(level)], ix, false)
            local cardNames = Helper.getKeys(levelContributions)
            Helper.shuffle(cardNames)
            for i = 1, cardCounts[level] do
                contributions[cardNames[i]] = 1
            end
        end
    end

    local position = deckZone.getPosition() + Vector(0, 1, 0)
    Deck.generateDeck("Conflict", position, contributions, Deck.sources.conflict).doAfter(continuation.run)

    return continuation
end

---
function Deck.generateHagalDeck(deckZone, ix, immortality, playerCount)
    assert(deckZone)
    assert(playerCount == 1 or playerCount == 2)
    local continuation = Helper.createContinuation()

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

    local contributions = Deck.mergeContributionSets(contributionSets)
    Deck.generateDeck("Hagal", deckZone.getPosition(), contributions, Deck.sources.hagal).doAfter(continuation.run)
    return continuation
end

---
function Deck.generateLeaderDeck(deckZone, ix, immortality, fanMadeLeaders)
    assert(deckZone)
    local continuation = Helper.createContinuation()
    local contributions = Deck.mergeStandardContributionSets(Deck.leaders, ix, immortality)
    if fanMadeLeaders then
        contributions = Deck.mergeContributionSets({ contributions, Deck.mergeStandardContributionSets(Deck.leaders.fanMade.arkhane, ix, immortality) })
    end
    Deck.generateDeck("Leader", deckZone.getPosition(), contributions, Deck.sources.leaders).doAfter(continuation.run)
    return continuation
end

---
function Deck.mergeStandardContributionSets(root, ix, immortality)
    local contributionSets = { root.base }
    if ix then
        table.insert(contributionSets, root.ix)
    end
    if immortality then
        table.insert(contributionSets, root.immortality)
    end
    return Deck.mergeContributionSets(contributionSets)
end

---
function Deck.mergeContributionSets(contributionSets)
    local contributions = {}
    for _, contributionSet in ipairs(contributionSets) do
        for name, arity in pairs(contributionSet) do
            local currentArity
            if arity == Helper.erase then
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
---@param cards any The set where to add the namec cards.
---@param customDeck any A custom deck (API struct) as returned by
--- Deck.createImperiumCustomDeck.
---@param startLuaIndex any The Lua start index for the card names.
---@param cardNames any An list of card names matching those in the custon deck.
---The startLuaIndex could be greater than 1 to skip the first cards, whereas
--- empty names ("") allows to skip intermediate cards.
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
function Deck.generateCardData(customDeck, customDeckId, cardId)
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
function Deck.generateDeck(deckName, position, contributions, sources)
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
        Nickname = deckName,
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

    local customDeck
    local customDeckId

    for name, cardinality in pairs(contributions) do
        local source = sources[name]

        if not source then
            log("No source for card '" .. name .. "'")
            goto continue
        end

        if source.customDeck ~= customDeck then
            customDeckId = Deck.nextCustomDeckId()
            data.CustomDeck[tostring(customDeckId)] = source.customDeck
            data.Transform.scaleX = source.customDeck.__scale
            data.Transform.scaleZ = source.customDeck.__scale
            customDeck = source.customDeck
        end

        for _ = 1, cardinality do
            local index = source.luaIndex - 1
            local cardId = tostring(customDeckId * 100 + index)
            table.insert(data.DeckIDs, tostring(cardId))
            local cardData = Deck.generateCardData(customDeck, customDeckId, cardId)
            cardData.Tags = { deckName }

            cardData.Description = name
            table.insert(data.ContainedObjects, cardData)
        end
        ::continue::
    end

    local continuation = Helper.createContinuation()

    local spawnParameters = {
        data = #data.ContainedObjects == 1 and data.ContainedObjects[1] or data,
        position = position,
        rotation = Vector(0, 180, 180),
        callback_function = function (newDeck)
            continuation.run(newDeck)
        end
    }

    spawnObjectData(spawnParameters)

    return continuation
end

---
function Deck.nextCustomDeckId()
    customDeckBaseId = customDeckBaseId + 1
    return customDeckBaseId
end

---
function Deck.createImperiumCustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(imperiumCardBack, faceUrl, width, height, 1.05)
end

---
function Deck.createIntrigueCustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(intrigueCardBack, faceUrl, width, height, 1)
end

---
function Deck.createTechCustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(techCardBack, faceUrl, width, height, 0.52)
end

---
function Deck.createConflict1CustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(conflict1CardBack, faceUrl, width, height, 1)
end

---
function Deck.createConflict2CustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(conflict2CardBack, faceUrl, width, height, 1)
end

---
function Deck.createConflict3CustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(conflict3CardBack, faceUrl, width, height, 1)
end

---
function Deck.createHagalCustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(hagalCardBack, faceUrl, width, height, 0.83)
end

---
function Deck.createLeaderCustomDeck(faceUrl, width, height)
    return Deck.createCustomDeck(leaderCardBack, faceUrl, width, height, 1.12)
end

---
function Deck.createCustomDeck(backUrl, faceUrl, width, height, scale)
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
