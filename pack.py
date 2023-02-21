import json
import sys

tts_tmp_dir = '/tmp/TabletopSimulator/Tabletop Simulator Lua'

def inject_script_and_UI(name, id, element):
    file_name = tts_tmp_dir + '/' + name + '.' + str(id)

    if element['LuaScript'] == '...':
        try:
            with open(file_name + '.ttslua', 'r') as script_file:
                element['LuaScript'] = script_file.read()
        except FileNotFoundError:
            print("Script Lua", file_name, "introuvable.", file = sys.stderr)

    if element['XmlUI'] == '...':
        try:
            with open(file_name + '.xml', 'r') as script_file:
                element['XmlUI'] = script_file.read()
        except FileNotFoundError:
            print("Description UI XML", file_name, "introuvable.", file = sys.stderr)

def pack_save(save_file_name):
    save = None
    with open(save_file_name, 'r') as save_file:
        save = json.load(save_file)

    inject_script_and_UI('Global', -1, save)

    object_states = save['ObjectStates']

    for object_state in object_states:
        name = object_state['Nickname']
        if not name:
            name = object_state['Name']
        inject_script_and_UI(name, object_state['GUID'], object_state)
        if 'States' in object_state:
            for _, state in object_state['States'].items():
                name = state['Nickname']
                if not name:
                    name = state['Name']
                inject_script_and_UI(name, state['GUID'], state)

    print(json.dumps(save, indent = 2))

assert len(sys.argv) == 2
pack_save(sys.argv[1])
