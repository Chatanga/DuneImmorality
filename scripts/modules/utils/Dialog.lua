local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

--[[
    Provide an abstraction to show dialogs to the users as well as an alternate
    and nicer implementation relying on the XML UI.
]]
local Dialog = {
    -- Internal flag to revert to the native dialogs.
    nativeDialogUsed = false,
    -- Set to true once the static UI part has been loaded and not to be changed later.
    staticDialogUsedLoaded = false,
}

--[[
    A wrapper on 'broadcastToColor' to switch 'broadcastToAll'
    in case the target player is a bot or not seated.
]]
function Dialog.broadcastToColor(message, playerColor, messageColor)
    assert(message)
    assert(playerColor)
    local player = Helper.findPlayerByColor(playerColor)
    if player and player.seated then
        broadcastToColor(message, playerColor, messageColor)
    else
        broadcastToAll(I18N("forwardMessage", { color = I18N(playerColor), message = message }), messageColor)
    end
end

--[[
    To work around the limitations of TTS regarding any kind of dynamic content,
    this function is to be called as soon as possible to generate and register a
    set of static dialogs in the global UI. Instances for up to 5 options are
    created. When needed, the proper version will be updated and displayed.
    
    Note that calling this function is not mandatory, but the old behavior of
    creating XML content on the fly is not reliable in general (on the guest
    side at least).
]]
function Dialog.loadStaticUI()
    local xmlRoots = UI.getXmlTable()
    local options = {}
    local techOptions = {}
    for i = 1, 5 do
        table.insert(options, "option" .. tostring(i))
        table.insert(xmlRoots, Dialog._generateDialogUI(nil, nil, nil, options, nil))
        table.insert(techOptions, {
            name = "techOption" .. tostring(i),
            url = "techOptionUrl" .. tostring(i),
        })
        table.insert(xmlRoots, Dialog._generateDialogUI(nil, nil, "tech_", techOptions, nil))
    end
    UI.setXmlTable(xmlRoots)
    Dialog.staticDialogUsedLoaded = true
    -- 10 instead of just 1, better be safe than sorry.
    return Helper.onceFramesPassed(10)
end

---@param color string The color of the player to show the dialogue to.
---@param message string The message to be displayed.
function Dialog.showInfoDialog(color, message)
    if Dialog.nativeDialogUsed then
        Player[color].showInfoDialog(message)
    else
        local options = {
            I18N("ok"),
        }
        Dialog._showOptionsAndCancelDialog(color, message, options, function (_) end)
    end
end

---@param color string The color of the player to show the dialogue to.
---@param message string The message to be displayed.
---@param callback function Called without arguments on "ok" (but not "cancel").
function Dialog.showConfirmDialog(color, message, callback)
    assert(callback)
    if Dialog.nativeDialogUsed then
        Player[color].showConfirmDialog(message, function ()
            callback()
        end)
    else
        local options = {
            I18N("ok"),
            I18N("cancel"),
        }
        Dialog._showOptionsAndCancelDialog(color, message, options, function (index)
            if index == 1 then
                callback()
            end
        end)
    end
end

---@param color string The color of the player to show the dialogue to.
---@param message string The message to be displayed.
---@param linkedContinuation? table An optional continuation to be forgotten (only useful when using a native dialog).
---@param callback function Called with a boolean arguments ("ok" -> true, "cancel" -> false).
function Dialog.unused_showConfirmOrCancelDialog(color, message, linkedContinuation, callback)
    assert(callback)
    if Dialog.nativeDialogUsed then
        if linkedContinuation then
            linkedContinuation.forget()
        end
        Player[color].showConfirmDialog(message, function ()
            callback(true)
        end)
    else
        local options = {
            I18N("ok"),
            I18N("cancel"),
        }
        Dialog._showOptionsAndCancelDialog(color, message, options, function (index)
            callback(index == 1)
        end)
    end
end

---@param color string The color of the player to show the dialogue to.
---@param message string The message to be displayed.
---@param linkedContinuation? table An optional continuation to be forgotten (only useful when using a native dialog).
---@param callback function Called with a boolean arguments ("yes" -> true, "no/cancel" -> false).
function Dialog.showYesOrNoDialog(color, message, linkedContinuation, callback)
    assert(callback)
    if Dialog.nativeDialogUsed then
        if linkedContinuation then
            linkedContinuation.forget()
        end
        Player[color].showConfirmDialog(message, function ()
            callback(true)
        end)
    else
        local options = {
            I18N("yes"),
            I18N("no"),
        }
        Dialog._showOptionsAndCancelDialog(color, message, options, function (index)
            callback(index == 1)
        end)
    end
end

---@param color string The color of the player to show the dialogue to.
---@param message string The message to be displayed.
---@param options string[] One or more options to choose among.
---@param linkedContinuation? table An optional continuation to be forgotten (only useful when using a native dialog).
---@param callback function Called with an index arguments ("option #n" -> n) if not canceled.
function Dialog.showOptionsDialog(color, message, options, linkedContinuation, callback)
    assert(options)
    assert(#options > 0)
    assert(callback)
    if Dialog.nativeDialogUsed then
        if linkedContinuation then
            linkedContinuation.forget()
        end
        Player[color].showOptionsDialog(message, options, 1, function (_, index, _)
            callback(index)
        end)
    else
        Dialog._showOptionsAndCancelDialog(color, message, options, function (index)
            if index > 0 then
                callback(index)
            end
        end)
    end
end

---@param color string The color of the player to show the dialogue to.
---@param message string The message to be displayed.
---@param options string[] One or more options to choose among.
---@param linkedContinuation? table An optional continuation to be forgotten (only useful when using a native dialog).
---@param callback function Called with an index arguments ("option #n" -> n, cancel -> 0).
function Dialog.showOptionsAndCancelDialog(color, message, options, linkedContinuation, callback)
    assert(options)
    assert(#options > 0)
    assert(callback)
    if Dialog.nativeDialogUsed then
        if linkedContinuation then
            linkedContinuation.forget()
        end
        Player[color].showOptionsDialog(message, options, 1, function (_, index, _)
            callback(index)
        end)
    else
        Dialog._showOptionsAndCancelDialog(color, message, options, callback)
    end
end

function Dialog._showOptionsAndCancelDialog(color, message, options, callback)
    if Dialog.staticDialogUsedLoaded and Dialog._checkExistence(nil, options) then
        Dialog._bindStaticUI(color, message, nil, options, callback)
    else
        local ui = Dialog._generateDialogUI(color, message, nil, options, callback)
        UI.setXmlTable({ ui })
    end
end

--[[
    Show a cancelable option dialog for Kota Odax where each option is a tech tile.
]]
---@param color string The color of the player to show the dialogue to.
---@param message string The message to be displayed.
---@param urls string[] One or more options to choose among as URLs to tech tile images.
---@param callback function Called with an index arguments ("option #n" -> n, cancel -> 0).
function Dialog.showTechOptionsDialog(color, message, urls, callback)
    if Dialog.staticDialogUsedLoaded and Dialog._checkExistence(nil, urls) then
        Dialog._bindStaticUI(color, message, "tech_", urls, callback)
    else
        local ui = Dialog._generateDialogUI(color, message, "tech_", urls, callback)
        UI.setXmlTable({ ui })
    end
end

--[[
    Update and show the proper UI pane previously registered by 'loadStaticUI'.
]]
---@param color string
---@param message string
---@param prefix? string
---@param options string[] | table[]
---@param callback function
function Dialog._bindStaticUI(color, message, prefix, options, callback)
    assert(options)
    local dialogId = Dialog._dialogId(prefix, options)

    UI.setAttribute(dialogId, "active", true)
    UI.setAttribute(dialogId, "visibility", color)
    UI.setValue(Dialog._messageId(prefix, options), message)

    local closingCallback = Dialog._createClosingCallback(prefix, options, function (...)
        UI.setAttribute(dialogId, "active", false)
        callback(...)
    end)

    local cancelButtonId = Dialog._cancelButtonId(prefix, options)
    UI.setAttribute(cancelButtonId, "onClick", Helper.registerGlobalCallback(function (player)
        closingCallback(0)
    end))

    for i, option in ipairs(options) do
        local optionButtonId = Dialog._optionButtonId(prefix, options, i)
        if prefix == "tech_" then
            UI.setAttribute(optionButtonId, "image", option.url)
        else
            -- Using the "text" attribute instead of the value is necessary here (that's weird).
            UI.setAttribute(optionButtonId, "text", option)
        end
        UI.setAttribute(optionButtonId, "onClick", Helper.registerGlobalCallback(function (player)
            closingCallback(i)
        end))
    end
end

--[[
    Check that a UI pane with the corresponding number of options is available
    (registered by loadStaticUI').
]]
function Dialog._checkExistence(prefix, options)
    assert(options)
    assert(#options > 0)
    local dialogId = Dialog._dialogId(prefix, options)
    local color = UI.getAttribute(dialogId, "color")
    return color and type(color) == "string" and color:len() > 0
end

function Dialog._dialogId(prefix, options)
    assert(options)
    assert(#options > 0)
    return (prefix or "") .. "dialogWith" .. tostring(#options) .. "Options"
end

function Dialog._messageId(prefix, options)
    assert(options)
    assert(#options > 0)
    return Dialog._dialogId(prefix, options) .. "Message"
end

function Dialog._cancelButtonId(prefix, options)
    assert(options)
    assert(#options > 0)
    return Dialog._dialogId(prefix, options) .. "CancelButton"
end

function Dialog._optionButtonId(prefix, options, index)
    assert(options)
    assert(#options > 0)
    return Dialog._dialogId(prefix, options) .. "OptionButton" .. tostring(index)
end

function Dialog._generateDialogUI(color, message, prefix, options, callback)
    assert(options)

    local closingCallback
    if callback then
        closingCallback = Dialog._createClosingCallback(prefix, options, function (...)
            UI.setXmlTable({{}})
            callback(...)
        end)
    end

    local cancelButton = Dialog._createCancelButton(prefix, options, closingCallback)

    local optionButtons = {}
    for i, option in ipairs(options) do
        table.insert(optionButtons, Dialog._createOptionButton(prefix, options, i, option, closingCallback))
    end

    local height = 95 + 50 * #optionButtons * (prefix == "tech_" and 3 or 1) + 35

    local ui = {
        tag = "Panel",
        attributes = {
            visibility = color,
            position = 0,
            width = 440,
            height = height,
            color = "#30281f",
            id = Dialog._dialogId(prefix, options),
            outline = "#8c794b",
            outlineSize = 1,
            active = closingCallback ~= nil,
            allowDragging = true,
            returnToOriginalPositionWhenReleased = false,
        },
        children = {
            {
                tag = "VerticalLayout",
                children = {
                    {
                        tag = "Image",
                        attributes = {
                            ignoreLayout = "True",
                            height = "120",
                            position="0 " .. tostring((height - 120) / 2 - 20),
                            color = "#544a33",
                            preserveAspect = true,
                            raycastTarget = true,
                        },
                    },
                    {
                        tag = "HorizontalLayout",
                        children = {
                            {
                                tag = "Text",
                                attributes = {
                                    preferredWidth = 400,
                                },
                            },
                            cancelButton,
                            {
                                tag = "Text",
                                attributes = {
                                    preferredWidth = 10,
                                },
                            }
                        }
                    },
                    {
                        tag = "VerticalLayout",
                        attributes = {
                            padding = "10 10 10 10",
                        },
                        children = {
                            {
                                tag = "Text",
                                attributes = {
                                    id = Dialog._messageId(prefix, options),
                                    preferredWidth = 415,
                                    preferredHeight = 40,
                                    color = "#deaf00",
                                    resizeTextForBestFit = true,
                                    resizeTextMaxSize = "24",
                                },
                                value = message,
                            },
                            {
                                tag = "VerticalLayout",
                                attributes = {
                                    childAlignment = "MiddleCenter",
                                    padding = "10 10 10 10",
                                    spacing = "10",
                                },
                                children = optionButtons
                            }
                        }
                    }
                }
            }
        }
    }

    return ui
end

function Dialog._createClosingCallback(prefix, options, callback)
    assert(options)
    assert(#options > 0)
    return function (index)
        local cancelButtonId = Dialog._cancelButtonId(prefix, options)
        Helper.unregisterGlobalCallback(UI.getAttribute(cancelButtonId, "onClick"))
        for i, _ in ipairs(options) do
            local optionButtonId = Dialog._optionButtonId(prefix, options, i)
            Helper.unregisterGlobalCallback(UI.getAttribute(optionButtonId, "onClick"))
        end
        callback(index)
    end
end

function Dialog._createCancelButton(prefix, options, closingCallback)
    local button = {
        tag = "Button",
        attributes = {
            id = Dialog._cancelButtonId(prefix, options),
            fontSize = "12",
            fontStyle = "Bold",
            outlineSize = "1 1",
            preferredWidth = 35,
            preferredHeight = 15,
            color = "#8c794b",
        },
        value = "X",
    }

    if closingCallback then
        button.attributes.onClick = Helper.registerGlobalCallback(function (player)
            closingCallback(0)
        end)
    end

    return button
end

function Dialog._createOptionButton(prefix, options, index, option, closingCallback)
    assert(index > 0)

    local container
    local button

    if prefix == "tech_" then
        button = {
            tag = "Image",
            attributes = {
                id = Dialog._optionButtonId(prefix, options, index),
                padding = "5 5 5 5",
                image = option.url,
                preserveAspect = "True",
                preferredHeight = "100",
            }
        }
        container = {
            tag = "VerticalLayout",
            attributes = {
                preferredHeight = "100",
            },
            children = { button }
        }
    else
        button = {
            tag = "Button",
            attributes = {
                id = Dialog._optionButtonId(prefix, options, index),
                color = "#8c794b",
                padding = "5 5 5 5",
                resizeTextForBestFit = true,
                resizeTextMaxSize = "18",
            },
            -- Using the "text" attribute would work as well.
            value = option,
        }
        container = button
    end

    if closingCallback then
        button.attributes.onClick = Helper.registerGlobalCallback(function (player)
            closingCallback(index)
        end)
    end

    return container
end

return Dialog
