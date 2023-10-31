leader = require("Leader")

helperModule = require("HelperModule")

_ = require("Core").registerLoadablePart(function(savedData)
    leader.init(onClaim, savedData)
end)

function onClaim(color)
    local beneTleilaxBoard = getObjectFromGUID("d5c2db")
    for i = 1, 2 do
        Wait.time(
            function()
                beneTleilaxBoard.call("moveBeneTleilaxToken", color)
            end,
            i - 1)
    end
end
