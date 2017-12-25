#ifndef FILEUTILS_HPP
#define FILEUTILS_HPP

#include "Error.hpp"
#include <string>

namespace fileutils {

struct Error : ::Error {};

struct FileHandle {

	struct FileHandleError : Error {};
	struct FileNotFoundError : FileHandleError {};

	FILE * handle = nullptr;

	FileHandle(char const * path, char const * mode="rb");
	FileHandle(FileHandle & that);
	virtual ~FileHandle();
};

struct FileHandleSeekRewinder {

	FILE * handle = nullptr;
	size_t offset = 0;

	FileHandleSeekRewinder(FileHandle const & fh, bool active=true);
	virtual ~FileHandleSeekRewinder();
};

bool is_path(char const * path);
bool is_file(char const * path);
bool is_dir(char const * path);
size_t get_size(FileHandle & fh);
size_t get_tail_size(FileHandle & fh);
std::string read_tail(FileHandle & fh, size_t offset=0);

} // !namespace fileutils

#endif // !FILEUTILS_HPP
