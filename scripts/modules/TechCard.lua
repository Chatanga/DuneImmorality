local Module = require("utils.Module")
local Helper = require("utils.Helper")

local PlayBoard = Module.lazyRequire("PlayBoard")

local function water(n)
    return function (color)
        return PlayBoard.getLeader(color).resources(color, "water", n)
    end
end

local function influence(n, faction)
    return function (color)
        return PlayBoard.getLeader(color).influence(color, faction, n)
    end
end

local function vp(n)
    return function (color, techName)
        for _ = 1, n do
            return PlayBoard.getLeader(color).gainVictoryPoint(color, techName)
        end
        return true
    end
end

local function draw(n)
    return function (color)
        return PlayBoard.getLeader(color).drawImperiumCards(color, n)
    end
end

local function persuasion(n)
    return function (color)
        return PlayBoard.getLeader(color).resources(color, "persuasion", n)
    end
end

local function intrigue(n)
    return function (color)
        return PlayBoard.getLeader(color).drawIntrigues(color, n)
    end
end

local function troop(n)
    return function (color)
        return PlayBoard.getLeader(color).troops(color, "supply", "garrison", n)
    end
end

local function seat(n)
    return function (color)
        if PlayBoard.hasHighCouncilSeat(color) then
            return n
        else
            return 0
        end
    end
end

local function trash(n)
    return function (color)
        return false
    end
end

local function choice(n, options)
    return function (color, techName)
        if not PlayBoard.getLeader(color).choose(color, techName) then
            local shuffledOptions = Helper.shallowCopy(options)
            Helper.shuffle(shuffledOptions)
            for i = 1, n do
                shuffledOptions[i](color, techName)
            end
        end
        return true
    end
end

local TechCard = {
    windtraps = {cost = 2, hagal = true, acquireBonus = {water(1)}},
    detonationDevices = {cost = 3, hagal = true},
    memocorders = {cost = 2, hagal = true, acquireBonus = {influence(1)}},
    flagship = {cost = 8, hagal = true, acquireBonus = {vp(1)}},
    spaceport = {cost = 5, hagal = false, acquireBonus = {draw(2)}},
    artillery = {cost = 1, hagal = false},
    holoprojectors = {cost = 2, hagal = false},
    restrictedOrdnance = {cost = 4, hagal = false, acquireBonus = {persuasion(seat(2))}},
    shuttleFleet = {cost = 6, hagal = true, acquireBonus = {choice(2, {influence(1, "emperor"), influence(1, "spacingGuild"), influence(1, "beneGesserit"), influence(1, "fremen")})}},
    spySatellites = {cost = 4, hagal = true},
    disposalFacility = {cost = 3, hagal = false, acquireBonus = {trash(1)}},
    chaumurky = {cost = 4, hagal = true, acquireBonus = {intrigue(2)}},
    sonicSnoopers = {cost = 2, hagal = true, acquireBonus = {intrigue(1)}},
    trainingDrones = {cost = 3, hagal = true},
    troopTransports = {cost = 2, hagal = true},
    holtzmanEngine = {cost = 6, hagal = true},
    minimicFilm = {cost = 2, hagal = false, acquireBonus = {persuasion(1)}},
    invasionShips = {cost = 5, hagal = true, acquireBonus = {troop(4)}},
}

function TechCard._resolveCard(card)
    local cardName = Helper.getID(card)
    local cardInfo = TechCard[cardName]
    assert(cardInfo, "Unknown card: " .. tostring(cardName))
    cardInfo.name = cardName
    return cardInfo
end

---
function TechCard.getDetails(techCard)
    return TechCard._resolveCard(techCard)
end

---
function TechCard.getCost(techCard)
    return TechCard._resolveCard(techCard).cost
end

---
function TechCard.isHagal(techCard)
    return TechCard._resolveCard(techCard).hagal
end

---
function TechCard.applyBuyEffect(color, techCard)
    local bonus = TechCard.getDetails(techCard).acquireBonus
    if bonus then
        for _, bonusItem in ipairs(bonus) do
            bonusItem(color, Helper.getID(techCard))
        end
    end
end

return TechCard
