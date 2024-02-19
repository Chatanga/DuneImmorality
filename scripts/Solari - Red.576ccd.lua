resource = require("Resource")

_ = require("Core").registerLoadablePart(function(savedData)
    resource.init("Red", "solari", 0, savedData)
end)
