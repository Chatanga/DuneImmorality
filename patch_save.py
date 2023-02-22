import copy
import json
import sys

colors = ['Green', 'Yellow', 'Blue', 'Red']

def collect_structure_guid(structure):
    guids = set()
    to_be_visited = [structure]
    while to_be_visited:
        element = to_be_visited.pop()
        if type(element) is str:
            guids.add(element)
        elif type(element) is dict:
            for key, value in element.items():
                if key != "_comment":
                    to_be_visited.append(value)
        else:
            for value in element:
                to_be_visited.append(value)
    return guids

def collect_structure_anchor_guid(structure):
    guids = set()
    to_be_visited = [structure]
    while to_be_visited:
        element = to_be_visited.pop()
        if type(element) is str:
            pass
        elif type(element) is dict:
            for key, value in element.items():
                if key.endswith("anchor"):
                    guids.add(value)
                else:
                    to_be_visited.append(value)
        else:
            for value in element:
                to_be_visited.append(value)
    return guids

def rectify_rotation(object):
    for coordinate in ['rotX', 'rotY', 'rotZ']:
        c = object['Transform'][coordinate]
        if abs(c - 180.0) < 10:
            c = 180
        else:
            c = 0
        object['Transform'][coordinate] = c

def set_position(object, p):
    px, py, pz = p
    object['Transform']['posX'] = px
    object['Transform']['posY'] = py
    object['Transform']['posZ'] = pz

def translate(object, d):
    dx, dy, dz = d
    object['Transform']['posX'] += dx
    object['Transform']['posY'] += dy
    object['Transform']['posZ'] += dz

def get_translation(object, new_pos):
    x, y, z = new_pos
    dx = x - object['Transform']['posX']
    dy = y - object['Transform']['posY']
    dz = z - object['Transform']['posZ']
    return (dx, dy, dz)

def is_among(search_key, set, keys):
    for key in keys:
        if search_key == set[key]:
            return True
    return False

def is_player_object(guid, structure, object_guids):
    for color in colors:
        for object_guid in object_guids:
            if guid == structure['players'][color][object_guid]:
                return True
    return False

def find_name(structure, guid):
    to_be_visited = [structure]
    while to_be_visited:
        element = to_be_visited.pop()
        if type(element) is str:
            pass
        elif type(element) is dict:
            for key, value in element.items():
                if value == guid:
                    return key
                else:
                    to_be_visited.append(value)
        else:
            for value in element:
                to_be_visited.append(value)

player_object_positions = {
    'offseted': {
        'pass_turn_anchor': (-3.5, -3),
        'character_zone': (-9.5, 0),
        'draw_deck': (-15.5, 0),
        'draw_deck_zone': (-15.5, 0),
        'discard_deck_zone': (-3.5, 0),
        'ix_atomics': (-15.5, -4),

        'spice_counter': (-12, -3.5),
        'solari_counter': (-9.5, -3.5),
        'water_counter': (-7, -3.5)
    },
    'unchanged': {
        'pv_board': (0, 0),
        'pv_board_zone': (0, 0),
        'VP 4 Players': (-0.46, -2.34)
    },
    'symmetrical': {
        'reveal_zone': (0, -11),
        'tech_board_zone': (10, 0),
        'trash': (16, -0.25),
        'hand_trigger': (0, -15),

        'first_player_zone': (-15.5, 3.5),
        'banner_bag': (-13.5, 4),
        'councilor': (-13.5, 3),
        'agents/0': (-12, 3.5),
        'agents/1': (-10.5, 3.5),
        'dreadnoughts/0': (-5.5, 4),
        'dreadnoughts/1': (-6.5, 4),

        'troup_zone': (-3.5, 3.3),
        'troup_bowl': (-3.5, 3.3),
        'troups/0': (-3.0, 3.0),
        'troups/1': (-3.5, 3.0),
        'troups/2': (-4.0, 3.0),
        'troups/3': (-3.0, 3.5),
        'troups/4': (-3.5, 3.5),
        'troups/5': (-4.0, 3.5),
        'troups/6': (-3.0, 4.0),
        'troups/7': (-3.5, 4.0),
        'troups/8': (-4.0, 4.0)
    }
}

player_object_scales = {
    'character_zone': (-1, 1, -1),
    'discard_deck_zone': (3, -1, 7),
    'reveal_zone': (36, -1, 3),
    'tech_board_zone': (10, -1, 9),
    'hand_trigger': (36, 5, 4)
}

def layout_player_board(structure, object_by_guid, color):

    root = structure['players'][color]
    if color == 'Green':
        board = object_by_guid['e6396b']
        xOrigin = 30.5
        zOrigin = 11.5
        unchanged_x = lambda x : xOrigin + x
        offseted_x = lambda x : xOrigin + x
        symmetrical_x = lambda x : xOrigin + x
    elif color == 'Yellow':
        board = object_by_guid['036b6a']
        xOrigin = 30.5
        zOrigin = -11.5
        unchanged_x = lambda x : xOrigin + x
        offseted_x = lambda x : xOrigin + x
        symmetrical_x = lambda x : xOrigin + x
    elif color == 'Blue':
        board = object_by_guid['d72200']
        xOrigin = -30.5
        zOrigin = -11.5
        unchanged_x = lambda x : xOrigin + x
        offseted_x = lambda x : xOrigin + 18.47 + x
        symmetrical_x = lambda x : xOrigin - x
    elif color == 'Red':
        board = object_by_guid['75561d']
        xOrigin = -30.5
        zOrigin = 11.5
        unchanged_x = lambda x : xOrigin + x
        offseted_x = lambda x : xOrigin + 18.47 + x
        symmetrical_x = lambda x : xOrigin - x

    def getGUID(key):
        try:
            slashIndex = key.index('/')
            index = int(key[slashIndex + 1:])
            key = key[0:slashIndex]
            guid = root[key][index]
        except ValueError:
            guid = root[key]
        return guid

    for key, (x, z) in player_object_positions['unchanged'].items():
        object = object_by_guid[getGUID(key)]
        object['Transform']['posX'] = unchanged_x(x)
        object['Transform']['posZ'] = zOrigin + z + 6

    for key, (x, z) in player_object_positions['offseted'].items():
        object = object_by_guid[getGUID(key)]
        object['Transform']['posX'] = offseted_x(x)
        object['Transform']['posZ'] = zOrigin + z + 6

    for key, (x, z) in player_object_positions['symmetrical'].items():
        object = object_by_guid[getGUID(key)]
        object['Transform']['posX'] = symmetrical_x(x)
        object['Transform']['posZ'] = zOrigin + z + 6

    for key, (sx, sy, sz) in player_object_scales.items():
        object = object_by_guid[getGUID(key)]
        if sx > 0:
            object['Transform']['scaleX'] = sx
        if sy > 0:
            object['Transform']['scaleY'] = sy
        if sz > 0:
            object['Transform']['scaleZ'] = sz

    board['AttachedSnapPoints'] = []

    def add_snap_point(key, transform_x, xOffset = 0, zOffset = 0, rotated = False):
        xPos = transform_x(-xOffset)
        zPos = zOrigin - zOffset
        if key:
            object = object_by_guid[getGUID(key)]
            xPos -= object['Transform']['posX']
            zPos -= object['Transform']['posZ']
        yRot = 0.0
        if rotated:
            yRot = 180.0
        snap_point = {
            "Position": {
                "x": xPos,
                "y": 0.5,
                "z": zPos
            },
            "Rotation": {
                "x": 0.0,
                "y": yRot,
                "z": 0.0
            }
        }
        board['AttachedSnapPoints'].append(snap_point)

    add_snap_point('character_zone', unchanged_x)
    add_snap_point('draw_deck', unchanged_x)
    add_snap_point('discard_deck_zone', unchanged_x)
    add_snap_point('agents/0', unchanged_x)
    add_snap_point('agents/1', unchanged_x)
    add_snap_point(None, unchanged_x, offseted_x(-9), zOrigin + 9.5),
    add_snap_point('dreadnoughts/0', unchanged_x, rotated = True)
    add_snap_point('dreadnoughts/1', unchanged_x, rotated = True)

    for i in range(0, 12):
        add_snap_point('pv_board', unchanged_x, (i // 6) * 0.995 - 0.45, (i % 6) * 1 - 2.35)

    for i in range(0, 24):
        add_snap_point('reveal_zone', symmetrical_x, (i % 12) * 2.5 - 16, (i // 12) * 4)

    for i in range(0, 12):
        add_snap_point('tech_board_zone', symmetrical_x, (i // 4) * 3 - 4, (i % 4) * 2 - 3)

def clean_up_bottom(structure, object_by_guid):
    root = structure['bottom_accessories']
    manuals = [
        "Base Rules",
        "Base Reference Sheet",
        "Rise of Ix Rulebook",
        "Immortality Rules",
        "blitz_rules"
    ]
    for manual in manuals:
        object = object_by_guid[root[manual]]
        translate(object, (0, 0, 110))

    translate(object_by_guid[root["resolving_ties_in_conflict"]], (2, 0, -1))
    translate(object_by_guid[root["turn_summary_sheet"]], (-5, 0, 2.5))
    translate(object_by_guid[root["Randomise Players Positions"]], (0.5, 0, -1))
    translate(object_by_guid[root["credits_note"]], (-0.7, 0, -2))

def patch_save(input_path, output_path):
    with open('structure.json', 'r') as structure_file:
        structure = json.load(structure_file)

    categories = [
        'official_characters',
        'fanbase_characters',
        'players',
        'hidden_accessories',
        'top_accessories',
        'bottom_accessories',
        'immortality_row',
        'imperium_row',
        'intrigue',
        'base',
        'ix',
        'immortality',
        'black_market'
    ]

    structure_guids = {}
    for category in categories:
        structure_guids[category] = collect_structure_guid(structure[category])
    for category in colors:
        structure_guids[category] = collect_structure_guid(structure['players'][category])

    anchor_guids = collect_structure_anchor_guid(structure)

    patch = None
    with open('patch.json', 'r') as save_file:
        patch = json.load(save_file)

    save = None
    with open(input_path, 'r') as save_file:
        save = json.load(save_file)

    noLuaScript = False

    save["VectorLines"] = []
    save["SnapPoints"] = []

    save["SkyURL"] = "file:////home/sadalsuud/Téléchargements/Textures/HDRI-II/HDRI-II.jpg"

    if noLuaScript:
        save['LuaScript'] = ''
        save['LuaScriptState'] = ''
        save['XmlUI'] = ''

    guids_to_be_removed = [
        # Table
        "bd69bd",
        "4ee1f2",
        "afc863",
        "c8edca",
        "393bf7",
        "12c65e",
        "f938a2",
        "9f95fd",
        "35b95f",
        "5af8f2",
        # Dés
        "2250ef",
        "a47416",
        # Plateaux joueurs
        "0c408d",
        "6037b3",
        "6957f2",
        "daf2a3",
        # Plateaux joueurs (tech)
        "96b94b",
        "d69aec",
        "b24cc5",
        "8b1f92",
        # Plateaux annexes
        '5a682a',
        '7ded4f',
        #'6e10cb',
        # Instructions pour le Baron
        'c65d17',
        # Texte de la maison Hagal
        '328efa',
        # Poubelle du bas
        "ef8614"
    ]

    additional_objects = []
    additional_character_table = None
    anchor_object = None

    global_translation = (0, 1.6, 0)

    for object in patch['ObjectStates']:
        if object['Nickname'] == "Anchor":
            anchor_object = object
        elif object['Name'] == 'Custom_Assetbundle':
            if object['GUID'] == '823bd3':
                assert not additional_character_table
                additional_character_table = object
            object['LuaScript'] = 'self.interactable = false\r\n'
            object['Transform']['posY'] -= 1
            if object['GUID'] != '200785':
                object['Transform']['posY'] -= 0.75
            translate(object, global_translation)
            additional_objects.append(object)
        elif object['Name'] == "HandTrigger":
            pass
        else:
            #print('skipping', object['Name'])
            pass

    assert anchor_object

    objects = save['ObjectStates']
    new_objects = []
    object_by_guid = {}

    for object in objects:
        if 'States' in object:
            for _, state in object['States'].items():
                if noLuaScript:
                    state['Locked'] = True
                    state['LuaScript'] = ''
                    state['LuaScriptState'] = ''
                    state['XmlUI'] = ''
                if True:
                    state['AttachedSnapPoints'] = []
                rectify_rotation(state)

        guid = object['GUID']

        if guid in guids_to_be_removed:
            if guid == 'bd69bd':
                pass
            elif guid == '5a682a':
                # On préserve néanmoins ses scripts Lua.
                additional_character_table['LuaScript'] = object['LuaScript']
                additional_character_table['LuaScriptState'] = object['LuaScriptState']
                additional_character_table['XmlUI'] = object['XmlUI']
            else:
                assert object['LuaScript'] == ''
                assert object['LuaScriptState'] == ''
                assert object['XmlUI'] == ''
                if guid == 'ef8614':
                    other_kind_of_trash = object_by_guid['cf6ca1']
                    if not 'ContainedObjects' in other_kind_of_trash:
                        other_kind_of_trash['ContainedObjects'] = []
                    for contained_object in object['ContainedObjects']:
                        print("Transvasement de", guid, contained_object['Nickname'])
                        other_kind_of_trash['ContainedObjects'].append(contained_object)
                else:
                    assert not 'ContainedObjects' in object
            continue

        if noLuaScript:
            object['Locked'] = True
            object['LuaScript'] = ''
            object['LuaScriptState'] = ''
            object['XmlUI'] = ''
        if True:
            object['AttachedSnapPoints'] = []

        if guid in anchor_guids:
            new_anchor = copy.deepcopy(anchor_object)
            new_anchor['GUID'] = guid
            new_anchor['Locked'] = True
            for coordinate in ['posX', 'posY', 'posZ']:
                new_anchor['Transform'][coordinate] = object['Transform'][coordinate]
            for coordinate in ['rotX', 'rotY', 'rotZ']:
                new_anchor['Transform'][coordinate] = object['Transform'][coordinate]
            new_anchor['Nickname'] = object['Nickname']
            for property in ['LuaScript', 'LuaScriptState', 'XmlUI']:
                new_anchor[property] = object[property]
            object = new_anchor

        rectify_rotation(object)
        translate(object, global_translation)

        if guid in structure_guids['black_market']:
            if guid == structure['black_market']['board']:
                set_position(object, (-6, -1, 21))
            else:
                translate(object, (0, -3, -3))

        elif guid in structure_guids['official_characters'] or guid in structure_guids['fanbase_characters']:
            translate(object, (1, -3, 2))
            if guid == structure['official_characters']['Leaders Randomizer bag']:
                translate(object, (17, 0, 0))
        elif guid in structure_guids['hidden_accessories']:
            translate(object, (-10, 0, 15))

        elif guid in structure_guids['top_accessories']:
            translate(object, (-2, -2.5, -4))
        elif guid in structure_guids['bottom_accessories']:
            translate(object, (0, -2.5, -4))
        elif guid in structure_guids['immortality_row'] or guid in structure_guids['imperium_row'] or guid in structure_guids['intrigue']:
            translate(object, (0, -2.5, -4))
        elif guid in structure_guids['ix'] or guid in structure_guids['immortality']:
            translate(object, (0, -2.5, -4))
        elif guid in structure_guids['base']:
            translate(object, (0, -2.5, -4))

        elif guid in structure_guids['Green']:
            green = structure['players']['Green']
            if not is_among(guid, green, ['hand_trigger']):
                translate(object, (2, -2.1, -2.8))
            if is_among(guid, green, ['pv_board', 'pv_board_zone', 'VP 4 Players']):
                translate(object, (0, 0, -2))
            elif is_among(guid, green, ['trash']):
                translate(object, (10, 0.2, 6))
        elif guid in structure_guids['Yellow']:
            yellow = structure['players']['Yellow']
            if not is_among(guid, yellow, ['hand_trigger']):
                translate(object, (2, -2.1, -4))
            if is_among(guid, yellow, ['pv_board', 'pv_board_zone', 'VP 4 Players']):
                translate(object, (0, 0, -2))
            elif is_among(guid, yellow, ['trash']):
                translate(object, (10, 0.2, 6))
        elif guid in structure_guids['Blue']:
            blue = structure['players']['Blue']
            if not is_among(guid, blue, ['hand_trigger']):
                translate(object, (-2, -2.1, -4))
            if is_among(guid, blue, ['pv_board', 'pv_board_zone', 'VP 4 Players']):
                translate(object, (0, 0, -2))
            elif is_among(guid, blue, ['trash']):
                translate(object, (-10, 0.2, 6))
        elif guid in structure_guids['Red']:
            red = structure['players']['Red']
            if not is_among(guid, red, ['hand_trigger']):
                translate(object, (-2, -2.1, -2.8))
            if is_among(guid, red, ['pv_board', 'pv_board_zone', 'VP 4 Players']):
                translate(object, (0, 0, -2))
            elif is_among(guid, red, ['trash']):
                translate(object, (-10, 0.2, 6))

        new_objects.append(object)
        object_by_guid[guid] = object

    for object in additional_objects:
        new_objects.append(object)
        object_by_guid[object['GUID']] = object

    for color in colors:
        layout_player_board(structure, object_by_guid, color)

    clean_up_bottom(structure, object_by_guid)

    save['ObjectStates'] = new_objects

    with open(output_path, 'w') as new_save:
        new_save.write(json.dumps(save, indent = 2))

assert len(sys.argv) == 3
patch_save(sys.argv[1], sys.argv[2])
