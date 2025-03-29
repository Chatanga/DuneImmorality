local Module = require("utils.Module")
local Helper = require("utils.Helper")
local AcquireCard = require("utils.AcquireCard")
local I18N = require("utils.I18N")
local Park = require("utils.Park")
local Dialog = require("utils.Dialog")

local Deck = Module.lazyRequire("Deck")
local PlayBoard = Module.lazyRequire("PlayBoard")
local MainBoard = Module.lazyRequire("MainBoard")
local Combat = Module.lazyRequire("Combat")
local SardaukarCommanderSkillCard = Module.lazyRequire("SardaukarCommanderSkillCard")
local Commander = Module.lazyRequire("Commander")
local TurnControl = Module.lazyRequire("TurnControl")
local Board = Module.lazyRequire("Board")

local SardaukarCommander = {}

---@param state table
function SardaukarCommander.onLoad(state)
    Helper.append(SardaukarCommander, Helper.resolveGUIDs(false, {
        protoSardaukar = "87b7c1",
        deckZone = "7507fe",
        slotZones = {
            'b1003b',
            '7ecb9d',
            'a0e208',
            'a065b4',
        },
        sardaukarMarkers = {
            "3880dd",
            "119db9",
            "4186a0",
            "4cc23f",
            "836aae",
            "8f81a2",
            "087af1",
        },
    }))

    if state.settings and state.settings.bloodlines then
        SardaukarCommander._transientSetUp(state.settings)
    end
end

---@param settings Settings
---@return Continuation?
function SardaukarCommander.setUp(settings)
    if settings.bloodlines then
        local continuation = Helper.createContinuation("SardaukarCommander.setUp")

        local position = SardaukarCommander.deckZone.getPosition() - Vector(0, 1.5, 0)
        Helper.createTransientAnchor("SardaukarCommanderSkillCardDeck", position).doAfter(function (anchor)
            local snapPoint = Helper.createRelativeSnapPointFromZone(anchor, SardaukarCommander.deckZone, true, { "SardaukarCommanderSkill" })
            anchor.setSnapPoints({ snapPoint })

            Deck.generateSardaukarCommanderSkillDeck(SardaukarCommander.deckZone, settings).doAfter(function (deck)
                assert(deck, "No sardaukar skill deck!")
                Helper.shuffleDeck(deck)
                for _, zone in ipairs(SardaukarCommander.slotZones) do
                    Helper.moveCardFromZone(SardaukarCommander.deckZone, zone.getPosition(), Vector(0, 180, 0))
                end
                SardaukarCommander._transientSetUp(settings)
                continuation.run()
            end)
        end)

        return continuation
    else
        return nil
    end
end

---@param settings Settings
function SardaukarCommander._transientSetUp(settings)
    for i, zone in ipairs(SardaukarCommander.slotZones) do
        AcquireCard.new(zone, Board.onTable(0), "SardaukarCommanderSkill", PlayBoard.withLeader(function (leader, color)
            leader.acquireSardaukarCommanderSkillCard(color, i)
        end), Deck.getAcquireCardDecalUrl("generic"))
    end

    SardaukarCommander._createSardaukarCommanderRecruitmentButtons(settings)

    Helper.registerEventListener("combatUpdate", function (forces)
        for _, color in ipairs(PlayBoard.getActivePlayBoardColors(true)) do
            SardaukarCommander._setStrengthContributions(color)
        end
    end)

    Helper.registerEventListener("agentSent", function (color, spaceName)
        if PlayBoard.isHuman(color) and MainBoard.isGreenSpace(spaceName) then
            Helper.onceTimeElapsed(2).doAfter(Helper.partialApply(SardaukarCommander._setStrengthContributions, color))
        end
    end)

    Helper.registerEventListener("influence", function (faction, color, newRank)
        if PlayBoard.isHuman(color) and faction == "emperor" then
            SardaukarCommander._setStrengthContributions(color)
        end
    end)
end

---@param color PlayerColor
function SardaukarCommander._setStrengthContributions(color)
    local strength = 0
    if Combat.hasAnySardaukarCommander(color) then
        local skillCardNames = PlayBoard.getAllCommanderSkillNames(color)
        strength = SardaukarCommanderSkillCard.evaluateCombat(color, skillCardNames)
    end
    PlayBoard.getResource(color, "strength"):setBaseValueContribution("sardaukarCommanderSkills", strength)
end

---@param settings Settings
function SardaukarCommander._createSardaukarCommanderRecruitmentButtons(settings)
    local sardaukarLocationNames = {}
    if settings.numberOfPlayers == 6 then
        sardaukarLocationNames = {
            "militarySupport",
            "deliverSupplies",
            "highCouncil",
            settings.ix and "dreadnought" or "gatherSupport",
            "sardaukar",
            "sardaukarStandard",
        }
        if not settings.ix then
            table.insert(sardaukarLocationNames, "assemblyHall")
        end
    else
        sardaukarLocationNames = {
            "sardaukar",
            "dutifulService",
            "deliverSupplies",
            "highCouncil",
            settings.ix and "dreadnought" or "gatherSupport",
            "sardaukarStandard",
        }
        if settings.numberOfPlayers == 4 then
            table.insert(sardaukarLocationNames, settings.ix and "techNegotiation" or "assemblyHall")
        end
    end

    local sardaukarLocationPositions = {}
    MainBoard.collectSnapPointsOnAllBoards(settings, {
        sardaukar = function (name, position)
            sardaukarLocationPositions[name] = position
            position.y = 1.65 -- 1.58
        end
    })

    sardaukarLocationPositions.sardaukarStandard = Vector(0.34, 1.56, 14.6)

    for i, sardaukarLocationName in ipairs(sardaukarLocationNames) do
        local position = sardaukarLocationPositions[sardaukarLocationName]
        assert(position, "Unknown Sardaukar location: " .. sardaukarLocationName)
        local marker = SardaukarCommander.sardaukarMarkers[i]
        marker.setPosition(position)
        marker.setInvisibleTo({})
        Helper.noPhysics(marker)
        marker.setTags({ "SardaukarCommanderRecruitmentMarker" })
        marker.setGMNotes(sardaukarLocationName)
        assert(Helper.getID(marker) == sardaukarLocationName)
        SardaukarCommander.createSardaukarCommanderRecruitmentButton(marker, true, PlayBoard.withLeader(function (leader, color)
            if SardaukarCommander._getRecruitedSardaukar(sardaukarLocationName) then
                Dialog.showYesOrNoDialog(color, I18N("confirmSardaukarRecall"), nil, function (confirmed)
                    local sardaukar = SardaukarCommander._getRecruitedSardaukar(sardaukarLocationName)
                    if confirmed and sardaukar then
                        sardaukar.destruct()
                        SardaukarCommander.setAvailable(marker, true)
                    end
                end)
            else
                if settings.numberOfPlayers == 6 and Commander.isTeamMuadDib(color) then
                    if sardaukarLocationName ~= "sardaukarStandard" then
                        if leader.resources(color, "spice", -2) then
                            leader.discardSardaukarCommander(color, sardaukarLocationName)
                        else
                            Dialog.broadcastToColor(I18N('notEnoughSpiceToDiscardSardaukarCommander'), color, "Purple")
                        end
                    end
                else
                    if sardaukarLocationName == "sardaukarStandard" or leader.resources(color, "solari", PlayBoard.hasTech(color, "sardaukarHighCommand") and -1 or -2) then
                        leader.recruitSardaukarCommander(color, sardaukarLocationName)
                    else
                        Dialog.broadcastToColor(I18N('notEnoughSolarisToRecruitSardaukarCommander'), color, "Purple")
                    end
                end
            end
        end))
        if SardaukarCommander._getRecruitedSardaukar(sardaukarLocationName) then
            SardaukarCommander.setAvailable(marker, false)
        end
    end
end

---@param marker Object
---@param acquire boolean
---@param callback ClickFunction
function SardaukarCommander.createSardaukarCommanderRecruitmentButton(marker, acquire, callback)
    local height = marker.getPosition().y + 0.1
    Helper.createSizedAreaButton(360, 360, marker, 0, 0, height, I18N(acquire and "sardaukarAcquireAndRecruitButton" or "sardaukarRecruitButton"), callback)
    SardaukarCommander.setAvailable(marker, acquire)
end

---@param origin string
---@return Object?
function SardaukarCommander._getRecruitedSardaukar(origin)
    for _, sardaukar in ipairs(getObjectsWithTag("SardaukarCommander")) do
        if Helper.getID(sardaukar) == origin then
            return sardaukar
        end
    end
    return nil
end

---@param color PlayerColor
---@param origin string
---@return boolean
function SardaukarCommander.recruitSardaukarCommander(color, origin)
    return SardaukarCommander._acquireSardaukarCommander(color, origin, true)
end

---@param color PlayerColor
---@param origin string
---@return boolean
function SardaukarCommander.discardSardaukarCommander(color, origin)
    return SardaukarCommander._acquireSardaukarCommander(color, origin, false)
end

---@param color PlayerColor
---@param origin string
---@param recruit boolean
---@return boolean
function SardaukarCommander._acquireSardaukarCommander(color, origin, recruit)
    for _, marker in ipairs(getObjectsWithTag("SardaukarCommanderRecruitmentMarker")) do
        if Helper.getID(marker) == origin then
            SardaukarCommander.setAvailable(marker, false)
            if recruit then
                local garrisonPark = Combat.getGarrisonPark(color)
                local sardaukar = SardaukarCommander.protoSardaukar.clone({
                    position = Park.getPosition(garrisonPark) - Vector(0, 1, 0)
                })
                sardaukar.setScale(sardaukar.getScale():copy():scale(1/1.25))
                sardaukar.addTag("SardaukarCommander")
                sardaukar.addTag(color)
                sardaukar.setColorTint(color)
                sardaukar.setGMNotes(origin)
                Park.putObject(sardaukar, garrisonPark)
            end
            return true
        end
    end
    return false
end

---@param marker Object
---@param available boolean
function SardaukarCommander.setAvailable(marker, available)
    marker.editButton({
        index = 0,
        color = available and Helper.AREA_BUTTON_COLOR or { 1, 0, 0, 0.95 },
    })
end

---@param origin string
---@return boolean
function SardaukarCommander.isAvailable(origin)
    for _, marker in ipairs(SardaukarCommander.sardaukarMarkers) do
        if Helper.getID(marker) == origin then
            return not SardaukarCommander._getRecruitedSardaukar(origin)
        end
    end
    return false
end

---@param indexInRow integer
---@param color PlayerColor
function SardaukarCommander.acquireSardaukarCommanderSkillCard(indexInRow, color)
    if TurnControl.getPlayerCount() == 6 then
        if Commander.isTeamMuadDib(color) then
            return
        elseif Commander.isShaddam(color) then
            return
        end
    end
    local zone = SardaukarCommander.slotZones[indexInRow]
    return Helper.withAnyCard(zone, function (card)
        local newSkillCardName = Helper.getID(card)
        local skillCardNames = PlayBoard.getAllCommanderSkillNames(color)
        if not Helper.isElementOf(newSkillCardName, skillCardNames) then
            PlayBoard.grantSardaukarCommanderSkillCard(color, card)
            Helper.onceTimeElapsed(2).doAfter(Helper.partialApply(SardaukarCommander._setStrengthContributions, color))
            SardaukarCommander._replenish(indexInRow)
        else
            Dialog.broadcastToColor(I18N('sardaukarCommanderSkillAlreadyPossessed'), color, "Purple")
        end
    end)
end

---@param indexInRow integer
function SardaukarCommander._replenish(indexInRow)
    local position = SardaukarCommander.slotZones[indexInRow].getPosition()
    Helper.moveCardFromZone(SardaukarCommander.deckZone, position, Vector(0, 180, 0))
end

return SardaukarCommander
