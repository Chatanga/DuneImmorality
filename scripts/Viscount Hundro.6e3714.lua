leader = require("Leader")

_ = require("Core").registerLoadablePart(function(savedData)
    leader.init(onClaim, savedData)
end)

function onClaim(color)
    getObjectFromGUID(constants.intrigue_base).deal(2, color)
end