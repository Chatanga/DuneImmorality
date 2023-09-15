#! /bin/bash

# Unresolved:
# http://cloud-3.steamusercontent.com/ugc/2029468177564515609/E8525C84FFDB7EE16577D130FA17B58629BE38E9/
# http://cloud-3.steamusercontent.com/ugc/2029469358268107658/416555ED5FD18C7045AD716EF2A0428611A7530C/
# http://cloud-3.steamusercontent.com/ugc/2029469358268108609/1EAE76FAC8926E36E7D95F84E62E36EEBFAE57E8/

# Hein ?
# http://cloud-3.steamusercontent.com/ugc/2029469358268109382/7E98B2CF99D80E27213815E475B27212574BBC76/

import_dir="resources/import"
mkdir -p "$import_dir"
python3 extract_url.py mod.base.json | sort -u | while read url; do
    name=$(sed s/[^A-Za-z0-9]//g <<< "$url")
    if [ ! -f "$import_dir/$name" ]; then
        echo "Downloading $url"
        wget -q -O "$import_dir/${name}" "$url"
        if [ $? -ne 0 ]; then
            echo "-> unresolved"
            rm "$import_dir/${name}"
        fi
    fi
done
