local Helper = require("utils.Helper")

---@class Set
---@field elements any[]
local Set = Helper.createClass()

---@return Set
function Set.unused_empty()
    return Set.newFromList({})
end

---@param ... any
---@return Set
function Set.newFromItems(...)
    local data = {
        elements = {}
    }
    for _, element in ipairs({...}) do
        data.elements[element] = true
    end
    return Helper.createClassInstance(Set, data)
end

---@param elements any[]
---@return Set
function Set.newFromList(elements)
    local data = {
        elements = {}
    }
    for _, element in ipairs(elements) do
        data.elements[element] = true
    end
    return Helper.createClassInstance(Set, data)
end

---@param elements table<any, any>
---@return Set
function Set.unused_newFromSet(elements)
    local data = {
        elements = {}
    }
    if elements then
        for element, _ in pairs(elements) do
            data.elements[element] = true
        end
    end
    return Helper.createClassInstance(Set, data)
end

---@param set? Set
---@return Set
function Set.new(set)
    local data = {
        elements = {}
    }
    if set then
        for element, _ in pairs(set.elements) do
            data.elements[element] = true
        end
    end
    return Helper.createClassInstance(Set, data)
end

---@return integer
function Set:size()
    return #self:toList()
end

---@param set Set
---@return Set
function Set:union(set)
    local newSet = Set.new(self)
    for element, _ in pairs(set.elements) do
        newSet:add(element)
    end
    return newSet
end

---@param set Set
---@return Set
function Set:subtraction(set)
    assert(set)
    local newSet = Set.new()
    for element, _ in pairs(self.elements) do
        if not set.elements[element] then
            newSet:add(element)
        end
    end
    return newSet
end

---@param set Set
---@return Set
function Set:intersection(set)
    assert(set)
    local newSet = Set.new()
    for element, _ in pairs(self.elements) do
        if set.elements[element] then
            newSet:add(element)
        end
    end
    return newSet
end

---@param set Set
---@return boolean
function Set:isSupersetOf(set)
    assert(set)
    for element, _ in pairs(set.elements) do
        if not self.elements[element] then
            return false
        end
    end
    return true
end

---@param set Set
---@return boolean
function Set:isSubsetOf(set)
    assert(set)
    for element, _ in pairs(self.elements) do
        if not set.elements[element] then
            return false
        end
    end
    return true
end

---@param element any
---@return boolean
function Set:contains(element)
    assert(element)
    return self.elements[element]
end

---@param element any
---@return boolean
function Set:add(element)
    assert(element)
    if not self.elements[element] then
        self.elements[element] = true
        return true
    else
        return false
    end
end

---@param element any
---@return boolean
function Set:remove(element)
    assert(element)
    if self.elements[element] then
        self.elements[element] = nil
        return true
    else
        return false
    end
end

---@param f fun(x: any): any
---@return Set
function Set:map(f)
    local newSet = Set.new()
    for element, _ in pairs(self.elements) do
        local notAnInjection = newSet:add(f(element))
        assert(notAnInjection)
    end
    return newSet
end

---@param p fun(x: any): boolean
---@return Set
function Set:filter(p)
    local newSet = Set.new()
    for element, _ in pairs(self.elements) do
        if p(element) then
            local success = newSet:add(element)
            assert(success)
        end
    end
    return newSet
end

---@return any[]
function Set:toList()
    local list = {}
    for element, _ in pairs(self.elements) do
        table.insert(list, element)
    end
    return list
end

---@return string
function Set:toString()
    local str = "{"
    local first = true
    for element, _ in pairs(self.elements) do
        if first then
            first = false
        else
            str = str .. ", "
        end
        str = str .. tostring(element)
    end
    str = str .. "}"
    return str
end

Set.__len = Set.size
Set.__add = Set.union
Set.__sub = Set.subtraction
Set.__pow = Set.intersection
Set.__ge = Set.isSupersetOf
Set.__le = Set.isSubsetOf
Set.__gt = function (a, b) return Set.isSupersetOf(a, b) and not Set.isSubsetOf(b, a) end
Set.__lt = function (a, b) return Set.isSubsetOf(a, b) and not Set.isSupersetOf(b, a) end
Set.__tostring = Set.toString

return Set
