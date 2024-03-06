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

    ScoreBoard.hiddenZone = Helper.resolveGUIDs(true, "3848a9")

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
            greatHousesBag = "07e49b",
            fringeWorldsBag = "ff38f9",
        },
        base = {
            fourPlayerBag = "c2290f",
            theSpiceMustFlowBag = "43c7b5",
            guildAmbassadorBag = "4bdbd5",
            sayyadinaBag = "4575f3",
            opulenceBag = "67fbba",
            theSleeperMustAwaken = "946ca1",
            choamShares = "c530e6",
            stagedIncident = "bee42f",
            endgameCardBag = "cfe0cb",
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
            techEndgameBag = "1d3e4f",
        },
        immortality = {
            scientificBreakthrough = "d22031",
            beetleBag = "082e07",
            forHumanityBag = "71c0c8"
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
                        --log("Renaming in " .. name)
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
    Helper.dumpFunction("ScoreBoard.gainVictoryPoint", color, name, count)
    local holder = {
        success = false
    }
    Helper.forEachRecursively(ScoreBoard.tokens, function (victoryPointName, victoryPointSource)
        if name == victoryPointName then
            Helper.dump("Found VP in top area.")
            PlayBoard.grantScoreToken(color, victoryPointSource)
            holder.success = true
        elseif name .. "Bag" == victoryPointName then
            Helper.dump("Found VP in a top area bag.")
            PlayBoard.grantScoreTokenFromBag(color, victoryPointSource, count)
            holder.success = true
        end
    end)
    if holder.success then
        return true
    elseif Combat.gainVictoryPoint(color, name) then
        Helper.dump("Found VP from the combat.")
        return true
    elseif InfluenceTrack.gainVictoryPoint(color, name) then
        Helper.dump("Found VP from the influence track.")
        return true
    else
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
