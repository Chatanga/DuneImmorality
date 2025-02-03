local Module = require("utils.Module")
local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

local PlayBoard = Module.lazyRequire("PlayBoard")
local TurnControl = Module.lazyRequire("TurnControl")

local PRIMARY_URL = "http://dunerank.servehttp.com:8081"
local GOOGLE_DOC_URL = "https://docs.google.com/forms/u/1/d/e/1FAIpQLSeaApnr3rZNPGvTsHilxg390UPtrTuCm8kVP9gSiK0yitU9IQ"

local SubmitGame = Helper.createClass(nil, {
    fields = {

        -- Partially set on setup, then completed and sorted on each "openSubmitScreen".
        players = {},

        -- Set on setup from settings.
        numberOfPlayers = 0,
        hotseat = false,
        randomizePlayerPositions = false,
        legacy = false,
        riseOfIx = false,
        epicMode = false,
        immortality = false,
        goTo11 = false,
        leaderSelection = nil,
        leaderPoolSize = 0,
        submitGameRankedGame = false,
        submitGameTournament = false,

        -- Set on setup.
        startTime = nil,
        token = nil,

        -- Set on submission.
        firstPlayerColor = nil,
        endTime = nil,
        turn = 0,
        gameSubmitted = false,
    }
})

---@param state table
function SubmitGame.onLoad(state)
    if state.SubmitGame then
        SubmitGame.fields = state.SubmitGame.fields
        if SubmitGame.fields.submitGameRankedGame or SubmitGame.fields.submitGameTournament then
            SubmitGame._staticSetUp()
        end
    end
end

---@param state table
function SubmitGame.onSave(state)
    state.SubmitGame = {
        fields = SubmitGame.fields
    }
end

---@param settings Settings
function SubmitGame.setUp(settings)
    if settings.submitGameRankedGame or settings.submitGameTournament then

        SubmitGame.fields.players = {}
        for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
            local player = Helper.findPlayerByColor(color)
            table.insert(SubmitGame.fields.players, {
                steamId = player.steam_id,
                name = player.steam_name,
                color = player.color,
            })
        end
        assert(#SubmitGame.fields.players == 4)

        local fieldNames = {
            "numberOfPlayers",
            "hotseat",
            "randomizePlayerPositions",
            "legacy",
            "riseOfIx",
            "epicMode",
            "immortality",
            "goTo11",
            "leaderSelection",
            "leaderPoolSize",
            "submitGameRankedGame",
            "submitGameTournament",
        }

        for _, fieldName in ipairs(fieldNames) do
            SubmitGame.fields[fieldName] = settings[fieldName]
        end

        SubmitGame.fields.startTime = SubmitGame._currentTimestamp()

        SubmitGame._generateToken(SubmitGame.fields.players, function (token)
            SubmitGame.fields.token = token
            SubmitGame._staticSetUp()
        end)
    end
end

function SubmitGame._staticSetUp()
    if SubmitGame.fields.token then
        Global.setVar("openSubmitScreen", SubmitGame._openSubmitScreen)
        Global.setVar("closeSubmitGameScreen", SubmitGame._closeSubmitGameScreen)
        Global.setVar("submitGame", SubmitGame._submitGame)

        UI.setAttributes("openSubmitScreenPanel", { active = true })
    end
end

function SubmitGame._closeSubmitGameScreen()
    UI.setAttributes("submitScreenPanel", { active = false })
end

function SubmitGame._openSubmitScreen()
    local playerWith10VP = false

    SubmitGame.fields.firstPlayerColor = TurnControl.getFirstPlayerOfTheGame()

    for _, player in ipairs(SubmitGame.fields.players) do
        local color = player.color

        player.score = math.max(0, PlayBoard.getPlayBoard(color):getScore()) -- Why max?
        player.leader = PlayBoard.getLeaderName(color)
        player.spice = PlayBoard.getResource(color, "spice"):get()
        player.solari = PlayBoard.getResource(color, "solari"):get()
        player.water = PlayBoard.getResource(color, "water"):get()
        player.firstPlayer = nil

        playerWith10VP = playerWith10VP or player.score >= 10
    end

    SubmitGame._updateSubmitScreenPanel()

    UI.setAttributes("submitScreenPanel", { active = true })
    UI.setAttributes("submitGameConfirm", { key = "submitGame", interactable = playerWith10VP })
end

function SubmitGame._updateSubmitScreenPanel()

    -- Sort players by score, spice, solari, and water.
    table.sort(SubmitGame.fields.players, function(a, b)
        if a.score ~= b.score then return a.score > b.score end
        if a.spice ~= b.spice then return a.spice > b.spice end
        if a.solari ~= b.solari then return a.solari > b.solari end
        return a.water > b.water
    end)

    for i, player in ipairs(SubmitGame.fields.players) do
        player.placement = i

        local attributes = {
            name = player.name,
            leader_name = player.leader,
            victory_points = player.score,
            spice = player.spice,
            solaris = player.solari,
            water = player.water,
        }

        for attribute, value in pairs(attributes) do
            local placementCellIndex = "cell_placement_" .. i
            UI.setAttributes(placementCellIndex, { color = player.color })

            local placementIndex = "placement_" .. i .. "_" .. attribute
            UI.setAttribute(placementIndex, "text", value)

            local cellIndex = "cell_placement_" .. i .. "_" .. attribute
            UI.setAttributes(cellIndex, { color = player.color })
        end
    end
end

---@param players PlayerColor[]
---@param tokenSetter fun(text: integer|string)
function SubmitGame._generateToken(players, tokenSetter)
    SubmitGame._makeWebRequest(PRIMARY_URL .. "/generation/v1/token", "POST", players, function (request)
        if request.is_error then
            Helper.dump("Failed to generate a token:", request.text)
            tokenSetter(0)
        else
            tokenSetter(request.text)
        end
    end)
end

function SubmitGame._submitGame()
    if SubmitGame.fields.gameSubmitted then
        broadcastToAll(I18N("gameAlreadySubmitted"), "Orange")
    else
        SubmitGame.firstPlayerColor = TurnControl.getFirstPlayerOfTheGame()
        SubmitGame.endTime = SubmitGame._currentTimestamp()
        SubmitGame.turn = TurnControl.getCurrentRound()

        SubmitGame._doSubmitGameStats()
        SubmitGame._doSubmitGame()

        UI.setAttributes("submitGameConfirm", {key = "gameSubmitted", interactable = false})
        SubmitGame.fields.gameSubmitted = true
    end
end

function SubmitGame._doSubmitGameStats()
    local fields = SubmitGame.fields
    local body = {
        ["entry.1366590140"] = fields.startTime,
        ["entry.1761818302"] = fields.endTime,
        ["entry.754082197"] = fields.submitGameRankedGame,
        ["entry.1220354769"] = fields.submitGameTournament,
        ["entry.863659574"] = fields.turn,
        ["entry.971195728"] = fields.firstPlayerColor,

        ["entry.1210623"] = fields.players[1].name,
        ["entry.212984148"] = fields.players[1].color,
        ["entry.861602902"] = fields.players[1].leader,
        ["entry.652567690"] = fields.players[1].steamId,

        ["entry.1767025989"] = fields.players[2].name,
        ["entry.1733905844"] = fields.players[2].color,
        ["entry.1430075466"] = fields.players[2].leader,
        ["entry.1445792508"] = fields.players[2].steamId,

        ["entry.852059461"] = fields.players[3].name,
        ["entry.1159019046"] = fields.players[3].color,
        ["entry.1977206887"] = fields.players[3].leader,
        ["entry.813977476"] = fields.players[3].steamId,

        ["entry.1953565350"] = fields.players[4].name,
        ["entry.1319735869"] = fields.players[4].color,
        ["entry.910125184"] = fields.players[4].leader,
        ["entry.997583011"] = fields.players[4].steamId,

        ["entry.845707618"] = fields.legacy,
        ["entry.2040351705"] = fields.riseOfIx,
        ["entry.744802168"] = fields.immortality,
        ["entry.419313208"] = fields.token,
        ["entry.2086786594"] = fields.epicMode,
        ["entry.530174472"] = fields.goTo11,
        ["entry.959235419"] = fields.leaderSelection,
        ["entry.886901664"] = fields.leaderPoolSize,
        ["entry.831709295"] = fields.numberOfPlayers,
    }

    local normalizedBody = {}
    for k, v in pairs(body) do
        normalizedBody[k] = type(v) == "string" and v or tostring(v)
    end

    WebRequest.post(GOOGLE_DOC_URL .. "/formResponse", normalizedBody, function (request)
        if request.is_error then
            Helper.dump("Failed to submit stats:", request.text)
        else
            broadcastToAll(I18N("gameSubmitted"), "Red")
        end
    end)
end

function SubmitGame._doSubmitGame()
    local fields = SubmitGame.fields
    local body = {
        token = fields.token,
        firstPlayerColor = fields.firstPlayerColor,
        numberOfPlayers = fields.numberOfPlayers,
        riseOfIx = fields.riseOfIx,
        epicMode = fields.epicMode,
        Imperium = fields.legacy, -- Imperium with an uppercase, really?
        immortality = fields.immortality,
        goTo11 = fields.goTo11,
        leaderSelection = fields.leaderSelection,
        leaderPoolSize = fields.leaderPoolSize,
        rankedGame = fields.submitGameRankedGame,
        tournament = fields.submitGameTournament,
        playerData = fields.players,
        startTime = fields.startTime,
        endTime = fields.endTime,
        turn = fields.turn,
    }

    SubmitGame._makeWebRequest(PRIMARY_URL .. "/game/v1/submit", "POST", body, function (request)
        if request.is_error then
            Helper.dump("Failed to submit game:", request.text)
        else
            broadcastToAll(request.text, "White")
        end
    end)
end

---@param url string
---@param method "POST"
---@param body table<string, any>
---@param callback fun(request: table)
function SubmitGame._makeWebRequest(url, method, body, callback)
    local headers = {
        ["Content-Type"] = "application/json",
        Accept = "application/json"
    }

    local jsonString = JSON.encode(body)

    WebRequest.custom(url, method, true, jsonString, headers, callback)
end

---@return string|osdate
function SubmitGame._currentTimestamp()
    -- Weird: osdateparam != string|osdate...
---@diagnostic disable-next-line: param-type-mismatch
    return os.date("!%m/%d/%Y %H:%M:%S", os.time(os.date("!*t")))
end

return SubmitGame
