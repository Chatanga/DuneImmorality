local Module = require("utils.Module")
local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

local TurnControl = Module.lazyRequire("TurnControl")
local PlayBoard = Module.lazyRequire("PlayBoard")

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
            secretHideout = true,
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
            if round == 1 then
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
    local contents = ArrakeenScouts.selectedContent[round - 1]
    if #contents > 0 then
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
    local leaderNames = {}
    for _, color in ipairs(PlayBoard.getPlayBoardColors()) do
        leaderNames[color] = PlayBoard.getLeaderName(color)
    end

    ArrakeenScouts.turnSequence = TurnControl.getPhaseTurnSequence()
    ArrakeenScouts.widgets = {}

    local handler = ArrakeenScouts[Helper.toCamelCase("_handle", content)]
    if not handler then
        handler = function (color)
            local options = { "Perdre de l’épice", "Perdre de l’influence" }
            return ArrakeenScouts._handleDefault(color, true, false, nil)
        end
    end

    local playerMiniUIs = {}
    for _, color in ipairs({"Red", "Green", "Blue", "Yellow"}) do
        local leaderName = leaderNames[color]
        local playerUI = ArrakeenScouts._createPlayerUI(handler, color, leaderName)
        table.insert(playerMiniUIs, playerUI)
    end

    local image = ArrakeenScouts[I18N.getLocale()][content]
    assert(image, "Unknow Arrakeen Scouts content: " .. content)
    log(image)

    ArrakeenScouts.ui = ArrakeenScouts._createDialogUI(image, playerMiniUIs)

    UI.setXmlTable({ ArrakeenScouts.ui })
end

---
function ArrakeenScouts._createPlayerUI(handler, color, leaderName)
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
                        handler(color)
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
function ArrakeenScouts._handleDefault(color, sequential, secret, options)
    local widget = {}
    if not sequential or color == ArrakeenScouts.turnSequence[1] then
        ArrakeenScouts._mutateAsButton(widget, sequential, color)
    else
        ArrakeenScouts._mutateAsText(widget, false)
    end

    ArrakeenScouts.widgets[color] = widget

    if secret and options then
        options = Helper.shallowCopy(options)
        Helper.shuffle(options)
    end

    local children
    if options then
        local dropdown = {
            tag = "Dropdown",
            attributes = {
                flexibleWidth = 100,
            },
            children = Helper.map(options, function (i, option)
                return {
                    tag = "Option",
                    attributes = {
                        selected = i == 1,
                    },
                    value = option
                }
            end)
        }
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
    widget.value = "OK"

    widget.attributes.onClick = Helper.registerGlobalCallback(function (player)
        if player.color == color then
            Helper.unregisterGlobalCallback(widget.attributes.onClick)
            ArrakeenScouts.widgets[color] = nil
            ArrakeenScouts._mutateAsText(widget, true)

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

            UI.setXmlTable({ ArrakeenScouts.ui })
        end
    end)
end

---
function ArrakeenScouts._mutateAsText(widget, done)
    widget.tag = "Text"
    widget.attributes = {
        fontSize = "40",
        color = "#FFFFFF",
        preferredWidth = 40,
        preferredHeight = 40,
    }
    widget.value = done and "✓" or "✗"
end

---
function ArrakeenScouts._done()
   log("Terminé.")
    Wait.time(function ()
        UI.setXmlTable({{}})
        ArrakeenScouts._nextContent()
    end, 1)
end

return ArrakeenScouts
