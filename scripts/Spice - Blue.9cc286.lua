resource = require("Resource")

_ = require("Core").registerLoadablePart(function(savedData)
    resource.init("Blue", "spice", 0, savedData)
end)