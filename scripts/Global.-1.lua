--[[
    The Global script:
    - register the modules,
    - call onLoad (and later onSave) on them.
    - show a UI or use the 'autoLoadedSettings' to set up the modules.
    That's all. When set up, the LeaderSelection module will proceed with the
    next step and finally call TurnControl.startGame to effectively start the
    game.

    In case you don't know, the source code for this mod is available at:
    https://github.com/Chatanga/DuneImmorality
]]

-- Will be automatically replaced by the build timestamp.
local BUILD = 'TBD'

local MOD_NAME = 'Spice Flow + Bloodlines'

-- Do not load anything. Appropriate to work on the mod content in TTS without
-- interference from the scripts.
local constructionModeEnabled = false

-- For test purposes (the secondary table won't disappear as a side effect).
local autoLoadedSettings = nil

--[[
]]
autoLoadedSettings = {
    language = "fr",
    hotSeat = true,
    numberOfPlayers = 4,
    randomizePlayerPositions = false,
    riseOfIx = true,
    epicMode = false,
    immortality = false,
    goTo11 = false,
    bloodlines = true,
    leaderSelection = {
        Green = "paulAtreides",
        Yellow = "duncanIdaho",
        Red = "chani",
        Blue = "letoAtreides",
    },
    formalCombatPhase = false,
    soundEnabled = true,
    variant = "arrakeenScouts",
}

GameTableGUIDs = {
    primary = "2b4b92",
    secondary = "662ced"
}

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
    ArrakeenScouts = require("ArrakeenScouts"),
    Combat = require("Combat"),
    ConflictCard = require("ConflictCard"),
    ShippingTrack = require("ShippingTrack"),
    Deck = require("Deck"),
    ScoreBoard = require("ScoreBoard"),
    DynamicBonus = require("DynamicBonus"),
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
    SardaukarCommander = require("SardaukarCommander"),
    SardaukarCommanderSkillCard = require("SardaukarCommanderSkillCard"),
    TechMarket = require("TechMarket"),
    TechCard = require("TechCard"),
    TleilaxuResearch = require("TleilaxuResearch"),
    TleilaxuRow = require("TleilaxuRow"),
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
        },
        virtualHotSeatMode = XmlUI.HIDDEN,
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
        difficulty = XmlUI.HIDDEN,
        autoTurnInSolo = XmlUI.DISABLED,
        imperiumRowChurn = XmlUI.DISABLED,
        brutalEscalation = XmlUI.DISABLED,
        expertDeployment = XmlUI.DISABLED,
        smartPolitics = XmlUI.DISABLED,
        riseOfIx = false,
        epicMode = XmlUI.DISABLED,
        immortality = false,
        goTo11 = XmlUI.DISABLED,
        bloodlines = true,
        ixAmbassy = true,
        ixAmbassyWithIx = false,
        leaderSelection_all = allModules.LeaderSelection.getSelectionMethods(4),
        leaderSelection = "reversePick",
        leaderPoolSize_range = { min = 4, max = 12 },
        leaderPoolSize = 9,
        leaderPoolSizeLabel = "-",
        tweakLeaderSelection = true,
        variant_all = {
            none = "none",
            arrakeenScouts = "arrakeenScouts"
        },
        variant = "none",
        formalCombatPhase = false,
        soundEnabled = true,
        submitGameRankedGame = XmlUI.DISABLED,
        submitGameTournament = XmlUI.DISABLED,
    }
}

-- The game settings, set by the startup menu when pressing the "Setup" button
-- or automatically using the autoLoadedSettings variable.
local settings

--- TTS event handler.
---@param scriptState string
function onLoad(scriptState)
    log("--------< " .. MOD_NAME .. " - " .. BUILD .. " >--------")

    -- All transient objects (mostly anchors, but also some zones) are destroyed
    -- at startup, then recreated in the 'onLoad' functions (and 'staticSetup'
    -- methods in case the game has already been set up).
    Helper.destroyTransientObjects()

    -- These 3 rebuild functions work the same way. They modify the otherwise
    -- static content of the game. As such, you need to save the mod as the new
    -- "Flow_Base", then call "build.py --full" to update the local skeleton
    -- file. After that, "build.py" or "build.py --upload" is enough to rebuild
    -- the mod.
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

---@param scriptState string
function asyncOnLoad(scriptState)
    local tables = Helper.resolveGUIDs(false, {
        primaryTable = GameTableGUIDs.primary,
        secondaryTable = GameTableGUIDs.secondary,
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
        { name = "ArrakeenScouts", module = allModules.ArrakeenScouts },
        { name = "Pdf", module = allModules.Pdf },
        { name = "Music", module = allModules.Music },
        { name = "Deck", module = allModules.Deck },
        { name = "ScoreBoard", module = allModules.ScoreBoard },
        { name = "Hagal", module = allModules.Hagal },
        { name = "PlayBoard", module = allModules.PlayBoard },
        { name = "ShippingTrack", module = allModules.ShippingTrack },
        { name = "TechMarket", module = allModules.TechMarket },
        { name = "MainBoard", module = allModules.MainBoard },
        { name = "Combat", module = allModules.Combat },
        { name = "InfluenceTrack", module = allModules.InfluenceTrack },
        { name = "Intrigue", module = allModules.Intrigue },
        { name = "ImperiumRow", module = allModules.ImperiumRow },
        { name = "Reserve", module = allModules.Reserve },
        { name = "SardaukarCommander", module = allModules.SardaukarCommander },
        { name = "TleilaxuResearch", module = allModules.TleilaxuResearch },
        { name = "TleilaxuRow", module = allModules.TleilaxuRow },
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
            Controller.extensionUi = XmlUI.new(Global, "extensionSetupPane", Controller.fields)
            Controller.extensionUi:show()
            Controller.soloUi = XmlUI.new(Global, "soloSetupPane", Controller.fields)
            I18N.setLocale(Controller.fields.language)
            Controller.updateLeaderPoolSizeLabel()
            Controller.updateSetupButton()
            Controller.ui:toUI()
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
                local primaryTable = getObjectFromGUID(GameTableGUIDs.primary)
                primaryTable.setName(primaryTable.getName() == "" and "..." or "")
            end, 0.5, 2)
        end

        local savedState = {
            date = os.time(),
            settings = settings,
            stable = stable and "stable" or "unstable",
        }

        -- TODO Only call it for the same modules for which "onLoad" has been called.
        Module.callOnAllRegisteredModules("onSave", savedState)
        return JSON.encode(savedState)
    else
        -- We do not save anything until the game is set up.
        return ''
    end
end

--- TTS event handler.
---@param object Object
function onObjectDestroy(object)
    if object.getGUID() == GameTableGUIDs.primary then
        Module.unregisterAllModuleRedirections()
        --Helper.destroyTransientObjects()
        Helper.dump("Bye!")
    end
end

--- Set up the game, an irreversible operation.
---@param newSettings Settings
function setUp(newSettings)
    assert(newSettings)

    assert((not newSettings.epicMode) or newSettings.riseOfIx)
    assert((not newSettings.ixAmbassy) or (not newSettings.riseOfIx))
    assert((not newSettings.goTo11) or newSettings.immortality)

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
---@param index integer
---@param activeOpponents table<PlayerColor, ActiveOpponent>
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
    if Controller.ui then
        Controller.updateSetupButton()
        Controller.updateSelectionMethods()
        Controller.ui:toUI()
    end
end

--- TTS event handler.
function onPlayerConnect()
    if Controller.ui then
        Controller.updateSetupButton()
        Controller.updateSelectionMethods()
        Controller.ui:toUI()
    end
end

--- TTS event handler.
function onPlayerDisconnect()
    if Controller.ui then
        Controller.updateSetupButton()
        Controller.updateSelectionMethods()
        Controller.ui:toUI()
    end
end

--- Generic UI callback (cf. XML).
function setAnyField(player, value, id)
    Controller.ui:fromUI(player, value, id)
end

--- UI callback (cf. XML).
function setLanguage(player, value, id)
    Controller.ui:fromUI(player, value, id)
    -- The locale is changed in real time by the UI, but not the test mode.
    I18N.setLocale(Controller.fields.language)
    Controller.updateLeaderPoolSizeLabel()
    Controller.ui:toUI()
end

--- UI callback (cf. XML).
function setVirtualHotSeat(player, value, id)
    Controller.ui:fromUI(player, value, id)
    if Controller.fields.virtualHotSeat then
        Controller.fields.virtualHotSeatMode = 1
    else
        Controller.fields.virtualHotSeatMode = XmlUI.HIDDEN
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
    if Helper.isElementOf(Controller.fields.difficulty, { "novice", "veteran" }) then
        Controller.fields.brutalEscalation = false
        Controller.fields.expertDeployment = false
        Controller.fields.smartPolitics = false
    else
        Controller.fields.brutalEscalation = true
        Controller.fields.expertDeployment = true
        Controller.fields.smartPolitics = true
    end
    Controller.ui:toUI()
end

--- UI callback (cf. XML).
function setHotSeat(player, value, id)
    Controller.ui:fromUI(player, value, id)
    Controller.updateSetupButton()
    Controller.ui:toUI()
end

--- UI callback (cf. XML).
function setRiseOfIx(player, value, id)
    Controller.ui:fromUI(player, value, id)
    if Controller.fields.riseOfIx then
        Controller.fields.epicMode = false
        Controller.fields.ixAmbassy = XmlUI.DISABLED
        Controller.fields.ixAmbassyWithIx = XmlUI.DISABLED
    else
        Controller.fields.epicMode = XmlUI.DISABLED
        Controller.ui:fromUI(player, value, id)
        if Controller.fields.bloodlines and XmlUI.isDisabled(Controller.fields.ixAmbassy) then
            Controller.fields.ixAmbassy = true
            Controller.fields.ixAmbassyWithIx = false
        end
    end
    Controller.ui:toUI()
end

--- UI callback (cf. XML).
function setImmortality(player, value, id)
    Controller.ui:fromUI(player, value, id)
    if Controller.fields.immortality then
        Controller.fields.goTo11 = false
    else
        Controller.fields.goTo11 = XmlUI.DISABLED
    end
    Controller.ui:toUI()
end

--- UI callback (cf. XML).
function setBloodlines(player, value, id)
    Controller.ui:fromUI(player, value, id)
    if Controller.fields.bloodlines then
        Controller.fields.ixAmbassy = true
        Controller.fields.ixAmbassyWithIx = false
    else
        Controller.fields.ixAmbassy = XmlUI.DISABLED
        Controller.fields.ixAmbassyWithIx = XmlUI.DISABLED
    end
    Controller.ui:toUI()
end

--- UI callback (cf. XML).
function setIxAmbassy(player, value, id)
    Controller.ui:fromUI(player, value, id)
    if Controller.fields.ixAmbassy then
        Controller.fields.ixAmbassyWithIx = false
    else
        Controller.fields.ixAmbassyWithIx = XmlUI.DISABLED
    end
    Controller.ui:toUI()
end

--- UI callback (cf. XML).
function setLeaderPoolSize(player, value, id)
    Controller.ui:fromUI(player, value, id)
    Controller.updateLeaderPoolSizeLabel()
    -- Do not use Controller.ui:toUI() to avoid breaking the current UI operation.
    self.UI.setValue("leaderPoolSizeLabel", Controller.fields.leaderPoolSizeLabel)
end

--- UI callback (cf. XML).
function setUpFromUI()
    if not Controller.ui then
        Helper.dump("No UI. Bouncing button?")
        return
    end

    Controller.ui:hide()
    Controller.ui = nil
    Controller.extensionUi:hide()
    Controller.extensionUi = nil
    Controller.soloUi:hide()
    Controller.soloUi = nil

    local numberOfPlayers = Controller.getNumberOfPlayers(Controller.fields.virtualHotSeatMode)

    ---@alias Settings {
    --- language: string,
    --- numberOfPlayers: 1|2|3|4,
    --- hotSeat: boolean,
    --- firstPlayer: PlayerColor|"random",
    --- randomizePlayerPositions: boolean,
    --- difficulty?: string,
    --- autoTurnInSolo: boolean,
    --- imperiumRowChurn: boolean,
    --- streamlinedRivals: boolean,
    --- brutalEscalation: boolean,
    --- expertDeployment: boolean,
    --- smartPolitics: boolean,
    --- riseOfIx: boolean,
    --- epicMode: boolean,
    --- immortality: boolean,
    --- goTo11: boolean,
    --- bloodlines: boolean,
    --- ixAmbassy: boolean,
    --- ixAmbassyWithIx: boolean,
    --- leaderSelection: "random"|"reversePick"|"reverseHiddenPick"|"altHiddenPick"|string[],
    --- leaderPoolSize?: integer,
    --- tweakLeaderSelection: boolean,
    --- fanmadeLeaders: boolean,
    --- horizontalHandLayout: boolean,
    --- variant: "none"|"arrakeenScouts",
    --- formalCombatPhase: boolean,
    --- soundEnabled: boolean,
    --- submitGameRankedGame: boolean,
    --- submitGameTournament: boolean,
    ---}
    setUp({
        language = Controller.fields.language,
        numberOfPlayers = numberOfPlayers,
        hotSeat = not Controller.isUndefined(Controller.fields.virtualHotSeatMode),
        firstPlayer = Controller.fields.firstPlayer,
        randomizePlayerPositions = Controller.fields.randomizePlayerPositions,
        difficulty = XmlUI.toStringValue(Controller.fields.difficulty),
        autoTurnInSolo = Controller.fields.autoTurnInSolo == true,
        imperiumRowChurn = Controller.fields.imperiumRowChurn == true,
        streamlinedRivals = Controller.fields.streamlinedRivals == true,
        brutalEscalation = Controller.fields.brutalEscalation == true,
        expertDeployment = Controller.fields.expertDeployment == true,
        smartPolitics = Controller.fields.smartPolitics == true,
        riseOfIx = Controller.fields.riseOfIx,
        epicMode = Controller.fields.epicMode == true,
        immortality = Controller.fields.immortality,
        goTo11 = Controller.fields.goTo11 == true,
        bloodlines = Controller.fields.bloodlines,
        ixAmbassy = Controller.fields.ixAmbassy == true,
        ixAmbassyWithIx = Controller.fields.ixAmbassyWithIx == true,
        leaderSelection = Controller.fields.leaderSelection,
        leaderPoolSize = tonumber(Controller.fields.leaderPoolSize),
        tweakLeaderSelection = Controller.fields.tweakLeaderSelection,
        fanmadeLeaders = Controller.fields.fanmadeLeaders,
        horizontalHandLayout = Controller.fields.horizontalHandLayout,
        variant = Controller.fields.variant,
        formalCombatPhase = Controller.fields.formalCombatPhase,
        soundEnabled = Controller.fields.soundEnabled,
        submitGameRankedGame = Controller.fields.submitGameRankedGame == true,
        submitGameTournament = Controller.fields.submitGameTournament == true,
    })
end

---@alias ActiveOpponent Player|"rival"|"puppet"
---@alias Opponent "rival"|"human"

--- Return the mapping between (player) colors and opponent types. An opponent
--- type could be:
--- - a Player instance,
--- - the "rival" string for an automated rival (or House Hagal in the 1P mode),
--- - the "puppet" string for a playable but unseated color in hotseat mode.
--- Later, in opponents (not activeOppenents), Player instances and "puppet" are
--- replaced by the "human" string.
---@param properlySeatedPlayers any
---@param numberOfPlayers integer
---@return table<PlayerColor, ActiveOpponent>
function Controller.findActiveOpponents(properlySeatedPlayers, numberOfPlayers)
    local colorsByPreference = { "Green", "Red", "Yellow", "Blue" }

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
--- mode (1-4P).
---@return PlayerColor[]
function Controller.getProperlySeatedPlayers()
    local seatedPlayers = getSeatedPlayers()

    local authorizedColors = {
        Green = true,
        Yellow = true,
        Blue = true,
        Red = true,
    }

    local properlySeatedPlayers = {}
    for _, color in ipairs(seatedPlayers) do
        if authorizedColors[color] then
            table.insert(properlySeatedPlayers, color)
        end
    end
    return properlySeatedPlayers
end

function Controller.applyVirtualHotSeatMode()
    local numberOfPlayers = Controller.getNumberOfPlayers(Controller.fields.virtualHotSeatMode)

    if Controller.isUndefined(Controller.fields.virtualHotSeatMode) or numberOfPlayers > 2 then
        Controller.fields.difficulty = XmlUI.HIDDEN
        Controller.fields.autoTurnInSolo = XmlUI.DISABLED
        Controller.fields.imperiumRowChurn = XmlUI.DISABLED
        Controller.fields.streamlinedRivals = XmlUI.DISABLED
        Controller.fields.brutalEscalation = XmlUI.DISABLED
        Controller.fields.expertDeployment = XmlUI.DISABLED
        Controller.soloUi:hide()
    else
        if numberOfPlayers == 1 then
            Controller.fields.difficulty = "novice"
            Controller.fields.autoTurnInSolo = false
            Controller.fields.imperiumRowChurn = true
            Controller.fields.streamlinedRivals = XmlUI.HIDDEN
            Controller.fields.brutalEscalation = false
            Controller.fields.expertDeployment = false
        else
            Controller.fields.difficulty = XmlUI.HIDDEN
            Controller.fields.autoTurnInSolo = true
            Controller.fields.imperiumRowChurn = XmlUI.HIDDEN
            Controller.fields.streamlinedRivals = true
            Controller.fields.brutalEscalation = false
            Controller.fields.expertDeployment = false
        end
        Controller.soloUi:show()
    end

    Controller.updateVariant(numberOfPlayers)
    Controller.updateSetupButton()
end

---@param numberOfPlayers integer
function Controller.updateVariant(numberOfPlayers)
    if numberOfPlayers > 2 then
        Controller.fields.variant_all = {
            none = "none",
            arrakeenScouts = "arrakeenScouts"
        }
    else
        Controller.fields.variant_all = {
            none = "none",
        }
        Controller.fields.variant = "none"
    end
end

---@param virtualHotSeatMode any
---@return integer
function Controller.getNumberOfPlayers(virtualHotSeatMode)
    local numberOfPlayers
    if Controller.isUndefined(virtualHotSeatMode) then
        numberOfPlayers = math.min(4, #Controller.getProperlySeatedPlayers())
    else
        local toNumberOfPlayers = { 1, 2, 3, 4 }
        numberOfPlayers = toNumberOfPlayers[virtualHotSeatMode]
    end
    return numberOfPlayers
end

function Controller.updateSelectionMethods()
    local numberOfPlayers = Controller.getNumberOfPlayers(Controller.fields.virtualHotSeatMode)
    Controller.fields.leaderSelection_all = allModules.LeaderSelection.getSelectionMethods(numberOfPlayers)
end

function Controller.updateSetupButton()
    local numberOfPlayers = Controller.getNumberOfPlayers(Controller.fields.virtualHotSeatMode)
    Controller.fields.leaderSelection_all = allModules.LeaderSelection.getSelectionMethods(numberOfPlayers)

    local properlySeatedPlayers = Controller.getProperlySeatedPlayers()

    local minPlayerCount
    if Controller.isUndefined(Controller.fields.virtualHotSeatMode) then
        minPlayerCount = 3
    else
        minPlayerCount = 1
    end

    if #properlySeatedPlayers ~= 4 then
        Controller.fields.submitGameRankedGame = XmlUI.DISABLED
        Controller.fields.submitGameTournament = XmlUI.DISABLED
    else
        if XmlUI.isDisabled(Controller.fields.submitGameRankedGame) then
            Controller.fields.submitGameRankedGame = false
        end
        if XmlUI.isDisabled(Controller.fields.submitGameTournament) then
            Controller.fields.submitGameTournament = false
        end
    end

    if #properlySeatedPlayers >= minPlayerCount then
        Controller.ui:setButtonI18N("setUpButton", "setup", true)
    else
        Controller.ui:setButtonI18N("setUpButton", "notEnoughPlayers", false)
    end
end

function Controller.updateLeaderPoolSizeLabel()
    local value = Controller.fields.leaderPoolSize
    Controller.fields.leaderPoolSizeLabel = I18N("leaderPoolSizeLabel", { value = value } )
end

---@generic T
---@param value Deactivable<T> | Hideable<T>
---@return boolean
function Controller.isUndefined(value)
    return not value or XmlUI.isDisabled(value) or XmlUI.isHidden(value)
end
