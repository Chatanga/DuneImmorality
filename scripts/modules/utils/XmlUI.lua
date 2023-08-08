local Helper = require("utils.Helper")

local XmlUI = {}

---
function XmlUI.new(holder, id, fields)
    local xmlUI = Helper.newObject(XmlUI, {
        holder = holder,
        xml = holder.UI.getXmlTable(), -- Why the retrieved XML is always stale (even after some time)?
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
    local element = XmlUI.findXmlElement(self.xml, id)
    assert(element, "Unknown id: " .. id)
    XmlUI.setXmlButton(element, label)
    XmlUI.setXmlInteractable(element, interactable)
end

---
function XmlUI:toUI()
    local root =  XmlUI.findXmlElement(self.xml, self.id)
    assert(root, "Unknown id: " .. self.id)
    root.attributes.active = self.active
    for name, value in pairs(self.fields) do
        if not XmlUI.isEnumeration(name) then
            local element = XmlUI.findXmlElement(self.xml, name)
            assert(element, "Unknown id: " .. name)
            if XmlUI.isActive(value) then
                local values = self:getEnumeration(name)
                if values then
                    XmlUI.setXmlDropdownOptions(element, values, value)
                else
                    XmlUI.setXmlToggle(element, value)
                end
                XmlUI.setXmlInteractable(element, true)
            else
                XmlUI.setXmlInteractable(element, false)
            end
        end
    end
    self.holder.UI.setXmlTable(self.xml)
end

---
function XmlUI.isEnumeration(name)
    return name:sub(-4) == "_all"
end

---
function XmlUI:getEnumeration(name)
    return self.fields[name .. "_all"]
end

---
function XmlUI.isActive(value)
    return type(value) ~= "table" or #table > 0
end

---
function XmlUI.findXmlElement(xml, id)
    for _, element in ipairs(xml) do
        if element.attributes and element.attributes.id == id then
            return element
        elseif element.children then
            local hit = XmlUI.findXmlElement(element.children, id)
            if hit then
                return hit
            end
        end
    end
    return nil
end

---
function XmlUI.setXmlDropdownOptions(dropdown, optionValues, default)
    assert(dropdown)
    assert(dropdown.tag == "Dropdown")
    assert(dropdown.children)
    assert(#dropdown.children > 0)
    local protoOption = dropdown.children[1]
    dropdown.children = {}
    for key, optionValue in pairs(optionValues) do
        local option = Helper.deepCopy(protoOption)
        option.attributes.selected = key == default
        option.value = optionValue
        table.insert(dropdown.children, option)
    end
end

---
function XmlUI.setXmlToggle(toggle, on)
    assert(toggle)
    assert(toggle.tag == "Toggle")
    toggle.attributes.isOn = on and "True" or "False"
end

---
function XmlUI.setXmlButton(button, label)
    assert(button)
    assert(button.tag == "Button")
    button.value = label
end

---
function XmlUI.setXmlActive(xml, active)
    assert(xml)
    xml.attributes.active = active and "True" or "False"
end

---
function XmlUI.setXmlInteractable(xml, interactable)
    assert(xml)
    if xml.tag == "Dropdown" then
        -- TODO Bidouille esthétique.
        xml.attributes.active = interactable and "True" or "False"
    else
        xml.attributes.interactable = interactable and "True" or "False"
    end
end

---
function XmlUI:fromUI(player, value, id)
    local values = self:getEnumeration(id)
    if values then
        for key, knownValue in pairs(values) do
            if value == knownValue then
                self.fields[id] = key
                return
            end
        end
    else
        local on = value == "True"
        self.fields[id] = on
        return
    end
    assert(false)
end

return XmlUI