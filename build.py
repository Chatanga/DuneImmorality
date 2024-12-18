#! /usr/bin/python3

import argparse
import configparser
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
#tts_tmp_dir='/tmp/TabletopSimulator/Tabletop Simulator Lua/'
# Any other location would be fine.
tts_tmp_dir='tmp/scripts.bundled/'

# Requirements:
# - Python3
#	   https://www.python.org/downloads/
# - LuaBundler
#	   https://docs.npmjs.com/downloading-and-installing-node-js-and-npm
#	   https://github.com/Benjamin-Dobell/luabundler
def build():
	platform_system = platform.system()

	local_node_modules_path = os.path.exists('node_modules')

	linux_suffix = os.path.join('.local', 'share', 'Tabletop Simulator', 'Saves')
	windows_suffix = os.path.join('Documents', 'My Games', 'Tabletop Simulator', 'Saves')

	if platform_system == 'Linux':
		# 286160 is the Steam application ID for TTS
		proton_path = os.path.join('steamapps', 'compatdata', '286160', 'pfx', 'drive_c', 'users', 'steamuser')
		tts_save_dirs = [
			# Steam as a .deb + without Proton
			os.path.join(os.environ['HOME'], linux_suffix),
			# Steam as a Snap
			os.path.join(os.environ['HOME'], 'snap', 'steam', 'common', linux_suffix),
			# Steam as a .deb + with Proton
			os.path.join(os.environ['HOME'], '.local', 'share', 'Steam', proton_path, windows_suffix),
			# Steam as a .deb + with Proton (custom directory)
			os.path.join(os.environ['HOME'], 'Fast', 'SteamLibrary', proton_path, windows_suffix)
		]
		luabundler = 'node_modules/.bin/luabundler' if local_node_modules_path else 'luabundler'
	elif platform_system == 'Windows':
		tts_save_dirs = [
			os.path.join(os.environ['USERPROFILE'], 'OneDrive', windows_suffix),
			os.path.join(os.environ['USERPROFILE'], windows_suffix)
		]
		luabundler = 'node_modules/.bin/luabundler.cmd' if local_node_modules_path else 'luabundler.cmd'
	else:
		print('Unknown OS:', platform_system, file=sys.stderr)
		sys.exit(1)

	tts_save_dir = select_first_existing_path(tts_save_dirs)
	if tts_save_dir is None:
		print("No valid Tabletop Simulator 'Saves' directory found.", file=sys.stderr)
		sys.exit(1)

	config = configparser.ConfigParser()
	config.read('build.properties')
	save_input = config.get("save", "input")
	save_output = config.get("save", "output")

	input_save = os.path.join(tts_save_dir, f'{save_input}.json')
	output_save = os.path.join(tts_save_dir, f'{save_output}.json')

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
		unbundle(luabundler)
		patch()
		storeJson()

	bundle(luabundler, timestamp)

	if args.upload:
		upload()
	else:
		pack(timestamp)
		exportSave(output_save)

def select_first_existing_path(paths):
	for path in paths:
		if os.path.exists(path):
			return path

def importSave(input_save):
	print("[import]")
	if os.path.exists(input_save):
		shutil.copyfile(input_save, os.path.join('tmp', 'mod.unpatched.json'))
	else:
		raise("No save to import! Do not use the '--full' option here.")

def unpack():
	print("[unpack]")
	input_file_name = os.path.join('tmp', 'mod.unpatched.json')
	output_file_name = os.path.join('tmp', 'mod.unscripted.json')
	tts_build.unpack.unpack_save(tts_tmp_dir, input_file_name, output_file_name)

def unbundle(luabundler):
	print("[unbundle]")

	if os.path.exists('scripts'):
		target = os.path.join('tmp', 'scripts')
	else:
		print('Import directly into the source script directory since one does not exist.')
		target = 'scripts'

	if os.path.exists(target) and os.path.isdir(target):
		shutil.rmtree(target)
	os.makedirs(os.path.join(target, 'modules'), exist_ok = True)

	for f in os.listdir(tts_tmp_dir):
		full_path = os.path.join(tts_tmp_dir, f)
		if os.path.isfile(full_path) and f.endswith('.ttslua'):
			filename = re.sub(r'\.ttslua$', '.lua', f)
			print("Unbundle " + f + "...")
			try:
				exitCode = subprocess.call([
					luabundler, 'unbundle', full_path,
					'-m', os.path.join(target, 'modules'),
					'-o', os.path.join(target, filename)])
				if exitCode != 0:
					sys.exit(1)
			except:
				print('    (An error is ok if the script does not use require directives.)')
				shutil.copyfile(full_path, os.path.join(target, filename))
			print("Segmenting module paths.")
			module_dir = os.path.join(target, 'modules')
			for m in os.listdir(module_dir):
				n = re.sub(r'\.', '/', re.sub(r'\.lua$', '', m)) + '.lua'
				if m != n:
					os.makedirs(os.path.join(module_dir, os.path.dirname(n)), exist_ok = True)
					shutil.move(os.path.join(module_dir, m), os.path.join(module_dir, n))

def patch():
	print("[patch]")
	input_file_name = os.path.join('tmp', 'mod.unscripted.json')
	output_file_name = os.path.join('tmp', 'mod.unscripted.patched.json')
	tts_build.patch.patch_save(input_file_name, output_file_name)
	#expand()

def expand():
	print("[expand]")
	input_file_name = os.path.join('tmp', 'mod.unscripted.patched.json')
	tts_build.expand.expand(input_file_name, 'scripts')

def storeJson():
	print("[store]")
	shutil.copyfile(os.path.join('tmp', 'mod.unscripted.patched.json'), 'skeleton.json')

def bundle(luabundler, timestamp):
	print("[bundle]")

	if os.path.exists(tts_tmp_dir):
		for f in os.listdir(tts_tmp_dir):
			full_path = os.path.join(tts_tmp_dir, f)
			if os.path.isfile(full_path) and f.endswith('.ttslua'):
				os.remove(full_path)

	for f in os.listdir('scripts'):
		full_path = os.path.join('scripts', f)
		if os.path.isfile(full_path) and f.endswith('.lua'):
			filename = re.sub(r'\.lua$', '', f)
			print("Bundle " + f + "...")
			exitCode = subprocess.call([
				luabundler, 'bundle', full_path,
				'-p', os.path.join('scripts', 'modules', '?.lua'),
				'-o', os.path.join(tts_tmp_dir, filename + '.ttslua')])
			if exitCode == 0:
				if os.path.exists(os.path.join('scripts', filename + '.xml')):
					shutil.copyfile(os.path.join('scripts', filename + '.xml'), os.path.join(tts_tmp_dir, filename + '.xml'))
			else:
				sys.exit(1)

	luaFile = os.path.join(tts_tmp_dir, 'Global.-1.ttslua')
	with open (luaFile, 'r', encoding='utf-8') as f:
		content = f.read()

	content_new = re.sub(r"local BUILD\s*=\s*.*", "local BUILD = '{}'".format(timestamp), content)

	with open (luaFile, 'w', encoding='utf-8') as f:
		f.write(content_new)

def pack(timestamp):
	print("[pack]")
	input_file_name = 'skeleton.json'
	output_file_name = os.path.join('tmp', 'mod.patched.json')
	tts_build.pack.pack_save(tts_tmp_dir, input_file_name, output_file_name, timestamp)

def exportSave(output_save):
	print("[export]")
	shutil.copyfile(os.path.join('tmp', 'mod.patched.json'), output_save)
	output_png_file = output_save.replace('.json', '.png')
	if not os.path.exists(output_png_file):
		shutil.copyfile('icon.png', output_png_file)

def upload():
	print("[upload]")
	input_file_name = 'skeleton.json'
	tts_build.upload.upload(tts_tmp_dir, input_file_name)

build()
