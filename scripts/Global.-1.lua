local BUILD = 'TBD'

-- Do not load anything. Appropriate to work on the mod content without
-- interference.
local constructionModeEnabled = false

-- For test purposes.
local autoLoadedSettings

--[[
autoLoadedSettings = {
    language = "fr",
    randomizePlayerPositions = false,
    specialMode = true,
    numberOfPlayers = 4,
    riseOfIx = true,
    epicMode = false,
    immortality = true,
    goTo11 = false,
    leaderSelection = {
        Green = "rhomburVernius",
        Yellow = "ilbanRichese",
        Red = "tessiaVernius",
        Blue = "yunaMoritani"
    },
    soundEnabled = true,
}
]]

local Module = require("utils.Module")
local Helper = require("utils.Helper")
local XmlUI = require("utils.XmlUI")
local AcquireCard = require("utils.AcquireCard")
local I18N = require("utils.I18N")

--[[
    Remember that 'require' must have a literal parameter, since it is not a
    real function, but simply a macro for 'luabundler'.

    Note that "CardEffect" is not here since it is always hard required by the
    other modules.
]]
local allModules = Module.registerModules({
    AcquireCard, -- To take advantage of Module.registerModuleRedirections.
    Action = require("Action"),
    Combat = require("Combat"),
    ShipmentTrack = require("ShipmentTrack"),
    Deck = require("Deck"),
    ScoreBoard = require("ScoreBoard"),
    Hagal = require("Hagal"),
    HagalCard = require("HagalCard"),
    ImperiumRow = require("ImperiumRow"),
    InfluenceTrack = require("InfluenceTrack"),
    Intrigue = require("Intrigue"),
    Leader = require("Leader"),
    LeaderSelection = require("LeaderSelection"),
    Locale = require("Locale"),
    MainBoard = require("MainBoard"),
    Music = require("Music"),
    Pdf = require("Pdf"),
    PlayBoard = require("PlayBoard"),
    Reserve = require("Reserve"),
    Resource = require("Resource"),
    TechMarket = require("TechMarket"),
    TleilaxuResearch = require("TleilaxuResearch"),
    TleilaxuRow = require("TleilaxuRow"),
    TurnControl = require("TurnControl"),
    Types = require("Types"),
})

-- A 'xxx_all' member is not UI field, but define the options for the 'xxx' field.
local PlayerSet = {
    fields = {
        color_all = {
            Green = true,
            Yellow = true,
            Blue = true,
            Red = true
        },
        language_all = {
            --de = "Deutsche",
            en = "English",
            --ep = "Español",
            --eo = "Esperanto",
            fr = "Français",
            --it = "Italiano",
            --jp = "日本語",
            --zh = "中文",
        },
        language = "en",
        specialMode = false,
        numberOfPlayers_all = {
            "1 (+2)",
            "2 (+1)",
            "3",
            "4",
            "2 x 3"
        },
        numberOfPlayers = {},
        randomizePlayerPositions = false,
        difficulty_all = Helper.map(allModules.Hagal.getDifficulties(), function (_, v) return v.name end),
        difficulty = {},
        useContracts = false,
        riseOfIx = true,
        epicMode = false,
        immortality = true,
        goTo11 = true,
        leaderSelection_all = allModules.LeaderSelection.getSelectionMethods(),
        leaderSelection = "reversePick",
        soundEnabled = true,
    }
}

local settings

---
function onLoad(scriptState)
    log("--------< Dune Uprising - " .. BUILD .. " >--------")
    Helper.destroyTransientObjects()

    if constructionModeEnabled then
        allModules.PlayBoard.rebuild()
        return
    end

    local tables = Helper.resolveGUIDs(true, {
        primaryTable = "2b4b92",
        secondaryTable = "662ced",
    })
    Helper.noPhysicsNorPlay(
        tables.primaryTable,
        tables.secondaryTable)

    local state = scriptState ~= "" and JSON.decode(scriptState) or {}

    allModules.Locale.onLoad(state)
    allModules.Action.onLoad(state)

    allModules.ordered = {
        allModules.Pdf,
        allModules.Music,
        allModules.Deck,
        allModules.Hagal,
        allModules.ScoreBoard,
        allModules.PlayBoard,
        allModules.Combat,
        allModules.LeaderSelection,
        allModules.MainBoard,
        allModules.ShipmentTrack,
        allModules.TechMarket,
        allModules.Intrigue,
        allModules.InfluenceTrack,
        allModules.ImperiumRow,
        allModules.Reserve,
        allModules.TleilaxuResearch,
        allModules.TleilaxuRow,
        allModules.TurnControl,
    }

    -- We cannot use Module.callOnAllRegisteredModules("onLoad", state),
    -- because the order matter, now that we reload with "staticSetUp" (for the
    -- same reason setUp is ordered too).
    for _, module in ipairs(allModules.ordered) do
        module.onLoad(state)
    end

    -- List the TTS events we want to make available in the modules.
    Module.registerModuleRedirections({
        "onObjectEnterScriptingZone",
        "onObjectLeaveScriptingZone",
        "onObjectDrop",
        "onPlayerChangeColor",
        "onPlayerConnect",
        "onPlayerDisconnect",
        "onPlayerTurn",
    })

    if not state.settings then
        if autoLoadedSettings then
            Helper.onceFramesPassed(1).doAfter(function ()
                setUp(autoLoadedSettings)
            end)
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

    if not Helper.isStabilized() then
        Helper.dump("Unstable save!")
    end

    local savedState = {
        settings = settings
    }
    --Module.callOnAllRegisteredModules("onSave", savedState)
    if #Helper.getKeys(savedState) then
        return JSON.encode(savedState)
    else
        return ''
    end
end

---
function setUp(newSettings)
    assert(newSettings)
    I18N.setLocale(newSettings.language)

    log("--- Settings ---")
    log(newSettings)

    local properlySeatedPlayers = PlayerSet.getProperlySeatedPlayers()
    if not newSettings.specialMode then
        newSettings.numberOfPlayers = math.min(6, #properlySeatedPlayers)
    end

    local continuation = Helper.createContinuation("setUp")
    local activeOpponents = PlayerSet.findActiveOpponents(properlySeatedPlayers, newSettings.numberOfPlayers)
    if newSettings.randomizePlayerPositions then
        PlayerSet.randomizePlayerPositions(activeOpponents, continuation)
    else
        continuation.run()
    end

    continuation.doAfter(function ()
        -- Not assigned before in order to avoid saving anything.
        settings = newSettings

        local orderedPlayers = PlayerSet.toCanonicallyOrderedPlayerList(activeOpponents)
        log("--- orderedPlayers ---")
        log(orderedPlayers)
        for _, module in ipairs(allModules.ordered) do
            module.setUp(settings, activeOpponents, orderedPlayers)
        end

        -- TurnControl.start() is called by "LeaderSelection" asynchronously,
        -- effectively starting the game.
    end)
end

---
function onPlayerChangeColor()
    PlayerSet.updateSetupButton()
end

---
function onPlayerConnect()
    PlayerSet.updateSetupButton()
end

---
function onPlayerDisconnect()
    PlayerSet.updateSetupButton()
end

---
function PlayerSet.findActiveOpponents(properlySeatedPlayers, numberOfPlayers)
    local colorsByPreference = { "Green", "Red", "Yellow", "Blue", "Purple", "White" }

    local activeOpponents = {}
    for i, color in ipairs(properlySeatedPlayers) do
        if i <= numberOfPlayers then
            activeOpponents[color] = Helper.findPlayerByColor(color)
        else
            break
        end
    end

    local remainingCount = math.max(0, 3 - numberOfPlayers)
    local opponentType = "rival"
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
function PlayerSet.toCanonicallyOrderedPlayerList(activeOpponents)
    local orderedColors
    if #activeOpponents == 6 then
        orderedColors = { "Green", "Purple", "Yellow", "Blue", "White", "Red" }
    else
        orderedColors = { "Green", "Yellow", "Blue", "Red" }
    end

    local players = {}
    for _, color in ipairs(orderedColors) do
        if activeOpponents[color] then
            table.insert(players, color)
        end
    end

    return players
end

---
function PlayerSet.randomizePlayerPositions(activeOpponents, continuation)
    PlayerSet.registeredCallback = Helper.registerGlobalCallback(function ()
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
            if opponent ~= "rival" and opponent ~= "puppet" then
                Helper.changePlayerColorInCoroutine(opponent, newColor)
            end
            activeOpponents[newColor] = opponent
        end

        Helper.unregisterGlobalCallback(PlayerSet.registeredCallback)
        PlayerSet.registeredCallback = nil

        continuation.run()
        return 1
    end)
    startLuaCoroutine(Global, PlayerSet.registeredCallback)
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
function setSpecialMode(player, value, id)
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
    if PlayerSet.fields.numberOfPlayers == 5 then
        -- index ~= numberOfPlayers for the 5th entry
        PlayerSet.fields.numberOfPlayers = PlayerSet.fields.numberOfPlayers + 1
    end
    PlayerSet.applyNumberOfPlayers()
    PlayerSet.ui:toUI()
end

---
function PlayerSet.applyNumberOfPlayers()
    if type(PlayerSet.fields.numberOfPlayers) == "table" or PlayerSet.fields.numberOfPlayers > 2 then
        PlayerSet.fields.difficulty = {}
    else
        if PlayerSet.fields.numberOfPlayers == 1 then
            PlayerSet.fields.difficulty = "novice"
        else
            PlayerSet.fields.difficulty = {}
        end
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
function setSoundEnabled(player, value, id)
    PlayerSet.ui:fromUI(player, value, id)
end

---
function PlayerSet.updateSetupButton()
    if PlayerSet.ui then
        local properlySeatedPlayers = PlayerSet.getProperlySeatedPlayers()

        local minPlayerCount
        if type(PlayerSet.fields.numberOfPlayers) == "table" then
            minPlayerCount = 3
        elseif PlayerSet.fields.specialMode then
            minPlayerCount = 1
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
        specialMode = PlayerSet.fields.specialMode == true,
        numberOfPlayers = PlayerSet.fields.numberOfPlayers,
        difficulty = PlayerSet.fields.difficulty,
        riseOfIx = PlayerSet.fields.riseOfIx == true,
        epicMode = PlayerSet.fields.epicMode == true,
        immortality = PlayerSet.fields.immortality == true,
        goTo11 = PlayerSet.fields.goTo11 == true,
        leaderSelection = PlayerSet.fields.leaderSelection,
        soundEnabled = PlayerSet.fields.soundEnabled,
    })
end
