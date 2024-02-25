leader = require("Leader")

constants = require("Constants")

_ = require("Core").registerLoadablePart(function(savedData)
    leader.init(onClaim, savedData)
end)

function onClaim(color)
    local player = constants.players[color]
    player.spice.call("incrementVal")
    player.solari.call("incrementVal")
end