import json

def rectify_rotation(object):
    for coordinate in ['rotX', 'rotY', 'rotZ']:
        c = object['Transform'][coordinate]
        if abs(c - 180.0) < 10:
            c = 180
        elif abs(c) < 10 or 360 - c < 10:
            c = 0
        object['Transform'][coordinate] = c

def patch_object(object, componentTagCounts):
    rectify_rotation(object)

    object['LuaScript'] = ''
    object['LuaScriptState'] = ''

    if False:
        url_mapping = {
            # Shared
            'http://cloud-3.steamusercontent.com/ugc/2200632144681138003/0BC7C82FC8DEE649252E2B3411BB65CA48C80DDB/': 'http://cloud-3.steamusercontent.com/ugc/2228780365505979502/6B5133415732C568628AC323E473BA675B726F5B/',
            # Main
            'http://cloud-3.steamusercontent.com/ugc/2200632144681138497/ED1913436FCC12CF7706C10D316EC730B0DCA97A/': 'http://cloud-3.steamusercontent.com/ugc/2228780277328373783/67EAFA3C92B61B92F5540F95625B9333123EBE16/',
            # Left
            'http://cloud-3.steamusercontent.com/ugc/2200632144681225598/49C8793F8A1EE35B0A4BEF16EFC2B34F94FB0740/': 'http://cloud-3.steamusercontent.com/ugc/2228780365505978362/59DB3B9719C7494308C7883944C75F4E0EAED3AE/',
            # Right
            'http://cloud-3.steamusercontent.com/ugc/2200632144681226075/382A12611480DC7E0664A2FE86F29466D5F5B931/': 'http://cloud-3.steamusercontent.com/ugc/2228780365505977002/3615093D810350824B76D3E57244FE888F0CE844/',
        }
        for key in ['AssetbundleURL', 'AssetbundleSecondaryURL']:
            if 'CustomAssetbundle' in object and key in object['CustomAssetbundle']:
                url = object['CustomAssetbundle'][key]
                if url in url_mapping:
                    object['CustomAssetbundle'][key] = url_mapping[url]
                    print("Patching URL: " + url)

    if False:
        for interestingContent in ['Decal', 'AttachedSnapPoints', 'States', 'ContainedObjects']:
            if interestingContent in object:
                print("{} ({}) has {}".format(object['Name'], object['GUID'], interestingContent))

    if True:
        if 'Tags' in object:
            for tag in object['Tags']:
                if not tag in componentTagCounts:
                    print("Missing tag: " + tag)
                    componentTagCounts[tag] = 0
                componentTagCounts[tag] += 1
        if 'AttachedSnapPoints' in object:
            for snapPoint in object['AttachedSnapPoints']:
                if 'Tags' in snapPoint:
                    for tag in snapPoint['Tags']:
                        if not tag in componentTagCounts:
                            print("Missing tag: " + tag)
                            componentTagCounts[tag] = 0
                        componentTagCounts[tag] += 1

def patch_save(input_path, output_path):

    save = None
    with open(input_path, 'r') as save_file:
        save = json.load(save_file)

    save['SaveName'] = "Dune Uprising - Prototype"

    componentTags = {}
    componentTagCounts = {}
    for tag in save['ComponentTags']['labels']:
        componentTags[tag['displayed']] = tag['normalized']
        componentTagCounts[tag['displayed']] = 0

    objects = save['ObjectStates']
    new_objects = []
    object_by_guid = {}
    object_by_guid["-1"] = save

    for object in objects:
        if 'States' in object:
            for _, state in object['States'].items():
                patch_object(state, componentTagCounts)

        if 'ContainedObjects' in object:
            for child in object['ContainedObjects']:
                patch_object(child, componentTagCounts)

        guid = object['GUID']
        object_by_guid[guid] = object

        patch_object(object, componentTagCounts)

        new_objects.append(object)

    newLabels = []
    for tag in componentTagCounts.items():
        if tag[1] > 0:
            print(tag[0])
            if tag[0] in componentTags:
                newLabels.append({
                    'displayed': tag[0],
                    'normalized': componentTags[tag[0]],
                })
    save['ComponentTags']['labels'] = newLabels

    save['ObjectStates'] = new_objects

    with open(output_path, 'w') as new_save:
        new_save.write(json.dumps(save, indent = 2))
