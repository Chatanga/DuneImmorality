local BUILD = 'TBD'

-- Do not load anything. Appropriate to work on the mod content without
-- interference.
local constructionModeEnabled = false

-- For test purposes.
local autoLoadedSettings

--[[
autoLoadedSettings = {
    language = "en",
    randomizePlayerPositions = false,
    numberOfPlayers = 4,
    hotSeat = true,
    useContracts = true,
    riseOfIx = false,
    epicMode = false,
    immortality = false,
    goTo11 = false,
    leaderSelection = {
        --Green = "jessicaAtreides",
        Green = "amberMetulli",
        Yellow = "gurneyHalleck",
        Red = "irulanCorrino",
        Blue = "feydRauthaHarkonnen",
        Teal = "muadDib",
        Brown = "shaddamCorrino",
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
    ChoamContractMarket = require("ChoamContractMarket"),
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
            Red = true,
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
        gameModeEnabled = false,
        gameMode_all = {
            "1 (+2)",
            "2 (+1)",
            "3",
            "4",
            "2 x 3"
        },
        gameMode = {},
        hotSeat = {},
        randomizePlayerPositions = false,
        difficulty_all = Helper.map(allModules.Hagal.getDifficulties(), function (_, v) return v.name end),
        difficulty = {},
        useContracts = true,
        riseOfIx = false,
        epicMode = {},
        immortality = false,
        goTo11 = {},
        leaderSelection_all = allModules.LeaderSelection.getSelectionMethods(4),
        leaderSelection = "reversePick",
        defaultLeaderPoolSize_range = { min = 4, max = 12 },
        defaultLeaderPoolSize = 8,
        defaultLeaderPoolSizeLabel = "-",
        tweakLeaderSelection = false,
        soundEnabled = true,
    }
}

local settings

---
function onLoad(scriptState)
    log("--------< Dune Uprising - " .. BUILD .. " >--------")
    Helper.destroyTransientObjects()

    if constructionModeEnabled then
        --allModules.PlayBoard.rebuild()
        --allModules.MainBoard.rebuild()
    else
        -- The destroyed objects need one frame to disappear and not interfere with the mod.
        Wait.frames(function ()
            asyncOnLoad(scriptState)
        end, 1)
    end
end

---
function asyncOnLoad(scriptState)
    local tables = Helper.resolveGUIDs(false, {
        primaryTable = "2b4b92",
        secondaryTable = "662ced",
    })
    Helper.noPhysicsNorPlay(
        tables.primaryTable,
        tables.secondaryTable)

    local state = scriptState ~= "" and JSON.decode(scriptState) or {}
    settings = state.settings

    allModules.Locale.onLoad(state)
    allModules.Action.onLoad(state)

    allModules.ordered = {
        allModules.Pdf,
        allModules.Music,
        allModules.Deck,
        allModules.ScoreBoard,
        allModules.Hagal,
        allModules.PlayBoard,
        allModules.Combat,
        allModules.LeaderSelection,
        allModules.MainBoard,
        allModules.ShipmentTrack,
        allModules.TechMarket,
        allModules.ChoamContractMarket,
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
        "onObjectEnterContainer",
        "onObjectLeaveContainer",
    })

    if not state.settings then
        if autoLoadedSettings then
            Helper.onceFramesPassed(1).doAfter(function ()
                setUp(autoLoadedSettings)
            end)
        else
            PlayerSet.ui = XmlUI.new(Global, "setupPane", PlayerSet.fields)
            PlayerSet.ui:show()
            PlayerSet.updateDefaultLeaderPoolSizeLabel()
            PlayerSet.updateSetupButton()
        end
    end
end

---
function onSave()
    --Helper.dumpFunction("onSave")
    if constructionModeEnabled then
        return
    end

    if not Helper.isStabilized() then
        Helper.dump("Unstable save!")
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
function onDestroy()
    Helper.dump("onDestroy")
    Module.unregisterAllModuleRedirections()
    Helper.dump("destroyTransientObjects")
    Helper.destroyTransientObjects()
    Helper.dump("done")
end

---
function setUp(newSettings)
    assert(newSettings)
    I18N.setLocale(newSettings.language)

    local properlySeatedPlayers = PlayerSet.getProperlySeatedPlayers()
    if not newSettings.hotSeat then
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
    local colorsByPreference = { "Green", "Red", "Yellow", "Blue", "Brown", "Teal" }

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
    if #Helper.getKeys(activeOpponents) == 6 then
        orderedColors = { "Green", "Brown", "Yellow", "Blue", "Teal", "Red" }
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
    PlayerSet.updateDefaultLeaderPoolSizeLabel()
end

---
function setRandomizePlayerPositions(player, value, id)
    PlayerSet.ui:fromUI(player, value, id)
end

---
function setGameModeEnabled(player, value, id)
    Helper.dumpFunction("setGameModeEnabled", player, value, id)
    PlayerSet.ui:fromUI(player, value, id)
    if value == "True" then
        PlayerSet.fields.gameMode = 1
    else
        PlayerSet.fields.gameMode = {}
    end
    PlayerSet.applyNumberOfPlayers()
    PlayerSet.ui:toUI()
end

---
function setGameMode(player, value, id)
    PlayerSet.ui:fromUI(player, value, id)
    PlayerSet.applyNumberOfPlayers()
    PlayerSet.ui:toUI()
end

function PlayerSet.applyNumberOfPlayers()
    --PlayerSet.fields.hotSeat = type(PlayerSet.fields.gameMode) ~= "table" and false or {}

    if type(PlayerSet.fields.gameMode) == "table" or PlayerSet.fields.gameMode > 2 then
        PlayerSet.fields.difficulty = {}
    else
        PlayerSet.fields.difficulty = "novice"
    end

    PlayerSet.fields.hotSeat = (type(PlayerSet.fields.gameMode) == "table" or PlayerSet.fields.gameMode == 1) and {} or false

    local numberOfPlayers
    if type(PlayerSet.fields.gameMode) == "table" then
        numberOfPlayers = PlayerSet.getProperlySeatedPlayers()
    else
        numberOfPlayers = PlayerSet.fields.gameMode + math.floor(PlayerSet.fields.gameMode / 5)
    end
    Helper.dump("numberOfPlayers:", numberOfPlayers)

    PlayerSet.fields.leaderSelection_all = allModules.LeaderSelection.getSelectionMethods(numberOfPlayers)
    if PlayerSet.fields.gameMode == 5 then
        PlayerSet.fields.useContracts = {}
        PlayerSet.fields.color_all = {
            Green = true,
            Yellow = true,
            Blue = true,
            Red = true,
            Brown = true,
            Teal = true,
        }
    else
        PlayerSet.fields.useContracts = true
        PlayerSet.fields.color_all = {
            Green = true,
            Yellow = true,
            Blue = true,
            Red = true,
        }
    end

    PlayerSet.updateSetupButton()
    PlayerSet.ui:toUI()
end

---
function setDifficulty(player, value, id)
    PlayerSet.ui:fromUI(player, value, id)
end

---
function setHotSeat(player, value, id)
    PlayerSet.ui:fromUI(player, value, id)
    PlayerSet.updateSetupButton()
end

---
function setUseContracts(player, value, id)
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
function setDefaultLeaderPoolSize(player, value, id)
    PlayerSet.ui:fromUI(player, value, id)
    PlayerSet.updateDefaultLeaderPoolSizeLabel()
end

---
function setTweakLeaderSelection(player, value, id)
    Helper.dumpFunction("setTweakLeaderSelection", player, value, id)
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
        if type(PlayerSet.fields.gameMode) == "table" then
            minPlayerCount = 3
        elseif PlayerSet.fields.hotSeat then
            minPlayerCount = 1
        else
            minPlayerCount = math.min(2, PlayerSet.fields.gameMode)
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
function PlayerSet.updateDefaultLeaderPoolSizeLabel()
    local value = PlayerSet.fields.defaultLeaderPoolSize
    PlayerSet.fields.defaultLeaderPoolSizeLabel = I18N("defaultLeaderPoolSizeLabel", { value = value } )
    -- Do not use PlayerSet.ui:toUI() to avoid breaking the current UI operation.
    self.UI.setValue("defaultLeaderPoolSizeLabel", PlayerSet.fields.defaultLeaderPoolSizeLabel)
end

---
function setUpFromUI()
    PlayerSet.ui:hide()
    PlayerSet.ui = nil

    setUp({
        language = PlayerSet.fields.language,
        numberOfPlayers = PlayerSet.fields.gameMode + math.floor(PlayerSet.fields.gameMode / 5),
        hotSeat = PlayerSet.fields.hotSeat == true,
        randomizePlayerPositions = PlayerSet.fields.randomizePlayerPositions == true,
        difficulty = PlayerSet.fields.difficulty,
        useContracts = PlayerSet.fields.useContracts == true,
        riseOfIx = PlayerSet.fields.riseOfIx == true,
        epicMode = PlayerSet.fields.epicMode == true,
        immortality = PlayerSet.fields.immortality == true,
        goTo11 = PlayerSet.fields.goTo11 == true,
        leaderSelection = PlayerSet.fields.leaderSelection,
        defaultLeaderPoolSize = tonumber(PlayerSet.fields.defaultLeaderPoolSize),
        tweakLeaderSelection = PlayerSet.fields.tweakLeaderSelection,
        soundEnabled = PlayerSet.fields.soundEnabled,
    })
end
