resource = require("Resource")

_ = require("Core").registerLoadablePart(function(savedData)
    resource.init(nil, "spice", 2, savedData)
end)