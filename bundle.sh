#! /bin/bash

mkdir -p "/tmp/TabletopSimulator/Tabletop Simulator Lua/"

function bundle {
	path="$1"
	filename=$(basename "$path")
	echo "Bundle $path..."
	luabundler bundle "$path" -p "scripts/modules/?.ttslua" -o "/tmp/TabletopSimulator/Tabletop Simulator Lua/$filename"
	if [ $? -ne 0 ]; then
		exit 1
	fi
}

if [ $# -gt 0 ]; then
	while [ $# -gt 0 ]; do
		bundle "$1"
		shift
	done
else
	find '/tmp/TabletopSimulator/Tabletop Simulator Lua' -maxdepth 1 -name "*.ttslua" -exec rm {} \;
	find '/tmp/TabletopSimulator/Tabletop Simulator Lua' -maxdepth 1 -name "*.lua" -exec rm {} \;
	for f in scripts/*.ttslua
	do
		bundle "$f"
	done
fi
