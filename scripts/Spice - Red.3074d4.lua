resource = require("Resource")

_ = require("Core").registerLoadablePart(function(savedData)
    resource.init("Red", "spice", 0, savedData)
end)