local Helper = require("utils.Helper")

local Action = Helper.lazyRequire("Action")

local Leader = {}

---
function Leader.new(card)
    local leader = Helper.newInheritingObject(Action, Leader, {
        card = card
    })

    return leader
end

return Leader
