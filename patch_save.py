import json
import math
import sys

def distance(p1, p2):
    (x1, y1, z1) = p1
    (x2, y2, z2) = p2
    return math.sqrt((x1 - x2)**2 + (y1 - y2)**2 + (z1 - z2)**2)

def rectify_rotation(object):
    for coordinate in ['rotX', 'rotY', 'rotZ']:
        c = object['Transform'][coordinate]
        if abs(c - 180.0) < 10:
            c = 180
        elif abs(c) < 10 or 360 - c < 10:
            c = 0
        object['Transform'][coordinate] = c

def get_position(object):
    transform = object['Transform']
    return (transform['posX'], transform['posY'], transform['posZ'])

def erase_snap_points(save, center, radius):
    cx, cy, cz = center
    filtered_snap_points = []
    for snap_point in save["SnapPoints"]:
        p = snap_point["Position"]
        square_distance = (p["x"] - cx)**2 + (p["y"] - cy)**2 + (p["z"] - cz)**2
        if square_distance > radius**2:
            filtered_snap_points.append(snap_point)
    save["SnapPoints"] = filtered_snap_points

def erase_zones(objects, center, radius):
    cx, cy, cz = center
    filtered_objects = []
    for object in objects:
        keep = True
        if "Name" in object:
            name = object["Name"]
            if name == "ScriptingTrigger":
                transform = object["Transform"]
                px = transform['posX']
                py = transform['posY']
                pz = transform['posZ']
                square_distance = (px - cx)**2 + (py - cy)**2 + (pz - cz)**2
                keep = square_distance > radius**2
        if keep:
            filtered_objects.append(object)
    return filtered_objects

def migrate_description(object):
    if 'Nickname' in object and object['Nickname'] != '' :
        object['Nickname'] = ''
    if 'Description' in object:
        description = object['Description']
    else:
        description = None
    if description:
        if ' ' in description or description[0].islower():
            print('Migrating: ' + description)
            object['GMNotes'] = description
        else:
            print('Rejecting: ' + description)
        object['Description'] = ''

def patch_object(object):
    rectify_rotation(object)
    #migrate_description(object)

def patch_save(input_path, output_path):

    save = None
    with open(input_path, 'r') as save_file:
        save = json.load(save_file)

    save['SaveName'] = "Dune Immorality - Alpha Test"

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
