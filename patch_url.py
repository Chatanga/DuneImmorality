#! /usr/bin/python3

# Enable construction mode.
# $ find scripts/ -name \*.ttslua -exec ./patch_url.py -i {} \;
# $ ./init.sh
# $ ./patch_url.py -i tmp/mod.patched.json
# $ ./upload.sh
# Load save 99 and overwrite save 122 in TTS.
# $ ./import.sh

import sys

def patch_url(filePath, inPlace):
    mappings = [
#        ('AE55C2BB6B9BE3CF9F407EF5C610DC30B154D5CE', 'none!'),
        ('http://cloud-3.steamusercontent.com/ugc/2093667512238508100/2551267D6FE07F1742E239316376FF840CD7E711/', 'http://cloud-3.steamusercontent.com/ugc/2093668799785646585/5A6FB1D7F4148F22FEF453500A6627132379BD6B/'), # TechNegotiation1P
        ('http://cloud-3.steamusercontent.com/ugc/2093667512238508299/352C9C2F86BCE0E8832CA2265D0C2A4829D11A14/', 'http://cloud-3.steamusercontent.com/ugc/2093668799785646429/978923957A87E0CB3DFAA25DF543FD863DA1EC95/'), # SmugglingandInterstellarShipping
        ('http://cloud-3.steamusercontent.com/ugc/2093667512238508480/ACE7BA96F9E5F8218FA434192B90234FD9ED4E38/', 'http://cloud-3.steamusercontent.com/ugc/2093668799785646965/26E28590801800D852F4BCA53E959AAFAAFC8FF3/'), # HagalBack
        ('http://cloud-3.steamusercontent.com/ugc/2093667512238508623/CC2DD2C8267024F457F281E0ECCBBE97DA75C6C0/', 'http://cloud-3.steamusercontent.com/ugc/2093668799785646315/5E6323692811F0530FB83FAE286162BDF6010E47/'), # Dreadnought1P
        ('http://cloud-3.steamusercontent.com/ugc/2093667512238508791/677B5A5C2EECAF60962F6002D7320601EB4E49AA/', 'http://cloud-3.steamusercontent.com/ugc/2093668799785647713/66020C11E4FEA2D22744020D27465DCC2BB02BBE/'), # HagalDeck
        ('http://cloud-3.steamusercontent.com/ugc/2093667512238509012/A92B5F8751A12CC7D42688E5C8B00A64D62FDDAB/', 'http://cloud-3.steamusercontent.com/ugc/2093668799785646835/1A8E52049F9853C42DA1D0A2E26AF50F7B503773/'), # Dreadnought2P
        ('http://cloud-3.steamusercontent.com/ugc/2093667512238509182/CAE72AEA7F428DB102776EBFD022458D58673955/', 'http://cloud-3.steamusercontent.com/ugc/2093668799785647086/8C2F363EFD82AB1A80A01A3E527E6A4ACE369643/'), # Arrakeen2P
        ('http://cloud-3.steamusercontent.com/ugc/2093667512238509332/AA0F8C9CAE3E11C28EE4379FA045FF11DDD03C38/', 'http://cloud-3.steamusercontent.com/ugc/2120691978813601622/36ABA3AD7A540FF6960527C1E77565F10BB2C6CB/'), # ImmortalityCarthag
        ('http://cloud-3.steamusercontent.com/ugc/2093667512238509443/4F6C09B50E63B47E3F40BB9B605729DC67C3E458/', 'http://cloud-3.steamusercontent.com/ugc/2093668799785647605/D7FAA1F3EB842A0EB4A2966F134EB58ACD966AFC/'), # FoldSpaceAndInterstellarShipping
        ('http://cloud-3.steamusercontent.com/ugc/2093667512238509603/E59D268A3103235748A7CEE2535ED0BF97D61A9A/', 'http://cloud-3.steamusercontent.com/ugc/2093668799785647209/43CA7B78F12F01CED26D1B57D3E62CAC912D846C/'), # Churn
        ('http://cloud-3.steamusercontent.com/ugc/2093667512238509788/4E94083423F0DD9F5B0A4E72BAC4A60328175163/', 'http://cloud-3.steamusercontent.com/ugc/2093668799785647456/46014D79D2E1D2F68F4BF5740A0A9E1FED6E540D/'), # Wealth
        ('http://cloud-3.steamusercontent.com/ugc/2093667512238509948/7B73BB94440A5E5F4032C692B58DAFFD759DBF98/', 'http://cloud-3.steamusercontent.com/ugc/2093668799785646429/978923957A87E0CB3DFAA25DF543FD863DA1EC95/'), # InterstellarShipping
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
