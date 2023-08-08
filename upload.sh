#! /bin/bash
tts_save_dir='/home/sadalsuud/.local/share/Tabletop Simulator/Saves'
cp 'tmp/mod.patched.json' 'output.mod.json'
output_png_file=$(readlink output.mod.json | sed 's/.json/.png/g')
if [ ! -f "$output_png_file" ]; then
    cp immorality.png "$output_png_file"
fi