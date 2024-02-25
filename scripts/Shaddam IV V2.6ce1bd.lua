leader = require("Leader")

boardCommon = require("BoardCommonModule")

_ = require("Core").registerLoadablePart(function(savedData)
    leader.init(onClaim, savedData)
end)

function onClaim(color)
    local t = 0
    for faction, _ in pairs(pion_reput) do
        for _ = 1, 4 do
            Wait.time(
                function()
                    boardCommon.ReputationUp(color, faction)
                end, t)
            t = t + 1
        end
    end
end