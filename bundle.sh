#! /bin/bash

mkdir -p "/tmp/TabletopSimulator/Tabletop Simulator Lua/"

function bundle {
	path="$1"
	filename=$(basename "$path" ".lua")
	echo "Bundle $path..."
	luabundler bundle "$path" -p "scripts/modules/?.lua" -o "/tmp/TabletopSimulator/Tabletop Simulator Lua/$filename.ttslua"
	if [ $? -ne 0 ]; then
		exit 1
	fi
	if [ -f "scripts/$filename.xml" ]; then
		cp "scripts/$filename.xml" "/tmp/TabletopSimulator/Tabletop Simulator Lua/$filename.xml"
	fi
}

if [ $# -gt 0 ]; then
	while [ $# -gt 0 ]; do
		bundle "$1"
		shift
	done
else
	find '/tmp/TabletopSimulator/Tabletop Simulator Lua' -maxdepth 1 -name "*.ttslua" -exec rm {} \;
	for f in scripts/*.lua
	do
		bundle "$f"
	done
fi
