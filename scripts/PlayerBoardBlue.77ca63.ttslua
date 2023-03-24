playerBoardModule = require("PlayerBoardModule")

_ = require("Core").registerLoadablePart(function(saved_data)
    playerBoardModule.init('Blue', Vector(-27.5, 1, -6.4), saved_data)
end)

function getOrbitPark()
    return playerBoardModule.orbitPark
end

function getTechPark()
    return playerBoardModule.techPark
end

function getScorePark()
    return playerBoardModule.scorePark
end

function getScore()
    return playerBoardModule.score
end

function onObjectEnterScriptingZone(zone, enter_object)
    playerBoardModule.onObjectEnterScriptingZone(zone, enter_object)
end

function onObjectLeaveScriptingZone(zone, enter_object)
    playerBoardModule.onObjectLeaveScriptingZone(zone, enter_object)
end

function shutdown(parameters)
    local riseOfIxEnabled = parameters[1] == 1
    local immortalityEnabled = parameters[2] == 1
    playerBoardModule.shutdown(riseOfIxEnabled, immortalityEnabled)
end
