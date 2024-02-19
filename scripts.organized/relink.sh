#! /bin/bash
find -name \*.lua | while read path
do
    mv "$path" "$path.trash"
    file=$(basename "$path" .trash)
    dir=$(dirname "$path")
    pushd "$dir" > /dev/null
        ln -s "$(echo $dir | sed 's#[^/]*#..#g')/scripts/$file" "$file"
    popd > /dev/null
done
