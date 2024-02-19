leader = require("Leader")

helperModule = require("HelperModule")

_ = require("Core").registerLoadablePart(function(savedData)
    leader.init(onClaim, savedData)
end)

function onClaim(color)
    helperModule.landTroopsFromOrbit(color, 12) -- Troops in excess won't be deployed.
end
