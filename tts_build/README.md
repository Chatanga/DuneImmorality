# Build Process

## Requirements

- [LuaBundler](https://github.com/Benjamin-Dobell/luabundler)
- Python 3

## Build & Deploy

You must first populate the `build.properties` files with the input index (XXX) and output index (YYY) of the two TTS saves you want to use to build the mod.
Depending on the context, one must exist while the other will be created/overwritten.
The two indexes may actually be the same, but this is not necessarily a good idea.

```
[save]
input = TS_Save_900
output = TS_Save_901
```

Note: input/output indexes have been replaced by full names.
You can still emulate the old behavior by following the `TS_Save_<number>` pattern, but it's not mandatory with TTS.*

Finally, edit the `build.py` to adjust the `app_dir` and `luabundler` variables if needed to match your environment.

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

**You've changed the save in TTS:**

Overwrite the save XXX with it, then `python3 build.py --full` and finally reload the save YYY.

**You want to change the save outside TTS:**

Edit the local `skeleton.json` file, then `python3 build.py` and reload the save.

**You want to import an existing save:**

Simply copy the save and its content in the TTS Save directory and rename them to match your input index, then ```python3 build.py --full```.
If it doesn't exist, the `scripts` directory will be created.
Otherwise, the imported scripts will be available in `tmp\scripts`.

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
