local Music = {
    sounds = {
        atomics = "http://cloud-3.steamusercontent.com/ugc/2079029969561141342/C9F0035DAF76EE6B353F9885C2859EBB282A9988/",
        --battle = "",
        turn = "http://cloud-3.steamusercontent.com/ugc/2027235268872374937/7FE5FD8B14ED882E57E302633A16534C04C18ECE/",
    }
}

---
function Music.onLoad(state)
    if state.settings then
        Music.enabled = state.settings.soundEnabled
    end
end

---
function Music.setUp(settings)
    Music.enabled = settings.soundEnabled
end

---
function Music.play(sound)
    if Music.enabled and Music.sounds[sound] then
        MusicPlayer.setCurrentAudioclip({
            url = Music.sounds[sound],
            title = sound
        })
    end
end

return Music