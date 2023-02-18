#! /bin/bash

mkdir -p "/tmp/TabletopSimulator/Tabletop Simulator Lua/"

function bundle {
	path="$1"
	filename=$(basename "$path")
	echo "Bundle $path..."
	luabundler bundle "$path" -p "scripts/modules/?.ttslua" -o "/tmp/TabletopSimulator/Tabletop Simulator Lua/$filename"
}

if [ $# -gt 0 ]; then
	while [ $# -gt 0 ]; do
		bundle "$1"
		shift
	done
else
	rm "/tmp/TabletopSimulator/Tabletop Simulator Lua"/*.ttslua
	for f in scripts/*.ttslua
	do
		bundle "$f"
	done
fi
