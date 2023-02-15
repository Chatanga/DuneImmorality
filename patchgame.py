import json
import copy

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

def rectify_rotation(object_state):
    for coordinate in ['rotX', 'rotY', 'rotZ']:
        c = object_state['Transform'][coordinate]
        if abs(c - 180.0) < 10:
            c = 180
        else:
            c = 0
        object_state['Transform'][coordinate] = c

def set_position(object_state, p):
    px, py, pz = p
    object_state['Transform']['posX'] = px
    object_state['Transform']['posY'] = py
    object_state['Transform']['posZ'] = pz

def translate(object_state, d):
    dx, dy, dz = d
    object_state['Transform']['posX'] += dx
    object_state['Transform']['posY'] += dy
    object_state['Transform']['posZ'] += dz

def get_translation(object_state, new_pos):
    x, y, z = new_pos
    dx = x - object_state['Transform']['posX']
    dy = y - object_state['Transform']['posY']
    dz = z - object_state['Transform']['posZ']
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

def patch_save():
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
    with open('structure.json', 'r') as structure_file:
        structure = json.load(structure_file)
        for category in categories:
            structure_guids[category] = collect_structure_guid(structure[category])
        for category in colors:
            structure_guids[category] = collect_structure_guid(structure['players'][category])

    anchor_guids = collect_structure_anchor_guid(structure)

    patch = None
    with open('TS_Save_Patch.json', 'r') as save_file:
        patch = json.load(save_file)

    save = None
    with open('2702663883.json', 'r') as save_file:
        save = json.load(save_file)

    save["VectorLines"] = []
    save["SnapPoints"] = []

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
        'c65d17'
    ]

    noLuaScript = False

    additional_object_states = []
    additional_character_table = None
    anchor_object_state = None

    for object_state in patch['ObjectStates']:
        if object_state['Name'] != "HandTrigger":
            if object_state['Nickname'] == "Anchor":
                anchor_object_state = object_state
            elif object_state['Name'] == 'Custom_Assetbundle':
                if object_state['GUID'] == '823bd3':
                    assert not additional_character_table
                    additional_character_table = object_state
                else:
                    object_state['LuaScript'] = 'self.interactable = false\r\n'
                object_state['Transform']['posY'] -= 1
                if object_state['GUID'] != '200785':
                    object_state['Transform']['posY'] -= 0.75
                additional_object_states.append(object_state)
            else:
                #print('skipping', object_state['Name'])
                pass

    assert anchor_object_state

    new_object_states = []

    if noLuaScript:
        save['LuaScript'] = ''
        save['LuaScriptState'] = ''
        save['XmlUI'] = ''

    object_states = save['ObjectStates']

    object_state_by_guid = {}
    for object_state in object_states:
        guid = object_state['GUID']
        object_state_by_guid[guid] = object_state

    black_market_guid = structure['black_market']['board']

    for object_state in object_states:
        guid = object_state['GUID']
        if guid in guids_to_be_removed:
            if guid == 'bd69bd':
                pass
            elif guid == '5a682a':
                # On préserve néanmoins ses scripts Lua.
                additional_character_table['LuaScript'] = object_state['LuaScript']
                additional_character_table['LuaScriptState'] = object_state['LuaScriptState']
                additional_character_table['XmlUI'] = object_state['XmlUI']
            else:
                assert object_state['LuaScript'] == ''
                assert object_state['LuaScriptState'] == ''
                assert object_state['XmlUI'] == ''
            continue

        if noLuaScript:
            object_state['Locked'] = True
            object_state['LuaScript'] = ''
            object_state['LuaScriptState'] = ''
            object_state['XmlUI'] = ''
        if True:
            object_state['AttachedSnapPoints'] = []

        rectify_rotation(object_state)

        if guid in anchor_guids:
            new_anchor = copy.deepcopy(anchor_object_state)
            new_anchor['GUID'] = guid
            new_anchor['Locked'] = True
            for coordinate in ['posX', 'posY', 'posZ']:
                new_anchor['Transform'][coordinate] = object_state['Transform'][coordinate]
            for coordinate in ['rotX', 'rotY', 'rotZ']:
                new_anchor['Transform'][coordinate] = object_state['Transform'][coordinate]
            rectify_rotation(new_anchor)
            new_anchor['Nickname'] = find_name(structure, guid)
            for property in ['LuaScript', 'LuaScriptState', 'XmlUI']:
                new_anchor[property] = object_state[property]
            #print(new_anchor['Nickname'], "->", new_anchor['Transform']['posY'])
            #if new_anchor['Transform']['posY'] < 1.5:
            #    new_anchor['Transform']['posY'] = 1.55
            new_anchor['Transform']['posY'] = 1.5
            if False and guid == structure['base']['Setup UI anchor']:
                new_anchor['Transform']['posY'] += 1
            #print(new_anchor['Nickname'], "->", object_state['Transform']["scaleX"], object_state['Transform']["scaleY"], object_state['Transform']["scaleZ"])
            object_state = new_anchor

        if False and is_player_object(guid, structure, ['board', 'tech_board']):
            continue

        #translate(object_state, (0, 0, 0))

        if guid in structure_guids['black_market']:
            if guid == black_market_guid:
                set_position(object_state, (-6, -0.5, 21))
            else:
                translate(object_state, (0, -1, -3))
        elif guid in structure_guids['official_characters'] or guid in structure_guids['fanbase_characters']:
            translate(object_state, (1, -3, 2))
            if guid == structure['official_characters']['Leaders Randomizer bag']:
                translate(object_state, (17, 0, 0))
        elif guid in structure_guids['hidden_accessories']:
            translate(object_state, (-10, 0, 15))
        elif guid in structure_guids['top_accessories']:
            translate(object_state, (-2, -2.5, -4))
        elif guid in structure_guids['bottom_accessories']:
            translate(object_state, (0, -2.5, -4))
        elif guid in structure_guids['immortality_row'] or guid in structure_guids['imperium_row'] or guid in structure_guids['intrigue']:
            translate(object_state, (0, -2.5, -4))
            if False and guid == structure['imperium_row']['Foldspace Deck']:
                translate(object_state, (0, 0.5, 0))
        elif guid in structure_guids['ix'] or guid in structure_guids['immortality']:
            translate(object_state, (0, -2.5, -4))
        elif guid in structure_guids['base']:
            translate(object_state, (0, -2.5, -4))
        elif guid in structure_guids['Green']:
            translate(object_state, (2, -2.1, -2.8))
            if is_among(guid, structure['players']['Green'], ['pv_board', 'pv_board_zone', 'VP 4 Players']):
                translate(object_state, (0, 0, -2))
            elif is_among(guid, structure['players']['Green'], ['trash']):
                translate(object_state, (10, 0.2, 6))
        elif guid in structure_guids['Yellow']:
            translate(object_state, (2, -2.1, -4))
            if is_among(guid, structure['players']['Yellow'], ['pv_board', 'pv_board_zone', 'VP 4 Players']):
                translate(object_state, (0, 0, -2))
            elif is_among(guid, structure['players']['Yellow'], ['trash']):
                translate(object_state, (10, 0.2, 6))
        elif guid in structure_guids['Blue']:
            translate(object_state, (-2, -2.1, -4))
            if is_among(guid, structure['players']['Blue'], ['pv_board', 'pv_board_zone', 'VP 4 Players']):
                translate(object_state, (0, 0, -2))
            elif is_among(guid, structure['players']['Blue'], ['trash']):
                translate(object_state, (-10, 0.2, 6))
        elif guid in structure_guids['Red']:
            translate(object_state, (-2, -2.1, -2.8))
            if is_among(guid, structure['players']['Red'], ['pv_board', 'pv_board_zone', 'VP 4 Players']):
                translate(object_state, (0, 0, -2))
            elif is_among(guid, structure['players']['Red'], ['trash']):
                translate(object_state, (-10, 0.2, 6))

        new_object_states.append(object_state)

    for object_state in additional_object_states:
        new_object_states.append(object_state)

    # AttachedSnapPoints

    save['ObjectStates'] = new_object_states

    with open("2702663883.patched.json", "w") as new_save:
        new_save.write(json.dumps(save, indent = 2))

patch_save()
