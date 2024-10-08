local Module = require("utils.Module")
local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

local PlayBoard = Module.lazyRequire("PlayBoard")
local Combat = Module.lazyRequire("Combat")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")

local ScoreBoard = {
    tokens = {}
}

---
function ScoreBoard.onLoad(state)

    ScoreBoard.hiddenZone = Helper.resolveGUIDs(true, "2edb38")

    for _, object in ipairs(ScoreBoard.hiddenZone.getObjects()) do
        object.setInvisibleTo(Player.getColors())
    end

    --[[
        4 players tokens -> PlayBoard
        alliance / friendship -> InfluenceTrack
        others -> here
    ]]
    ScoreBoard.tokens = Helper.resolveGUIDs(false, {
        friendship = {
            emperorBag = "7007df",
            spacingGuildBag = "af9795",
            beneGesseritBag = "3ebbd7",
            fremenBag = "f5a7af",
        },
        base = {
            fourPlayerBag = "c2290f",
            theSpiceMustFlowBag = "7bd6f8",
            guildAmbassadorBag = "912d75",
            opulenceBag = "c22e46",
            theSleeperMustAwaken = "9bfd65",
            choamShares = "2da115",
            stagedIncident = "1f98e2",
            endgameCardBag = "182475",
            combatVictoryPointBag = "86dc4e",
        },
        hagal = {
            intrigueBag = "772594",
            solariBag = "266448",
            waterBag = "3963f0",
            spiceBag = "19c977",
        },
        ix = {
            sayyadinaBag = "9193f5",
            ixianEngineerBag = "4ae3de",
            detonationDevicesBag = "4cc3d5",
            flagship = "692480",
            spySatellites = "c94718",
            techEndgameBag = "3e2ce6",
        },
        immortality = {
            scientificBreakthrough = "b56adc",
            tleilaxBag = "37ceab",
            forHumanityBag = "6e2a13"
        }
    })

    if state.settings and state.settings.riseOfIx then
        ScoreBoard._transientSetUp(state.settings)
    end
end

---
function ScoreBoard.setUp(settings)
    local activateCategories = {
        base = true,
        hagal = settings.numberOfPlayers <= 2,
        ix = settings.riseOfIx,
        immortality = settings.immortality,
    }

    for _, category in ipairs({ "base", "hagal", "ix", "immortality" }) do
        if activateCategories[category] then
            Helper.forEachRecursively(ScoreBoard.tokens[category], function (name, token)
                assert(token)
                local key = Helper.getID(token)
                if key and key:len() > 0 then
                    token.setName(I18N(key))
                end
                if false then
                    -- Clumsy workaround to name items in a bag.
                    -- TODO Recreate the bag?
                    if token.type == "Bag" then
                        local count = #token.getObjects()
                        for i = 1, count do
                            local innerToken = token.takeObject({ position = token.getPosition() + Vector(0, i * 0.5, 0) })
                            innerToken.setLock(true)
                            Helper.onceTimeElapsed(0.5).doAfter(function ()
                                innerToken.setName(I18N(Helper.getID(innerToken)))
                                innerToken.setLock(false)
                            end)
                        end
                    elseif token.type == "Infinite" then
                        -- TODO
                    end
                end
            end)
        else
            Helper.forEach(ScoreBoard.tokens[category], function (_, token)
                token.destruct()
            end)
            ScoreBoard.tokens[category] = nil
        end
    end

    ScoreBoard._transientSetUp(settings)
end

---
function ScoreBoard._transientSetUp(settings)
    -- NOP
end

---
function ScoreBoard.gainVictoryPoint(color, name, count)
    -- FIXME Useless indirection.
    local holder = {
        success = false
    }
    Helper.forEachRecursively(ScoreBoard.tokens, function (victoryPointName, victoryPointSource)
        if name == victoryPointName then
            PlayBoard.grantScoreToken(color, victoryPointSource)
            holder.success = true
        elseif name .. "Bag" == victoryPointName then
            PlayBoard.grantScoreTokenFromBag(color, victoryPointSource, count)
            holder.success = true
        end
    end)
    if holder.success then
        return true
    elseif Combat.gainVictoryPoint(color, name, count) then
        return true
    elseif InfluenceTrack.gainVictoryPoint(color, name, count) then
        return true
    else
        Helper.dump("No VP named", name)
        return false
    end
end

--- TODO Find a better place and implementation.
function ScoreBoard.getFreeVoiceToken()
    for _, object in ipairs(ScoreBoard.hiddenZone.getObjects()) do
        if Helper.isElementOf(object.getGUID(), { "516df5", "cc0eda" }) then
            object.setInvisibleTo({})
            return object
        end
    end
    return nil
end

return ScoreBoard
