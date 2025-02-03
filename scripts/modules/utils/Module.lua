local Module = {
    modulesByName = {},
    registeredModuleRedirections = {},
}

---@param modulesByName table<string, table>
---@return table<string, table>
function Module.registerModules(modulesByName)
    Module.modulesByName = Module._registerModules("", modulesByName)
    return Module._lazyRequireAll("", modulesByName)
end

---@param path string
---@param modulesByName table<string, table>
---@return table<string, table>
function Module._registerModules(path, modulesByName)
    local modules = {}

    for name, node in pairs(modulesByName) do
        -- FIXME Can’t work! Find a way to distinguish between a node and a module.
        if type(node) == "table" and false then
            modules[name] = Module._registerModules(path .. name .. ".", node)
        else
            modules[name] = node
        end
    end

    return modules
end

---@param path string
---@param modulesByName table<string, table>
---@return table<string, table>
function Module._lazyRequireAll(path, modulesByName)
    local modules = {}

    for name, node in pairs(modulesByName) do
        -- FIXME Can’t work! Find a way to distinguish between a node and a module.
        if type(node) == "table" and false then
            modules[name] = Module._lazyRequireAll(path .. name .. ".", node)
        else
            modules[name] = Module.lazyRequire(name)
        end
    end

    return modules
end

---@param name string
---@return table
function Module.lazyRequire(name)
    local lazyModule = {}

    local meta = {
        module = nil
    }
    meta.__index = function (_, key)
        if not meta.module then
            meta.module = Module._resolveModule(name)
        end
        if meta.module then
            local item = meta.module[key]
            if item then
                if type(item) ~= "function" then
                    if key ~= "__loaded" then
                        log("Accessing inner field: " .. name .. "." .. key .. " (" .. type(item) .. ")")
                    end
                elseif key == "onLoad" then
                    meta.module.__loaded = true
                elseif key:sub(1, 1) == "_" then
                    log("Accessing private function: " .. name .. "." .. key)
                elseif not meta.module.__loaded and meta.module['onLoad'] ~= nil then
                    log("Accessing unloaded module: " .. name .. "." .. key)
                end
            end
            return item
        else
            log("Unresolvable module: " .. name .. " (while accessing: " .. key .. ")")
            return nil
        end
    end

    -- Necessary redirection when used as a class.
    lazyModule.__index = lazyModule

    setmetatable(lazyModule, meta)

    return lazyModule
end

---@param name string
---@return table?
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

---@param functionNames string[]
function Module.registerModuleRedirections(functionNames)
    for _, functionName in ipairs(functionNames) do
        local originalGlobalFunction = Global.getVar(functionName)
        local globalFunction = function (...)
            if originalGlobalFunction then
                originalGlobalFunction(...)
            end
            for _, module in pairs(Module.modulesByName) do
                if module[functionName] then
                    module[functionName](...)
                end
            end
        end
        local safeGlobalFunction = function (...)
            local ran, ret = pcall(globalFunction, ...)
            if not ran then
                log(tostring(ret) .. "(error in redirection '" .. functionName .. "')")
            end
            return ret
        end
        Module.registeredModuleRedirections[functionName] = safeGlobalFunction
        Global.setVar(functionName, safeGlobalFunction)
    end
end

---@param functionName string
---@param ... any
function Module.callOnAllRegisteredModules(functionName, ...)
    for _, module in pairs(Module.modulesByName) do
        if module[functionName] then
            module[functionName](...)
        end
    end
end

function Module.unregisterAllModuleRedirections()
    for functionName, _ in pairs(Module.registeredModuleRedirections) do
        Global.setVar(functionName, function (...)
        end)
    end
end

return Module
