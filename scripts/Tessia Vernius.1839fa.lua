leader = require("Leader")

constants = require("Constants")

_ = require("Core").registerLoadablePart(function(savedData)
    leader.init(onClaim, savedData)

    Stillsuits = "556f43"
    HardyWarriors = "a2fd8e"
    Secrets = "1f7c08"
    SelectiveBreeding = "7dc6e5"
    Foldspace = "9a9eb5"
    Heighliner = "8b0515"
    Wealth = "b2c461"
    Conspire = "cd9386"

    snoopers = {
        { guid = "a58ce8", position = getAveragePosition({Conspire, Wealth})},
        { guid = "857f74", position = getAveragePosition({Heighliner, Foldspace})},
        { guid = "bed196", position = getAveragePosition({SelectiveBreeding, Secrets})},
        { guid = "b10897", position = getAveragePosition({HardyWarriors, Stillsuits})}
    }
end)

function getAveragePosition(guids)
    local p = Vector(0, 0, 0)
    local count = 0
    for _, guid in ipairs(guids) do
        local object = getObjectFromGUID(guid)
        p = p + object.getPosition()
        count = count + 1
    end
    return p * (1 / count)
end

function onClaim(color)
    local snapPoints = {}
    for i, snooper in ipairs(snoopers) do
        local object = getObjectFromGUID(snooper.guid)
        object.setPositionSmooth(snooper.position, false, false)
        object.setRotationSmooth(Vector(0, 90, 0))
        Wait.time(function ()
            object.setLock(true)
        end, 3)

        local p = constants.leaderPos[color] + Vector(i / 4 - 2, 0, 1.4 - i / 2)
        table.insert(snapPoints, {
            position = self.positionToLocal(p),
            tags = { "Snooper" }
        })
    end
    self.setSnapPoints(snapPoints)
end