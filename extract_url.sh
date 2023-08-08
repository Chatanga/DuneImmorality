#! /bin/bash

mkdir -p resources
python3 extract_url.py input.mod.json | sort -u | while read url; do
    name=$(sed s/[^A-Za-z0-9]//g <<< "$url")
    if [ ! -f "resources/$name" ]; then
        echo "Downloading $url"
        wget -q -O "resources/${name}" "$url"
        if [ $? -ne 0 ]; then
            echo "-> unresolved"
            rm "resources/${name}"
        fi
    fi
done
