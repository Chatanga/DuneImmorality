resource = require("Resource")

_ = require("Core").registerLoadablePart(function(savedData)
    resource.init("Yellow", "water", 1, savedData)
end)