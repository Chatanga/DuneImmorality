resource = require("Resource")

_ = require("Core").registerLoadablePart(function(savedData)
    resource.init("Green", "water", 1, savedData)
end)