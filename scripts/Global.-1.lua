local constructionModeEnabled = false

local validateDefaultSetup
validateDefaultSetup = {
    language = "en",
    randomizePlayerPositions = false,
    virtualHotSeat = true,
    numberOfPlayers = 3,
    difficulty = nil,
    riseOfIx = true,
    epicMode = false,
    immortality = true,
    goTo11 = false,
    leaderSelection = {
        Green = "ilesaEcaz",
        Yellow = "ilbanRichese",
        Red = "helenaRichese",
    },
    fanMadeLeaders = false,
    variant = nil,
}
validateDefaultSetup = {
    language = "en",
    randomizePlayerPositions = false,
    virtualHotSeat = false,
    numberOfPlayers = 1,
    difficulty = "novice",
    riseOfIx = true,
    epicMode = false,
    immortality = true,
    goTo11 = false,
    leaderSelection = {
        Green = "letoAtreides",
        Yellow = "ilbanRichese",
        Red = "glossuRabban",
    },
    fanMadeLeaders = false,
    variant = nil,
}
--validateDefaultSetup = nil

local Module = require("utils.Module")
local Helper = require("utils.Helper")
local XmlUI = require("utils.XmlUI")
local AcquireCard = require("utils.AcquireCard")
local I18N = require("utils.I18N")

--[[
    Remember that 'require' must have a literal parameter, since it is not a
    real function, but simply a macro for 'luabundler'.
]]--
local allModules = Module.registerModules({
    AcquireCard, -- To take advantage of Module.registerModuleRedirections.
    Action = require("Action"),
    Combat = require("Combat"),
    CommercialTrack = require("CommercialTrack"),
    ConflictCard = require("ConflictCard"),
    Deck = require("Deck"),
    ScoreBoard = require("ScoreBoard"),
    Hagal = require("Hagal"),
    HagalCard = require("HagalCard"),
    ImperiumCard = require("ImperiumCard"),
    ImperiumRow = require("ImperiumRow"),
    InfluenceTrack = require("InfluenceTrack"),
    Intrigue = require("Intrigue"),
    IntrigueCard = require("IntrigueCard"),
    Leader = require("Leader"),
    LeaderSelection = require("LeaderSelection"),
    Locales = require("Locales"),
    MainBoard = require("MainBoard"),
    Music = require("Music"),
    PlayBoard = require("PlayBoard"),
    Reserve = require("Reserve"),
    Resource = require("Resource"),
    TechCard = require("TechCard"),
    TechMarket = require("TechMarket"),
    TleilaxuResearch = require("TleilaxuResearch"),
    TleilaxuRow = require("TleilaxuRow"),
    TurnControl = require("TurnControl"),
    Utils = require("Utils"),
})

local PlayerSet = {
    fields = {
        color_all = {
            Green = true,
            Yellow = true,
            Blue = true,
            Red = true
        },
        language_all = {
            --de = "Deutsch",
            en = "English",
            --ep = "Español",
            --eo = "Esperanto",
            fr = "Français",
            --it = "Italiano",
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
        difficulty_all = Helper.map(allModules.Hagal.difficulties, function (_, v) return v.name end),
        difficulty = {},
        riseOfIx = true,
        epicMode = false,
        immortality = true,
        goTo11 = false,
        leaderSelection_all = allModules.LeaderSelection.selectionMethods,
        leaderSelection = "reversePick",
        fanMadeLeaders = false,
        variant_all = {
            none = "None",
            blitz = "Blitz!",
            arrakeenScouts = "Arrakeen scouts"
        },
        variant = "none"
    }
}

local settings

---
function onLoad(scriptState)
    log("--------< Dune Immorality >--------")
    Helper.destroyTransientObjects()

    if constructionModeEnabled then
        return
    end

    Helper.noPhysicsNorPlay(Helper.resolveGUIDs(true, {
        primaryTable = "2b4b92",
        secondaryTable = "662ced",
    }))

    local state = scriptState ~= "" and JSON.decode(scriptState) or {}

    --Module.callOnAllRegisteredModules("onLoad", state)
    -- Order matter, now that we reload with "staticSetUp" (for the same reason setUp is ordered too).
    -- FIXME It is too much error prone.

    allModules.Action.onLoad(state)

    allModules.Music.onLoad(state)
    allModules.Deck.onLoad(state)
    allModules.ScoreBoard.onLoad(state)
    allModules.PlayBoard.onLoad(state)
    allModules.Combat.onLoad(state)
    allModules.LeaderSelection.onLoad(state)
    allModules.Hagal.onLoad(state)
    allModules.MainBoard.onLoad(state)
    allModules.CommercialTrack.onLoad(state)
    allModules.TechMarket.onLoad(state)
    allModules.Intrigue.onLoad(state)
    allModules.InfluenceTrack.onLoad(state)
    allModules.ImperiumRow.onLoad(state)
    allModules.Reserve.onLoad(state)
    allModules.TleilaxuResearch.onLoad(state)
    allModules.TleilaxuRow.onLoad(state)
    allModules.TurnControl.onLoad(state)

    Module.registerModuleRedirections({
        "onObjectEnterScriptingZone",
        "onObjectLeaveScriptingZone",
        "onObjectDrop",
        "onPlayerChangeColor",
        "onPlayerConnect",
        "onPlayerDisconnect" })

    if not state.settings then
        if validateDefaultSetup then
            Wait.frames(function ()
                setUp(validateDefaultSetup)
            end, 1)
        else
            PlayerSet.ui = XmlUI.new(Global, "setupPane", PlayerSet.fields)
            PlayerSet.ui:show()
            PlayerSet.updateSetupButton()
        end
    end
end

---
function onSave()
    if constructionModeEnabled then
        return
    end

    local savedState = {
        settings = settings
    }
    Module.callOnAllRegisteredModules("onSave", savedState)
    if #Helper.getKeys(savedState) then
        return JSON.encode(savedState)
    else
        return ''
    end
end

---
function setUp(newSettings)
    settings = newSettings

    local properlySeatedPlayers = PlayerSet.getProperlySeatedPlayers()
    if not settings.virtualHotSeat then
        settings.numberOfPlayers = math.min(4, #properlySeatedPlayers)
    end

    local activeOpponents = PlayerSet.findActiveOpponents(properlySeatedPlayers, settings.numberOfPlayers)
    if settings.randomizePlayerPositions then
        PlayerSet.randomizePlayerPositions(activeOpponents)
    end

    allModules.Music.setUp(settings)
    allModules.Deck.setUp(settings)
    allModules.ScoreBoard.setUp(settings)
    allModules.PlayBoard.setUp(settings, activeOpponents)
    allModules.Combat.setUp(settings)
    allModules.LeaderSelection.setUp(settings, activeOpponents)
    allModules.Hagal.setUp(settings)
    allModules.MainBoard.setUp(settings)
    allModules.CommercialTrack.setUp(settings)
    allModules.TechMarket.setUp(settings)
    allModules.Intrigue.setUp(settings)
    allModules.ImperiumRow.setUp(settings)
    allModules.Reserve.setUp()
    allModules.TleilaxuResearch.setUp(settings)
    allModules.TleilaxuRow.setUp(settings)
    allModules.TurnControl.setUp(settings, PlayerSet.toOrderedPlayerList(activeOpponents))

    -- TurnControl.start() is called by "LeaderSelection" asynchronously. (FIXME: use a continuation for readiness?)
end

---
function onPlayerChangeColor(color)
    PlayerSet.updateSetupButton()
end

---
function onPlayerConnect(color)
    PlayerSet.updateSetupButton()
end

---
function onPlayerDisconnect(color)
    PlayerSet.updateSetupButton()
end

---
function PlayerSet.findActiveOpponents(properlySeatedPlayers, numberOfPlayers)
    local colorsByPreference = { "Green", "Red", "Yellow", "Blue" }

    local activeOpponents = {}
    for i, color in ipairs(properlySeatedPlayers) do
        if i <= numberOfPlayers then
            activeOpponents[color] = Helper.findPlayer(color)
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

---
function PlayerSet.switchPositions(opponent, newColor)
    if opponent ~= "hagal" and opponent ~= "rival" and opponent ~= "puppet" then
        local oldColor = opponent.color
        local player = Helper.findPlayer(newColor)
        if oldColor ~= newColor then
            if player then
                player:changeColor("Teal")
            end
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
        if PlayerSet.fields.color_all[color] then
            table.insert(properlySeatedPlayers, color)
        end
    end
    return properlySeatedPlayers
end

---
function setLanguage(player, value, id)
    PlayerSet.ui:fromUI(player, value, id)
    I18N.setLocale(PlayerSet.fields.language)
    PlayerSet.ui:toUI()
end

---
function setRandomizePlayerPositions(player, value, id)
    PlayerSet.ui:fromUI(player, value, id)
end

---
function setVirtualHotSeat(player, value, id)
    PlayerSet.ui:fromUI(player, value, id)
    if value == "True" then
        PlayerSet.fields.numberOfPlayers = 1
    else
        PlayerSet.fields.numberOfPlayers = {}
    end
    PlayerSet.applyNumberOfPlayers()
    PlayerSet.ui:toUI()
end

---
function setNumberOfPlayers(player, value, id)
    PlayerSet.ui:fromUI(player, value, id)
    PlayerSet.applyNumberOfPlayers()
    PlayerSet.ui:toUI()
end

---
function PlayerSet.applyNumberOfPlayers()
    if type(PlayerSet.fields.numberOfPlayers) == "table" or PlayerSet.fields.numberOfPlayers > 2 then
        PlayerSet.fields.difficulty = {}

        PlayerSet.fields.fanMadeLeaders = false

        PlayerSet.fields.variant_all = {
            none = "None",
            blitz = "Blitz!",
            arrakeenScouts = "Arrakeen scouts"
        }
    else
        if PlayerSet.fields.numberOfPlayers == 1 then
            PlayerSet.fields.difficulty = "novice"
        else
            PlayerSet.fields.difficulty = {}
        end

        PlayerSet.fields.fanMadeLeaders = {}

        PlayerSet.fields.variant_all = {
            none = "None"
        }
    end
    PlayerSet.updateSetupButton()
end

---
function setDifficulty(player, value, id)
    PlayerSet.ui:fromUI(player, value, id)
end

---
function setRiseOfIx(player, value, id)
    PlayerSet.ui:fromUI(player, value, id)
    if value == "True" then
        PlayerSet.fields.epicMode = false
    else
        PlayerSet.fields.epicMode = {}
    end
    PlayerSet.ui:toUI()
end

---
function setEpicMode(player, value, id)
    PlayerSet.ui:fromUI(player, value, id)
end

---
function setImmortality(player, value, id)
    PlayerSet.ui:fromUI(player, value, id)
    if value == "True" then
        PlayerSet.fields.goTo11 = false
    else
        PlayerSet.fields.goTo11 = {}
    end
    PlayerSet.ui:toUI()
end

---
function setGoTo11(player, value, id)
    PlayerSet.ui:fromUI(player, value, id)
end

---
function setLeaderSelection(player, value, id)
    PlayerSet.ui:fromUI(player, value, id)
end

---
function setFanMadeLeaders(player, value, id)
    PlayerSet.ui:fromUI(player, value, id)
end

---
function setVariant(player, value, id)
    PlayerSet.ui:fromUI(player, value, id)
end

---
function PlayerSet.updateSetupButton()
    if PlayerSet.ui then
        local properlySeatedPlayers = PlayerSet.getProperlySeatedPlayers()

        local minPlayerCount
        if type(PlayerSet.fields.numberOfPlayers) == "table" then
            minPlayerCount = 3
        else
            minPlayerCount = math.min(2, PlayerSet.fields.numberOfPlayers)
        end

        if #properlySeatedPlayers >= minPlayerCount then
            PlayerSet.ui:setButtonI18N("setUpButton", "setup", true)
        else
            PlayerSet.ui:setButtonI18N("setUpButton", "notEnoughPlayers", false)
        end

        PlayerSet.ui:toUI()
    end
end

---
function setUpFromUI()
    PlayerSet.ui:hide()
    PlayerSet.ui = nil

    setUp({
        language = PlayerSet.fields.language,
        randomizePlayerPositions = PlayerSet.fields.randomizePlayerPositions == true,
        virtualHotSeat = PlayerSet.fields.virtualHotSeat == true,
        numberOfPlayers = PlayerSet.fields.numberOfPlayers,
        difficulty = PlayerSet.fields.difficulty,
        riseOfIx = PlayerSet.fields.riseOfIx == true,
        epicMode = PlayerSet.fields.epicMode == true,
        immortality = PlayerSet.fields.immortality == true,
        goTo11 = PlayerSet.fields.goTo11 == true,
        leaderSelection = PlayerSet.fields.leaderSelection,
        fanMadeLeaders = PlayerSet.fields.fanMadeLeaders == true,
        variant = PlayerSet.fields.variant,
    })
end
