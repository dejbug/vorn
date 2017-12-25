import os
import sys

def get_sorted_paths(paths, highest_first=True):
	"""Return a generator that will yield the items of 'paths' sorted highest first if `highest_first` is True. This will work for numbers as well as strings."""
	return sorted(paths, key=lambda x: x[0], reverse=highest_first)

def get_paths(root=".", ext=".exe"):
	"""Return a generator that will yield every filepath in `root` that ends with `ext`."""
	names = (n for n in os.listdir(root) if n.lower().endswith(ext))
	paths = (os.path.abspath(os.path.join(root, n)) for n in names)
	return get_sorted_paths(paths, highest_first=False)

def get_size_paths(paths):
	"""Extend the `paths` iterator to yield sizes too."""
	return ((os.path.getsize(p), p) for p in paths)

def get_size_diff_paths(size_paths):
	"""Extend the `size_paths` iterator to yield diffs as well. See __main__ output for details."""
	sorted_sp = get_sorted_paths(size_paths)
	s_highest = None
	for s, p in sorted_sp:
		if s_highest is None: s_highest = s
		diff = s_highest - s
		yield (s, diff, p)

def get_size_diff_drop_paths(size_diff_paths):
	"""Extend the `size_diff_paths` iterator to yield drops as well. See __main__ output for details."""
	sorted_sdp = get_sorted_paths(size_diff_paths)
	s_last = None
	for s, d, p in sorted_sdp:
		drop = s_last - s if s_last is not None else 0
		s_last = s
		yield (s, d, drop, p)

def main(root="."):
	root = os.path.abspath(root)
	paths = get_paths(root)

	if not paths:
		print '[warning] no executables were found in the current directory ("%s"); try calling "%s" with a directory path as argument.' % (root, sys.argv[0])
		return 0

	size_paths = get_size_paths(paths)
	size_diff_paths = get_size_diff_paths(size_paths)
	size_diff_drop_paths = get_size_diff_drop_paths(size_diff_paths)

	print '\nThe following table shows the executable files that were found in "%s". It lists them sorted by filesize, highest first. The `diff` column shows the difference of item N to item 0, while the `drop` column shows the difference between item N and item N-1.\n' % (root, )

	print "%8s | %4s | %4s | %s" % ("filesize", "diff", "drop", "filepath")
	print "-" * 78
	for n, sddp in enumerate(get_sorted_paths(size_diff_drop_paths)):
		s, d, dr, p = sddp
		dr_s = " n/a" if 0 == n else ("%+4d" % -dr if dr else "%4d" % dr)
		print '%8d | %4d | %s | "%s"' % (s, d, dr_s, p)

	return 0

if "__main__" == __name__:
	root = sys.argv[1] if len(sys.argv) > 1 else "."
	code = main(root)
	exit(code)
