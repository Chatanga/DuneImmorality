# Dune Uprising TTS Mod

Features:
- Base game 4P
- Base game 6P
- Rise of Ix extension
- Immortality extension

Supported langages:
- French
- English

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

## Nota

- Boostrap: copy `cp input.mod.json "$HOME/.local/share/Tabletop Simulator/Saves/TS_Save_200.json"`
- Windows / Bash scripts, UNIX paths, symbolic links?
