local Module = {
    modulesByName = {}
}

---
function Module.registerModules(modulesByName)
    Module.modulesByName = Module._registerModules("", modulesByName)
    return Module._lazyRequireAll("", modulesByName)
end

---
function Module._registerModules(path, modulesByName)
    local modules = {}

    for name, node in pairs(modulesByName) do
        -- Can’t work! Find a way to distinguish between a node and a module.
        if type(node) == "table" and false then
            modules[name] = Module._registerModules(path .. name .. ".", node)
        else
            modules[name] = node
        end
    end

    return modules
end

---
function Module._lazyRequireAll(path, modulesByName)
    local modules = {}

    for name, node in pairs(modulesByName) do
        -- Can’t work! Find a way to distinguish between a node and a module.
        if type(node) == "table" and false then
            modules[name] = Module._lazyRequireAll(path .. name .. ".", node)
        else
            modules[name] = Module.lazyRequire(name)
        end
    end

    return modules
end

---
function Module.lazyRequire(name)
    local lazyModule = {}

    local meta = {
        module = nil
    }
    meta.__index = function(_, key)
        if not meta.module then
            meta.module = Module._resolveModule(name)
        end
        if meta.module then
            local item = meta.module[key]
            if item and type(item) ~= "function" then
                log("Accessing inner field: " .. name .. "." .. key .. " (" .. type(item) .. ")")
            end
            return item
        else
            log("Unresolvable module: " .. name .. " (while accessing: " .. key .. ")")
            return nil
        end
    end

    -- When used as a class.
    lazyModule.__index = lazyModule

    setmetatable(lazyModule, meta)

    return lazyModule
end

---
function Module._resolveModule(name)
    local node = Module.modulesByName

    local selector = name
    while true do
        local nextSelector = nil
        local dotIndex = selector:find(".", 1, true)
        if dotIndex then
            selector = selector:sub(1, dotIndex - 1)
            nextSelector = selector:sub(dotIndex + 1)
        end
        node = node[selector]
        if node then
            if not nextSelector then
                return node
            else
                selector = nextSelector
            end
        else
            return nil
        end
    end
end

---
function Module.registerModuleRedirections(functionNames)
    for _, functionName in ipairs(functionNames) do
        local originalGlobalFunction = Global.getVar(functionName)
        Global.setVar(functionName, function (...)
            if originalGlobalFunction then
                originalGlobalFunction()
            end
            for _, module in pairs(Module.modulesByName) do
                if module[functionName] then
                    module[functionName](...)
                end
            end
        end)
    end
end

---
function Module.redirect(functionName, ...)
    for _, module in pairs(Module.modulesByName) do
        if module[functionName] then
            module[functionName](...)
        end
    end
end

return Module
