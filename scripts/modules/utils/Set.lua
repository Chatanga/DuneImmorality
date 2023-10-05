local Helper = require("utils.Helper")

local Set = Helper.createClass()

function Set.newFromItems(...)
    local data = {
        elements = {}
    }
    for _, element in ipairs({...}) do
        data.elements[element] = true
    end
    return Helper.createClassInstance(Set, data)
end

function Set.newFromList(elements)
    local data = {
        elements = {}
    }
    for _, element in ipairs(elements) do
        data.elements[element] = true
    end
    return Helper.createClassInstance(Set, data)
end

function Set.newFromSet(elements)
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

function Set:size()
    return #self:toList()
end

function Set:union(set)
    local newSet = Set.new(self)
    for element, _ in pairs(set.elements) do
        newSet:add(element)
    end
    return newSet
end

function Set:soustraction(set)
    assert(set)
    local newSet = Set.new()
    for element, _ in pairs(self.elements) do
        if not set.elements[element] then
            newSet:add(element)
        end
    end
    return newSet
end

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

function Set:isSupersetOf(set)
    assert(set)
    for element, _ in pairs(set.elements) do
        if not self.elements[element] then
            return false
        end
    end
    return true
end

function Set:isSubsetOf(set)
    assert(set)
    for element, _ in pairs(self.elements) do
        if not set.elements[element] then
            return false
        end
    end
    return true
end

function Set:contains(element)
    assert(element)
    return self.elements[element]
end

function Set:add(element)
    assert(element)
    if not self.elements[element] then
        self.elements[element] = true
        return true
    else
        return false
    end
end

function Set:remove(element)
    assert(element)
    if self.elements[element] then
        self.elements[element] = nil
        return true
    else
        return false
    end
end

function Set:map(f)
    local newSet = Set.new()
    for element, _ in pairs(self.elements) do
        local notAnInjection = newSet:add(f(element))
        assert(notAnInjection)
    end
    return newSet
end

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

function Set:toList()
    local list = {}
    for element, _ in pairs(self.elements) do
        table.insert(list, element)
    end
    return list
end

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
Set.__sub = Set.soustraction
Set.__pow = Set.intersection
Set.__ge = Set.isSupersetOf
Set.__le = Set.isSubsetOf
Set.__gt = function (a, b) return Set.isSupersetOf(a, b) and not Set.isSubsetOf(b, a) end
Set.__lt = function (a, b) return Set.isSubsetOf(a, b) and not Set.isSupersetOf(b, a) end
Set.__tostring = Set.toString

return Set
