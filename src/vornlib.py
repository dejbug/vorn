import contextlib
import os
import subprocess

OPT_QUERY_EXE_SIZE = "--exe-size"

ENDL = "\r\n"

class Error(Exception): pass
class FileNotFoundError(Error): pass
class ExeError(Error): pass

class DictObject(object):

	def __init__(self, dict_={}):
		for k, v in dict_.items():
			if isinstance(v, dict):
				self.__dict__[k] = DictObject(v)
			else:
				self.__dict__[k] = v

	def __repr__(self):
		return str(self.__dict__)

	def __str__(self):
		return self.__class__.__name__ + str(self.__dict__)


@contextlib.contextmanager
def cm_read_exe_output(path, cmd=[]):
	if not cmd:
		yield ""
		return

	if not os.path.isfile(path):
		raise FileNotFoundError(path)

	process = subprocess.Popen(cmd, stdout=subprocess.PIPE ,stderr=subprocess.PIPE)

	yield process.stdout.read()

	result = process.wait()
	if 0 != result:
		raise ExeError("process returned %d after command '%s'" % (result, " ".join(cmd)))
