import json

def rectify_rotation(object):
    for coordinate in ['rotX', 'rotY', 'rotZ']:
        c = object['Transform'][coordinate]
        if abs(c - 180.0) < 10:
            c = 180
        elif abs(c) < 10 or 360 - c < 10:
            c = 0
        object['Transform'][coordinate] = c

def register_tags(object, component_tag_counts):

    def register_tag(tag_type):
        if not tag in component_tag_counts:
            print("Undeclared " + tag_type + ": " + tag)
            component_tag_counts[tag] = 0
        component_tag_counts[tag] += 1

    if 'Tags' in object:
        for tag in object['Tags']:
            register_tag("tag")

    if 'AttachedSnapPoints' in object:
        for snap_point in object['AttachedSnapPoints']:
            if 'Tags' in snap_point:
                for tag in snap_point['Tags']:
                    register_tag("snappoint tag")

def patch_object(object, component_tag_counts):
    rectify_rotation(object)
    register_tags(object, component_tag_counts)
    object['LuaScript'] = ''
    object['LuaScriptState'] = ''

def patch_save(input_path, output_path):

    save = None
    with open(input_path, 'r', encoding='utf-8') as save_file:
        save = json.load(save_file)

    save['SaveName'] = save['GameMode']

    component_tags = {}
    component_tag_counts = {}
    for tag in save['ComponentTags']['labels']:
        displayed_tag_name = tag['displayed']
        component_tags[displayed_tag_name] = tag['normalized']
        component_tag_counts[displayed_tag_name] = 0

    objects = save['ObjectStates']
    new_objects = []
    object_by_guid = {}
    object_by_guid["-1"] = save

    for object in objects:
        if 'States' in object:
            for _, state in object['States'].items():
                patch_object(state, component_tag_counts)

        if 'ContainedObjects' in object:
            for child in object['ContainedObjects']:
                patch_object(child, component_tag_counts)

        guid = object['GUID']
        object_by_guid[guid] = object

        patch_object(object, component_tag_counts)

        new_objects.append(object)

    new_labels = []
    for tag in component_tag_counts.items():
        if tag[1] > 0:
            if tag[0] in component_tags:
                displayed_tag_name = tag[0]
                new_labels.append({
                    'displayed': displayed_tag_name,
                    'normalized': component_tags[displayed_tag_name],
                })
        else:
            print("Orphan tag:", tag[0])
    save['ComponentTags']['labels'] = new_labels

    save['ObjectStates'] = new_objects

    with open(output_path, 'w', encoding='utf-8') as new_save:
        new_save.write(json.dumps(save, indent = 2))
