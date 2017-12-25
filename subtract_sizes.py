import os
import sys

if "__main__" == __name__:

	size_first = None

	for path in sys.argv[1:]:
		size = os.path.getsize(path)
		if size_first is None: size_first = size
		else: size_first -= size
		print "%8d %8d |%s|" % (size_first, size, path)

	sys.exit(int(size_first))
