local Core = require("utils.Core")
local Helper = require("utils.Helper")
local XmlUI = require("utils.XmlUI")

local constructionModeEnabled = false

-- FIXME Too specific.
require("Locales")
Locale = "fr"

Helper.allModules = {
    Action = require("Action"),
    Combat = require("Combat"),
    Deck = require("Deck"),
    ImperiumRow = require("ImperiumRow"),
    Intrigue = require("Intrigue"),
    MainBoard = require("MainBoard"),
    Playboard = require("Playboard"),
    InfluenceTrack = require("InfluenceTrack"),
    Reserve = require("Reserve"),
    Resource = require("Resource"),
    TleilaxuResearch = require("TleilaxuResearch"),
    TleilaxuRow = require("TleilaxuRow"),
    TurnControl = require("TurnControl"),
    Utils = require("Utils"),
    CommercialTrack = require("CommercialTrack"),
    TechMarket = require("TechMarket"),
    LeaderSelection = require("LeaderSelection"),
    Hagal = require("Hagal"),
    Leader = require("Leader"),
}

local state = {
}

local setupUI

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
    difficulty_all = Helper.allModules.Hagal.soloDifficulties,
    difficulty = {},
    riseOfIx = true,
    epicMode = false,
    immortality = true,
    goTo11 = false,
    leaderSelection_all = Helper.allModules.LeaderSelection.selectionMethods,
    leaderSelection = "reversePick",
    fanMadeLeaders = false,
    variant_all = {
        none = "None",
        blitz = "Blitz!",
        arrakeenScouts = "Arrakeen scouts"
    },
    variant = "none"
}

---
function onLoad(scriptState)
    log("[Global]")
    log("--------< Dune Immorality >--------")
    Helper.destroyTransientObjects()

    if constructionModeEnabled then
        --Global.UI.hide("setupPane")
        return
    end

    local inventory = Core.resolveGUIDs(true, {
        primaryTable = "2b4b92",
        secondaryTable = "662ced",
    })
    for _, object in ipairs(inventory) do
        object.interactable = false
    end

    state = scriptState ~= "" and JSON.decode(scriptState) or {}

    for moduleName, module in pairs(Helper.allModules) do
        if module["onLoad"] then
            --log("[" .. moduleName .. "]")
            module["onLoad"](state)
        end
    end

    setupUI = XmlUI.new(Global, "setupPane", settings)
    if true then
        setupUI:show()
        updateSetupButton()
    else
        Wait.frames(setUp, 1)
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
function onPlayerTurn(player, previousPlayer)
    dispatchEvent("onPlayerTurn", player, previousPlayer)
end

---
function onObjectEnterScriptingZone(zone, enterObject)
    dispatchEvent("onObjectEnterScriptingZone", zone, enterObject)
end

---
function onObjectLeaveScriptingZone(zone, enterObject)
    dispatchEvent("onObjectLeaveScriptingZone", zone, enterObject)
end

---
function onObjectDrop(playerColor, object)
    dispatchEvent("onObjectDrop", playerColor, object)
end

---
function onPlayerChangeColor(playerColor)
    updateSetupButton()
    dispatchEvent("onPlayerChangeColor", playerColor)
end

---
function onPlayerConnect(playerColor)
    updateSetupButton()
    dispatchEvent("onPlayerConnect", playerColor)
end

---
function onPlayerDisconnect(playerColor)
    updateSetupButton()
    dispatchEvent("onObjectDrop", onPlayerDisconnect)
end

---
function dispatchEvent(name, ...)
    for _, module in pairs(Helper.allModules) do
        if module[name] then
            module[name](...)
        end
    end
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
    local fanMadeLeaders = settings.fanMadeLeaders == true
    local variant = settings.variant

    local properlySeatedPlayers = getProperlySeatedPlayers()
    if not virtualHotSeat then
        numberOfPlayers = math.min(4, #properlySeatedPlayers)
    end

    local activeOpponents = PlayerSet.findActiveOpponents(properlySeatedPlayers, numberOfPlayers)
    if randomizePlayerPositions then
        PlayerSet.randomizePlayerPositions(activeOpponents)
    end

    Helper.allModules.Playboard.setUp(riseOfIx, immortality, epicMode, activeOpponents)
    Helper.allModules.Combat.setUp(riseOfIx, epicMode)
    Helper.allModules.LeaderSelection.setUp(riseOfIx, immortality, fanMadeLeaders, activeOpponents, leaderSelection)

    if numberOfPlayers < 3 then
        Helper.allModules.Hagal.setUp(riseOfIx, immortality, numberOfPlayers, difficulty)
    else
        Helper.allModules.Hagal.tearDown()
    end

    Helper.allModules.MainBoard.setUp(riseOfIx)
    if riseOfIx then
        Helper.allModules.CommercialTrack.setUp()
        Helper.allModules.TechMarket.setUp()
    else
        Helper.allModules.CommercialTrack.tearDown()
        Helper.allModules.TechMarket.tearDown()
    end

    Helper.allModules.Intrigue.setUp(riseOfIx, immortality)
    Helper.allModules.ImperiumRow.setUp(riseOfIx, immortality)
    Helper.allModules.Reserve.setUp()
    if immortality then
        Helper.allModules.TleilaxuResearch.setUp()
        Helper.allModules.TleilaxuRow.setUp()
    else
        Helper.allModules.TleilaxuResearch.tearDown()
        Helper.allModules.TleilaxuRow.tearDown()
    end

    Helper.allModules.TurnControl.setUp(PlayerSet.toOrderedPlayerList(activeOpponents))

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

    local remainingRivalCount = math.max(0, 3 - numberOfPlayers)
    for _, color in ipairs(colorsByPreference) do
        if remainingRivalCount > 0 then
            if not activeOpponents[color] then
                activeOpponents[color] = "rival"
                remainingRivalCount = remainingRivalCount - 1
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

--- TODO Too fast?
function PlayerSet.switchPositions(opponent, newColor)
    if opponent ~= "rival" and opponent ~= "puppet" then
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
function getProperlySeatedPlayers()
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
    applyNumberOfPlayers()
    setupUI:toUI()
end

---
function setNumberOfPlayers(player, value, id)
    setupUI:fromUI(player, value, id)
    applyNumberOfPlayers()
    setupUI:toUI()
end

---
function applyNumberOfPlayers()
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
        local properlySeatedPlayers = getProperlySeatedPlayers()

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
