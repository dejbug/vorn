import os

paths = [p for p in os.listdir(".") if p.lower().endswith(".exe")]

size_paths = []
for path in paths:
	size_paths.append((os.path.getsize(path), path))

size_delta_paths = []
s_highest = None
for s, p in sorted(size_paths, key=lambda x: x[0], reverse=True):
	if s_highest is None: s_highest = s
	delta = s_highest - s
	size_delta_paths.append((s, delta, p))

size_delta_drop_paths = []
s_last = None
for s, d, p in sorted(size_delta_paths, key=lambda x: x[0], reverse=True):
	drop = s_last - s if s_last is not None else 0
	s_last = s
	size_delta_drop_paths.append((s, d, drop, p))

for s,d,dr,p in size_delta_drop_paths:
	dr_s = "%+4d" % -dr if dr else "    "
	print "%8d %4d %s |%s|" % (s, d, dr_s, p)
