import json
import math

def rectify_rotation(object):
    for coordinate in ['rotX', 'rotY', 'rotZ']:
        c = object['Transform'][coordinate]
        if abs(c - 180.0) < 10:
            c = 180
        elif abs(c) < 10 or 360 - c < 10:
            c = 0
        object['Transform'][coordinate] = c

def get_position(object):
    return (
        object['Transform']['posX'],
        object['Transform']['posY'],
        object['Transform']['posZ'])

def distance(p1, p2):
    (x1, y1, z1) = p1
    (x2, y2, z2) = p2
    return math.sqrt((x1 - x2)**2 + (y1 - y2)**2 + (z1 - z2)**2)

def is_transient_zone(object):
    if object["Name"] == "ScriptingTrigger":
        p = get_position(object)
        useless_zone_positions = {
            # PV rows
            (22.28, 1.52, 21.85),
            (22.28, 1.52, -1.15),
            (-22.28, 1.52, 21.85),
            (-22.28, 1.52, -1.15),
            # Troops in orbit
            (27.5, 1.29, 16.6),
            (27.5, 1.29, -6.4),
            (-27.5, 1.29, 16.6),
            (-27.5, 1.29, -6.4),
            # Garrisons
            (8.15, 0.85, -10.35),
            (8.15, 0.85, -7.65),
            (1.55, 0.85, -10.35),
            (1.55, 0.85, -7.65),
            # Negociators
            (6.57, 1.06, 9.26),
            (7.47, 1.06, 9.26),
            (6.57, 1.06, 8.36),
            (7.47, 1.06, 8.36),
            # Specimens
            (2.1, 1.06, 15.72),
            (2.1, 1.06, 14.72),
            (0.5, 1.06, 15.72),
            (0.5, 1.06, 14.72),
            # Tech tiles
            (9.26, 1.4, 12.86),
            (9.26, 1.4, 10.81),
            (9.26, 1.4, 8.76),
        }
        for c in useless_zone_positions:
            if distance(p, c) < 0.5 and object['Transform']['scaleZ'] < 5:
                print("Removing useless zone", object['GUID'])
                return True
    return False

def patch_object(object):
    rectify_rotation(object)
    object['LuaScriptState'] = ''

def patch_save(input_path, output_path):
    save = None
    with open(input_path, 'r') as save_file:
        save = json.load(save_file)

    save['SaveName'] = save['GameMode']

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

        if not is_transient_zone(object):
            patch_object(object)
            new_objects.append(object)

    save['ObjectStates'] = new_objects

    with open(output_path, 'w') as new_save:
        new_save.write(json.dumps(save, indent = 2))
