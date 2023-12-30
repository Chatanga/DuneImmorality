#! /bin/bash

# Not enough!
save=../skeleton.json

import_dir='import'
mkdir -p "$import_dir"
python3 extract_url.py "$save" | sort -u | while read url; do
    name=$(sed s/[^A-Za-z0-9]//g <<< "$url")
    if [ ! -f "$import_dir/$name" ]; then
        echo "Downloading $url"
        wget -q -P "$import_dir" --content-disposition "$url"
        if [ $? -ne 0 ]; then
            echo "-> unresolved"
        fi
    fi
done
