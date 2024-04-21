local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

local Dialog = {
    nativeDialogUsed = false,
    staticDialogUsed = false,
}

---
function Dialog.loadStaticUI()
    local xmlRoots = UI.getXmlTable()
    local options = {}
    for i = 1, 5 do
        table.insert(options, "option" .. tostring(i))
        local ui = Dialog._generateDialogUI(nil, nil, options, nil)
        table.insert(xmlRoots, ui)
    end
    UI.setXmlTable(xmlRoots)
    Dialog.staticDialogUsed = true
    -- 10 instead of just 1, better be safe than sorry.
    return Helper.onceFramesPassed(10)
end

---
function Dialog.showInfoDialog(color, title)
    if Dialog.nativeDialogUsed then
        Player[color].showInfoDialog(title)
    else
        local options = {
            I18N("ok"),
        }
        Dialog._showOptionsAndCancelDialog(color, title, options, function (_) end)
    end
end

---
function Dialog.showConfirmDialog(color, title, callback)
    if Dialog.nativeDialogUsed then
        Player[color].showConfirmDialog(title, function ()
            callback()
        end)
    else
        local options = {
            I18N("ok"),
            I18N("cancel"),
        }
        Dialog._showOptionsAndCancelDialog(color, title, options, function (index)
            if index == 1 then
                callback()
            end
        end)
    end
end

---
function Dialog.showConfirmOrCancelDialog(color, title, linkedContinuation, callback)
    if Dialog.nativeDialogUsed then
        if linkedContinuation then
            linkedContinuation.forget()
        end
        Player[color].showConfirmDialog(title, function ()
            callback(true)
        end)
    else
        local options = {
            I18N("ok"),
            I18N("cancel"),
        }
        Dialog._showOptionsAndCancelDialog(color, title, options, function (index)
            callback(index == 1)
        end)
    end
end

---
function Dialog.showYesOrNoDialog(color, title, linkedContinuation, callback)
    if Dialog.nativeDialogUsed then
        if linkedContinuation then
            linkedContinuation.forget()
        end
        Player[color].showConfirmDialog(title, function ()
            callback(true)
        end)
    else
        local options = {
            I18N("yes"),
            I18N("no"),
        }
        Dialog._showOptionsAndCancelDialog(color, title, options, function (index)
            callback(index == 1)
        end)
    end
end

---
function Dialog.showOptionsDialog(color, title, options, linkedContinuation, callback)
    assert(options)
    assert(#options > 0)
    if Dialog.nativeDialogUsed then
        if linkedContinuation then
            linkedContinuation.forget()
        end
        Player[color].showOptionsDialog(title, options, 1, function (_, index, _)
            callback(index)
        end)
    else
        Dialog._showOptionsAndCancelDialog(color, title, options, function (index)
            if index > 0 then
                callback(index)
            end
        end)
    end
end

---
function Dialog.showOptionsAndCancelDialog(color, title, options, linkedContinuation, callback)
    assert(options)
    assert(#options > 0)
    if Dialog.nativeDialogUsed then
        if linkedContinuation then
            linkedContinuation.forget()
        end
        Player[color].showOptionsDialog(title, options, 1, function (_, index, _)
            callback(index)
        end)
    else
        Dialog._showOptionsAndCancelDialog(color, title, options, callback)
    end
end

---
function Dialog._showOptionsAndCancelDialog(color, title, options, callback)
    if Dialog.staticDialogUsed and Dialog._checkExistence(options) then
        Dialog._bindStaticUI(color, title, options, callback)
    else
        local ui = Dialog._generateDialogUI(color, title, options, callback)
        UI.setXmlTable({ ui })
    end
end

---
function Dialog._bindStaticUI(color, title, options, callback)
    local dialogId = Dialog._dialogId(options)

    UI.setAttribute(dialogId, "active", true)
    UI.setAttribute(dialogId, "visibility", color)
    UI.setValue(Dialog._titleId(options), title)

    local closingCallback = Dialog._createClosingCallback(options, function (...)
        UI.setAttribute(dialogId, "active", false)
        callback(...)
    end)

    local cancelButtonId = Dialog._cancelButtonId(options)
    UI.setAttribute(cancelButtonId, "onClick", Helper.registerGlobalCallback(function (player)
        closingCallback(0)
    end))

    for i, option in ipairs(options) do
        local optionButtonId = Dialog._optionButtonId(options, i)
        -- Using the "text" attribute instead of the value is necessary here (that's weird).
        UI.setAttribute(optionButtonId, "text", option)
        UI.setAttribute(optionButtonId, "onClick", Helper.registerGlobalCallback(function (player)
            closingCallback(i)
        end))
    end
end

---
function Dialog._checkExistence(options)
    local dialogId = Dialog._dialogId(options)
    local color = UI.getAttribute(dialogId, "color")
    return color and type(color) == "string" and color:len() > 0
end

---
function Dialog._dialogId(options)
    return "dialogWith" .. tostring(#options) .. "Options"
end
---
function Dialog._titleId(options)
    return Dialog._dialogId(options) .. "Title"
end

---
function Dialog._cancelButtonId(options)
    return Dialog._dialogId(options) .. "CancelButton"
end

---
function Dialog._optionButtonId(options, index)
    return Dialog._dialogId(options) .. "OptionButton" .. tostring(index)
end

---
function Dialog._createClosingCallback(options, callback)
    return function (index)
        local cancelButtonId = Dialog._cancelButtonId(options)
        Helper.unregisterGlobalCallback(UI.getAttribute(cancelButtonId, "onClick"))
        for i, _ in ipairs(options) do
            local optionButtonId = Dialog._optionButtonId(options, i)
            Helper.unregisterGlobalCallback(UI.getAttribute(optionButtonId, "onClick"))
        end
        callback(index)
    end
end

---
function Dialog._generateDialogUI(color, title, options, callback)

    local closingCallback
    if callback then
        closingCallback = Dialog._createClosingCallback(options, function (...)
            UI.setXmlTable({{}})
            callback(...)
        end)
    end

    local cancelButton = Dialog._createCancelButton(options, closingCallback)

    local optionButtons = {}
    for i, label in ipairs(options) do
        table.insert(optionButtons, Dialog._createOptionButton(options, i, label, closingCallback))
    end

    local height = 95 + 50 * #optionButtons + 35

    local ui = {
        tag = "Panel",
        attributes = {
            visibility = color,
            position = 0,
            width = 440,
            height = height,
            color = "#30281f",
            id = Dialog._dialogId(options),
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
                            ignoreLayout="True",
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
                                    id = Dialog._titleId(options),
                                    preferredWidth = 415,
                                    preferredHeight = 40,
                                    color = "#deaf00",
                                    resizeTextForBestFit = true,
                                    resizeTextMaxSize = "24",
                                },
                                value = title,
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

---
function Dialog._createCancelButton(options, closingCallback)
    local button = {
        tag = "Button",
        attributes = {
            id = Dialog._cancelButtonId(options),
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

---
function Dialog._createOptionButton(options, index, label, closingCallback)
    assert(index > 0)

    local button = {
        tag = "Button",
        attributes = {
            id = Dialog._optionButtonId(options, index),
            color = "#8c794b",
            padding = "5 5 5 5",
            resizeTextForBestFit = true,
            resizeTextMaxSize = "18",
        },
        -- Using the "text" attribute would work as well.
        value = label,
    }

    if closingCallback then
        button.attributes.onClick = Helper.registerGlobalCallback(function (player)
            closingCallback(index)
        end)
    end

    return button
end

---
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

return Dialog
