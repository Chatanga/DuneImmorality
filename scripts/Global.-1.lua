--[[
    The Global script:
    - register the modules,
    - call onLoad (and later onSave) on them.
    - show a UI or use the 'autoLoadedSettings' to set up the modules.
    That's all. When set up, the LeaderSelection module will proceed with the
    next step and finally call TurnControl.startGame to effectively start the
    game.

    In case you don't know, the source code for this mod is available at:
    https://github.com/Chatanga/DuneImmorality/tree/rakis
]]

-- Will be automatically replaced by the build timestamp.
local BUILD = 'TBD'

local MOD_NAME = 'Rakis Rising'

-- Do not load anything. Appropriate to work on the mod content in TTS without
-- interference from the scripts.
local constructionModeEnabled = false

-- For test purposes (the secondary table won't disappear as a side effect).
local autoLoadedSettings = nil

--[[
autoLoadedSettings = {
    language = "fr",
    numberOfPlayers = 6,
    hotSeat = true,
    firstPlayer = "random",
    randomizePlayerPositions = false,
    useContracts = true,
    legacy = false,
    merakon = false,
    riseOfIx = false,
    epicMode = false,
    immortality = false,
    goTo11 = false,
    leaderSelection = {
        Green = "jessica",
        Yellow = "gurneyHalleck",
        Red = "feydRauthaHarkonnen",
        Blue = "irulanCorrino",
        White = "muadDib",
        Purple = "shaddamCorrino",
    },
    horizontalHandLayout = true,
    soundEnabled = true,
    submitGameRankedGame = false,
}

autoLoadedSettings = {
    language = "en",
    numberOfPlayers = 4,
    hotSeat = true,
    firstPlayer = "Green",
    randomizePlayerPositions = false,
    useContracts = true,
    legacy = false,
    merakon = false,
    riseOfIx = false,
    epicMode = false,
    immortality = false,
    goTo11 = false,
    leaderSelection = {
        Green = "jessica",
        Yellow = "gurneyHalleck",
        Red = "feydRauthaHarkonnen",
        Blue = "irulanCorrino",
    },
    horizontalHandLayout = true,
    soundEnabled = true,
    submitGameRankedGame = true,
}

autoLoadedSettings = {
    language = "fr",
    numberOfPlayers = 1,
    hotSeat = true,
    firstPlayer = "Green",
    randomizePlayerPositions = false,
    difficulty = "expert",
    streamlinedRivals = false,
    useContracts = true,
    legacy = false,
    merakon = false,
    riseOfIx = false,
    epicMode = false,
    immortality = false,
    goTo11 = false,
    leaderSelection = {
        Green = "jessica",
        Yellow = "feydRauthaHarkonnen",
        Red = "stabanTuek",
    },
    horizontalHandLayout = true,
    soundEnabled = true,
    submitGameRankedGame = true,
}
]]

local Module = require("utils.Module")
local Helper = require("utils.Helper")
local XmlUI = require("utils.XmlUI")
local AcquireCard = require("utils.AcquireCard")
local I18N = require("utils.I18N")
local Dialog = require("utils.Dialog")

--[[
    Remember that 'require' must have a literal parameter, since it is not a
    real function, but simply a macro for 'luabundler'.

    Note that "CardEffect" is not here since it is always hard required by the
    other modules.
]]
local allModules = Module.registerModules({
    AcquireCard, -- To take advantage of Module.registerModuleRedirections.
    Action = require("Action"),
    Board = require("Board"),
    ChoamContractMarket = require("ChoamContractMarket"),
    Combat = require("Combat"),
    Commander = require("Commander"),
    ConflictCard = require("ConflictCard"),
    ShippingTrack = require("ShippingTrack"),
    Deck = require("Deck"),
    ScoreBoard = require("ScoreBoard"),
    Hagal = require("Hagal"),
    HagalCard = require("HagalCard"),
    ImperiumCard = require("ImperiumCard"),
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
    Rival = require("Rival"),
    TechMarket = require("TechMarket"),
    TechCard = require("TechCard"),
    TleilaxuResearch = require("TleilaxuResearch"),
    TleilaxuRow = require("TleilaxuRow"),
    ThroneRow = require("ThroneRow"),
    TurnControl = require("TurnControl"),
    Types = require("Types"),
    SubmitGame = require("SubmitGame"),
})

local Controller = {
    -- The view.
    ui = nil,
    -- The model.
    -- A 'xxx_all' member is not a UI field, but defines the options for the
    -- corresponding 'xxx' field.
    fields = {
        language_all = {
            en = "english",
            fr = "french",
        },
        language = "fr",
        virtualHotSeat = false,
        virtualHotSeatMode_all = {
            "onePlayerTwoRivals",
            "twoPlayersOneRival",
            "threePlayers",
            "fourPlayers",
            "twoTeams",
        },
        virtualHotSeatMode = {},
        firstPlayer = "random",
        firstPlayer_all = {
            random = "random",
            Green = "Green",
            Yellow = "Yellow",
            Blue = "Blue",
            Red = "Red",
        },
        randomizePlayerPositions = false,
        difficulty_all = allModules.Hagal.getDifficulties(),
        difficulty = {},
        rivalType_all = allModules.Rival.getRivalTypes(),
        rivalType = {},
        useContracts = true,
        legacy = false,
        merakon = {},
        riseOfIx = false,
        epicMode = {},
        immortality = false,
        goTo11 = {},
        leaderSelection_all = allModules.LeaderSelection.getSelectionMethods(4),
        leaderSelection = "reversePick",
        defaultLeaderPoolSize_range = { min = 4, max = 12 },
        defaultLeaderPoolSize = 9,
        defaultLeaderPoolSizeLabel = "-",
        tweakLeaderSelection = false,
        horizontalHandLayout = true,
        formalCombatPhase = false,
        soundEnabled = true,
        submitGameRankedGame = false,
    }
}

-- The game settings, set by the startup menu when pressing the "Setup" button
-- or automatically using the autoLoadedSettings variable.
local settings

--- TTS event handler.
function onLoad(scriptState)
    log("--------< " .. MOD_NAME .. " - " .. BUILD .. " >--------")

    -- All transient objects (mostly anchors, but also some zones) are destroyed
    -- at startup, then recreated in the 'onLoad' functions (and 'staticSetup'
    -- methods in case the game has already been set up).
    Helper.destroyTransientObjects()

    if constructionModeEnabled then
        -- Edit the player boards in a procedural way.
        if false then
            allModules.PlayBoard.rebuild()
        end
        -- Regenerate the decks in the localized cached areas.
        if false then
            allModules.Deck.rebuildPreloadAreas()
        end
        -- Regenerate the boards for each language.
        if false then
            allModules.Board.rebuildPreloadAreas()
        end
    else
        -- The destroyed objects need one frame to disappear and not interfere
        -- with the mod.
        Helper.onceFramesPassed(1).doAfter(function ()
            Dialog.loadStaticUI().doAfter(function ()
                asyncOnLoad(scriptState)
            end)
        end)
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

    -- Make it available to 'Helper.postError'.
    Global.setVar("saveInfo", {
        modname = MOD_NAME,
        build = BUILD,
        stable = state.stable or "prime",
    });

    -- TODO Detail dependencies? An explicit graph would be useful.
    allModules.ordered = {
        { name = "Locale", module = allModules.Locale },
        { name = "Action", module = allModules.Action },
        { name = "Board", module = allModules.Board },
        { name = "Pdf", module = allModules.Pdf },
        { name = "Music", module = allModules.Music },
        { name = "Deck", module = allModules.Deck },
        { name = "ScoreBoard", module = allModules.ScoreBoard },
        { name = "Hagal", module = allModules.Hagal },
        { name = "Commander", module = allModules.Commander },
        { name = "PlayBoard", module = allModules.PlayBoard },
        { name = "ShippingTrack", module = allModules.ShippingTrack },
        { name = "TechMarket", module = allModules.TechMarket },
        { name = "MainBoard", module = allModules.MainBoard },
        { name = "Combat", module = allModules.Combat },
        { name = "ChoamContractMarket", module = allModules.ChoamContractMarket },
        { name = "InfluenceTrack", module = allModules.InfluenceTrack },
        { name = "Intrigue", module = allModules.Intrigue },
        { name = "ImperiumRow", module = allModules.ImperiumRow },
        { name = "Reserve", module = allModules.Reserve },
        { name = "TleilaxuResearch", module = allModules.TleilaxuResearch },
        { name = "TleilaxuRow", module = allModules.TleilaxuRow },
        { name = "ThroneRow", module = allModules.ThroneRow },
        { name = "TurnControl", module = allModules.TurnControl },
        { name = "LeaderSelection", module = allModules.LeaderSelection },
        { name = "SubmitGame", module = allModules.SubmitGame },
    }

    -- We cannot use Module.callOnAllRegisteredModules("onLoad", state),
    -- because the order matter, now that we reload with "staticSetUp" (for the
    -- same reason setUp is ordered too).
    for i, moduleInfo in ipairs(allModules.ordered) do
        --Helper.dump(i, " - Load module", moduleInfo.name)
        moduleInfo.module.onLoad(state)
        Helper.emitEvent("loaded", moduleInfo.name)
    end
    --Helper.dump("Done loading all modules")

    -- List the TTS events we want to make available in the modules.
    Module.registerModuleRedirections({
        "onPlayerChangeColor",
        "onPlayerConnect",
        "onPlayerDisconnect",
        "onObjectEnterZone",
        "onObjectLeaveZone",
        "onObjectEnterContainer",
        "onObjectLeaveContainer",
        "onObjectDrop",
    })

    local uiAlreadySetUp = false
    if not state.settings then
        if autoLoadedSettings then
            I18N.setLocale(autoLoadedSettings.language or "en")
            Helper.onceFramesPassed(1).doAfter(function ()
                setUp(autoLoadedSettings)
            end)
        else
            Controller.ui = XmlUI.new(Global, "setupPane", Controller.fields)
            Controller.ui:show()
            I18N.setLocale(Controller.fields.language)
            Controller.updateDefaultLeaderPoolSizeLabel()
            Controller.updateSetupButton()
            uiAlreadySetUp = true
        end
    end
    if not uiAlreadySetUp then
        -- Force the translation of the whole UI (not restricted to the "setupPane" actually)
        -- since the other panels are also used after the setup.
        XmlUI.new(Global)
    end
end

--- TTS event handler.
function onSave()
    if constructionModeEnabled then
        return
    end

    if settings then
        local stable = Helper.isStabilized(true)

        --[[
            TTS will ignore the ongoing save if:
            - it has the same (serialized) value as the previous,
            - the world hasn't physically changed meanwhile.
            That's why we store the date and "shake" the world
            when we detect an unstable save (ie. a save occuring
            while one or more continuations are still alive).
        ]]

        if not stable then
            -- Shake the world a bit.
            Wait.time(function ()
                local primaryTable = getObjectFromGUID("2b4b92")
                primaryTable.setName(primaryTable.getName() == "" and "..." or "")
            end, 0.5, 2)
        end

        local savedState = {
            date = os.time(),
            settings = settings,
            stable = stable and "stable" or "unstable",
        }

        -- FIXME Only call it for the same modules for which "onLoad" has been called.
        Module.callOnAllRegisteredModules("onSave", savedState)
        return JSON.encode(savedState)
    else
        -- We do not save anything until the game is set up.
        return ''
    end
end

--- TTS event handler.
function onObjectDestroy(object)
    if object.getGUID() == "2b4b92" then
        Module.unregisterAllModuleRedirections()
        --Helper.destroyTransientObjects()
        Helper.dump("Bye!")
    end
end

--- Set up the game, an irreversible operation.
function setUp(newSettings)
    assert(newSettings)

    local continuation = Helper.createContinuation("setUp")
    if newSettings.randomizePlayerPositions then
        Helper.randomizePlayerPositions(Controller.getProperlySeatedPlayers()).doAfter(continuation.run)
    else
        continuation.run()
    end

    continuation.doAfter(function ()
        -- Not assigned before in order to avoid saving anything.
        settings = newSettings

        local properlySeatedPlayers = Controller.getProperlySeatedPlayers()
        local activeOpponents = Controller.findActiveOpponents(properlySeatedPlayers, newSettings.numberOfPlayers)
        runSetUp(1, activeOpponents)
    end)

    -- TurnControl.start() is called by "LeaderSelection" asynchronously,
    -- effectively starting the game.
end

--- Set up each module, one by one.
function runSetUp(index, activeOpponents)
    local moduleInfo = allModules.ordered[index]
    if moduleInfo then
        --Helper.dump(index, " - Set up module", moduleInfo.name)
        local nextContinuation = moduleInfo.module.setUp(settings, activeOpponents)
        if not nextContinuation then
            nextContinuation = Helper.createContinuation("runSetUp")
            nextContinuation.run()
        end
        nextContinuation.doAfter(Helper.partialApply(runSetUp, index + 1, activeOpponents))
    else
        --Helper.dump("Done setting all modules")
    end
end

--- TTS event handler.
function onPlayerChangeColor()
    Controller.updateSetupButton()
    Controller.updateSelectionMethods()
end

--- TTS event handler.
function onPlayerConnect()
    Controller.updateSetupButton()
    Controller.updateSelectionMethods()
end

--- TTS event handler.
function onPlayerDisconnect()
    Controller.updateSetupButton()
    Controller.updateSelectionMethods()
end

--- UI callback (cf. XML).
function setLanguage(player, value, id)
    Controller.ui:fromUI(player, value, id)
    -- The locale is changed in real time by the UI, but not the test mode.
    I18N.setLocale(Controller.fields.language)
    Controller.ui:toUI()
    Controller.updateDefaultLeaderPoolSizeLabel()
end

--- UI callback (cf. XML).
function setFirstPlayer(player, value, id)
    Controller.ui:fromUI(player, value, id)
end

--- UI callback (cf. XML).
function setRandomizePlayerPositions(player, value, id)
    Controller.ui:fromUI(player, value, id)
end

--- UI callback (cf. XML).
function setVirtualHotSeat(player, value, id)
    Controller.ui:fromUI(player, value, id)
    if value == "True" then
        Controller.fields.virtualHotSeatMode = 1
    else
        Controller.fields.virtualHotSeatMode = {}
    end
    Controller.applyVirtualHotSeatMode()
    Controller.ui:toUI()
end

--- UI callback (cf. XML).
function setVirtualHotSeatMode(player, value, id)
    Controller.ui:fromUI(player, value, id)
    Controller.applyVirtualHotSeatMode()
    Controller.ui:toUI()
end

--- UI callback (cf. XML).
function setDifficulty(player, value, id)
    Controller.ui:fromUI(player, value, id)
end

--- UI callback (cf. XML).
function setRivalType(player, value, id)
    Controller.ui:fromUI(player, value, id)
end

--- UI callback (cf. XML).
function setHotSeat(player, value, id)
    Controller.ui:fromUI(player, value, id)
    Controller.updateSetupButton()
end

--- UI callback (cf. XML).
function setUseContracts(player, value, id)
    Controller.ui:fromUI(player, value, id)
end

--- UI callback (cf. XML).
function setLegacy(player, value, id)
    Controller.ui:fromUI(player, value, id)
    if value == "True" then
        Controller.fields.merakon = false
    else
        Controller.fields.merakon = {}
    end
    Controller.ui:toUI()
end

--- UI callback (cf. XML).
function setMerakon(player, value, id)
    Controller.ui:fromUI(player, value, id)
end

--- UI callback (cf. XML).
function setRiseOfIx(player, value, id)
    Controller.ui:fromUI(player, value, id)
    if value == "True" then
        Controller.fields.epicMode = false
    else
        Controller.fields.epicMode = {}
    end
    Controller.ui:toUI()
end

--- UI callback (cf. XML).
function setEpicMode(player, value, id)
    Controller.ui:fromUI(player, value, id)
end

--- UI callback (cf. XML).
function setImmortality(player, value, id)
    Controller.ui:fromUI(player, value, id)
    if value == "True" then
        Controller.fields.goTo11 = false
    else
        Controller.fields.goTo11 = {}
    end
    Controller.ui:toUI()
end

--- UI callback (cf. XML).
function setGoTo11(player, value, id)
    Controller.ui:fromUI(player, value, id)
end

--- UI callback (cf. XML).
function setLeaderSelection(player, value, id)
    Controller.ui:fromUI(player, value, id)
end

--- UI callback (cf. XML).
function setDefaultLeaderPoolSize(player, value, id)
    Controller.ui:fromUI(player, value, id)
    Controller.updateDefaultLeaderPoolSizeLabel()
end

--- UI callback (cf. XML).
function setTweakLeaderSelection(player, value, id)
    Controller.ui:fromUI(player, value, id)
end

--- UI callback (cf. XML).
function setHorizontalHandLayout(player, value, id)
    Controller.ui:fromUI(player, value, id)
end

--- UI callback (cf. XML).
function setFormalCombatPhase(player, value, id)
    Controller.ui:fromUI(player, value, id)
end

--- UI callback (cf. XML).
function setSoundEnabled(player, value, id)
    Controller.ui:fromUI(player, value, id)
end

--- UI callback (cf. XML).
function submitGameRankedGame(player, value, id)
    Controller.ui:fromUI(player, value, id)
    local seatedPlayers = getSeatedPlayers()
    if #seatedPlayers <= 3 then
        Controller.fields.submitGameRankedGame = false
        broadcastToAll(I18N("need4Players"), Color.fromString("White"))
    end
    Controller.ui:toUI()
end

--- UI callback (cf. XML).
function submitGameTournament(player, value, id)
    Controller.ui:fromUI(player, value, id)
    if value == "True" then
        Controller.fields.submitGameRankedGame = false
    end
    Controller.ui:toUI()
end

--- UI callback (cf. XML).
function setUpFromUI()
    if not Controller.ui then
        Helper.dump("No UI. Bouncing button?")
        return
    end

    Controller.ui:hide()
    Controller.ui = nil

    local numberOfPlayers = Controller.getNumberOfPlayers(Controller.fields.virtualHotSeatMode)

    setUp({
        language = Controller.fields.language,
        numberOfPlayers = numberOfPlayers,
        hotSeat = not Controller.isUndefined(Controller.fields.virtualHotSeatMode),
        firstPlayer = Controller.fields.firstPlayer,
        randomizePlayerPositions = Controller.fields.randomizePlayerPositions == true,
        difficulty = Controller.fields.difficulty,
        streamlinedRivals = Controller.fields.rivalType == "streamlined",
        useContracts = Controller.fields.useContracts == true or numberOfPlayers == 6,
        legacy = Controller.fields.legacy == true,
        merakon = Controller.fields.merakon == true,
        riseOfIx = Controller.fields.riseOfIx == true,
        epicMode = Controller.fields.epicMode == true,
        immortality = Controller.fields.immortality == true,
        goTo11 = Controller.fields.goTo11 == true,
        leaderSelection = Controller.fields.leaderSelection,
        defaultLeaderPoolSize = tonumber(Controller.fields.defaultLeaderPoolSize),
        tweakLeaderSelection = Controller.fields.tweakLeaderSelection,
        horizontalHandLayout = Controller.fields.horizontalHandLayout,
        formalCombatPhase = Controller.fields.formalCombatPhase,
        soundEnabled = Controller.fields.soundEnabled,
        submitGameRankedGame = Controller.fields.submitGameRankedGame,
    })
end

--- Return the mapping between (player) colors and opponent types. An opponent
--- type could be:
--- - a Player instance,
--- - the "rival" string for an automated rival (or House Hagal in the 1P mode),
--- - the "puppet" string for a playable but unseated color in hotseat mode.
--- Later, in opponents (not activeOppenents), Player instances and "puppet" are
--- replaced by the "human" string.
function Controller.findActiveOpponents(properlySeatedPlayers, numberOfPlayers)
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

--- return only the (colors of the) legitimate player depending on the selected
--- mode (1-4P or 6P).
function Controller.getProperlySeatedPlayers()
    local seatedPlayers = getSeatedPlayers()

    local authorizedColors = {
        Green = true,
        Yellow = true,
        Blue = true,
        Red = true,
        Purple = #seatedPlayers == 6 or Controller.fields.virtualHotSeatMode == 5,
        White = #seatedPlayers == 6 or Controller.fields.virtualHotSeatMode == 5,
    }

    local properlySeatedPlayers = {}
    for _, color in ipairs(seatedPlayers) do
        if authorizedColors[color] then
            table.insert(properlySeatedPlayers, color)
        end
    end
    return properlySeatedPlayers
end

---
function Controller.applyVirtualHotSeatMode()
    local numberOfPlayers = Controller.getNumberOfPlayers(Controller.fields.virtualHotSeatMode)

    if Controller.isUndefined(Controller.fields.virtualHotSeatMode) or numberOfPlayers > 1 then
        Controller.fields.difficulty = {}
    else Controller.isUndefined(Controller.fields.difficulty)
        Controller.fields.difficulty = "novice"
    end

    if Controller.isUndefined(Controller.fields.virtualHotSeatMode) or numberOfPlayers ~= 2 then
        Controller.fields.rivalType = {}
    else Controller.isUndefined(Controller.fields.rivalType)
        Controller.fields.rivalType = "streamlined"
    end

    Controller.fields.leaderSelection_all = allModules.LeaderSelection.getSelectionMethods(numberOfPlayers)
    if numberOfPlayers == 6 then
        Controller.fields.useContracts = {}
    elseif Controller.isUndefined(Controller.fields.useContracts) then
        Controller.fields.useContracts = true
    end

    Controller.updateSetupButton()
    Controller.ui:toUI()
end

---
function Controller.getNumberOfPlayers(virtualHotSeatMode)
    local numberOfPlayers
    if Controller.isUndefined(virtualHotSeatMode) then
        numberOfPlayers = math.min(6, #Controller.getProperlySeatedPlayers())
    else
        local toNumberOfPlayers = { 1, 2, 3, 4, 6 }
        numberOfPlayers = toNumberOfPlayers[virtualHotSeatMode]
    end
    return numberOfPlayers
end

---
function Controller.updateSelectionMethods()
    if Controller.ui then
        local numberOfPlayers = Controller.getNumberOfPlayers(Controller.fields.virtualHotSeatMode)
        Controller.fields.leaderSelection_all = allModules.LeaderSelection.getSelectionMethods(numberOfPlayers)

        Controller.ui:toUI()
    end
end

---
function Controller.updateSetupButton()
    if Controller.ui then
        local numberOfPlayers = Controller.getNumberOfPlayers(Controller.fields.virtualHotSeatMode)
        Controller.fields.leaderSelection_all = allModules.LeaderSelection.getSelectionMethods(numberOfPlayers)

        local properlySeatedPlayers = Controller.getProperlySeatedPlayers()

        local minPlayerCount
        if Controller.isUndefined(Controller.fields.virtualHotSeatMode) then
            minPlayerCount = 3
        else
            minPlayerCount = 1
        end

        if #properlySeatedPlayers >= minPlayerCount then
            Controller.ui:setButtonI18N("setUpButton", "setup", true)
        else
            Controller.ui:setButtonI18N("setUpButton", "notEnoughPlayers", false)
        end

        Controller.ui:toUI()
    end
end

---
function Controller.updateDefaultLeaderPoolSizeLabel()
    local value = Controller.fields.defaultLeaderPoolSize
    Controller.fields.defaultLeaderPoolSizeLabel = I18N("defaultLeaderPoolSizeLabel", { value = value } )
    -- Do not use Controller.ui:toUI() to avoid breaking the current UI operation.
    self.UI.setValue("defaultLeaderPoolSizeLabel", Controller.fields.defaultLeaderPoolSizeLabel)
end

---
function Controller.isUndefined(value)
    return value == nil or type(value) == "table"
end
