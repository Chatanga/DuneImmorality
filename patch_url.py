#! /usr/bin/python3

import sys

def extract_url(filePath):
    mappings = [
        ('AE55C2BB6B9BE3CF9F407EF5C610DC30B154D5CE', 'none!'),
        ('D5C0242C3F8B78E9253EF1084F10E513AC001B4C', 'none!'),
        ('BEC43C979193F71220B89199159DFE61BCEECBB7', 'none!'),
        ('A25FD31F949807A7779195788AAAD8AA50DDB080', 'none!'),
        ('C2F6C0AD18C7299941F719D13B12A936C58EB20B', 'http://cloud-3.steamusercontent.com/ugc/2093667512238521846/D63B92C616541C84A7984026D757DB03E79532DD/'),
        ('A96C3FC9FD0B47BF94415CC751D70B78394B831C', 'http://cloud-3.steamusercontent.com/ugc/2093667512238509012/A92B5F8751A12CC7D42688E5C8B00A64D62FDDAB/'),
        ('B66782D07562B53EFDAE2A826A1D681667DBF4C7', 'http://cloud-3.steamusercontent.com/ugc/2093667512238508100/2551267D6FE07F1742E239316376FF840CD7E711/'),
        ('BFEB9420A565C548E9D7D29F9BF4C618F113FB2E', 'http://cloud-3.steamusercontent.com/ugc/2093667512241858475/7250F8271ADD93DA98F12A6BEDFF70AFC56E5850/'),
        ('F32F243777501EBB8DFE31247D83A938D8842C27', 'http://cloud-3.steamusercontent.com/ugc/2093667512241806726/835A2318DB56688DA1EF86C64382C2D50E76C5F6/'),
        ('EB75C43263E6266AB4637FB4CE66EC9985616680', 'http://cloud-3.steamusercontent.com/ugc/2093667512241807254/0F8DF1932BCCB2020CFF236DDDA0F584B6DB3545/'),
        ('7490A3E10DA39092301DBA483A41A74EC27A3776', 'http://cloud-3.steamusercontent.com/ugc/2093667512241807054/F1C215A457D5AB66B57C92E987E99EFB486D1FAA/'),
        ('37A53D71D3D80F35ADA6ACB63EB75236B0812785', 'http://cloud-3.steamusercontent.com/ugc/2093667512238538862/FCCABC17419EAB20222AD220FCCCFB40F3CAC3F1/'),
        ('6EA4D32881F7EAC54AF64F6004682B0E7F690ABE', 'http://cloud-3.steamusercontent.com/ugc/2093667512241806908/3D88860AF983BB92493F8F01E17C5B67D0254F1E/'),
        ('1686793087C941E722F4274119A6C91EFA02C9C1', 'http://cloud-3.steamusercontent.com/ugc/2093667512241807403/09BF3A35131C64892B78A6C7E44D10F7D9319F55/'),
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
