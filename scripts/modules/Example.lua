--[[
    Not a real module, simply a documented example/template.
]]

-- Modules in "utils" are generic and could be reused outside this mod.
-- In particualar, they don't depend on other mmodules outide "utils".
local Module = require("utils.Module")
local Helper = require("utils.Helper")

-- The "lazyRequire" main benefit is to allow circular dependencies
-- between applicative modules, providing more freedom to break down
-- the mod into smaller parts. The obvious constraint is to not used
-- a lazy dependencies too soon (in the "onLoad" method) or in a
-- strict order.
local OtherModule = Module.lazyRequire("OtherModule")

local Example = {
    something = nil
}

--- Explictely called by the Global "onLoad" function.
function Example.onLoad(state)
    Helper.dumpFunction("Example.onLoad", state)

    -- "Helper.resolveGUIDs" is typically used in the "onLoad" function to find
    -- objects. For are a game mod, not a reusable scripted content, it is fine.
    Example.content = Helper.resolveGUIDs(false, {
        someZone = "23f2b5"
    })

    if state.settings then
        Example.something = state.Example.something
        -- Reapply all the transient changes made in the set up.
        Example._transientSetUp(state.settings)
    end
end

--- Explictely called by the Global "onSave" function.
function Example.onSave(state)
    -- state is the global saved state. Each module is expected to store its
    -- data in its own space. Reusing the module name is the simplest solution.
    state.Example = {
        something = Example.something,
    }
end

--- Explictely called by Global when the game is set up.
function Example.setUp(settings)

    -- All changes which will need to be reapplied on reload should be isolated
    -- in a "_transientSetUp" function also used by the "onLoad" function.
    Example._transientSetUp(settings)
end

function Example._transientSetUp(settings)
    -- A typical things done here is torecreate the transient anchor and their
    -- associated content (park, button, etc.). Event handlers using dynamic
    -- callbacks also need to be recreated.

    Helper.createTransientAnchor("ExampleButton", Vector(0, 0.5, 0)).doAfter(function (anchor)
        Example.anchor = anchor
        local zone = Example.content.someZone

        local snapPoint = Helper.createRelativeSnapPointFromZone(anchor, zone, true)
        anchor.setSnapPoints({ snapPoint })

        Example.callbackNme = Helper.registerGlobalCallback(function (...)
            Helper.dump("Click once:", ...)

            -- Same as "Example.anchor.removeButtons()", except when a dynamic
            -- callback is found. In this case, the callbck is also unregistered.
            Helper.removeButtons(Example.anchor)
            -- The function above already takes care of removing any dynamic callback.
            Helper.unregisterGlobalCallback(Example.callbackNme)
        end)

        anchor.createButton({
            label = "A button",
            callback = Example.callbackNme
        })
    end)

    Example.connectionListener = function (...)
        Helper.dump("Connection event:", ...)

        -- For the record, that's how you unregister a listener.
        Helper.unregisterEventListener("connection", Example.connectionListener)
    end

    Helper.registerEventListener("connection", Example.connectionListener)
end

--- TTS event handler.
--- This event is never used in this mod where all the scripts are put in Global.
function onDestroy()
    -- Transient objects such as anchors are destroyed at the beginning of the
    -- Global "onLoad" function.
end

--- TTS event handler.
function onPlayerConnect(...)
    -- Any event handler declared as such in Global is forwarded in all modules
    -- providing the callback.

    -- The Helper module provide an event mechanism relying on the pair
    -- "emitEvent" / "registerEventListener".
    Helper.emitEvent("connection", ...)
end

return Example
