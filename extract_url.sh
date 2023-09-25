#! /bin/bash

import_dir='resources/cloud'
mkdir -p "$import_dir"
python3 extract_url.py mod.base.json | sort -u | while read url; do
    name=$(sed s/[^A-Za-z0-9]//g <<< "$url")
    if [ ! -f "$import_dir/$name" ]; then
        echo "Downloading $url"
        wget -q -P "$import_dir" --content-disposition "$url"
        if [ $? -ne 0 ]; then
            echo "-> unresolved"
            rm "$import_dir/${name}"
        fi
    fi
done
