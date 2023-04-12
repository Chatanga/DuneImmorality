import json
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
        else:
            c = 0
        object['Transform'][coordinate] = c

def translate(object, d):
    dx, dy, dz = d
    object['Transform']['posX'] += dx
    object['Transform']['posY'] += dy
    object['Transform']['posZ'] += dz

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

        #rectify_rotation(object)

        new_objects.append(object)
        object_by_guid[guid] = object

    save['ObjectStates'] = new_objects

    with open(output_path, 'w') as new_save:
        new_save.write(json.dumps(save, indent = 2))

assert len(sys.argv) == 3
patch_save(sys.argv[1], sys.argv[2])
