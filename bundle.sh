#! /bin/bash

mkdir -p "/tmp/TabletopSimulator/Tabletop Simulator Lua/"
rm "/tmp/TabletopSimulator/Tabletop Simulator Lua/*"

for f in scripts/*.ttslua
do
	filename=$(basename "$f")
	echo "Bundle $f..."
	luabundler bundle "$f" -p "scripts/modules/?.ttslua" -o "/tmp/TabletopSimulator/Tabletop Simulator Lua/$filename"
done
