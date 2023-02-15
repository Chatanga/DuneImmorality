#! /bin/bash

if [ -d scripts/ ]; then
	rm -r scripts/
fi
mkdir -p scripts/modules/

for f in /tmp/TabletopSimulator/"Tabletop Simulator Lua"/*.ttslua
do
	filename=$(basename "$f" ttslua)ttslua
	echo "Unbundle $f..."
	luabundler unbundle "$f" -o "scripts/$filename" -m scripts/modules/
done

for f in scripts/modules/*.lua
do
	filename=$(basename "$f" lua)ttslua
	mv "$f" "scripts/modules/$filename"
done
