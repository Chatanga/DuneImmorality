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
local Action = Module.lazyRequire("Action")
local InfluenceTrack = Module.lazyRequire("InfluenceTrack")
local ImperiumCard = Module.lazyRequire("ImperiumCard")
local Combat = Module.lazyRequire("Combat")
local Intrigue = Module.lazyRequire("Intrigue")

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
            offWordOperations = true,
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

ArrakeenScouts._debug = { "intriguingGift" }

---
function ArrakeenScouts.onLoad(state)
    ArrakeenScouts.fr = require("fr.ArrakeenScouts")
    Helper.append(ArrakeenScouts, Helper.resolveGUIDs(true, {
        board = "54b5be"
    }))

    Helper.noPhysicsNorPlay(ArrakeenScouts.board)

    if state.settings then
        ArrakeenScouts.selectedCommittees = state.selectedCommittees
        ArrakeenScouts.selectedContent = state.selectedContent
        ArrakeenScouts._staticSetUp()
    end
end

---
function ArrakeenScouts.onSave(state)
    state.ArrakeenScouts = {
        selectedCommittees = ArrakeenScouts.selectedCommittees,
        selectedContent = ArrakeenScouts.selectedContent,
    }
end

---
function ArrakeenScouts.setUp(settings)
    if settings.variant == "arrakeenScouts" then

        local selection = {}
        for _, category in ipairs({ "committees", "auctions", "events", "missions", "sales" }) do
            local contributions = ArrakeenScouts._mergeContributions({
                ArrakeenScouts[category].base,
                settings.riseOfIx and ArrakeenScouts[category].ix or {},
                ArrakeenScouts[category].immortality or {}})
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
        for name, widget in pairs(contributionSet) do
            local value
            if widget == Helper.ERASE then
                value = nil
            else
                value = widget
            end
            contributions[name] = value
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
                for i, commitee in ipairs(ArrakeenScouts.selectedCommittees) do
                    ArrakeenScouts._createCommiteeTile(commitee, i)
                end
                Wait.frames(TurnControl.endOfPhase, 1)
            else
                ArrakeenScouts._nextContent()
            end
        end
    end)
end

---
function ArrakeenScouts._tearDown()
    ArrakeenScouts.board.destruct()
end

---
function ArrakeenScouts._nextContent()
    -- TODO Afficher aussi les missions réussies sous forme de contenu spécifique.
    local round = TurnControl.getCurrentRound()
    local firstRound = ArrakeenScouts._debug and 0 or 1
    local contents = ArrakeenScouts.selectedContent[round - firstRound]
    if contents and #contents > 0 then
        local content = contents[1]
        table.remove(contents, 1)
        ArrakeenScouts._createDialog(content)
    else
        TurnControl.endOfPhase()
    end
end

---
function ArrakeenScouts._createCommiteeTile(commitee, index)
    local image = ArrakeenScouts[I18N.getLocale()][commitee]
    assert(image, "Unknow Arrakeen Scouts content: " .. commitee)

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
            r = 0.0,
            g = 0.0,
            b = 0.0
        },
        Locked = true,
        Grid = true,
        Snap = true,
        IgnoreFoW = false,
        MeasureMovement = false,
        DragSelectable = true,
        Autoraise = true,
        Sticky = true,
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
        },
    }

    local spawnParameters = {
        data = data,
        position = ArrakeenScouts.board.getPosition() + Vector(0, 0.2, index * 0.5 - 1.7),
        rotation = Vector(0, 180, 180),
    }

    spawnObjectData(spawnParameters)
end

---
function ArrakeenScouts._createDialog(content)
    Helper.dump("Content:", content)

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
        if player.color == color or true then
            Helper.unregisterGlobalCallback(dropdown.attributes.onValueChanged)
            Helper.unregisterGlobalCallback(button.attributes.onClick)
            controller.validate(color, holder.selectedOption)
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
function ArrakeenScouts._setAsValidationPane(color, playerPane, secret, controller)

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
        if player.color == color or true then
            Helper.unregisterGlobalCallback(button.attributes.onClick)
            controller.onValidation(color)
        end
    end)

    Helper.mutateTable(playerPane, {
        tag = "HorizontalLayout",
        attributes = {
            padding = "20 20 0 0",
            spacing = 20,
        },
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
    Wait.time(function ()
        UI.setXmlTable({{}})
        ArrakeenScouts._nextContent()
    end, 2)
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

--- Auctions ---

function ArrakeenScouts._createMentat1Controller(playerPanes)
    return ArrakeenScouts._createMentatController(playerPanes, "solari")
end

function ArrakeenScouts._createMentat2Controller(playerPanes)
    return ArrakeenScouts._createMentatController(playerPanes, "spice")
end

function ArrakeenScouts._createMentatController(playerPanes, resourceName)
    ArrakeenScouts._createSequentialAuctionController(playerPanes, resourceName, nil, false, function (bids)
        local ranking = ArrakeenScouts._rankPlayers(bids)
        if #ranking > 0 and #ranking[1] == 1 then
            local winner = ranking[1][1]
            local leader = PlayBoard.getLeader(winner)
            local amount = bids[winner]
            leader.resources(winner, resourceName, -amount)
            leader.takeMentat(winner)
            if resourceName == "spice" then
                leader.drawImperiumCards(winner, 1)
            end
        end
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
        for color, amount in pairs(bids) do
            local leader = PlayBoard.getLeader(color)
            leader.resources(color, "spice", -amount)
            leader.troops(color, "supply", "combat", amount)
        end
    end)
end

function ArrakeenScouts._createTreachery1Controller(playerPanes)
    ArrakeenScouts._createSequentialAuctionController(playerPanes, "spice", nil, true, function (bids)
        local ranking = ArrakeenScouts._rankPlayers(bids)
        if ranking[1] then
            for _, color in ipairs(ranking[1]) do
                local leader = PlayBoard.getLeader(color)
                local amount = bids[color]
                leader.resources(color, "spice", -amount)
                leader.drawIntrigues(color, 1)
            end
        end
    end)
end

function ArrakeenScouts._createTreachery2Controller(playerPanes)
    ArrakeenScouts._createSequentialAuctionController(playerPanes, "spice", nil, true, function (bids)
        local ranking = ArrakeenScouts._rankPlayers(bids)
        if ranking[1] then
            for _, color in ipairs(ranking[1]) do
                local leader = PlayBoard.getLeader(color)
                local amount = bids[color]
                leader.resources(color, "spice", -amount)
                leader.drawIntrigues(color, 2)
            end
            if #ranking[1] == 1 and ranking[2] then
                for _, color in ipairs(ranking[2]) do
                    local leader = PlayBoard.getLeader(color)
                    local amount = bids[color]
                    leader.resources(color, "spice", -amount)
                    leader.drawIntrigues(color, 1)
                end
            end
        end
    end)
end

function ArrakeenScouts._createToTheHighestBidder1Controller(playerPanes)
    ArrakeenScouts._createSequentialAuctionController(playerPanes, "solari", nil, true, function (bids)
        local ranking = ArrakeenScouts._rankPlayers(bids)
        if ranking[1] then
            for _, color in ipairs(ranking[1]) do
                local leader = PlayBoard.getLeader(color)
                local amount = bids[color]
                leader.resources(color, "solari", -amount)
                leader.drawImperiumCards(color, 1)
            end
        end
    end)
end

function ArrakeenScouts._createToTheHighestBidder2Controller(playerPanes)
    ArrakeenScouts._createSequentialAuctionController(playerPanes, "solari", nil, true, function (bids)
        local ranking = ArrakeenScouts._rankPlayers(bids)
        if ranking[1] then
            for _, color in ipairs(ranking[1]) do
                local leader = PlayBoard.getLeader(color)
                local amount = bids[color]
                leader.resources(color, "solari", -amount)
                leader.drawImperiumCards(color, 2)
            end
            if #ranking[1] == 1 and ranking[2] then
                for _, color in ipairs(ranking[2]) do
                    local leader = PlayBoard.getLeader(color)
                    local amount = bids[color]
                    leader.resources(color, "solari", -amount)
                    leader.drawImperiumCards(color, 1)
                end
            end
        end
    end)
end

function ArrakeenScouts._createCompetitiveStudy1Controller(playerPanes)
    return ArrakeenScouts._createCompetitiveStudyController(playerPanes, 1)
end

function ArrakeenScouts._createCompetitiveStudy2Controller(playerPanes)
    return ArrakeenScouts._createCompetitiveStudyController(playerPanes, 2)
end

function ArrakeenScouts._createCompetitiveStudyController(playerPanes, level)
    ArrakeenScouts._createSequentialAuctionController(playerPanes, "solari", nil, true, function (bids)
        local ranking = ArrakeenScouts._rankPlayers(bids)
        if ranking[1] then
            for _, color in ipairs(ranking[1]) do
                local leader = PlayBoard.getLeader(color)
                local amount = bids[color]
                leader.resources(color, "solari", -amount)
                leader.troops(color, "supply", "tanks", 1)
                return ArrakeenScouts._ensureResearch(color)
            end
            if #ranking[1] == 1 and ranking[2] and level == 2 then
                for _, color in ipairs(ranking[2]) do
                    local leader = PlayBoard.getLeader(color)
                    local amount = bids[color]
                    leader.resources(color, "solari", -amount)
                    return ArrakeenScouts._ensureResearch(color)
                end
            end
        end
    end)
end

function ArrakeenScouts._createSequentialAuctionController(playerPanes, resourceName, maxValue, secret, resolve)
    local controller = {
        turnSequence = TurnControl.getPhaseTurnSequence(),
        values = {},
        bids = {},
    }

    function controller.setAsOptionPane(color, playerPane)
        local options = { { amount = 0, value = "Passer" } }
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
            table.insert(options, { amount = i, value = tostring(i) .. " " .. resourceName })
        end
        ArrakeenScouts._setAsOptionPane(color, playerPane, secret, options, controller)
    end

    function controller.validate(color, option)
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
            resolve(controller.bids)
            ArrakeenScouts._endContent()
        end
        ArrakeenScouts._refreshContent()
    end

    for color, playerPane in pairs(playerPanes) do
        local currentColor = controller.turnSequence[1]
        if color == currentColor then
            controller.setAsOptionPane(color, playerPane)
        else
            ArrakeenScouts._setAsPassivePane(color, playerPane, false, nil, "…")
        end
    end
end

--- Events ---

function ArrakeenScouts._createChangeOfPlansController(playerPanes)
    local getOptions = function (_)
        return {
            { status = false, value = "Refuser" },
            { status = true, value = "Accepter" }
        }
    end
    local resolve = function (color, option, continuation)
        ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, "✗")
        if option.status then
            ArrakeenScouts._ensureDiscard(color).doAfter(function (card)
                local cardName = card.getName and card.getName() or card.name
                ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, cardName, "✓")
                local leader = PlayBoard.getLeader(color)
                leader.drawImperiumCards(color, 1)
                continuation.run()
            end)
        else
            continuation.run()
        end
    end
    ArrakeenScouts._createSequentialChoiceController(playerPanes, getOptions, false, resolve)
end

function ArrakeenScouts._createCovertOperationController(playerPanes)
    local getOptions = function (_)
        return {
            { roundCount = 1, value = "+2 solari dans 1 manche" },
            { roundCount = 1, value = "+1 Empereur dans 1 manche" },
            { roundCount = 1, value = "+1 Guilde Spatiale dans 1 manche" },
            { roundCount = 1, value = "+1 Bene Gesserit dans 1 manche" },
            { roundCount = 1, value = "+1 Fremens dans 1 manche" },
            { roundCount = 2, value = "+2 épice dans 2 manches" },
            { roundCount = 2, value = "+2 Empereur dans 2 manches" },
            { roundCount = 2, value = "+2 Guilde Spatiale dans 2 manches" },
            { roundCount = 2, value = "+2 Bene Gesserit dans 2 manches" },
            { roundCount = 2, value = "+2 Fremens dans 2 manches" },
        }
    end
    local resolve = function (color, option, continuation)
        ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, "✓")
        table.insert(ArrakeenScouts.pendingOperations, {
            round = TurnControl.getCurrentRound() + option.roundCount,
            color = color,
            value = option.value,
        })
        continuation.run()
    end
    ArrakeenScouts._createSequentialChoiceController(playerPanes, getOptions, true, resolve)
end

function ArrakeenScouts._createGiftOfWaterController(playerPanes)
    local getOptions = function (color)
        local options = { { status = false, value = "Refuser" } }
        local water = PlayBoard.getResource(color, "water")
        if water:get() >= 1 then
            table.insert(options, { status = true, value = "Accepter" })
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
        local options = { { status = false, value = "Passer" } }
        local notStarterCards = Helper.filter(PlayBoard.getHandCards(color), notAStarterCard)
        if #notStarterCards > 0 then
            table.insert(options, { status = true, value = "Défausser" })
        end
        return options
    end
    local resolve = function (color, option, continuation)
        ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, option.status and "✓" or "✗")
        if option.status then
            ArrakeenScouts._ensureDiscard(color, notAStarterCard).doAfter(function ()
                local leader = PlayBoard.getLeader(color)
                leader.influence(color, "fremen", 1)
                continuation.run()
            end)
        else
            continuation.run()
        end
    end
    ArrakeenScouts._createSequentialChoiceController(playerPanes, getOptions, true, resolve)
end

function ArrakeenScouts._createGuildNegotiationController(playerPanes)
    local getOptions = function (color)
        local options = { { status = false, value = "Passer" } }
        local solari = PlayBoard.getResource(color, "solari")
        if solari:get() >= 2 then
            table.insert(options, { status = true, value = "Accepter" })
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
        local options = { { status = false, value = "Passer" } }
        local intrigues = PlayBoard.getIntrigues(color)
        if #intrigues > 0 then
            table.insert(options, { status = true, value = "Accepter" })
        end
        return options
    end
    local resolve = function (color, option, continuation)
        ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, option.status and "✓" or "✗")
        if option.status then
            ArrakeenScouts._ensureDiscardIntrigue(color).doAfter(function ()
                Action.influence(color, "beneGesserit", 1)
                continuation.run()
            end)
        else
            continuation.run()
        end
    end
    ArrakeenScouts._createSequentialChoiceController(playerPanes, getOptions, true, resolve)
end

--[[

function ArrakeenScouts._createTestOfLoyalty(color)
    local options = { "Passer" }
    local garissonPark = Combat.getGarrisonPark(color)
    if not Park.isEmpty(garissonPark) then
        table.insert(options, "Accepter")
    end
    local function handler(_, option)
        local index = Helper.indexOf(options, option)
        if index == 2 then
            Action.troops(color, "garisson", "supply", 1)
            Action.influence(color, "emperor", 1)
        end
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

function ArrakeenScouts._createBeneGesseritTreachery(color)
    local options = { "Défausser" }
    if InfluenceTrack.getInfluence("beneGesserit", color) > 0 then
        table.insert(options, "-1 Bene Gesserit")
    end
    local function handler(_, option)
        local index = Helper.indexOf(options, option)
        if index == 1 then
            ArrakeenScouts._ensureDiscard(color)
        elseif index == 2 then
            Action.influence(color, "beneGesserit", -1)
        end
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

function ArrakeenScouts._createEmperorsTax(color)
    local options = {}
    local spice = PlayBoard.getResource(color, "spice")
    if spice:get() >= 1 then
        table.insert(options, "-1 épice")
    end
    if InfluenceTrack.getInfluence("emperor", color) > 0 then
        table.insert(options, "-1 Empereur")
    end
    local function handler(_, option)
        local index = Helper.indexOf(options, option)
        if index == "-1 épice" then
            Action.resources(color, "spice", -1)
        elseif index == "-1 Empereur" then
            Action.influence(color, "emperor", -1)
        end
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

function ArrakeenScouts._createFremenExchange(color)
    local options = {}
    local garrisonPark = Combat.getGarrisonPark(color)
    if not Park.isEmpty(garrisonPark) then
        table.insert(options, "-1 troop")
    end
    if InfluenceTrack.getInfluence("fremen", color) > 0 then
        table.insert(options, "-1 Fremens")
    end
    local function handler(_, option)
        if option == "-1 troop" then
            Action.troops(color, "garrison", "supply", -1)
        elseif option == "-1 Fremens" then
            Action.influence(color, "fremen", -1)
        end
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

function ArrakeenScouts._createPoliticalEquilibrium(color)
    local highestInfluence
    local highestFactions
    for _, faction in ipairs({ "emperor", "spacingGuild", "beneGesserit", "fremen" }) do
        local influence = InfluenceTrack.getInfluence(faction, color)
        if not highestFactions or influence > highestFactions then
            highestInfluence = influence
            highestFactions = { faction }
        elseif highestInfluence == influence then
            table.insert(highestFactions, faction)
        end
    end

    local options = #highestFactions > 1 and highestFactions or nil
    local function handler(_, option)
        Action.influence(color, option, 1)
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

function ArrakeenScouts._createWaterForSpiceSmugglers(color)
    local options = {}
    local water = PlayBoard.getResource(color, "water")
    if water:get() >= 1 then
        table.insert(options, "-1 solari")
    end
    if InfluenceTrack.getInfluence("spacingGuild", color) > 0 then
        table.insert(options, "-1 Spacing Guild")
    end
    local function handler(_, option)
        if option == "water" then
            Action.resources(color, "water", 1)
        else
            Action.influence(color, "spacingGuild", -1)
        end
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

function ArrakeenScouts._createRotationgDoors(color)
    local options = { "Refuser" }
    local intrigues = PlayBoard.getIntrigues(color)
    if #intrigues > 0 then
        table.insert(options, "Accepter")
    end
    local function handler(_, option)
        local index = Helper.indexOf(options, option)
        if index == 2 then
            ArrakeenScouts._ensureDiscardIntrigue(color).doAfter(function ()
                Action.drawIntrigues(color, 1)
            end)
        end
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

function ArrakeenScouts._createSecretsForSale(color)
    local options = { "Refuser" }
    local solari = PlayBoard.getResource(color, "solari")
    if solari:get() >= 1 then
        table.insert(options, "-1 solari")
    end
    local spice = PlayBoard.getResource(color, "spice")
    if spice:get() >= 1 then
        table.insert(options, "-1 épice")
    end
    local function handler(_, option)
        local index = Helper.indexOf(options, option)
        if index > 1 then
            if option == "-1 solari" then
                Action.resources(color, "solari", -1)
            elseif option == "-1 épice" then
                Action.resources(color, "spice", -1)
            end
            Action.drawIntrigues(color, 1)
        end
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

function ArrakeenScouts._createNoComingBack(color)
    local factions = { "Empereur", "Guilde Spatiale", "Bene Gesserit", "Fremens" }
    local options = {
        "Refuser",
        "Accepter (" .. factions[1] .. ")",
        "Accepter (" .. factions[2] .. ")",
        "Accepter (" .. factions[3] .. ")",
        "Accepter (" .. factions[4] .. ")",
    }
    local function handler(_, option)
        local index = Helper.indexOf(options, option)
        if index > 1 then
            local faction = factions[index - 1]
            return ArrakeenScouts._ensureTrashFromHand(color).doAfter(function (card)
                local cardName = Helper.getID(card)
                if cardName == "seekAllies" then
                    Action.influence(color, faction, 1)
                elseif cardName == "diplomacy" then
                    Action.influence(color, faction, 2)
                end
                Action.troops(color, "supply", "tanks", 1)
            end)
        end
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

function ArrakeenScouts._createTapIntoSpiceReserves(color)
    local function handler(_, option)
        Action.resources(color, "spice", 1)
    end
    return ArrakeenScouts._createDefault(color, false, false, nil, handler)
end

function ArrakeenScouts._createGetBackInTheGoodGraces(color)
    local options = { "Passer" }
    local tankPark = TleilaxuResearch.getTankPark(color)
    if not Park.isEmpty(tankPark) then
        table.insert(options, "+1 Empereur")
        table.insert(options, "+1 Guilde Spatiale")
        table.insert(options, "+1 Bene Gesserit")
        table.insert(options, "+1 Fremens")
    end
    local function handler(_, option)
        local index = Helper.indexOf(options, option)
        if index > 1 then
            Action.troops(color, "tanks", "supply", 1)
            if index == 2 then
                Action.influence(color, "emperor", 1)
            elseif index == 3 then
                Action.influence(color, "spacingGuild", 1)
            elseif index == 4 then
                Action.influence(color, "beneGesserit", 1)
            elseif index == 5 then
                Action.influence(color, "fremen", 1)
            end
        end
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

function ArrakeenScouts._createTreachery(color)
    local options = { "Passer" }
    if InfluenceTrack.getInfluence("beneGesserit", color) > 0 then
        table.insert(options, "-1 Bene Gesserit")
    end
    local function handler(_, option)
        local index = Helper.indexOf(options, option)
        if index == 2 then
            Action.influence(color, "beneGesserit", -1)
            Action.beetle(color, 1)
        end
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

function ArrakeenScouts._createNewInnovations(color)
    local options = { "Refuser" }
    local solari = PlayBoard.getResource(color, "solari")
    if solari:get() >= 1 then
        table.insert(options, "-1 solari")
    end
    local spice = PlayBoard.getResource(color, "spice")
    if spice:get() >= 1 then
        table.insert(options, "-1 épice")
    end
    local function handler(_, option)
        local index = Helper.indexOf(options, option)
        if index > 1 then
            if option == "-1 solari" then
                Action.resources(color, "solari", -1)
            elseif option == "-1 épice" then
                Action.resources(color, "spice", -1)
            end
            return ArrakeenScouts._ensureResearch(color)
        end
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

function ArrakeenScouts._createOffWordOperations(color)
    local options = {
        "+2 solari dans 1 manche",
        "+1/+2 épices dans 1 manche",
        "+1 scarabé dans 2 manches",
        "+1 intrigue dans 2 manches",
    }
    local function handler(_, option)
        local index = Helper.indexOf(options, option)
        local roundCount = 1 + math.floor(index / 5)
        table.insert(ArrakeenScouts.pendingOperations, {
            round = TurnControl.getCurrentRound() + roundCount,
            color = color,
            option = option,
        })
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

function ArrakeenScouts._createCeaseAndDesistRequest(color)
    local options = { "Refuser" }
    local supplyPark = PlayBoard.getSupplyPark(color)
    if not Park.isEmpty(supplyPark) then
        table.insert(options, "Détruire 1 carte de sa main")
    end
    local function handler(_, option)
        local index = Helper.indexOf(options, option)
        if index == 2 then
            return ArrakeenScouts._ensureTrashFromHand(color).doAfter(function ()
                Action.troops(color, "supply", "tanks", 1)
            end)
        end
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

--- Missions ---

function ArrakeenScouts._createSecretsInTheDesert(color, isFirstPlayer)
    if isFirstPlayer then
        MainBoard.addSpaceBonus("researchStation", { all = { intrigue = 2 } })
    end
    return ArrakeenScouts._createDefault(color)
end

function ArrakeenScouts._createStationedSupport(color)
    local options = { "Refuser" }
    local supplyPark = PlayBoard.getSupplyPark(color)
    local troops = Park.getObjects(supplyPark)
    if #troops >= 2 then
        table.insert(options, "Accepter")
    end
    local function handler(c, index, option)
        if option == "Accepter" then
            MainBoard.addSpaceBonus("researchStation", { [color] = { combatTroop = { troops[1], troops[2] } } })
        end
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

function ArrakeenScouts._createGeneticResearch(color)
    local options = { "Refuser" }
    local supplyPark = PlayBoard.getSupplyPark(color)
    if not Park.isEmpty(supplyPark) then
        table.insert(options, "Accepter")
    end
    local function handler(_, option)
        if option == "Accepter" then
            MainBoard.addSpaceBonus("secrets", { [color] = { combatTroop = { Park.getAnyObject(supplyPark) }, solari = 2 } })
        end
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

function ArrakeenScouts._createGuildManipulations(color)
    local options = { "Refuser" }
    local supplyPark = PlayBoard.getSupplyPark(color)
    local troops = Park.getObjects(supplyPark)
    local spice = PlayBoard.getResource(color, "spice")
    if #troops >= 2 and spice:get() >= 1 then
        table.insert(options, "Accepter")
    end
    local function handler(_, option)
        if option == "Accepter" then
            Action.resources(color, "spice", -1)
            MainBoard.addSpaceBonus("foldspace", { [color] = { combatTroop = { troops[1], troops[2] } } })
        end
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

function ArrakeenScouts._createSpiceIncentive(color, isFirstPlayer)
    if isFirstPlayer then
        MainBoard.addSpaceBonus("rallyTroops", { all = { solari = 2 } })
    end
    return ArrakeenScouts._createDefault(color)
end

function ArrakeenScouts._createStrongarmedAlliance(color)
    local options = { "Refuser" }
    local supplyPark = PlayBoard.getSupplyPark(color)
    if not Park.isEmpty(supplyPark) then
        table.insert(options, "Accepter")
    end
    local function handler(_, option)
        if option == "Accepter" then
            MainBoard.addSpaceBonus("rallyTroops", { [color] = { combatTroop = { Park.getAnyObject(supplyPark) } } })
        end
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

function ArrakeenScouts._createSaphoJuice(color)
    local function handler(_, option)
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
    end
    return ArrakeenScouts._createDefault(color, false, false, nil, handler)
end

function ArrakeenScouts._createSpaceTravelDeal(color, isFirstPlayer)
    if isFirstPlayer then
        MainBoard.addSpaceBonus("heighliner", { all = { "solari", "solari", "solari" } })
    end
    return ArrakeenScouts._createDefault(color)
end

function ArrakeenScouts._createArmedEscort(color)
    local options = { "Refuser" }
    local dreadnoughtPark = PlayBoard.getDreadnoughtPark(color)
    if not Park.isEmpty(dreadnoughtPark) then
        table.insert(options, "Accepter")
    end
    local function handler(_, option)
        if option == "Accepter" then
            MainBoard.addSpaceBonus("dreadnought", { [color] = { combatDreadnought = { Park.getAnyObject(dreadnoughtPark) }, spice = 1 } })
        end
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

function ArrakeenScouts._createSecretStash(color, isFirstPlayer)
    if isFirstPlayer then
        MainBoard.addSpaceBonus("smuggling", { all = { spice = 2 } })
    end
    return ArrakeenScouts._createDefault(color)
end

function ArrakeenScouts._createStowaway(color)
    local options = { "Refuser" }
    local supplyPark = PlayBoard.getSupplyPark(color)
    local troops = Park.getObjects(supplyPark)
    local spice = PlayBoard.getResource(color, "spice")
    if #troops >= 2 and spice:get() >= 1 then
        table.insert(options, "Accepter")
    end
    local function handler(_, option)
        if option == "Accepter" then
            Action.resources(color, "spice", -1)
            MainBoard.addSpaceBonus("smuggling", { [color] = { combatTroop = { troops[1], troops[2] } } })
        end
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

function ArrakeenScouts._createBackstageAgreement(color, isFirstPlayer)
    if isFirstPlayer then
        TleilaxuRow.addAcquireBonus({ all = { solari = 2 } })
    end
    return ArrakeenScouts._createDefault(color)
end

function ArrakeenScouts._createSecretsInTheDesert_immortality(color)
    return ArrakeenScouts._createSecretsInTheDesert(color)
end

function ArrakeenScouts._createStationedSupport_immortality(color)
    return ArrakeenScouts._createStationedSupport(color)
end

function ArrakeenScouts._createCoordinationWithTheEmperor(color)
    local options = { "Refuser" }
    local tankPark = TleilaxuResearch.getTankPark(color)
    if not Park.isEmpty(tankPark) then
        table.insert(options, "Accepter")
    end
    local function handler(_, option)
        if option == "Accepter" then
            MainBoard.addSpaceBonus("conspire", { [color] = { garrisonTroop = { Park.getAnyObject(tankPark) }, solari = 2 } })
        end
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

function ArrakeenScouts._createSponsoredResearch(color, isFirstPlayer)
    if isFirstPlayer then
        TleilaxuResearch.addSpaceBonus("oneHelix", { all = { solari = 2 } })
    end
    return ArrakeenScouts._createDefault(color)
end

function ArrakeenScouts._createTleilaxuOffering(color)
    local options = { "Refuser" }
    local supplyPark = PlayBoard.getSupplyPark(color)
    local troops = Park.getObjects(supplyPark)
    if #troops >= 2 then
        table.insert(options, "Accepter")
    end
    local function handler(_, option)
        if option == "Accepter" then
            -- Not to be deployed, but to be added as specimen.
            TleilaxuResearch.addSpaceBonus(3, { [color] = { tankTroop = { troops[1], troops[2] } } })
        end
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

--- Sales ---

function ArrakeenScouts._createFremenMercenaries(color)
    local options = { "Refuser" }
    local supplyPark = PlayBoard.getSupplyPark(color)
    local troops = Park.getObjects(supplyPark)
    local water = PlayBoard.getResource(color, "water")
    local maxValue = math.min(math.floor((#troops + 1) / 2), water:get())
    for i = 1, maxValue do
        table.insert(options, "Spent " .. tostring(i) .. " water")
    end
    local function handler(_, option)
        local index = Helper.indexOf(options, option)
        local waterAmount = index - 1
        Action.resources(color, "water", -waterAmount)
        Action.troops(color, "supply", "combat", waterAmount * 2)
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

function ArrakeenScouts._createRevealTheFuture(color)
    local options = { "Refuser" }
    local spice = PlayBoard.getResource(color, "spice")
    if spice:get() >= 1 then
        table.insert(options, "Spent 1 spice")
    end
    if spice:get() >= 3 then
        table.insert(options, "Spent 3 spices")
    end
    local function handler(_, option)
        local index = Helper.indexOf(options, option)
        if index == 2 then
            Action.resources(color, "spice", -1)
            Action.drawImperiumCards(color, 1)
        elseif index == 3 then
            Action.resources(color, "spice", -3)
            Action.drawImperiumCards(color, 2)
        end
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

function ArrakeenScouts._createSooSooSookWaterPeddlers(color)
    local options = { "Refuser" }
    local solari = PlayBoard.getResource(color, "solari")
    if solari:get() >= 2 then
        table.insert(options, "Spent 2 solari")
    end
    if solari:get() >= 3 then
        table.insert(options, "Spent 4 solari")
    end
    local function handler(_, option)
        local index = Helper.indexOf(options, option)
        if index == 2 then
            Action.resources(color, "solari", -2)
            Action.resources(color, "water", 1)
        elseif index == 3 then
            Action.resources(color, "solari", -4)
            Action.resources(color, "water", 2)
        end
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

]]--

function ArrakeenScouts._createSequentialChoiceController(playerPanes, getOptions, secret, resolve)
    local controller = {
        turnSequence = TurnControl.getPhaseTurnSequence(),
        options = {},
    }

    function controller.validate(color, option)
        controller.options[color] = option
        ArrakeenScouts._setAsPassivePane(color, playerPanes[color], false, nil, "✓")
        table.remove(controller.turnSequence, 1)
        if #controller.turnSequence > 0 then
            local nextColor = controller.turnSequence[1]
            ArrakeenScouts._setAsOptionPane(nextColor, playerPanes[nextColor], true, getOptions(nextColor), controller)
        else
            local remainingPlayerCount = #Helper.getKeys(playerPanes)
            for otherColor, otherPlayerPane in pairs(playerPanes) do
                local otherOptionValue = nil -- Contrary to global variables, local variables are not initialized to 'nil' by Lua.
                if not secret then
                    otherOptionValue = controller.options[otherColor].value
                end
                ArrakeenScouts._setAsPassivePane(otherColor, otherPlayerPane, false, otherOptionValue, "…")
                local continuation = Helper.createContinuation()
                resolve(otherColor, controller.options[otherColor], continuation)
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

    for color, playerPane in pairs(playerPanes) do
        local currentColor = controller.turnSequence[1]
        if color == currentColor then
            ArrakeenScouts._setAsOptionPane(color, playerPane, true, getOptions(color), controller)
        else
            ArrakeenScouts._setAsPassivePane(color, playerPane, false, nil, "…")
        end
    end
end

--- Missions ---

--- Sales ---

---
function ArrakeenScouts._ensureDiscard(color, predicate)
    local continuation = Helper.createContinuation()

    local cardCache = {}

    local function createSetFromDiscard()
        local set = Set.new()
        for _, card in ipairs(PlayBoard.getDiscardedCards(color)) do
            set:add(card.guid)
            cardCache[card.guid] = card
        end
        return set
    end

    local oldDiscardedCards = createSetFromDiscard()

    local function getNewlyDiscardedCards()
        local newDiscardedCards = createSetFromDiscard()
        local newlyDiscardedCards = newDiscardedCards - oldDiscardedCards
        if predicate then
            newlyDiscardedCards = Helper.filter(newlyDiscardedCards, predicate)
        end
        return newlyDiscardedCards:toList()
    end

    Wait.condition(function()
        local card = cardCache[getNewlyDiscardedCards()[1]]
        Wait.time(function ()
            continuation.run(card)
        end, 0.5)
    end, function()
        return #getNewlyDiscardedCards() > 0
    end)

    return continuation
end

---
function ArrakeenScouts._ensureTrashFromHand(color)
    local continuation = Helper.createContinuation()
    local card = nil
    continuation.run(card)
    log("TODO ArrakeenScouts._ensureTrashFromHand")
    return continuation
end

---
function ArrakeenScouts._ensureDiscardIntrigue(color)
    local continuation = Helper.createContinuation()

    local cardCache = {}

    local function createCardSet(cards)
        local set = Set.new()
        for _, card in ipairs(cards) do
            set:add(card.guid)
            cardCache[card.guid] = card
        end
        return set
    end

    local oldHandedIntrigues = createCardSet(PlayBoard.getIntrigues(color))
    local allOldDiscardedIntrigues = createCardSet(Intrigue.getDiscardedIntrigues())

    local function getNewlyDiscardedIntrigues()
        local newDiscardedIntrigues = createCardSet(Intrigue.getDiscardedIntrigues())
        local allNewlyDiscardedIntrigues = newDiscardedIntrigues - allOldDiscardedIntrigues
        local newlyDiscardedCards = allNewlyDiscardedIntrigues ^ oldHandedIntrigues
        return newlyDiscardedCards:toList()
    end

    Wait.condition(function()
        local card = cardCache[getNewlyDiscardedIntrigues()[1]]
        Wait.time(function ()
            continuation.run(card)
        end, 0.5)
    end, function()
        return #getNewlyDiscardedIntrigues() > 0
    end)

    return continuation
end

---
function ArrakeenScouts._ensureResearch(color)
    local continuation = Helper.createContinuation()

    local oldCellPosition = TleilaxuResearch.getTokenCellPosition(color)

    Wait.condition(function()
        Wait.time(function ()
            continuation.run()
        end, 0.5)
    end, function()
        local newCellPosition = TleilaxuResearch.getTokenCellPosition(color)
        return newCellPosition ~= oldCellPosition
    end)

    return continuation
end

return ArrakeenScouts
