import json
import sys

def rectify_rotation(object):
    for coordinate in ['rotX', 'rotY', 'rotZ']:
        c = object['Transform'][coordinate]
        if abs(c - 180.0) < 10:
            c = 180
        elif abs(c) < 10 or 360 - c < 10:
            c = 0
        object['Transform'][coordinate] = c

def patch_object(object):
    rectify_rotation(object)

    if False:
        url_mapping = {
            # Shared
            #'http://cloud-3.steamusercontent.com/ugc/2200632144681138003/0BC7C82FC8DEE649252E2B3411BB65CA48C80DDB/': '',
            # Main
            'http://cloud-3.steamusercontent.com/ugc/2200632144681138497/ED1913436FCC12CF7706C10D316EC730B0DCA97A/': 'http://cloud-3.steamusercontent.com/ugc/2228780277328373783/67EAFA3C92B61B92F5540F95625B9333123EBE16/',
            # Left
            #'http://cloud-3.steamusercontent.com/ugc/2200632144681138887/2DE0F519454D88576D4771D995A62B16619CDB11/': 'http://cloud-3.steamusercontent.com/ugc/2200632144681225598/49C8793F8A1EE35B0A4BEF16EFC2B34F94FB0740/',
            # Right
            #'http://cloud-3.steamusercontent.com/ugc/2200632144681139293/F106E7B38918AFFF8BBBBA8D696CA60B3A526162/': 'http://cloud-3.steamusercontent.com/ugc/2200632144681226075/382A12611480DC7E0664A2FE86F29466D5F5B931/',
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

def patch_save(input_path, output_path):

    save = None
    with open(input_path, 'r') as save_file:
        save = json.load(save_file)

    save['SaveName'] = "Dune Uprising - Prototype"

    objects = save['ObjectStates']
    new_objects = []
    object_by_guid = {}
    object_by_guid["-1"] = save

    for object in objects:
        if 'States' in object:
            for _, state in object['States'].items():
                patch_object(state)

        if 'ContainedObjects' in object:
            for child in object['ContainedObjects']:
                patch_object(child)

        guid = object['GUID']
        object_by_guid[guid] = object

        patch_object(object)

        new_objects.append(object)

    save['ObjectStates'] = new_objects

    with open(output_path, 'w') as new_save:
        new_save.write(json.dumps(save, indent = 2))

assert len(sys.argv) == 3
patch_save(sys.argv[1], sys.argv[2])
