#! /bin/bash

target='tmp/scripts.tmp'

if [ -d $target ]; then
	rm -r $target
fi
mkdir -p $target/modules/

for f in /tmp/TabletopSimulator/"Tabletop Simulator Lua"/*.ttslua
do
	filename=$(basename "$f" ttslua)ttslua
	echo "Unbundle $f..."
	luabundler unbundle "$f" -o "$target/$filename" -m $target/modules/
	if [ $? -ne 0 ]; then
		cp "$f" "$target/$filename"
	fi
done

for f in $target/modules/*.lua
do
	filename=$(basename "$f" lua)ttslua
	mv "$f" "$target/modules/$filename"
done
