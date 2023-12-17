import glob
import json
import os

def extract_script_and_UI(tts_tmp_dir, name, id, element):
    file_name = os.path.join(tts_tmp_dir, name + '.' + str(id))

    if element.get('LuaScript'):
        with open(file_name + '.ttslua', 'w') as script_file:
            script_file.write(element['LuaScript'])
        element['LuaScript'] = "..."
        #element['LuaScriptState'] = ""

    if element.get('XmlUI'):
        with open(file_name + '.xml', 'w') as script_file:
            script_file.write(element['XmlUI'])
        element['XmlUI'] = "..."

def unpack_save(tts_tmp_dir, input_save_file_name, output_save_file_name):
    os.makedirs(tts_tmp_dir, exist_ok = True)

    for f in glob.glob(os.path.join(tts_tmp_dir, '*')):
        os.remove(f)

    save = None
    with open(input_save_file_name, 'r') as save_file:
        save = json.load(save_file)

    extract_script_and_UI(tts_tmp_dir, 'Global', -1, save)

    object_states = save['ObjectStates']

    for object_state in object_states:
        name = object_state['Nickname']
        if not name:
            name = object_state['Name']
        extract_script_and_UI(tts_tmp_dir, name, object_state['GUID'], object_state)
        if 'States' in object_state:
            for _, state in object_state['States'].items():
                name = state['Nickname']
                if not name:
                    name = state['Name']
                extract_script_and_UI(tts_tmp_dir, name, state['GUID'], state)

    with open(output_save_file_name, 'w') as save_file:
        print(json.dumps(save, indent = 2), file = save_file)
