#! /usr/bin/python3

import json
import os
import re
import select
import socket
import sys

BUFFER_SIZE = 1024

tts_tmp_dir='tmp/scripts.bundled/'

def listen(host, port):
    print('Listening for TTS error messages...')
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.bind((host, port))
    server.listen(1)
    rxset = [server]

    while True:
        rxfds, _, _ = select.select(rxset, [], rxset)
        for sock in rxfds:
            if sock is server:
                connection, _ = server.accept()
                connection.setblocking(0)
                rxset.append(connection)
            else:
                try:
                    data = sock.makefile("rb")
                    try:
                        handle_message(json.load(data))
                    except Exception as e:
                        print(e)
                finally:
                    rxset.remove(sock)
                    sock.close()

def handle_message(message):
    id = message['messageID']
    if id == 0:
        debug("Pushing new object.")
        pass
    elif id == 1:
        debug("Loading new game.")
        pass
    elif id == 2:
        # Messages could be received out of order compared to the ingame log, which is weird with a locale TCP connection...
        body = message['message']
        if not log_exception(body):
            info(body)
    elif id == 3:
        error_message = message['error']
        if not log_exception(error_message):
            error(error_message)
    elif id == 4:
        custom_message = message['customMessage']
        debug(f'> {custom_message}')
        pass
    elif id == 5:
        return_value = message['returnValue']
        debug(f'< {return_value}')
    elif id == 6:
        debug("Game saved.")
    elif id == 7:
        guid = message['guid']
        debug(f'New object with GUID {guid}')
    else:
        print("Unknown message with ID", id)

def debug(message):
    print('\033[32m', end = '')
    print(message, end = '')
    print('\033[0m')

def info(message):
    print('\033[34m', end = '')
    print(message, end = '')
    print('\033[0m')

def error(message):
    print('\033[31m', file = sys.stderr, end = '')
    print(message, file = sys.stderr, end = '')
    print('\033[0m', file = sys.stderr)

def log_exception(message):
    result = re.search(r'([^:]*):\((\d+),(\d+)-(\d+)(,(\d+))?\): (.*)', message)
    if result:
        try:
            start_line_number = int(result.group(2))
            start_col_number = int(result.group(3)) + 1
            if result.group(5):
                end_line_number = int(result.group(4)) + 1
                end_col_number = int(result.group(6)) + 1
            else:
                end_line_number = start_line_number
                end_col_number = int(result.group(4)) + 1
            message = result.group(7)
            start_location = relocate(start_line_number)
        except:
            for i in range(1, 7):
                print(i, '->', result.group(i))
            start_location = None
    else:
        start_location = None
    if start_location:
        file, line_number = start_location
        error(f'{file}:{line_number}:{start_col_number}: {message}')
        return True
    else:
        return False

def relocate(line_ñumber):
    file_origin = 0
    with open(os.path.join(tts_tmp_dir, 'Global.-1.ttslua'), 'r', encoding='utf-8') as script_file:
        i = 0
        while True:
            line = script_file.readline()
            if line:
                i += 1
                if i == line_ñumber:
                    return file, i - file_origin
                result = re.search(r'__bundle_register\("(.*)", function\(require, _LOADED, __bundle_register, __bundle_modules\)', line)
                if result:
                    file = result.group(1)
                    if file == '__root':
                        file = os.path.join('scripts', 'Global.-1.lua')
                    else:
                        file = 'scripts/modules/' + file.replace('.', '/') + '.lua'
                    file_origin = i
            else:
                return None

listen('127.0.0.1', 39998)
