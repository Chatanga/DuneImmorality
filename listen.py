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
    if id == 0:
        debug("Pushing new object.")
        pass
    elif id == 1:
        debug("Loading new game.")
        pass
    elif id == 2:
        # Messages could be received out of order compared to the ingame log, which is weird with a locale TCP connection...
        body = message['message']
        info(body)
    elif id == 3:
        errorMessage = message['error']
        result = re.search('([^:]*):\((\d+),(\d+)-(\d+)(,(\d+))?\): (.*)', errorMessage)
        if result:
            try:
                startLineNumber = int(result.group(2))
                startColNumber = int(result.group(3)) + 1
                if result.group(5):
                    endLineNumber = int(result.group(4)) + 1
                    endColNumber = int(result.group(6)) + 1
                else:
                    endLineNumber = startLineNumber
                    endColNumber = int(result.group(4)) + 1
                errorMessage = result.group(7)
                startLocation = relocate(startLineNumber)
            except:
                for i in range(1, 7):
                    print(i, '->', result.group(i))
                startLocation = None
        else:
            startLocation = None
        if startLocation:
            file, lineNumber = startLocation
            error(f'{file}:{lineNumber}:{startColNumber}: {errorMessage}')
        else:
            error(errorMessage)
    elif id == 4:
        customMessage = message['customMessage']
        debug(f'> {customMessage}')
        pass
    elif id == 5:
        returnValue = message['returnValue']
        debug(f'< {returnValue}')
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
                        file = 'scripts/Global.-1.lua'
                    else:
                        file = 'scripts/modules/' + file.replace('.', '/') + '.lua'
                    file_origin = i
            else:
                return None

listen('127.0.0.1', 39998)
