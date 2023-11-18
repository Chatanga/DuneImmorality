#! /usr/bin/python3

import argparse
import os
import platform
import re
import shutil
import subprocess
import sys
from datetime import datetime

import tts_build.expand
import tts_build.pack
import tts_build.patch
import tts_build.unpack
import tts_build.upload

# Same folder as the one used by the Atom plugin for historical reasons.
# Any other location would be fine.
tts_tmp_dir='/tmp/TabletopSimulator/Tabletop Simulator Lua/'

# Requirements:
# - Python3
#	   https://www.python.org/downloads/
# - LuaBundler
#	   https://docs.npmjs.com/downloading-and-installing-node-js-and-npm
#	   https://github.com/Benjamin-Dobell/luabundler
def build():
	platform_system = platform.system()
	if platform_system == 'Linux':
		app_dir = os.path.join(os.environ['HOME'], '.local', 'share')
	elif platform_system == 'Window':
		app_dir = os.path.join(os.environ['USERPROFILE'], 'Documents', 'My Games')
	else:
		print('Unknown os: ' + platform_system, file = sys.stderr)
		exit(1)

	tts_save_dir = os.path.join(app_dir, 'Tabletop Simulator', 'Saves')

	# The 200 -> 201 pair is arbitrary.
	input_save = os.path.join(tts_save_dir, 'TS_Save_200.json')
	output_save = os.path.join(tts_save_dir, 'TS_Save_201.json')

	parser = argparse.ArgumentParser(
		prog = 'TSS Build Tool',
		description = 'Build a TSS save from an existing save and Lua modules.')
	parser.add_argument('-f', '--full', action='store_true', help = 'The complete workflow, instead of a simple update of the script parts.')
	parser.add_argument('-u', '--upload', action='store_true', help = 'Do not update the output save, but upload the scripts to TTS instead.')
	args = parser.parse_args()

	os.makedirs('tmp', exist_ok = True)

	timestamp = datetime.now().strftime("%m/%d/%Y %I:%M:%S %p")

	if args.full:
		importSave(input_save)
		unpack()
		unbundle()
		patch()
		#expand()

	bundle(timestamp)

	if args.upload:
		upload()
	else:
		pack(timestamp)
		exportSave(output_save)

def importSave(input_save):
	print("[importSave]")
	if os.path.exists(input_save):
		shutil.copyfile(input_save, 'input.mod.json')
	else:
		print("Boostrapping by creating " + input_save)
		shutil.copyfile('input.mod.json', input_save)

def unpack():
	print("[unpack]")
	tts_build.unpack.unpack_save('input.mod.json', os.path.join('tmp', 'mod.unscripted.json'))

def unbundle():
	print("[unbundle]")

	target = os.path.join('tmp', 'scripts')

	if os.path.exists(target) and os.path.isdir(target):
		shutil.rmtree(target)
	os.makedirs(os.path.join(target, 'modules'), exist_ok = True)

	for f in os.listdir(tts_tmp_dir):
		full_path = os.path.join(tts_tmp_dir, f)
		if os.path.isfile(full_path) and f.endswith('.ttslua'):
			filename = re.sub('\.ttslua$', '.lua', f)
			print("Unbundle " + f + "...")
			exitCode = subprocess.call([
				'luabundler', 'unbundle', full_path,
				'-m', os.path.join(target, 'modules'),
				'-o', os.path.join(target, filename)])
			if exitCode == 0:
				shutil.copyfile(full_path, os.path.join(target, filename))
			else:
				sys.exit(1)

def patch():
	print("[patch]")
	tts_build.patch.patch_save(os.path.join('tmp', 'mod.unscripted.json'), os.path.join('tmp', 'mod.unscripted.patched.json'))

def expand():
	print("[expand]")
	tts_build.expand.expand(os.path.join('tmp', 'mod.unscripted.patched.json'), 'scripts')

def bundle(timestamp):
	print("[bundle]")

	for f in os.listdir(tts_tmp_dir):
		full_path = os.path.join(tts_tmp_dir, f)
		if os.path.isfile(full_path) and f.endswith('.ttslua'):
			os.remove(full_path)

	for f in os.listdir('scripts'):
		full_path = os.path.join('scripts', f)
		if os.path.isfile(full_path) and f.endswith('.lua'):
			filename = re.sub('\.lua$', '', f)
			print("Bundle " + f + "...")
			exitCode = subprocess.call([
				'luabundler', 'bundle', full_path,
				'-p', os.path.join('scripts', 'modules', '?.lua'),
				'-o', os.path.join(tts_tmp_dir, filename + '.ttslua')])

			if exitCode == 0:
				if os.path.exists(os.path.join('scripts', filename + '.xml')):
					shutil.copyfile(os.path.join('scripts', filename + '.xml'), os.path.join(tts_tmp_dir, filename + '.xml'))
			else:
				sys.exit(1)

	luaFile = os.path.join(tts_tmp_dir, 'Global.-1.ttslua')
	with open (luaFile, 'r') as f:
		content = f.read()

	content_new = re.sub("local BUILD\s*=\s*.*", "local BUILD = '{}'".format(timestamp), content)

	with open (luaFile, 'w') as f:
		f.write(content_new)

def pack(timestamp):
	print("[pack]")
	tts_build.pack.pack_save(os.path.join('tmp', 'mod.unscripted.patched.json'), os.path.join('tmp', 'mod.patched.json'), timestamp)

def exportSave(output_save):
	print("[exportSave]")
	shutil.copyfile(os.path.join('tmp', 'mod.patched.json'), output_save)
	output_png_file = output_save.replace('.json', '.png')
	if not os.path.exists(output_png_file):
		shutil.copyfile('immorality.png', output_png_file)

def upload():
	print("[upload]")
	tts_build.upload.upload()

build()
