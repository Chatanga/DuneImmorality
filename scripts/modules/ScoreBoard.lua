local Module = require("utils.Module")
local Helper = require("utils.Helper")

local PlayBoard = Module.lazyRequire("PlayBoard")
local Combat = Module.lazyRequire("Combat")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")

local ScoreBoard = {
    tokens = {}
}

---
function ScoreBoard.onLoad(state)
    --[[
        4 players tokens -> PlayerBoard
        alliance / friendship -> InfluenceTrack
        others -> here
    ]]--
    ScoreBoard.tokens = Helper.resolveGUIDs(true, {
        base = {
            theSpiceMustFlowBag = "43c7b5",
            guildAmbassadorBag = "4bdbd5",
            sayyadinaBag = "4575f3",
            opulenceBag = "67fbba",
            theSleeperMustAwaken = "946ca1",
            stagedIncident = "bee42f",
            endgameCardBag = "cfe0cb",
            endgameTechBag = "1d3e4f",
            combatVictoryPointBag = "d9a457",
        },
        hagal = {
            intrigueBag = "f9bc89",
            solariBag = "61c242",
            waterBag = "0c4ca1",
            spiceBag = "2fd6f0",
        },
        ix = {
            detonationDevicesBag = "7b3fa2",
            ixianEngineerBag = "3371d8",
            flagship = "366237",
            spySatellites = "73a68f",
            choamShares = "c530e6",
        },
        immortality = {
            scientificBreakthrough = "d22031",
            tleilaxBag = "082e07",
            forHumanityBag = "71c0c8"
        }
    })

    if state.settings and state.settings.riseOfIx then
        ScoreBoard._staticSetUp(state.settings)
    end
end

---
function ScoreBoard.setUp(settings)
    for _, extension in ipairs({"riseOfIx", "immortality"}) do
        if not settings[extension] then
            Helper.forEach(ScoreBoard.tokens[extension], function (_, token)
                token.destruct()
            end)
            ScoreBoard.tokens[extension] = nil
        end
    end

    if settings.numberOfPlayers > 2 then
        Helper.forEach(ScoreBoard.tokens.hagal, function (_, token)
            token.destruct()
        end)
        ScoreBoard.tokens.hagal = nil
    end

    ScoreBoard._staticSetUp(settings)
end

---
function ScoreBoard._staticSetUp(settings)

end

---
function ScoreBoard.gainVictoryPoint(color, name)
    local holder = {
        success = false
    }
    Helper.forEachRecursively(ScoreBoard.tokens, function (victoryPointName, victoryPointSource)
        if name == victoryPointName then
            PlayBoard.grantScoreToken(color, victoryPointSource)
            holder.success = true
        elseif name .. "Bag" == victoryPointName then
            PlayBoard.grantScoreTokenFromBag(color, victoryPointSource)
            holder.success = true
        end
    end)
    if holder.success then
        return true
    elseif Combat.gainVictoryPoint(color, name) then
        return true
    elseif InfluenceTrack.gainVictoryPoint(color, name) then
        return true
    else
        return false
    end
end

return ScoreBoard
