#!/usr/bin/python3

import json
import re
import select
import socket
import sys

BUFFER_SIZE = 1024

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
                        handleMessage(json.load(data))
                    except Exception as e:
                        print(e)
                finally:
                    rxset.remove(sock)
                    sock.close()

def handleMessage(message):
    id = message['messageID']
    if id == 2:
        body = message['message']
        print('\033[94m', end = '')
        print(f'> {body}', end = '')
        print('\033[0m')
    elif id == 3:
        result = re.search('([^:]*):\((\d+),(\d+)-(\d+)\): (.*)', message['error'])
        lineNumber = result.group(2)
        startColNumber = int(result.group(3)) + 1
        endColNumber = int(result.group(4)) + 1
        location = relocate(int(lineNumber))
        if location:
            file, lineNumber = location
            error = message['error']
            print('\033[91m', file = sys.stderr, end = '')
            print(f'scripts/{file}:{lineNumber}:{startColNumber},{endColNumber}: {error}', file = sys.stderr, end = '')
            print('\033[0m', file = sys.stderr)
    else:
        print("Ignoring message with ID", id)

def relocate(lineNumber):
    file_origin = 0
    with open('tts.tmp/Global.-1.ttslua', 'r') as script_file:
        i = 0
        while True:
            line = script_file.readline()
            if line:
                i += 1
                if i == lineNumber:
                    return file, i - file_origin
                result = re.search('__bundle_register\("(.*)", function\(require, _LOADED, __bundle_register, __bundle_modules\)', line)
                if result:
                    file = result.group(1)
                    if file == '__root':
                        file = 'Global.-1.lua'
                    file_origin = i
            else:
                return None

listen('127.0.0.1', 39998)
