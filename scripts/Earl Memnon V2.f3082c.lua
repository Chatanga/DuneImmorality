leader = require("Leader")

_ = require("Core").registerLoadablePart(function(savedData)
    leader.init(nil, savedData)
end)