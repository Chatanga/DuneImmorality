return {
    ["?"] = "?",

    Green = "vert",
    Yellow = "jaune",
    Blue = "bleu",
    Red = "rouge",

    -- Setup UI
    prolog = "« Une mise en place est toujours un moment très délicat. »",
    language = "Langue",
    players = "Joueurs",
    randomizePlayersPositions = "Mélanger les positions des joueurs",
    randomizePlayersPositionTooltip = "Aucun joueur ne doit utiliser le siège noir pendant\nque les positions des joueurs sont mélangées.",
    virtualHotSeat = "1 ou 2 joueurs",
    virtualHotSeatTooltip = "Permet de jouer en solo, à 2 joueurs ou\nbien en « hotseat » pour les autres modes.",
    firstPlayer = "Premier joueur",
    extensions = "Extensions",
    riseOfIx = "L’Avènement de Ix",
    epicMode = "Mode épique",
    immortality = "Immortalité",
    goTo11 = "Pousser jusqu’à 11",
    leaderSelection = "Sél. dirigeants",
    fanmadeLeaders = "Dirigeants fanmade",
    leaderPoolSize = "Taille de la sélection",
    defaultLeaderPoolSizeLabel = "Nombre de dirigeants ({value})",
    tweakLeaderSelection = "Personnaliser les dirigeants",
    variants = "Variantes",
    miscellanous = "Divers",
    soundEnabled = "Sons activés",
    formalCombatPhase = "Phase de combat formelle",
    formalCombatPhaseTooltip = "Les joueurs possédant une ou plusieurs cartes\nd’intrigue doivent explicitement finir leur tour\naprès en avoir joué une ou pour passer.",
    setup = "Mise en place",
    notEnoughPlayers = "Pas assez de joueurs",
    english = "English",
    french = "Français",
    random = "aléatoire",
    reversePick = "en sens inverse",
    reverseHiddenPick = "secrètement en sens inverse",
    altHiddenPick = "secrètement dans le sens 4·3·1·2",
    onePlayerTwoRivals = "1 (+2)",
    twoPlayersOneRival = "2 (+1)",
    threePlayers = "3",
    fourPlayers = "4",
    none = "Aucune",
    arrakeenScouts = "Éclaireurs d’Arrakeen",

    -- Solo Setup UI
    soloSettings = "Mode solo",
    difficulty = "Difficulté",
    all = "tous",
    novice = "mercenaire",
    veteran = "sardaukar",
    expert = "mentat",
    expertPlus = "kwisatz",
    autoTurnInSoloOption = "Passage de tour automatique pour les rivaux",
    imperiumRowChurnOption = "Barattage de la rangée de l’Imperium",
    brutalEscalationOption = "Escalade brutale",

    -- Phases
    phaseLeaderSelection = "Phase : sélection des dirigeants",
    phaseGameStart = "Phase : début du jeu",
    phaseRoundStart = "Phase : début de la manche n°{round}\n══════════════════════════════",
    phasePlayerTurns = "Phase : tours des joueurs",
    phaseCombat = "Phase : combat",
    phaseCombatEnd = "Phase : fin du combat",
    phaseMakers = "Phase : faiseurs",
    phaseRecall = "Phase : rappel",
    phaseEndgame = "Phase : fin de jeu",
    phaseArrakeenScouts = "Phase : éclaireurs d’Arrakeen",
    endgameReached = "Fin de jeu théorique atteinte",
    takeHighCouncilSeatByForce = "Prend de force",
    takeHighCouncilSeatByForceConfirm = "Prendre de force son siège au Haut-Conseil ?",

    -- Card
    acquireButton = "Acquérir",
    noEnoughSpecimen = "Vous n’avez pas assez de spécimens !",

    -- Playboards
    noTouch = "Ne touchez pas à ce bouton !",
    noLeader = "Vous n’avez pas encore de dirigeant !",
    notYourTurn = "Ce n’est pas votre tour !",
    noAgent = "Il ne vous reste plus d’agent !",
    agentAlreadyPresent = "Vous avez déjà un agent présent sur cette case !",
    noFriendship = "Vous n’avez pas assez d’influence auprès {withFaction} !",
    alreadyHaveSwordmaster = "Vous avez déjà un maître d’armes !",
    noResource = "Vous n’êtes pas assez pourvu en {resource} !",
    forbiddenAccess = "Vous n’avez pas accès à cet espace !",
    drawOneCardButton = "Piocher 1 carte",
    drawFiveCardsButton = "❰ Piocher 5 cartes ❱",
    resetDiscardButton = "Défausse ➤ pioche",
    agentTurn = "Tour d’agent",
    revealHandButton = "Révélation",
    revealHandTooltip = "Clic droit pour une révélation étendue.",
    atomics = "Atomiser",
    revealNotTurn = "Vous ne pouvez pas révéler en dehors de votre tour.",
    revealEarlyConfirm = "Révéler votre main ?",
    isDecidingToDraw = "{leader} est en train de décider de piocher des cartes tout de suite ou non car sa défausse va être remélangée.",
    warningBeforeDraw = "Attention : votre défausse va être remélangée et/ou vous avez moins de {count} carte(s). Voulez-vous piocher {maxCount} carte(s) tout de suite ? (Vous devrez piocher manuellement si vous annulez)",
    atomicsConfirm = "Confirmer",
    yes = "Oui",
    no = "Non",
    ok = "Ok",
    cancel = "Annuler",
    dialogCardAbove = "Voulez-vous mettre la carte sur le dessus de votre paquet ?",
    endTurn = "Finir\ntour",
    noSeatedPlayer = "Le joueur {color} est absent !",
    takePlace = "Piquer\nla\nplace",
    forwardMessage = "Au joueur {color} : {message}",

    -- Leader selection
    leaderSelectionAdjust = "Ajustez le nombre de dirigeants sélectionnés au hasard\nparmi lesquels les joueurs devront choisir :",
    leaderSelectionExclude = "Vous pouvez retourner (ou détruire) n’importe quel dirigeant pour l’exclure.\nUne fois satisfait, appuyez sur le bouton « Démarrer ».",
    start = "Démarrer",
    claimLeader = "Prendre {leader} comme dirigeant",
    incompatibleLeaderForRival = "Dirigeant incompatible avec un rival : {leader}",

    -- Instructions
    leaderSelectionActiveInstruction = "Sélectionnez un dirigeant\nsur le plateau supérieur.",
    leaderSelectionInactiveInstruction = "Attendez que vos adversaires\naient sélectionné leurs dirigeants.",
    playerTurnsActiveInstruction = "Envoyez un agent\nou révélez votre main,\npuis appuyez sur Fin de tour.",
    playerTurnsInactiveInstruction = "Attendez que vos adversaires\naient joué leurs tours\nd’agent / révélation.",
    combatActiveInstruction = "Jouez une intrigue et\nappuyez sur Fin de tour\nou appuyez directement\nsur Fin de tour pour passer.",
    combatInactiveInstruction = "Attendez que vos\nadversaires en combat\naient joué une intrigue\nou passé leur tour.",
    combatEndActiveInstruction = "Prenez votre butin et\njouez des cartes d’intrigue\nle cas échéant,\npuis appuyez sur Fin de tour.",
    combatEndInactiveInstruction = "Attendez que vos adversaires\naient récolté leur butin\net joué des intrigues.",
    endgameActiveInstruction = "Jouez vos cartes de fin de jeu et\ntuiles tech que vous possédez\nafin de gagner des PV finaux.",
    endgameInactiveInstruction = "Attendez que vos adversaires aient\njoué leurs cartes de fin de jeu\net tuiles tech qu’ils possèdent.",
    -- Special instructions
    gameStartActiveInstructionForVladimirHarkonnen = "Choisissez secrètement\ndeux factions.",
    gameStartInactiveInstructionForVladimirHarkonnen = "Attendez que Vladimir Harkonnen\nait secrétement choisi\nses deux factions.",
    gameStartActiveInstructionForIlesaEcaz = "Mettez de côté une carte\nde votre main.",
    gameStartInactiveInstructionForIlesaEcaz = "Attendez que Ilesa Ecaz\nait mis de côté une carte\nde sa main.",
    gameStartActiveInstructionForHundroMoritani = "Gardez une intrigue\net reposez l’autre\nau dessus du paquet d’intrigues.",
    gameStartInactiveInstructionForHundroMoritani = "Attendez que Hundro Moritani\nait choisi entre\nses deux intrigues.",

    -- Resource
    spiceAmount = "Épice",
    spice = "unité d’épice",
    spices = "unités d’épices",
    waterAmount = "Eau",
    water = "mesure d’eau",
    waters = "mesures d’eau",
    solariAmount = "Solari",
    solari = "solari",
    solaris = "solaris",
    persuasionAmount = "Persuasion",
    persuasion = "point de persuasion",
    persuasions = "points de persuasion",
    strengthAmount = "Force",
    strength = "épée",
    strengths = "épées",
    spendManually = "▲ {leader} dépense {amount} {resource} manuellement.",
    receiveManually = "▼ {leader} reçoit {amount} {resource} manuellement.",
    fixManually = "Correction de {amount} {resource} manuellement ({location}).",
    influence = "influence",
    beetle = "scarabée",
    beetles = "scarabées",
    card = "carte",
    cards = "cartes",

    -- Actions
    playerTurn = "■ Tour : {leader}",
    drawObjects = "■ Pioche de {amount} {object}",
    imperiumCard = "carte",
    imperiumCards = "cartes",
    intrigueCard = "carte d’intrigue",
    intrigueCards = "cartes d’intrigue",
    beetleAdvance = "■ Progression x{count} sur la piste du Tleilax.",
    beetleRollback = "■ Régression sur la piste du Tleilax.",
    researchAdvance = "■ Progression sur la piste de recherche.",
    researchRollback = "■ Régression sur la piste de recherche.",
    credit = "■ +{amount} {what}",
    debit = "■ -{amount} {what}",
    transfer = "■ Transfert de {count} {what} : {from} ➤ {to}.",
    troop = "troupe",
    troops = "troupes",
    dreadnoughts = "cuirassés",
    supplyPark = "réserve",
    garrisonPark = "garnison",
    combatPark = "champ de bataille",
    negotiationPark = "négotiation tech.",
    tanksPark = "cuves axolotls",
    advanceFreighter = "■ Progression sur la piste d’expédition.",
    recallFreighter = "■ Rappel de cargo.",
    takeMentat = "■ Recrutement du Mentat.",
    recruitSwordmaster = "■ Recrutement du maître d’armes.",
    takeHighCouncilSeat = "■ Prise de siège au Haut-Conseil.",
    gainInfluence = "■ +{amount} influence auprès {withFaction}.",
    loseInfluence = "■ -{amount} influence auprès {withFaction}.",
    acquireTleilaxuCard = "■ Acquisition carte tleilaxu : « {card} ».",
    acquireImperiumCard = "■ Acquisition carte Imperium : « {card} ».",
    buyTech = "■ Acquisition pour {amount} {resource} de la tech. : « {name} ».",
    sendingAgent = "■ Envoi d’un agent vers : {space} ({cards}).",
    stealIntrigues = "■ Vol de « {card} » à {victim}.",
    gainVictoryPoint = "■ Gain de PV ({name}).",

    -- Combat
    announceCombat = "Le combat de la manche est : « {combat} »",
    dreadnoughtMandatoryOccupation = "Rappel : vous devez envoyer un cuirassé occuper un espace.",
    troopEdit = "Troupes : ±1",

    -- Boards
    sendAgentTo = "Envoyer un agent vers ➤ {space}",
    progressOnInfluenceTrack = "Progresser sur la piste d’influence {withFaction}",
    recallYourFreighter = "Rappeler son cargo",
    progressOnShippingTrack = "Progresser sur la piste d’expédition",
    pickBonus = "Prendre le bonus : {bonus}",
    troopsAndInfluence = "troupes et influence",
    forbiddenMove = "Mouvement interdit. Voulez-vous quand même le réaliser ?",
    progressOnTleilaxTrack = "Progresser sur la piste du Tleilax",
    specimenEdit = "Spécimen: ±1",
    progressOnResearchTrack = "Progresser sur la piste de recheche",
    progressAfterResearchTrack = "Progresser au-delà de la piste de recherche",
    negotiatorEdit = "Négociateur: ±1",
    goSellMelange = "Selectionnez le montant en épice à convertir en solaris.",
    goTechNegotiation = "Sélectionnez une option.",
    sendNegotiatorOption = "Négociateur",
    buyTechWithDiscount1Option = "Tech. avec un rabais",
    buyTechSelection = "Selectionnez votre option d’achat de tech.",
    freighterTechBuyOption = "Piste d’expédition",
    techNegotiationTechBuyOption = "Négociation tech.",
    dreadnoughtTechBuyOption = "Cuirassé",
    appropriateTechBuyOption = "Appropriation",
    ixianEngineerTechBuyOption = "Ingénieur Ixien",
    machineCultureTechBuyOption = "Culture des machines",
    rhomburVerniusTechBuyOption = "Chevalière de Rhombur Vernius",
    manuallyBuyTech = "Acquérir manuellement une tech sans en payer le prix ?",
    notAffordableOption = "Vous n’avez pas les moyens d’utiliser cette option d’achat !",
    pruneTechCard = "Retrait de la tuile tech. : « {card} »",
    reclaimRewards = "Réclamer les récompenses",
    roundNumber = "Manche n°",
    doYouWantAnotherRound = "Jouer encore une manche ?",

    -- Arrakeen Scouts
    joinCommittee = "Rejoindre le sous-comité : {committee}",
    appropriations = "appropriations",
    development = "développement",
    information = "information",
    investigation = "investigation",
    joinForces = "forces combinées",
    politicalAffairs = "affaires politiques",
    preparation = "préparation",
    relations = "révélations",
    supervision = "supervision",
    dataAnalysis = "analyse des données",
    developmentProject = "projet de développement",
    tleilaxuRelations = "relations tleixlaxu",
    committeeReminder = "Vous avez maintenant la possibilité de rejoindre un sous-comité ce tour-ci.",
    first = "1er",
    firstExAequo = "1er ex aequo",
    second = "2nd",
    secondExAequo = "2nd ex aequo",
    third = "3ème",
    thirdExAequo = "3ème ex aequo",
    fourth = "4ème",
    fourthExAequo = "4ème ex aequo",
    lose = "perdu",
    passOption = "Passer",
    waitOption = "Attendre",
    refuseOption = "Refuser",
    acceptOption = "Accepter",
    discardOption = "Défausser",
    discardNonStarterCard = "Défausser une carte (hors cartes de départ)",
    discardACard = "Défausser une carte",
    discardAnIntrigue = "Défausser une intrigue",
    trashACard = "Détruire une carte",
    doAResearch = "Réaliser une recherche",
    destroyACardFromYourHand = "Détruire 1 carte de sa main",
    spendOption = "Dépenser {amount} {resource}",
    amount = "{amount} {resource}",

    -- Ranking
    firstInCombat = "★ 1er : {leader}",
    firstExAequoInCombat = "★ 1er ex aequo : {leader}",
    secondInCombat = "★ 2nd : {leader}",
    secondExAequoInCombat = "★ 2nd ex aequo : {leader}",
    thirdInCombat = "★ 3éme : {leader}",
    thirdExAequoInCombat = "★ 3éme ex aequo : {leader}",
    fourthInCombat = "★ 4éme : {leader}",
    fourthExAequoInCombat = "★ 4éme ex aequo : {leader}",

    -- Tleilax board
    confirmSolarisToBeetles = "Voulez-vous payer 7 solaris pour avancer deux fois sur la piste Tleilaxu ?",
    tleilaxTrack = "Piste du Tleilax",

    -- Factions
    withEmperor = "de l’Empereur",
    withSpacingGuild = "de la Guilde spatiale",
    withBeneGesserit = "du Bene Gesserit",
    withFremen = "des Fremens",

    -- Leaders
    vladimirHarkonnen = "Baron Vladimir Harkonnen",
    glossuRabban = 'Glossu « la bête » Rabban',
    ilbanRichese = "Comte Ilban Richese",
    helenaRichese = "Helena Richese",
    letoAtreides = "Duc Leto Atréides",
    paulAtreides = "Paul Atréides",
    arianaThorvald = "Comtesse Ariana Thorvald",
    memnonThorvald = "Comte Memnon Thorvald",
    armandEcaz = "Archiduc Armand Ecaz",
    ilesaEcaz = "Ilesa Ecaz",
    rhomburVernius = "Prince Rhombur Vernius",
    tessiaVernius = "Tessia Vernius",
    yunaMoritani = '« Princesse » Yuna Moritani',
    hundroMoritani = "Vicomte Hundro Moritani",
    houseHagal = "Maison Hagal",

    -- Leader abilities
    schemeTooltip = "Manigancer un sale tour de derrière les fagots",
    brutalityTooltip = "Faut r'connaître c'est du brutal",
    manufacturingTooltip = "Faire des profits",
    prescienceTooltip = "Inspecter facilement la prochaine carte de votre pioche.",
    prescienceUsed = "↯ Paul Atreides utilise sa prescience used his prescience pour entrevoir l’avenir.",
    prescienceVoid = "Difficile d’entrevoir l’avenir quand on ne voit même pas son deck correctement…",
    prescienceManual = "Vous devez inspecter manuellement votre pioche (ALT + SHIFT), car elle se résume à une unique carte.",
    disciplineTooltip = "Piocher une carte de votre pioche.",
    hiddenReservoirTooltip = "Siphonner votre réservoir caché",
    spiceHoardTooltip = "Amasser de l’épice",
    guildContactsTooltip = "Faire jouer ses contacts auprès de la Guilde",
    firstSnooperRecall = "↯ Tessia Vernius a rappelé son premier fouineur {withFaction}.",
    secondSnooperRecall = "↯ Tessia Vernius a rappelé son second fouineur {withFaction}.",
    thirdSnooperRecall = "↯ Tessia Vernius a rappelé son troisième fouineur {withFaction}.",
    fourthSnooperRecall = "↯ Tessia Vernius a rappelé son quatrième fouineur {withFaction}.",
    firstSnooperRecallEffectInfo = "Ayant rappelé votre premier fouineur, vous pouvez défausser une carte pour gagne 1 mesure d’épice.",
    finalDeliveryTooltip = "Dernière livraison.",

    -- Fanmade leaders
    ak_abulurdHarkonnen = "Abulurd Harkonnen",
    ak_xavierHarkonnen = "Xavier Harkonnen",
    ak_feydRauthaHarkonnen = "Feyd-Rautha Harkonnen",
    ak_hasimirFenring = "Comte Hasimir Fenring",
    ak_margotFenring = "Dame Margot Fenring",
    ak_lietKynes = "Dr Liet Kynes",
    ak_hwiNoree = "Hwi Noree",
    ak_metulli = "Duc Metulli",
    ak_milesTeg = "Miles Teg",
    ak_normaCenvas = "Norma Cenvas",
    ak_irulanCorrino = "Princesse Irulan",
    ak_wencisiaCorrino = "Princesse Wencisia",
    ak_vorianAtreides = "Vorian Atreides",
    ak_serenaButler = "Serena Butler",
    ak_whitmoreBluud = "Whitmore Bluud",
    ak_executrixOrdos = "Executrix",
    ak_torgTheYoung = "Torg le jeune",
    ak_twylwythWaff = "Twylwyth Waff",
    ak_scytale = "Scytale",
    ak_stabanTuek = "Staban Tuek",
    ak_esmarTuek = "Esmar Tuek",
    ak_drisk = "Drisk",
    ak_arkhane = "Arkhane",

    rt_horatioDelta = "Horatio Delta",
    rt_horatioFive = "Horatio Five",
    rt_sionaAtreides = "Siona Atreides",
    rt_almaMavisTaraza = "Alma Mavis Taraza",
    rt_dukeJenhaestraDrevMeos = "Duke Jenhaestra Drev Meos",
    rt_horatioPrime = "Horatio Prime",

    -- Spaces
    conspire = "Conspirer",
    wealth = "Richesse",
    heighliner = "Long-courrier",
    foldspace = "Replier l’espace",
    selectiveBreeding = "Sélection génétique",
    secrets = "Secrets",
    hardyWarriors = "Guerriers endurcis",
    stillsuits = "Distilles",
    highCouncil = "Haut Conseil",
    mentat = "Mentat",
    swordmaster = "Maître d’armes",
    rallyTroops = "Rallier des troupes",
    hallOfOratory = "Hall de l’oratoire",
    secureContract = "Sécuriser un contrat",
    sellMelange = "Vendre du mélange",
    sellMelange_1 = "Vendre du mélange (1)",
    sellMelange_2 = "Vendre du mélange (2)",
    sellMelange_3 = "Vendre du mélange (3)",
    sellMelange_4 = "Vendre du mélange (4)",
    arrakeen = "Arrakeen",
    carthag = "Carthag",
    researchStation = "Station de recherche",
    researchStationImmortality = "Station de recherche",
    sietchTabr = "Sietch Tabr",
    imperialBasin = "Bassin impérial",
    haggaBasin = "Bassin de Hagga",
    theGreatFlat = "La grande plaine",
    smuggling = "Contrebande",
    interstellarShipping = "Livraison interstellaire",
    techNegotiation = "Négociation tech.",
    techNegotiation_1 = "Acheter une tech.",
    techNegotiation_2 = "Envoyer un négociateur.",
    dreadnought = "Cuirassé",

    -- Imperium cards
    duneTheDesertPlanet = "Dune, la planète désertique",
    seekAllies = "À la recherche d’alliés",
    signetRing = "Chevalière",
    diplomacy = "Diplomatie",
    reconnaissance = "Reconnaissance",
    convincingArgument = "Argument convaincant",
    dagger = "Dague",
    controlTheSpice = "Contrôler l’épice",
    experimentation = "Expérimentation",
    jessicaOfArrakis = "Jessica d’Arrakis",
    sardaukarLegion = "Légion Sardaukar",
    drYueh = "Dr Yueh",
    assassinationMission = "Mission d’assassination",
    sardaukarInfantry = "Infantrie Sardaukar",
    beneGesseritInitiate = "Initiée Bene Gesserit",
    guildAdministrator = "Administrateur de la guilde",
    theVoice = "La Voix",
    scout = "Éclaireur",
    imperialSpy = "Espion impérial",
    beneGesseritSister = "Sœur du Bene Gesserit",
    missionariaProtectiva = "Missionaria Protectiva",
    spiceHunter = "Chasseur d’épice",
    spiceSmugglers = "Contrebandier d’épice",
    fedaykinDeathCommando = "Commando de la mort Fedaykin",
    geneManipulation = "Manipulation génétique",
    guildBankers = "Banquiers de la Guilde",
    choamDirectorship = "Directoire de CHOM",
    crysknife = "Krys",
    chani = "Chani",
    spaceTravel = "Voyage spatial",
    duncanIdaho = "Duncan Idaho",
    shiftingAllegiances = "Allégiances changeantes",
    kwisatzHaderach = "Kwisatz Haderach",
    sietchReverendMother = "Révérende mère de sietch",
    arrakisRecruiter = "Recruteur d’Arrakis",
    firmGrip = "Poigne de fer",
    smugglersThopter = "Orni de contrebandiers",
    carryall = "Aile portante",
    gunThopter = "Orni-mitrailleur",
    guildAmbassador = "Ambassadeur de la Guilde",
    testOfHumanity = "Test d’humanité",
    fremenCamp = "Camp fremen",
    opulence = "Opulence",
    ladyJessica = "Dame Jessica",
    stilgar = "Stilgar",
    piterDeVries = "Piter de Vries",
    gurneyHalleck = "Gurney Halleck",
    thufirHawat = "Thufir Hawat",
    otherMemory = "Mémoire seconde",
    lietKynes = "Liet Kynes",
    wormRiders = "Chevaucheurs de ver",
    reverendMotherMohiam = "Révérende mère Mohiam",
    powerPlay = "Jeu de pouvoir",
    duncanLoyalBlade = "Duncan, lame fidèle",
    boundlessAmbition = "Ambition sans limites",
    guildChiefAdministrator = "Administrateur en chef de la Guilde",
    guildAccord = "Accord de la Guilde",
    localFence = "Receleur local",
    shaiHulud = "Shai Hulud",
    ixGuildCompact = "Contrat Ix-Guild",
    choamDelegate = "Délégé de la CHOM",
    bountyHunter = "Chasseur de primes",
    embeddedAgent = "Agent infiltré",
    esmarTuek = "Esmar Tuek",
    courtIntrigue = "Intrigue de cour",
    sayyadina = "Sayyadina",
    imperialShockTrooper = "Troupe de choc impériale",
    appropriate = "Appropriation",
    desertAmbush = "Embuscade dans le désert",
    inTheShadows = "Parmi les ombres",
    satelliteBan = "Ban satellitaire",
    freighterFleet = "Flotte de cargos",
    imperialBashar = "Bashar impérial",
    jamis = "Jamis",
    landingRights = "Droits d’atterrissage",
    waterPeddler = "Porteuse d’eau",
    treachery = "Trahison",
    truthsayer = "Diseuse de vérité",
    spiceTrader = "Vendeur d’épice",
    ixianEngineer = "Ingénieurs ixiens",
    webOfPower = "Toile du pouvoir",
    weirdingWay = "Art étrange",
    negotiatedWithdrawal = "Retait négocié",
    fullScaleAssault = "Assaut planétaire",
    beneTleilaxLab = "Laboratoire du Bene Tleilax",
    beneTleilaxResearcher = "Chercheur du Bene Tleilax",
    blankSlate = "Ardoise vierge",
    clandestineMeeting = "Réunion clandestine",
    corruptSmuggler = "Contrebandier corrompu",
    dissectingKit = "Kit de dissection",
    forHumanity = "Pour l’Humanité",
    highPriorityTravel = "Voyage en haute priorité",
    imperiumCeremony = "Cérémonie de l’Imperium",
    interstellarConspiracy = "Conspiration interstellaire",
    keysToPower = "Les clefs du pouvoir",
    lisanAlGaib = "Lisan Al-Gaib",
    longReach = "Bras long",
    occupation = "Occupation",
    organMerchants = "Marchands d’organes",
    plannedCoupling = "Mariage arrangé",
    replacementEyes = "Yeux de rechange",
    sardaukarQuartermaster = "Quartier-maître Sardaukar",
    shadoutMapes = "Shadout Mapes",
    showOfStrength = "Démonstration de force",
    spiritualFervor = "Ferveur spirituel",
    stillsuitManufacturer = "Fabricant de distilles",
    throneRoomPolitics = "Réunion du conseil",
    tleilaxuMaster = "Maître tleilaxu",
    tleilaxuSurgeon = "Chirurgien tleilaxu",
    --foldspace = "Espace plissé",
    arrakisLiaison = "Contact d’Arrakis",
    theSpiceMustFlow = "L’épice doit couler",
    reclaimedForces = "Forces reconquises",
    piterGeniusAdvisor = "Piter, conseiller de génie",
    beguilingPheromones = "Phéromones ensorcelantes",
    chairdog = "Canisiège",
    contaminator = "Contaminateur",
    corrinoGenes = "Gènes Corrino",
    faceDancer = "Danseur-visage",
    faceDancerInitiate = "Initié danseur visage",
    fromTheTanks = "Né des cuves",
    ghola = "Ghola",
    guildImpersonator = "Imposteur de la Guilde",
    industrialEspionage = "Espionnage industriel",
    scientificBreakthrough = "Percée scientifique",
    sligFarmer = "Éleveur de limachons",
    stitchedHorror = "Amalgame horrifique",
    subjectX137 = "Sujet X-137",
    tleilaxuInfiltrator = "Infiltrateur tleilaxu",
    twistedMentat = "Mentat « tordu »",
    unnaturalReflexes = "Réflexes anormaux",
    usurp = "Usurper",

    -- Intrigue
    bribery = "Pot-de-vin",
    refocus = "recentrage",
    ambush = "Embuscade",
    alliedArmada = "Armada alliée",
    favoredSubject = "Sujet favori",
    demandRespect = "Demander le respect",
    poisonSnooper = "Goûte-poison",
    guildAuthorization = "Autorisation de la Guilde",
    dispatchAnEnvoy = "Dépêcher un envoyé",
    infiltrate = "Infiltrer",
    knowTheirWays = "Connaître leurs coutumes",
    masterTactician = "Maître tacticien",
    plansWithinPlans = "Des plans dans des plans",
    privateArmy = "Armée privée",
    doubleCross = "Trahison",
    councilorsDispensation = "Dispense des conseillers",
    cornerTheMarket = "Accaparer le marché",
    charisma = "Charisme",
    calculatedHire = "Recrutement calculé",
    choamShares = "Part de la CHOM",
    bypassProtocol = "Contourner les procédures",
    recruitmentMission = "Mission de recrutement",
    reinforcements = "Renforts",
    binduSuspension = "Suspension bindu",
    secretOfTheSisterhood = "Secret de la sororité",
    rapidMobilization = "Mobilisation éclair",
    stagedIncident = "Incident mise en scène",
    theSleeperMustAwaken = "Le dormeur doit se réveiller",
    tiebreaker = "tir au but",
    toTheVictor = "Au vainqueur",
    waterPeddlersUnion = "Syndicat des porteurs d’eau",
    windfall = "Aubaine",
    waterOfLife = "Eau de la vie",
    urgentMission = "Mission urgente",
    diversion = "Diversion",
    warChest = "Butin de guerre",
    advancedWeaponry = "Armement avancé",
    secretForces = "Forces secrètes",
    grandConspiracy = "Grande conspiration",
    cull = "Élimination",
    strategicPush = "Poussée stratégique",
    blackmail = "Chantage",
    machineCulture = "Culte de la machine",
    cannonTurrets = "Tourelles de canons",
    expedite = "Accélérer",
    ixianProbe = "Sonde ixienne",
    secondWave = "Second vague",
    glimpseThePath = "Entrevoir le chemin",
    finesse = "Finesse",
    strongarm = "Rapport de force",
    quidProQuo = "Quid Pro Quo",
    breakthrough = "Percée",
    counterattack = "Contre attaque",
    disguisedBureaucrat = "Déguisement de bureaucrate",
    economicPositioning = "Positionnement économique",
    gruesomeSacrifice = "Sacrifice sanglant",
    harvestCells = "Prélèvement de cellules",
    illicitDealings = "Transactions illicites",
    shadowyBargain = "Combine foireuse",
    studyMelange = "Étudier le mélange",
    tleilaxuPuppet = "Marionnette tleilaxu",
    viciousTalents = "Talents vicieux",

    -- Conflicts
    skirmishA = "Escarmouche",
    skirmishB = "Escarmouche",
    skirmishC = "Escarmouche",
    skirmishD = "Escarmouche",
    skirmishE = "Escarmouche",
    skirmishF = "Escarmouche",
    desertPower = "La puissance du désert",
    raidStockpiles = "Piller les stocks",
    cloakAndDagger = "De cap et d’épée",
    machinations = "Machinations",
    sortThroughTheChaos = "Tirer les marrons du feu",
    terriblePurpose = "But terrifiant",
    guildBankRaid = "Ocean 11",
    siegeOfArrakeen = "Siège d’Arrakeen",
    siegeOfCarthag = "Siège de Carthag",
    secureImperialBasin = "Sécuriser le bassin impérial",
    tradeMonopoly = "Monopole du commerce",
    battleForImperialBasin = "Bataille pour le bassin impérial",
    grandVision = "Vision grandiose",
    battleForCarthag = "Bataille pour Carthag",
    battleForArrakeen = "Bataille pour Arrakeen",
    economicSupremacy = "Suprémacie économique",

    -- Techs
    spaceport = "Spatioport",
    restrictedOrdnance = "Ordonnance restrictive",
    artillery = "Artillerie",
    disposalFacility = "Installation d’élimination",
    holoprojectors = "Holoprojecteurs",
    minimicFilm = "Film Minimic",
    windtraps = "Pièges à vent",
    detonationDevices = "Engins de détonation",
    memocorders = "Memocorders",
    flagship = "Navire amiral",
    shuttleFleet = "Flotte de navettes",
    spySatellites = "Satellites espions",
    chaumurky = "Chaumurky",
    sonicSnoopers = "Fouineurs soniques",
    trainingDrones = "Drones d’entraînement",
    troopTransports = "Transports de troupes",
    holtzmanEngine = "Moteur Holtzman",
    invasionShips = "Vaisseaux d’invasion",

    -- Specific victory tokens
    emperorFriendship = "Amitié avec l’Empereur",
    emperorAlliance = "Alliance avec l’Empereur",
    spacingGuildFriendship = "Amitié avec la Guilde spatiale",
    spacingGuildAlliance = "Alliance avec la Guilde spatiale",
    beneGesseritFriendship = "Amitié avec le Bene Gesserit",
    beneGesseritAlliance = "Alliance le Bene Gesserit",
    fremenFriendship = "Amitié avec les Fremens",
    fremenAlliance = "Alliance avec les Fremens",
    endgameTech = "Tech. de fin de partie",
    endgameCard = "Carte de fin de partie",
    combat = "Combat",
    rivalIntrigue = "Rival - Intrigue",
    rivalSolari = "Rival - Solari",
    rivalWater = "Rival - Eau",
    rivalSpice = "Rival - Épice",
    beneTleilax = "Bene Tleilax",

    -- Hagal cards
    harvestSpice = "Récolter l’épice",
    arrakeen1p = "Arrakeen 1J",
    arrakeen2p = "Arrakeen 2J",
    foldspaceAndInterstellarShipping = "Replier l’espace et Livraison interstellaire",
    smugglingAndInterstellarShipping = "Contrebande et Livraison interstellaire",
    dreadnought1p = "Cuirasser 1J",
    dreadnought2p = "Cuirasser 2J",
    carthag1 = "Carthag 1",
    carthag2 = "Carthag 2",
    carthag3 = "Carthag 3",

    -- Hagal
    reshuffle = "Rémélanger",
    churnImperiumRow = "Barattage de la rangée de l’Imperium ({count} {card})",
    brutalEscalation = "↯ Escalade brutale !",
    expertDeploymentLimit = "↯ Limitation du déploiement de forces à {limit}.",
}
