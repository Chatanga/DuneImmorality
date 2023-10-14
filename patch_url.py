#! /usr/bin/python3

# Enable construction mode.
# $ find scripts/ -name \*.lua -exec ./patch_url.py -i {} \;
# $ ./build.sh
# $ ./patch_url.py -i tmp/mod.patched.json
# $ ./export.sh
# Load save 99 and overwrite save 122 in TTS.
# $ ./import.sh

import sys

def patch_url(filePath, inPlace):
    mappings = [
#        ('AE55C2BB6B9BE3CF9F407EF5C610DC30B154D5CE', 'none!'),
#        ('C2F6C0AD18C7299941F719D13B12A936C58EB20B', 'http://cloud-3.steamusercontent.com/ugc/2093667512238521846/D63B92C616541C84A7984026D757DB03E79532DD/'),
    ]
    with open('resources/mapping.lst') as mappingFile:
        lines = mappingFile.readlines()
        for line in lines:
            tokens = line[:-1].split(';')
            mappings.append((tokens[0][0 : 40], tokens[1]))

    with open(filePath) as file:
        content = file.read()

    if inPlace:
        output = open(filePath, 'w')
    else:
        output = sys.stdout

    i = 0
    try:
        while True:
            iInitial = i
            i = content.index('"http://', i)
            i += 1
            j = content.index('"', i)
            url = content[i : j]
            if url.endswith('\\'):
                j = j - 1
                url = content[i : j]
            patched = False
            for (key, newUrl) in mappings:
                if key in url:
                    print(content[iInitial : i], end = "", file = output)
                    print(newUrl, end = "", file = output)
                    if url != newUrl:
                        print("Patched: " + url + " -> " + newUrl, file = sys.stderr)
                    patched = True
                    break
            if not patched:
                print(content[iInitial : j], end = "", file = output)
                print("Not patched: " + url, file = sys.stderr)
            i = j
    except ValueError:
        print(content[i :], end = "", file = output)
        pass

argc = len(sys.argv)
if argc == 3:
    assert sys.argv[1] == "-i"
    patch_url(sys.argv[2], True)
else:
    patch_url(sys.argv[1], False)
