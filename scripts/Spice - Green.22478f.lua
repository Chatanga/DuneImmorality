resource = require("Resource")

_ = require("Core").registerLoadablePart(function(savedData)
    resource.init("Green", "spice", 0, savedData)
end)