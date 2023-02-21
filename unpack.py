import glob
import json
import os
import sys

tts_tmp_dir = '/tmp/TabletopSimulator/Tabletop Simulator Lua'

os.makedirs(tts_tmp_dir, exist_ok = True)

for f in glob.glob(tts_tmp_dir + '/*'):
    os.remove(f)

def extract_script_and_UI(name, id, element):
    file_name = tts_tmp_dir + '/' + name + '.' + str(id)

    if element['LuaScript']:
        with open(file_name + '.ttslua', 'w') as script_file:
            script_file.write(element['LuaScript'])
        element['LuaScript'] = "..."

    if element['XmlUI']:
        with open(file_name + '.xml', 'w') as script_file:
            script_file.write(element['XmlUI'])
        element['XmlUI'] = "..."

def unpack_save(save_file_name):
    save = None
    with open(save_file_name, 'r') as save_file:
        save = json.load(save_file)

    extract_script_and_UI('Global', -1, save)

    object_states = save['ObjectStates']

    for object_state in object_states:
        name = object_state['Nickname']
        if not name:
            name = object_state['Name']
        extract_script_and_UI(name, object_state['GUID'], object_state)
        if 'States' in object_state:
            for _, state in object_state['States'].items():
                name = state['Nickname']
                if not name:
                    name = state['Name']
                extract_script_and_UI(name, state['GUID'], state)

    print(json.dumps(save, indent = 2))

assert len(sys.argv) == 2
unpack_save(sys.argv[1])
