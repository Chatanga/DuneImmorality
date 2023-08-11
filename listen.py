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
                    data = bytearray()
                    while True:
                        packet = sock.recv(BUFFER_SIZE)
                        data.extend(packet)
                        if len(packet) < BUFFER_SIZE:
                            break
                    try:
                        handleMessage(json.loads(data.decode('utf-8')))
                    except Exception as e:
                        print(e)
                finally:
                    rxset.remove(sock)
                    sock.close()

def handleMessage(message):
    if message['messageID'] == 3:
        result = re.search('([^:]*):\((\d+),(\d+)-(\d+)\): (.*)', message['error'])
        lineNumber = result.group(2)
        colNumber = result.group(3)
        location = relocate(int(lineNumber))
        if location:
            file, lineNumber = location
            error = message['error']
            print(f'scripts/{file}:{lineNumber}:{colNumber}: {error}', file = sys.stderr)

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
