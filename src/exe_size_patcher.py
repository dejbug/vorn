import argparse
import os
import re
import subprocess
import sys

from vornlib import ENDL
from vornlib import OPT_QUERY_EXE_SIZE
from vornlib import Error as ErrorBase
from vornlib import DictObject

class Error(ErrorBase): pass
class FileNotFoundError(Error): pass
class OverwriteError(Error): pass

def query_exe_size(path):
	try:
		size = subprocess.call([path, OPT_QUERY_EXE_SIZE], stdout=subprocess.PIPE)
	except WindowsError as e:
		if e.winerror == 2:
			raise FileNotFoundError('exe not found at "%s"' % path)
		else: raise
	else:
		return int(size)

def write_cpp_file(path, size, force_overwrite=False):
	if not force_overwrite and os.path.exists(path):
		raise OverwriteError('output file already exists at path "%s"; delete it manually or specify `--force-overwrite`' % path)
	with open(path, "wb") as f:
		f.write('unsigned int EXE_SIZE = 0x%08X;%s' % (size, ENDL))

def main_1(args):
	exe_path = args.root_name + ".exe"
	cpp_path = args.root_name + "_size.cpp"
	exe_file_size = query_exe_size(exe_path)
	write_cpp_file(cpp_path, exe_file_size, args.force_write)
	return 0

def main_2(args):
	exe_file_size = query_exe_size(args.exe_path)
	write_cpp_file(args.cpp_path, exe_file_size, args.force_write)
	return 0

def create_parser():
	description = "Used in the vern [1] makefile to auto-generate *_size.cpp files in the exe-size self-knowledge HACK."
	epilog = "[1] <https://github.com/dejbug/vorn>"

	parser = argparse.ArgumentParser(description=description, epilog=epilog)

	subparsers = parser.add_subparsers(title="invocation styles", description="There are two invocation styles of this script, normal and simple:")

	a = subparsers.add_parser("normal", help="type `%(prog)s normal -h` for details")
	a.add_argument("exe_path", help="path to input exe file to be queried for how big a file it thinks it is")
	a.add_argument("cpp_path", help="path to output cpp for the exe-size to be written to")
	a.add_argument("-f", "--force-write", action="store_true", help="overwrite output file if it exists")
	a.set_defaults(func=main_2)

	b = subparsers.add_parser("simple", help="type `%(prog)s simple -h` for details")
	b.add_argument("root_name", help="exe_path/cpp_path will be generated from this like so: for root_name 'build/main', exe_path will be 'build/main.exe' and cpp_path will be 'build/main_size.cpp'")
	b.add_argument("-f", "--force-write", action="store_true", help="overwrite output file if it exists")
	b.set_defaults(func=main_1)

	return parser

if "__main__" == __name__:
	parser = create_parser()
	args = parser.parse_args()
	args.func(args)
