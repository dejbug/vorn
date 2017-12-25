import os
import re
import subprocess
import sys

class Error(Exception): pass
class FileNotFoundError(Error): pass
class OverwriteError(Error): pass

ENDL = "\r\n"

def query_exe_size(path):
	try:
		size = subprocess.call([path, "--exe-size"], stdout=subprocess.PIPE)
	except WindowsError as e:
		if e.winerror == 2:
			raise FileNotFoundError('[error] exe not found at "%s"' % path)
		else: raise
	else:
		return int(size)

def write_cpp_file(path, size):
	if os.path.exists(path):
		raise OverwriteError('error: output file already exists at path "%s"; delete it manually please' % path)
	with open(path, "wb") as f:
		f.write('unsigned int EXE_SIZE = 0x%08X;%s' % (size, ENDL))

def print_usage():
	app_name = os.path.split(sys.argv[0])[1]
	print "usage:"
	print "  %s {root_name}[,exe|.cpp]" % app_name
	print "  %s {exe_path} {cpp_path}" % app_name
	print "example:"
	print "  `%s main`" % app_name
	print "  -- same as: `%s main.exe main_size.cpp`" % app_name

def main_1(root_name):
	exe_path = root_name + ".exe"
	cpp_path = root_name + "_size.cpp"
	exe_file_size = query_exe_size(exe_path)
	write_cpp_file(cpp_path, exe_file_size)
	return 0

def main_2(exe_path, cpp_path):
	exe_file_size = query_exe_size(exe_path)
	write_cpp_file(cpp_path, exe_file_size)
	return 0

if "__main__" == __name__:

	if len(sys.argv) > 2:
		exe_path = sys.argv[1]
		cpp_path = sys.argv[2]
		code = main_2(exe_path, cpp_path)
		exit(code)

	elif len(sys.argv) > 1:
		root_name = os.path.splitext(sys.argv[1])[0]
		code = main_1(root_name)
		exit(code)

	elif len(sys.argv) < 2:
		print_usage()
		exit(0)
