return {
    ["?"] = "?",

    -- Setup UI
    prolog = "\"A setup is a very delicate time...\"",
    language = "Language",
    players = "Players",
    virtualHotSeat = "Solo / Hotseat",
    randomizePlayersPositions = "Randomize players' positions",
    extensions = "Extensions",
    useContracts = "CHOAM contracts",
    riseOfIx = "Rise of Ix (unsupported)",
    epicMode = "Epic mode",
    immortality = "Immortality",
    goTo11 = "Go to 11",
    leaderSelection = "Leader selection",
    leaderPoolSize = "Leader pool size",
    defaultLeaderPoolSizeLabel = "Leader pool size ({value})",
    tweakLeaderSelection = "Tweak leader pool",
    fanmadeLeaders = "Fanmade leaders",
    variants = "Variants",
    miscellanous = "Miscellanous",
    horizontalHandLayout = "Horizontal hands layout with 4 players",
    assistedRevelation = "Assisted revelation",
    soundEnabled = "Sounds enabled",
    setup = "Setup",
    notEnoughPlayers = "Not enough players",

    -- Phases
    phaseLeaderSelection = "Phase: leader selection",
    phaseGameStart = "Phase: game start",
    phaseRoundStart = "Phase: round start",
    phasePlayerTurns = "Phase: player turns",
    phaseCombat = "Phase: combat",
    phaseCombatEnd = "Phase: combat end",
    phaseMakers = "Phase: makers",
    phaseRecall = "Phase: recall",
    phaseEndgame = "Phase: endgame",
    phaseArrakeenScouts = "Phase: Arrakeen scouts",
    endgameReached = "Theorical End of Game reached",

    -- Card
    acquireButton = "Acquire",

    -- Playboard
    noTouch = "Don't touch this button!",
    noLeader = "You don't have a leader yet!",
    noYourTurn = "It's not your turn!",
    sandwormButton = "Sandworms:\n±1",
    drawOneCardButton = "Draw 1 Card",
    drawFiveCardsButton = "❰ Draw 5 Cards ❱",
    resetDiscardButton = "Discard ➤ Deck",
    agentTurn = "Agent Turn",
    revealHandButton = "Reveal Turn",
    atomics = "Atomics",
    revealNotTurn = "You can't Reveal while it's not your turn.",
    revealEarlyConfirm = "Reveal Hand ?",
    isDecidingToDraw = "{leader} is deciding wether to draw cards right away or not cause their discard will be reshuffled.",
    warningBeforeDraw = "Warning: your discard will be reshuffled and/or you have less than {count} card(s). Do you want to draw {maxCount} card(s) right away ? (You will have to draw manually if you cancel)",
    atomicsConfirm = "Confirm",
    yes = "Yes",
    no = "No",
    dialogCardAbove = "Do you want to put the card on top of your deck ? (Ok = yes, Cancel = No)",
    endOfTurn = "End\nTurn",

    -- Leader selection
    leaderSelectionAdjust = "Adjust the number of leaders who will be randomly\nselected for the players to choose among:",
    leaderSelectionExclude = "You can flip out (or delete) any leader you want to exclude.\nOnce satisfied, hit the 'Start' button.",
    start = "Start",
    claimLeader = "Claim {leader} as leader",

    -- Resource
    spiceAmount = "Spice",
    spice = "spice unit",
    spices = "spice units",
    waterAmount = "Water",
    water = "measure of water",
    waters = "measures of water",
    solariAmount = "Solari",
    solari = "solari",
    solaris = "solaris",
    persuasionAmount = "Persuasion",
    persuasion = "Persuasion point",
    persuasions = "Persuasion points",
    strengthAmount = "Strength",
    strength = "Sword",
    strengths = "Swords",
    spendManually = "▲ {leader} spent {amount} {resource} manually.",
    receiveManually = "▼ {leader} received {amount} {resource} manually.",
    fixManually = "Fixed {amount} {resource} manually ({location})\".",
    influence = "influence",
    beetle = "beetle",
    beetles = "beetles",

    -- Actions
    playerTurn = "■ Turn: {leader}",
    drawObjects = "■ Draw {amount} {object}",
    imperiumCard = "card",
    imperiumCards = "cards",
    intrigueCard = "intrigue card",
    intrigueCards = "intrigue cards",
    beetleAdvance = "■ Progress x{count} on the Tleilax track.",
    beetleRollback = "■ Regress on the Tleilax track.",
    researchAdvance = "■ Progress on the research track.",
    researchRollback = "■ Régress on the research track.",
    credit = "■ +{amount} {what}",
    debit = "■ -{amount} {what}",
    transfer = "■ Transfer of {count} {what}: {from} ➤ {to}.",
    troop = "troop",
    troops = "troops",
    dreadnoughts = "dreadnoughts",
    supplyPark = "reserve",
    garrisonPark = "garrison",
    combatPark = "battlefield",
    negotiationPark = "tech negotiation",
    tanksPark = "Axolotl tanks",
    advanceFreighter = "■ Progress on the shipment track.",
    recallFreighter = "■ Recall freighter.",
    recruitSwordmaster = "■ Recruit Swordmaster.",
    takeHighCouncilSeat = "■ Take High-Council seat.",
    takeMakerHook = "■ Learn to use a Maker hook.",
    gainInfluence = "■ +{amount} influence with {withFaction}",
    loseInfluence = "■ -{amount} influence with {withFaction}",
    acquireTleilaxuCard = "■ Acquire Tleixlaxu card: \"{card}\"",
    acquireImperiumCard = "■ Acquire Imperium card: \"{card}\"",
    buyTechCard= "■ Acquire tech for {amount} {resource}: \"{card}\"",
    sendingAgent = "■ Sending an agent to: {space}",
    stealIntrigue = '■ Stealing "{card}" from {victim}',

    -- Combat
    announceCombat = "Round combat is: \"{combat}\"",
    dreadnoughtMandatoryOccupation = "Reminder: you must sent a dreadnought and occupy a space.",
    troopEdit = "Troops: ±1",

    -- Boards
    sendAgentTo = "Send agent to ➤ {space}",
    sendSpyTo = "Send spy",
    progressOnInfluenceTrack = "Progress on {withFaction} influence track",
    recallYourFreighter = "Recall your freighter",
    progressOnShipmentTrack = "Progress on the shipment track",
    pickBonus = "Pick your bonus: {bonus}",
    troopsAndInfluence = "troops and influnce",
    forbiddenMove = "Forbidden move. Do you confirm it neverless?",
    progressOnTleilaxTrack = "Progress on the Tleilax track",
    specimenEdit = "Specimen: ±1",
    progressOnResearchTrack = "Progress on the research track",
    progressAfterResearchTrack = "Progress beyond the research track",
    negotiatorEdit = "Negotiator: ±1",
    goGatherSupport = "Select an option.",
    noWaterOption = "Without water",
    withWaterOption = "With water",
    goSietchTabr = "Select an option.",
    hookTroopWaterOption = "Hook + Water + Troop",
    waterShieldWallOption = "Water + Atomics",
    goSpiceRefinery = "Select an option.",
    zeroSpiceOption = "0 spice unit",
    oneSpiceOption = "1 spice unit",
    makersAndRecall = "Makers + Recall",

    goDeepDesert = "Select an option.",
    fourSpicesOption = "4 spice units",
    twoWormsOption = "2 sandworm",
    goHaggaBasin = "Select an option.",
    twoSpicesOption = "2 spice units",
    onWormOption = "1 sandworm",

    goTechNegotiation = "Select an option.",
    sendNegotiatorOption = "Negotiator",
    buyTechWithDiscont1Option = "Discounted tech.",
    buyTechSelection = "Select which tech acquisition option you want to use.",
    freighterTechBuyOption = "shipment track",
    techNegotiationTechBuyOption = "Tech. negotiation",
    dreadnoughtTechBuyOption = "Dreadnought",
    appropriateTechBuyOption = "Appropriate",
    ixianEngineerTechBuyOption = "Ixian Engineer",
    machineCultureTechBuyOption = "Machine Culture",
    rhomburVerniusTechBuyOption = "Rhombur Vernius' ring",
    manuallyBuyTech = "Manually acquiring a tech at no cost?",
    notAffordableOption = "You can't afford this buying option!",
    pruneTechCard = "Pruning tech tile: \"{card}\"",

    -- Arrakeen Scouts
    joinCommittee = "Join the subcommittee: {committee}",
    appropriations = "Appropriations",
    development = "Development",
    information = "Information",
    investigation = "Investigation",
    joinForces = "Join Forces",
    politicalAffairs = "Political Affairs",
    preparation = "Preparation",
    relations = "Relations",
    supervision = "Supervision",
    dataAnalysis = "Data Analysis",
    developmentProject = "Development Project",
    tleilaxuRelations = "Tleilaxu Relations",
    committeeReminder = "You now have the opportunity to join a subcommittee this turn.",
    first = "1st",
    firstExAequo = "1st ex aequo",
    second = "2nd",
    secondExAequo = "2nd ex aequo",
    third = "3rd",
    thirdExAequo = "3rd ex aequo",
    fourth = "4th",
    fourthExAequo = "4th ex aequo",
    lose = "perdu",
    passOption = "Pass",
    waitOption = "Wait",
    refuseOption = "Refuse",
    acceptOption = "Accept",
    discardOption = "Discard",
    discardNonStarterCard = "Discard a non starter card",
    discardACard = "Discard a card",
    discardAnIntrigue = "Discard an intrigue",
    trashACard = "Trash a card",
    doAResearch = "Do a research",
    destroyACardFromYourHand = "Destroy a card from your hand",
    spendOption = "Spend {amount} {resource}",

    -- Ranking
    firstInCombat = "★ 1st: {leader}",
    firstExAequoInCombat = "★ 1st ex aequo: {leader}",
    secondInCombat = "★ 2nd: {leader}",
    secondExAequoInCombat = "★ 2nd ex aequo: {leader}",
    thirdInCombat = "★ 3rd: {leader}",
    thirdExAequoInCombat = "★ 3rd ex aequo: {leader}",
    fourthInCombat = "★ 4th: {leader}",
    fourthExAequoInCombat = "★ 4th ex aequo: {leader}",

    -- Tleilax board
    confirmSolarisToBeetles = "Do you want to pay 7 Solaris to Advance Twice on the Tleilaxu Track ?",

    -- Factions
    withEmperor = "the Emperor",
    withSpacingGuild = "the Spacing Guild",
    withBeneGesserit = "the Bene Gesserit",
    withFremen = "the Fremens",
    withGreatHouses = "the Great Houses",
    withFringeWorlds = "the Fringe Worlds",

    -- Leaders
    vladimirHarkonnen = "Baron Vladimir Harkonnen",
    glossuRabban = 'Glossu "The Beast" Rabban',
    ilbanRichese = "Count Ilban Richese",
    helenaRichese = "Helena Richese",
    letoAtreides = "Duke Leto Atreides",
    paulAtreides = "Paul Atreides",
    arianaThorvald = "Countess Ariana Thorvald",
    memnonThorvald = "Earl Memnon Thorvald",
    armandEcaz = "Archduke Armand Ecaz",
    ilesaEcaz = "Ilesa Ecaz",
    rhomburVernius = "Prince Rhombur Vernius",
    tessiaVernius = "Tessia Vernius",
    yunaMoritani = '"Princess" Yuna Moritani',
    hundroMoritani = "Viscount Hundro Moritani",

    prescienceButton = "Prescience",
    prescienceTooltip = "Look at top card of your deck easily with this.",
    prescienceUsed = "Paul Atreides used his prescience to look into the future.",
    prescienceVoid = "All you see is the void ! (Your deck it empty actually…)",
    prescienceManual = "You need to peek manually (ALT + SHIFT) because there is only one card in your deck.",

    otherMemoriesButton = "Other Memories",
    otherMemoriesTooltip = "Use your memories.",
    otherMemoriesUsed = "Lady Jessica used her memories.",

    firstSnooperRecall = "Tessia Vernius has recalled her first snooper from {withFaction}.",
    secondSnooperRecall = "Tessia Vernius has recalled her second snooper from {withFaction}.",
    thirdSnooperRecall = "Tessia Vernius has recalled her third snooper from {withFaction}.",
    fourthSnooperRecall = "Tessia Vernius has recalled her fourth snooper from {withFaction}.",
    firstSnooperRecallEffectInfo = "Having recalled your first snooper, you may discard a card to get 1 spice unit.",

    gurneyIsSmiling = "Gurney is showing his teeths.",

    imperialBirthright = "Irulan exercises his imperial birthright.",

    loyalty = "Margot reaps the rewards of her loyalty",

    -- Uprising leaders
    stabanTuek = "Staban Tuek",
    amberMetulli = "Lady Amber Metulli",
    gurneyHalleck = "Gurney Halleck",
    margotFenring = "Lady Margot Fenring",
    irulanCorrino = "Princess Irulan",
    reverendMotherJessica = "Reverend Mother Jessica",
    jessicaAtreides = "Lady Jessica",
    feydRauthaHarkonnen = "Feyd-Rautha Harkonnen",
    shaddamCorrino = "Shaddam IV",
    muadDib = "Muad'Dib",

    -- Spaces
    conspire = "Conspire",
    wealth = "Wealth",
    heighliner = "Heighliner",
    foldspace = "Foldspace",
    selectiveBreeding = "Selective Breeding",
    secrets = "Secrets",
    hardyWarriors = "Hardy Warriors",
    stillsuits = "Stillsuits",
    highCouncil = "High Council",
    mentat = "Mentat",
    swordmaster = "Swordmaster",
    rallyTroops = "Rally Troops",
    hallOfOratory = "Hall of Oratory",
    secureContract = "Secure Contract",
    arrakeen = "Arrakeen",
    carthag = "Carthag",
    researchStation = "Research Station",
    researchStationImmortality = "Research Station",
    sietchTabr = "Sietch Tabr",
    imperialBasin = "Imperial Basin",
    haggaBasin = "Hagga Basin",
    theGreatFlat = "The Great Flat",
    smuggling = "Smuggling",
    interstellarShipping = "Interstellar Shipping",
    techNegotiation = "Tech Negotiation",
    techNegotiation_1 = "Buy Tech",
    techNegotiation_2 = "Send Negotiator",
    dreadnought = "Dreadnought",

    fremkit = "Fremkit",
    desertTactics = "Desert Tactics",
    --secrets = "Secrets",
    espionage = "Espionage",
    deliverSupplies = "Deliver Supplies",
    --heighliner = "Heighliner",
    dutifulService = "Dutiful Service",
    sardaukar = "Sardaukar",
    --highCouncil = "HighCouncil",
    imperialPrivilege = "Imperial Privilege",
    --swordmaster = "Swordmaster",
    assemblyHall = "Assembly Hall",
    gatherSupport = "Gather Support",
    gatherSupport_NoWater = "Free and no water",
    gatherSupport_WithWater = "2 solaris for 1 water measure",
    shipping = "Shipping",
    acceptContract = "Accept Contract",
    --sietchTabr = "SietchTabr",
    sietchTabr_HookTroopWater = "Taking supplies",
    sietchTabr_WaterShieldWall = "Breaking the Wall",
    --researchStation = "ResearchStation",
    spiceRefinery = "Spice Refinery",
    spiceRefinery_0 = "2 solaris for no spice",
    spiceRefinery_1 = "4 solaris for 1 spice unit",
    --arrakeen = "Arrakeen",
    deepDesert = "Deep Desert",
    deepDesert_Spice = "Take the spice",
    deepDesert_WormsIfHook = "Call two sandworms",
    --haggaBasin = "HaggaBasin",
    haggaBasin_Spice = "Take the spice",
    haggaBasin_WormIfHook = "Call a sandworm",
    --imperialBasin = "ImperialBasin",
    militarySupport = "Military Support",
    economicSupport = "Economic Support",
    controversialTechnology = "controversial Technology",
    expedition = "Expedition",
    habbanyaErg = "Habbanya Erg",
    desertMastery = "Desert Mastery",
    vastWealth = "Vast Wealth",

    -- Objective cards
    --crysknife = "",
    ornithopter1to3p = "Ornithopter",
    muadDib4to6p = "Muad'Dib",
    crysknife4to6p = "Crysknife",
    muadDibFirstPlayer = "Muad'Dib (First Player)",

    -- Imperium cards
    duneTheDesertPlanet = "Dune the Desert Planet",
    seekAllies = "Seek Allies",
    signetRing = "Signet Ring",
    diplomacy = "Diplomacy",
    reconnaissance = "Reconnaissance",
    convincingArgument = "Convincing Argument",
    dagger = "Dagger",
    controlTheSpice = "Control the Spice",
    experimentation = "Experimentation",
    jessicaOfArrakis = "Jessica of Arrakis",
    sardaukarLegion = "Sardaukar Legion",
    drYueh = "Dr Yueh",
    assassinationMission = "Assassination Mission",
    sardaukarInfantry = "Sardaukar Infantry",
    beneGesseritInitiate = "Bene Gesserit Initiate",
    guildAdministrator = "Guild Administrator",
    theVoice = "The Voice",
    scout = "Scout",
    imperialSpy = "Imperial Spy",
    beneGesseritSister = "Bene Gesserit Sister",
    missionariaProtectiva = "Missionaria Protectiva",
    spiceHunter = "Spice Hunter",
    spiceSmugglers = "Spice Smugglers",
    feydakinDeathCommando = "Feydakin Death Commando",
    geneManipulation = "Gene Manipulation",
    guildBankers = "Guild Bankers",
    choamDirectorship = "CHOAM Directorship",
    crysknife = "Crysknife",
    chani = "Chani",
    spaceTravel = "Space Travel",
    duncanIdaho = "Duncan Idaho",
    shiftingAllegiances = "Shifting Allegiances",
    kwisatzHaderach = "Kwisatz Haderach",
    sietchReverendMother = "Sietch Reverend Mother",
    arrakisRecruiter = "Arrakis Recruiter",
    firmGrip = "Firm Grip",
    smugglersThopter = "Smuggler's Thopter",
    carryall = "Carryall",
    gunThopter = "Gun'Thopter",
    guildAmbassador = "Guild Ambassador",
    testOfHumanity = "Test of Humanity",
    fremenCamp = "Fremen Camp",
    opulence = "Opulence",
    ladyJessica = "Lady Jessica",
    stilgar = "Stilgar",
    piterDeVries = "Piter de Vries",
    --gurneyHalleck = "Gurney Halleck",
    thufirHawat = "Thufir Hawat",
    otherMemory = "Other Memory",
    --lietKynes = "lietKynes",
    wormRiders = "Worm Riders",
    reverendMotherMohiam = "Reverend Mother Mohiam",
    powerPlay = "Power Play",
    duncanLoyalBlade = "Duncan Loyal Blade",
    --thumper = "Thumper",
    boundlessAmbition = "Boundless Ambition",
    guildChiefAdministrator = "Guild Chief Administrator",
    guildAccord = "Guild Accord",
    localFence = "Local Fence",
    shaiHulud = "Shai Hulud",
    ixGuildCompact = "Ix-Guild Compact",
    choamDelegate = "CHOAM Delegate",
    bountyHunter = "Bounty Hunter",
    embeddedAgent = "Embedded Agent",
    --esmarTuek = "esmarTuek",
    courtIntrigue = "Court Intrigue",
    sayyadina = "Sayyadina",
    imperialShockTrooper = "Imperial Shock Trooper",
    appropriate = "Appropriate",
    desertAmbush = "Desert Ambush",
    inTheShadows = "In the Shadows",
    satelliteBan = "Satellite Ban",
    freighterFleet = "Freighter Fleet",
    imperialBashar = "Imperial Bashar",
    jamis = "Jamis",
    landingRights = "Landing Rights",
    waterPeddlersUnion = "Water Peddlers Union",
    treachery = "Treachery",
    truthsayer = "Truthsayer",
    spiceTrader = "Spice Trader",
    ixianEngineer = "Ixian Engineer",
    webOfPower = "Web of Power",
    weirdingWay = "Weirding Way",
    negotiatedWithdrawal = "Negotiated Withdrawal",
    fullScaleAssault = "Full Scale Assault",
    beneTleilaxLab = "Bene Tleilax Lab",
    beneTleilaxResearcher = "Bene Tleilax Researcher",
    blankSlate = "Blank Slate",
    clandestineMeeting = "Clandestine Meeting",
    corruptSmuggler = "Corrupt Smuggler",
    dissectingKit = "Dissecting Kit",
    forHumanity = "For Humanity",
    highPriorityTravel = "High Priority Travel",
    imperiumCeremony = "Imperium Ceremony",
    interstellarConspiracy = "Interstellar Conspiracy",
    keysToPower = "Keys to Power",
    lisanAlGaib = "Lisan Al-Gaib",
    longReach = "Long Reach",
    occupation = "Occupation",
    organMerchants = "Organ Merchants",
    plannedCoupling = "Planned Coupling",
    replacementEyes = "Replacement Eyes",
    sardaukarQuartermaster = "Sardaukar Quartermaster",
    shadoutMapes = "Shadout Mapes",
    showOfStrength = "Show of Strength",
    spiritualFervor = "Spiritual Fervor",
    stillsuitManufacturer = "Stillsuit Manufacturer",
    throneRoomPolitics = "Throne Room Politics",
    tleilaxuMaster = "Tleilaxu Master",
    tleilaxuSurgeon = "Tleilaxu Surgeon",
    --foldspace = "foldspace",
    arrakisLiaison = "Arrakis Liaison",
    theSpiceMustFlow = "The Spice must Flow",
    reclaimedForces = "Reclaimed Forces",
    piterGeniusAdvisor = "Piter Genius Advisor",
    beguilingPheromones = "Beguiling Pheromones",
    chairdog = "Chairdog",
    contaminator = "Contaminator",
    corrinoGenes = "Corrino Genes",
    faceDancer = "Face Dancer",
    faceDancerInitiate = "Face Dancer Initiate",
    fromTheTanks = "From the Tanks",
    ghola = "Ghola",
    guildImpersonator = "Guild Impersonator",
    industrialEspionage = "Industrial Espionage",
    scientificBreakthrough = "Scientific Breakthrough",
    sligFarmer = "Slig Farmer",
    stitchedHorror = "Stitched Horror",
    subjectX137 = "Subject X-137",
    tleilaxuInfiltrator = "Tleilaxu Infiltrator",
    twistedMentat = "Twisted Mentat",
    unnaturalReflexes = "Unnatural Reflexes",
    usurp = "Usurp",

    unswervingLoyalty = "Unswerving Loyalty",
    spaceTimeFolding = "Space Time Folding",
    weirdingWoman = "Weirding Woman",
    sardaukarSoldier = "Sardaukar Soldier",
    smugglerHarvester = "Smuggler Harvester",
    makerKeeper = "Maker Keeper",
    reliableInformant = "Reliable Informant",
    hiddenMissive = "Hidden Missive",
    wheelsWithinWheels = "Wheels within Wheels",
    fedaykinStilltent = "Fedaykin Stilltent",
    imperialSpymaster = "Imperial Spymaster",
    spyNetwork = "Spy Network",
    desertSurvival = "Desert Survival",
    undercoverAsset = "Undercover Asset",
    beneGesseritOperative = "Bene Gesserit Operative",
    maulaPistol = "Maula Pistol",
    thumper = "thumper",
    nothernWatermaster = "Nothern Watermaster",
    covertOperation = "Covert Operation",
    doubleAgent = "Double Agent",
    guildEnvoy = "Guild Envoy",
    rebelSupplier = "Rebel Supplier",
    calculusOfPower = "Calculus of Power",
    guildSpy = "Guild Spy",
    dangerousRhetoric = "Dangerous Rhetoric",
    branchingPath = "Branching Path",
    ecologicalTestingStation = "Ecological Testing Station",
    theBeastSpoils = "The Beast Spoils",
    smugglerHaven = "Smuggler Haven",
    shishakli = "Shishakli",
    paracompass = "Paracompass",
    sardaukarCoordination = "Sardaukar Coordination",
    truthtrance = "Truthtrance",
    publicSpectable = "Public Spectable",
    southernElders = "Southern Elders",
    treadInDarkness = "Tread in Darkness",
    spacingGuildFavor = "Spacing Guild Favor",
    capturedMentat = "Captured Mentat",
    subversiveAdvisor = "Subversive Advisor",
    leadership = "Leadership",
    inHighPlaces = "In High Places",
    strikeFleet = "Strike Fleet",
    trecherousManeuver = "Trecherous Maneuver",
    chaniCleverTactician = "Chani Clever Tactician",
    junctionHeadquarters = "Junction Headquarters",
    corrinthCity = "Corrinth City",
    stilgarTheDevoted = "Stilgar the Devoted",
    desertPower = "Desert Power",
    arrakisRevolt = "Arrakis Revolt",
    priceIsNoObject = "Price is no Object",
    longLiveTheFighters = "Long Live the Fighters",
    overthrow = "Overthrow",
    steersman = "Steersman",
    cargoRunner = "CargoRunner",
    deliveryAgreement = "Delivery Agreement",
    priorityContracts = "Priority Contracts",
    interstellarTrade = "Interstellar Trade",
    prepareTheWay = "Prepare the Way",
    theSpiceMustFlowNew  = "The Spice must Flow",

    -- Intrigue
    bribery = "Bribery",
    refocus = "Refocus",
    ambush = "Ambush",
    alliedArmada = "Allied Armada",
    favoredSubject = "Favored Subject",
    demandRespect = "Demand Respect",
    poisonSnooper = "PoisonS nooper",
    guildAuthorization = "Guild Authorization",
    dispatchAnEnvoy = "Dispatch an Envoy",
    infiltrate = "Infiltrate",
    knowTheirWays = "Know their Ways",
    masterTactician = "Master Tactician",
    plansWithinPlans = "Plans within Plans",
    privateArmy = "Private Army",
    doubleCross = "Double Cross",
    councilorsDispensation = "Councilors Dispensation",
    cornerTheMarket = "Corner the Market",
    charisma = "Charisma",
    calculatedHire = "Calculated Hire",
    choamShares = "CHOAM Shares",
    bypassProtocol = "Bypass Protocol",
    recruitmentMission = "Recruitment Mission",
    reinforcements = "Reinforcements",
    binduSuspension = "Bindu Suspension",
    secretOfTheSisterhood = "Secret of the Sisterhood",
    rapidMobilization = "Rapid Mobilization",
    stagedIncident = "Staged Incident",
    theSleeperMustAwaken = "The Sleeper must Awaken",
    tiebreaker = "Tiebreaker",
    toTheVictor = "To the Victor",
    waterPeedlersUnion = "Water Peedlers Union",
    windfall = "Windfall",
    waterOfLife = "Water of Life",
    urgentMission = "Urgent Mission",
    diversion = "Diversion",
    warChest = "WarChest",
    advancedWeaponry = "Advanced Weaponry",
    secretForces = "Secret Forces",
    grandConspiracy = "Grand Conspiracy",
    cull = "Cull",
    strategicPush = "Strategic Push",
    blackmail = "Blackmail",
    machineCulture = "Machine Culture",
    cannonTurrets = "Cannon Turrets",
    expedite = "Expedite",
    ixianProbe = "Ixian Probe",
    secondWave = "Second Wave",
    glimpseThePath = "Glimpse the Path",
    finesse = "Finesse",
    strongarm = "Strongarm",
    quidProQuo = "Quid Pro Quo",
    breakthrough = "Breakthrough",
    counterattack = "Counterattack",
    disguisedBureaucrat = "Disguised Bureaucrat",
    economicPositioning = "Economic Positioning",
    gruesomeSacrifice = "Gruesome Sacrifice",
    harvestCells = "Harvest Cells",
    illicitDealings = "Illicit Dealings",
    shadowyBargain = "Shadowy Bargain",
    studyMelange = "Study Melange",
    tleilaxuPuppet = "Tleilaxu Puppet",
    viciousTalents = "Vicious Talents",

    sietchRitual = "Sietch Ritual",
    mercenaries = "Mercenaries",
    councilorAmbition = "Councilor Ambition",
    strategicStockpiling = "Strategic Stockpiling",
    detonation = "Detonation",
    departForArrakis = "Depart for Arrakis",
    cunning = "Cunning",
    opportunism = "Opportunism",
    changeAllegiances = "Change Allegiances",
    specialMission = "Special Mission",
    unexpectedAllies = "Unexpected Allies",
    callToArms = "Call to Arms",
    buyAccess = "Buy Access",
    imperiumPolitics = "Imperium Politics",
    shaddamFavor = "Shaddam Favor",
    intelligenceReport = "Intelligence Report",
    manipulate = "Manipulate",
    distraction = "Distraction",
    marketOpportunity = "Market Opportunity",
    goToGround = "Go to Ground",
    contingencyPlan = "Contingency Plan",
    inspireAwe = "Inspire Awe",
    findWeakness = "Find Weakness",
    spiceIsPower = "Spice is Power",
    devour = "Devour",
    impress = "Impress",
    springTheTrap = "Spring the Trap",
    weirdingCombat = "Weirding Combat",
    tacticalOption = "Tactical Option",
    questionableMethods = "Questionable Methods",
    desertMouse = "Desert Mouse",
    ornithopter = "Ornithopter",
    --crysknife = "Crysknife",
    shadowAlliance = "Shadow Alliance",
    secureSpiceTrade = "Secure Spice Trade",

    -- Conflicts
    skirmishA = "Skirmish",
    skirmishB = "Skirmish",
    skirmishC = "Skirmish",
    skirmishD = "Skirmish",
    skirmishE = "Skirmish",
    skirmishF = "Skirmish",
    skirmishG = "Skirmish",
    skirmishH = "Skirmish",
    skirmishI = "Skirmish",
    --desertPower = "Desert Power",
    raidStockpiles = "Raid Stockpiles",
    cloakAndDagger = "Cloak and Dagger",
    machinations = "Machinations",
    sortThroughTheChaos = "Sort through the Chaos",
    terriblePurpose = "Terrible Purpose",
    guildBankRaid = "Guild Bank Raid",
    siegeOfArrakeen = "Siege of Arrakeen",
    siegeOfCarthag = "Siege of Carthag",
    secureImperialBasin = "Secure Imperial Basin",
    tradeMonopoly = "Trade Monopoly",
    choamSecurity = "CHOAM Security",
    spiceFreighters = "Spice Freighters",
    siegeOfArrakeenNew = "Siege of Arrakeen",
    seizeSpiceRefinery = "Seize Spice Refinery",
    testOfLoyalty = "Test of Loyalty",
    shadowContest = "Shadow Contest",
    secureImperialBasinNew = "Secure Imperial Basin",
    protectTheSietches = "Protect the Sietches",
    tradeDispute = "Trade Dispute",
    battleForImperialBasin = "Battle for Imperial Basin",
    grandVision = "Grand Vision",
    battleForCarthag = "Battle for Carthag",
    battleForArrakeen = "Battle for Arrakeen",
    economicSupremacy = "Economic Supremacy",
    propaganda = "Propaganda",
    battleForImperialBasinNew = "Battle for Imperial Basin",
    battleForArrakeenNew = "Battle for Arrakeen",
    battleForSpiceRefinery = "Battle for Spice Refinery",

    -- Techs
    spaceport = "Spaceport",
    restrictedOrdnance = "Restricted Ordnance",
    artillery = "Artillery",
    disposalFacility = "Disposal Facility",
    holoprojectors = "Holoprojectors",
    minimicFilm = "Minimic Film",
    windtraps = "Windtraps",
    detonationDevices = "Detonation Devices",
    memocorders = "Memocorders",
    flagship = "Flagship",
    shuttleFleet = "Shuttle Fleet",
    spySatellites = "Spy Satellites",
    chaumurky = "Chaumurky",
    sonicSnoopers = "Sonic Snoopers",
    trainingDrones = "Training Drones",
    troopTransports = "Troop Transports",
    holtzmanEngine = "Holtzman Engine",
    invasionShips = "Invasion Ships",

    -- Specific victory tokens
    endgameTech = "Endgame Tech",
    endgameCard = "Endgame Card",
    combat = "Combat",
    rivalIntrigue = "Rival - Intrigue",
    rivalSolari = "Rival - Solari",
    rivalWater = "Rival - Water",
    rivalSpice = "Rival - Spice",
    beneTleilax = "Bene Tleilax",
}
