import json
import os
import re
import sys

def create_anchor(guid, name, position, luaScript):
    (x, y, z) = position
    return {
        "GUID": guid,
            "Name": "Custom_Model",
                "Transform": {
                "posX": x,
                "posY": y,
                "posZ": z,
                "rotX": 0.0,
                "rotY": 180.0,
                "rotZ": 0.0,
                "scaleX": 1.0,
                "scaleY": 1.0,
                "scaleZ": 1.0
            },
            "Nickname": name,
            "Description": "",
            "GMNotes": "",
            "AltLookAngle": {
                "x": 0.0,
                "y": 0.0,
                "z": 0.0
            },
            "ColorDiffuse": {
                "r": 1.0,
                "g": 0.0,
                "b": 1.0
            },
            "LayoutGroupSortIndex": 0,
            "Value": 0,
            "Locked": True,
            "Grid": True,
            "Snap": True,
            "IgnoreFoW": False,
            "MeasureMovement": False,
            "DragSelectable": True,
            "Autoraise": True,
            "Sticky": True,
            "Tooltip": True,
            "GridProjection": False,
            "HideWhenFaceDown": False,
            "Hands": False,
            "CustomMesh": {
                "MeshURL": "http://cloud-3.steamusercontent.com/ugc/2042984592862608679/0383C231514AACEB52B88A2E503A90945A4E8143/",
                "DiffuseURL": "",
                "NormalURL": "",
                "ColliderURL": "",
                "Convex": True,
                "MaterialIndex": 0,
                "TypeIndex": 4,
                "CustomShader": {
                    "SpecularColor": {
                        "r": 0.0,
                        "g": 0.0,
                        "b": 0.0
                    },
                    "SpecularIntensity": 0.0,
                    "SpecularSharpness": 7.0,
                    "FresnelStrength": 0.4
                },
                "CastShadows": True
            },
            "LuaScript": luaScript,
            "LuaScriptState": "",
            "XmlUI": ""
        }

def rectify_rotation(object):
    for coordinate in ['rotX', 'rotY', 'rotZ']:
        c = object['Transform'][coordinate]
        if abs(c - 180.0) < 10:
            c = 180
        elif abs(c) < 10 or 360 - c < 10:
            c = 0
        object['Transform'][coordinate] = c

def translate(object, d):
    dx, dy, dz = d
    object['Transform']['posX'] += dx
    object['Transform']['posY'] += dy
    object['Transform']['posZ'] += dz

def get_script_name(object):
    guid = object['GUID']
    name = object['Name']
    nickname = object['Nickname']
    if nickname:
        filename = nickname
    else:
        filename = name
    filename += "." + guid  + ".ttslua"
    return filename

def find_script(root_dir, guid):
    suffix = "." + guid + ".ttslua"
    for root, _, files in os.walk(root_dir):
        for file in files:
            if file.endswith(suffix):
                return file
    return None

def find_script_dir(root_dir, guid):
    suffix = "." + guid + ".ttslua"
    for root, _, files in os.walk(root_dir):
        for file in files:
            if file.endswith(suffix):
                return root
    return None

def rectify_name(object):

    renaming = {
        '2b4b92': 'Primary Table',
        '662ced': 'Secondary Table',
        '120026': 'Makers and Recall',
        'cf6ca1': 'Leader Randomizer',
        '9ea771': 'Randomise Player Positions',

        '976c3a': 'Buy Intrigue Card',
        '38ffc0': 'Buy First Imperium Row Card',
        '21b287': 'Buy Second Imperium Row Card',
        '0a5f50': 'Buy Third Imperium Row Card',
        'ded672': 'Buy Fourth Imperium Row Card',
        'ad2a82': 'Buy Fifth Imperium Row Card',
        '6a1097': 'Buy Special Imperium Cards',

        '3cdb2d': 'Spice Bonus - Imperial Basin',
        '394db2': 'Spice Bonus - Hagga Basin',
        '116807': 'Spice Bonus - The Great Flat',

        '54413c': 'Immortality Research Station',

        '576ccd': 'Solari - Red',
        'c5c4ef': 'Solari - Yellow',
        'e597dc': 'Solari - Green',
        'fa5236': 'Solari - Blue',
        '9cc286': 'Spice - Blue',
        '78fb8a': 'Spice - Yellow',
        '3074d4': 'Spice - Red',
        '22478f': 'Spice - Green',
        '0afaeb': 'Water - Blue',
        '692c4d': 'Water - Red',
        'f217d0': 'Water - Yellow',
        'fa9522': 'Water - Green',

        '700023': 'Atomics - Blue',
        '7e10a9': 'Atomics - Yellow',
        '0a22ec': 'Atomics - Green',
        'd5ff47': 'Atomics - Red',
        'adcd28': 'Player Board- Red',
        '77ca63': 'Player Board- Blue',
        'fdd5f9': 'Player Board- Yellow',
        '0bbae1': 'Player Board - Green',

        '439df9': 'Buy First Immortality Row Card',
        '363f98': 'Buy Second Immortality Row Card',
        '46cd6b': 'Tleilaxu Bonus Spice'
    }

    guid = object['GUID']
    if guid in renaming:
        script_name = find_script("scripts/", guid)
        if script_name:
            object['Nickname'] = renaming[guid]
            new_script_name = get_script_name(object)

            organized_dir = find_script_dir("scripts.organized/", guid)
            if organized_dir:
                print(guid, ":", script_name, "->", new_script_name)

                os.rename("scripts/" + script_name, "scripts/" + new_script_name)

                relative_prefix = re.sub('[^/]*', '.', organized_dir) # Un seul point ?!

                os.remove(organized_dir + "/" + script_name)
                os.symlink(relative_prefix + "/scripts/" + new_script_name, organized_dir + "/" + new_script_name)
        else:
            print("Missing script file for GUID", guid)

def patch_save(input_path, output_path):

    save = None
    with open(input_path, 'r') as save_file:
        save = json.load(save_file)

    objects = save['ObjectStates']
    new_objects = []
    object_by_guid = {}
    object_by_guid["-1"] = save

    for object in objects:
        if 'States' in object:
            for _, state in object['States'].items():
                rectify_rotation(state)

        guid = object['GUID']
        object_by_guid[guid] = object

        rectify_rotation(object)
        #rectify_name(object)

        new_objects.append(object)

    save['ObjectStates'] = new_objects

    with open(output_path, 'w') as new_save:
        new_save.write(json.dumps(save, indent = 2))

assert len(sys.argv) == 3
patch_save(sys.argv[1], sys.argv[2])
