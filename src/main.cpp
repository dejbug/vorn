#include <stdio.h>
#include <string.h>

#include "fileutils.hpp"
#include "textutils.hpp"
#include "luautils.hpp"

#define E_OK 0
#define E_UNPATCHED_EXE -1

extern unsigned int const EXE_SIZE;

void print_usage(char ** argv) {
	printf("usage %s [--exe-size]\n", argv[0]);
}

size_t print_exe_size(char ** argv) {
	fileutils::FileHandle fh(argv[0]);

	size_t exe_size = fileutils::get_size(fh);
	printf("File size for \"%s\" is %d", argv[0], exe_size);
	if (EXE_SIZE == exe_size) printf(" (as expected)");
	printf(" .\n");

	return exe_size;
}

int dump_payload(int, char ** argv) {
	fileutils::FileHandle fh(argv[0]);
	std::string text = fileutils::read_tail(fh, EXE_SIZE);
	textutils::print_hex(text);
	return E_OK;
}

int run_payload(int, char ** argv) {
	luautils::Lua lua;

	fileutils::FileHandle fh(argv[0]);
	std::string text = fileutils::read_tail(fh, EXE_SIZE);

	if (!lua.run(text, "payload"))
		fprintf(stderr, "[lua error] %s\n", lua.get_last_error().c_str());

	return E_OK;
}

int test_lua_repl() {
	luautils::Lua lua;

	char buff[256];

	while (1) {
		printf("lua> ");
		if (nullptr == fgets(buff, sizeof(buff), stdin)) break;
		if (!lua.run(buff)) fprintf(stderr, "! %s\n", lua.get_last_error().c_str());
	}
	printf("bye.\n");
	return 0;
}

int main(int argc, char ** argv) {
	if (argc > 1 && !strcmp(argv[1], "--exe-size")) {
		return print_exe_size(argv);
	}
	else if (argc > 1 && !strcmp(argv[1], "--test-lua-repl")) {
		return test_lua_repl();
	}
	else if (argc > 1 && !strcmp(argv[1], "--dump-payload")) {
		return dump_payload(argc, argv);
	}
	else if (0 == EXE_SIZE) {
		return E_UNPATCHED_EXE;
	}
	return run_payload(argc, argv);
}
