#ifndef VORN_LUAUTILS_HPP
#define VORN_LUAUTILS_HPP

#include "Error.hpp"
#include <string>
#include <lua.hpp>

namespace luautils {

struct Error : ::Error {};

struct Lua {

	struct LuaError : Error {};
	struct LuaNewStateError : LuaError {};
	struct LuaCallError : LuaError {};

	lua_State * handle = nullptr;

	Lua();
	virtual ~Lua();
	operator lua_State * () const;

	std::string get_last_error(bool pop=true) const;
	bool run(std::string & text, char const * name=nullptr) const;
	bool run(char const * text) const;
};

} // !namespace luautils

#endif // !VORN_LUAUTILS_HPP
