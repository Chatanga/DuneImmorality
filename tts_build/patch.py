import json


class TagRegistry:

    def __init__(self, save):
        self.component_tags = {}
        self.component_tag_counts = {}
        for tag in save['ComponentTags']['labels']:
            displayed_tag_name = tag['displayed']
            self.component_tags[displayed_tag_name] = tag['normalized']
            self.component_tag_counts[displayed_tag_name] = 0

    def register_tags(self, object):

        def register_tag(tag_type):
            if not tag in self.component_tag_counts:
                print(f'Undeclared {tag_type}: {tag}')
                self.component_tag_counts[tag] = 0
            self.component_tag_counts[tag] += 1

        if 'Tags' in object:
            for tag in object['Tags']:
                register_tag("tag")

        if 'AttachedSnapPoints' in object:
            for snap_point in object['AttachedSnapPoints']:
                if 'Tags' in snap_point:
                    for tag in snap_point['Tags']:
                        register_tag("snappoint tag")

    def get_used_labels(self):
        used_labels = []
        for tag in self.component_tag_counts.items():
            if tag[1] > 0:
                if tag[0] in self.component_tags:
                    displayed_tag_name = tag[0]
                    used_labels.append({
                        'displayed': displayed_tag_name,
                        'normalized': self.component_tags[displayed_tag_name],
                    })
            else:
                print(f'Orphan tag: {tag[0]}')
        return used_labels


def rectify_snappoints(parent, object):
    if 'AttachedSnapPoints' in object:
        #print('-' * 80)
        yParent = None if parent is None else parent['Transform']['posY']
        yObject = None if object is None else object['Transform']['posY']
        for snap_point in object['AttachedSnapPoints']:
            tags = snap_point['Tags']
            y = snap_point['Position']['y']
            #print(f'{yParent} / {yObject} / {y} - {tags}')
            snap_point['Position']['y'] = 0.100000143

def rectify_rotation(object):
    for coordinate in ['rotX', 'rotY', 'rotZ']:
        c = object['Transform'][coordinate]
        if abs(c - 180.0) < 10:
            c = 180
        elif abs(c) < 10 or 360 - c < 10:
            c = 0
        object['Transform'][coordinate] = c

def visit_object(parent, object, tag_registry):
    rectify_rotation(object)
    tag_registry.register_tags(object)
    rectify_snappoints(parent, object)
    object['LuaScript'] = ''
    object['LuaScriptState'] = ''

def patch_save(input_path, output_path):

    save = None
    with open(input_path, 'r', encoding='utf-8') as save_file:
        save = json.load(save_file)

    save['SaveName'] = save['GameMode']

    tag_registry = TagRegistry(save)

    objects = save['ObjectStates']
    new_objects = []
    object_by_guid = {}
    object_by_guid["-1"] = save

    for object in objects:
        if 'States' in object:
            for _, state in object['States'].items():
                visit_object(object, state, tag_registry)

        if 'ContainedObjects' in object:
            for child in object['ContainedObjects']:
                visit_object(object, child, tag_registry)

        guid = object['GUID']
        object_by_guid[guid] = object

        visit_object(None, object, tag_registry)

        new_objects.append(object)

    save['ComponentTags']['labels'] = tag_registry.get_used_labels()
    save['ObjectStates'] = new_objects

    with open(output_path, 'w', encoding='utf-8') as new_save:
        new_save.write(json.dumps(save, indent = 2))
