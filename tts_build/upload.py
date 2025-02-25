#!/usr/bin/python3

import json
import os
import socket
import sys

def saveAndPlay(host, port, request):
    print('Sending save to TTS.')
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.connect((host, port))
    server.sendall(bytes(json.dumps(request), 'utf-8'))
    server.close()

def collect_script_and_UI(tts_tmp_dir, name, id, element, scriptStates):
    file_name = os.path.join(tts_tmp_dir, name + '.' + str(id))

    scriptState = {
        "name": name,
        "guid": id
    }

    if element.get('LuaScript') == '...':
        try:
            with open(file_name + '.ttslua', 'r', encoding='utf-8') as script_file:
                scriptState['script'] = script_file.read()
        except FileNotFoundError:
            print("Script Lua", file_name, "introuvable.", file = sys.stderr)
            element.pop('LuaScript')

    if element.get('XmlUI') == '...':
        try:
            with open(file_name + '.xml', 'r', encoding='utf-8') as script_file:
                scriptState['ui'] = script_file.read()
        except FileNotFoundError:
            print("Description UI XML", file_name, "introuvable.", file = sys.stderr)
            element.pop('XmlUI')

    scriptStates.append(scriptState)

def browse_save(tts_tmp_dir, save_file_name, scriptStates):
    save = None
    with open(save_file_name, 'r', encoding='utf-8') as save_file:
        save = json.load(save_file)

    collect_script_and_UI(tts_tmp_dir, 'Global', -1, save, scriptStates)

    object_states = save['ObjectStates']

    for object_state in object_states:
        name = object_state['Nickname']
        if not name:
            name = object_state['Name']
        collect_script_and_UI(tts_tmp_dir, name, object_state['GUID'], object_state, scriptStates)
        if 'States' in object_state:
            for _, state in object_state['States'].items():
                name = state['Nickname']
                if not name:
                    name = state['Name']
                collect_script_and_UI(tts_tmp_dir, name, state['GUID'], state, scriptStates)

# netstat -tlpn
def upload(tts_tmp_dir, save_file_name):
    scriptStates = []
    browse_save(tts_tmp_dir, save_file_name, scriptStates)
    saveAndPlay('127.0.0.1', 39999, {
        "messageID": 1,
        "scriptStates": scriptStates
    })
