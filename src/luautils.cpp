#include "luautils.hpp"

luautils::Lua::Lua() {
	handle = luaL_newstate();
	if (!handle) throw LuaNewStateError();
	luaL_openlibs(handle);
}

luautils::Lua::~Lua() {
	if (handle) lua_close(handle);
}

luautils::Lua::operator lua_State * () const {
	return handle;
}

std::string luautils::Lua::get_last_error(bool pop) const {
	std::string msg(lua_tostring(handle, -1));
	if (pop) lua_pop(handle, 1); // pop error message from the stack
	return msg;
}

bool luautils::Lua::run(std::string & text, char const * name) const {
	if (luaL_loadbuffer(handle, text.data(), text.size(), name))
		return false;
	if (lua_pcall(handle, 0, 0, 0))
		return false;
	return true;
}

bool luautils::Lua::run(char const * text) const {
	if (luaL_loadstring(handle, text)) return false;
	if (lua_pcall(handle, 0, 0, 0)) return false;
	return true;
}
