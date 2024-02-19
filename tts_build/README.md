# Build Process

## Requirements

- [LuaBundler](https://github.com/Benjamin-Dobell/luabundler)
- Python 3

## Build & Deploy

**First time:**

```bash
python3 build.py
```

You should now have a new save XXX in TTS.

**You've only changed the scripts, but don't have a running TTS instance with a loaded save:**

```bash
python3 build.py
```

**You've only change the scripts and have a running TTS instance with a loaded save:**

```bash
python3 build.py --upload
```

It directly updates the scripts to your live save.

**You've changed the save in TSS:**

Overwrite the save YYY with it, then `python3 build.py --full` and finally reload the save XXX.

**You want to change the save outside TSS:**

Edit the local `skeleton.json` file, then `python3 build.py` and reload the save.

## Notes

Using 'TS_Save_YYY.json' and 'TS_Save_XXX.json' as our working saves is arbitrary and could be changed in the top `build.properties` file.
In fact, the two could be the same, it's just safer to separate the two of them.

## Internals

![Capture](workflow.png)

The whole process could be executed with a single call:

```bash
python3 build.py --full
```

It amounts to call the sequence of commands `import + unpack + unbundle + patch + store + bundle + pack + export`.
However, when only modifying scripts, the beginning of this sequence is not needed and,
after an initial call to `import + unpack + unbundle + patch + store`, we simply need to call `bundle + pack + export`.

```bash
python3 build.py
```

## TTS Editor API

While the scripts above don't rely on TTS to work and simply change the save files it uses,
it also possible to take advantage of the TTS Editor API.

When you have a running TTS instance, you can use the alternate `upload` path instead of `pack + export` by simply adding the `--upload` option.
It doesn't update the physical save file, but directly patches the loaded save instead.

```bash
python3 build.py --upload
```

You can also launch the `listen.py` script in another terminal to collect all the logs from TTS.
It is especially useful to translate the error message locations into ctrl-clickable links (in VS Code),
the script taking care of translating them into something usable.

```bash
python3 listen.py
```
