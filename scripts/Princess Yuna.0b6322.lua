leader = require("Leader")

constants = require("Constants")

_ = require("Core").registerLoadablePart(function(savedData)
    leader.init(onClaim, savedData)
end)

function onClaim(color)
    constants.players[color].water.call("resetVal")
end