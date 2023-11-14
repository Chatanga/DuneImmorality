#! /bin/bash
input_save="$HOME/.local/share/Tabletop Simulator/Saves/TS_Save_122.json"
if [ -f "$input_save" ] ; then
    cp "$input_save" 'input.mod.json'
else
    echo "Boostrapping by creating $input_save"
    cp 'input.mod.json' "$input_save"
fi
