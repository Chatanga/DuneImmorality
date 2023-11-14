#! /bin/bash

tmp_dir='/tmp/TabletopSimulator/Tabletop Simulator Lua/'
mkdir -p "$tmp_dir"

function bundle {
	path="$1"
	filename=$(basename "$path" ".lua")
	echo "Bundle $path..."
	luabundler bundle "$path" -p "scripts/modules/?.lua" -o "$tmp_dir/$filename.ttslua"
	if [ $? -ne 0 ]; then
		exit 1
	fi
	if [ -f "scripts/$filename.xml" ]; then
		cp "scripts/$filename.xml" "$tmp_dir/$filename.xml"
	fi
}

if [ $# -gt 0 ]; then
	while [ $# -gt 0 ]; do
		bundle "$1"
		shift
	done
else
	find "$tmp_dir" -maxdepth 1 -name "*.ttslua" -exec rm {} \;
	for f in scripts/*.lua
	do
		bundle "$f"
	done
fi

timestamp="$(LANG=C date)"
sed -i "s/^local BUILD\s*=\s*.*/local BUILD = '${timestamp}'/" "$tmp_dir/Global.-1.ttslua"
