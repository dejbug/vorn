import argparse
import collections
import os
import re
import subprocess

from vornlib import cm_read_exe_output

class Error(Exception): pass
class UnpackerError(Error): pass

ArchiveFileInfo = collections.namedtuple("ArchiveFileInfo", "date time flags size compressed path")

def iter_archive_file_list(path, root=None):
	is_file = lambda x: '.' == x.group(3)[0]
	# is_dir = lambda x: 'D' == x.group(3)[0]

	m = re.compile(r'(\d{4}-\d{2}-\d{2}) +(\d{2}:\d{2}:\d{2}) +(.{5}) +(\d+) +(\d+) +(.+?)\r?$', re.M)

	cmd = ["7z", "l", path]
	with cm_read_exe_output(path, cmd) as text:
		xx = (x for x in m.finditer(text) if is_file(x))
		for x in xx:
			if root: yield ArchiveFileInfo(x.group(1), x.group(2), x.group(3), x.group(4), x.group(5), os.path.join(root, x.group(6)))
			else: yield ArchiveFileInfo(*x.groups())

def unpack_bulk(args):
	cmd = ["7z.exe", "x",]
	if args.outdir: cmd.append("-o%s" % args.outdir)
	if args.force: cmd.append("-y")
	cmd.append(args.archive)

	stdout = subprocess.PIPE if args.quiet else None

	result = subprocess.call(cmd, stdout=stdout)
	if 0 != result:
		raise UnpackerError("unpacker returned %d after command '%s'" % (result, cmd))

def touch_bulk(args):
	if args.touch:
		for t,dd,nn in os.walk(args.outdir):
			pp = (os.path.join(t, n) for n in nn)
			for p in pp:
				# print "b-touching", p
				os.utime(p, None)

def touch_individual(args):
	pp = iter_archive_file_list(args.archive, args.outdir)
	for p in pp:
		if os.path.isfile(p.path):
			# print "i-touching", p.path
			os.utime(p.path, None)

def create_parser():
	parser = argparse.ArgumentParser()
	parser.add_argument("archive", help="path to archive file (7z, zip, rar, tar, gz, ...)")
	parser.add_argument("-o", "--outdir", help="directory to extract into", metavar="DIR", default=os.getcwd())
	parser.add_argument("-t", "--touch", action="store_true", help="update timestamps of extracted files")
	parser.add_argument("-f", "--force", action="store_true", help="force overwrites, don't ask for permission")
	parser.add_argument("-q", "--quiet", action="store_true", help="don't print to stdout")
	return parser

if "__main__" == __name__:
	parser = create_parser()
	args = parser.parse_args()
	args.outdir = os.path.abspath(args.outdir)
	# print args

	folder_was_empty_before = True

	if os.path.exists(args.outdir):
		folder_was_empty_before = False

		if not os.path.isdir(args.outdir):
			parser.error('--outdir does not specify a directory: "%s"' % args.outdir)
		elif not args.force and os.listdir(args.outdir):
			parser.error('--outdir="%s" does not specify an empty directory and --force flag was not specified' % args.outdir)

	unpack_bulk(args)

	if args.touch:
		if folder_was_empty_before: touch_bulk(args)
		else: touch_individual(args)
