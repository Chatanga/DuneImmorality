#! /bin/bash

find scripts.organized -name \*.ttslua | while read f; do
    rm "$f"
    base=$(basename "$f")
    dir=$(dirname "$f")
    other_dir=$(sed s#[^/]*#..#g <<< "$dir")
    cd "$dir"
    if [ -f "$other_dir/scripts/$base" ]; then
        ln -s "$other_dir/scripts/$base" "$base"
    else
        ln -s "$other_dir/scripts/modules/$base" "$base"
    fi
    cd - > /dev/null
done
