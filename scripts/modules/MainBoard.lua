local Module = require("utils.Module")
local Helper = require("utils.Helper")
local Park = require("utils.Park")
local I18N = require("utils.I18N")
local Dialog = require("utils.Dialog")

local Resource = Module.lazyRequire("Resource")
local Types = Module.lazyRequire("Types")
local PlayBoard = Module.lazyRequire("PlayBoard")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")
local TechMarket = Module.lazyRequire("TechMarket")
local Combat = Module.lazyRequire("Combat")
local Hagal = Module.lazyRequire("Hagal")
local DynamicBonus = Module.lazyRequire("DynamicBonus")
local Action = Module.lazyRequire("Action")
local TurnControl = Module.lazyRequire("TurnControl")

local MainBoard = {}

---
function MainBoard.onLoad(state)

    Helper.append(MainBoard, Helper.resolveGUIDs(false, {
        board = "483a1a",
        otherBoard = "21cc52",
        --[[
        factions = {
            emperor = {
                alliance = "f7fff2",
                Green = "d7c9ba",
                Yellow = "489871",
                Blue = "426a23",
                Red = "acfcef"
            },
            spacingGuild = {
                alliance = "8f7ee3",
                Green = "89da7d",
                Yellow = "9d0075",
                Blue = "4069d8",
                Red = "be464e"
            },
            beneGesserit = {
                alliance = "a4da94",
                Green = "2dc980",
                Yellow = "a3729e",
                Blue = "2a88a6",
                Red = "713eae"
            },
            fremen = {
                alliance = "1ca742",
                Green = "d390dc",
                Yellow = "77d7c8",
                Blue = "0e6e41",
                Red = "088f51"
            }
        },
        ]]
        spaces = {
            -- Factions
            conspire = { zone = "cd9386" },
            wealth = { zone = "b2c461" },
            heighliner = { zone = "8b0515" },
            foldspace = { zone = "9a9eb5" },
            selectiveBreeding = { zone = "7dc6e5" },
            secrets = { zone = "1f7c08" },
            hardyWarriors = { zone = "a2fd8e" },
            stillsuits = { zone = "556f43" },
            -- Landsraad
            highCouncil = { zone = "8a6315" },
            mentat = { zone = "30cff9" },
            swordmaster = { zone = '6cc2f8' },
            rallyTroops = { zone = '6932df' },
            hallOfOratory = { zone = '3e7409' },
            -- CHOAM
            secureContract = { zone = "db4022" },
            sellMelange = { zone = "7539a3" },
            sellMelange_1 = { zone = "107a42" },
            sellMelange_2 = { zone = "43cb14" },
            sellMelange_3 = { zone = "b00ba5" },
            sellMelange_4 = { zone = "debf5e" },
            -- Dune
            arrakeen = { zone = "17b646" },
            carthag = { zone = "b1c938" },
            researchStation = { zone = "af11aa" },
            sietchTabr = { zone = "5bc970" },
            -- Desert
            imperialBasin = { zone = "2c77c1" },
            haggaBasin = { zone = "622708" },
            theGreatFlat = { zone = "69f925" },
        },
        ixSpaces = {
            -- Landsraad
            highCouncil = { zone = "dbdd82" },
            mentat = { zone = "d6c7dd" },
            swordmaster = { zone = "035975" },
            rallyTroops = Helper.ERASE,
            hallOfOratory = Helper.ERASE,
            -- CHOAM
            secureContract = Helper.ERASE,
            sellMelange = Helper.ERASE,
            sellMelange_1 = Helper.ERASE,
            sellMelange_2 = Helper.ERASE,
            sellMelange_3 = Helper.ERASE,
            sellMelange_4 = Helper.ERASE,
            smuggling = { zone = "82589e" },
            interstellarShipping = { zone = "487ad9" },
            -- Ix
            techNegotiation = { zone = "04f512" },
            techNegotiation_1 = { zone = "a7cdf8" },
            techNegotiation_2 = { zone = "479378" },
            dreadnought = { zone = "83ea90" },
        },
        immortalitySpaces = {
            researchStation = Helper.ERASE,
            researchStationImmortality = { zone = "af11aa" },
        },
        banners = {
            arrakeenBannerZone = "f1f53d",
            carthagBannerZone = "9fc2e1",
            imperialBasinBannerZone = "3fe117",
        },
        spiceBonusTokens = {
            imperialBasin = "3cdb2d",
            haggaBasin = "394db2",
            theGreatFlat = "116807"
        },
        mentat = "c2a908",
        mentatZones = {
            base = "a11936",
            ix = "0b21df"
        },
        highCouncilZones = {
            base = "e51f6e",
            ix = "a719db"
        },
        firstPlayerMarker = "1f5576",
    }))
    MainBoard.spiceBonuses = {}

    MainBoard.board = MainBoard.board or MainBoard.otherBoard

    Helper.noPhysicsNorPlay(MainBoard.board)
    Helper.forEachValue(MainBoard.spiceBonusTokens, Helper.noPhysicsNorPlay)

    for name, token in pairs(MainBoard.spiceBonusTokens) do
        MainBoard.spiceBonuses[name] = Resource.new(token, nil, "spice", 0, name)
    end

    if state.settings then
        for name, token in pairs(MainBoard.spiceBonusTokens) do
            if token then
                local value = state.MainBoard and state.MainBoard.spiceBonuses[name] or 0
                MainBoard.spiceBonuses[name]:set(value)
            end
        end

        MainBoard.highCouncilZone = getObjectFromGUID(state.MainBoard.highCouncilZoneGUID)
        MainBoard.mentatZone = getObjectFromGUID(state.MainBoard.mentatZoneGUID)
        MainBoard.spaces = Helper.map(state.MainBoard.spaceGUIDs, function (_, guid)
            return { zone = getObjectFromGUID(guid) }
        end)

        MainBoard._transientSetUp(state.settings)
    end
end

---
function MainBoard.onSave(state)
    state.MainBoard = {
        spiceBonuses = Helper.map(MainBoard.spiceBonuses, function (_, resource)
            return resource:get()
        end),

        highCouncilZoneGUID = MainBoard.highCouncilZone.getGUID(),
        mentatZoneGUID = MainBoard.mentatZone.getGUID(),
        spaceGUIDs = Helper.map(MainBoard.spaces, function (_, space)
            return space.zone.getGUID()
        end),
    }
end

---
function MainBoard.setUp(settings)
    local continuation = Helper.createContinuation("MainBoard.setUp")
    if settings.riseOfIx then
        MainBoard.highCouncilZones.base.destruct()
        MainBoard.highCouncilZone = MainBoard.highCouncilZones.ix
        MainBoard.mentatZones.base.destruct()
        MainBoard.mentatZone = MainBoard.mentatZones.ix
        --MainBoard.board.setState(1)
        continuation.run()
    else
        MainBoard.highCouncilZones.ix.destruct()
        MainBoard.highCouncilZone = MainBoard.highCouncilZones.base
        MainBoard.mentatZones.ix.destruct()
        MainBoard.mentatZone = MainBoard.mentatZones.base
        MainBoard.board.setState(2)
        Helper.onceTimeElapsed(2).doAfter(function ()
            MainBoard.board = getObjectFromGUID("21cc52")
            continuation.run()
        end)
    end

    local enabledExtensions = {
        ix = settings.riseOfIx,
        immortality = settings.immortality
    }

    for _, extension in ipairs({ "ix", "immortality" }) do
        for spaceName, extSpace in pairs(MainBoard[extension .. "Spaces"]) do
            if enabledExtensions[extension] then
                local baseSpace = MainBoard.spaces[spaceName]
                -- Immortality reuses the research station zone, so we skip its destruction.
                if baseSpace and spaceName ~= "researchStation" then
                    baseSpace.zone.destruct()
                end
                MainBoard.spaces[spaceName] = (extSpace ~= Helper.ERASE and extSpace or nil)
            else
                -- Same reason as above, the other way.
                if extSpace ~= Helper.ERASE and spaceName ~= "researchStationImmortality" then
                    extSpace.zone.destruct()
                end
            end
        end
        MainBoard[extension .. "Spaces"] = nil
    end

    local nextContinuation = Helper.createContinuation("MainBoard.setUp.next")
    continuation.doAfter(function ()
        MainBoard._transientSetUp(settings)
        nextContinuation.run()
    end)

    return nextContinuation
end

---
function MainBoard._transientSetUp(settings)
    MainBoard.highCouncilPark = MainBoard:_createHighCouncilPark(MainBoard.highCouncilZone)

    for name, space in pairs(MainBoard.spaces) do
        space.name = name

        local p = space.zone.getPosition()
        -- FIXME Hardcoded height, use an existing parent anchor.
        local slots = {
            Vector(p.x - 0.36, 0.68, p.z - 0.3),
            Vector(p.x + 0.36, 0.68, p.z + 0.3),
            Vector(p.x - 0.36, 0.68, p.z + 0.3),
            Vector(p.x + 0.36, 0.68, p.z - 0.3)
        }

        MainBoard._createSpaceButton(space, p, slots)
    end

    Helper.registerEventListener("phaseStart", function (phase)
        if phase == "makers" then
            for desert, _ in pairs(MainBoard.spiceBonusTokens) do
                local space = MainBoard.spaces[desert]
                local spiceBonus = MainBoard.spiceBonuses[desert]
                if Park.isEmpty(space.park) then
                    spiceBonus:change(1)
                end
            end
        elseif phase == "recall" then
            -- Recalling mentat.
            if MainBoard.mentat.hasTag("notToBeRecalled") then
                MainBoard.mentat.removeTag("notToBeRecalled")
            else
                for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
                    MainBoard.mentat.removeTag(color)
                end
                MainBoard.mentat.setPosition(MainBoard.mentatZone.getPosition())
            end

            -- Recalling dreadnoughts in controlable spaces.
            for _, bannerZone in pairs(MainBoard.banners) do
                for _, dreadnought in ipairs(Helper.filter(bannerZone.getObjects(), Types.isDreadnought)) do
                    for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
                        if dreadnought.hasTag(color) then
                            if dreadnought.hasTag("toBeRecalled") then
                                dreadnought.removeTag("toBeRecalled")
                                Park.putObject(dreadnought, Combat.getDreadnoughtPark(color))
                            else
                                dreadnought.addTag("toBeRecalled")
                            end
                        end
                    end
                end
            end

            -- Recalling agents.
            for _, space in pairs(MainBoard.spaces) do
                if space.park then
                    for _, object in ipairs(Park.getObjects(space.park)) do
                        if object.hasTag("Agent") and not object.hasTag("Mentat") then
                            for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
                                if object.hasTag(color) then
                                    Park.putObject(object, PlayBoard.getAgentPark(color))
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

---
function MainBoard:_createHighCouncilPark(zone)
    local seats = {}
    for i = 1, 4 do
        local x = (i - 2.5) * zone.getScale().x / 4
        local seat = Vector(x, 0, 0) + zone.getPosition()
        table.insert(seats, seat)
    end

    return Park.createPark(
        "HighCouncil",
        seats,
        Vector(0, 0, 0),
        { zone },
        { "HighCouncilSeatToken" },
        nil,
        true,
        true)
end

---
function MainBoard.getHighCouncilSeatPark()
    return MainBoard.highCouncilPark
end

---
function MainBoard.findControlableSpaceFromConflictName(conflictName)
    assert(conflictName)
    if conflictName == "secureImperialBasin" or conflictName == "battleForImperialBasin" then
        return MainBoard.banners.imperialBasinBannerZone
    elseif conflictName == "siegeOfArrakeen" or conflictName == "battleForArrakeen" then
        return MainBoard.banners.arrakeenBannerZone
    elseif conflictName == "siegeOfCarthag" or conflictName == "battleForCarthag" then
        return MainBoard.banners.carthagBannerZone
    else
        return nil
    end
end

---
function MainBoard.occupy(controlableSpace, color, onlyCleanUp)
    for _, object in ipairs(controlableSpace.getObjects()) do
        for _, otherColor in ipairs(PlayBoard.getActivePlayBoardColors()) do
            if Types.isControlMarker(object, otherColor) then
                if otherColor ~= color then
                    local p = PlayBoard.getControlMarkerBag(otherColor).getPosition() + Vector(0, 1, 0)
                    object.setLock(false)
                    object.setPosition(p)
                else
                    return
                end
            end
        end
    end

    if not onlyCleanUp then
        local p = controlableSpace.getPosition()
        PlayBoard.getControlMarkerBag(color).takeObject({
            -- Position is adjusted so as to insert the token below any dreadnought.
            position = Vector(p.x, 0.78, p.z),
            rotation = Vector(0, 180, 0),
            smooth = false,
            callback_function = function (controlMarker)
                controlMarker.setLock(true)
            end
        })
    end
end

---
function MainBoard._createSpaceButton(space, position, slots)
    Helper.createTransientAnchor("AgentPark", position - Vector(0, 0.5, 0)).doAfter(function (anchor)

        if MainBoard._findParentSpace(space) == space then
            local zone = space.zone
            local tags = { "Agent" }
            space.park = Park.createPark("AgentPark", slots, Vector(0, 0, 0), { zone }, tags, nil, false, true)

            local snapPoints = {}
            for _, slot in ipairs(slots) do
                table.insert(snapPoints, Helper.createRelativeSnapPoint(anchor, slot, false, tags))
            end
            anchor.setSnapPoints(snapPoints)
        end

        local tooltip = I18N("sendAgentTo", { space = I18N(space.name)})
        Helper.createAreaButton(space.zone, anchor, 0.7, tooltip, PlayBoard.withLeader(function (leader, color, _)
            if TurnControl.getCurrentPlayer() == color then
                leader.sendAgent(color, space.name)
            else
                Dialog.broadcastToColor(I18N('notYourTurn'), color, "Purple")
            end
        end))
    end)
end

--- TODO Rename "parent" to "root" since it's absolute, not relative.
function MainBoard._findParentSpace(space)
    local parentSpace = space
    local underscoreIndex = space.name:find("_")
    if underscoreIndex then
        local parentSpaceName = space.name:sub(1, underscoreIndex - 1)
        parentSpace = MainBoard.spaces[parentSpaceName]
        assert(parentSpace, "No parent space name named: " .. parentSpaceName)
    end
    return parentSpace
end

---
function MainBoard.sendAgent(color, spaceName)
    local continuation = Helper.createContinuation("MainBoard.sendAgent")

    local agent = MainBoard._findProperAgent(color)

    local buttonSpace = MainBoard.spaces[spaceName]
    local functionSpaceName = Helper.toCamelCase("_go", buttonSpace.name)
    local goSpace = MainBoard[functionSpaceName]
    assert(goSpace, "Unknow go space function: " .. functionSpaceName)

    local parentSpace = MainBoard._findParentSpace(buttonSpace)
    local parentSpaceName = parentSpace.name

    if not agent then
        Dialog.broadcastToColor(I18N("noAgent"), color, "Purple")
        continuation.cancel()
    elseif MainBoard.hasAgentInSpace(parentSpaceName, color) then
        Dialog.broadcastToColor(I18N("agentAlreadyPresent"), color, "Purple")
        continuation.cancel()
    else
        local leader = PlayBoard.getLeader(color)
        local innerContinuation = Helper.createContinuation("MainBoard." .. parentSpaceName)

        goSpace(color, leader, innerContinuation)
        innerContinuation.doAfter(function (action)
            -- The innerContinuation never cancels (but returns nil) to allow us to cancel the root continuation.
            if action then
                Helper.emitEvent("agentSent", color, parentSpaceName)
                Action.setContext("agentSent", { space = parentSpaceName, cards = Helper.mapValues(PlayBoard.getCardsPlayedThisTurn(color), Helper.getID) })
                Park.putObject(agent, parentSpace.park)
                action()
                MainBoard.collectExtraBonuses(color, leader, spaceName)
                -- FIXME We are cheating here...
                Helper.onceTimeElapsed(1).doAfter(function ()
                    Action.unsetContext("agentSent")
                end)
                continuation.run()
            else
                continuation.cancel()
            end
        end)
    end

    return continuation
end

---
function MainBoard._findProperAgent(color)
    local agentPark = PlayBoard.getAgentPark(color)
    return Park.getObjects(agentPark)[1]
end

---
function MainBoard.sendRivalAgent(color, spaceName)
    local space = MainBoard.spaces[spaceName]
    assert(space, spaceName)
    if not Park.isEmpty(PlayBoard.getAgentPark(color)) then
        local agentPark = PlayBoard.getAgentPark(color)
        Helper.emitEvent("agentSent", color, spaceName)
        Action.setContext("agentSent", { space = spaceName })
        Park.transfert(1, agentPark, space.park)
        if spaceName == "imperialBasin" then
            MainBoard._applyControlOfAnySpace(MainBoard.banners.imperialBasinBannerZone, "spice")
        elseif spaceName == "arrakeen" then
            MainBoard._applyControlOfAnySpace(MainBoard.banners.arrakeenBannerZone, "solari")
        elseif spaceName == "carthag" then
            MainBoard._applyControlOfAnySpace(MainBoard.banners.carthagBannerZone, "solari")
        end
        return true
    else
        return false
    end
end

---
function MainBoard._hasResource(leader, color, resourceName, amount)
    local realAmount = leader.bargain(color, resourceName, amount)
    return PlayBoard.getResource(color, resourceName):get() >= realAmount
end

---
function MainBoard._checkGenericAccess(color, leader, requirements)
    if PlayBoard.isRival(color) then
        return true
    end

    for requirement, value in pairs(requirements) do
        if Helper.isElementOf(requirement, { "spice", "water", "solari" }) then
            if not MainBoard._hasResource(leader, color, requirement, value) then
                Dialog.broadcastToColor(I18N("noResource", { resource = I18N(requirement .. "Amount") }), color, "Purple")
                return false
            end
        elseif requirement == "friendship" then
            local infiltrationCards = {
                "kwisatzHaderach",
                "guildAccord",
                "choamDelegate",
                "bountyHunter",
                "embeddedAgent",
                "tleilaxuInfiltrator",
            }
            for _, cardName in ipairs(infiltrationCards) do
                if PlayBoard.hasPlayedThisTurn(color, cardName) then
                    return true
                end
            end
            if not InfluenceTrack.hasFriendship(color, value) then
                Dialog.broadcastToColor(I18N("noFriendship", { withFaction = I18N(Helper.toCamelCase("with", value)) }), color, "Purple")
                return false
            end
        end
    end
    return true
end

---
function MainBoard._goConspire(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { spice = 4 }) then
        continuation.run(function ()
            leader.resources(color, "spice", -4)
            leader.resources(color, "solari", 5)
            leader.troops(color, "supply", "garrison", 2)
            leader.drawIntrigues(color, 1)
            leader.influence(color, "emperor", 1)
        end)
    else
        continuation.run()
    end
end

---
function MainBoard._goWealth(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, {}) then
        continuation.run(function ()
            leader.resources(color, "solari", 2)
            leader.influence(color, "emperor", 1)
        end)
    else
        continuation.run()
    end
end

---
function MainBoard._goHeighliner(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { spice = 6 }) then
        continuation.run(function ()
            leader.resources(color, "spice", -6)
            leader.resources(color, "water", 2)
            leader.troops(color, "supply", "garrison", 5)
            leader.influence(color, "spacingGuild", 1)
        end)
    else
        continuation.run()
    end
end

---
function MainBoard._goFoldspace(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, {}) then
        continuation.run(function ()
            leader.acquireFoldspace(color)
            leader.influence(color, "spacingGuild", 1)
        end)
    else
        continuation.run()
    end
end

---
function MainBoard._goSelectiveBreeding(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { spice = 2 }) then
        continuation.run(function ()
            leader.resources(color, "spice", -2)
            leader.influence(color, "beneGesserit", 1)
        end)
    else
        continuation.run()
    end
end

---
function MainBoard._goSecrets(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, {}) then
        continuation.run(function ()
            leader.drawIntrigues(color, 1)
            for _, otherColor in ipairs(PlayBoard.getActivePlayBoardColors()) do
                if otherColor ~= color then
                    Helper.dump(otherColor, "-»", #PlayBoard.getIntrigues(otherColor))
                    if #PlayBoard.getIntrigues(otherColor) > 3 then
                        leader.stealIntrigue(color, otherColor, 1)
                    end
                end
            end
            leader.influence(color, "beneGesserit", 1)
        end)
    else
        continuation.run()
    end
end

---
function MainBoard._goHardyWarriors(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { water = 1 }) then
        continuation.run(function ()
            leader.resources(color, "water", -1)
            leader.troops(color, "supply", "garrison", 2)
            leader.influence(color, "fremen", 1)
        end)
    else
        continuation.run()
    end
end

---
function MainBoard._goStillsuits(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, {}) then
        continuation.run(function ()
            leader.resources(color, "water", 1)
            leader.influence(color, "fremen", 1)
        end)
    else
        continuation.run()
    end
end

---
function MainBoard._goImperialBasin(color, leader, continuation)
    local innerContinuation = Helper.createContinuation("MainBoard._goImperialBasin")
    MainBoard._anySpiceSpace(color, leader, innerContinuation, 0, 1, MainBoard.spiceBonuses.imperialBasin)
    innerContinuation.doAfter(function (action)
        continuation.run(function ()
            action()
            MainBoard._applyControlOfAnySpace(MainBoard.banners.imperialBasinBannerZone, "spice")
        end)
    end)
end

---
function MainBoard._goHaggaBasin(color, leader, continuation)
    MainBoard._anySpiceSpace(color, leader, continuation, 1, 2, MainBoard.spiceBonuses.haggaBasin)
end

---
function MainBoard._goTheGreatFlat(color, leader, continuation)
    MainBoard._anySpiceSpace(color, leader, continuation, 2, 3, MainBoard.spiceBonuses.theGreatFlat)
end

---
function MainBoard._anySpiceSpace(color, leader, continuation, waterCost, spiceBaseAmount, spiceBonus)
    if MainBoard._checkGenericAccess(color, leader, { water = waterCost }) then
        continuation.run(function ()
            leader.resources(color, "water", -waterCost)
            local harvestedSpiceAmount = MainBoard._harvestSpice(spiceBaseAmount, spiceBonus)
            leader.resources(color, "spice", harvestedSpiceAmount)
        end)
    else
        continuation.run()
    end
end

---
function MainBoard.getSpiceBonus(desertSpaceName)
    assert(MainBoard.isDesertSpace(desertSpaceName))
    return MainBoard.spiceBonuses[desertSpaceName]
end

---
function MainBoard._harvestSpice(baseAmount, spiceBonus)
    assert(spiceBonus)
    local spiceAmount = baseAmount + spiceBonus:get()
    spiceBonus:set(0)
    return spiceAmount
end

---
function MainBoard._goSietchTabr(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { friendship = "fremen" }) then
        continuation.run(function ()
            leader.troops(color, "supply", "garrison", 1)
            leader.resources(color, "water", 1)
        end)
    else
        continuation.run()
    end
end

---
function MainBoard._goResearchStation(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { water = 2 }) then
        continuation.run(function ()
            leader.resources(color, "water", -2)
            leader.drawImperiumCards(color, 3)
        end)
    else
        continuation.run()
    end
end

---
function MainBoard._goResearchStationImmortality(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { water = 2 }) then
        continuation.run(function ()
            leader.resources(color, "water", -2)
            leader.drawImperiumCards(color, 2)
            leader.research(color)
        end)
    else
        continuation.run()
    end
end

---
function MainBoard._goCarthag(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, {}) then
        continuation.run(function ()
            leader.drawIntrigues(color, 1)
            leader.troops(color, "supply", "garrison", 1)
            MainBoard._applyControlOfAnySpace(MainBoard.banners.carthagBannerZone, "solari")
        end)
    else
        continuation.run()
    end
end

---
function MainBoard._goArrakeen(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, {}) then
        continuation.run(function ()
            leader.troops(color, "supply", "garrison", 1)
            leader.drawImperiumCards(color, 1)
            MainBoard._applyControlOfAnySpace(MainBoard.banners.arrakeenBannerZone, "solari")
        end)
    else
        continuation.run()
    end
end

---
function MainBoard._applyControlOfAnySpace(bannerZone, resourceName)
    local controllingPlayer = MainBoard.getControllingPlayer(bannerZone)
    if controllingPlayer then
        PlayBoard.getLeader(controllingPlayer).resources(controllingPlayer, resourceName, 1)
    end
end

---
function MainBoard.getControllingPlayer(bannerZone)
    local controllingPlayer = nil

    -- Check player dreadnoughts first since they supersede flags.
    for _, object in ipairs(bannerZone.getObjects()) do
        for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
            if Types.isDreadnought(object, color) then
                assert(not controllingPlayer, "Too many dreadnoughts")
                controllingPlayer = color
            end
        end
    end

    -- Check player flags otherwise.
    if not controllingPlayer then
        for _, object in ipairs(bannerZone.getObjects()) do
            for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
                if Types.isControlMarker(object, color) then
                    assert(not controllingPlayer, "Too many flags around")
                    controllingPlayer = color
                end
            end
        end
    end

    return controllingPlayer
end

---
function MainBoard.getControllingDreadnought(bannerZone)
    for _, object in ipairs(bannerZone.getObjects()) do
        for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
            if Types.isDreadnought(object, color) then
                return object
            end
        end
    end
    return nil
end

---
function MainBoard._goSwordmaster(color, leader, continuation)
    if PlayBoard.hasSwordmaster(color) then
        Dialog.broadcastToColor(I18N("alreadyHaveSwordmaster"), color, "Purple")
        continuation.run()
    elseif MainBoard._checkGenericAccess(color, leader, { solari = 8 }) then
        continuation.run(function ()
            leader.resources(color, "solari", -8)
            -- Wait for the first agent sent to be marked as moving (not resting),
            -- then move the swordmaster. Otherwise, the target agent park will
            -- grab the first agent back to the park when tidying it up.
            Helper.onceFramesPassed(1).doAfter(function ()
                leader.recruitSwordmaster(color)
            end)
        end)
    else
        continuation.run()
    end
end

---
function MainBoard._goMentat(color, leader, continuation)
    local mentatCost = Hagal.getMentatSpaceCost()
    if MainBoard._checkGenericAccess(color, leader, { solari = mentatCost }) then
        continuation.run(function ()
            leader.resources(color, "solari", -mentatCost)
            leader.drawImperiumCards(color, 1)
            -- Wait for the first agent sent to be marked as moving (not resting),
            -- then move the swordmaster. Otherwise, the target agent park will
            -- grab the first agent back to the park when tidying it up.
            Helper.onceFramesPassed(1).doAfter(function ()
                leader.takeMentat(color)
            end)
        end)
    else
        continuation.run()
    end
end

---
function MainBoard.getMentat()
    if Vector.distance(MainBoard.mentat.getPosition(), MainBoard.mentatZone.getPosition()) < 1 then
        return MainBoard.mentat
    else
        return nil
    end
end

---
function MainBoard._goHighCouncil(color, leader, continuation)
    if PlayBoard.hasHighCouncilSeat(color) then
        Dialog.broadcastToColor(I18N("alreadyHaveHighCouncilSeat"), color, "Purple")
        continuation.run()
    elseif MainBoard._checkGenericAccess(color, leader, { solari = 5 }) then
        continuation.run(function ()
            leader.resources(color, "solari", -5)
            leader.takeHighCouncilSeat(color)
        end)
    else
        continuation.run()
    end
end

---
function MainBoard._goSecureContract(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, {}) then
        continuation.run(function ()
            leader.resources(color, "solari", 3)
        end)
    else
        continuation.run()
    end
end

function MainBoard._goSellMelange(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { spice = "2" }) then
        local hasEnoughSpice = function (index, _)
            local spiceCost = index + 1
            return MainBoard._hasResource(leader, color, "spice", spiceCost)
        end
        local options = Helper.takeWhile(hasEnoughSpice, {
            "2 -> 4",
            "3 -> 8",
            "4 -> 10",
            "5 -> 12",
        })
        Dialog.showOptionsAndCancelDialog(color, I18N("goSellMelange"), options, continuation, function (index)
            if index > 0 then
                MainBoard._sellMelange(color, leader, continuation, index)
            else
                continuation.run()
            end
        end)
    else
        continuation.run()
    end
end

function MainBoard._goSellMelange_1(color, leader, continuation)
    return MainBoard._sellMelange(color, leader, continuation, 1)
end

function MainBoard._goSellMelange_2(color, leader, continuation)
    return MainBoard._sellMelange(color, leader, continuation, 2)
end

function MainBoard._goSellMelange_3(color, leader, continuation)
    return MainBoard._sellMelange(color, leader, continuation, 3)
end

function MainBoard._goSellMelange_4(color, leader, continuation)
    return MainBoard._sellMelange(color, leader, continuation, 4)
end

function MainBoard._sellMelange(color, leader, continuation, index)
    local spiceCost = index + 1
    if MainBoard._checkGenericAccess(color, leader, { spice = spiceCost }) then
        continuation.run(function ()
            leader.resources(color, "spice", -spiceCost)
            local solariBenefit = (index + 1) * 2 + 2
            leader.resources(color, "solari", solariBenefit)
        end)
    else
        continuation.run()
    end
end

---
function MainBoard._goRallyTroops(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { solari = 4 }) then
        continuation.run(function ()
            leader.resources(color, "solari", -4)
            leader.troops(color, "supply", "garrison", 4)
        end)
    else
        continuation.run()
    end
end

---
function MainBoard._goHallOfOratory(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, {}) then
        continuation.run(function ()
            leader.troops(color, "supply", "garrison", 1)
            leader.resources(color, "persuasion", 1)
        end)
    else
        continuation.run()
    end
end

---
function MainBoard._goSmuggling(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, {}) then
        continuation.run(function ()
            leader.resources(color, "solari", 1)
            leader.shipments(color, 1)
        end)
    else
        continuation.run()
    end
end

---
function MainBoard._goInterstellarShipping(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { friendship = "spacingGuild" }) then
        continuation.run(function ()
            leader.shipments(color, 2)
        end)
    else
        continuation.run()
    end
end

function MainBoard._goTechNegotiation(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, {}) then
        local options = {
            I18N("sendNegotiatorOption"),
            I18N("buyTechWithDiscount1Option"),
        }
        Dialog.showOptionsAndCancelDialog(color, I18N("goTechNegotiation"), options, continuation, function (index)
            if index == 1 then
                MainBoard._goTechNegotiation_2(color, leader, continuation)
            elseif index == 2 then
                MainBoard._goTechNegotiation_1(color, leader, continuation)
            else
                assert(index == 0)
                continuation.run()
            end
        end)
    else
        continuation.run()
    end
end

function MainBoard._goTechNegotiation_1(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, {}) then
        continuation.run(function ()
            leader.resources(color, "persuasion", 1)
            TechMarket.registerAcquireTechOption(color, "techNegotiationTechBuyOption", "spice", 1)
        end)
    else
        continuation.run()
    end
end

function MainBoard._goTechNegotiation_2(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, {}) then
        continuation.run(function ()
            leader.resources(color, "persuasion", 1)
            leader.troops(color, "supply", "negotiation", 1)
        end)
    else
        continuation.run()
    end
end

---
function MainBoard._goDreadnought(color, leader, continuation)
    if MainBoard._checkGenericAccess(color, leader, { solari = 3 }) then
        continuation.run(function ()
            leader.resources(color, "solari", -3)
            TechMarket.registerAcquireTechOption(color, "dreadnoughtTechBuyOption", "spice", 0)
            Park.transfert(1, PlayBoard.getDreadnoughtPark(color), Combat.getDreadnoughtPark(color))
        end)
    else
        continuation.run()
    end
end

--- The color could be nil (the same way it could be nil with Types.isAgent)
function MainBoard.hasAgentInSpace(spaceName, color)
    local space = MainBoard.spaces[spaceName]
    -- Avoid since it depends on the active extensions.
    --assert(space, "Unknow space: " .. spaceName)
    if space then
        for _, object in ipairs(space.zone.getObjects()) do
            if Types.isAgent(object, color) then
                return true
            end
        end
    end
    return false
end

---
function MainBoard.hasEnemyAgentInSpace(spaceName, color)
    for _, otherColor in ipairs(PlayBoard.getActivePlayBoardColors()) do
        if otherColor ~= color and MainBoard.hasAgentInSpace(spaceName, otherColor) then
            return true
        end
    end
    return false
end

---
function MainBoard.hasVoiceToken(spaceName)
    local space = MainBoard.spaces[spaceName]
    if space then
        return #Helper.filter(space.zone.getObjects(), Types.isVoiceToken) > 0
    end
    return false
end

---
function MainBoard.isEmperorSpace(spaceName)
    return Helper.isElementOf(spaceName, MainBoard.getEmperorSpaces())
end

---
function MainBoard.getEmperorSpaces()
    return {
        "conspire",
        "wealth" }
end

---
function MainBoard.isSpacingGuildSpace(spaceName)
    return Helper.isElementOf(spaceName, MainBoard.getSpacingGuildSpace())
end

---
function MainBoard.getSpacingGuildSpace()
    return {
        "heighliner",
        "foldspace" }
end

---
function MainBoard.isBeneGesseritSpace(spaceName)
    return Helper.isElementOf(spaceName, MainBoard.getBeneGesseritSpaces())
end

---
function MainBoard.getBeneGesseritSpaces()
    return {
        "selectiveBreeding",
        "secrets" }
end

---
function MainBoard.isFremenSpace(spaceName)
    return Helper.isElementOf(spaceName, MainBoard.getFremenSpaces())
end

---
function MainBoard.getFremenSpaces()
    return {
        "hardyWarriors",
        "stillsuits" }
end

---
function MainBoard.isFactionSpace(spaceName)
    return MainBoard.isEmperorSpace(spaceName)
        or MainBoard.isSpacingGuildSpace(spaceName)
        or MainBoard.isBeneGesseritSpace(spaceName)
        or MainBoard.isFremenSpace(spaceName)
end

---
function MainBoard.isLandsraadSpace(spaceName)
    return Helper.isElementOf(spaceName, MainBoard.getLandsraadSpaces())
end

---
function MainBoard.getLandsraadSpaces()
    return {
        "highCouncil",
        "mentat",
        "swordmaster",
        "rallyTroops",
        "hallOfOratory",
        "techNegotiation",
        "dreadnought" }
end

---
function MainBoard.isCHOAMSpace(spaceName)
    return Helper.isElementOf(spaceName, MainBoard.getCHOAMSpaces())
end

---
function MainBoard.getCHOAMSpaces()
    return {
        "secureContract",
        "sellMelange",
        "smuggling",
        "interstellarShipping" }
end

---
function MainBoard.isCitySpace(spaceName)
    return Helper.isElementOf(spaceName, MainBoard.getCitySpaces())
end

---
function MainBoard.getCitySpaces()
    return {
        "arrakeen",
        "carthag",
        "researchStation",
        "researchStationImmortality",
        "sietchTabr" }
end

---
function MainBoard.isDesertSpace(spaceName)
    return Helper.isElementOf(spaceName, MainBoard.getDesertSpaces())
end

---
function MainBoard.getDesertSpaces()
    return {
        "imperialBasin",
        "haggaBasin",
        "theGreatFlat" }
end

---
function MainBoard.isSpiceTradeSpace(spaceName)
    return MainBoard.isDesertSpace(spaceName)
        or MainBoard.isCHOAMSpace(spaceName)
end

---
function MainBoard.getCombatSpaces()
    return {
        "heighliner",
        "hardyWarriors",
        "stillsuits",
        "arrakeen",
        "carthag",
        "researchStation",
        "researchStationImmortality",
        "sietchTabr",
        "imperialBasin",
        "haggaBasin",
        "theGreatFlat" }
end

---
function MainBoard.isCombatSpace(spaceName)
    local result = Helper.isElementOf(spaceName, MainBoard.getCombatSpaces())
    --Helper.dump(spaceName, "is a combat space ->", result)
    return result
end

---
function MainBoard.getBannerZones()
    return {
        MainBoard.banners.imperialBasinBannerZone,
        MainBoard.banners.arrakeenBannerZone,
        MainBoard.banners.carthagBannerZone,
    }
end

---
function MainBoard.onObjectEnterScriptingZone(zone, object)
    if zone == MainBoard.mentatZone then
        if Types.isMentat(object) then
            for _, color in ipairs(PlayBoard.getActivePlayBoardColors()) do
                object.removeTag(color)
            end
            -- FIXME One case of whitewashing too many?
            object.setColorTint(Color.fromString("White"))
        end
    end
end

---
function MainBoard.addSpaceBonus(spaceName, bonuses)
    local space = MainBoard.spaces[spaceName]
    assert(space, "Unknow space: " .. spaceName)
    if not space.extraBonuses then
        space.extraBonuses = {}
    end
    DynamicBonus.createSpaceBonus(space.zone.getPosition() + Vector(1.2, 0, 0.75), bonuses, space.extraBonuses)
end

---
function MainBoard.collectExtraBonuses(color, leader, spaceName)
    local space = MainBoard.spaces[spaceName]
    if space.extraBonuses then
        DynamicBonus.collectExtraBonuses(color, leader, space.extraBonuses)
    end
end

---
function MainBoard.getSnooperTrackPosition(faction)

    local getAveragePosition = function (spaceNames)
        local p = Vector(0, 0, 0)
        local count = 0
        for _, spaceName in ipairs(spaceNames) do
            local space = MainBoard.spaces[spaceName]
            assert(space, spaceName)
            p = p + space.zone.getPosition()
            count = count + 1
        end
        return p * (1 / count)
    end

    local positions = {
        emperor = getAveragePosition({ "conspire", "wealth" }),
        spacingGuild = getAveragePosition({ "heighliner", "foldspace" }),
        beneGesserit = getAveragePosition({ "selectiveBreeding", "secrets" }),
        fremen = getAveragePosition({ "hardyWarriors", "stillsuits" }),
    }

    return positions[faction]
end

---
function MainBoard.getFirstPlayerMarker()
    return MainBoard.firstPlayerMarker
end

---
function MainBoard.trash(object)
    MainBoard.trashQueue = MainBoard.trashQueue or Helper.createSpaceQueue()
    MainBoard.trashQueue.submit(function (height)
        object.interactable = true
        object.setLock(false)
        object.setPosition(getObjectFromGUID('ef8614').getPosition() + Vector(0, 1 + height * 0.5, 0))
    end)
end

return MainBoard
