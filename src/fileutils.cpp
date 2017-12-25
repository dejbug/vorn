#include "fileutils.hpp"
#include <io.h>
#include <memory>

fileutils::FileHandle::FileHandle(char const * path, char const * mode) {
	handle = fopen(path, mode);
	if (!handle) throw FileNotFoundError();
}

fileutils::FileHandle::FileHandle(FileHandle & that) {
	handle = that.handle;
	that.handle = nullptr;
}

fileutils::FileHandle::~FileHandle() {
	if (handle) {
		fclose(handle);
		handle = nullptr;
	}
}

fileutils::FileHandleSeekRewinder::FileHandleSeekRewinder(FileHandle const & fh, bool active) : handle(active ? fh.handle : nullptr), offset(ftell(handle)) {
}

fileutils::FileHandleSeekRewinder::~FileHandleSeekRewinder() {
	if (handle) {
		fseek(handle, offset, SEEK_SET);
		handle = nullptr;
	}
}

bool fileutils::is_path(char const * path) {
	struct _finddata_t fd;
	long const seek_handle = _findfirst(path, &fd);
	return -1 != seek_handle;
}

bool fileutils::is_file(char const * path) {
	struct _finddata_t fd;
	long const seek_handle = _findfirst(path, &fd);
	if (-1 == seek_handle) return false;
	return (_A_SUBDIR & fd.attrib) != _A_SUBDIR;
}

bool fileutils::is_dir(char const * path) {
	struct _finddata_t fd;
	long const seek_handle = _findfirst(path, &fd);
	if (-1 == seek_handle) return false;
	return (_A_SUBDIR & fd.attrib) == _A_SUBDIR;
}

size_t fileutils::get_size(FileHandle & fh) {
	FileHandleSeekRewinder rewinder(fh);
	fseek(fh.handle, 0, SEEK_END);
	size_t const size = ftell(fh.handle);
	return size;
}

size_t fileutils::get_tail_size(FileHandle & fh) {
	FileHandleSeekRewinder rewinder(fh);
	fseek(fh.handle, 0, SEEK_END);
	size_t const size = ftell(fh.handle);
	return size - rewinder.offset;
}

std::string fileutils::read_tail(FileHandle & fh, size_t offset) {
	fseek(fh.handle, offset, SEEK_SET);
	size_t const count = get_tail_size(fh);

	auto mem = std::unique_ptr<char>(new char[count + 1]);

	size_t const done = fread(mem.get(), 1, count, fh.handle);
	mem.get()[done] = '\0';

	return std::string(mem.get(), mem.get() + count);
}
