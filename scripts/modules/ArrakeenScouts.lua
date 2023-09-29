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
            treachery_immortality = true,
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
    }
}

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
        -- DEBUG
        table.insert(ArrakeenScouts.selectedContent, { "geneticResearch" })
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

local firstRound = 0

---
function ArrakeenScouts._staticSetUp()
    Helper.registerEventListener("phaseStart", function (phaseName)
        if phaseName == "arrakeenScouts" then
            local round = TurnControl.getCurrentRound()
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
    local contents = ArrakeenScouts.selectedContent[round - firstRound]
    if #contents > 0 then
        local content = contents[1]
        table.remove(contents, 1)

        ArrakeenScouts.turnSequence = TurnControl.getPhaseTurnSequence()

        ArrakeenScouts.auctions = {}
        ArrakeenScouts.choices = {}
        ArrakeenScouts.handlers = {}
        ArrakeenScouts.widgets = {}

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
    local leaderNames = {}
    for _, color in ipairs(PlayBoard.getPlayBoardColors()) do
        leaderNames[color] = PlayBoard.getLeaderName(color)
    end

    local createPlayerDialog = ArrakeenScouts[Helper.toCamelCase("_create", content)]
    assert(createPlayerDialog)

    local playerMiniUIs = {}
    for _, color in ipairs({ "Red", "Green", "Blue", "Yellow" }) do
        local leaderName = leaderNames[color]
        local playerUI = ArrakeenScouts._createPlayerUI(createPlayerDialog, color, leaderName)
        table.insert(playerMiniUIs, playerUI)
    end

    local image = ArrakeenScouts[I18N.getLocale()][content]
    assert(image, "Unknow Arrakeen Scouts content: " .. content)

    ArrakeenScouts.ui = ArrakeenScouts._createDialogUI(image, playerMiniUIs)

    UI.setXmlTable({ ArrakeenScouts.ui })
end

---
function ArrakeenScouts._createPlayerUI(createPlayerDialog, color, leaderName)
    local playerUI

    if leaderName then
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
                            value = leaderName
                        },
                        createPlayerDialog(color, TurnControl.getFirstPlayer() == color)
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
function ArrakeenScouts._createDialogUI(image, playerMiniUIs)
    return {
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
                        children = playerMiniUIs
                    }
                }
            }
        }
    }
end

---
function ArrakeenScouts._createDefault(color, sequential, secret, options, handler)
    ArrakeenScouts.handlers[color] = handler

    local dropdown
    if options then
        ArrakeenScouts.choices[color] = options[1]
        dropdown = {
            tag = "Dropdown",
            attributes = {
                id = color .. "Options",
                flexibleWidth = 100,
                onValueChanged = Helper.registerGlobalCallback(function (_, value, _)
                    ArrakeenScouts.choices[color] = value
                end),
            },
            children = Helper.map(options, function (i, option)
                return {
                    tag = "Option",
                    attributes = {
                        selected = i == 1,
                    },
                    value = option
                }
            end),
        }
    end

    local widget = {
        dropdown = dropdown
    }
    if not sequential or color == ArrakeenScouts.turnSequence[1] then
        ArrakeenScouts._mutateAsButton(widget, sequential, color)
    else
        ArrakeenScouts._mutateAsText(widget, "✗")
    end

    ArrakeenScouts.widgets[color] = widget

    if secret and options then
        options = Helper.shallowCopy(options)
        Helper.shuffle(options)
    end

    local children
    if options then
        ArrakeenScouts.choices[color] = options[1]
        children = {
            dropdown,
            widget,
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
            widget,
            {
                tag = "Text",
                attributes = {
                    flexibleWidth = 50,
                },
                value = "-"
            },
        }
    end

    local ui = {
        tag = "HorizontalLayout",
        attributes = {
            padding = "20 20 0 0",
            spacing = 20,
        },
        children = children
    }

    if secret then
        ui.attributes.visibility = color
    end

    return ui
end

---
function ArrakeenScouts._mutateAsText(widget, value)
    widget.tag = "Text"
    widget.attributes = {
        fontSize = "40",
        color = "#FFFFFF",
        preferredWidth = 40,
        preferredHeight = 40,
    }
    widget.children = {}
    widget.value = value
end

---
function ArrakeenScouts._mutateAsLabel(widget, value)
    widget.tag = "Text"
    widget.attributes = {
        --fontSize = "20",
        color = "#FFFFFF",
        --referredWidth = 40,
        --preferredHeight = 40,
    }
    widget.children = {}
    widget.value = value
end

---
function ArrakeenScouts._mutateAsButton(widget, sequential, color)
    widget.tag = "Button"
    widget.attributes = {
        fontSize = "20",
        fontStyle = "Bold",
        outlineSize = "1 1",
        preferredWidth = 40,
        preferredHeight = 40,
        flexibleWidth = 0,
    }
    widget.children = {}
    widget.value = "OK"

    widget.attributes.onClick = Helper.registerGlobalCallback(function (player)
        if player.color == color or true then
            Helper.unregisterGlobalCallback(widget.attributes.onClick)
            ArrakeenScouts._processPlayerValidation(widget, sequential, color)
        end
    end)
end

---
function ArrakeenScouts._processPlayerValidation(widget, sequential, color)
    ArrakeenScouts.widgets[color] = nil
    ArrakeenScouts._mutateAsText(widget, "…")
    if widget.dropdown then
        Helper.unregisterGlobalCallback(widget.dropdown.attributes.onValueChanged)
        ArrakeenScouts._mutateAsLabel(widget.dropdown, ArrakeenScouts.choices[color])
    end
    UI.setXmlTable({ ArrakeenScouts.ui })

    local continuation = Helper.createContinuation()
    local handler = ArrakeenScouts.handlers[color]
    if handler then
        local choice = ArrakeenScouts.choices and ArrakeenScouts.choices[color] or nil
        local subContinuation = handler(color, choice)
        if subContinuation then
            subContinuation.doAfter(continuation.run)
        else
            continuation.run()
        end
    else
        continuation.run()
    end

    continuation.doAfter(function ()
        local done = false
        if sequential then
            table.remove(ArrakeenScouts.turnSequence, 1)
            if #ArrakeenScouts.turnSequence > 0 then
                local nextColor = ArrakeenScouts.turnSequence[1]
                ArrakeenScouts._mutateAsButton(ArrakeenScouts.widgets[nextColor], sequential, nextColor)
            else
                done = true
            end
        elseif #Helper.getKeys(ArrakeenScouts.widgets) == 0 then
            done = true
        end

        if done then
            ArrakeenScouts._done()
        end

        ArrakeenScouts._mutateAsText(widget, "✓")
        UI.setXmlTable({ ArrakeenScouts.ui })
    end)
end

---
function ArrakeenScouts._done()
    if #ArrakeenScouts.auctions > 0 then
        log("TODO auctions")
    end

    Wait.time(function ()
        UI.setXmlTable({{}})
        ArrakeenScouts._nextContent()
    end, 0.250)
end

--- Auctions ---

function ArrakeenScouts._createMentat1(color)
    local maxAuction = 0
    for _, auction in ipairs(ArrakeenScouts.auctions) do
        maxAuction = math.max(maxAuction, auction.value)
    end
    local options = { "Passer" }
    local solari = PlayBoard.getResource(color, "solari")
    local amounts = { 0 }
    for i = maxAuction + 1, solari:get() do
        table.insert(amounts, i)
        table.insert(options, tostring(i) .. " solari")
    end
    local function handler(_, option)
        local index = Helper.indexOf(options, option)
        local amount = amounts[index]
        ArrakeenScouts.auctions[color] = {
            value = amount,
            solver = function (ranking)
                if Helper.tableContains(ranking[1], color) then
                    Action.resources(color, "solari", -amount)
                    if not Action.takeMentat(color) then
                        -- TODO Choix influence
                    end
                end
            end
        }
    end
    return ArrakeenScouts._createDefault(color, true, false, options, handler)
end

function ArrakeenScouts._createMentat2(color)
    local maxAuction = 0
    for _, auction in ipairs(ArrakeenScouts.auctions) do
        maxAuction = math.max(maxAuction, auction.value)
    end
    local options = { "Passer" }
    local spice = PlayBoard.getResource(color, "spice")
    local amounts = { 0 }
    for i = maxAuction + 1, spice:get() do
        table.insert(amounts, i)
        table.insert(options, tostring(i) .. " spice")
    end
    local function handler(_, option)
        local index = Helper.indexOf(options, option)
        local amount = amounts[index]
        ArrakeenScouts.auctions[color] = {
            value = amount,
            solver = function (ranking)
                if Helper.tableContains(ranking[1], color) then
                    Action.resources(color, "spice", -amount)
                    Action.takeMentat(color)
                    Action.drawImperiumCards(color, 1)
                end
            end
        }
    end
    return ArrakeenScouts._createDefault(color, true, false, options, handler)
end

function ArrakeenScouts._createMercenaries1(color)
    return ArrakeenScouts._createMercenaries(color)
end

function ArrakeenScouts._createMercenaries2(color)
    return ArrakeenScouts._createMercenaries(color)
end

function ArrakeenScouts._createMercenaries(color)
    local options = {}
    local spice = PlayBoard.getResource(color, "spice")
    local amounts = {}
    for i = 0, math.min(3, spice:get()) do
        table.insert(amounts, i)
    end
    Helper.shuffle(amounts)
    for _, amount in ipairs(amounts) do
        table.insert(options, tostring(amount) .. " spice")
    end
    local function handler(_, option)
        local index = Helper.indexOf(options, option)
        local amount = amounts[index]
        Action.resources(color, "spice", -amount)
        Action.troops(color, "supply", "combat", amount)
        ArrakeenScouts.auctions[color] = {
            value = amount,
            solver = function (ranking)
                if Helper.tableContains(ranking[#ranking], color) then
                    -- TODO Can retreat up to amount troops.
                end
            end
        }
    end
    return ArrakeenScouts._createDefault(color, false, true, options, handler)
end

function ArrakeenScouts._createTreachery1(color)
    local options = {}
    local spice = PlayBoard.getResource(color, "spice")
    local amounts = {}
    for i = 0, spice:get() do
        table.insert(amounts, i)
    end
    Helper.shuffle(amounts)
    for _, amount in ipairs(amounts) do
        table.insert(options, tostring(amount) .. " spice")
    end
    local function handler(_, option)
        local index = Helper.indexOf(options, option)
        local amount = amounts[index]
        ArrakeenScouts.auctions[color] = {
            value = amount,
            solver = function (ranking)
                if Helper.tableContains(ranking[1], color) then
                    Action.resources(color, "spice", -amount)
                    Action.drawIntrigues(color, 1)
                end
            end
        }
    end
    return ArrakeenScouts._createDefault(color, false, true, options, handler)
end

function ArrakeenScouts._createTreachery2(color)
    local options = {}
    local spice = PlayBoard.getResource(color, "spice")
    local amounts = {}
    for i = 0, spice:get() do
        table.insert(amounts, i)
    end
    Helper.shuffle(amounts)
    for _, amount in ipairs(amounts) do
        table.insert(options, tostring(amount) .. " spice")
    end
    local function handler(_, option)
        local index = Helper.indexOf(options, option)
        local amount = amounts[index]
        ArrakeenScouts.auctions[color] = {
            value = amount,
            solver = function (ranking)
                if Helper.tableContains(ranking[1], color) then
                    Action.resources(color, "spice", -amount)
                    Action.drawIntrigues(color, 2)
                elseif Helper.tableContains(ranking[2], color) and #ranking[1] == 1 then
                    Action.resources(color, "solari", -amount)
                    Action.drawIntrigues(color, 1)
                end
            end
        }
    end
    return ArrakeenScouts._createDefault(color, false, true, options, handler)
end

function ArrakeenScouts._createToTheHighestBidder1(color)
    local options = {}
    local solari = PlayBoard.getResource(color, "solari")
    local amounts = {}
    for i = 0, solari:get() do
        table.insert(amounts, i)
    end
    Helper.shuffle(amounts)
    for _, amount in ipairs(amounts) do
        table.insert(options, tostring(amount) .. " solari")
    end
    local function handler(_, option)
        local index = Helper.indexOf(options, option)
        local amount = amounts[index]
        ArrakeenScouts.auctions[color] = {
            value = amount,
            solver = function (ranking)
                if Helper.tableContains(ranking[1], color) then
                    Action.resources(color, "solari", -amount)
                    Action.drawImperiumCards(color, 1)
                end
            end
        }
    end
    return ArrakeenScouts._createDefault(color, false, true, options, handler)
end

function ArrakeenScouts._createToTheHighestBidder2(color)
    local options = {}
    local solari = PlayBoard.getResource(color, "solari")
    local amounts = {}
    for i = 0, solari:get() do
        table.insert(amounts, i)
    end
    Helper.shuffle(amounts)
    for _, amount in ipairs(amounts) do
        table.insert(options, tostring(amount) .. " solari")
    end
    local function handler(_, option)
        local index = Helper.indexOf(options, option)
        local amount = amounts[index]
        ArrakeenScouts.auctions[color] = {
            value = amount,
            solver = function (ranking)
                if Helper.tableContains(ranking[1], color) then
                    Action.resources(color, "solari", -amount)
                    Action.drawImperiumCards(color, 2)
                elseif Helper.tableContains(ranking[2], color) and #ranking[1] == 1 then
                    Action.resources(color, "solari", -amount)
                    Action.drawImperiumCards(color, 1)
                end
            end
        }
    end
    return ArrakeenScouts._createDefault(color, false, true, options, handler)
end

function ArrakeenScouts._createCompetitiveStudy1(color)
    return ArrakeenScouts._createCompetitiveStudy(color, 1)
end

function ArrakeenScouts._createCompetitiveStudy2(color)
    return ArrakeenScouts._createCompetitiveStudy(color, 2)
end

function ArrakeenScouts._createCompetitiveStudy(color, level)
    local options = {}
    local solari = PlayBoard.getResource(color, "solari")
    local amounts = {}
    for i = 0, solari:get() do
        table.insert(amounts, i)
    end
    Helper.shuffle(amounts)
    for _, amount in ipairs(amounts) do
        table.insert(options, tostring(amount) .. " solari")
    end
    local function handler(_, option)
        local index = Helper.indexOf(options, option)
        local amount = amounts[index]
        ArrakeenScouts.auctions[color] = {
            value = amount,
            solver = function (ranking)
                if Helper.tableContains(ranking[1], color) then
                    Action.resources(color, "solari", -amount)
                    Action.troops(color, "supply", "specimen", 1)
                    return ArrakeenScouts._ensureResearch(color)
                elseif #ranking[1] == 1 and Helper.tableContains(ranking[2], color) and level == 2 then
                    Action.resources(color, "solari", -amount)
                    return ArrakeenScouts._ensureResearch(color)
                end
            end
        }
    end
    return ArrakeenScouts._createDefault(color, false, true, options, handler)
end

--- Events ---

function ArrakeenScouts._createChangeOfPlans(color)
    local options = { "Refuser", "Accepter" }
    local function handler(_, option)
        local index = Helper.indexOf(options, option)
        if index == 2 then
            local continuation = Helper.createContinuation()
            ArrakeenScouts._ensureDiscard(color).doAfter(function ()
                Action.drawImperiumCards(color, 1)
                continuation.run()
            end)
            return continuation
        end
        return nil
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

function ArrakeenScouts._createCovertOperation(color)
    local options = {
        "+2 solari dans 1 manche",
        "+1 Empereur dans 1 manche",
        "+1 Guilde Spatiale dans 1 manche",
        "+1 Bene Gesserit dans 1 manche",
        "+1 Fremens dans 1 manche",
        "+2 épice dans 2 manches",
        "+2 Empereur dans 2 manches",
        "+2 Guilde Spatiale dans 2 manches",
        "+2 Bene Gesserit dans 2 manches",
        "+2 Fremens dans 2 manches",
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

function ArrakeenScouts._createGiftOfWater(color)
    local options = { "Refuser" }
    local water = PlayBoard.getResource(color, "water")
    if water:get() >= 1 then
        table.insert(options, "Accepter")
    end
    local function handler(_, option)
        local index = Helper.indexOf(options, option)
        if index == 2 then
            Action.acquireArrakisLiaisonCard(color)
        end
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

function ArrakeenScouts._createDesertGift(color)
    local options = { "Passer" }
    local notAStarterCard = Helper.negate(ImperiumCard.isStarterCard)
    local notStarterCards = Helper.filter(PlayBoard.getHandCards(color), notAStarterCard)
    if #notStarterCards > 0 then
        table.insert(options, "Défausser")
    end
    local function handler(_, option)
        local index = Helper.indexOf(options, option)
        if index == 2 then
            local continuation = Helper.createContinuation()
            ArrakeenScouts._ensureDiscard(color, notAStarterCard).doAfter(function ()
                Action.influence(color, "fremen", 1)
                continuation.run()
            end)
            return continuation
        end
        return nil
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

function ArrakeenScouts._createGuildNegotiation(color)
    local options = { "Passer" }
    local solari = PlayBoard.getResource(color, "solari")
    if solari:get() >= 2 then
        table.insert(options, "Accepter")
    end
    local function handler(_, option)
        local index = Helper.indexOf(options, option)
        if index == 2 then
            Action.resources(color, "solari", -2)
            Action.influence(color, "spacingGuild", 1)
        end
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

function ArrakeenScouts._createIntriguingGift(color)
    local options = { "Passer" }
    local intrigues = PlayBoard.getIntrigues(color)
    if #intrigues > 0 then
        table.insert(options, "Accepter")
    end
    local function handler(_, option)
        local index = Helper.indexOf(options, option)
        if index == 2 then
            ArrakeenScouts._ensureDiscardIntrigue(color).doAfter(function ()
                Action.influence(color, "beneGesserit", 1)
            end)
        end
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

function ArrakeenScouts._createTestOfLoyalty(color)
    local options = { "Passer" }
    local garissonPark = MainBoard.getGarrisonPark(color)
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
    local garrisonPark = MainBoard.getGarrisonPark(color)
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

function ArrakeenScouts._createTreachery_immortality(color)
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
        MainBoard.addSpaceBonus("researchStation", { all = { "intrigue", "intrigue" } })
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
            MainBoard.addSpaceBonus("researchStation", { [color] = { troops[1], troops[2] } })
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
            MainBoard.addSpaceBonus("secrets", { [color] = { Park.getAnyObject(supplyPark), "solari", "solari" } })
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
            MainBoard.addSpaceBonus("foldspace", { [color] = { troops[1], troops[2] } })
        end
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

function ArrakeenScouts._createSpiceIncentive(color, isFirstPlayer)
    if isFirstPlayer then
        MainBoard.addSpaceBonus("rallyTroops", { all = { "solari", "solari" } })
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
            MainBoard.addSpaceBonus("rallyTroops", { [color] = { Park.getAnyObject(supplyPark) } })
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
                    MainBoard.addSpaceBonus("mentat", { [color] = { controlMarker, "spice" } })
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
    return ArrakeenScouts._createDefault(color, false, false, nil, function ()
        local dreadnoughtPark = PlayBoard.getDreadnoughtPark(color)
        if not Park.isEmpty(dreadnoughtPark) then
            MainBoard.addSpaceBonus("dreadnought", { [color] = { Park.getAnyObject(dreadnoughtPark), "spice" } })
        end
    end)
end

function ArrakeenScouts._createSecretStash(color, isFirstPlayer)
    if isFirstPlayer then
        MainBoard.addSpaceBonus("smuggling", { all = { "spice", "spice" } })
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
            MainBoard.addSpaceBonus("smuggling", { [color] = { troops[1], troops[2] } })
        end
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

function ArrakeenScouts._createBackstageAgreement(color, isFirstPlayer)
    if isFirstPlayer then
        TleilaxuRow.addAcquireBonus({ all = { "solari", "solari" } })
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
            MainBoard.addSpaceBonus("conspire", { [color] = { Park.getAnyObject(tankPark), "solari", "solari" } })
        end
    end
    return ArrakeenScouts._createDefault(color, false, false, options, handler)
end

function ArrakeenScouts._createSponsoredResearch(color, isFirstPlayer)
    if isFirstPlayer then
        TleilaxuResearch.addSpaceBonus("oneHelix", { all = { "solari", "solari" } })
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
            TleilaxuResearch.addSpaceBonus(3, { [color] = { troops[1], troops[2] } })
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

---
function ArrakeenScouts._ensureDiscard(color, predicate)
    local continuation = Helper.createContinuation()

    local oldDiscardedCards = Set.newFromList(PlayBoard.getDiscardedCards(color))

    local function getNewlyDiscardedCards()
        local newDiscardedCards = Set.newFromList(PlayBoard.getDiscardedCards(color))
        local newlyDiscardedCards = newDiscardedCards - oldDiscardedCards
        if predicate then
            newlyDiscardedCards = Helper.filter(newlyDiscardedCards, predicate)
        end
        return newlyDiscardedCards
    end

    Wait.condition(function()
        continuation.run(getNewlyDiscardedCards()[1])
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
    local intrigue = nil
    continuation.run(intrigue)
    log("TODO ArrakeenScouts._ensureDiscardIntrigue")
    return continuation
end

---
function ArrakeenScouts._ensureResearch(color)
    local continuation = Helper.createContinuation()
    continuation.run()
    log("TODO ArrakeenScouts._ensureResearch")
    return continuation
end

return ArrakeenScouts
