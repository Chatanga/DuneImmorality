#! /bin/bash
output_save="$HOME/.local/share/Tabletop Simulator/Saves/TS_Save_99.json"
cp 'tmp/mod.patched.json' "$output_save"
output_png_file=$(readlink -f "$output_save" | sed 's/.json/.png/g')
if [ ! -f "$output_png_file" ]; then
    cp immorality.png "$output_png_file"
fi
