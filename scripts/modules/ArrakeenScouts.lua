local Module = require("utils.Module")
local Helper = require("utils.Helper")
local I18N = require("utils.I18N")
local Park = require("utils.Park")
local Set = require("utils.Set")

local TurnControl = Module.lazyRequire("TurnControl")
local PlayBoard = Module.lazyRequire("PlayBoard")
local MainBoard = Module.lazyRequire("MainBoard")
local TleilaxuRow = Module.lazyRequire("TleilaxuRow")
local TleilaxuResearch = Module.lazyRequire("TleilaxuResearch")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")
local ImperiumCard = Module.lazyRequire("ImperiumCard")
local Combat = Module.lazyRequire("Combat")
local Intrigue = Module.lazyRequire("Intrigue")
local Types = Module.lazyRequire("Types")

local ArrakeenScouts = {
    committees = {
        base = {
            appropriations = true,
            development = true,
            information = true,
            investigation = true,
            joinForces = true,
            politicalAffairs = true,
            preparation = true,
            relations = true,
            supervision = true,
        },
        immortality = {
            dataAnalysis = true,
            developmentProject = true,
            tleilaxuRelations = true,
        }
    },
    auctions = {
        base = {
            mentat = true,
            mercenaries = true,
            treachery = true,
        },
        ix = {
            toTheHighestBidder = true,
        },
        immortality = {
            competitiveStudy = true,
        },
    },
    events = {
        base = {
            changeOfPlans = true,
            covertOperation = true,
            giftOfWater = true,
            influenceGain = {
                desertGift = true,
                guildNegotiation = true,
                intriguingGift = true,
                testOfLoyalty = true,
            },
            influenceReduction = {
                beneGesseritTreachery = true,
                emperorsTax = true,
                fremenExchange = true,
                politicalEquilibrium = true,
                waterForSpiceSmugglers = true,
            },
            intrigueBonus = {
                rotationgDoors = true,
                secretsForSale = true,
            },
            noComingBack = true,
            spiceGain = {
                tapIntoSpiceReserves = true,
            },
        },
        immortality = {
            getBackInTheGoodGraces = true,
            treachery = true,
            newInnovations = true,
            offWordOperation = true,
            ceaseAndDesistRequest = true,
        },
    },
    missions = {
        base = {
            botanicTesting = {
                secretsInTheDesert = true,
                stationedSupport = true,
            },
            geneticResearch = true,
            guildManipulations = true,
            musterAnArmy = {
                spiceIncentive = true,
                strongarmedAlliance = true,
            },
            saphoJuice = true,
            spaceTravelDeal = true,
        },
        ix = {
            armedEscort = true,
            musterAnArmy = Helper.ERASE,
            secretStash = true,
            stowaway = true,
        },
        immortality = {
            backstageAgreement = true,
            botanicTesting = {
                secretsInTheDesert = Helper.ERASE,
                secretsInTheDesert_immortality = true,
                stationedSupport = Helper.ERASE,
                stationedSupport_immortality = true,
            },
            coordinationWithTheEmperor = true,
            sponsoredResearch = true,
            tleilaxuOffering = true,
        },
    },
    sales = {
        base = {
            fremenMercenaries = true,
            revealTheFuture = true,
            sooSooSookWaterPeddlers = true,
        },
    },
    pendingOperations = {},
}

--ArrakeenScouts._debug = { "stationedSupport_immortality" }

---
function ArrakeenScouts.onLoad(state)
    ArrakeenScouts.fr = require("fr.ArrakeenScouts")
    ArrakeenScouts.en = require("en.ArrakeenScouts")
    Helper.append(ArrakeenScouts, Helper.resolveGUIDs(true, {
        board = "54b5be",
        committeeZones = {
            "1d4471",
            "c2d35a",
            "f02b42",
            "e09c43",
            "f39539",
        }
    }))

    Helper.noPhysicsNorPlay(ArrakeenScouts.board)

    if state.settings then
        ArrakeenScouts.selectedCommittees = state.selectedCommittees
        ArrakeenScouts.selectedContent = state.selectedContent
        ArrakeenScouts.numberOfPlayers = state.numberOfPlayers
        ArrakeenScouts._staticSetUp()
    end
end

---
function ArrakeenScouts.onSave(state)
    state.ArrakeenScouts = {
        selectedCommittees = ArrakeenScouts.selectedCommittees,
        selectedContent = ArrakeenScouts.selectedContent,
        numberOfPlayers = ArrakeenScouts.numberOfPlayers,
    }
end

---
function ArrakeenScouts.setUp(settings)
    if settings.variant == "arrakeenScouts" then
        ArrakeenScouts.numberOfPlayers = settings.numberOfPlayers

        local selection = {}
        for _, category in ipairs({ "committees", "auctions", "events", "missions", "sales" }) do
            local contributions = ArrakeenScouts._mergeContributions({
                ArrakeenScouts[category].base,
                settings.riseOfIx and ArrakeenScouts[category].ix or {},
                settings.immortality and ArrakeenScouts[category].immortality or {}})

            selection[category] = {}
            for key, value in pairs(contributions) do
                local item
                if type(value) == "table" then
                    item = Helper.pickAnyKey(value)
                else
                    item = key
                end
                table.insert(selection[category], item)
            end
            Helper.shuffle(selection[category])
        end

        ArrakeenScouts.selectedCommittees = {
            selection.committees[1],
            selection.committees[2],
            selection.committees[3],
            selection.committees[4],
            selection.committees[5],
        }

        ArrakeenScouts.selectedContent = {}
        if ArrakeenScouts._debug then
            table.insert(ArrakeenScouts.selectedContent, ArrakeenScouts._debug )
        end
        if math.random() > 0 then
            table.insert(ArrakeenScouts.selectedContent, { selection.missions[1], selection.missions[2] })
            table.insert(ArrakeenScouts.selectedContent, { selection.missions[3] })
        else
            table.insert(ArrakeenScouts.selectedContent, { selection.missions[1] })
            table.insert(ArrakeenScouts.selectedContent, { selection.missions[2], selection.missions[3] })
        end
        table.insert(ArrakeenScouts.selectedContent, { selection.events[1] })
        if math.random() > 0 then
            table.insert(ArrakeenScouts.selectedContent, { selection.auctions[1] .. "1", selection.events[2] })
            table.insert(ArrakeenScouts.selectedContent, { selection.events[3] })
        else
            table.insert(ArrakeenScouts.selectedContent, { selection.events[2] })
            table.insert(ArrakeenScouts.selectedContent, { selection.auctions[1] .. "1", selection.events[3] })
        end
        table.insert(ArrakeenScouts.selectedContent, { selection.events[4] })
        if math.random() > 0 then
            table.insert(ArrakeenScouts.selectedContent, { selection.auctions[2] .. "2" })
            table.insert(ArrakeenScouts.selectedContent, { selection.sales[1] })
        else
            table.insert(ArrakeenScouts.selectedContent, { selection.sales[1] })
            table.insert(ArrakeenScouts.selectedContent, { selection.auctions[2] .. "2" })
        end

        TurnControl.registerSpecialPhase("arrakeenScouts")
        ArrakeenScouts._staticSetUp()
    else
        ArrakeenScouts._tearDown()
    end
end

---
function ArrakeenScouts._mergeContributions(contributionSets)
    local contributions = {}
    for _, contributionSet in ipairs(contributionSets) do
        for name, element in pairs(contributionSet) do
            if type(element) == "table" then
                local subContributionSets = {
                    contributions[name] or {},
                    element,
                }
                contributions[name] = ArrakeenScouts._mergeContributions(subContributionSets)
            else
                local value
                if element == Helper.ERASE then
                    value = nil
                else
                    value = element
                end
                contributions[name] = value
            end
        end
    end
    return contributions
end

---
function ArrakeenScouts._staticSetUp()
    Helper.registerEventListener("phaseStart", function (phaseName)
        if phaseName == "arrakeenScouts" then
            local round = TurnControl.getCurrentRound()
            local firstRound = ArrakeenScouts._debug and 0 or 1
            if round == firstRound then
                ArrakeenScouts.committeeTiles = {}
                ArrakeenScouts.committeeAnchors = {}
                for i, committee in ipairs(ArrakeenScouts.selectedCommittees) do
                    local zone = ArrakeenScouts.committeeZones[i]
                    if i <= ArrakeenScouts.numberOfPlayers + 1 then
                        ArrakeenScouts._createCommitteeTile(committee, zone).doAfter(function (tile)
                            tile.interactable = false
                            ArrakeenScouts.committeeTiles[i] = tile
                            local tooltip = I18N("joinCommittee", { committee = I18N(committee) })
                            ArrakeenScouts.committeeAnchors[i] = tile
                            Helper.createAreaButton(zone, tile, 0.85, tooltip, PlayBoard.withLeader(function (_, color, _)
                                ArrakeenScouts.joinCommitee(color, i)
                            end))
                        end)
                    else
                        zone.destruct()
                    end
                end
                Helper.onceFramesPassed(1).doAfter(TurnControl.endOfPhase)
            else
                -- Give some time to setup / recall to stabilize.
                Helper.onceTimeElapsed(2).doAfter(ArrakeenScouts._nextContent)
            end
        end
    end)

    Helper.registerEventListener("playerTurns", function (color)
        ArrakeenScouts.committeeAccess = {}
    end)

    Helper.registerEventListener("highCouncilSeatTaken", function (color)
        ArrakeenScouts.committeeAccess[color] = true
        Player[color].showInfoDialog(I18N("committeeReminder"))
    end)
end

---
function ArrakeenScouts._tearDown()
    ArrakeenScouts.board.destruct()
    for _, zone in ipairs(ArrakeenScouts.committeeZones) do
        zone.destruct()
    end
end

---
function ArrakeenScouts._nextContent()
    local round = TurnControl.getCurrentRound()
    local firstRound = ArrakeenScouts._debug and 0 or 1
    local contents = ArrakeenScouts.selectedContent[round - firstRound]

    local missions = {}
    for _, pendingOperation in ipairs(ArrakeenScouts.pendingOperations) do
        if pendingOperation.round == round then
            missions[pendingOperation.operation] = true
        end
    end
    for operation, _ in pairs(missions) do
        table.insert(contents, 1, operation .. "Reward")
    end

    if contents and #contents > 0 then
        local content = contents[1]
        table.remove(contents, 1)
        --Helper.dump("content = ", content)
        ArrakeenScouts._createDialog(content)
    else
        --Helper.dump("TurnControl.endOfPhase()")
        TurnControl.endOfPhase()
    end
end

---
function ArrakeenScouts._createCommitteeTile(committee, zone)
    local image = ArrakeenScouts[I18N.getLocale()][committee]
    assert(image, "Unknow Arrakeen Scouts content: " .. committee)

    local data = {
        Name = "Custom_Tile",
        Transform = {
            posX = 0,
            posY = 0,
            posZ = 0,
            rotX = 0,
            rotY = 180,
            rotZ = 0,
            scaleX = 0.25,
            scaleY = 1.0,
            scaleZ = 0.25
        },
        ColorDiffuse = {
            r = 0,
            g = 0,
            b = 0
        },
        Locked = false,
        Grid = false,
        Snap = false,
        IgnoreFoW = false,
        MeasureMovement = false,
        DragSelectable = true,
        Autoraise = true,
        Sticky = false,
        Tooltip = true,
        GridProjection = false,
        HideWhenFaceDown = false,
        Hands = false,
        CustomImage = {
            ImageURL = image,
            ImageSecondaryURL = "",
            ImageScalar = 1.0,
            WidthScale = 0.0,
            CustomTile = {
                Type = 0,
                Thickness = 0.1,
                Stackable = false,
                Stretch = true
            }
        }
    }

    local continuation = Helper.createContinuation("ArrakeenScouts._createCommitteeTile")

    local spawnParameters = {
        data = data,
        position = zone.getPosition() - Vector(0, 0.19, 0),
        callback_function = function (tile)
            tile.interactable = false
            continuation.run(tile)
        end
    }

    spawnObjectData(spawnParameters)

    return continuation
end

---
function ArrakeenScouts._createDialog(content)
    local createController = ArrakeenScouts[Helper.toCamelCase("_create", content, "controller")]
    assert(createController, "No create controller function for content: " .. content)

    local playerPanes = {}
    for _, color in ipairs(PlayBoard.getPlayBoardColors()) do
        local leaderName = PlayBoard.getLeaderName(color)
        if leaderName then
            local playerPane = {}
            playerPanes[color] = playerPane
        end
    end

    createController(playerPanes)

    local image = ArrakeenScouts[I18N.getLocale()][content]
    assert(image, "Unknow Arrakeen Scouts content: " .. content)

    ArrakeenScouts.ui = ArrakeenScouts._createDialogUI(image, playerPanes)

    ArrakeenScouts._refreshContent()
end

---
function ArrakeenScouts._createDialogUI(image, playerPanes)
    local playerUIs = {}
    for _, color in ipairs({ "Red", "Green", "Blue", "Yellow" }) do
        table.insert(playerUIs, ArrakeenScouts._createPlayerUI(color, playerPanes[color]))
    end

    local dialogUI = {
        tag = "Panel",
        attributes = {
            position = 0,
            width = 780,
            height = 297 + 200,
            color = "#000000",
            id = "arrakeenScoutPane",
            outline = "#ffffffcc",
            outlineSize = 1,
            active = true,
            allowDragging = true,
            returnToOriginalPositionWhenReleased = true,
        },
        children = {
            {
                tag = "Image",
                attributes = {
                    ignoreLayout = true,
                    raycastTarget = true,
                    color = "#000000",
                },
            },
            {
                tag = "VerticalLayout",
                children = {
                    {
                        tag = "Image",
                        attributes = {
                            width = "780",
                            height = "297",
                            image = image,
                            preserveAspect = true,
                            raycastTarget = true,
                        },
                    },
                    {
                        tag = "GridLayout",
                        attributes = {
                            cellSize = "389 94",
                            childAlignment = "MiddleCenter",
                            spacing = "1 1",
                        },
                        children = playerUIs
                    }
                }
            }
        }
    }

    return dialogUI
end

---
function ArrakeenScouts._createPlayerUI(color, playerPane)
    local playerUI

    if playerPane then
        playerUI = {
            tag = "VerticalLayout",
            attributes = {
                childAlignment = "UpperCenter",
                childForceExpandHeight = false,
                childForceExpandWidth = false,
                minWitdh = 390,
                minHeight = 100,
            },
            children = {
                {
                    tag = "Image",
                    attributes = {
                        ignoreLayout = true,
                        raycastTarget = true,
                        color = "#222222",
                    }
                },
                {
                    tag = "VerticalLayout",
                    attributes = {
                        childAlignment = "MiddleCenter",
                        childForceExpandWidth = false,
                        childForceExpandHeight = false,
                        spacing = 10,
                        padding = 10,
                    },
                    children = {
                        {
                            tag = "Text",
                            attributes = {
                                fontSize = "16",
                                flexibleHeight = 0,
                                color = color,
                            },
                            value = PlayBoard.getLeaderName(color)
                        },
                        playerPane
                    }
                }
            }
        }
    else
        playerUI = {
            tag = "Image",
            attributes = {
                ignoreLayout = false,
                raycastTarget = true,
                color = "#222222",
            }
        }
    end

    return playerUI
end

---
function ArrakeenScouts._setAsOptionPane(color, playerPane, secret, options, controller)
    Types.assertIsPlayerColor(color)
    assert(playerPane)
    assert(secret ~= nil)
    assert(options)
    assert(controller)

    if #options == 0 then
        log("Providing a default option.")
        options = {{ value = I18N("passOption") }}
    end

    local optionValues = Helper.mapValues(options, function (option) return option.value end)
    if secret then
        Helper.shuffle(optionValues)
    end

    local function findOption(value)
        for _, option in ipairs(options) do
            if option.value == value then
                return option
            end
        end
        return nil
    end

    local holder = {
        selectedOption = findOption(optionValues[1])
    }

    local dropdown = {
        tag = "Dropdown",
        attributes = {
            id = color .. "Options",
            flexibleWidth = 100,
            onValueChanged = Helper.registerGlobalCallback(function (_, value, _)
                holder.selectedOption = findOption(value)
            end),
        },
        children = Helper.map(optionValues, function (i, value)
            return {
                tag = "Option",
                attributes = {
                    selected = i == 1,
                },
                value = value
            }
        end),
    }

    local button = {
        tag = "Button",
        attributes = {
            fontSize = "20",
            fontStyle = "Bold",
            outlineSize = "1 1",
            preferredWidth = 40,
            preferredHeight = 40,
            flexibleWidth = 0,
        },
        value = "OK",
    }

    button.attributes.onClick = Helper.registerGlobalCallback(function (player)
        if Helper.getPlayerColor(player) == color then
            Helper.unregisterGlobalCallback(dropdown.attributes.onValueChanged)
            Helper.unregisterGlobalCallback(button.attributes.onClick)
            controller.validate(color, holder.selectedOption)
        else
            --Helper.dump("color =", color)
            --Helper.dump("Helper.getPlayerColor(player) = ", Helper.getPlayerColor(player))
            broadcastToColor(I18N('noTouch'), color, "Purple")
        end
    end)

    Helper.mutateTable(playerPane, {
        tag = "HorizontalLayout",
        attributes = {
            padding = "20 20 0 0",
            spacing = 20,
        },
        children = {
            dropdown,
            button,
        }
    })

    ArrakeenScouts._setSecret(color, playerPane, secret)
end

---
function ArrakeenScouts._setAsValidationPane(color, playerPane, secret, label, controller)

    local button = {
        tag = "Button",
        attributes = {
            fontSize = "20",
            fontStyle = "Bold",
            outlineSize = "1 1",
            preferredWidth = 40,
            preferredHeight = 40,
            flexibleWidth = 0,
        },
        value = "OK",
    }

    button.attributes.onClick = Helper.registerGlobalCallback(function (player)
        if Helper.getPlayerColor(player) == color or ArrakeenScouts._debug then
            Helper.unregisterGlobalCallback(button.attributes.onClick)
            controller.validate(color)
        end
    end)

    local children
    if label then
        children = {
            {
                tag = "Text",
                attributes = {
                    flexibleWidth = 100,
                    color = "#FFFFFF",
                },
                value = label
            },
            button
        }
    else
        children = {
            {
                tag = "Text",
                attributes = {
                    flexibleWidth = 50,
                },
                value = "-"
            },
            button,
            {
                tag = "Text",
                attributes = {
                    flexibleWidth = 50,
                },
                value = "-"
            },
        }
    end

    Helper.mutateTable(playerPane, {
        tag = "HorizontalLayout",
        attributes = {
            padding = "20 20 0 0",
            spacing = 20,
        },
        children = children
    })

    ArrakeenScouts._setSecret(color, playerPane, secret)
end

---
function ArrakeenScouts._setAsPassivePane(color, playerPane, secret, label, textIcon)

    local icon = {
        tag = "Text",
        attributes = {
            fontSize = "40",
            color = "#FFFFFF",
            preferredWidth = 40,
            preferredHeight = 40,
        },
        children = {},
        value = textIcon, -- "…", "✗", "✓"
    }

    local children
    if label then
        children = {
            {
                tag = "Text",
                attributes = {
                    flexibleWidth = 100,
                    color = "#FFFFFF",
                },
                value = label
            },
            icon
        }
    else
        children = {
            {
                tag = "Text",
                attributes = {
                    flexibleWidth = 50,
                },
                value = "-"
            },
            icon,
            {
                tag = "Text",
                attributes = {
                    flexibleWidth = 50,
                },
                value = "-"
            },
        }
    end

    Helper.mutateTable(playerPane, {
        tag = "HorizontalLayout",
        attributes = {
            padding = "20 20 0 0",
            spacing = 20,
        },
        children = children
    })

    ArrakeenScouts._setSecret(color, playerPane, secret)
end

---
function ArrakeenScouts._setSecret(color, playerPane, secret)
    playerPane.attributes.visibility = secret and color or ""
end

---
function ArrakeenScouts._refreshContent()
    UI.setXmlTable({ ArrakeenScouts.ui })
end

---
function ArrakeenScouts._endContent()
    Helper.onceTimeElapsed(2).doAfter(function ()
        UI.setXmlTable({{}})
        ArrakeenScouts._nextContent()
    end)
end

---
function ArrakeenScouts._rankPlayers(bids)
    local remainingBids = Helper.shallowCopy(bids)
    local ranking = {}

    while true do
        local bestValue = 1
        local colors = {}
        for color, value in pairs(remainingBids) do
            if value > bestValue then
                colors = { color }
                bestValue = value
            elseif value == bestValue then
                table.insert(colors, color)
            end
        end
        if #colors > 0 then
            for _, color in ipairs(colors) do
                remainingBids[color] = nil
            end
            table.insert(ranking, colors)
        else
            break
        end
    end

    return ranking
end

---
function ArrakeenScouts._getRank(color, ranking, maxLevel)
    local level = 1
    local count = 0
    while count < maxLevel and ranking[level] do
        local levelRanking = ranking[level]
        count = count + #levelRanking
        local exAequo = #levelRanking > 1
        if Helper.isElementOf(color, levelRanking) then
            return { level = level, exAequo = exAequo }
        end
        level = level + 1
    end
    return nil
end

--- Commitees ---

function ArrakeenScouts.joinCommitee(color, luaIndex)
    if ArrakeenScouts.committeeAccess[color] then
        local committeeTile = ArrakeenScouts.committeeTiles[luaIndex]
        local committee = ArrakeenScouts.selectedCommittees[luaIndex]
        assert(committee)

        local token = PlayBoard.getCouncilToken(color)
        assert(token, "No " .. color .. " token")
        local newToken = token.clone({ position = committeeTile.getPosition() + Vector(-2.2, 0, 0 )})
        newToken.setScale(Vector(0.1, 1, 0.1 ))
        Helper.noPlay(newToken)
        Helper.clearButtons(ArrakeenScouts.committeeAnchors[luaIndex])
        ArrakeenScouts.committeeAccess[color] = false

        local effector = ArrakeenScouts[Helper.toCamelCase("_join", committee)]
        assert(effector, "No effector for commitee: " .. committee)
        if effector then
            local leader = PlayBoard.getLeader(color)
            effector(color, leader)
        end
    else
        broadcastToColor(I18N('noTouch'), color, "Purple")
    end
end

function ArrakeenScouts._joinAppropriations(color, leader)
    leader.resources(color, "spice", 1)
end

function ArrakeenScouts._joinDevelopment(color, leader)
    -- leader.resources(color, "spice", 3)
    -- leader.drawImperiumCards(color, 3)
end

function ArrakeenScouts._joinInformation(color, leader)
    leader.drawImperiumCards(color, 1)
end

function ArrakeenScouts._joinInvestigation(color, leader)
    -- leader.resources(color, "solari", -1)
    -- leader.drawIntrigues(color, 1)
end

function ArrakeenScouts._joinJoinForces(color, leader)
    -- leader.resources(color, "solari", -2)
    -- leader.troops(color, "supply", "garrison", 3)
end

function ArrakeenScouts._joinPoliticalAffairs(color, leader)
    -- leader.resources(color, "spice", -4)
    -- 2 influences
end

function ArrakeenScouts._joinPreparation(color, leader)
    leader.troops(color, "supply", "garrison", 1)
end

function ArrakeenScouts._joinRelations(color, leader)
    -- leader.resources(color, "spice", -2)
    -- 1 influence
end

function ArrakeenScouts._joinSupervision(color, leader)
    -- leader.resources(color, "solari", -1)
    -- ArrakeenScouts._ensureTrashFromHand(color)
end

function ArrakeenScouts._joinImmortality(color, leader)
end

function ArrakeenScouts._joinDataAnalysis(color, leader)
    -- leader.resources(color, "solari", -1)
    -- ArrakeenScouts._ensureResearch(color)
end

function ArrakeenScouts._joinDevelopmentProject(color, leader)
    leader.troops(color, "supply", "tanks", 1)
end

function ArrakeenScouts._joinTleilaxuRelations(color, leader)
    -- leader.resources(color, "spice", 3)
    -- leader.beetle(color, 2)
end

--- Auctions ---

function ArrakeenScouts._createMentat1Controller(playerPanes)
    return ArrakeenScouts._createMentatController(playerPanes, "solari", 1)
end

function ArrakeenScouts._createMentat2Controller(playerPanes)
    return ArrakeenScouts._createMentatController(playerPanes, "spice", 2)
end

function ArrakeenScouts._createMentatController(playerPanes, resourceName, level)
    ArrakeenScouts._createBetterSequentialAuctionController(playerPanes, resourceName, nil, false, level, function (color, bids, rank, continuation)
        local leader = PlayBoard.getLeader(color)
        local amount = bids[color]
        leader.resources(color, resourceName, -amount)
        if rank.level == 1 then
            if not leader.takeMentat(color) then
                -- TODO Take 1 influence instead.
            end
            if level == 2 then
                leader.drawImperiumCards(color, 1)
            end
        elseif rank.level == level then
            leader.drawImperiumCards(color, 1)
        end
        continuation.run()
    end)
end

function ArrakeenScouts._createMercenaries1Controller(playerPanes)
    return ArrakeenScouts._createMercenariesController(playerPanes)
end

function ArrakeenScouts._createMercenaries2Controller(playerPanes)
    return ArrakeenScouts._createMercenariesController(playerPanes)
end

function ArrakeenScouts._createMercenariesController(playerPanes)
    ArrakeenScouts._createSequentialAuctionController(playerPanes, "spice", 3, true, function (bids)

        local getLabel = function (color)
            local label = tostring(bids[color]) .. " spice"
            return label
        end

        ArrakeenScouts._createRandomValidationController(playerPanes, false, getLabel, function (color, continuation)
            local leader = PlayBoard.getLeader(color)
            local amount = bids[color]
            leader.resources(color, "spice", -amount)
            leader.troops(color, "supply", "combat", amount)
            continuation.run()
        end)
    end)
end

function ArrakeenScouts._createTreachery1Controller(playerPanes)
    ArrakeenScouts._createTreacheryBisController(playerPanes, 1)
end

function ArrakeenScouts._createTreachery2Controller(playerPanes)
    ArrakeenScouts._createTreacheryBisController(playerPanes, 2)
end

function ArrakeenScouts._createTreacheryBisController(playerPanes, level)
    ArrakeenScouts._createBetterSequentialAuctionController(playerPanes, "spice", nil, true, level, function (color, bids, rank, continuation)
        local leader = PlayBoard.getLeader(color)
        local amount = bids[color]
        leader.resources(color, "spice", -amount)
        if rank.level == 1 then
            leader.drawIntrigues(color, level)
        elseif rank.level == level then
            leader.drawIntrigues(color, 1)
        end
        continuation.run()
    end)
end

function ArrakeenScouts._createToTheHighestBidder1Controller(playerPanes)
    ArrakeenScouts._createToTheHighestBidderController(playerPanes, 1)
end

function ArrakeenScouts._createToTheHighestBidder2Controller(playerPanes)
    ArrakeenScouts._createToTheHighestBidderController(playerPanes, 2)
end

function ArrakeenScouts._createToTheHighestBidderController(playerPanes, level)
    ArrakeenScouts._createBetterSequentialAuctionController(playerPanes, "solari", nil, true, level, function (color, bids, rank, continuation)
        local leader = PlayBoard.getLeader(color)
        local amount = bids[color]
        leader.resources(color, "solari", -amount)
        if rank.level == 1 then
            leader.drawImperiumCards(color, level)
        elseif rank.level == level then
            leader.drawImperiumCards(color, 1)
        end
        continuation.run()
    end)
end

function ArrakeenScouts._createCompetitiveStudy1Controller(playerPanes)
    return ArrakeenScouts._createCompetitiveStudyController(playerPanes, 1)
end

function ArrakeenScouts._createCompetitiveStudy2Controller(playerPanes)
    return ArrakeenScouts._createCompetitiveStudyController(playerPanes, 2)
end

function ArrakeenScouts._createCompetitiveStudyController(playerPanes, level)
    ArrakeenScouts._createBetterSequentialAuctionController(playerPanes, "solari", nil, true, level, function (color, bids, rank, continuation)
        local leader = PlayBoard.getLeader(color)
        local amount = bids[color]
        leader.resources(color, "solari", -amount)
        if rank.level == 1 then
            leader.troops(color, "supply", "tanks", 1)
        end
        ArrakeenScouts._ensureResearch(color).doAfter(continuation.run)
    end)
end

function ArrakeenScouts._createBetterSequentialAuctionController(playerPanes, resourceName, maxValue, secret, level, resolve)
    ArrakeenScouts._createSequentialAuctionController(playerPanes, resourceName, maxValue, secret, function (bids)
        local ranking = ArrakeenScouts._rankPlayers(bids)

        local rankName = { "first", "second", "third", "fourth" }

        local getLabel = function (color)
            local label = I18N("amount", { amount = bids[color], resource = I18N.agree(bids[color], resourceName) }) .. " ➤ "
            local rank = ArrakeenScouts._getRank(color, ranking, level)
            if rank and rank.level <= level then
                label = label .. I18N(rankName[rank.level] .. (rank.exAequo and "ExAequo" or ""))
            else
                label = label .. I18N("lose")
            end
            return label
        end

        ArrakeenScouts._createRandomValidationController(playerPanes, false, getLabel, function (color, continuation)
            local rank = ArrakeenScouts._getRank(color, ranking, level)
            if rank and rank.level <= level then
                resolve(color, bids, rank, continuation)
            else
                continuation.run()
            end
        end)
    end)
end

function ArrakeenScouts._createSequentialAuctionController(playerPanes, resourceName, maxValue, secret, resolveAll)
    assert(playerPanes)
    Types.assertIsResourceName(resourceName)
    assert(secret ~= nil)
    assert(resolveAll)

    local controller = {
        turnSequence = TurnControl.getPhaseTurnSequence(),
        values = {},
        bids = {},
    }

    function controller.setAsOptionPane(color, playerPane)
        local options = { { amount = 0, value = I18N("passOption") } }
        local resource = PlayBoard.getResource(color, resourceName)
        local finalMaxValue = resource:get()
        finalMaxValue = maxValue and math.min(maxValue, finalMaxValue) or finalMaxValue
        local minValue = 1
        if not secret then
            local maxBid = 0
            for _, bid in pairs(controller.bids) do
                maxBid = math.max(maxBid, bid)
            end
            minValue = maxBid + 1
        end
        for i = minValue, finalMaxValue do
            local value = I18N("amount", { amount = i, resource = I18N.agree(i, resourceName) })
            table.insert(options, { amount = i, value = value })
        end
        ArrakeenScouts._setAsOptionPane(color, playerPane, secret, options, controller)
    end

    function controller.validate(color, option)
        TurnControl.endOfTurn(color)

        if controller.bids[color] then
            log("Doing nothing: already validated")
            return
        end

        controller.bids[color] = option.amount
        controller.values[color] = option.value
        if secret then
            ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, "✓")
        else
            ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, option.value, "✓")
        end
        table.remove(controller.turnSequence, 1)
        if #controller.turnSequence > 0 then
            local nextColor = controller.turnSequence[1]
            controller.setAsOptionPane(nextColor, playerPanes[nextColor])
        else
            if secret then
                for otherColor, playerPane in pairs(playerPanes) do
                    ArrakeenScouts._setAsPassivePane(color, playerPane, false, controller.values[otherColor], "✓")
                end
            end
            -- FIXME turn sequence.
            resolveAll(controller.bids)
            --ArrakeenScouts._endContent()
        end
        ArrakeenScouts._refreshContent()
    end

    local currentColor = controller.turnSequence[1]
    for color, playerPane in pairs(playerPanes) do
        if color == currentColor then
            controller.setAsOptionPane(color, playerPane)
        else
            ArrakeenScouts._setAsPassivePane(color, playerPane, false, I18N("waitOption"), "…")
        end
    end
end

--- Events ---

function ArrakeenScouts._createChangeOfPlansController(playerPanes)
    local getOptions = function (_)
        return {
            { status = false, value = I18N("refuseOption") },
            { status = true, value = I18N("acceptOption") }
        }
    end
    local resolve = function (color, option, continuation)
        if option.status then
            ArrakeenScouts._ensureDiscard(color).doAfter(function (card)
                assert(card)
                local cardName = Helper.getID(card)
                ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, cardName, "✓")
                local leader = PlayBoard.getLeader(color)
                leader.drawImperiumCards(color, 1)
                continuation.run()
            end)
        else
            ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, "✗")
            continuation.run()
        end
    end
    ArrakeenScouts._createSequentialChoiceController(playerPanes, getOptions, false, resolve)
end

function ArrakeenScouts._createCovertOperationController(playerPanes)
    local getOptions = function (_)
        return {
            --TODO I18N
            { index = 1, roundCount = 1, reward = "+2 solari", value = "+2 solari dans 1 manche" },
            { index = 2, roundCount = 1, reward = "+1 Empereur", value = "+1 Empereur dans 1 manche" },
            { index = 3, roundCount = 1, reward = "+1 Guilde Spatiale", value = "+1 Guilde Spatiale dans 1 manche" },
            { index = 4, roundCount = 1, reward = "+1 Bene Gesserit", value = "+1 Bene Gesserit dans 1 manche" },
            { index = 5, roundCount = 1, reward = "+1 Fremens", value = "+1 Fremens dans 1 manche" },
            { index = 6, roundCount = 2, reward = "+2 épice", value = "+2 épice dans 2 manches" },
            { index = 7, roundCount = 2, reward = "+2 Empereur", value = "+2 Empereur dans 2 manches" },
            { index = 8, roundCount = 2, reward = "+2 Guilde Spatiale", value = "+2 Guilde Spatiale dans 2 manches" },
            { index = 9, roundCount = 2, reward = "+2 Bene Gesserit", value = "+2 Bene Gesserit dans 2 manches" },
            { index = 10, roundCount = 2, reward = "+2 Fremens", value = "+2 Fremens dans 2 manches" },
        }
    end
    local resolve = function (color, option, continuation)
        ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, "✓")
        table.insert(ArrakeenScouts.pendingOperations, {
            operation = "covertOperation",
            color = color,
            reward = option.reward,
            round = TurnControl.getCurrentRound() + option.roundCount,
            resolver = function ()
                local leader = PlayBoard.getLeader(color)
                if option.index == 1 then
                    leader.resources(color, "solari", 2)
                elseif option.index == 2 then
                    leader.influence(color, "emperor", 1)
                elseif option.index == 3 then
                    leader.influence(color, "spacingGuild", 1)
                elseif option.index == 4 then
                    leader.influence(color, "beneGesserit", 1)
                elseif option.index == 5 then
                    leader.influence(color, "fremen", 1)
                elseif option.index == 6 then
                    leader.resources(color, "spice", 2)
                elseif option.index == 7 then
                    leader.influence(color, "emperor", 2)
                elseif option.index == 8 then
                    leader.influence(color, "spacingGuild", 2)
                elseif option.index == 9 then
                    leader.influence(color, "beneGesserit", 2)
                elseif option.index == 10 then
                    leader.influence(color, "fremen", 2)
                else
                    assert("Unknow index: " .. tostring(option.index))
                end
            end
        })
        continuation.run()
    end
    ArrakeenScouts._createSequentialChoiceController(playerPanes, getOptions, true, resolve)
end

function ArrakeenScouts._createCovertOperationRewardController(playerPanes)
    ArrakeenScouts._createPendingController(playerPanes, "covertOperation")
end

function ArrakeenScouts._createGiftOfWaterController(playerPanes)
    local getOptions = function (color)
        local options = { { status = false, value = I18N("refuseOption") } }
        local water = PlayBoard.getResource(color, "water")
        if water:get() >= 1 then
            table.insert(options, { status = true, value = I18N("acceptOption") })
        end
        return options
    end
    local resolve = function (color, option, continuation)
        ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, option.status and "✓" or "✗")
        if option.status then
            local leader = PlayBoard.getLeader(color)
            leader.resources(color, "water", -1)
            leader.acquireArrakisLiaison(color)
        end
        continuation.run()
    end
    ArrakeenScouts._createSequentialChoiceController(playerPanes, getOptions, true, resolve)
end

function ArrakeenScouts._createDesertGiftController(playerPanes)
    local notAStarterCard = Helper.negate(ImperiumCard.isStarterCard)
    local getOptions = function (color)
        local options = { { status = false, value = I18N("passOption") } }
        local notStarterCards = Helper.filter(PlayBoard.getHandedCards(color), notAStarterCard)
        if #notStarterCards > 0 then
            table.insert(options, { status = true, value = I18N("discardOption") })
        end
        return options
    end
    local resolve = function (color, option, continuation)
        if option.status then
            ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, I18N("discardNonStarterCard"), "…")
            ArrakeenScouts._ensureDiscard(color, notAStarterCard).doAfter(function (card)
                assert(card)
                local cardName = Helper.getID(card)
                ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, cardName, "✓")
                local leader = PlayBoard.getLeader(color)
                leader.influence(color, "fremen", 1)
                continuation.run()
            end)
        else
            ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, "✗")
            continuation.run()
        end
    end
    ArrakeenScouts._createSequentialChoiceController(playerPanes, getOptions, true, resolve)
end

function ArrakeenScouts._createGuildNegotiationController(playerPanes)
    local getOptions = function (color)
        local options = { { status = false, value = I18N("passOption") } }
        local solari = PlayBoard.getResource(color, "solari")
        if solari:get() >= 2 then
            table.insert(options, { status = true, value = I18N("acceptOption") })
        end
        return options
    end
    local resolve = function (color, option, continuation)
        ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, option.status and "✓" or "✗")
        if option.status then
            local leader = PlayBoard.getLeader(color)
            leader.resources(color, "solari", -2)
            leader.influence(color, "spacingGuild", 1)
        end
        continuation.run()
    end
    ArrakeenScouts._createSequentialChoiceController(playerPanes, getOptions, true, resolve)
end

function ArrakeenScouts._createIntriguingGiftController(playerPanes)
    local getOptions = function (color)
        local options = { { status = false, value = I18N("passOption") } }
        local intrigues = PlayBoard.getIntrigues(color)
        if #intrigues > 0 then
            table.insert(options, { status = true, value = I18N("acceptOption") })
        end
        return options
    end
    local resolve = function (color, option, continuation)
        if option.status then
            ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, I18N("discardAnIntrigue"), "…")
            ArrakeenScouts._ensureDiscardIntrigue(color).doAfter(function (card)
                assert(card)
                local cardName = Helper.getID(card)
                ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, cardName, "✓")
                local leader = PlayBoard.getLeader(color)
                leader.influence(color, "beneGesserit", 1)
                continuation.run()
            end)
        else
            ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, "✗")
            continuation.run()
        end
    end
    ArrakeenScouts._createSequentialChoiceController(playerPanes, getOptions, true, resolve)
end

function ArrakeenScouts._createTestOfLoyaltyController(playerPanes)
    local getOptions = function (color)
        local options = { { status = false, value = I18N("passOption") } }
        local garrisonPark = Combat.getGarrisonPark(color)
        if not Park.isEmpty(garrisonPark) then
            table.insert(options, { status = true, value = I18N("acceptOption") })
        end
        return options
    end
    local resolve = function (color, option, continuation)
        ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, option.status and "✓" or "✗")
        if option.status then
            local leader = PlayBoard.getLeader(color)
            leader.troops(color, "garrison", "supply", 1)
            leader.influence(color, "emperor", 1)
        end
        continuation.run()
    end
    ArrakeenScouts._createSequentialChoiceController(playerPanes, getOptions, true, resolve)
end

function ArrakeenScouts._createBeneGesseritTreacheryController(playerPanes)
    local getOptions = function (color)
        local options = { { status = true, value = I18N("discardOption") } }
        if InfluenceTrack.getInfluence("beneGesserit", color) > 0 then
            table.insert(options, { status = false, value = "-1 Bene Gesserit" })
        end
        return options
    end
    local resolve = function (color, option, continuation)
        if option.status then
            ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, I18N("discardACard"), "…")
            ArrakeenScouts._ensureDiscard(color).doAfter(function (card)
                assert(card)
                local cardName = Helper.getID(card)
                ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, cardName, "✓")
                continuation.run()
            end)
        else
            ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, "✗")
            local leader = PlayBoard.getLeader(color)
            leader.influence(color, "beneGesserit", -1)
            continuation.run()
        end
    end
    ArrakeenScouts._createSequentialChoiceController(playerPanes, getOptions, true, resolve)
end

function ArrakeenScouts._createEmperorsTaxController(playerPanes)
    local getOptions = function (color)
        local options = {}
        local spice = PlayBoard.getResource(color, "spice")
        -- TODO I18N
        if InfluenceTrack.getInfluence("emperor", color) > 0 then
            table.insert(options, { status = false, value = "-1 Empereur" })
            if spice:get() >= 1 then
                table.insert(options, { status = true, value = "-1 épice" })
            end
        else
            table.insert(options, { status = false, value = "Nothing to lose!" })
        end
        return options
    end
    local resolve = function (color, option, continuation)
        ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, option.status and "✓" or "✗")
        local leader = PlayBoard.getLeader(color)
        if option.status then
            leader.resources(color, "spice", -1)
        else
            leader.influence(color, "emperor", -1)
        end
        continuation.run()
    end
    ArrakeenScouts._createSequentialChoiceController(playerPanes, getOptions, true, resolve)
end

function ArrakeenScouts._createFremenExchangeController(playerPanes)
    local getOptions = function (color)
        local options = {}
        local garrisonPark = Combat.getGarrisonPark(color)
        -- TODO I18N
        if InfluenceTrack.getInfluence("fremen", color) > 0 then
            table.insert(options, { status = false, value = "-1 Fremens" })
            if not Park.isEmpty(garrisonPark) then
                table.insert(options, { status = true, value = "-1 troop" })
            end
        else
            table.insert(options, { status = false, value = "Nothing to lose!" })
        end
        return options
    end
    local resolve = function (color, option, continuation)
        ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, option.status and "✓" or "✗")
        local leader = PlayBoard.getLeader(color)
        if option.status then
            leader.troops(color, "garrison", "supply", 1)
        else
            leader.influence(color, "fremen", -1)
        end
        continuation.run()
    end
    ArrakeenScouts._createSequentialChoiceController(playerPanes, getOptions, true, resolve)
end

function ArrakeenScouts._createPoliticalEquilibriumController(playerPanes)
    local getOptions = function (color)
        local highestInfluence
        local highestFactions
        for _, faction in ipairs({ "emperor", "spacingGuild", "beneGesserit", "fremen" }) do
            local influence = InfluenceTrack.getInfluence(faction, color)
            if not highestFactions or influence > highestInfluence then
                highestInfluence = influence
                highestFactions = { faction }
            elseif highestInfluence == influence then
                table.insert(highestFactions, faction)
            end
        end
        local options = {}
        if #highestFactions > 1 then
            if highestInfluence > 0 then
                for _, highestFaction in ipairs(highestFactions) do
                    table.insert(options, { faction = highestFaction, value = "-1 " .. highestFaction })
                end
            else
                table.insert(options, { value = I18N("passOption") })
            end
        else
            table.insert(options, { faction = highestFactions[1], value = "-1 " .. highestFactions[1] })
        end
        return options
    end
    local resolve = function (color, option, continuation)
        ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, option.faction and "✓" or "✓")
        if option.faction then
            local leader = PlayBoard.getLeader(color)
            leader.influence(color, option.faction, -1)
        end
        continuation.run()
    end
    ArrakeenScouts._createSequentialChoiceController(playerPanes, getOptions, true, resolve)
end

function ArrakeenScouts._createWaterForSpiceSmugglersController(playerPanes)
    local getOptions = function (color)
        local options = {}
        local water = PlayBoard.getResource(color, "water")
        -- TODO I18N
        if water:get() >= 1 then
            table.insert(options, { status = true, value = "-1 water" })
        end
        -- TODO To be confirmed.
        if true or InfluenceTrack.getInfluence("spacingGuild", color) > 0 then
            table.insert(options, { status = false, value = "-1 Spacing Guild" })
        end
        return options
    end
    local resolve = function (color, option, continuation)
        ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, option.status and "✓" or "✗")
        local leader = PlayBoard.getLeader(color)
        if option.status then
            leader.resources(color, "water", -1)
        else
            leader.influence(color, "spacingGuild", -1)
        end
        continuation.run()
    end
    ArrakeenScouts._createSequentialChoiceController(playerPanes, getOptions, true, resolve)
end

function ArrakeenScouts._createRotationgDoorsController(playerPanes)
    local getOptions = function (color)
        local options = { { status = false, value = I18N("refuseOption") } }
        local intrigues = PlayBoard.getIntrigues(color)
        if #intrigues > 0 then
            table.insert(options, { status = true, value = I18N("acceptOption") })
        end
        return options
    end
    local resolve = function (color, option, continuation)
        if option.status then
            ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, I18N("discardAnIntrigue"), "…")
            ArrakeenScouts._ensureDiscardIntrigue(color).doAfter(function (card)
                assert(card)
                local cardName = Helper.getID(card)
                ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, cardName, "✓")
                local leader = PlayBoard.getLeader(color)
                leader.drawIntrigues(color, 1)
                continuation.run()
            end)
        else
            ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, "✗")
            continuation.run()
        end
    end
    ArrakeenScouts._createSequentialChoiceController(playerPanes, getOptions, true, resolve)
end

function ArrakeenScouts._createSecretsForSaleController(playerPanes)
    local getOptions = function (color)
        local options = { { value = I18N("refuseOption") } }
        local solari = PlayBoard.getResource(color, "solari")
        -- TODO I18N
        if solari:get() >= 1 then
            table.insert(options, { resource = "solari", value = "-1 solari" })
        end
        local spice = PlayBoard.getResource(color, "spice")
        if spice:get() >= 1 then
            table.insert(options, { resource = "spice", value = "-1 épice" })
        end
        return options
    end
    local resolve = function (color, option, continuation)
        ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, option.resource and "✓" or "✗")
        if option.resource then
            local leader = PlayBoard.getLeader(color)
            leader.resources(color, option.resource, -1)
            leader.drawIntrigues(color, 1)
        end
        continuation.run()
    end
    ArrakeenScouts._createSequentialChoiceController(playerPanes, getOptions, true, resolve)
end

function ArrakeenScouts._createNoComingBackController(playerPanes)
    local getOptions = function (_)
        local factions = { "emperor", "spacingGuild", "beneGesserit", "fremen" }
        -- TODO I18N
        return {
            { value = I18N("refuseOption") },
            { faction = factions[1], value = "Accepter (" .. factions[1] .. ")" },
            { faction = factions[2], value = "Accepter (" .. factions[2] .. ")" },
            { faction = factions[3], value = "Accepter (" .. factions[3] .. ")" },
            { faction = factions[4], value = "Accepter (" .. factions[4] .. ")" },
        }
    end
    local resolve = function (color, option, continuation)
        if option.faction then
            ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, I18N("trashACard"), "…")
            ArrakeenScouts._ensureTrashFromHand(color).doAfter(function (card)
                assert(card)
                local cardName = Helper.getID(card)
                ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, cardName, "✓")
                local leader = PlayBoard.getLeader(color)
                if cardName == "seekAllies" then
                    leader.influence(color, option.faction, 1)
                elseif cardName == "diplomacy" then
                    leader.influence(color, option.faction, 2)
                end
                leader.troops(color, "supply", "tanks", 1)
                continuation.run()
            end)
        else
            ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, "✗")
            continuation.run()
        end
    end
    ArrakeenScouts._createSequentialChoiceController(playerPanes, getOptions, true, resolve)
end

function ArrakeenScouts._createTapIntoSpiceReservesController(playerPanes)
    local resolve = function (color, continuation)
        ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, "✓")
        local leader = PlayBoard.getLeader(color)
        leader.resources(color, "spice", 1)
        continuation.run()
    end
    ArrakeenScouts._createRandomValidationController(playerPanes, true, nil, resolve)
end

function ArrakeenScouts._createGetBackInTheGoodGracesController(playerPanes)
    local getOptions = function (color)
        local options = { { value = I18N("passOption") } }
        local tankPark = TleilaxuResearch.getTankPark(color)
        if not Park.isEmpty(tankPark) then
            for _, faction in ipairs({ "emperor", "spacingGuild", "beneGesserit", "fremen" }) do
                table.insert(options, { faction = faction, value = "+1 " .. faction })
            end
        end
        return options
    end
    local resolve = function (color, option, continuation)
        ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, option.faction and "✓" or "✗")
        if option.faction then
            local leader = PlayBoard.getLeader(color)
            leader.troops(color, "tanks", "supply", 1)
            leader.influence(color, option.faction, 1)
        end
        continuation.run()
    end
    ArrakeenScouts._createSequentialChoiceController(playerPanes, getOptions, true, resolve)
end

function ArrakeenScouts._createTreacheryController(playerPanes)
    local getOptions = function (color)
        local options = { { status = false, value = I18N("passOption") } }
        if InfluenceTrack.getInfluence("beneGesserit", color) > 0 then
            table.insert(options, { status = true, value = "-1 Bene Gesserit" })
        end
        return options
    end
    local resolve = function (color, option, continuation)
        ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, option.status and "✓" or "✗")
        if option.status then
            local leader = PlayBoard.getLeader(color)
            leader.influence(color, "beneGesserit", -1)
            leader.beetle(color, 1)
        end
        continuation.run()
    end
    ArrakeenScouts._createSequentialChoiceController(playerPanes, getOptions, true, resolve)
end

function ArrakeenScouts._createNewInnovationsController(playerPanes)
    local getOptions = function (color)
        local options = { { value = I18N("refuseOption") } }
        local solari = PlayBoard.getResource(color, "solari")
        if solari:get() >= 1 then
            table.insert(options, { resource = "solari", value = "-1 solari" })
        end
        local spice = PlayBoard.getResource(color, "spice")
        if spice:get() >= 1 then
            table.insert(options, { resource = "spice", value = "-1 épice" })
        end
        return options
    end
    local resolve = function (color, option, continuation)
        if option.resource then
            ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, I18N("doAResearch"), "…")
            local leader = PlayBoard.getLeader(color)
            leader.resources(color, option.resource, -1)
            return ArrakeenScouts._ensureResearch(color).doAfter(function ()
                ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, "✓")
                continuation.run()
            end)
        else
            ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, "✗")
            continuation.run()
        end
    end
    ArrakeenScouts._createSequentialChoiceController(playerPanes, getOptions, true, resolve)
end

function ArrakeenScouts._createOffWordOperationController(playerPanes)
    local getOptions = function (_)
        -- TODO I18N
        return {
            { index = 1, roundCount = 1, reward = "+2 solari", value = "+2 solari dans 1 manche" },
            { index = 2, roundCount = 1, reward = "+1 (+2) épices", value = "+1 (+2) épices dans 1 manche" },
            { index = 3, roundCount = 2, reward = "+1 scarabé", value = "+1 scarabé dans 2 manches" },
            { index = 4, roundCount = 2, reward = "+1 intrigue", value = "+1 intrigue dans 2 manches" },
        }
    end
    local resolve = function (color, option, continuation)
        ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, "✓")
        table.insert(ArrakeenScouts.pendingOperations, {
            operation = "offWordOperation",
            color = color,
            reward = option.reward,
            round = TurnControl.getCurrentRound() + option.roundCount,
            resolver = function ()
                local leader = PlayBoard.getLeader(color)
                if option.index == 1 then
                    leader.resources(color, "solari", 2)
                elseif option.index == 2 then
                    leader.resources(color, "spice", TleilaxuResearch.hasReachedOneHelix(color) and 2 or 1)
                elseif option.index == 3 then
                    leader.beetle(color, 1)
                elseif option.index == 4 then
                    leader.drawIntrigues(color, 1)
                else
                    assert("Unknow index: " .. tostring(option.index))
                end
            end
        })
        continuation.run()
    end
    ArrakeenScouts._createSequentialChoiceController(playerPanes, getOptions, true, resolve)
end

function ArrakeenScouts._createOffWordOperationRewardController(playerPanes)
    ArrakeenScouts._createPendingController(playerPanes, "offWordOperation")
end

function ArrakeenScouts._createCeaseAndDesistRequestController(playerPanes)
    local getOptions = function (color)
        local options = { { status = false, value = I18N("refuseOption") } }
        local supplyPark = PlayBoard.getSupplyPark(color)
        if not Park.isEmpty(supplyPark) then
            table.insert(options, { status = true, value = I18N("destroyACardFromYourHand") })
        end
        return options
    end
    local resolve = function (color, option, continuation)
        if option.status then
            ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, I18N("trashACard"), "…")
            return ArrakeenScouts._ensureTrashFromHand(color).doAfter(function (card)
                assert(card)
                local cardName = Helper.getID(card)
                ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, cardName, "✓")
                local leader = PlayBoard.getLeader(color)
                leader.troops(color, "supply", "tanks", 1)
                continuation.run()
            end)
        else
            ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, "✗")
            continuation.run()
        end
    end
    ArrakeenScouts._createSequentialChoiceController(playerPanes, getOptions, true, resolve)
end

--- Missions ---

function ArrakeenScouts._createSecretsInTheDesertController(playerPanes, immortality)
    local spaceName = immortality and "researchStationImmortality" or "researchStation"
    MainBoard.addSpaceBonus(spaceName, { all = { intrigue = 2 } })
    ArrakeenScouts._createRandomValidationController(playerPanes, false, nil, nil)
end

function ArrakeenScouts._createStationedSupportController(playerPanes, immortality)
    local troops = {}
    local getOptions = function (color)
        local options = { { amount = 0, value = I18N("refuseOption") } }
        local supplyPark = PlayBoard.getSupplyPark(color)
        troops[color] = Park.getObjects(supplyPark)
        if #troops[color] >= 2 then
            table.insert(options, { status = true, value = I18N("acceptOption") })
        end
        return options
    end
    local resolve = function (color, option, continuation)
        if option.status then
            ArrakeenScouts._ensureDiscard(color).doAfter(function (card)
                assert(card)
                local cardName = Helper.getID(card)
                ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, cardName, "✓")
                local spaceName = immortality and "researchStationImmortality" or "researchStation"
                MainBoard.addSpaceBonus(spaceName, { [color] = { combatTroop = { troops[color][1], troops[color][2] } } })
                continuation.run()
            end)
        else
            ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, "✗")
            continuation.run()
        end
    end
    ArrakeenScouts._createSequentialChoiceController(playerPanes, getOptions, false, resolve)
end

function ArrakeenScouts._createGeneticResearchController(playerPanes)
    local troops = {}
    local predicate = function (color)
        local supplyPark = PlayBoard.getSupplyPark(color)
        troops[color] = Park.getObjects(supplyPark)
        return #troops[color] >= 1
    end
    local resolve = function (color, _)
        MainBoard.addSpaceBonus("secrets", { [color] = { combatTroop = { troops[color][1] }, solari = 2 } })
    end
    ArrakeenScouts._createSequentialBinaryChoiceController(playerPanes, predicate, resolve)
end

function ArrakeenScouts._createGuildManipulationsController(playerPanes)
    local troops = {}
    local predicate = function (color)
        local supplyPark = PlayBoard.getSupplyPark(color)
        troops[color] = Park.getObjects(supplyPark)
        local spice = PlayBoard.getResource(color, "spice")
        return #troops[color] >= 2 and spice:get() >= 1
    end
    local resolve = function (color, leader)
        leader.resources(color, "spice", -1)
        MainBoard.addSpaceBonus("foldspace", { [color] = { combatTroop = { troops[color][1], troops[color][2] } } })
    end
    ArrakeenScouts._createSequentialBinaryChoiceController(playerPanes, predicate, resolve)
end

function ArrakeenScouts._createSpiceIncentiveController(playerPanes)
    MainBoard.addSpaceBonus("rallyTroops", { all = { solari = 2 } })
    ArrakeenScouts._createRandomValidationController(playerPanes, false, nil, nil)
end

function ArrakeenScouts._createStrongarmedAllianceController(playerPanes)
    local troops = {}
    local predicate = function (color)
        local supplyPark = PlayBoard.getSupplyPark(color)
        troops[color] = Park.getObjects(supplyPark)
        return #troops[color] >= 1
    end
    local resolve = function (color, _)
        MainBoard.addSpaceBonus("rallyTroops", { [color] = { combatTroop = { troops[color][1] } } })
    end
    ArrakeenScouts._createSequentialBinaryChoiceController(playerPanes, predicate, resolve)
end

function ArrakeenScouts._createSaphoJuiceController(playerPanes)
    local resolve = function (color, continuation)
        local controlMarkerBag = PlayBoard.getControlMarkerBag(color)
        if #controlMarkerBag.getObjects() > 0 then
            controlMarkerBag.takeObject({
                position = Vector(0, 1, 0),
                rotation = Vector(0, 180, 0),
                smooth = false,
                callback_function = function (controlMarker)
                    MainBoard.addSpaceBonus("mentat", { [color] = { controlMarker = { controlMarker }, spice = 1 } })
                end
            })
        end
        continuation.run()
    end
    ArrakeenScouts._createRandomValidationController(playerPanes, false, nil, resolve)
end

function ArrakeenScouts._createSpaceTravelDealController(playerPanes)
    MainBoard.addSpaceBonus("heighliner", { all = { solari = 3 } })
    ArrakeenScouts._createRandomValidationController(playerPanes, false, nil, nil)
end

function ArrakeenScouts._createArmedEscortController(playerPanes)
    local dreadnoughtParks = {}
    local predicate = function (color)
        dreadnoughtParks[color] = PlayBoard.getDreadnoughtPark(color)
        return not Park.isEmpty(dreadnoughtParks[color])
    end
    local resolve = function (color, _)
        MainBoard.addSpaceBonus("dreadnought", { [color] = { combatDreadnought = { Park.getAnyObject(dreadnoughtParks[color]) }, spice = 1 } })
    end
    ArrakeenScouts._createSequentialBinaryChoiceController(playerPanes, predicate, resolve)
end

function ArrakeenScouts._createSecretStashController(playerPanes)
    MainBoard.addSpaceBonus("smuggling", { all = { spice = 2 } })
    ArrakeenScouts._createRandomValidationController(playerPanes, false, nil, nil)
end

function ArrakeenScouts._createStowawayController(playerPanes)
    local troops = {}
    local predicate = function (color)
        local supplyPark = PlayBoard.getSupplyPark(color)
        troops[color] = Park.getObjects(supplyPark)
        local spice = PlayBoard.getResource(color, "spice")
        return #troops[color] >= 2 and spice:get() >= 1
    end
    local resolve = function (color, leader)
        leader.resources(color, "spice", -1)
        MainBoard.addSpaceBonus("smuggling", { [color] = { combatTroop = { troops[color][1], troops[color][2] } } })
    end
    ArrakeenScouts._createSequentialBinaryChoiceController(playerPanes, predicate, resolve)
end

function ArrakeenScouts._createBackstageAgreementController(playerPanes)
    TleilaxuRow.addAcquireBonus({ all = { solari = 2 } })
    ArrakeenScouts._createRandomValidationController(playerPanes, false, nil, nil)
end

function ArrakeenScouts._createSecretsInTheDesert_immortalityController(playerPanes)
    return ArrakeenScouts._createSecretsInTheDesertController(playerPanes, true)
end

function ArrakeenScouts._createStationedSupport_immortalityController(playerPanes)
    return ArrakeenScouts._createStationedSupportController(playerPanes, true)
end

function ArrakeenScouts._createCoordinationWithTheEmperorController(playerPanes)
    local tankParks = {}
    local predicate = function (color)
        tankParks[color] = TleilaxuResearch.getTankPark(color)
        return not Park.isEmpty(tankParks[color])
    end
    local resolve = function (color, _)
        MainBoard.addSpaceBonus("conspire", { [color] = { garrisonTroop = { Park.getAnyObject(tankParks[color]) }, solari = 2 } })
    end
    ArrakeenScouts._createSequentialBinaryChoiceController(playerPanes, predicate, resolve)
end

function ArrakeenScouts._createSponsoredResearchController(playerPanes)
    TleilaxuResearch.addSpaceBonus("oneHelix", { all = { spice = 2 } })
    ArrakeenScouts._createRandomValidationController(playerPanes, false, nil, nil)
end

function ArrakeenScouts._createTleilaxuOfferingController(playerPanes)
    local troops = {}
    local predicate = function (color)
        local supplyPark = PlayBoard.getSupplyPark(color)
        troops[color] =  Park.getObjects(supplyPark)
        return #troops[color] >= 2
    end
    local resolve = function (color, _)
        -- Not to be deployed, but to be added as specimen.
        TleilaxuResearch.addSpaceBonus(3, { [color] = { tankTroop = { troops[color][1], troops[color][2] } } })
    end
    ArrakeenScouts._createSequentialBinaryChoiceController(playerPanes, predicate, resolve)
end

--- Sales ---

function ArrakeenScouts._createFremenMercenariesController(playerPanes)
    local getOptions = function (color)
        local options = { { amount = 0, value = I18N("refuseOption") } }
        local supplyPark = PlayBoard.getSupplyPark(color)
        local troops = Park.getObjects(supplyPark)
        local water = PlayBoard.getResource(color, "water")
        local maxValue = math.min(math.floor((#troops + 1) / 2), water:get())
        for i = 1, maxValue do
            table.insert(options, { amount = i, value = I18N("spendOption", { amount = i, resource = I18N.agree(i, "water") }) })
        end
        return options
    end
    local resolve = function (color, option, continuation)
        ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, option.amount > 0 and "✓" or "✗")
        local leader = PlayBoard.getLeader(color)
        leader.resources(color, "water", -option.amount)
        leader.troops(color, "supply", "combat", option.amount * 2)
        continuation.run()
    end
    ArrakeenScouts._createSequentialChoiceController(playerPanes, getOptions, true, resolve)
end

function ArrakeenScouts._createRevealTheFutureController(playerPanes)
    local getOptions = function (color)
        local options = { { amount = 0, value = I18N("refuseOption") } }
        local spice = PlayBoard.getResource(color, "spice")
        if spice:get() >= 1 then
            table.insert(options, { amount = 1, value = I18N("spendOption", { amount = 1, resource = I18N.agree(1, "spice") }) })
        end
        if spice:get() >= 3 then
            table.insert(options, { amount = 3, value = I18N("spendOption", { amount = 3, resource = I18N.agree(3, "spice") }) })
        end
        return options
    end
    local resolve = function (color, option, continuation)
        ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, option.amount > 0 and "✓" or "✗")
        local leader = PlayBoard.getLeader(color)
        leader.resources(color, "spice", -option.amount)
        if option.amount == 1 then
            leader.resources(color, "spice", -1)
            leader.drawImperiumCards(color, 1)
        elseif option.amount == 3 then
            leader.resources(color, "spice", -3)
            leader.drawImperiumCards(color, 2)
        end
        continuation.run()
    end
    ArrakeenScouts._createSequentialChoiceController(playerPanes, getOptions, true, resolve)
end

function ArrakeenScouts._createSooSooSookWaterPeddlersController(playerPanes)
    local getOptions = function (color)
        local options = { { amount = 0, value = I18N("refuseOption") } }
        local solari = PlayBoard.getResource(color, "solari")
        if solari:get() >= 2 then
            table.insert(options, { amount = 2, value = I18N("spendOption", { amount = 2, resource = I18N.agree(1, "solari") }) })
        end
        if solari:get() >= 4 then
            table.insert(options, { amount = 4, value = I18N("spendOption", { amount = 4, resource = I18N.agree(3, "solari") }) })
        end
        return options
    end
    local resolve = function (color, option, continuation)
        ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, option.amount > 0 and "✓" or "✗")
        local leader = PlayBoard.getLeader(color)
        leader.resources(color, "solari", -option.amount)
        leader.resources(color, "water", math.floor(option.amount / 2))
        continuation.run()
    end
    ArrakeenScouts._createSequentialChoiceController(playerPanes, getOptions, true, resolve)
end

---
function ArrakeenScouts._createRandomValidationController(playerPanes, secret, getLabel, resolve)
    local controller = {
        remainigPlayerCount = #Helper.getKeys(playerPanes),
        labels = {},
    }

    function controller.validate(color)
        ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, controller.labels[color], "…")
        local continuation = Helper.createContinuation("ArrakeenScouts._createRandomValidationController")
        if resolve then
            resolve(color, continuation)
        else
            continuation.run()
        end
        continuation.doAfter(function ()
            ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, controller.labels[color], "✓")
            ArrakeenScouts._refreshContent()
            controller.remainigPlayerCount = controller.remainigPlayerCount - 1
            if controller.remainigPlayerCount == 0 then
                ArrakeenScouts._endContent()
            end
        end)
        ArrakeenScouts._refreshContent()
    end

    for color, playerPane in pairs(playerPanes) do
        controller.labels[color] = getLabel and getLabel(color) or nil
        ArrakeenScouts._setAsValidationPane(color, playerPane, secret, controller.labels[color], controller)
    end
end

---
function ArrakeenScouts._createSequentialChoiceController(playerPanes, getOptions, secret, resolve)
    local controller = {
        turnSequence = TurnControl.getPhaseTurnSequence(),
        options = {},
    }

    function controller.setAsActivePlayer(color)
        local playerPane = playerPanes[color]
        local options = getOptions and getOptions(color) or nil
        if options then
            ArrakeenScouts._setAsOptionPane(color, playerPane, true, options, controller)
        else
            ArrakeenScouts._setAsValidationPane(color, playerPane, true, nil, controller)
        end
    end

    function controller.validate(color, option)
        TurnControl.endOfTurn(color)

        if controller.options[color] then
            log("Doing nothing: already validated")
            return
        end

        controller.options[color] = option
        ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, "✓")
        table.remove(controller.turnSequence, 1)
        if #controller.turnSequence > 0 then
            controller.setAsActivePlayer(controller.turnSequence[1])
        else
            local remainingPlayerCount = #Helper.getKeys(playerPanes)
            -- FIXME turn sequence.
            for otherColor, otherPlayerPane in pairs(playerPanes) do
                local otherOptionValue = nil -- Contrary to global variables, local variables are not initialized to 'nil' by Lua.
                if not secret then
                    otherOptionValue = controller.options[otherColor].value
                end
                ArrakeenScouts._setAsPassivePane(otherColor, otherPlayerPane, false, otherOptionValue, "…")
                local continuation = Helper.createContinuation("ArrakeenScouts._createSequentialChoiceController")
                if resolve then
                    resolve(otherColor, controller.options[otherColor], continuation)
                else
                    continuation.run()
                end
                continuation.doAfter(function ()
                    ArrakeenScouts._refreshContent()
                    remainingPlayerCount = remainingPlayerCount - 1
                    if remainingPlayerCount == 0 then
                        ArrakeenScouts._endContent()
                    end
                end)
            end
        end
        ArrakeenScouts._refreshContent()
    end

    local currentColor = controller.turnSequence[1]
    for color, playerPane in pairs(playerPanes) do
        if color == currentColor then
            controller.setAsActivePlayer(color)
        else
            ArrakeenScouts._setAsPassivePane(color, playerPane, false, I18N("waitOption"), "…")
        end
    end
end

---
function ArrakeenScouts._createSequentialBinaryChoiceController(playerPanes, predicate, resolveWithLeader)
    local getOptions = function (color)
        local options = { { status = false, value = I18N("refuseOption") } }
        if predicate(color) then
            table.insert(options, { status = true, value = I18N("acceptOption") })
        end
        return options
    end
    local resolve = function (color, option, continuation)
        if option.status then
            ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, "✓")
            local leader = PlayBoard.getLeader(color)
            resolveWithLeader(color, leader)
        else
            ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, "✗")
        end
        continuation.run()
    end
    ArrakeenScouts._createSequentialChoiceController(playerPanes, getOptions, true, resolve)
end

---
function ArrakeenScouts._createPendingController(playerPanes, operation)
    local controller = {
        turnSequence = TurnControl.getPhaseTurnSequence(),
        pendingResolver = nil,
    }

    function controller.setUpPlayerPane(color)
        local round = TurnControl.getCurrentRound()
        for i, pendingOperation in ipairs(ArrakeenScouts.pendingOperations) do
            if pendingOperation.round == round
                and pendingOperation.color == color
                and pendingOperation.operation == operation
            then
                table.remove(ArrakeenScouts.pendingOperations, i)
                controller.pendingResolver = pendingOperation.resolver
                ArrakeenScouts._setAsValidationPane(color, playerPanes[color], false, pendingOperation.reward, controller)
                return true
            end
        end
        ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, "✗")
        return false
    end

    function controller.nextReward()
        while #controller.turnSequence > 0 and not controller.setUpPlayerPane(controller.turnSequence[1]) do
            TurnControl.endOfTurn(controller.turnSequence[1])
            table.remove(controller.turnSequence, 1)
        end
    end

    function controller.validate(color)
        controller.pendingResolver()

        TurnControl.endOfTurn(color)
        table.remove(controller.turnSequence, 1)

        ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, "✓")
        controller.nextReward()
        ArrakeenScouts._refreshContent()

        if #controller.turnSequence == 0 then
            ArrakeenScouts._endContent()
        end
    end

    for color, playerPane in pairs(playerPanes) do
        ArrakeenScouts._setAsPassivePane(color, playerPane, false, I18N("waitOption"), "…")
    end

    controller.nextReward()
end

---
function ArrakeenScouts._ensureDiscard(color, predicate)
    return ArrakeenScouts._ensureCardOperation(
        Helper.partialApply(PlayBoard.getHandedCards, color),
        Helper.partialApply(PlayBoard.getDiscardedCards, color),
        predicate)
end

---
function ArrakeenScouts._ensureTrashFromHand(color)
    return ArrakeenScouts._ensureCardOperation(
        Helper.partialApply(PlayBoard.getHandedCards, color),
        Helper.partialApply(PlayBoard.getTrashedCards, color))
end

---
function ArrakeenScouts._ensureDiscardIntrigue(color)
    return ArrakeenScouts._ensureCardOperation(
        Helper.partialApply(PlayBoard.getIntrigues, color),
        Intrigue.getDiscardedIntrigues)
end

---
function ArrakeenScouts._ensureCardOperation(getSourceCards, getDestinationCards, predicate)
    local continuation = Helper.createContinuation("ArrakeenScouts._ensureCardOperation")

    local cardCache = {}

    local function createCardSet(cards)
        local set = Set.new()
        if cards then
            assert(type(cards) == "table")
            for _, card in ipairs(cards) do
                set:add(card.guid)
                cardCache[card.guid] = card
            end
        end
        return set
    end

    local function resolve(guid)
        return cardCache[guid]
    end

    local function getGuid(card)
        return card.guid
    end

    local sourceOldCards = createCardSet(getSourceCards())
    assert(#sourceOldCards >= 0, "No source cards!")

    local destinationOldCards = createCardSet(getDestinationCards())

    local function getMovedCardsFromSource()
        local destinationNewCards = createCardSet(getDestinationCards())
        local movedCards = destinationNewCards - destinationOldCards
        local movedCardsFromSource = movedCards ^ sourceOldCards
        local candidates = movedCardsFromSource:toList()
        if predicate and #candidates > 0 then
            candidates = Helper.mapValues(Helper.filter(Helper.mapValues(candidates, resolve), predicate), getGuid)
        end
        return candidates
    end

    Wait.condition(function()
        local card = cardCache[getMovedCardsFromSource()[1]]
        Helper.onceTimeElapsed(0.5).doAfter(function ()
            continuation.run(card)
        end)
    end, function()
        return #getMovedCardsFromSource() > 0
    end)

    return continuation
end

---
function ArrakeenScouts._ensureResearch(color)
    local continuation = Helper.createContinuation("ArrakeenScouts._ensureResearch")

    local holder = {}
    holder.listener = function (otherColor)
        if otherColor == color then
            Helper.unregisterEventListener("researchProgress", holder.listener)
            continuation.run()
        end
    end
    Helper.registerEventListener("researchProgress", holder.listener)

    return continuation
end

return ArrakeenScouts
