#! /bin/bash

target='tmp/scripts'

if [ -d $target ]; then
	rm -r $target
fi
mkdir -p $target/modules/

for f in /tmp/TabletopSimulator/"Tabletop Simulator Lua"/*.ttslua
do
	filename=$(basename "$f" ttslua)lua
	echo "Unbundle $f..."
	luabundler unbundle "$f" -o "$target/$filename" -m $target/modules/
	if [ $? -ne 0 ]; then
		cp "$f" "$target/$filename"
	fi
done
