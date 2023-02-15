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

    if element['XmlUI']:
        with open(file_name + '.xml', 'w') as script_file:
            script_file.write(element['XmlUI'])

def unpack_save(save_file_name):
    save = None
    with open(save_file_name, 'r') as save_file:
        save = json.load(save_file)

    extract_script_and_UI('Global', -1, save)
    save.pop('LuaScript')
    save.pop('XmlUI')

    object_states = save['ObjectStates']

    for object_state in object_states:
        extract_script_and_UI(object_state['Nickname'], object_state['GUID'], object_state)
        object_state.pop('LuaScript')
        object_state.pop('XmlUI')

    print(json.dumps(save, indent = 2))

assert len(sys.argv) == 2
unpack_save(sys.argv[1])
