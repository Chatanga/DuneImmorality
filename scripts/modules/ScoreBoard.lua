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
    --Helper.dumpFunction("ScoreBoard.onLoad(...)")

    --[[
        4 players tokens -> PlayBoard
        alliance / friendship -> InfluenceTrack
        others -> here
    ]]
    ScoreBoard.tokens = Helper.resolveGUIDs(false, {
        base = {
            theSpiceMustFlowBag = "43c7b5",
            combatVictoryPointBag = "d9a457",
            emperorFriendshipBag = "6a4186",
            spacingGuildFriendshipBag = "400d45",
            beneGesseritFriendshipBag = "e763f6",
            fremenFriendshipBag = "8bcfe7",
            greatHousesFriendshipBag = "95926b",
            fringeWorldsFriendshipBag = "a43ec0",
            endgameCardBag = "cfe0cb",
            --
            smugglerHaven = "8243d3",
            corrinthCity = "46f6f2",
            junctionHeadquarters = "c799ba",
            objective = "f346be",
            priorityContracts = "5e061e",
            deliveryAgreement = "d081dd",
            strategicStockpiling1 = "3b1328",
            strategicStockpiling2 = "227ee4",
            opportunism = "5785d5",
        },
        legacy = {
            guildAmbassadorBag = "4bdbd5",
            sayyadinaBag = "4575f3",
            opulenceBag = "67fbba",
            theSleeperMustAwaken = "946ca1",
            choamShares = "c530e6",
            stagedIncident = "bee42f",
        },
        hagal = {
            intrigueBag = "f9bc89",
            solariBag = "61c242",
            waterBag = "0c4ca1",
            spiceBag = "2fd6f0",
        },
        -- Not simply "ix" here.
        riseOfIx = {
            detonationDevicesBag = "7b3fa2",
            ixianEngineerBag = "3371d8",
            flagship = "366237",
            spySatellites = "73a68f",
            endgameTechBag = "1d3e4f",
        },
        immortality = {
            scientificBreakthrough = "d22031",
            tleilaxBag = "082e07",
            forHumanityBag = "71c0c8"
        },
    })

    if state.settings and state.settings.riseOfIx then
        ScoreBoard._staticSetUp(state.settings)
    end
end

---
function ScoreBoard.setUp(settings)

    Helper.forEachRecursively(ScoreBoard.tokens, function (name, token)
        assert(token)
        token.setName(I18N(Helper.getID(token)))

        -- Clumsy workaround to name items in a bag.
        if token.type == "Bag" then
            log("Renaming in " .. name)
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
    end)

    for _, extension in ipairs({ "legacy", "riseOfIx", "immortality" }) do
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
    -- NOP
end

function ScoreBoard.gainVictoryPoint(color, name)
    -- FIXME Ugly workaround!
    if name == "theSpiceMustFlowNew" then
        name = "theSpiceMustFlow"
    end

    local holder = {
        success = false
    }
    Helper.forEachRecursively(ScoreBoard.tokens, function (victoryPointName, victoryPointSource)
        if name == victoryPointName then
            --Helper.dump("Found VP in top area.")
            PlayBoard.grantScoreToken(color, victoryPointSource)
            holder.success = true
        elseif name .. "Bag" == victoryPointName then
            --Helper.dump("Found VP in a top area bag.")
            PlayBoard.grantScoreTokenFromBag(color, victoryPointSource)
            holder.success = true
        end
    end)
    if holder.success then
        return true
    elseif Combat.gainVictoryPoint(color, name) then
        --Helper.dump("Found VP from the combat.")
        return true
    elseif InfluenceTrack.gainVictoryPoint(color, name) then
        --Helper.dump("Found VP from the influence track.")
        return true
    else
        return false
    end
end

return ScoreBoard
