startEndTurnModule = require("StartEndTurnModule")

_ = require("Core").registerLoadablePart(function(saved_data)
  startEndTurnModule.init('Yellow')
end)
