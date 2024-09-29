--COLOUR SHUFFLER SCRIPT
--DEVELOPED BY MARKIMUS ON STEAM

adminOnlyButton = true
selectColour = {0.3, 1, 0.3}
textColour = {0.5, 0.5, 0.5}

_ = require("Core").registerLoadablePart(function()
    local buttonParams = {}
    buttonParams.function_owner = self
    buttonParams.click_function = "shufflePlayers"
    --buttonParams.label = "Shuffle\nPlayers"
    buttonParams.width = 700
    buttonParams.height = 700
    buttonParams.font_size = 300
    buttonParams.position = {0, 0, 0}
    self:createButton(buttonParams)
end)

function shuffleTable(tab)
    --print("Shuffle Table called.")
    for i = 1, #tab * 2 do
        local a = math.random(#tab)
        local b = math.random(#tab)
        tab[a], tab[b] = tab[b], tab[a]
    end
    return tab
end

shufflePlayersDebounce = false

function shufflePlayers(object, colour)
    if shufflePlayersDebounce == true then return end
    if adminOnlyButton == true and Player[colour].admin == false then return end
    if #getSeatedPlayers() < 2 then printToAll("Shuffle Players: [808080]".. Player[colour].steam_name ..", there must be more than one player for shuffling to work.", textColour) return end
    if Player["Black"].seated == true then printToAll("Please remove Player Black for shuffling to work.", textColour) return end
    shufflePlayersDebounce = true

    local deselectColour = self:getColorTint()

    self:setColorTint(selectColour)

    printToAll("Shuffle Players: ".. Player[colour].steam_name .. " initiated shuffling.", textColour)

    local ranColours = {}

    --INSERT THE COLOURS

    for _, v in pairs(getSeatedPlayers()) do
        table.insert(ranColours, v)
    end

    shuffleTable(ranColours)

    seatedPlayers = {}
    for i, v in pairs(getSeatedPlayers()) do
        seatedPlayers[v] = {}
        seatedPlayers[v].target = ranColours[i]
        seatedPlayers[v].myColour = v
        --printToAll(Player[v].steam_name .. "(".. v ..") -> ".. ranColours[i], {1, 1, 1})
        if seatedPlayers[v].target == v then
            seatedPlayers[v].prevMoved = true
            seatedPlayers[v].moved = true
        else
            seatedPlayers[v].prevMoved = false
            seatedPlayers[v].moved = false
        end
    end

    --START SHUFFLING PLAYERS.

    function shuffleDelay()

        for timeout = 1, 50 do

            --GO THROUGH SEATED PLAYERS. IF THEY HAVEN'T MOVED, CHECK IF THEY CAN BE MOVED.
            for i, v in pairs(seatedPlayers) do
                --print("Test")
                if v.moved == false then
                    if Player[v.target].seated == false then
                        local myC = v.myColour
                        if Player[myC].seated == true then
                            --print("Moving player ".. myC)
                            Player[myC]:changeColor(v.target)
                            while Player[myC].seated == true and Player[v.target].seated == false do
                                coroutine.yield()
                            end
                            v.myColour = v.target
                            v.moved = true
                        else
                            table.remove(seatedPlayers, i)
                        end
                    end
                end
            end

            local checkIfSame = true
            for _, v in pairs(seatedPlayers) do
                if v.prevMoved ~= v.moved then
                    checkIfSame = false
                    break
                end
            end

            if checkIfSame == true then
                --print("Is same.")
                local allNonMovedPlayers = {}
                for i, v in pairs(seatedPlayers) do
                    if v.moved == false then
                        table.insert(allNonMovedPlayers, v)
                    end
                end

                if #allNonMovedPlayers ~= 0 then
                    local lastPlayer = allNonMovedPlayers[#allNonMovedPlayers]
                    Player[lastPlayer.myColour]:changeColor("Black")
                    lastPlayer.myColour = "Black"
                    while Player["Black"].seated == false do
                        coroutine.yield()
                    end
                end

            end

            local count1, count2 = 0, 0
            for _, v in pairs(seatedPlayers) do
                count1 = count1 + 1
                if v.moved == true then
                    count2 = count2 + 1
                end
            end

            if count1 == count2 then break end

            for _, v in pairs(seatedPlayers) do
                v.prevMoved = v.moved
            end

            coroutine.yield()
        end

        shufflePlayersDebounce = false

        self:setColorTint(deselectColour)

        return 1
    end

    startLuaCoroutine(self, "shuffleDelay")
    self.setPosition({-7.88, -1, -14.59})

end
