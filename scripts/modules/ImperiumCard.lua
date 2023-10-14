local Module = require("utils.Module")
local Helper = require("utils.Helper")

local Combat = Module.lazyRequire("Combat")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")
local MainBoard = Module.lazyRequire("MainBoard")
local TleilaxuResearch = Module.lazyRequire("TleilaxuResearch")


local function _evaluateEffects(card, input, output)
    for _, effect in ipairs(card.reveal) do
        if type(effect) == 'function' then
            input.card = card
            effect(input, output)
        else
            log('Ignoring manual effect: "' .. tostring(effect) .. '"')
        end
    end
end

local function _evaluate(input, value)
    if type(value) == 'function' then
        return value(input)
    else
        return value
    end
end

local function _resource(nature, value)
    return function (input, output)
        output[nature] = (output[nature] or 0) + _evaluate(input, value)
    end
end

local function persuasion(value)
    return _resource('persuasion', value)
end

local function sword(value)
    return _resource('sword', value)
end

local function spice(value)
    return _resource('spice', value)
end

local function water(value)
    return _resource('water', value)
end

local function solari(value)
    return _resource('solari', value)
end

local function troop(value)
    return _resource('troop', value)
end

local function dreadnought(value)
    return _resource('dreadnought', value)
end

local function negotiator(value)
    return _resource('negotiator', value)
end

local function specimen(value)
    return _resource('specimen', value)
end

local function intrigue(value)
    return _resource('intrigue', value)
end

local function trash(value)
    return _resource('trash', value)
end

local function shipments(value)
    return _resource('shipments', value)
end

local function research(value)
    return _resource('research', value)
end

local function beetle(value)
    return _resource('beetle', value)
end

local function influence(faction, value)
    return function (input, output)
        if not faction then
            faction = "?"
        end
        output[faction] = (output[faction] or 0) + _evaluate(input, value)
    end
end

local function perDreadnoughtInConflict(value)
    return function (input)
        return _evaluate(input, value) * Combat.getNumberOfDreadnoughtsInConflict(input.color)
    end
end

local function perSwordCard(value, cardExcluded)
    return function (input)
        if input.fake then
            return 0
        end
        local count = 0
        for _, card in ipairs(input.revealedCards) do
            if card.reveal and (not cardExcluded or card ~= input.card) then
                local pseudoInput = {
                    fake = true,
                    card = card,
                    color = input.color,
                    playedCards = {},
                    revealedCards = {card},
                }
                local output = {}
                _evaluateEffects(card, pseudoInput, output)
                if output.sword and output.sword > 0 then
                    count = count + 1
                end
            end
        end
        return _evaluate(input, value) * count
    end
end

local function fremenBond(value)
    return function (input)
        for _, card in ipairs(Helper.concatTables(input.playedCards, input.revealedCards)) do
            if card ~= input.card and card.factions and Helper.isElementOf("fremen", card.factions) then
                return _evaluate(input, value)
            else
                --log("card " .. card.name .. " is not fremen")
            end
        end
        return 0
    end
end

local function perFremen(value)
    return function (input)
        local count = 0
        for _, card in ipairs(input.revealedCards) do
            if card.factions and Helper.isElementOf("fremen", card.factions) then
                count = count + 1
            else
                --log("card " .. card.name .. " is not fremen")
            end
        end
        return _evaluate(input, value) * count
    end
end

local function agentInEmperorSpace(value)
    return function (input)
        for _, spaceName in ipairs(MainBoard.getEmperorSpaces()) do
            if MainBoard.hasAgentInSpace(spaceName, input.color) then
                return _evaluate(input, value)
            end
        end
        return 0
    end
end

local function _alliance(faction, value)
    return function (input)
        if InfluenceTrack.hasAlliance(input.color, faction) then
            return _evaluate(input, value)
        else
            --log("No alliance with the fremens.")
            return 0
        end
    end
end

local function _friendShip(faction, value)
    return function (input)
        if InfluenceTrack.hasFriendship(input.color, faction) then
            return _evaluate(input, value)
        else
            --log("No friendship with the fremens.")
            return 0
        end
    end
end

local function emperorAlliance(value)
    return _alliance("emperor", value)
end

local function spacingGuildAlliance(value)
    return _alliance("spacingGuild", value)
end

local function beneGesseritAlliance(value)
    return _alliance("beneGesserit", value)
end

local function fremenAlliance(value)
    return _alliance("fremen", value)
end

local function fremenFriendship(value)
    return _friendShip("fremen", value)
end

local function oneHelix(value)
    return function (input)
        if TleilaxuResearch.hasReachedOneHelix(input.color) then
            return _evaluate(input, value)
        else
            return 0
        end
    end
end

local function twoHelices(value)
    return function (input)
        if TleilaxuResearch.hasReachedTwoHelices(input.color) then
            return _evaluate(input, value)
        else
            return 0
        end
    end
end

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
    controlTheSpice = {agentIcons = {'yellow'}, reveal = {spice(1)}, starter = true},
    -- starter: immortality
    experimentation = {agentIcons = {'yellow'}, reveal = {persuasion(1)}, starter = true},
    -- reserve
    arrakisLiaison = {factions = {'fremen'}, cost = 2, agentsIcons = {'blue'}, reveal = {persuasion(2)}},
    foldspace = {cost = 0, agentIcons = {'emperor', 'spacingGuild', 'beneGesserit', 'fremen', 'green', 'blue', 'yellow'}},
    theSpiceMustFlow = {cost = 9, acquireBonus = {'+1 VP'}, reveal = {spice(1)}},
    -- base
    arrakisRecruiter = {cost = 2, agentIcons = {'blue'}, reveal = {persuasion(1), sword(1)}},
    assassinationMission = {cost = 1, reveal = {sword(1), solari(1)}},
    beneGesseritInitiate = {factions = {'beneGesserit'}, cost = 3, agentIcons = {'green', 'blue', 'yellow'}, reveal = {persuasion(1)}},
    beneGesseritSister = {factions = {'beneGesserit'}, cost = 3, agentIcons = {'beneGesserit', 'green'}, reveal = {'2 sword or 2 persuasion'}},
    carryall = {cost = 5, agentIcons = {'yellow'}, reveal = {persuasion(1), spice(1)}},
    chani = {factions = {'fremen'}, cost = 5, acquireBonus = {water(1)}, agentIcons = {'fremen', 'blue', 'yellow'}, reveal = {persuasion(2), 'Retreat any # of troops'}},
    choamDirectorship = {cost = 8, acquireBonus = {'4x inf all'}, reveal = {solari(1)}},
    crysknife = {factions = {'fremen'}, cost = 3, agentIcons = {'fremen', 'yellow'}, reveal = {sword(1), influence('fremen', fremenBond(1))}},
    drYueh = {cost = 1, agentIcons = {'blue'}, reveal = {persuasion(1)}},
    duncanIdaho = {cost = 4, agentIcons = {'blue'}, reveal = {sword(2), water(1)}},
    feydakinDeathCommando = {factions = {'fremen'}, cost = 3, agentIcons = {'blue', 'yellow'}, reveal = {persuasion(1), sword(fremenBond(3))}},
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
    ladyJessica = {factions = {'beneGesserit'}, cost = 7, acquireBonus = {influence(nil, 1)}, agentIcons = {'beneGesserit', 'green', 'blue', 'yellow'}, reveal = {persuasion(3), sword(1)}},
    lietKynes = {factions = {'emperor', 'fremen'}, cost = 5, acquireBonus = {influence('emperor', 1)}, agentIcons = {'fremen', 'blue'}, reveal = {persuasion(perFremen(2))}},
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
    theVoice = {factions = {'beneGesserit'}, cost = 2, agentIcons = {'blue', 'yellow'}, reveal = {persuasion(2)}},
    thufirHawat = {cost = 5, agentIcons = {'emperor', 'spacingGuild', 'beneGesserit', 'fremen', 'blue', 'yellow'}, reveal = {persuasion(1), intrigue(1)}},
    wormRiders = {factions = {'fremen'}, cost = 6, agentIcons = {'blue', 'yellow'}, reveal = {sword(fremenFriendship(4)), sword(fremenAlliance(2))}},
    -- ix
    appropriate = {factions = {'emperor'}, cost = 5, acquireBonus = {shipments(1)}, agentIcons = {'green', 'yellow'}, reveal = {persuasion(2)}},
    bountyHunter = {cost = 1, agentIcons = {'blue'}, infiltrate = true, reveal = {persuasion(1), sword(1)}},
    choamDelegate = {cost = 1, agentIcons = {'yellow'}, infiltrate = true, reveal = {solari(1)}},
    courtIntrigue = {factions = {'emperor'}, cost = 2, agentIcons = {'emperor'}, infiltrate = true, reveal = {persuasion(1), sword(1)}},
    desertAmbush = {factions = {'fremen'}, cost = 3, agentIcons = {'yellow'}, reveal = {persuasion(1), sword(1)}},
    embeddedAgent = {factions = {'beneGesserit'}, cost = 5, agentIcons = {'green'}, infiltrate = true, reveal = {persuasion(1), intrigue(1)}},
    esmarTuek = {factions = {'spacingGuild'}, cost = 5, agentIcons = {'blue', 'yellow'}, reveal = {spice(2), solari(2)}},
    freighterFleet = {cost = 2, agentIcons = {'yellow'}, reveal = {shipments(1)}},
    fullScaleAssault = {factions = {'emperor'}, cost = 8, acquireBonus = {dreadnought(1)}, agentIcons = {'emperor', 'blue'}, reveal = {persuasion(2), sword(perDreadnoughtInConflict(3))}},
    guildAccord = {factions = {'spacingGuild'}, cost = 6, agentIcons = {'spacingGuild'}, infiltrate = true, reveal = {water(1), spice(spacingGuildAlliance(3))}},
    guildChiefAdministrator = {factions = {'spacingGuild'}, cost = 4, agentIcons = {'spacingGuild', 'blue', 'yellow'}, reveal = {persuasion(1), shipments(1)}},
    imperialBashar = {factions = {'emperor'}, cost = 4, agentIcons = {'blue'}, reveal = {persuasion(1), sword(2), sword(perSwordCard(1, true))}},
    imperialShockTrooper = {factions = {'emperor'}, cost = 3, reveal = {persuasion(1), sword(2), sword(agentInEmperorSpace(3))}},
    inTheShadows = {factions = {'beneGesserit'}, cost = 2, agentIcons = {'green', 'blue'}, reveal = {influence('spacingGuild', 1)}},
    ixGuildCompact = {factions = {'spacingGuild'}, cost = 3, agentIcons = {'spacingGuild'}, reveal = {negotiator(2)}},
    ixianEngineer = {cost = 5, agentIcons = {'yellow'}, reveal = {'If 3 Tech: Trash this card -> +1 VP'}},
    jamis = {factions = {'fremen'}, cost = 2, agentIcons = {'fremen'}, infiltrate = true, reveal = {persuasion(1), sword(2)}},
    landingRights = {factions = {'spacingGuild'}, cost = 4, agentIcons = {'blue'}, reveal = {persuasion(2)}},
    localFence = {cost = 3, agentIcons = {'blue'}, reveal = {persuasion(2)}},
    negotiatedWithdrawal = {cost = 4, acquireBonus = {troop(1)}, agentIcons = {'green', 'blue', 'yellow'}, reveal = {persuasion(2), 'Retreat 3x troops - > +1 inf ?'}},
    satelliteBan = {factions = {'spacingGuild', 'fremen'}, cost = 5, agentIcons = {'spacingGuild', 'fremen'}, reveal = {persuasion(1), 'Retreat up to 2 troops'}},
    sayyadina = {factions = {'beneGesserit', 'fremen'}, cost = 3, agentIcons = {'beneGesserit', 'fremen'}, reveal = {persuasion(fremenBond(3))}},
    shaiHulud = {factions = {'fremen'}, cost = 7, acquireBonus = {trash(1)}, agentIcons = {'yellow'}, reveal = {sword(fremenBond(5))}},
    spiceTrader = {factions = {'fremen'}, cost = 4, agentIcons = {'blue', 'yellow'}, reveal = {persuasion(2), sword(1)}},
    treachery = {cost = 6, agentIcons = {'emperor', 'spacingGuild', 'beneGesserit', 'fremen'}, reveal = {'+2 troops and deploy them to conflict'}},
    truthsayer = {factions = {'emperor', 'beneGesserit'}, cost = 3, agentIcons = {'emperor', 'beneGesserit', 'green'}, reveal = {persuasion(1), sword(1)}},
    waterPeddlersUnion = {cost = 1, acquireBonus = {water(1)}, reveal = {water(1)}},
    webOfPower = {factions = {'beneGesserit'}, cost = 4, agentIcons = {'beneGesserit'}, infiltrate = true, reveal = {persuasion(1), influence(nil, 1)}},
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
    throneRoomPolitics = {factions = {'emperor', 'beneGesserit'}, cost = 4, agentIcons = {'emperor'}, reveal = {persuasion(1), influence('beneGesserit', 1)}},
    tleilaxuMaster = {cost = 5, agentIcons = {'green', 'yellow'}, reveal = {persuasion(1), research(2)}},
    tleilaxuSurgeon = {cost = 3, agentIcons = {'emperor', 'blue'}, reveal = {persuasion(2), 'Lose 2 Troops--> +2 Specimen'}},
    -- tleilaxu
    reclaimedForces = {cost = 3, tleilaxu = true, acquireBonus = {'+2 troops or Beetle'}},
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
    thumper = {factions = {'fremen'}, cost = 3, agentIcons = {'yellow'}, reveal = {persuasion(1), spice(1)}},
    piterGeniusAdvisor = {cost = 3, tleilaxu = true, agentIcons = {'green', 'yellow'}, reveal = {persuasion(1), sword(1)}},
}

function ImperiumCard._resolveCard(card)
    assert(card)
    local cardName = Helper.getID(card)
    local cardInfo = ImperiumCard[cardName]
    assert(cardInfo, "Unknown card: " .. tostring(cardName))
    cardInfo.name = cardName
    return cardInfo
end

function ImperiumCard.evaluateReveal(color, playedCards, revealedCards, artillery)
    local input = {
        color = color,
        playedCards = Helper.mapValues(playedCards, ImperiumCard._resolveCard),
        revealedCards = Helper.mapValues(revealedCards, ImperiumCard._resolveCard)
    }
    local output = {}
    for _, card in ipairs(input.revealedCards) do
        if card.reveal then
            input.card = card
            _evaluateEffects(card, input, output)
        end
    end
    if artillery then
        input.card = nil
        sword(perSwordCard(1))(input, output)
    end
    return output
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

return ImperiumCard
