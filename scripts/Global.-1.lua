local constructionModeEnabled = false
local validateDefaultSetup = true

local Module = require("utils.Module")
local Helper = require("utils.Helper")
local XmlUI = require("utils.XmlUI")
local AcquireCard = require("utils.AcquireCard")

--[[
    Remember that 'require' must have a literal parameter, since it is not a
    real function, but simply a macro for 'luabundler'.
]]--
local allModules = Module.registerModules({
    AcquireCard, -- To take advantage of Module.registerModuleRedirections.
    Action = require("Action"),
    Combat = require("Combat"),
    CommercialTrack = require("CommercialTrack"),
    Deck = require("Deck"),
    Hagal = require("Hagal"),
    ImperiumRow = require("ImperiumRow"),
    InfluenceTrack = require("InfluenceTrack"),
    Intrigue = require("Intrigue"),
    Leader = require("Leader"),
    LeaderSelection = require("LeaderSelection"),
    Locales = require("Locales"),
    MainBoard = require("MainBoard"),
    Playboard = require("Playboard"),
    Reserve = require("Reserve"),
    Resource = require("Resource"),
    TechMarket = require("TechMarket"),
    TleilaxuResearch = require("TleilaxuResearch"),
    TleilaxuRow = require("TleilaxuRow"),
    TurnControl = require("TurnControl"),
    Utils = require("Utils"),
})

local state = {
}

local settings = {
    color_all = {
        Green = true,
        Yellow = true,
        Blue = true,
        Red = true
    },
    language_all = {
        de = "Deutsch",
        en = "English",
        ep = "Español",
        fr = "Français",
        it = "Italiano",
        jp = "日本語"
    },
    language = "en",
    randomizePlayerPositions = true,
    virtualHotSeat = false,
    numberOfPlayers_all = {
        "1 (+2)",
        "2 (+1)",
        "3 (hotseat)",
        "4 (hotseat)"
    },
    numberOfPlayers = {},
    difficulty_all = allModules.Hagal.soloDifficulties,
    difficulty = {},
    riseOfIx = true,
    epicMode = false,
    immortality = true,
    goTo11 = false,
    leaderSelection_all = allModules.LeaderSelection.selectionMethods,
    leaderSelection = "reversePick",
    --fanMadeLeaders = false,
    variant_all = {
        none = "None",
        blitz = "Blitz!",
        arrakeenScouts = "Arrakeen scouts"
    },
    variant = "none"
}

local setupUI

---
function onLoad(scriptState)
    log("--------< Dune Immorality >--------")
    Helper.destroyTransientObjects()

    if constructionModeEnabled then
        return
    end

    local inventory = Helper.resolveGUIDs(true, {
        primaryTable = "2b4b92",
        secondaryTable = "662ced",
    })
    for _, object in pairs(inventory) do
        object.interactable = false
    end

    state = scriptState ~= "" and JSON.decode(scriptState) or {}
    Module.redirect("onLoad", state)

    Module.registerModuleRedirections({
        "onObjectEnterScriptingZone",
        "onObjectLeaveScriptingZone",
        "onObjectDrop",
        "onPlayerChangeColor",
        "onPlayerConnect",
        "onPlayerDisconnect" })

    setupUI = XmlUI.new(Global, "setupPane", settings)
    if validateDefaultSetup then
        settings.riseOfIx = true
        settings.immortality = true
        settings.virtualHotSeat = true
        settings.leaderSelection = {
            Green = "ilesaEcaz",
            Yellow = "ilbanRichese",
            Red = "helenaRichese",
            Blue = "letoAtreides",
        }
        settings.virtualHotSeat = true
        settings.numberOfPlayers = 4
        settings.randomizePlayerPositions = false
        Wait.frames(setUp, 1)
    else
        setupUI:show()
        updateSetupButton()
    end
end

---
function onSave()
    if state then
        return JSON.encode(state)
    else
        return ''
    end
end

---
function onPlayerChangeColor(color)
    updateSetupButton()
end

---
function onPlayerConnect(color)
    updateSetupButton()
end

---
function onPlayerDisconnect(color)
    updateSetupButton()
end

local PlayerSet = {}

---
function setUp()
    setupUI:hide()
    setupUI = nil

    -- Normalize values.
    local language = settings.language
    local randomizePlayerPositions = settings.randomizePlayerPositions == true
    local virtualHotSeat = settings.virtualHotSeat == true
    local numberOfPlayers = settings.numberOfPlayers
    local difficulty = settings.difficulty
    local riseOfIx = settings.riseOfIx == true
    local epicMode = settings.epicMode == true
    local immortality = settings.immortality == true
    local goTo11 = settings.goTo11 == true
    local leaderSelection = settings.leaderSelection
    local fanMadeLeaders = false --settings.fanMadeLeaders == true
    local variant = settings.variant

    local properlySeatedPlayers = PlayerSet.getProperlySeatedPlayers()
    if not virtualHotSeat then
        numberOfPlayers = math.min(4, #properlySeatedPlayers)
    end

    local activeOpponents = PlayerSet.findActiveOpponents(properlySeatedPlayers, numberOfPlayers)
    if randomizePlayerPositions then
        PlayerSet.randomizePlayerPositions(activeOpponents)
    end

    allModules.Playboard.setUp(riseOfIx, immortality, epicMode, activeOpponents)
    allModules.Combat.setUp(riseOfIx, epicMode)
    allModules.LeaderSelection.setUp(riseOfIx, immortality, fanMadeLeaders, activeOpponents, leaderSelection)

    if numberOfPlayers < 3 then
        allModules.Hagal.setUp(riseOfIx, immortality, numberOfPlayers, difficulty)
    else
        allModules.Hagal.tearDown()
    end

    allModules.MainBoard.setUp(riseOfIx)
    if riseOfIx then
        allModules.CommercialTrack.setUp()
        allModules.TechMarket.setUp()
    else
        allModules.CommercialTrack.tearDown()
        allModules.TechMarket.tearDown()
    end

    allModules.Intrigue.setUp(riseOfIx, immortality)
    allModules.ImperiumRow.setUp(riseOfIx, immortality)
    allModules.Reserve.setUp()
    if immortality then
        allModules.TleilaxuResearch.setUp()
        allModules.TleilaxuRow.setUp()
    else
        allModules.TleilaxuResearch.tearDown()
        allModules.TleilaxuRow.tearDown()
    end

    allModules.TurnControl.setUp(numberOfPlayers, PlayerSet.toOrderedPlayerList(activeOpponents))

    -- TurnControl.start() is called by "LeaderSelection.setUp" asynchronously (FIXME: use a continuation for readiness)
end

---
function PlayerSet.findPlayer(color)
    for _, player in ipairs(Player.getPlayers()) do
        if player.color == color then
            return player
        end
    end
    return nil
end

---
function PlayerSet.findActiveOpponents(properlySeatedPlayers, numberOfPlayers)
    local colorsByPreference = { "Green", "Red", "Yellow", "Blue" }

    local activeOpponents = {}
    for i, color in ipairs(properlySeatedPlayers) do
        if i <= numberOfPlayers then
            activeOpponents[color] = PlayerSet.findPlayer(color)
        else
            break
        end
    end

    local remainingCount = math.max(0, 3 - numberOfPlayers)
    local opponentType = remainingCount == 2 and "rival" or "hagal"
    for _, color in ipairs(colorsByPreference) do
        if remainingCount > 0 then
            if not activeOpponents[color] then
                activeOpponents[color] = opponentType
                remainingCount = remainingCount - 1
            end
        else
            break
        end
    end

    local remainingPuppetCount = math.max(0, numberOfPlayers - #properlySeatedPlayers)
    for _, color in ipairs(colorsByPreference) do
        if remainingPuppetCount > 0 then
            if not activeOpponents[color] then
                activeOpponents[color] = "puppet"
                remainingPuppetCount = remainingPuppetCount - 1
            end
        else
            break
        end
    end

    return activeOpponents
end

---
function PlayerSet.toOrderedPlayerList(activeOpponents)
    local orderedColors = { "Green", "Yellow", "Blue", "Red" }

    local players = {}
    for _, color in ipairs(orderedColors) do
        if activeOpponents[color] then
            table.insert(players, color)
        end
    end

    return players
end

---
function PlayerSet.randomizePlayerPositions(activeOpponents)
    local colors = {}
    local opponents = {}
    local newColors = {}

    for color, opponent in pairs(activeOpponents) do
        table.insert(colors, color)
        table.insert(opponents, opponent)
        table.insert(newColors, color)
    end

    Helper.shuffle(newColors)

    for i = 1, #opponents do
        local opponent = opponents[i]
        local newColor = newColors[i]
        PlayerSet.switchPositions(opponent, newColor)
        activeOpponents[newColor] = opponent
    end
end

function PlayerSet.switchPositions(opponent, newColor)
    if opponent ~= "hagal" and opponent ~= "rival" and opponent ~= "puppet" then
        local oldColor = opponent.color
        local player = PlayerSet.findPlayer(newColor)
        if oldColor ~= newColor then
            if player then
                player:changeColor("Teal")
            end
            Helper.dump("switchPositions:", opponent.color, "->", newColor)
            opponent:changeColor(newColor)
            if player then
                player:changeColor(oldColor)
            end
        end
    end
end

---
function PlayerSet.getProperlySeatedPlayers()
    local properlySeatedPlayers = {}
    for _, color in ipairs(getSeatedPlayers()) do
        if settings.color_all[color] then
            table.insert(properlySeatedPlayers, color)
        end
    end
    return properlySeatedPlayers
end

---
function setLanguage(player, value, id)
    setupUI:fromUI(player, value, id)
end

---
function setRandomizePlayerPositions(player, value, id)
    setupUI:fromUI(player, value, id)
end

---
function setVirtualHotSeat(player, value, id)
    setupUI:fromUI(player, value, id)
    if value == "True" then
        settings.numberOfPlayers = 1
    else
        settings.numberOfPlayers = {}
    end
    PlayerSet.applyNumberOfPlayers()
    setupUI:toUI()
end

---
function setNumberOfPlayers(player, value, id)
    setupUI:fromUI(player, value, id)
    PlayerSet.applyNumberOfPlayers()
    setupUI:toUI()
end

---
function PlayerSet.applyNumberOfPlayers()
    if type(settings.numberOfPlayers) == "table" or settings.numberOfPlayers > 2 then
        settings.difficulty = {}

        settings.fanMadeLeaders = false

        settings.variant_all = {
            none = "None",
            blitz = "Blitz!",
            arrakeenScouts = "Arrakeen scouts"
        }
    else
        if settings.numberOfPlayers == 1 then
            settings.difficulty = 1
        else
            settings.difficulty = {}
        end

        settings.fanMadeLeaders = {}

        settings.variant_all = {
            none = "None"
        }
    end
    updateSetupButton()
end

---
function setDifficulty(player, value, id)
    setupUI:fromUI(player, value, id)
end

---
function setRiseOfIx(player, value, id)
    setupUI:fromUI(player, value, id)
    if value == "True" then
        settings.epicMode = false
    else
        settings.epicMode = {}
    end
    setupUI:toUI()
end

---
function setEpicMode(player, value, id)
    setupUI:fromUI(player, value, id)
end

---
function setImmortality(player, value, id)
    setupUI:fromUI(player, value, id)
    if value == "True" then
        settings.goTo11 = false
    else
        settings.goTo11 = {}
    end
    setupUI:toUI()
end

---
function setGoTo11(player, value, id)
    setupUI:fromUI(player, value, id)
end

---
function setLeaderSelection(player, value, id)
    setupUI:fromUI(player, value, id)
end

---
function setFanMadeLeaders(player, value, id)
    setupUI:fromUI(player, value, id)
end

---
function setVariant(player, value, id)
    setupUI:fromUI(player, value, id)
end

---
function updateSetupButton()
    if setupUI then
        local properlySeatedPlayers = PlayerSet.getProperlySeatedPlayers()

        local minPlayerCount
        if type(settings.numberOfPlayers) == "table" then
            minPlayerCount = 3
        else
            minPlayerCount = 1
        end

        if #properlySeatedPlayers >= minPlayerCount then
            setupUI:setButton("setUpButton", "Setup", true)
        else
            setupUI:setButton("setUpButton", "Not enough players", false)
        end
        setupUI:toUI()
    end
end
