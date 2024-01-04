local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

local Dialog = {
    nativeDialogUsed = false
}

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
function Dialog.showOptionsDialog(color, title, options, callback)
    assert(options)
    assert(#options > 0)
    if Dialog.nativeDialogUsed then
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

    local cancelButtons = {}
    local optionButtons = {}

    local closingCallback = function (index)
        Helper.unregisterGlobalCallback(cancelButtons[1].attributes.onClick)
        for _, button in ipairs(optionButtons) do
            Helper.unregisterGlobalCallback(button.attributes.onClick)
        end
        UI.setXmlTable({{}})
        callback(index)
    end

    cancelButtons = { Dialog._createCancelButton(closingCallback) }

    for i, label in ipairs(options) do
        table.insert(optionButtons, Dialog._createOptionButton(i, label, closingCallback))
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
            id = "dialogPane",
            outline = "#8c794b",
            outlineSize = 1,
            active = true,
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
                            cancelButtons[1],
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
    UI.setXmlTable({ ui })
end

---
function Dialog._createCancelButton(callback)
    local button = {
        tag = "Button",
        attributes = {
            fontSize = "12",
            fontStyle = "Bold",
            outlineSize = "1 1",
            preferredWidth = 35,
            preferredHeight = 15,
            color = "#8c794b",
        },
        value = "X",
    }

    button.attributes.onClick = Helper.registerGlobalCallback(function (player)
        callback(0)
    end)

    return button
end

---
function Dialog._createOptionButton(index, label, callback)
    assert(index > 0)

    local button = {
        tag = "Button",
        attributes = {
            color = "#8c794b",
            padding = "5 5 5 5",
            resizeTextForBestFit = true,
            resizeTextMaxSize = "18",
        },
        value = label,
    }

    button.attributes.onClick = Helper.registerGlobalCallback(function (player)
        callback(index)
    end)

    return button
end

return Dialog
