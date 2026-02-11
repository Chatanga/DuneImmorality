local Module = require("utils.Module")
local Helper = require("utils.Helper")

-- Exceptional Immediate require for the sake of aliasing.
local CardEffect = require("CardEffect")

local PlayBoard = Module.lazyRequire("PlayBoard")
local Types = Module.lazyRequire("Types")

-- Function aliasing for a more readable code.
local todo = CardEffect.todo
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
local shipment = CardEffect.shipment
local voice = CardEffect.voice
local perDreadnoughtInConflict = CardEffect.perDreadnoughtInConflict
local perSwordCard = CardEffect.perSwordCard
local perFremen = CardEffect.perFremen
local choice = CardEffect.choice
local optional = CardEffect.optional
local fremenBond = CardEffect.fremenBond
local agentInEmperorSpace = CardEffect.agentInEmperorSpace
local emperorAlliance = CardEffect.emperorAlliance
local spacingGuildAlliance = CardEffect.spacingGuildAlliance
local beneGesseritAlliance = CardEffect.beneGesseritAlliance
local fremenAlliance = CardEffect.fremenAlliance
local fremenFriendship = CardEffect.fremenFriendship
local oneHelix = CardEffect.oneHelix
local twoHelices = CardEffect.twoHelices
local hasSardaukarCommanderInConflict = CardEffect.hasSardaukarCommanderInConflict
local command = CardEffect.command
local garrisonQuad = CardEffect.garrisonQuad
local twoTechs = CardEffect.twoTechs

---@alias RevealContribution {
--- solari: integer,
--- spice: integer,
--- water: integer,
--- intrigue: integer,
--- troops: integer,
--- fighters: integer,
--- negotiators: integer,
--- specimens: integer }

---@class ImperiumCardInfo: CardInfo
---@field factions Faction[]
---@field cost integer
---@field acquireBonus CardEffect[]
---@field agentIcons AgentIcon[]
---@field reveal CardEffect[]
---@field tleilaxu boolean
---@field starter boolean

-- Note: the 'agentIcons' field is not used today.
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
    arrakisLiaison = {factions = {'fremen'}, cost = 2, agentIcons = {'blue'}, reveal = {persuasion(2)}},
    foldspace = {cost = 0, agentIcons = {'emperor', 'spacingGuild', 'beneGesserit', 'fremen', 'green', 'blue', 'yellow'}},
    theSpiceMustFlow = {cost = 9, acquireBonus = {vp(1)}, reveal = {spice(1)}},
    -- base
    arrakisRecruiter = {cost = 2, agentIcons = {'blue'}, reveal = {persuasion(1), sword(1)}},
    assassinationMission = {cost = 1, reveal = {sword(1), solari(1)}},
    beneGesseritInitiate = {factions = {'beneGesserit'}, cost = 3, agentIcons = {'green', 'blue', 'yellow'}, reveal = {persuasion(1)}},
    beneGesseritSister = {factions = {'beneGesserit'}, cost = 3, agentIcons = {'beneGesserit', 'green'}, reveal = choice(1, {{sword(2)}, {persuasion(2)}})},
    carryall = {cost = 5, agentIcons = {'yellow'}, reveal = {persuasion(1), spice(1)}},
    chani = {factions = {'fremen'}, cost = 5, acquireBonus = {water(1)}, agentIcons = {'fremen', 'blue', 'yellow'}, reveal = {persuasion(2), todo('Retreat any # of troops')}},
    choamDirectorship = {cost = 8, acquireBonus = {'4x inf all'}, reveal = {solari(3)}},
    crysknife = {factions = {'fremen'}, cost = 3, agentIcons = {'fremen', 'yellow'}, reveal = {sword(1), influence(fremenBond(1), 'fremen')}},
    drYueh = {cost = 1, agentIcons = {'blue'}, reveal = {persuasion(1)}},
    duncanIdaho = {cost = 4, agentIcons = {'blue'}, reveal = {sword(2), water(1)}},
    fedaykinDeathCommando = {factions = {'fremen'}, cost = 3, agentIcons = {'blue', 'yellow'}, reveal = {persuasion(1), sword(fremenBond(3))}},
    firmGrip = {factions = {'emperor'}, cost = 4, agentIcons = {'emperor', 'green'}, reveal = {persuasion(emperorAlliance(4))}},
    fremenCamp = {factions = {'fremen'}, cost = 4, agentIcons = {'yellow'}, reveal = {persuasion(2), sword(1)}},
    geneManipulation = {factions = {'beneGesserit'}, cost = 3, agentIcons = {'green', 'blue'}, reveal = {persuasion(2)}},
    guildAdministrator = {factions = {'spacingGuild'}, cost = 2, agentIcons = {'spacingGuild', 'yellow'}, reveal = {persuasion(1)}},
    guildAmbassador = {factions = {'spacingGuild'}, cost = 4, agentIcons = {'green'}, reveal = {spacingGuildAlliance(todo('-3 Sp -> +1 VP'))}},
    guildBankers = {factions = {'spacingGuild'}, cost = 3, agentIcons = {'emperor', 'spacingGuild', 'green'}, reveal = {todo('SMF costs 3 less this turn')}},
    gunThopter = {cost = 4, agentIcons = {'blue', 'yellow'}, reveal = {sword(3), todo('may deploy 1x troop from garrison')}},
    gurneyHalleck = {cost = 6, agentIcons = {'blue'}, reveal = {persuasion(2), todo('-3 Sol -> +2 troops may deploy to conflict')}},
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
    sardaukarLegion = {factions = {'emperor'}, cost = 5, agentIcons = {'emperor', 'green'}, reveal = {persuasion(1), todo('deploy up to 3 troops from garrison')}},
    scout = {cost = 1, agentIcons = {'blue', 'yellow'}, reveal = {persuasion(1), sword(1), todo('Retreat up to 2 troops')}},
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
    choamDelegate = {cost = 1, agentIcons = {'yellow'}, infiltrate = true, reveal = {solari(3)}},
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
    ixianEngineer = {cost = 5, agentIcons = {'yellow'}, reveal = {todo('If 3 Tech: Trash this card -> +1 VP')}},
    jamis = {factions = {'fremen'}, cost = 2, agentIcons = {'fremen'}, infiltrate = true, reveal = {persuasion(1), sword(2)}},
    landingRights = {factions = {'spacingGuild'}, cost = 4, agentIcons = {'blue'}, reveal = {persuasion(2)}},
    localFence = {cost = 3, agentIcons = {'blue'}, reveal = {persuasion(2)}},
    negotiatedWithdrawal = {cost = 4, acquireBonus = {troop(1)}, agentIcons = {'green', 'blue', 'yellow'}, reveal = {persuasion(2), todo('Retreat 3x troops -> +1 inf ?')}},
    satelliteBan = {factions = {'spacingGuild', 'fremen'}, cost = 5, agentIcons = {'spacingGuild', 'fremen'}, reveal = {persuasion(1), todo('Retreat up to 2 troops')}},
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
    forHumanity = {factions = {'beneGesserit'}, cost = 7, agentIcons = {'beneGesserit', 'green', 'yellow'}, reveal = {persuasion(2), beneGesseritAlliance(todo('-2 Inf --> +1 VP'))}},
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
    shadoutMapes = {factions = {'fremen'}, cost = 2, agentIcons = {'fremen', 'yellow'}, reveal = {persuasion(1), sword(1), todo('May deploy or retreat 1 of your Troops')}},
    showOfStrength = {factions = {'emperor', 'fremen'}, cost = 3, reveal = {persuasion(1), sword(2)}},
    spiritualFervor = {cost = 3, acquireBonus = {research(1)}, agentIcons = {'yellow'}, reveal = {persuasion(1), specimen(1)}},
    stillsuitManufacturer = {factions = {'fremen'}, cost = 5, agentIcons = {'fremen', 'blue'}, reveal = {persuasion(1), spice(fremenBond(2))}},
    throneRoomPolitics = {factions = {'emperor', 'beneGesserit'}, cost = 4, agentIcons = {'emperor'}, reveal = {persuasion(1), influence(1, 'beneGesserit')}},
    tleilaxuMaster = {cost = 5, agentIcons = {'green', 'yellow'}, reveal = {persuasion(1), research(2)}},
    tleilaxuSurgeon = {cost = 3, agentIcons = {'emperor', 'blue'}, reveal = {persuasion(2), todo('Lose 2 Troops--> +2 Specimen')}},
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
    boundlessAmbition = {cost = 5, agentIcons = {'emperor', 'spacingGuild', 'beneGesserit', 'fremen'}, reveal = {todo('Acquire a card that costs 5 or less')}},
    duncanLoyalBlade = {cost = 5, agentIcons = {'fremen', 'blue'}, reveal = {persuasion(1), sword(2), todo('trash this --> deploy/retreat any # of troops')}},
    jessicaOfArrakis = {factions = {'beneGesserit'}, cost = 3, agentIcons = {'yellow'}, reveal = {persuasion(1), sword(2)}},
    piterGeniusAdvisor = {cost = 3, tleilaxu = true, agentIcons = {'green', 'yellow'}, reveal = {persuasion(1), sword(1)}},
    -- bloodlines
    bombast = {factions = {'emperor'}, agentIcons = {'green'}, cost = 1, reveal = {persuasion(1), solari(command(3))}}, -- TODO command => trash
    sandwalk = {factions = {'fremen'}, agentIcons = {'yellow'}, cost = 1, reveal = {persuasion(1), sword(1), persuasion(fremenBond(1))}},
    disruptionTactics = {factions = {'fremen'}, agentIcons = {'fremen', 'yellow'}, cost = 2, reveal = {persuasion(1), todo('trash --> combat(true)')}},
    urgentShigawire = {factions = {'beneGesserit'}, agentIcons = {'beneGesserit', 'blue'}, cost = 2, reveal = {persuasion(1)}},
    commandCenter = {factions = {'emperor'}, agentIcons = {'emperor', 'blue'}, cost = 3, reveal = {persuasion(1), todo('retreat(2) --> persuasion(2)')}},
    engineeredMiracle = {factions = {'beneGesserit'}, agentIcons = {'fremen', 'yellow'}, cost = 3, reveal = {persuasion(1), todo('command --> (trash --> acquire card)')}},
    iBelieve = {factions = {'fremen'}, agentIcons = {'fremen', 'blue'}, cost = 3, reveal = {persuasion(1), troop(command(2))}},
    litanyAgainstFear = {factions = {'beneGesserit'}, cost = 3, reveal = {persuasion(2)}},
    eliteForces = {factions = {'emperor', 'spacingGuild'}, agentIcons = {'emperor', 'spacingGuild'}, cost = 3, reveal = {persuasion(1), sword(1)}},
    fremenWarName = {factions = {'fremen'}, agentIcons = {'fremen', 'yellow'}, cost = 4, reveal = {persuasion(2), sword(fremenBond(2))}},
    sardaukarStandard = {factions = {'emperor'}, agentIcons = {'emperor', 'blue'}, cost = 4, reveal = {persuasion(2), troop(2)}},
    quashRebellion = {factions = {'emperor'}, agentIcons = {'emperor', 'spacingGuild', 'green'}, cost = 5, reveal = {sword(2), persuasion(hasSardaukarCommanderInConflict(2))}},
    southernFaith = {factions = {'beneGesserit', 'fremen'}, agentIcons = {'fremen', 'blue'}, cost = 5, reveal = {persuasion(1), sword(2), spice(command(2))}},
    imperialThroneship = {factions = {'emperor'}, agentIcons = {'emperor', 'spacingGuild', 'beneGesserit', 'fremen', 'green', 'blue', 'yellow'}, cost = 7, acquireBonus = {influence(1, 'emperor')}, reveal = {persuasion(2), persuasion(garrisonQuad(1)), solari(garrisonQuad(3))}},
    possibleFutures = {factions = {'beneGesserit', 'fremen'}, agentIcons = {'green', 'blue', 'yellow'}, cost = 8, acquireBonus = {water(1)}, reveal = {persuasion(2), water(1)}},
    ixianAmbassador = {factions = {'spacingGuild'}, cost = 4, reveal = {persuasion(1), influence(twoTechs(1))}},
    ruthlessLeadership = {factions = {'emperor'}, agentIcons = {'blue', 'yellow'}, cost = 4, reveal = {persuasion(1), sword(1), todo('combat(command(true))')}},
    pivotalGambit = {factions = {'fremen'}, agentIcons = {'fremen', 'blue'}, cost = 3, reveal = {persuasion(1), sword(2), todo('trash this --> troop + influnce at 1st place in conflict')}},
}

---@param card Card
---@return ImperiumCardInfo
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

---@param color PlayerColor
---@param playedCards Card[]
---@param revealedCards Card[]
---@return table<string, integer>
function ImperiumCard.evaluateReveal(color, playedCards, revealedCards)
    return ImperiumCard.evaluateRevealDirectly(
        1,
        color,
        Helper.mapValues(playedCards, ImperiumCard._resolveCard),
        Helper.mapValues(revealedCards, ImperiumCard._resolveCard))
end

---@param depth integer
---@param color PlayerColor
---@param playedCards ImperiumCardInfo[]
---@param revealedCards ImperiumCardInfo[]
---@return RevealContribution
function ImperiumCard.evaluateRevealDirectly(depth, color, playedCards, revealedCards)
    local result = {}

    local context = {
        depth = depth,
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

    for cardName, card in pairs(context.revealedCards) do
        if card.reveal then
            context.card = card
            context.cardName = cardName
            for _, effect in ipairs(card.reveal) do
                CardEffect.evaluate(context, effect)
            end
        end
    end

    return result
end

---@param color PlayerColor
---@param card Card
function ImperiumCard.applyAcquireEffect(color, card)
    assert(Types.isPlayerColor(color))
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

---@param card Card
---@return integer
function ImperiumCard.getTleilaxuCardCost(card)
    local cardInfo = ImperiumCard._resolveCard(card)
    assert(cardInfo.tleilaxu)
    return cardInfo.cost
end

---@param card Card
---@return boolean
function ImperiumCard.isStarterCard(card)
    local cardInfo = ImperiumCard._resolveCard(card)
    return cardInfo.starter or false
end

---@param card Card
---@return boolean
function ImperiumCard.isFactionCard(card, faction)
    if faction then
        assert(Types.isFaction(faction))
    end
    local cardInfo = ImperiumCard._resolveCard(card)
    return cardInfo.factions and (not faction or Helper.isElementOf(faction, cardInfo.factions))
end

return ImperiumCard
