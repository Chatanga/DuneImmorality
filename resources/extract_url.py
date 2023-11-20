import sys

def extract_url(filePath):
    with open(filePath) as file:
        content = file.read()

    try:
        i = 0
        while True:
            i = content.index('"http://', i)
            i += 1
            j = content.index('"', i)
            url = content[i : j]
            if url.endswith('\\'):
                url = content[i : j - 1]
            print(url)
            i = j
    except ValueError:
        pass

assert len(sys.argv) == 2
extract_url(sys.argv[1])
