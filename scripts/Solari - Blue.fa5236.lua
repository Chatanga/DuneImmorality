resource = require("Resource")

_ = require("Core").registerLoadablePart(function(savedData)
    resource.init("Blue", "solari", 0, savedData)
end)