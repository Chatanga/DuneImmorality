startEndTurnModule = {}

-- Static constants
startEndTurnModule.thisColor = nil
startEndTurnModule.offseat = "White" -- An unseated color; Teal and Brown are usually safe
startEndTurnModule.confirmForce = false
startEndTurnModule.lockout = false

--Runs on load, creates button and makes sure the startEndTurnModule.lockout is off
function startEndTurnModule.init(color)
    startEndTurnModule.thisColor = color
    self.createButton({
        label = "Color Changer",
        click_function = "changeColor",
        function_owner = self,
        position = {0, 0.25, 0},
        height = 1400,
        width = 1400
    })
    self.setColorTint(startEndTurnModule.thisColor)
end

--Function run when button is pressed
function changeColor(_, clicked_color, alt_click)
    local currentColor = Player.getPlayers()[1].color
    local desc = self.getDescription()

    -- Button animation
    if not startEndTurnModule.lockout then
        self.AssetBundle.playTriggerEffect(0) --triggers animation/sound
        startEndTurnModule.lockout = true --locks out the button
        startEndTurnModule.lockoutTimer() --Starts up a timer to remove startEndTurnModule.lockout
    end

    if alt_click then
        -- Not a left-click, so change the startEndTurnModule.offseat player for this button
        broadcastToAll("startEndTurnModule.offseat for " .. startEndTurnModule.thisColor .. " button changed to " .. clicked_color, startEndTurnModule.thisColor)
        startEndTurnModule.offseat = clicked_color
    else
        -- Left-click, perform the player swap
        if desc == nil or desc == '' then
            desc = startEndTurnModule.thisColor .. " Seat"
        end

        if currentColor==startEndTurnModule.offseat then
            startEndTurnModule.changePlayer(currentColor, startEndTurnModule.thisColor)
            broadcastToAll("Now Playing: " .. desc, startEndTurnModule.thisColor)
        elseif currentColor==startEndTurnModule.thisColor then
            startEndTurnModule.changePlayer(currentColor, startEndTurnModule.offseat)
            broadcastToAll(desc .. " ended their turn", startEndTurnModule.thisColor)
        elseif startEndTurnModule.confirmForce then
            startEndTurnModule.changePlayer(currentColor, startEndTurnModule.thisColor)
            broadcastToAll("Now Playing: " .. desc .. "     (Switched from " .. currentColor .. " Seat)", startEndTurnModule.thisColor)
            startEndTurnModule.confirmForce = false
        else
            broadcastToAll(currentColor .. " is still playing! Please end their turn first, or click again to force a turn change.", "Grey")
            startEndTurnModule.confirmForce = true
        end
    end
end

function startEndTurnModule.changePlayer(currentColor, newColor)
  Player[currentColor].changeColor(newColor)
  Global.call("onPlayerTurn", Player[newColor])
end

-- Original button timer functions

-- Starts a timer that, when it ends, will unlock the button
function startEndTurnModule.lockoutTimer()
    Timer.create({
        identifier = self.getGUID(),
        function_name = 'lockout',
        delay = 0.5
    })
end

-- Unlocks button
function lockout()
    startEndTurnModule.lockout = false
end

-- Ends the timer if the object is destroyed before the timer ends, to prevent an error
function onDestroy()
    Timer.destroy(self.getGUID())
end

return startEndTurnModule
