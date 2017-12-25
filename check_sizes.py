import os

def get_sorted_paths(paths, highest_first=True):
	return sorted(paths, key=lambda x: x[0], reverse=highest_first)

def get_paths(root=".", ext=".exe"):
	paths = (p for p in os.listdir(root) if p.lower().endswith(ext))
	return get_sorted_paths(paths, highest_first=False)

def get_size_paths(paths):
	return ((os.path.getsize(p), p) for p in paths)

def get_size_delta_paths(size_paths):
	sorted_sp = get_sorted_paths(size_paths)
	s_highest = None
	for s, p in sorted_sp:
		if s_highest is None: s_highest = s
		delta = s_highest - s
		yield (s, delta, p)

def get_size_delta_drop_paths(size_delta_paths):
	sorted_sdp = get_sorted_paths(size_delta_paths)
	s_last = None
	for s, d, p in sorted_sdp:
		drop = s_last - s if s_last is not None else 0
		s_last = s
		yield (s, d, drop, p)

if "__main__" == __name__:
	paths = get_paths()
	size_paths = get_size_paths(paths)
	size_delta_paths = get_size_delta_paths(size_paths)
	size_delta_drop_paths = get_size_delta_drop_paths(size_delta_paths)

	for s,d,dr,p in get_sorted_paths(size_delta_drop_paths):
		dr_s = "%+4d" % -dr if dr else "    "
		print "%8d %4d %s |%s|" % (s, d, dr_s, p)
