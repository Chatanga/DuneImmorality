leader = require("Leader")

_ = require("Core").registerLoadablePart(function(savedData)
    leader.init(onClaim, savedData)
end)

function onClaim(color)
    for _, obj in pairs(getAllObjects()) do
        local stealthColor = {1, 1, 1, 0.33}
        if color=="Blue" then
            stealthColor = {0.12156862745, 0.5294117647, 1, 0.33}
        elseif color=="Red" then
            stealthColor = {1, 0, 0, 0.33}
        elseif color=="Green" then
            stealthColor = {0, 1, 0, 0.33}
        elseif color=="Yellow" then
            stealthColor = {1, 1, 0, 0.33}
        end
        if obj.getName() == color.." Agent" or obj.getName() == color.." Swordmaster" then
            obj.setColorTint(stealthColor)
        end
    end
end