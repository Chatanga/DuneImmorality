#! /usr/bin/python3

import sys

def extract_url(filePath):
    mappings = [
        ('82B13DA92562457E5A2045D46624B1ADF6DF6CE9', 'http://cloud-3.steamusercontent.com/ugc/2093667512238508623/CC2DD2C8267024F457F281E0ECCBBE97DA75C6C0/')
    ]
    with open('resources/mapping.lst') as mappingFile:
        lines = mappingFile.readlines()
        for line in lines:
            tokens = line[:-1].split(';')
            mappings.append((tokens[0][0 : 40], tokens[1]))

    with open(filePath) as file:
        content = file.read()

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
                    print(content[iInitial : i], end = "")
                    print(newUrl, end = "")
                    if url != newUrl:
                        print("Patched: " + url + " -> " + newUrl, file = sys. stderr)
                    patched = True
                    break
            if not patched:
                print(content[iInitial : j], end = "")
                print("Not patched: " + url, file = sys. stderr)
            i = j
    except ValueError:
        print(content[i :], end = "")
        pass

assert len(sys.argv) == 2
extract_url(sys.argv[1])
