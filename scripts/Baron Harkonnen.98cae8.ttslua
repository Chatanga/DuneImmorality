leader = require("Leader")

_ = require("Core").registerLoadablePart(function(savedData)
    leader.init(onClaim, savedData)
end)

function onClaim(color)
    local baron_bag = getObjectFromGUID("f89231")
    baron_bag.randomize()
    baron_bag.deal(4, color)
    Wait.time(function() baron_bag.destruct() end, 2)
end
