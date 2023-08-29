local Music = {
    sounds = {
        atomics = "http://cloud-3.steamusercontent.com/ugc/2002447125408335433/56A15AA85A1C45DE92FA3FD2372F0ECE6ABA0495/",
        --battle = "",
        turn = "http://cloud-3.steamusercontent.com/ugc/2027235268872374937/7FE5FD8B14ED882E57E302633A16534C04C18ECE/",
    }
}

---
function Music.onLoad(state)
    if state.settings then
        Music.enabled = state.settings.musicEnabled
    end
end

---
function Music.setUp(settings)
    Music.enabled = settings.musicEnabled
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
