local Module = require("utils.Module")
local Helper = require("utils.Helper")

local InfluenceTrack = Module.lazyRequire("InfluenceTrack")

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

local function specimen(value)
    return _resource('specimen', value)
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

local function anyAlliance(value)
    return emperorAlliance(value)
        or spacingGuildAlliance(value)
        or beneGesseritAlliance(value)
        or fremenAlliance(value)
end

local function winner(value)
    return function ()
        error("TODO")
        return value
    end
end

local IntrigueCard = {
    -- base
    masterTactician = {categories = {'combat'}, combat = {"+3 swords or retreat up to 3 troops"}},
    ambush = {categories = {'combat'}, combat = {sword(4)} },
    privateArmy = {categories = {'combat'}, combat = {"-2 Sp -> +5 Swords"}},
    stagedIncident = {categories = {'combat'}, combat = {"Lose 3 troops in conflict -> +1 VP"} },
    alliedArmada = {categories = {'combat'}, combat = {sword(anyAlliance("-2 Sp -> +7 sword"))}},
    tiebreaker = {categories = {'combat', 'endgame'}, combat = {sword(2)},  endgame = {spice(10)}},
    toTheVictor = {categories = {'outcome'}, outcome = {spice(winner(3))}},
    demandRespect = {categories = {'outcome'}, outcome = {influence(nil, winner("+1 inf ? Or -2 Sp -> +2 inf ?"))}},
    cornerTheMarket = {categories = {'endgame'}, endgame = {"If you have 2 SMF: +1 VP, if you have more SMF than all opps: +2 VP"}},
    plansWithinPlans = {categories = {'endgame'}, endgame = {"3 inf on 3 tracks: +1 VP or 3 inf on all 4 tracks: +2 VP"}},
    poisonSnooper = {categories = {'plot'}, plot = {"Look at the top card of your, draw or trash it"}},
    urgentMission = {categories = {'plot'}, plot = {"Recall one of your agents"}},
    dispatchAnEnvoy = {categories = {'plot'}, plot = {"Add faction agent icons to the card you play this turn"}},
    rapidMobilization = {categories = {'plot'}, plot = {"Deploy any # of garrisoned troops to conflict"}},
    recruitmentMission = {categories = {'plot'}, plot = {persuasion(1), "you may hadd acquired card to top of"}},
    calculatedHire = {categories = {'plot'}, plot = {"-1 Spice -> Take the mentat from Mentat space on board"}},
    favoredSubject = {categories = {'plot'}, plot = {influence('emperor', 1)}},
    theSleeperMustAwaken = {categories = {'plot'}, plot = {"-4 Sp -> +1 VP"}},
    councilorsDispensation = {categories = {'plot'}, plot = {"+2 Spice if you have a seat on the high council"}},
    waterOfLife = {categories = {'plot'}, plot = {"-1 Water and -1 Spice -> 3x draw"}},
    charisma = {categories = {'plot'}, plot = {persuasion(2)}},
    waterPeddlersUnion = {categories = {'plot'}, plot = {water(1)}},
    refocus = {categories = {'plot'}, plot = {"Shuffle your discard into, then 1x draw"}},
    knowTheirWays = {categories = {'plot'}, plot = {influence('fremen', 1)}},
    secretOfTheSisterhood = {categories = {'plot'}, plot = {influence('beneGesserit', 1)}},
    guildAuthorization = {categories = {'plot'}, plot = {influence('spacingGuild', 1)}},
    bribery = {categories = {'plot'}, plot = {"-2 Solari -> +1 Influence ?"}},
    binduSuspension = {categories = {'plot'}, plot = {"At start of turn: draw 1 card and you may pass your turn"}},
    doubleCross = {categories = {'plot'}, plot = {"-1 Solari - > An opp of your choice loses one deployed troop, you add one troop from supply to conflict"}},
    reinforcements = {categories = {'plot'}, plot = {"-3 Solari -> +3 troops. If its your reveal you may deploy to conflict"}},
    infiltrate = {categories = {'plot'}, plot = {"Enemy agents don’t block your next agent on board spaces this turn"}},
    windfall = {categories = {'plot'}, plot = {solari(2)}},
    choamShares = {categories = {'plot'}, plot = {"-7 -> +1 VP"}},
    -- ix
    bypassProtocol = {categories = {'plot'}, plot = {"Acquire 1 card worth 3 or less or -2 Spice -> card worth 5 or less and place on top of"}},
    blackmail = {categories = {'combat'}, plot = {"-1 inf ? -> +5 swords"}},
    cannonTurrets = {categories = {'combat'}, plot = {"+2 swords and each opp retreats one Dreadnought"}},
    strategicPush = {categories = {'combat'}, plot = {"and2 swords and if you win +2 Solari	2"}},
    secondWave = {categories = {'combat'}, plot = {"+2 sword and deploy up to 2 units from garrisson"}},
    warChest = {categories = {'combat', 'endgame'}, combat = {"-2 Solari -> 4 swords"}, endgame = {"If you have 10 Solari: +1 VP"}},
    finesse = {categories = {'combat', 'plot'}, combat = {"2 swords"}, plot = {"-1 influence ? -> +1 influence ?"}},
    advancedWeaponry = {categories = {'combat'}, plot = {"-3 solari -> +1 dreadnought"}, combat = {"If you have 3 tech: +4 sword."}},
    grandConspiracy = {categorise = {'endgame'}, plot = {"If you have (2 dread, 1 SMF, 4 inf on 2 tracks, council): 3 = 1 VP, 4 = 2 VP"}},
    strongArm = {categories = {'plot'}, plot = {"Lose a troop -> +1 influece on track where you placed an agent this turn"}},
    ixianProbe = {categories = {'plot'}, plot = {"2x discard -> 2x draw"}},
    cull = {categories = {'plot'}, plot = {"-1 Solari -> 1x trash"}},
    secretForces = {categories = {'plot'}, plot = {"+2 troops if you have a seat on high council"}},
    quidProQuo = {categories = {'plot'}, plot = {"-2 Spice -> +1 influence on each track where you currently have an agent"}},
    glimpseThePath = {categories = {'plot'}, plot = {"-1 Spice -> +1 Water and 1x draw"}},
    diversion = {categories = {'plot'}, plot = {"+1 shipping when you deploy 4 units to conflict in 1 turn"}},
    expedite = {categories = {'plot'}, plot = {"-1 Spice -> +1 shipping"}},
    machineCulture = {categories = {'plot', 'endgame'}, plot = {"+1 Tech"}, endgame = {"If you have 3 tech: +1 VP"}},
    -- immo
    harvestCells = {categories = {'combat'}, plot = {"When you lose 3+ troops at end of conflict: +2 specimen. May also acquire a tleilaxu card paying normal cost"}},
    viciousTalents = {categories = {'combat'}, plot = {"2 swords. If research lvl 1: +2 swords. If research lvl 2: +2 swords"}},
    gruesomeSacrifice = {categories = {'combat'}, plot = {"Lose 2 of your troops in the conflict --> +2 specimen and +1 beetle"}},
    breakthrough = {categories = {'plot'}, plot = {research(1)}},
    illicitDealings = {categories = {'plot'}, plot = {beetle(1)}},
    disguisedBureaucrat = {categories = {'plot'}, plot = {"If research lvl 1: +1 Spice, If research lvl 2: +1 inf ?"}},
    shadowyBargain = {categories = {'plot', 'endgame'}, plot = {specimen(1)}, endgame = {beetle(1)}},
    tleilaxuPuppet = {categories = {'plot', 'endgame'}, plot = {persuasion(1)}, engame = {"If you have high council and research lvl 2: +1 VP"}},
    studyMelange = {categories = {'plot', 'endgame'}, plot = {spice(1)}, endgame = {"If you have 3 spice and research lvl 2: +1 VP"}},
    counterAttack = {categories = {'combat', 'plot'}, plot = {"Deploy up to 2 troops from garrison."}, combat = {"If Opp played combat intrigue: +4 swords"}},
    economicPositioning = {categories = {'combat', 'endgame'}, plot = {"retreat two troops --> +3 solari."}, endgame = {"if you have 10 solari: +1 VP"}},
}

function IntrigueCard._resolveCard(card)
    local cardName = Helper.getID(card)
    local cardInfo = IntrigueCard[cardName]
    assert(cardInfo, "Unknown card: " .. cardName)
    cardInfo.name = cardName
    return cardInfo
end

function IntrigueCard.evaluatePlot(color, playedCards)
    local input = {
        color = color,
        playedCards = Helper.mapValues(playedCards, IntrigueCard._resolveCard),
    }
    local output = {}
    for _, card in ipairs(input.playedCards) do
        if card.plot then
            for _, effect in ipairs(card.plot) do
                if type(effect) == 'function' then
                    input.card = card
                    effect(input, output)
                else
                    log('Ignoring manual effect: "' .. tostring(effect) .. '"')
                end
             end
        end
    end
    return output
end

return IntrigueCard
