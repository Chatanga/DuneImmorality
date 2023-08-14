local Module = require("utils.Module")
local Helper = require("utils.Helper")

local Action = Module.lazyRequire("Action")
local MainBoard = Module.lazyRequire("MainBoard")
local ImperiumRow = Module.lazyRequire("ImperiumRow")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")
local Combat = Module.lazyRequire("Combat")

local Leader = {
    vladimirHarkonnen = {},
    glossuRabban = {},
    ilbanRichese = {},
    helenaRichese = {},
    letoAtreides = {},
    paulAtreides = {},
    arianaThorvald = {},
    memnonThorvald = {},

    armandEcaz = {},
    ilesaEcaz = {},
    rhomburVernius = {},
    tessiaVernius = {},
    yunaMoritani = {},
    hundroMoritani = {},

    metulli = {},
    hasimirFenring = {},
    scytale = {},
    margotFenring = {},
    feydRauthaHarkonnen = {},
    serenaButler = {},
    lietKynes = {},
    wensiciaCorrino = {},
    irulanCorrino = {},
    hwiNoree = {},
    whitmoreBlund = {},
    drisq = {},
    executrix = {},
    milesTeg = {},
    esmarTuek = {},
    vorianAtreides = {},
    xavierHarkonnen = {},
    normaCenva = {},
    abuldurHarkonnen = {},
    arkhane = {},
    stabanTuek = {},
    tylwythWaff = {},
    torgTheYoung = {},

    shaddamIV = {},
}

---
function Leader.getLeader(name)
    local LeaderClass = Leader[name]
    assert(LeaderClass, "Unknown leader: " .. tostring(name))
    LeaderClass.getName = function ()
        return name
    end
    return Helper.newInheritingObject(Action, LeaderClass, {
        -- FIXME Instance are useless here.
    })
end

function Leader.vladimirHarkonnen.setUp(color, epic)
    Action.setUp(color, epic)

    --- Masterstroke
    local position = Player[color].getHandTransform().position
    local tokenBag = getObjectFromGUID('f89231')
    local tokenCount = #tokenBag.getObjects()
    for _ = 1, tokenCount do
        tokenBag.takeObject({
            position = position,
            callback_function = function (token)
                token.flip()
            end
        })
    end
    Wait.frames(function ()
        tokenBag.destruct()
    end, 1)
end

function Leader.vladimirHarkonnen.tearDown()
    local tokenBag = getObjectFromGUID('f89231')
    tokenBag.destruct()
end

function Leader.vladimirHarkonnen.instruct(phase, color)
    -- Masterstroke
    if phase == "gameStart" then
        return "Secretly choose 2 Factions."
    end
end

--- Scheme
function Leader.vladimirHarkonnen.signetRing(color)
    return Action.resource(color, "solari", -1) and Action.drawIntrigues(color, 1)
end

--- Arrakis fiefdom
function Leader.glossuRabban.setUp(color, epic)
    Action.setUp(color, epic)
    Action.resource(color, "spice", 1)
    Action.resource(color, "solari", 1)
end

--- Brutality
function Leader.glossuRabban.signetRing(color)
    return Action.troops(color, "supply", "garrison", InfluenceTrack.hasAnyAlliance(color) and 2 or 1)
end

--- Manufacturing
function Leader.ilbanRichese.signetRing(color)
    Action.resource(color, "solari", 1)
end

--- Ruthless negotiator
function Leader.ilbanRichese.resource(color, resourceName, amount)
    local success = Action.resource(color, resourceName, amount)
    if success and amount < 0 and Action.checkContext({ phase = "playerTurns", color = color, space = MainBoard.isLandsraadSpace }) then
        Action.drawImperiumCards(color, 1)
    end
    return success
end

--- Manipulate
function Leader.helenaRichese.acquireReservedImperiumCard(color, resourceName, amount)
    return ImperiumRow.acquireReservedImperiumCard(color)
end

--- Eyes everywhere
function Leader.helenaRichese.sendAgent(color, spaceName)
    -- TODO Manage accesses
    local force = MainBoard.isLandsraadSpace(spaceName) or MainBoard.isSpiceTradeSpace(spaceName)
    return Action.sendAgent(color, spaceName)
end

--- Landsraad popularity
function Leader.letoAtreides.resource(color, resourceName, amount)
    local finalAmount = amount
    if resourceName == "solari" and amount < 0 and Action.checkContext({ phase = "playerTurns", color = color, space = MainBoard.isLandsraadSpace }) then
        finalAmount = amount + 1
    end
    return Action.resource(color, resourceName, finalAmount)
end

--- Prescience
function Leader.paulAtreides.setUp(color, epic)
    Action.setUp(color, epic)
    -- TODO Add prescience button
end

--- Discipline
function Leader.paulAtreides.signetRing(color)
    return Action.drawImperiumCards(color, 1)
end

--- Hidden reservoir
function Leader.arianaThorvald.signetRing(color)
    return Action.resource(color, "water", 1)
end

--- Spice addict
function Leader.arianaThorvald.sendAgent(color, spaceName)
    if Action.sendAgent(color, spaceName) then
        if MainBoard.isDesertSpace(spaceName) then
            Action.resource(color, "spice", -1)
            Action.drawImperiumCards(color, 1)
        end
        return true
    else
        return false
    end
end

--- Connections
function Leader.memnonThorvald.sendAgent(color, spaceName)
    if Action.sendAgent(color, spaceName) then
        if spaceName == "highCouncil" then
            Action.influence(color, nil, 1)
        end
        return true
    else
        return false
    end
end

--- Spice hoard
function Leader.memnonThorvald.signetRing(color, spaceName)
    return Action.resource(color, "spice", 1)
end

--- Guild contacts
function Leader.ilesaEcaz.signetRing(color)
    return Action.resource(color, "solari", -1) and Action.acquireFoldspaceCard(color)
end

function Leader.ilesaEcaz.instruct(phase, color)
    --- One step ahead
    if phase == "roundStart" then
        return "Set aside a card from your hand."
    end
end

--- Heavy lasgun cannons
function Leader.rhomburVernius.setUp(color, epic)
    Action.setUp(color, epic)
    Combat.setDreadnoughtStrength(3)
end

function Leader.tessiaVernius.setUp(color, epic)
    Action.setUp(color, epic)

    local getAveragePosition = function (spaceNames)
        local p = Vector(0, 0, 0)
        local count = 0
        for _, spaceName in ipairs(spaceNames) do
            p = p + MainBoard.spaces[spaceName].zone.getPosition()
            count = count + 1
        end
        return p * (1 / count)
    end

    local snoopers = {
        { guid = "a58ce8", position = getAveragePosition({ "conspire", "wealth" })},
        { guid = "857f74", position = getAveragePosition({ "heighliner", "foldspace" })},
        { guid = "bed196", position = getAveragePosition({ "selectiveBreeding", "secrets" })},
        { guid = "b10897", position = getAveragePosition({ "hardyWarriors", "stillsuits" })},
    }

    for _, snooper in ipairs(snoopers) do
        local object = getObjectFromGUID(snooper.guid)
        object.setPositionSmooth(snooper.position, false, false)
        object.setRotationSmooth(Vector(0, 90, 0))
    end
end

function Leader.tessiaVernius.tearDown()
    local snoopers = {
        "a58ce8",
        "857f74",
        "bed196",
        "b10897",
    }

    for _, guid in ipairs(snoopers) do
        local object = getObjectFromGUID(guid)
        object.destruct()
    end
end

--- Duplicity
function Leader.tessiaVernius.signetRing(color)
    Action.influence(color, nil, -1)
    Action.influence(color, nil, 1)
end

---
function Leader.yunaMoritani.signetRing(color)
    return Action.resource(color, "solari", -7)
        and Action.influence(color, nil, 1)
        and Action.troop(color, "supply", "garrison", 1)
        and Action.resource(color, "spice", 1)
end

--- Smuggling operation
function Leader.yunaMoritani.setUp(color, epic)
    Action.setUp(color, epic)
    Action.resource(color, "water", -1)
end

-- Final delivery
function Leader.yunaMoritani.resource(color, resourceName, amount)
    local finalAmount = amount
    if resourceName == "solari" and amount > 0 and Action.checkContext({ phase = "playerTurns", color = color }) then
        finalAmount = amount + 1
    end
    return Action.resource(color, resourceName, finalAmount)
end

--- Intelligence
function Leader.hundroMoritani.setUp(color, epic)
    Action.setUp(color, epic)
    Wait.frames(function ()
        Action.drawIntrigues(color, 2)
    end, 1)
end

function Leader.hundroMoritani.instruct(phase, color)
    -- Intelligence
    if phase == "gameStart" then
        return "Keep one intrigue and put the other on top of the intrigue deck."
    end
end

--- Couriers
function Leader.hundroMoritani.signetRing(color)
    return Action.resource(color, "spice", 1)
        and Action.cargo(color, nil, 1)
end

---
function Leader.hasimirFenring.drawIntrigues(color, amount)
    return Action.drawIntrigues(color, amount + 1)
end

---
function Leader.shaddamIV.influence(color, faction, amount)
    return Action.influence(color, faction, amount == 1 and -1 or amount)
end

return Leader
