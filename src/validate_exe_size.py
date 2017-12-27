import collections
import re
import subprocess
import sys

from vornlib import OPT_QUERY_EXE_SIZE
from vornlib import Error as ErrorBase

class Error(Exception): pass
class FileNotFoundError(Error): pass
class ExeError(Error): pass
class ParseError(Error): pass

ParsedOutput = collections.namedtuple("ParsedOutput", "exe_name exe_size ok_blurb")

def get_exe_output(path):
	try:
		size = subprocess.call([path, OPT_QUERY_EXE_SIZE], stdout=subprocess.PIPE)
		stdout = subprocess.Popen([path, OPT_QUERY_EXE_SIZE], shell=False, stdout=subprocess.PIPE).stdout
	except WindowsError as e:
		if e.winerror == 2:
			raise FileNotFoundError('exe not found at "%s"' % path)
		elif e.winerror == 193:
			raise ExeError('not an executable at "%s"' % path)
		else: raise
	else:
		return stdout.read()

def parse_exe_output(text):
	m = re.compile(r'File size for "(?P<exe_path>.*?)" is (?P<exe_size>\d+)(?P<ok_blurb> \(as expected\))? \.')
	x = m.match(text)
	if not x: return None
	return ParsedOutput(*x.groups())

def validate_exe_size(path):
	text = get_exe_output(path)
	args = parse_exe_output(text)
	if not args:
		raise ParseError('file is not a vern.exe : "%s"' % path)
	return 0 if args.ok_blurb else int(args.exe_size)

def print_usage():
	print "[usage] %s {exe_path}" % sys.argv[0]

if "__main__" == __name__:
	if len(sys.argv) > 1:
		code = validate_exe_size(sys.argv[1])
		exit(code)
	else:
		print_usage()
