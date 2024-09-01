local Helper = require("utils.Helper")
local I18N = require("utils.I18N")

local XmlUI = Helper.createClass()

---
function XmlUI.new(holder, id, fields)
    --[[
        Important:
            UI.setXmlTable(xml)
            assert(UI.getXmlTable() == xml) -- Not Ok
            -- Wait at least 1 frame.
            assert(UI.getXmlTable() == xml) -- Ok

        Changes made  directly by the user (e.g. checking a box)
        won't be reflected in the retrieved XML though.
    ]]
    local xmlUI = Helper.createClassInstance(XmlUI, {
        holder = holder,
        xml = holder.UI.getXmlTable(),
        id = id,
        active = false,
        fields = fields
    })
    xmlUI:toUI()
    return xmlUI
end

---
function XmlUI:show()
    self.active = true
    self:toUI()
    --self.holder.UI.show(self.id)
end

---
function XmlUI:hide()
    self.active = false
    self:toUI()
    --self.holder.UI.hide(self.id)
end

---
function XmlUI:setButton(id, label, interactable)
    local element = XmlUI._findXmlElement(self.xml, id)
    assert(element, "Unknown id: " .. tostring(id))
    XmlUI._setXmlButton(element, label)
    XmlUI._setXmlInteractable(element, interactable)
end

---
function XmlUI:setButtonI18N(id, key, interactable)
    local element = XmlUI._findXmlElement(self.xml, id)
    assert(element, "Unknown id: " .. tostring(id))
    XmlUI._setXmlButtonI18N(element, key)
    XmlUI._setXmlInteractable(element, interactable)
end

---
function XmlUI:fromUI(player, value, id)
    local values = self:_getEnumeration(id)
    if values then
        for key, knownValue in pairs(values) do
            if value == I18N(knownValue) then
                self.fields[id] = key
                return
            end
        end
    elseif value == "False" or value == "True" then
        local on = value == "True"
        self.fields[id] = on
        return
    else
        self.fields[id] = value
        return
    end
    error("Unknown value: " .. tostring(value))
end

function XmlUI:toUI()
    local root =  XmlUI._findXmlElement(self.xml, self.id)
    assert(root, "Unknown id: " .. tostring(self.id))
    root.attributes.active = self.active
    for name, value in pairs(self.fields) do
        if not XmlUI._isEnumeration(name) and not XmlUI._isRange(name) then
            local element = XmlUI._findXmlElement(self.xml, name)
            if element then
                if XmlUI._isActive(value) then
                    local values = self:_getEnumeration(name)
                    local range = self:_getRange(name)
                    if values then
                        XmlUI._setXmlDropdownOptions(element, values, value)
                    elseif range then
                        XmlUI._setXmlSlider(element, range, value)
                    elseif element.tag == "Toggle" then
                        XmlUI._setXmlToggle(element, value)
                    elseif element.tag == "Text" then
                        XmlUI._setXmlText(element, value)
                    end
                    XmlUI._setXmlInteractable(element, true)
                else
                    XmlUI._setXmlInteractable(element, false)
                end
            else
                --log("Unknown id: " .. tostring(name))
            end
        end
    end
    XmlUI._translateContent(self.xml)
    self.holder.UI.setXmlTable(self.xml)
end

---
function XmlUI._isEnumeration(name)
    return name:sub(-4) == "_all"
end

---
function XmlUI:_getEnumeration(name)
    return self.fields[name .. "_all"]
end

---
function XmlUI._isRange(name)
    return name:sub(-6) == "_range"
end

---
function XmlUI:_getRange(name)
    return self.fields[name .. "_range"]
end

---
function XmlUI._isActive(value)
    return type(value) ~= "table" or #table > 0
end

---
function XmlUI._findXmlElement(xml, id)
    for _, element in ipairs(xml) do
        if element.attributes and element.attributes.id == id then
            return element
        elseif element.children then
            local hit = XmlUI._findXmlElement(element.children, id)
            if hit then
                return hit
            end
        end
    end
    return nil
end

---
function XmlUI._setXmlDropdownOptions(dropdown, optionValues, default)
    assert(dropdown)
    assert(dropdown.tag == "Dropdown", dropdown.tag)
    assert(dropdown.children)
    assert(#dropdown.children > 0)
    local protoOption = dropdown.children[1]
    dropdown.children = {}
    for key, optionValue in pairs(optionValues) do
        local option = Helper.deepCopy(protoOption)
        option.attributes.selected = key == default
        option.attributes.key = optionValue
        option.value = I18N(optionValue)
        table.insert(dropdown.children, option)
    end
end

---
function XmlUI._setXmlText(text, value)
    assert(text)
    assert(text.tag == "Text", text.tag)
    text.value = value
end

---
function XmlUI._setXmlToggle(toggle, on)
    assert(toggle)
    assert(toggle.tag == "Toggle", toggle.tag)
    toggle.attributes.isOn = XmlUI._toBool(on)
end

---
function XmlUI._setXmlSlider(slider, range, value)
    assert(slider)
    assert(slider.tag == "Slider", slider.tag)
    slider.attributes.minValue = range.min
    slider.attributes.maxValue = range.max
    slider.attributes.value = value
end

---
function XmlUI._setXmlButton(button, label)
    assert(button)
    assert(button.tag == "Button", button.tag)
    button.value = label
end

---
function XmlUI._setXmlButtonI18N(button, key)
    assert(button)
    assert(button.tag == "Button", button.tag)
    button.attributes.key = key
end

---
function XmlUI._setXmlActive(xml, active)
    assert(xml)
    xml.attributes.active = XmlUI._toBool(active)
end

---
function XmlUI._setXmlInteractable(xml, interactable)
    assert(xml)
    if xml.tag == "Dropdown" or xml.tag == "Slider" then
        -- FIXME Bidouille esthétique.
        xml.attributes.active = XmlUI._toBool(interactable)
    else
        xml.attributes.interactable = XmlUI._toBool(interactable)
    end
end

---
function XmlUI._translateContent(xml)
    for _, element in ipairs(xml) do
        XmlUI._translate(element)
    end
end

---
function XmlUI._translate(node)
    if node.attributes then
        if node.attributes.key then
            node.value = I18N(node.attributes.key)
        end
        -- Tooltip popups are disabled for now sice they tend
        -- to hang around after their widget has been removed.
        if node.attributes.tooltipKey and false then
            node.attributes.tooltip = I18N(node.attributes.tooltipKey)
        end
    end
    if node.children then
        for _, child in ipairs(node.children) do
            XmlUI._translate(child)
        end
    end
end

---
function XmlUI._toBool(value)
    return value and "True" or "False"
end

return XmlUI
