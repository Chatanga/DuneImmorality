local function fremenBond(value)
    return function (cards)
        -- TODO
        return value
    end
end

local function influence(faction, friendshipValue, allianceValue)
    return function (cards)
        -- TODO
        return friendshipValue
    end
end

local function helices(oneHelixValue, twoHelicesValue)
    return function (cards)
        -- TODO
        return oneHelixValue
    end
end

-- TODO Generate from Excel.
local ImperiumCard = {
    duneTheDesertPlanet = { agent = {}, reveal = {} },
    seekAllies = { agent = {}, reveal = {} },
    signetRing = { agent = {}, reveal = { persuasion = 1 } },
    diplomacy = { agent = {}, reveal = { persuasion = 1 } },
    reconnaissance = { agent = {}, reveal = { persuasion = 1 } },
    convincingArgument = { agent = {}, reveal = { persuasion = 2 } },
    dagger = { agent = {}, reveal = { strength = 1 } },
    controlTheSpice = { agent = {}, reveal = {} },
    experimentation = { agent = {}, reveal = { persuasion = 1, specimen = 1 } },

    jessicaOfArrakis = { agent = {}, reveal = {} },
    sardaukarLegion = { agent = {}, reveal = {} },
    drYueh = { agent = {}, reveal = {} },
    assassinationMission = { agent = {}, reveal = {} },
    sardaukarInfantry = { agent = {}, reveal = {} },
    beneGesseritInitiate = { agent = {}, reveal = {} },
    guildAdministrator = { agent = {}, reveal = {} },
    theVoice = { agent = {}, reveal = {} },
    scout = { agent = {}, reveal = {} },
    imperialSpy = { agent = {}, reveal = {} },
    beneGesseritSister = { agent = {}, reveal = {}, factions = { "beneGesserit" } },
    missionariaProtectiva = { agent = {}, reveal = { persuasion = 1 }, factions = { "beneGesserit" } },
    spiceHunter = { agent = {}, reveal = {} },
    spiceSmugglers = { agent = {}, reveal = {} },
    feydakinDeathCommando = { agent = {}, reveal = {} },
    geneManipulation = { agent = {}, reveal = {} },
    guildBankers = { agent = {}, reveal = {} },
    choamDirectorship = { agent = {}, reveal = {} },
    crysknife = { agent = {}, reveal = {} },
    chani = { agent = {}, reveal = {} },
    spaceTravel = { agent = {}, reveal = {} },
    duncanIdaho = { agent = {}, reveal = {} },
    shiftinAllegiances = { agent = {}, reveal = { persuasion = 2 } },
    kwisatzHaderach = { agent = {}, reveal = {} },
    sietchReverendMother = { agent = {}, reveal = { persuasion = fremenBond(3), spice = fremenBond(1) }, factions = { "beneGesserit", "fremen" } },
    arrakisRecruiter = { agent = {}, reveal = { persuasion = 1, strength = 1 } },
    firmGrip = { agent = {}, reveal = {} },
    smugglersThopter = { agent = {}, reveal = { persuasion = 1, spice = 1 }, factions = { "spacingGuild" } },
    carryall = { agent = {}, reveal = {} },
    gunThopter = { agent = {}, reveal = {} },
    guildAmbassador = { agent = {}, reveal = {} },
    testOfHumanity = { agent = {}, reveal = {} },
    fremenCamp = { agent = {}, reveal = {} },
    opulence = { agent = {}, reveal = {} },
    ladyJessica = { agent = {}, reveal = {} },
    stilgar = { agent = {}, reveal = {} },
    piterDeVries = { agent = {}, reveal = { persuasion = 3, strength = 1 } },
    gurneyHalleck = { agent = {}, reveal = {} },
    thufirHawat = { agent = {}, reveal = {} },
    otherMemory = { agent = {}, reveal = {} },
    lietKynes = { agent = {}, reveal = {} },
    wormRiders = { agent = {}, reveal = { strength = influence("fremen", 4, 2) }, factions = { "fremen" } },
    reverendMotherMohiam = { agent = {}, reveal = { persuasion = 2, spice = 2 }, factions = { "emperor", "beneGesserit" } },
    powerPlay = { agent = {}, reveal = {} },
    duncanLoyalBlade = { agent = {}, reveal = {} },
    thumper = { agent = {}, reveal = {} },

    boundlessAmbition = { agent = {}, reveal = {} },
    guildChiefAdministrator = { agent = {}, reveal = {} },
    guildAccord = { agent = {}, reveal = {} },
    localFence = { agent = {}, reveal = { persuasion = 2 } },
    shaiHulud = { agent = {}, reveal = {} },
    ixGuildCompact = { agent = {}, reveal = {} },
    choamDelegate = { agent = {}, reveal = {} },
    bountyHunter = { agent = {}, reveal = { persuasion = 1, strength = 1 } },
    embeddedAgent = { agent = {}, reveal = {} },
    esmarTuek = { agent = {}, reveal = { spice = 2, solari = 2 }, factions = { "spacingGuild" } },
    courtIntrigue = { agent = {}, reveal = { persuasion = 1, strength = 1 }, factions = { "emperor" } },
    sayyadina = { agent = {}, reveal = {} },
    imperialShockTrooper = { agent = {}, reveal = {} },
    appropriate = { agent = {}, reveal = { persuasion = 2 }, factions = { "emperor" }, acquisition = { freighter = 1 } },
    desertAmbush = { agent = {}, reveal = {} },
    inTheShadows = { agent = {}, reveal = {} },
    satelliteBan = { agent = {}, reveal = { persuasion = 1 }, factions = { "spacingGuild", "fremen" } },
    freighterFleet = { agent = {}, reveal = { freighter = 1 } },
    imperialBashar = { agent = {}, reveal = {} },
    jamis = { agent = {}, reveal = {} },
    landingRights = { agent = {}, reveal = {} },
    waterPeddler = { agent = {}, reveal = {} },
    treachery = { agent = {}, reveal = {} },
    truthsayer = { agent = {}, reveal = {} },
    spiceTrader = { agent = {}, reveal = {} },
    ixianEngineer = { agent = {}, reveal = {} },
    webOfPower = { agent = {}, reveal = {} },
    weirdingWay = { agent = {}, reveal = {} },
    negotiatedWithdrawal = { agent = {}, reveal = {} },
    fullScaleAssault = { agent = {}, reveal = {} },
    beneTleilaxLab = { agent = {}, reveal = {} },
    beneTleilaxResearcher = { agent = {}, reveal = {} },
    blankState = { agent = {}, reveal = {} },
    clandestineMeeting = { agent = {}, reveal = {} },
    corruptSmuggler = { agent = {}, reveal = {} },
    dissectingKit = { agent = {}, reveal = { persuasion = 1, beetle = helices(1, 0) } },
    forHumanity = { agent = {}, reveal = {} },
    highPriorityTravel = { agent = {}, reveal = { persuasion = 1, solari = 1 }, factions = { "spacingGuild" } },
    imperiumCeremony = { agent = {}, reveal = {} },
    interstellarConspiracy = { agent = {}, reveal = { persuasion = 2 }, factions = { "spacingGuild" } },
    keysToPower = { agent = {}, reveal = { persuasion = 2 }, factions = { "spacingGuild", "beneGesserit" } },
    lisanAlGaib = { agent = {}, reveal = { strength = fremenBond(2) }, factions = { "beneGesserit", "fremen" } },
    longReach = { agent = {}, reveal = {} },
    occupation = { agent = {}, reveal = {} },
    organMerchants = { agent = {}, reveal = {} },
    plannedCoupling = { agent = {}, reveal = {} },
    replacementEyes = { agent = {}, reveal = {} },
    sardaukarQuatermaster = { agent = {}, reveal = { persuasion = 1, strength = 2 }, factions = { "emperor" } },
    shadoutMapes = { agent = {}, reveal = {} },
    showOfStrength = { agent = {}, reveal = {} },
    spiritualFervor = { agent = {}, reveal = {} },
    stillsuitManufacturer = { agent = {}, reveal = {} },
    throneRoomPolitics = { agent = {}, reveal = {} },
    tleilaxuMaster = { agent = {}, reveal = {} },
    tleilaxuSurgeon = { agent = {}, reveal = {} },

    foldspace = { agent = {}, reveal = {} },
    arrakisLiaison = { agent = {}, reveal = { persuasion = 2 }, factions = { "fremen" } },
    theSpiceMustFlow = { agent = {}, reveal = { spice = 1 } },

    piterGeniusAdvisor = { agent = {}, reveal = {} },
    beguilingPheromones = { agent = {}, reveal = {} },
    chairdog = { agent = {}, reveal = {} },
    contaminator = { agent = {}, reveal = {} },
    corrinoGenes = { agent = {}, reveal = {} },
    faceDancer = { agent = {}, reveal = {} },
    faceDancerInitiate = { agent = {}, reveal = {} },
    fromTheTanks = { agent = {}, reveal = {} },
    ghola = { agent = {}, reveal = {} },
    guildImpersonator = { agent = {}, reveal = {} },
    industrialEspionage = { agent = {}, reveal = {} },
    scientificBreakthrough = { agent = {}, reveal = {} },
    sligFarmer = { agent = {}, reveal = {} },
    stitchedHorror = { agent = {}, reveal = {} },
    subjectX137 = { agent = {}, reveal = {} },
    tleilaxuInflitrator = { agent = {}, reveal = {} },
    twistedMentat = { agent = {}, reveal = {} },
    unnaturalReflexes = { agent = {}, reveal = {} },
    usurp = { agent = {}, reveal = {} },
}

--[[
access = {
    spaceType = emperor|spacingGuild|beneGesserit|fremen|landsraadAndIx|cities|choamAndDesert,
    infiltration = true|false
}
]]--

--[[
function ImperiumCard.isGraft(card)
end

function ImperiumCard.getAgentAccesses(card, grafted)
end

function ImperiumCard.getAgentEffect(color, graftedCardIfAny)
end

function ImperiumCard.getRevealEffect(color)
end
]]--

function ImperiumCard.getFixedRevealPersuasion(color, card)
    return ImperiumCard._resolveCard(card).reveal.persuasion or 0
end

function ImperiumCard.getFixedRevealStrength(color, card)
    return ImperiumCard._resolveCard(card).reveal.strength or 0
end

function ImperiumCard.getPersuasionCost(card)
    -- TODO
end

function ImperiumCard.getSpecimenCost(card)
    -- TODO
end

function ImperiumCard.getAcquisitionBonus(card)
    -- TODO
end

function ImperiumCard._resolveCard(card)
    local cardName = card.getDescription()
    local characteristics = ImperiumCard[cardName]
    assert(characteristics, "Unknown card: " .. cardName)
    return characteristics
end

return ImperiumCard
