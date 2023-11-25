# Build Process

## Requirements

- [LuaBundler](https://github.com/Benjamin-Dobell/luabundler)
- Python 3

## Build & Deploy

**First time:**

```bash
python3 build.py --full
```

You should now have 2 new saves 200 and 201 in TTS.

**You only change the scripts, but don't have a running TTS instance with a loaded save:**

```bash
python3 build.py
```

Save 200 is imported, updated with your scripts, then exported to 201.

**You only change the scripts and have a running TTS instance with a loaded save:**

```bash
python3 build.py --upload
```

It directly updates the scripts to your live save.

**You changed the save content in TSS:**

Overwrite save 200 with it, then `python3 build.py --full` and reload the save.

In addition to the steps above, you could have `python3 listen.py` running in another terminal to print the output of TSS (especially usefull for translating the source location of the error message).

## Internals

![Capture](workflow.png)

The whole process could be executed with a single call:

```bash
python3 build.py --full
```

It amounts to call the sequence of commands `import + unpack + unbundle + patch + bundle + pack + export`.
However, when only modifying scripts, the beginning of this sequence is not needed and,
after an initial call to `import + unpack + unbundle`, we simply need to call `bundle + pack + export`.

```bash
python3 build.py
```

If you have a TTS instance running your target save, you can also use the `upload` path instead of `pack + export`
The two Python scripts `upload.py` and `listen.py` are a new addition to take advantage of the TTS Editor API.
The second is especially useful to translate the error message locations into ctrl-clickable links.
When using this path, the `bundle + pack + export` sequence above becomes `bundle + upload`:

```bash
python3 listen.py
```

Having launched `listen.py` in another terminal will provide you with an immediate feedback from TTS.
