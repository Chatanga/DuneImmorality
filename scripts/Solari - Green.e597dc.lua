resource = require("Resource")

_ = require("Core").registerLoadablePart(function(savedData)
    resource.init("Green", "solari", 0, savedData)
end)