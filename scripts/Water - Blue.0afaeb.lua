resource = require("Resource")

_ = require("Core").registerLoadablePart(function(savedData)
    resource.init("Blue", "water", 1, savedData)
end)