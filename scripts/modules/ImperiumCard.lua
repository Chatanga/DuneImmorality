local Module = require("utils.Module")
local Helper = require("utils.Helper")

-- Exceptional Immediate require for the sake of aliasing.
local CardEffect = require("CardEffect")

local PlayBoard = Module.lazyRequire("PlayBoard")
local Types = Module.lazyRequire("Types")

-- Function aliasing for a more readable code.
local persuasion = CardEffect.persuasion
local sword = CardEffect.sword
local spice = CardEffect.spice
local water = CardEffect.water
local solari = CardEffect.solari
local deploy = CardEffect.deploy
local troop = CardEffect.troop
local dreadnought = CardEffect.dreadnought
local negotiator = CardEffect.negotiator
local specimen = CardEffect.specimen
local intrigue = CardEffect.intrigue
local trash = CardEffect.trash
local research = CardEffect.research
local beetle = CardEffect.beetle
local influence = CardEffect.influence
local vp = CardEffect.vp
local draw = CardEffect.draw
local shipment = CardEffect.shipment
local control = CardEffect.control
local spy = CardEffect.spy
local contract = CardEffect.contract
local voice = CardEffect.voice
local perDreadnoughtInConflict = CardEffect.perDreadnoughtInConflict
local perSwordCard = CardEffect.perSwordCard
local perFremen = CardEffect.perFremen
local perEmperor = CardEffect.perEmperor
local perFulfilledContract = CardEffect.perFulfilledContract
local choice = CardEffect.choice
local optional = CardEffect.optional
local seat = CardEffect.seat
local fremenBond = CardEffect.fremenBond
local agentInEmperorSpace = CardEffect.agentInEmperorSpace
local emperorAlliance = CardEffect.emperorAlliance
local spacingGuildAlliance = CardEffect.spacingGuildAlliance
local beneGesseritAlliance = CardEffect.beneGesseritAlliance
local fremenAlliance = CardEffect.fremenAlliance
local fremenFriendship = CardEffect.fremenFriendship
local anyAlliance = CardEffect.anyAlliance
local oneHelix = CardEffect.oneHelix
local twoHelices = CardEffect.twoHelices
local winner = CardEffect.winner
local twoSpies = CardEffect.twoSpies
local spyMakerSpace = CardEffect.spyMakerSpace
local swordmaster = CardEffect.swordmaster
local multiply = CardEffect.multiply

local ImperiumCard = {
    -- starter: base
    duneTheDesertPlanet = {agentIcons = {'yellow'}, reveal = {persuasion(1)}, starter = true },
    seekAllies = {agentIcons = {'emperor', 'spacingGuild', 'beneGesserit', 'fremen'}, starter = true },
    signetRing = {agentIcons = {'green', 'blue','yellow'}, reveal = {persuasion(1)}, starter = true },
    diplomacy = {agentIcons = {'emperor', 'spacingGuild', 'beneGesserit', 'fremen'}, reveal = {persuasion(1)}, starter = true },
    reconnaissance = {agentIcons = {'blue'}, reveal = {persuasion(1)}, starter = true },
    convincingArgument = {reveal = {persuasion(2)}, starter = true },
    dagger = {agentIcons = {'green', 'blue'}, reveal = {sword(1)}, starter = true},
    -- starter: ix
    controlTheSpice = {agentIcons = {'yellow'}, reveal = {persuasion(1), spice(1)}, starter = true},
    -- starter: immortality
    experimentation = {agentIcons = {'yellow'}, reveal = {persuasion(1), specimen(1)}, starter = true},
    -- reserve
    foldspace = {cost = 0, agentIcons = {'emperor', 'spacingGuild', 'beneGesserit', 'fremen', 'green', 'blue', 'yellow'}},
    prepareTheWay = {factions = {'beneGesserit'}, cost = 2, agentIcons = {'green', 'blue'}, reveal = {persuasion(2)}},
    theSpiceMustFlow  = {factions = {'spacingGuild'}, cost = 9, acquireBonus = {vp(1)}, reveal = {spice(1)}},
    -- base
    arrakisRecruiter = {cost = 2, agentIcons = {'blue'}, reveal = {persuasion(1), sword(1)}},
    assassinationMission = {cost = 1, reveal = {sword(1), solari(1)}},
    beneGesseritInitiate = {factions = {'beneGesserit'}, cost = 3, agentIcons = {'green', 'blue', 'yellow'}, reveal = {persuasion(1)}},
    beneGesseritSister = {factions = {'beneGesserit'}, cost = 3, agentIcons = {'beneGesserit', 'green'}, reveal = choice(1, {{sword(2)}, {persuasion(2)}})},
    carryall = {cost = 5, agentIcons = {'yellow'}, reveal = {persuasion(1), spice(1)}},
    chani = {factions = {'fremen'}, cost = 5, acquireBonus = {water(1)}, agentIcons = {'fremen', 'blue', 'yellow'}, reveal = {persuasion(2), 'Retreat any # of troops'}},
    choamDirectorship = {cost = 8, acquireBonus = {'4x inf all'}, reveal = {solari(3)}},
    crysknife = {factions = {'fremen'}, cost = 3, agentIcons = {'fremen', 'yellow'}, reveal = {sword(1), influence(fremenBond(1), 'fremen')}},
    drYueh = {cost = 1, agentIcons = {'blue'}, reveal = {persuasion(1)}},
    duncanIdaho = {cost = 4, agentIcons = {'blue'}, reveal = {sword(2), water(1)}},
    fedaykinDeathCommando = {factions = {'fremen'}, cost = 3, agentIcons = {'blue', 'yellow'}, reveal = {persuasion(1), sword(fremenBond(3))}},
    firmGrip = {factions = {'emperor'}, cost = 4, agentIcons = {'emperor', 'green'}, reveal = {persuasion(emperorAlliance(4))}},
    fremenCamp = {factions = {'fremen'}, cost = 4, agentIcons = {'yellow'}, reveal = {persuasion(2), sword(1)}},
    geneManipulation = {factions = {'beneGesserit'}, cost = 3, agentIcons = {'green', 'blue'}, reveal = {persuasion(2)}},
    guildAdministrator = {factions = {'spacingGuild'}, cost = 2, agentIcons = {'spacingGuild', 'yellow'}, reveal = {persuasion(1)}},
    guildAmbassador = {factions = {'spacingGuild'}, cost = 4, agentIcons = {'green'}, reveal = {spacingGuildAlliance('-3 Sp -> +1 VP')}},
    guildBankers = {factions = {'spacingGuild'}, cost = 3, agentIcons = {'emperor', 'spacingGuild', 'green'}, reveal = {'SMF costs 3 less this turn'}},
    gunThopter = {cost = 4, agentIcons = {'blue', 'yellow'}, reveal = {sword(3), 'may deploy 1x troop from garrison'}},
    gurneyHalleck = {cost = 6, agentIcons = {'blue'}, reveal = {persuasion(2), '-3 Sol -> +2 troops may deploy to conflict'}},
    imperialSpy = {factions = {'emperor'}, cost = 2, agentIcons = {'emperor'}, reveal = {persuasion(1), sword(1)}},
    kwisatzHaderach = {factions = {'beneGesserit'}, cost = 8, agentIcons = {'any'}, infiltrate = true},
    ladyJessica = {factions = {'beneGesserit'}, cost = 7, acquireBonus = {influence(1)}, agentIcons = {'beneGesserit', 'green', 'blue', 'yellow'}, reveal = {persuasion(3), sword(1)}},
    lietKynes = {factions = {'emperor', 'fremen'}, cost = 5, acquireBonus = {influence(1, 'emperor')}, agentIcons = {'fremen', 'blue'}, reveal = {persuasion(perFremen(2))}},
    missionariaProtectiva = {factions = {'beneGesserit'}, cost = 1, agentIcons = {'blue'}, reveal = {persuasion(1)}},
    otherMemory = {factions = {'beneGesserit'}, cost = 4, agentIcons = {'blue', 'yellow'}, reveal = {persuasion(2)}},
    piterDeVries = {cost = 5, agentIcons = {'green', 'blue'}, reveal = {persuasion(3), sword(1)}},
    powerPlay = {cost = 5, agentIcons = {'emperor', 'spacingGuild', 'beneGesserit', 'fremen'}},
    reverendMotherMohiam = {factions = {'emperor', 'beneGesserit'}, cost = 6, agentIcons = {'emperor', 'beneGesserit'}, reveal = {persuasion(2), spice(2)}},
    sardaukarInfantry = {factions = {'emperor'}, cost = 1, reveal = {persuasion(1), sword(2)}},
    sardaukarLegion = {factions = {'emperor'}, cost = 5, agentIcons = {'emperor', 'green'}, reveal = {persuasion(1), 'deploy up to 3 troops from garrison'}},
    scout = {cost = 1, agentIcons = {'blue', 'yellow'}, reveal = {persuasion(1), sword(1), 'Retreat up to 2 troops'}},
    shiftingAllegiances = {cost = 3, agentIcons = {'green', 'yellow'}, reveal = {persuasion(2)}},
    sietchReverendMother = {factions = {'beneGesserit', 'fremen'}, cost = 4, agentIcons = {'beneGesserit', 'fremen'}, reveal = {persuasion(fremenBond(3)), spice(1)}},
    smugglersThopter = {factions = {'spacingGuild'}, cost = 4, agentIcons = {'yellow'}, reveal = {persuasion(1), spice(1)}},
    spaceTravel = {factions = {'spacingGuild'}, cost = 3, agentIcons = {'spacingGuild'}, reveal = {persuasion(2)}},
    spiceHunter = {factions = {'fremen'}, cost = 2, agentIcons = {'fremen', 'yellow'}, reveal = {persuasion(1), sword(1), spice(fremenBond(1))}},
    spiceSmugglers = {factions = {'spacingGuild'}, cost = 2, agentIcons = {'blue'}, reveal = {persuasion(1), sword(1)}},
    stilgar = {factions = {'fremen'}, cost = 5, agentIcons = {'fremen', 'blue', 'yellow'}, reveal = {persuasion(2), sword(3)}},
    testOfHumanity = {factions = {'beneGesserit'}, cost = 3, agentIcons = {'beneGesserit', 'green', 'blue'}, reveal = {persuasion(2)}},
    theVoice = {factions = {'beneGesserit'}, cost = 2, acquireBonus = {voice()}, agentIcons = {'blue', 'yellow'}, reveal = {persuasion(2)}},
    thufirHawat = {cost = 5, agentIcons = {'emperor', 'spacingGuild', 'beneGesserit', 'fremen', 'blue', 'yellow'}, reveal = {persuasion(1), intrigue(1)}},
    wormRiders = {factions = {'fremen'}, cost = 6, agentIcons = {'blue', 'yellow'}, reveal = {sword(fremenFriendship(4)), sword(fremenAlliance(2))}},
    opulence = {factions = {'emperor'}, cost = 6, agentIcons = {'emperor'}, reveal = {persuasion(1), optional({solari(-6), vp(1)})}},
    -- ix
    appropriate = {factions = {'emperor'}, cost = 5, acquireBonus = {shipment(1)}, agentIcons = {'green', 'yellow'}, reveal = {persuasion(2)}},
    bountyHunter = {cost = 1, agentIcons = {'blue'}, infiltrate = true, reveal = {persuasion(1), sword(1)}},
    choamDelegate = {cost = 1, agentIcons = {'yellow'}, infiltrate = true, reveal = {solari(1)}},
    courtIntrigue = {factions = {'emperor'}, cost = 2, agentIcons = {'emperor'}, infiltrate = true, reveal = {persuasion(1), sword(1)}},
    desertAmbush = {factions = {'fremen'}, cost = 3, agentIcons = {'yellow'}, reveal = {persuasion(1), sword(1)}},
    embeddedAgent = {factions = {'beneGesserit'}, cost = 5, agentIcons = {'green'}, infiltrate = true, reveal = {persuasion(1), intrigue(1)}},
    esmarTuek = {factions = {'spacingGuild'}, cost = 5, agentIcons = {'blue', 'yellow'}, reveal = {spice(2), solari(2)}},
    freighterFleet = {cost = 2, agentIcons = {'yellow'}, reveal = {shipment(1)}},
    fullScaleAssault = {factions = {'emperor'}, cost = 8, acquireBonus = {dreadnought(1)}, agentIcons = {'emperor', 'blue'}, reveal = {persuasion(2), sword(perDreadnoughtInConflict(3))}},
    guildAccord = {factions = {'spacingGuild'}, cost = 6, agentIcons = {'spacingGuild'}, infiltrate = true, reveal = {water(1), spice(spacingGuildAlliance(3))}},
    guildChiefAdministrator = {factions = {'spacingGuild'}, cost = 4, agentIcons = {'spacingGuild', 'blue', 'yellow'}, reveal = {persuasion(1), shipment(1)}},
    imperialBashar = {factions = {'emperor'}, cost = 4, agentIcons = {'blue'}, reveal = {persuasion(1), sword(2), sword(perSwordCard(1, true))}},
    imperialShockTrooper = {factions = {'emperor'}, cost = 3, reveal = {persuasion(1), sword(2), sword(agentInEmperorSpace(3))}},
    inTheShadows = {factions = {'beneGesserit'}, cost = 2, agentIcons = {'green', 'blue'}, reveal = {influence(1, 'spacingGuild')}},
    ixGuildCompact = {factions = {'spacingGuild'}, cost = 3, agentIcons = {'spacingGuild'}, reveal = {negotiator(2)}},
    ixianEngineer = {cost = 5, agentIcons = {'yellow'}, reveal = {'If 3 Tech: Trash this card -> +1 VP'}},
    jamis = {factions = {'fremen'}, cost = 2, agentIcons = {'fremen'}, infiltrate = true, reveal = {persuasion(1), sword(2)}},
    landingRights = {factions = {'spacingGuild'}, cost = 4, agentIcons = {'blue'}, reveal = {persuasion(2)}},
    localFence = {cost = 3, agentIcons = {'blue'}, reveal = {persuasion(2)}},
    negotiatedWithdrawal = {cost = 4, acquireBonus = {troop(1)}, agentIcons = {'green', 'blue', 'yellow'}, reveal = {persuasion(2), 'Retreat 3x troops -> +1 inf ?'}},
    satelliteBan = {factions = {'spacingGuild', 'fremen'}, cost = 5, agentIcons = {'spacingGuild', 'fremen'}, reveal = {persuasion(1), 'Retreat up to 2 troops'}},
    sayyadina = {factions = {'beneGesserit', 'fremen'}, cost = 3, agentIcons = {'beneGesserit', 'fremen'}, reveal = {persuasion(fremenBond(3))}},
    shaiHulud = {factions = {'fremen'}, cost = 7, acquireBonus = {trash(1)}, agentIcons = {'yellow'}, reveal = {sword(fremenBond(5))}},
    spiceTrader = {factions = {'fremen'}, cost = 4, agentIcons = {'blue', 'yellow'}, reveal = {persuasion(2), sword(1)}},
    treachery = {cost = 6, agentIcons = {'emperor', 'spacingGuild', 'beneGesserit', 'fremen'}, reveal = {deploy(2)}},
    truthsayer = {factions = {'emperor', 'beneGesserit'}, cost = 3, agentIcons = {'emperor', 'beneGesserit', 'green'}, reveal = {persuasion(1), sword(1)}},
    waterPeddler = {cost = 1, acquireBonus = {water(1)}, reveal = {water(1)}},
    webOfPower = {factions = {'beneGesserit'}, cost = 4, agentIcons = {'beneGesserit'}, infiltrate = true, reveal = {persuasion(1), influence(1)}},
    weirdingWay = {factions = {'beneGesserit'}, cost = 3, agentIcons = {'blue', 'yellow'}, reveal = {persuasion(1), sword(2)}},
    -- immortality
    beneTleilaxLab = {cost = 2, agentIcons = {'blue', 'yellow'}, reveal = {persuasion(1), spice(oneHelix(1))}},
    beneTleilaxResearcher = {cost = 4, agentIcons = {'green'}, reveal = {persuasion(1), persuasion(oneHelix(1)), persuasion(twoHelices(1))}},
    blankSlate = {cost = 1, agentIcons = {'green', 'blue', 'yellow'}, reveal = {persuasion(1)}},
    clandestineMeeting = {factions = {'beneGesserit'}, cost = 4, reveal = {persuasion(2)}},
    corruptSmuggler = {factions = {'spacingGuild', 'fremen'}, cost = 3, agentIcons = {'spacingGuild', 'yellow'}, reveal = {persuasion(1), sword(1)}},
    dissectingKit = {cost = 2, agentIcons = {'green', 'blue'}, reveal = {persuasion(1), beetle(oneHelix(1))}},
    forHumanity = {factions = {'beneGesserit'}, cost = 7, agentIcons = {'beneGesserit', 'green', 'yellow'}, reveal = {persuasion(2), beneGesseritAlliance('-2 Inf --> +1 VP')}},
    highPriorityTravel = {factions = {'spacingGuild'}, cost = 1, agentIcons = {'green', 'yellow'}, reveal = {persuasion(1), solari(1)}},
    imperiumCeremony = {factions = {'emperor', 'spacingGuild'}, cost = 6, agentIcons = {'emperor', 'spacingGuild', 'green'}, reveal = {persuasion(3)}},
    interstellarConspiracy = {cost = 4, agentIcons = {'blue'}, reveal = {persuasion(2)}},
    keysToPower = {factions = {'spacingGuild', 'beneGesserit'}, cost = 5, agentIcons = {'spacingGuild', 'beneGesserit', 'green'}, reveal = {persuasion(2)}},
    lisanAlGaib = {factions = {'beneGesserit', 'fremen'}, cost = 4, acquireBonus = {spice(1)}, agentIcons = {'fremen', 'blue', 'yellow'}, reveal = {persuasion(1), sword(fremenBond(2))}},
    longReach = {factions = {'beneGesserit'}, cost = 6, reveal = {persuasion(1), intrigue(1)}},
    occupation = {factions = {'spacingGuild'}, cost = 8, acquireBonus = {troop(3)}, agentIcons = {'emperor', 'spacingGuild', 'beneGesserit', 'fremen', 'blue', 'yellow'}, reveal = {water(1), spice(1), troop(1)}},
    organMerchants = {cost = 3, agentIcons = {'blue', 'yellow'}, reveal = {persuasion(1), solari(1)}},
    plannedCoupling = {factions = {'beneGesserit'}, cost = 3, agentIcons = {'beneGesserit'}, reveal = {persuasion(1)}},
    replacementEyes = {cost = 5, agentIcons = {'blue'}, reveal = {persuasion(1), sword(1)}},
    sardaukarQuartermaster = {factions = {'emperor'}, cost = 2, agentIcons = {'green', 'blue'}, reveal = {persuasion(1), sword(2)}},
    shadoutMapes = {factions = {'fremen'}, cost = 2, agentIcons = {'fremen', 'yellow'}, reveal = {persuasion(1), sword(1), 'May deploy or retreat 1 of your Troops'}},
    showOfStrength = {factions = {'emperor', 'fremen'}, cost = 3, reveal = {persuasion(1), sword(2)}},
    spiritualFervor = {cost = 3, acquireBonus = {research(1)}, agentIcons = {'yellow'}, reveal = {persuasion(1), specimen(1)}},
    stillsuitManufacturer = {factions = {'fremen'}, cost = 5, agentIcons = {'fremen', 'blue'}, reveal = {persuasion(1), spice(fremenBond(2))}},
    throneRoomPolitics = {factions = {'emperor', 'beneGesserit'}, cost = 4, agentIcons = {'emperor'}, reveal = {persuasion(1), influence(1, 'beneGesserit')}},
    tleilaxuMaster = {cost = 5, agentIcons = {'green', 'yellow'}, reveal = {persuasion(1), research(2)}},
    tleilaxuSurgeon = {cost = 3, agentIcons = {'emperor', 'blue'}, reveal = {persuasion(2), 'Lose 2 Troops--> +2 Specimen'}},
    -- tleilaxu
    reclaimedForces = {cost = 3, tleilaxu = true, acquireBonus = choice(1, {{troop(2)}, {beetle(1)}})},
    usurp = {cost = 4, tleilaxu = true, reveal = {persuasion(1), sword(1), specimen(1)}},
    twistedMentat = {cost = 4, tleilaxu = true, agentIcons = {'green', 'blue'}, reveal = {persuasion(1), sword(1), specimen(1)}},
    beguilingPheromones = {cost = 3, tleilaxu = true, agentIcons = {'blue', 'yellow'}, reveal = {persuasion(1), sword(1)}},
    stitchedHorror = {cost = 3, tleilaxu = true, agentIcons = {'blue'}, reveal = {persuasion(1), sword(1)}},
    unnaturalReflexes = {cost = 3, tleilaxu = true, agentIcons = {'yellow'}, reveal = {persuasion(1), sword(1)}},
    ghola = {cost = 3, tleilaxu = true, agentIcons = {'blue'}, reveal = {persuasion(1), sword(1)}},
    scientificBreakthrough = {cost = 3, tleilaxu = true, agentIcons = {'green', 'blue', 'yellow'}, reveal = {persuasion(1), sword(1)}},
    sligFarmer = {cost = 2, tleilaxu = true, agentIcons = {'green'}, reveal = {persuasion(1)}},
    fromTheTanks = {cost = 2, tleilaxu = true, agentIcons = {'green'}, reveal = {persuasion(1)}},
    faceDancer = {factions = {'emperor', 'spacingGuild', 'fremen'}, cost = 2, tleilaxu = true, agentIcons = {'emperor', 'spacingGuild', 'fremen'}, reveal = {persuasion(1)}},
    guildImpersonator = {factions = {'spacingGuild'}, cost = 2, tleilaxu = true, agentIcons = {'spacingGuild'}, reveal = {persuasion(1)}},
    chairdog = {cost = 2, tleilaxu = true, agentIcons = {'blue'}, reveal = {persuasion(1)}},
    tleilaxuInfiltrator = {cost = 2, tleilaxu = true, agentIcons = {'blue'}, reveal = {persuasion(1)}},
    subjectX137 = {cost = 2, tleilaxu = true, acquireBonus = {beetle(1)}, agentIcons = {'green', 'yellow'}, reveal = {persuasion(1)}},
    corrinoGenes = {factions = {'emperor'}, cost = 1, tleilaxu = true, acquireBonus = {solari(2)}, agentIcons = {'emperor'}, reveal = {persuasion(1)}},
    contaminator = {factions = {'fremen'}, cost = 1, tleilaxu = true, agentIcons = {'fremen'}, reveal = {persuasion(1)}},
    industrialEspionage = {cost = 1, tleilaxu = true, agentIcons = {'green'}, reveal = {persuasion(1)}},
    faceDancerInitiate = {factions = {'emperor', 'spacingGuild', 'fremen'}, cost = 1, tleilaxu = true, agentIcons = {'emperor', 'spacingGuild', 'fremen'}, reveal = {persuasion(1)}},
    -- promo
    boundlessAmbition = {cost = 5, agentIcons = {'emperor', 'spacingGuild', 'beneGesserit', 'fremen'}, reveal = {'Acquire a card that costs 5 or less'}},
    duncanLoyalBlade = {cost = 5, agentIcons = {'fremen', 'blue'}, reveal = {persuasion(1), sword(2), 'trash this--> deploy/retreat any # of troops'}},
    jessicaOfArrakis = {factions = {'beneGesserit'}, cost = 3, agentIcons = {'yellow'}, reveal = {persuasion(1), sword(2)}},
    piterGeniusAdvisor = {cost = 3, tleilaxu = true, agentIcons = {'green', 'yellow'}, reveal = {persuasion(1), sword(1)}},
    -- uprising
    unswervingLoyalty = {factions = {'fremen'}, cost = 1, reveal = {persuasion(1), troop(1), 'deploy/reply 1 troop if fremen bond'}},
    spaceTimeFolding = {factions = {"spacingGuild"}, cost = 1, agentIcons = {"spacingGuild"}, reveal = {persuasion(1)}},
    weirdingWoman = {factions = {"beneGesserit"}, cost = 1, agentIcons = {'blue', 'yellow'}, reveal = {persuasion(1), sword(1)}},
    sardaukarSoldier = {factions = {"emperor"}, cost = 1, agentIcons = {'blue'}, reveal = {persuasion(1), sword(1)}},
    smugglerHarvester = {factions = {"spacingGuild"}, cost = 1, agentIcons = {'yellow'}, reveal = {persuasion(1)}},
    makerKeeper = {factions = {"beneGesserit", "fremen"}, cost = 2, agentIcons = {'blue'}, reveal = {persuasion(2)}},
    reliableInformant = {factions = {"spacingGuild"}, cost = 2, agentIcons = {"spacingGuild"}, reveal = {persuasion(1), solari(1)}},
    hiddenMissive = {factions = {"beneGesserit"}, cost = 2, agentIcons = {'green'}, reveal = {persuasion(1), sword(1)}},
    wheelsWithinWheels = {factions = {"emperor", "spacingGuild"}, cost = 2, spy = true, reveal = {persuasion(1), spy(1)}},
    fedaykinStilltent = {factions = {"fremen"}, cost = 2, agentIcons = {'yellow'}, reveal = {water(1)}},
    imperialSpymaster = {factions = {'emperor'}, cost = 2, agentIcons = {'emperor'}, spy = true, reveal = {persuasion(1), sword(1)}},
    spyNetwork = {factions = {'emperor', 'spacingGuild'}, cost = 2, acquireBonus = {spy(1)}, reveal = {persuasion(2), sword(1), 'spy --> treachery if 2 spies on board'}},
    desertSurvival = {factions = {'fremen'}, cost = 2, agentIcons = {'yellow'}, reveal = {persuasion(1), sword(1)}},
    undercoverAsset = {factions = {'emperor', 'spacingGuild'}, cost = 2, agentIcons = {'green', 'blue', 'yellow'}, reveal = choice(1, {{spy(1)}, {sword(2)}})},
    beneGesseritOperative = {factions = {'beneGesserit'}, cost = 3, agentIcons = {'beneGesserit'}, reveal = {persuasion(1), persuasion(twoSpies(2))}},
    maulaPistol = {factions = {'fremen'}, cost = 3, agentIcons = {'blue', 'yellow'}, reveal = {persuasion(1), sword(1)}},
    thumper = {factions = {'fremen'}, cost = 3, agentIcons = {'yellow'}, reveal = {persuasion(1), spice(1)}},
    nothernWatermaster = {factions = {'fremen'}, cost = 3, agentIcons = {'blue'}, reveal = {persuasion(1), spice(fremenBond(2))}},
    covertOperation = {cost = 3, spy = true, reveal = {spy(2)}},
    doubleAgent = {factions = {'emperor', 'spacingGuild'}, cost = 3, agentIcons = {'green', 'blue', 'yellow'}, reveal = {persuasion(1), sword(1)}},
    guildEnvoy = {factions = {'spacingGuild'}, cost = 3, agentIcons = {'emperor', 'spacingGuild', 'beneGesserit', 'fremen'}, reveal = {persuasion(1)}},
    rebelSupplier = {factions = {'fremen'}, cost = 3, agentIcons = {'blue'}, reveal = {spice(1), sword(1)}},
    calculusOfPower = {factions = {'emperor'}, cost = 3, spy = true, agentIcons = {'blue'}, reveal = {persuasion(2), 'trash emperor card in play --> sword(3)'}},
    guildSpy = {factions = {'spacingGuild'}, cost = 3, acquireBonus = {spy(1)}, spy = true, reveal = {persuasion(2), 'TSMF --> +1 infl / faction with agent'}},
    dangerousRhetoric = {cost = 3, spy = true, agentIcons = {'green'}, reveal = {persuasion(1), sword(1)}},
    branchingPath = {factions = {'beneGesserit'}, cost = 3, agentIcons = {'beneGesserit', "blue"}, reveal = {persuasion(2)}},
    ecologicalTestingStation = {factions = {'fremen'}, cost = 3, agentIcons = {'fremen', 'blue'}, reveal = {persuasion(1), water(fremenBond(1))}},
    theBeastSpoils = {factions = {'emperor'}, cost = 3, agentIcons = {'blue'}, reveal = {sword(3)}},
    smugglerHaven = {factions = {'spacingGuild'}, cost = 4, agentIcons = {'spacingGuild', 'yellow'}, reveal = {persuasion(1), spice(spyMakerSpace(2))}},
    shishakli = {factions = {'fremen'}, cost = 4, agentIcons = {'blue', 'yellow'}, reveal = {sword(2), influence(fremenBond(1), 'fremen')}},
    paracompass = {cost = 4, agentIcons = {'blue'}, reveal = {persuasion(seat(2)), persuasion(multiply(seat(1), swordmaster(1)))}},
    sardaukarCoordination = {factions = {'emperor'}, cost = 4, agentIcons = {'emperor', 'green'}, reveal = {persuasion(2), sword(perEmperor(1))}},
    truthtrance = {factions = {'beneGesserit'}, cost = 4, agentIcons = {'emperor', 'spacingGuild', 'beneGesserit', 'fremen'}, reveal = {persuasion(1)}},
    publicSpectable = {factions = {'emperor'}, cost = 4, spy = true, reveal = {persuasion(1), spy(1)}},
    southernElders = {factions = {'beneGesserit', 'fremen'}, cost = 4, agentIcons = {'beneGesserit', 'fremen'}, reveal = {water(1), persuasion(fremenBond(2))}},
    treadInDarkness = {factions = {'beneGesserit'}, cost = 4, agentIcons = {'green', 'blue', 'yellow'}, reveal = {persuasion(2), sword(1)}},
    spacingGuildFavor = {factions = {'spacingGuild'}, cost = 5, agentIcons = {'spacingGuild', 'yellow'}, reveal = {persuasion(2), 'spice(-3) -> influence(1)'}},
    capturedMentat = {cost = 5, agentIcons = {'green', 'yellow'}, reveal = {persuasion(1), 'influence(-1) --> influence(1)'}},
    subversiveAdvisor = {cost = 5, acquireBonus = {spy(1)}, spy = true, reveal = {persuasion(1)}},
    leadership = {factions = {'fremen'}, cost = 5, agentIcons = {'fremen', 'yellow'}, reveal = {persuasion(2), sword(1), sword(perSwordCard(1, true))}},
    inHighPlaces = {factions = {'emperor', 'beneGesserit'}, cost = 5, acquireBonus = {spy(1)}, agentIcons = {'emperor', 'beneGesserit'}, reveal = {persuasion(2), optional({spy(-2), persuasion(3)})}},
    strikeFleet = {cost = 5, acquireBonus = {spy(1)}, spy = true, reveal = {persuasion(1), sword(3)}},
    trecherousManeuver = {factions = {'emperor'}, cost = 5, agentIcons = {'emperor', 'spacingGuild', 'beneGesserit', 'fremen'}, reveal = {persuasion(1), intrigue(1)}},
    chaniCleverTactician = {factions = {'fremen'}, cost = 5, agentIcons = {'fremen', 'blue', 'yellow'}, reveal = {persuasion(fremenBond(2)), 'reply 2 troops --> sword(4)'}},
    junctionHeadquarters = {factions = {'spacingGuild'}, cost = 6, agentIcons = {'green', 'blue', 'yellow'}, reveal = {persuasion(1), water(1), troop(1)}},
    corrinthCity = {factions = {'emperor'}, cost = 6, agentIcons = {'emperor', 'green'}, reveal = {choice(1, {{solari(5)}, 'solari(-5) --> takeHighCouncilSeat(1)'})}},
    stilgarTheDevoted = {factions = {'fremen'}, cost = 6, agentIcons = {'fremen', 'blue', 'yellow'}, reveal = {persuasion(perFremen(2))}},
    desertPower = {factions = {'fremen'}, cost = 6, agentIcons = {'yellow'}, reveal = {choice(1, {{persuasion(2)}, {'hook: water(1) -> worm(1)'}})}},
    arrakisRevolt = {factions = {'fremen'}, cost = 6, acquireBonus = {troop(1)}, agentIcons = {'blue'}, reveal = {persuasion(1), sword(3)}},
    priceIsNoObject = {factions = {'emperor', 'beneGesserit'}, cost = 6, acquireBonus = {solari(2)}, agentIcons = {'emperor', 'beneGesserit'}, reveal = {persuasion(2), solari(2)}},
    longLiveTheFighters = {factions = {'fremen'}, cost = 7, agentIcons = {'fremen', 'blue'}, reveal = {persuasion(2), sword(3)}},
    overthrow = {cost = 8, acquireBonus = {intrigue(1)}, agentIcons = {'emperor', 'spacingGuild', 'beneGesserit', 'fremen'}, reveal = {persuasion(2), sword(2), troop(1)}},
    steersman = {factions = {'spacingGuild'}, cost = 8, acquireBonus = {influence(1, 'spacingGuild')}, agentIcons = {'spacingGuild', 'green', 'blue', 'yellow'}, reveal = {persuasion(2), spice(2)}},
    -- contract
    cargoRunner = {factions = {'spacingGuild'}, cost = 3, agentIcons = {'green', 'blue', 'yellow'}, reveal = {persuasion(1)}},
    deliveryAgreement = {factions = {'spacingGuild'}, cost = 5, agentIcons = {'blue'}, reveal = {choice(1, {spice(1), 'contract(4), trash --> vp(1)'})}},
    priorityContracts = {factions = {'spacingGuild'}, cost = 6, agentIcons = {'green', 'yellow'}, reveal = {choice(1, {spice(2), 'contract(4), trash --> vp(1)'})}},
    interstellarTrade = {factions = {'spacingGuild'}, cost = 7, acquireBonus = {contract(1)}, agentIcons = {'green', 'blue', 'yellow'}, reveal = {persuasion(perFulfilledContract(1))}},
    -- commander
    emperorConvincingArgument = {reveal = {persuasion(2)}},
    emperorCorrinoMight = {factions = {'emperor'}, agentIcons = {'green'}, reveal = {sword(1), 'spice(3), trash --> troop(2) / ally'}},
    emperorCriticalShipments = {agentIcons = {'yellow'}, reveal = {persuasion(1)}},
    emperorDemandResults = {factions = {'emperor'}, agentIcons = {'green'}, reveal = {sword(1)}},
    emperorDevastatingAssault = {agentIcons = {'yellow'}, reveal = {persuasion(1), 'swordmasterBonus: solari(3) --> sword(5)'}},
    emperorImperialOrnithopter = {factions = {'emperor'}, agentIcons = {'blue'}, reveal = {persuasion(1), solari(1)}},
    emperorSignetRing = {agentIcons = {'green', 'blue', 'yellow'}, reveal = {persuasion(1)}},
    emperorSeekAllies = {agentIcons = {'emperor', 'spacingGuild', 'beneGesserit', 'fremen'}},
    emperorImperialTent = {factions = {'emperor'}, agentIcons = {'emperor', 'spacingGuild', 'beneGesserit', 'fremen'}, reveal = {persuasion(1)}},
    muadDibCommandRespect = {agentIcons = {'blue'}, reveal = {persuasion(1)}},
    muadDibConvincingArgument = {reveal = {persuasion(2)}},
    muadDibDemandAttention = {agentIcons = {'emperor', 'spacingGuild', 'beneGesserit', 'fremen'}, reveal = {persuasion(1)}},
    muadDibDesertCall = {agentIcons = {'yellow'}, reveal = {persuasion(1)}},
    muadDibLimitedLandsraadAccess = {agentIcons = {'green'}, reveal = {spice(1), sword(1)}},
    muadDibSeekAllies = {agentIcons = {'emperor', 'spacingGuild', 'beneGesserit', 'fremen'}},
    muadDibUsul = {factions = {'fremen'}, agentIcons = {'blue'}, reveal = {persuasion(2)}},
    muadDibThreatenSpiceProduction = {agentIcons = {'yellow'}, reveal = {persuasion(1)}},
    muadDibSignetRing = {agentIcons = {'green', 'blue', 'yellow'}, reveal = {persuasion(1)}},
}

function ImperiumCard._resolveCard(card)
    assert(card)
    local cardName = Helper.getID(card)
    if cardName then
        local cardInfo = ImperiumCard[cardName]
        assert(cardInfo, "Unknown card (empty name usually means that the card is stacked with another): " .. tostring(cardName))
        cardInfo.name = cardName

        -- For identity tests.
        local instantiatedCardInfo = Helper.shallowCopy(cardInfo)
        instantiatedCardInfo.cardObject = card

        return instantiatedCardInfo
    else
        error("No card info!")
    end
end

function ImperiumCard.evaluateReveal(color, playedCards, revealedCards, artillery)
    return ImperiumCard.evaluateReveal2(
        color,
        Helper.mapValues(playedCards, ImperiumCard._resolveCard),
        Helper.mapValues(revealedCards, ImperiumCard._resolveCard),
        artillery)
end

-- TODO Rework this!
function ImperiumCard.evaluateReveal2(color, playedCards, revealedCards, artillery)
    local result = {}

    local context = {
        color = color,
        playedCards = playedCards,
        revealedCards = revealedCards,
        -- This mock up is enough since reveal effects only cover persuasion and strength (or other resources).
        player = {
            resources = function (_, resourceName, amount)
                result[resourceName] = (result[resourceName] or 0) + amount
            end,

            drawIntrigues = function (_, amount)
                result.intrigues = (result.intrigues or 0) + amount
            end,

            troops = function (_, from, to, amount)
                if from == "supply" then
                    if to == "garrison" then
                        result.troops = (result.troops or 0) + amount
                    elseif to == "combat" then
                        result.fighters = (result.fighters or 0) + amount
                    elseif to == "negotiation" then
                        result.negotiators = (result.negotiators or 0) + amount
                    elseif to == "tanks" then
                        result.specimens = (result.specimens or 0) + amount
                    end
                end
            end
        }
    }

    for cardName, card in ipairs(context.revealedCards) do
        if card.reveal then
            context.card = card
            context.cardName = cardName
            for _, effect in ipairs(card.reveal) do
                CardEffect.evaluate(context, effect)
            end
        end
    end

    if artillery then
        context.card = nil
        sword(perSwordCard(1))(context)
    end

    return result
end

function ImperiumCard.applyAcquireEffect(color, card)
    Types.assertIsPlayerColor(color)
    assert(card)

    local bonus = ImperiumCard._resolveCard(card).acquireBonus
    if bonus then
        local context = {
            color = color,
            player = PlayBoard.getLeader(color),
            cardName = Helper.getID(card),
            card = card,
        }

        for _, bonusItem in ipairs(bonus) do
            CardEffect.evaluate(context, bonusItem)
        end
    end
end

function ImperiumCard.getTleilaxuCardCost(card)
    local cardInfo = ImperiumCard._resolveCard(card)
    assert(cardInfo.tleilaxu)
    return cardInfo.cost
end

function ImperiumCard.isStarterCard(card)
    local cardInfo = ImperiumCard._resolveCard(card)
    return cardInfo.starter or false
end

function ImperiumCard.isFactionCard(card, faction)
    if faction then
        Types.assertIsFaction(faction)
    end
    local cardInfo = ImperiumCard._resolveCard(card)
    return cardInfo.factions and (not faction or Helper.isElementOf(faction, cardInfo.factions))
end

return ImperiumCard
