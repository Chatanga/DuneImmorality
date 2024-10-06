-- Required modules
local Module = require("utils.Module")
local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

-- Lazy required modules
local PlayBoard = Module.lazyRequire("PlayBoard")
local TurnControl = Module.lazyRequire("TurnControl")

-- Define constants
local PRIMARY_URL = "http://dunerank.servehttp.com:8081"
local INELIGIBLE_COLORS = {"Black", "Gray"}

-- SubmitGame class
local SubmitGame = Helper.createClass(nil, {
    ui = nil,  -- The view
    fields = {  -- The model
        startTime = os.date("!%m/%d/%Y %H:%M:%S", os.time(os.date("!*t"))),
        token = nil,
        players = {},
        firstPlayerColor = nil,
        numberOfPlayers = 0,
        hotseat = false,
        randomizePlayerPositions = false,
        useContracts = false,
        riseOfIx = false,
        epicMode = false,
        legacy = false,
        immortality = false,
        goTo11 = false,
        leaderSelection = nil,
        leaderPoolSize = 0,
        submitGameRankedGame = false,
        submitGameTournament = false,
        gameSubmitted = false,
        turn = 0,
    }
})

function SubmitGame.onLoad(state)
    if state.TurnControl then
        SubmitGame.fields = state.SubmitGame.fields
        if SubmitGame.fields.token ~= nil then
            UI.setAttributes("openSubmitScreenPanel", { active = true })
        end
    end

    Global.setVar("openSubmitScreen", function()
        SubmitGame.openSubmitScreen()
    end)

    Global.setVar("closeSubmitGameScreen", function()
        SubmitGame.closeSubmitGameScreen()
    end)

    Global.setVar("submitGame", function ()
        SubmitGame.submitGame()
    end)
end

function SubmitGame.onSave(state)
    state.SubmitGame = {
        fields = SubmitGame.fields
    }
end

function SubmitGame.setUp(settings)
    -- Set the panel active if either submitGameRankedGame or submitGameTournament is true
    if settings.submitGameRankedGame or settings.submitGameTournament then
        UI.setAttributes("openSubmitScreenPanel", {active = true})
    end

    -- Use a loop to set the fields
    local fieldNames = {
        "numberOfPlayers",
        "hotseat",
        "randomizePlayerPositions",
        "useContracts",
        "riseOfIx",
        "epicMode",
        "immortality",
        "goTo11",
        "leaderSelection",
        "leaderPoolSize",
        "submitGameRankedGame",
        "submitGameTournament",
        "legacy"
    }

    for _, fieldName in ipairs(fieldNames) do
        SubmitGame.fields[fieldName] = settings[fieldName]
    end

    -- leaderPoolSize is a special case, it uses a different key in settings
    SubmitGame.fields.leaderPoolSize = settings.defaultLeaderPoolSize

    SubmitGame.generateToken()
    SubmitGame._staticSetUp(settings)
end

function SubmitGame._staticSetUp(settings)
    -- NOP
end

function SubmitGame.closeSubmitGameScreen()
    UI.setAttributes("submitScreenPanel", {active = false})
end

function SubmitGame.openSubmitScreen()
    local playerColors = {"Red", "Green", "Blue", "Yellow"}
    local playerWith10VP = false

    -- Set the first player
    SubmitGame.fields.firstPlayerColor = TurnControl.getFirstPlayerOfTheGame()

    -- Retrieve player data by color from SubmitGame.fields.players
    local function getPlayerInfoByColor(color)
        for _, playerInfo in ipairs(SubmitGame.fields.players) do
            if playerInfo.color == color then
                return playerInfo
            end
        end
    end

    local playerData = {}
    for _, color in ipairs(playerColors) do
        local playBoard = PlayBoard.getPlayBoard(color)
        local playerInfo = getPlayerInfoByColor(color) -- get player info by color

        -- Safely handle nil playerInfo
        if playerInfo then
            local player = {
                name = playerInfo.name,
                steamId = playerInfo.steamId,
                color = playerInfo.color,
                score = math.max(0, playBoard:getScore()),
                leader = PlayBoard.getLeaderName(color),
                spice = PlayBoard.getResource(color, "spice"):get(),
                solari = PlayBoard.getResource(color, "solari"):get(),
                water = PlayBoard.getResource(color, "water"):get(),
                firstPlayer = nil,
            }

            table.insert(playerData, player)

            if player.score >= 10 then
                playerWith10VP = true
            end
        end
    end
    SubmitGame.fields.players = playerData
    SubmitGame.updateSubmitGameConfirm(playerWith10VP)
    SubmitGame.displayAllData()
    UI.setAttributes("submitScreenPanel", {active = true})
end

function SubmitGame.updateSubmitGameConfirm(playerWith10VP)
    if playerWith10VP then
        UI.setAttributes("submitGameConfirm", {key = "submitGame", interactable = true})
    else
        UI.setAttributes("submitGameConfirm", {key = "submitGame", interactable = false})
    end
end

function SubmitGame.displayAllData()
    for _, player in ipairs(SubmitGame.fields.players) do
        if player.score >= 10 then
            UI.setAttributes("submitGameConfirm", {interactable = true})
        end
    end

    -- Sort players by score, spice, solari, and water
    table.sort(SubmitGame.fields.players, function(a, b)
        if a.score ~= b.score then return a.score > b.score end
        if a.spice ~= b.spice then return a.spice > b.spice end
        if a.solari ~= b.solari then return a.solari > b.solari end
        return a.water > b.water
    end)

    -- Display the data on the UI
    for i, player in ipairs(SubmitGame.fields.players) do
        player.placement = i

        local attributes = {
            ["_name"] = player.name,
            ["_leader_name"] = player.leader,
            ["_victory_points"] = player.score,
            ["_spice"] = player.spice,
            ["_solaris"] = player.solari,
            ["_water"] = player.water,
        }

        for attribute, value in pairs(attributes) do
            local placementCellIndex = "cell_placement_" .. i
            UI.setAttributes(placementCellIndex, {color = player.color})
            
            local placementIndex = "placement_" .. i .. attribute
            UI.setAttribute(placementIndex, "text", value)

            local cellIndex = "cell_placement_" .. i .. attribute
            UI.setAttributes(cellIndex, {color = player.color})
        end
    end
end

function SubmitGame.isEligibleColor(color)
    for _, ineligibleColor in ipairs(INELIGIBLE_COLORS) do
        if color == ineligibleColor then
            return false
        end
    end
    return true
end

function SubmitGame.handleWebRequestToken(request)
    if request.is_error then
        Helper.dump("SubmitGame.handleWebRequestToken: Error: " .. request.text)
        SubmitGame.fields.token = 0
    else
        SubmitGame.fields.token = request.text
    end
end

function SubmitGame.handleWebRequestGame(request)
    if request.is_error then
        Helper.dump("SubmitGame.handleWebRequestGame: Error: " .. request.text)
    else
        broadcastToAll(request.text, "White")
    end
end

function SubmitGame.handleGameSubmitSheet(request)
    if request.is_error then
        Helper.dump("SubmitGame.handleGameSubmitSheet: Error: " .. request.text)
    else
        broadcastToAll(I18N("gameSubmitted"), "Red")
    end
end

-- Make a web request
function SubmitGame.makeWebRequest(url, method, body, callback)
    local headers = {
        ["Content-Type"] = "application/json",
        Accept = "application/json"
    }

    local jsonString = JSON.encode(body)

    WebRequest.custom(url, method, true, jsonString, headers, function(request)
        callback(request)
    end)
end

function SubmitGame.generateToken()
    local body = {
        playersList = {},
    }

    for _, player in ipairs(Player.getPlayers()) do
        if SubmitGame.isEligibleColor(player.color) then
            local playerInfo = {
                steamId = player.steam_id,
                name = player.steam_name,
                color = player.color,
            }
            table.insert(body.playersList, playerInfo)
        end
    end
    firstPlayer = TurnControl.getFirstPlayerOfTheGame()
    Helper.dump("The First player is: " .. firstPlayer)

    SubmitGame.fields.players = body.playersList

    SubmitGame.makeWebRequest(PRIMARY_URL .. "/generation/v1/token", "POST", body.playersList, SubmitGame.handleWebRequestToken)
end

function SubmitGame.submitGame()
    local jsonTable = {
        token = SubmitGame.fields.token,
        firstPlayerColor = TurnControl.getFirstPlayerOfTheGame(),
        numberOfPlayers = SubmitGame.fields.numberOfPlayers,
        useContracts = SubmitGame.fields.useContracts,
        riseOfIx = SubmitGame.fields.riseOfIx,
        epicMode = SubmitGame.fields.epicMode,
        Imperium = SubmitGame.fields.legacy,
        immortality = SubmitGame.fields.immortality,
        goTo11 = SubmitGame.fields.goTo11,
        leaderSelection = SubmitGame.fields.leaderSelection,
        leaderPoolSize = SubmitGame.fields.leaderPoolSize,
        rankedGame = SubmitGame.fields.submitGameRankedGame,
        tournament = SubmitGame.fields.submitGameTournament,
        playerData = SubmitGame.fields.players,
        startTime = SubmitGame.fields.startTime,
        endTime = os.date("!%m/%d/%Y %H:%M:%S", os.time(os.date("!*t"))),
        turn = TurnControl.getCurrentRound()
    }

    local infoTable = {
        ["entry.1366590140"] = SubmitGame.fields.startTime, -- startTime
        ["entry.1761818302"] = os.date("!%m/%d/%Y %H:%M:%S", os.time(os.date("!*t"))), -- endTime
        ["entry.754082197"] = SubmitGame.fields.submitGameRankedGame, -- rankedGame
        ["entry.1220354769"] = SubmitGame.fields.submitGameTournament, -- tournament

        ["entry.863659574"] = TurnControl.getCurrentRound(), -- turn

        ["entry.971195728"] = TurnControl.getFirstPlayerOfTheGame(),

        ["entry.1210623"] = SubmitGame.fields.players[1].name, -- playerData[0].name
        ["entry.212984148"] = SubmitGame.fields.players[1].color, -- playerData[0].color
        ["entry.861602902"] = SubmitGame.fields.players[1].leader, -- playerData[0].leader
        ["entry.652567690"] = SubmitGame.fields.players[1].steamId, -- playerData[0].steamId
        ["entry.1767025989"] = SubmitGame.fields.players[2].name, -- playerData[1].name
        ["entry.1733905844"] = SubmitGame.fields.players[2].color, -- playerData[1].color
        ["entry.1430075466"] = SubmitGame.fields.players[2].leader, -- playerData[1].leader
        ["entry.1445792508"] = SubmitGame.fields.players[2].steamId, -- playerData[1].steamId
        ["entry.852059461"] = SubmitGame.fields.players[3].name, -- playerData[2].name
        ["entry.1159019046"] = SubmitGame.fields.players[3].color, -- playerData[2].color
        ["entry.1977206887"] = SubmitGame.fields.players[3].leader, -- playerData[2].leader
        ["entry.813977476"] = SubmitGame.fields.players[3].steamId, -- playerData[2].steamId
        ["entry.1953565350"] = SubmitGame.fields.players[4].name, -- playerData[3].name
        ["entry.1319735869"] = SubmitGame.fields.players[4].color, -- playerData[3].color
        ["entry.910125184"] = SubmitGame.fields.players[4].leader, -- playerData[3].leader
        ["entry.997583011"] = SubmitGame.fields.players[4].steamId, -- playerData[3].steamId

        ["entry.845707618"] = SubmitGame.fields.legacy, -- legacy
        ["entry.2040351705"] = SubmitGame.fields.riseOfIx, -- riseOfIx
        ["entry.744802168"] = SubmitGame.fields.immortality, -- immortality
        ["entry.419313208"] = SubmitGame.fields.token, -- token
        ["entry.2086786594"] = SubmitGame.fields.epicMode, -- epicMode
        ["entry.530174472"] = SubmitGame.fields.goTo11, -- goTo11
        ["entry.959235419"] = SubmitGame.fields.leaderSelection, -- leaderSelection
        ["entry.886901664"] = SubmitGame.fields.leaderPoolSize, -- leaderPoolSize
        ["entry.831709295"] = SubmitGame.fields.numberOfPlayers -- numberOfPlayers
    }

    if SubmitGame.fields.gameSubmitted then
        broadcastToAll(I18N("gameAlreadySubmitted"), "Orange")
    else
        WebRequest.post("https://docs.google.com/forms/u/1/d/e/1FAIpQLSeaApnr3rZNPGvTsHilxg390UPtrTuCm8kVP9gSiK0yitU9IQ/formResponse", infoTable, SubmitGame.handleGameSubmitSheet)
        SubmitGame.makeWebRequest(PRIMARY_URL .. "/game/v1/submit", "POST", jsonTable, SubmitGame.handleWebRequestGame)
        UI.setAttributes("submitGameConfirm", {key = "gameSubmitted", interactable = false})
        SubmitGame.fields.gameSubmitted = true
    end
end

return SubmitGame