# Dune Immorality TTS Mod

![Capture](resources/capture.jpg)

ID: 2956104551

## Build Process

![Capture](workflow.png)

The whole process could be executed with a single call:

    ./build

It amounts to call the sequence of commands `import + unpack + unbundle + patch + bundle + pack + export`.
However, when only modifying scripts, the beginning of this sequence is not needed and,
after an initial call to `import + unpack + unbundle`, we simply need to call `bundle + pack + export`.

The two Python scripts `upload.py` and `listen.py` are a new addition to take advantage of the TTS Editor API.
The second is especially useful to translate the error message locations into ctrl-clickable links.
When using this path, the `bundle + pack + export` sequence above becomes `bundle + upload`:

    ./bundle.sh && ./upload.py

Having launched `./listen.py` in another terminal will provide you with an immediate feedback from TTS.

## Principles

- Game -> Action (+log)
- Player (-> Leader/Hagal -> Action (+log))

## TODO

- Leader over Action.
- Combat and conflict.
- Tleilaxu board.
- Identify and detect played cards.
- Reveal.
- Score track.
- Instruction reminder.
- Endgame.
- The Hagal house (+resources +difficulty).
- Introduce the graphic log.
- Restore translations.
- Restore music.
- Blitz!
- Arrakeen Scouts.
