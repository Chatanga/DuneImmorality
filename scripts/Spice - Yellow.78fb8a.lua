resource = require("Resource")

_ = require("Core").registerLoadablePart(function(savedData)
    resource.init("Yellow", "spice", 0, savedData)
end)