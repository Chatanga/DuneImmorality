i18n = require("i18n")
require("locales")

local soundEnabled = false

local currentMusic = nil

_ = require("Core").registerLoadablePart(function()
    self.interactable = false
    soundEnabled = false
    activateButtons()
end)

function isSoundEnabled()
    return soundEnabled
end

function onLocaleChange()
    self.clearButtons()
    activateButtons()
end

function activateButtons()

    self.createButton({
        click_function = "selectMusic",
        function_owner = self,
        label = i18n("selectSound"),
        position = {-12, 1.8, 32},
        scale = {1, 1, 1},
        width = 1800,
        height = 500,
        font_color = {1, 1, 1},
        font_size = 170,
        color = "Black"
    })
    local label = ""
    local color = ""
    if soundEnabled then
        label = i18n("soundOn")
        color = "Green"
    else
        label = i18n("soundOff")
        color = "Red"
    end
    self.createButton({
        click_function = "toggleSound",
        function_owner = self,
        label = label,
        position = {-15, 1.8, 32},
        scale = {1, 1, 1},
        width = 1000,
        height = 500,
        font_size = 170,
        color = color,
        font_color = {1, 1, 1, 1}
    })
end

function toggleSound()
    soundEnabled = not soundEnabled
    self.clearButtons()
    activateButtons()
end

function selectMusic(_, color)
    if not soundEnabled then
        return 1
    else
        self.clearButtons()
        Wait.time(activateButtons, 1)

        local musics = MusicPlayer.getPlaylist()
        local options = {}
        for i, music in ipairs(musics) do
            options[i] = music.title
        end

        Player[color].showOptionsDialog("Choose MP3 for Combat Warning", options, 1,
            function(text, index, player_color)
                currentMusic = musics[index]
                MusicPlayer.setCurrentAudioclip(currentMusic)
                MusicPlayer.play()
                broadcastToAll("Playing " .. currentMusic.title, undefined)
            end)
    end
end

function onFightStart()
    if currentMusic and soundEnabled then
        MusicPlayer.setCurrentAudioclip(currentMusic)
        MusicPlayer.play()
    end
end