resource = require("Resource")

_ = require("Core").registerLoadablePart(function(savedData)
    resource.init(nil, "spice", 0, savedData)
end)