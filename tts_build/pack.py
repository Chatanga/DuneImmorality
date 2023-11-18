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
            element.pop('LuaScript')

    if element['XmlUI'] == '...':
        try:
            with open(file_name + '.xml', 'r') as script_file:
                element['XmlUI'] = script_file.read()
        except FileNotFoundError:
            print("Description UI XML", file_name, "introuvable.", file = sys.stderr)
            element.pop('XmlUI')

def pack_save(input_save_file_name, output_save_file_name, date):
    save = None
    with open(input_save_file_name, 'r') as save_file:
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

    save['Date'] = date

    with open(output_save_file_name, 'w') as save_file:
        print(json.dumps(save, indent = 2), file = save_file)
