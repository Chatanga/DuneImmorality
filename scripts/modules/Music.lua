local Helper = require("utils.Helper")

local Music = {
    sounds = {
        atomics = "http://cloud-3.steamusercontent.com/ugc/2093668799785645931/C9F0035DAF76EE6B353F9885C2859EBB282A9988/",
        battle = "http://cloud-3.steamusercontent.com/ugc/2093667512238510273/474E09BB37578C5FC1CFDE001E7D6785EE54C52F/",
        turn = "http://cloud-3.steamusercontent.com/ugc/2093667512238510405/2C9434C28270DDD87D33648DA7B17B23DA0D5ECF/",
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
    -- Do nothing, but introduces a pause in sync with the music which highlights a noticable event.
    Helper.onceTimeElapsed(1)
end

return Music
