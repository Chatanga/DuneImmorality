import json
import os
import re
import sys

guid_pattern = re.compile('["\'][0-9a-f]{6}["\']')

def collect_position(state, positions):
    guid = state['GUID']
    transform = state['Transform']
    position = (
        float(transform['posX']),
        float(transform['posY']),
        float(transform['posZ']))
    positions[guid] = position

def collect_positions(save_file_name):
    save = None
    with open(save_file_name, 'r') as save_file:
        save = json.load(save_file)

    positions = {}

    object_states = save['ObjectStates']

    for object_state in object_states:
        collect_position(object_state, positions)

        if 'States' in object_state:
            for _, state in object_state['States'].items():
                collect_position(state, positions)

    return positions

def expand_in_scripts(positions, script_dir):
    for root, _, files in os.walk(script_dir):
        for filename in files:
            file_path = os.path.join(root, filename)
            with open(file_path, 'r') as f:
                content = f.read()
                (expansion_count, new_content) = process(positions, filename, content)
                if expansion_count > 0:
                    with open(file_path + ".patched.ttslua", 'w') as f:
                        f.write(new_content)
                    print(str(expansion_count) + " expansions in " + filename)

def process(positions, filename, content):
    function_name = "getHardcodedPositionFromGUID"

    expansion_count = 0
    new_content = ""

    from_index = 0
    while True:
        start_index = content.find(function_name + "(", from_index)
        new_from_index = from_index
        if start_index != -1:
            prefix_length = len(function_name + "(")
            new_from_index = start_index + prefix_length + 1
            skip = False
            declaration_prefix = 'function constants.'
            if start_index >= len(declaration_prefix) and content[start_index - len(declaration_prefix) : start_index] == declaration_prefix:
                skip = True
            else:
                end_index = content.find(")", new_from_index)
                if end_index != -1:
                    new_from_index = end_index + 1
                    tokens = content[start_index + prefix_length : end_index].split(',')
                    if guid_pattern.match(tokens[0]):
                        guid = tokens[0][1:-1]
                        if guid in positions:
                            (x, y, z) = positions[guid]
                            expansion = function_name + "('" + guid + "', " + str(x) + ", " + str(y) + ", " + str(z) + ")"
                            new_content += content[from_index : start_index]
                            new_content += expansion
                            from_index = new_from_index
                            expansion_count += 1
                        else:
                            skip = True
                            print("Unknown GUID in file " + filename + ": " + guid)
                    else:
                        skip = True
                        print("Ill-formed GUID in file " + filename + ": " + tokens[0])
                else:
                    skip = True
                    print("Ill-formed getHardcodedPositionFromGUID call in file " + filename)
            if skip:
                new_content += content[from_index : new_from_index]
                from_index = new_from_index
        else:
            break

    new_content += content[from_index:]

    return (expansion_count, new_content)

assert len(sys.argv) == 3
positions = collect_positions(sys.argv[1])
expand_in_scripts(positions, sys.argv[2])
