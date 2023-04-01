import copy
import json
import sys

colors = ['Green', 'Yellow', 'Blue', 'Red']

anchor_decal = (1, {
    "Name": "First Player Token Slot",
    #"ImageURL": "file:///home/sadalsuud/Personnel/Productions/Code/Maison/DuneImperiumTTS/misc/anchor_decal.png",
    "ImageURL": "http://cloud-3.steamusercontent.com/ugc/2042984592862621000/8C42D07B62ACE707EF3C206E9DFEA483821ECFD8/",
    "Size": 0.5
})

first_player_decal = (1, {
    "Name": "Deck Slot",
    #"ImageURL": "file:///home/sadalsuud/Personnel/Productions/Code/Maison/DuneImperiumTTS/misc/first_player_decal.png",
    "ImageURL": "http://cloud-3.steamusercontent.com/ugc/2042984592862631937/B2176FBF3640DC02A6840C8E0FB162057724DE41/",
    "Size": 2
})

draw_decal = (0.6933962, {
    "Name": "Deck Slot",
    #"ImageURL": "file:///home/sadalsuud/Personnel/Productions/Code/Maison/DuneImperiumTTS/misc/deck_decal.png",
    "ImageURL": "http://cloud-3.steamusercontent.com/ugc/2042984592862630696/9973F87497827C194B979D7410D0DD47E46305FA/",
    "Size": 3.5
})

discard_decal =  (0.6933962, {
    "Name": "Discard Slot",
    #"ImageURL": "file:///home/sadalsuud/Personnel/Productions/Code/Maison/DuneImperiumTTS/misc/discard_decal.png",
    "ImageURL": "http://cloud-3.steamusercontent.com/ugc/2042984592862631187/76205DFA6ECBC5F9C6B38BE95F42E6B5468B5999/",
    "Size": 3.5
})

leader_decal = (1.462555, {
    "Name": "Leader Slot",
    #"ImageURL": "file:///home/sadalsuud/Personnel/Productions/Code/Maison/DuneImperiumTTS/misc/leader_decal.png",
    "ImageURL": "http://cloud-3.steamusercontent.com/ugc/2042984592862632410/7882B2E68FF7767C67EE5C63C9D7CF17B405A5C3/",
    "Size": 3.5
})

tech_decal = (1.45631063, {
    "Name": "Tech Tile Slot",
    #"ImageURL": "file:///home/sadalsuud/Personnel/Productions/Code/Maison/DuneImperiumTTS/misc/tech_tile_decal.png",
    "ImageURL": "http://cloud-3.steamusercontent.com/ugc/2042984592862632706/6A948CDC20774D0D4E5EA0EFF3E0D2C23F30FCC1/",
    "Size": 1.8
})

left_scoreboard_decal = (20, {
    "Name": "Left Scoreboard",
    #"ImageURL": "file:///home/sadalsuud/Personnel/Productions/Code/Maison/DuneImperiumTTS/misc/left_scoreboard_decal.png",
    "ImageURL": "http://cloud-3.steamusercontent.com/ugc/2042984690511948114/BD4C6DB374A73A3A1586E84DD94DD2459EB51782/",
    "Size": 1.1
})

right_scoreboard_decal = (20, {
    "Name": "Right Scoreboard",
    #"ImageURL": "file:///home/sadalsuud/Personnel/Productions/Code/Maison/DuneImperiumTTS/misc/right_scoreboard_decal.png",
    "ImageURL": "http://cloud-3.steamusercontent.com/ugc/2042984690511949009/00AEA6A9B03D893B1BF82EFF392448FD52B8C70E/",
    "Size": 1.1
})

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
        'character_zone': (-8.5, 0),
        'draw_deck': (-13.5, -1),
        'draw_deck_zone': (-13.5, -1),
        'discard_deck_zone': (-3.5, -1),

        'spice_counter': (-10.5, -3),
        'water_counter': (-8.5, -3.5),
        'solari_counter': (-6.5, -3)
    },
    'unchanged': {
        #'pv_board': (200+0, 0),
        #'pv_board_zone': (200+0, 0)
    },
    'symmetrical': {
        'VP 4 Players': (-14.5, 4.35),

        'agent_and_reveal_zone': (0, -11),
        'tech_board_zone': (6, -0.5),
        'trash': (12, -1),
        'hand_trigger': (0, -15),

        'first_player_zone': (-13.5, 2.2),
        'banner_bag': (0, 0),
        'councilor': (0, 2.5),
        'agents/0': (-10.5, 2.8),
        'agents/1': (-9.2, 2.8),
        'dreadnoughts/0': (-1.2, 1.2),
        'dreadnoughts/1': (1.2, 1.2),
        'ix_atomics': (0, -3.8),

        #'troup_zone': (-3.5, 3.3),
        #'troup_bowl': (200-3.5, 3.3),
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
    'draw_deck_zone': (-1, 2, -1),
    'character_zone': (6, 2, 4.5),
    'discard_deck_zone': (3, 2, 7),
    'agent_and_reveal_zone': (31, -1, 12),
    'tech_board_zone': (6, 2, 6),
    'hand_trigger': (31, 5, 4),
    'first_player_zone': (2, 1, 2)
}

def layout_player_board(structure, object_by_guid, color):

    if color == 'Green':
        board = object_by_guid['0bbae1']
        xOrigin = 27.5
        zOrigin = 11.5
        unchanged_x = lambda x : xOrigin + x
        offseted_x = lambda x : xOrigin + x
        symmetrical_x = lambda x : xOrigin + x
    elif color == 'Yellow':
        board = object_by_guid['fdd5f9']
        xOrigin = 27.5
        zOrigin = -11.5
        unchanged_x = lambda x : xOrigin + x
        offseted_x = lambda x : xOrigin + x
        symmetrical_x = lambda x : xOrigin + x
    elif color == 'Blue':
        board = object_by_guid['77ca63']
        xOrigin = -27.5
        zOrigin = -11.5
        unchanged_x = lambda x : xOrigin + x
        offseted_x = lambda x : xOrigin + 17 + x
        symmetrical_x = lambda x : xOrigin - x
    elif color == 'Red':
        board = object_by_guid['adcd28']
        xOrigin = -27.5
        zOrigin = 11.5
        unchanged_x = lambda x : xOrigin + x
        offseted_x = lambda x : xOrigin + 17 + x
        symmetrical_x = lambda x : xOrigin - x

    root = structure['players'][color]

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
    board['Decals'] = []

    def add_snap_point(key, transform_x, xOffset = 0, zOffset = 0, rotated = False, with_decal = False, with_tag = None):
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
        if with_tag:
            snap_point["Tags"] = [with_tag]
        board['AttachedSnapPoints'].append(snap_point)
        if with_decal:
            size = with_decal[1]['Size']
            decal = {
                "Transform": {
                    "posX": -xPos + board['Transform']['posX'],
                    "posY": 0.68 + board['Transform']['posY'],
                    "posZ": -zPos + board['Transform']['posZ'],
                    "rotX": 90,
                    "rotY": 0,
                    "rotZ": 0,
                    "scaleX": size * with_decal[0],
                    "scaleY": size,
                    "scaleZ": size
                },
                "CustomDecal": with_decal[1]
            }
            object_by_guid[-1]['Decals'].append(decal)

    def extrapolate(src_key, dst_key, factor):
        src_transform = object_by_guid[getGUID(src_key)]['Transform']
        dst_transform = object_by_guid[getGUID(dst_key)]['Transform']
        srcX =  src_transform['posX']
        srcZ =  src_transform['posZ']
        dstX =  dst_transform['posX']
        dstZ =  dst_transform['posZ']
        posX = srcX + (dstX - srcX) * factor
        posZ = srcZ + (dstZ - srcZ) * factor
        return (posX, posZ)

    add_snap_point('first_player_zone', unchanged_x, with_decal = first_player_decal)
    add_snap_point('character_zone', unchanged_x, with_tag = "Leader", with_decal = leader_decal)
    add_snap_point('draw_deck', unchanged_x, with_tag = "Imperium", with_decal = draw_decal)
    add_snap_point('discard_deck_zone', unchanged_x, with_tag = "Imperium", with_decal = discard_decal)
    add_snap_point('agents/0', unchanged_x, with_tag = "Agent", with_decal = anchor_decal)
    add_snap_point('agents/1', unchanged_x, with_tag = "Agent", with_decal = anchor_decal)
    (x, z) = extrapolate('agents/0', 'agents/1', 2)
    add_snap_point(None, unchanged_x, x, z, with_decal = anchor_decal)
    (x, z) = extrapolate('agents/0', 'agents/1', 3)
    add_snap_point(None, unchanged_x, x, z, with_decal = anchor_decal)
    add_snap_point('dreadnoughts/0', unchanged_x, rotated = True, with_decal = anchor_decal)
    add_snap_point('dreadnoughts/1', unchanged_x, rotated = True, with_decal = anchor_decal)

    for i in range(0, 18):
        add_snap_point('VP 4 Players', symmetrical_x, i * 1.092, 0)

    for i in range(0, 24):
        add_snap_point('agent_and_reveal_zone', symmetrical_x, (i % 12) * 2.5 - 13, (i // 12) * 4)

    for i in range(0, 6):
        add_snap_point('tech_board_zone', symmetrical_x, (i // 3) * 3 - 1.5, (i % 3) * 2 - 2, with_decal = tech_decal)

    if True:
        if color == 'Green' or color == 'Yellow':
            decal = right_scoreboard_decal
        else:
            decal = left_scoreboard_decal
        size = decal[1]['Size']
        decal = {
            "Transform": {
                "posX": symmetrical_x(-4.5),
                "posY": 1.15,
                "posZ": zOrigin + 10.35,
                "rotX": 90,
                "rotY": 0,
                "rotZ": 0,
                "scaleX": size * decal[0],
                "scaleY": size,
                "scaleZ": size
            },
            "CustomDecal": decal[1]
        }
        object_by_guid[-1]['Decals'].append(decal)

def add_space_snap_points(structure, object_by_guid):

    board = object_by_guid[structure["base"]["board"]]

    def add_snap_point(guid, xOffset = 0, zOffset = 0, with_tag = None):
        object = object_by_guid[guid]
        xPos = xOffset - (object['Transform']['posX'] - board['Transform']['posX']) / board['Transform']['scaleX']
        zPos = zOffset - (object['Transform']['posZ'] - board['Transform']['posZ']) / board['Transform']['scaleZ']
        yRot = 0.0
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
        if with_tag:
            snap_point["Tags"] = [with_tag]
        board['AttachedSnapPoints'].append(snap_point)

    for _, guid in structure["base"]["spaces"].items():
        add_snap_point(guid, -0.05, -0.05, "Agent")
        add_snap_point(guid, 0.05, 0.05, "Agent")

    for _, guid in structure["ix"]["spaces"].items():
        add_snap_point(guid, -0.05, -0.20, "Agent")
        add_snap_point(guid, 0.05, -0.10, "Agent")
        add_snap_point(guid, -0.05, 0.10, "Agent")
        add_snap_point(guid, 0.05, 0.20, "Agent")

def add_combat_force_snap_points(structure, object_by_guid):

    board_guid = structure["base"]["board"]
    board = object_by_guid[board_guid]
    origin = object_by_guid[structure['base']['combat']['combat_tokens_zone']]

    if not 'AttachedSnapPoints' in board:
        board['AttachedSnapPoints'] = []

    def add_snap_point(xOffset = 0, zOffset = 0):
        xPos = -(xOffset + origin['Transform']['posX']) / board['Transform']['scaleX'] - board['Transform']['posX']
        zPos = (zOffset + origin['Transform']['posZ']) / board['Transform']['scaleZ'] - board['Transform']['posZ']
        yRot = 0.0
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
            },
            "Tags": [
                "CombatTokens"
            ]
        }
        board['AttachedSnapPoints'].append(snap_point)

    for i in range(0, 20):
        add_snap_point(
            -0.47 + (i % 10) * 0.90,
            -1.63 - (i // 10) * 1.01)

def add_card_snap_points(structure, object_by_guid, save):
    imperium_row = structure["imperium_row"]

    imperium_slots = {
#        "Foldspace Deck",
#        "foldspace_deck_zone",
        "Arrakis Liaison Deck",
        "The Spice Must Flow Deck",
        "the_spice_must_flow_deck_anchor",
        "Deck",
        "buy1_anchor",
        "buy2_anchor",
        "buy3_anchor",
        "buy4_anchor",
        "buy5_anchor",
    }

    for slot in imperium_slots:
        object = object_by_guid[imperium_row[slot]]
        save["SnapPoints"].append({
            "Position": {
                "x": object['Transform']['posX'],
                "y": object['Transform']['posY'],
                "z": object['Transform']['posZ']
            },
            "Rotation": {
                "x": 0.0,
                "y": 180.0,
                "z": 0.0
            },
            "Tags": ["Imperium"]
        })

    immortality_row = structure["immortality_row"]

    immortality_slots = {
        "deck",
        "pay1_anchor",
        "pay2_anchor"
    }

    for slot in immortality_slots:
        object = object_by_guid[immortality_row[slot]]
        save["SnapPoints"].append({
            "Position": {
                "x": object['Transform']['posX'],
                "y": object['Transform']['posY'],
                "z": object['Transform']['posZ']
            },
            "Rotation": {
                "x": 0.0,
                "y": 180.0,
                "z": 0.0
            },
            "Tags": ["Imperium"]
        })

def add_flag_snap_points(structure, object_by_guid):
    board_guid = structure["base"]["board"]
    board = object_by_guid[board_guid]

    if not 'AttachedSnapPoints' in board:
        board['AttachedSnapPoints'] = []

    for (x, y) in [(-0.4, -0.48), (-1.05, -0.61), (-1, -0.04)]:
        board['AttachedSnapPoints'].append({
            "Position": {
                "x": x,
                "y": 0.2,
                "z": y
            },
            "Rotation": {
                "x": 0.0,
                "y": 180.0,
                "z": 0.0
            }
        })

def add_tech_tile_snap_points(structure, object_by_guid):
    board_guid = structure["ix"]["Board Planet Ix"]
    board = object_by_guid[board_guid]

    if not 'AttachedSnapPoints' in board:
        board['AttachedSnapPoints'] = []

    for i in range(0, 3):
        board['AttachedSnapPoints'].append({
            "Position": {
                "x": -0.5,
                "y": 0,
                "z": 0.5 - i * 0.6
            },
            "Rotation": {
                "x": 0.0,
                "y": 0.0,
                "z": 0.0
            }
        })

def filterSnapPoints(object):
    accepted_tags = ['Agent', 'Mentat']
    if 'AttachedSnapPoints' in object:
        object['AttachedSnapPoints'] = list(filter(
            lambda snapPoint: 'Tags' in snapPoint and all(tag in accepted_tags for tag in snapPoint['Tags']),
            object['AttachedSnapPoints']))

def layout_fan_made_characters(structure, object_by_guid):
    bx = 0
    by = 0
    bz = 0
    count = 0
    for _, v in structure['fanbase_characters']['characters'].items():
        object = object_by_guid[v]
        bx += object['Transform']['posX']
        by += object['Transform']['posY']
        bz += object['Transform']['posZ']
        count += 1
    bx /= count
    by /= count
    bz /= count

    for _, v in structure['fanbase_characters']['characters'].items():
        object = object_by_guid[v]
        x = (object['Transform']['posX'] - bx) * 1.1 + bx
        y = (object['Transform']['posY'] - by) * 1.1 + by
        z = (object['Transform']['posZ'] - bz) * 1.1 + bz
        set_position(object, (x, y, z))

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

def replace(object, blank_clone):
    clone = copy.deepcopy(blank_clone)
    clone['GUID'] = object['GUID']
    clone['Locked'] = True
    for coordinate in ['posX', 'posY', 'posZ']:
        clone['Transform'][coordinate] = object['Transform'][coordinate]
    for coordinate in ['rotX', 'rotY', 'rotZ']:
        clone['Transform'][coordinate] = object['Transform'][coordinate]
    clone['Nickname'] = object['Nickname']
    for property in ['Description', 'LuaScript', 'LuaScriptState', 'XmlUI', 'ContainedObjects']:
        if property in object:
            clone[property] = object[property]
    return clone

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
    save["DecalPallet"] = [
        anchor_decal[1],
        draw_decal[1],
        discard_decal[1],
        leader_decal[1],
        tech_decal[1],
        left_scoreboard_decal[1],
        right_scoreboard_decal[1]
    ]
    save['Decals'] = []

    save["SkyURL"] = "http://cloud-3.steamusercontent.com/ugc/2023842395829093107/112311E29FB3F46CE91BC1998D2B005DAA1AAE2E/"

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
        '2b2575',
        # Texte de la maison Hagal
        '328efa',
        # Bols de troupes
        '6af67a',
        '8ea4af',
        '126c3c',
        'b71dd9',
        # Zones de troupes
        'bdfade',
        'ffbd81',
        '2a520c',
        'ab8fdf',
        # Plateaux de PV
        "caaba4",
        "99a860",
        "121bb6",
        "e0ed4b",
        # Zones des plateaux de PV
        "0e374f",
        "b25c3c",
        "376f34",
        "5b9a53"
    ]

    additional_objects = []
    additional_character_table = None
    anchor_object = None
    trash_object = None

    global_translation = (0, 1.6, 0)

    for object in patch['ObjectStates']:
        if object['Nickname'] == "anchor":
            anchor_object = object
        if object['Nickname'] == "Trash":
            trash_object = object
        elif object['Name'] == 'Custom_Assetbundle':
            if object['GUID'] == '662ced':
                assert not additional_character_table
                additional_character_table = object
            if object['Nickname'].startswith('PlayerBoard'):
                object['LuaScript'] = '...'
            else:
                object['LuaScript'] = 'self.interactable = false\r\n'
            object['Transform']['posY'] -= 1
            if object['GUID'] != '200785':
                object['Transform']['posY'] -= 0.75
            translate(object, global_translation)
            additional_objects.append(object)
        elif object['Name'] == 'ScriptingTrigger':
            additional_objects.append(object)
        elif object['Name'] == "HandTrigger":
            pass
        else:
            #print('skipping', object['Name'])
            pass

    assert additional_character_table
    assert anchor_object
    assert trash_object

    objects = save['ObjectStates']
    new_objects = []
    object_by_guid = {}

    object_by_guid[-1] = save

    for object in objects:
        if 'States' in object:
            for _, state in object['States'].items():
                if noLuaScript:
                    state['Locked'] = True
                    state['LuaScript'] = ''
                state['LuaScriptState'] = ''
                state['XmlUI'] = ''
                filterSnapPoints(state)
                rectify_rotation(state)

        guid = object['GUID']

        if guid in guids_to_be_removed:
            if guid == 'bd69bd':
                pass
            elif guid == '5a682a':
                # On préserve néanmoins ses scripts Lua.
                additional_character_table['LuaScript'] = object['LuaScript']
                #additional_character_table['LuaScriptState'] = object['LuaScriptState']
                #additional_character_table['XmlUI'] = object['XmlUI']
            else:
                #assert object['LuaScript'] == ''
                #assert object['LuaScriptState'] == ''
                #assert object['XmlUI'] == ''
                if guid == 'ef8614':
                    other_kind_of_trash = object_by_guid['cf6ca1']
                    if not 'ContainedObjects' in other_kind_of_trash:
                        other_kind_of_trash['ContainedObjects'] = []
                    for contained_object in object['ContainedObjects']:
                        other_kind_of_trash['ContainedObjects'].append(contained_object)
                else:
                    assert not 'ContainedObjects' in object
            continue

        if noLuaScript:
            object['Locked'] = True
            object['LuaScript'] = ''
        object['LuaScriptState'] = ''
        object['XmlUI'] = ''
        filterSnapPoints(object)

        if guid in anchor_guids:
            object = replace(object, anchor_object)

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
            if guid == structure['bottom_accessories']['trash']:
                y = object['Transform']['posY']
                z = object['Transform']['posZ']
                set_position(object, (0, y, z - 1))

        elif guid in structure_guids['immortality_row'] or guid in structure_guids['imperium_row'] or guid in structure_guids['intrigue']:
            translate(object, (0, -2.5, -4))
        elif guid in structure_guids['ix'] or guid in structure_guids['immortality']:
            translate(object, (0, -2.5, -4))
        elif guid in structure_guids['base']:
            translate(object, (0, -2.5, -4))
            for color in colors:
                if guid == structure["base"]["players"][color]["ix_cargo"]:
                    object['Locked'] = True
                    object['Transform']['RotY'] = 270

        elif guid in structure_guids['Green']:
            green = structure['players']['Green']
            if not is_among(guid, green, ['hand_trigger']):
                translate(object, (2, -2.1, -2.8))
            if is_among(guid, green, ['spice_counter', 'water_counter', 'solari_counter']):
                translate(object, (0, -0.1, 0))
            elif is_among(guid, green, ['pv_board', 'pv_board_zone', 'VP 4 Players']):
                translate(object, (0, 0, -2))
            elif is_among(guid, green, ['trash']):
                translate(object, (10, 0.15, 6))
                object = replace(object, trash_object)
        elif guid in structure_guids['Yellow']:
            yellow = structure['players']['Yellow']
            if not is_among(guid, yellow, ['hand_trigger']):
                translate(object, (2, -2.1, -4))
            if is_among(guid, yellow, ['spice_counter', 'water_counter', 'solari_counter']):
                translate(object, (0, -0.1, 0))
            elif is_among(guid, yellow, ['pv_board', 'pv_board_zone', 'VP 4 Players']):
                translate(object, (0, 0, -2))
            elif is_among(guid, yellow, ['trash']):
                translate(object, (10, 0.15, 6))
                object = replace(object, trash_object)
        elif guid in structure_guids['Blue']:
            blue = structure['players']['Blue']
            if not is_among(guid, blue, ['hand_trigger']):
                translate(object, (-2, -2.1, -4))
            if is_among(guid, blue, ['spice_counter', 'water_counter', 'solari_counter']):
                translate(object, (0, -0.1, 0))
            elif is_among(guid, blue, ['pv_board', 'pv_board_zone', 'VP 4 Players']):
                translate(object, (0, 0, -2))
            elif is_among(guid, blue, ['trash']):
                translate(object, (-10, 0.15, 6))
                object = replace(object, trash_object)
        elif guid in structure_guids['Red']:
            red = structure['players']['Red']
            if not is_among(guid, red, ['hand_trigger']):
                translate(object, (-2, -2.1, -2.8))
            if is_among(guid, red, ['spice_counter', 'water_counter', 'solari_counter']):
                translate(object, (0, -0.1, 0))
            elif is_among(guid, red, ['pv_board', 'pv_board_zone', 'VP 4 Players']):
                translate(object, (0, 0, -2))
            elif is_among(guid, red, ['trash']):
                translate(object, (-10, 0.15, 6))
                object = replace(object, trash_object)

        new_objects.append(object)
        object_by_guid[guid] = object

    for object in additional_objects:
        new_objects.append(object)
        object_by_guid[object['GUID']] = object

    for color in colors:
        layout_player_board(structure, object_by_guid, color)

    layout_fan_made_characters(structure, object_by_guid)

    #add_space_snap_points(structure, object_by_guid)
    add_combat_force_snap_points(structure, object_by_guid)
    add_card_snap_points(structure, object_by_guid, save)
    add_tech_tile_snap_points(structure, object_by_guid)
    add_flag_snap_points(structure, object_by_guid)
    clean_up_bottom(structure, object_by_guid)

    save['ObjectStates'] = new_objects

    with open(output_path, 'w') as new_save:
        new_save.write(json.dumps(save, indent = 2))

assert len(sys.argv) == 3
patch_save(sys.argv[1], sys.argv[2])
