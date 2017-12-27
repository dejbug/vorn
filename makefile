define COMPILE
$(CXX) -o $1 -c $(filter %.cpp,$2) $(CXXFLAGS)
endef

define LINK
$(CXX) -o $1 $(CXXFLAGS) $(LDFLAGS) $(filter %.o %.a,$2) $(LDLIBS)
endef

define WINPATH
$(subst /,\,$1)
endef

define TOUCH
$(shell python -c "import os; os.utime('$1', None)")
endef

# extern/lua-$(LUA_VERSION)/Makefile : extern/lua-$(LUA_VERSION).tar ; $(call UNPACK,$@,$<)
# extern/lua-$(LUA_VERSION).tar : dependencies/lua-$(LUA_VERSION).tar.gz | extern ; $(call UNPACK,$@,$<)
define UNPACK
python src/maketool_unpack.py --outdir $1 --force --quiet --touch $2
endef

# To be used with the $(eval) command. This will generate goals like these:
# vorn_1_size.cpp : vorn_1.exe ; @python exe_size_patcher.py normal $< $@
# vorn_1.exe : $(OBJ) vorn_0_size.o ; $(CMP) -o $@ $^
define VORN_N
build/vorn_$(1)_size.cpp : build/vorn_$(1).exe ; @python src/exe_size_patcher.py normal -f $$< $$@
build/vorn_$(1).exe : $$(LUAINCS) $$(OBJ) build/vorn_$(shell python -c "print($1-1)")_size.o ; $$(call LINK,$$@,$$^)
endef

# FIXME: Switch to python.
define REMOVE_DIR
IF EXIST $1 RMDIR /S /Q $1
endef

# FIXME: Switch to python.
define MAKE_DIR
IF NOT EXIST $(call WINPATH,$1) MKDIR $(call WINPATH,$1)
endef

# FIXME: Switch to python.
define COPY_FILE
IF NOT EXIST $(call WINPATH,$2) COPY $(call WINPATH,$1) $(call WINPATH,$2)
endef

# FIXME: Switch to python.
# build/test.exe : deploy/vorn.exe build/test.luac ; $(call BAKE_TO_APP,$^,$@)
# $1 : deploy/vorn.exe build/test.luac
# $2 : build/test.exe
define BAKE_TO_APP
IF NOT EXIST $(call WINPATH,$2) COPY /B $(call WINPATH,$(firstword $1))+$(call WINPATH,$(lastword $1)) $(call WINPATH,$2)
$(call TOUCH,$2)
endef

# build/test.luac : src/test.lua | extern/lua/luac.exe build ; $(call LUA_TO_LUAC,$<,$@)
# $1 : src/test.lua
# $2 : build/test.luac
define LUA_TO_LUAC
$(call WINPATH,extern/lua/luac.exe) -o $2 $1
$(call WINPATH,extern/lua/luac.exe) -p -l -l $2
endef

LUA_VERSION := 5.3.4
APPLIB_OBJS := fileutils textutils luautils

LUAINCS_H := lauxlib lua luaconf lualib
LUAINCS_HPP := lua

INCDIRS :=
LIBDIRS :=
LDLIBS :=
SYMBOLS :=

# We will build 5 preliminary versions, so a correct EXE_SIZE
#   may "settle in". To avoid this HACK, we need to find a way
#   to patch the exe's EXE_SIZE DWORD after it is built. This
#   is what a linker/loader is designed to do, so we may find
#   something in the g++ (or the ld) options if we look. Were
#   we writing this in assembly (NASM, e.g.) we could probably
#   use the $ operator (if my memory serves).
VORN_NN := 1 2 3 4 5

# FIXME: The 'clear' goal uses CMD.EXE commands for now. Need to switch
#   this to python -c "..." for better portability. Also: the COPYB macro.
SHELL := cmd.exe

LUA_INCDIRS := extern/lua/include
LUA_LIBDIRS := extern/lua
LUALIB_PATH := extern/lua/liblua.a

LUAINCS := $(LUAINCS_H:%=extern/lua/include/%.h)
LUAINCS += $(LUAINCS_HPP:%=extern/lua/include/%.hpp)

CXX := g++

CXXFLAGS := -std=c++11 -Wpedantic -Wall -Wextra -O3
CXXFLAGS += $(addprefix -D,$(SYMBOLS))
CXXFLAGS += $(addprefix -I,$(INCDIRS))
CXXFLAGS += $(addprefix -I,$(LUA_INCDIRS))

LDFLAGS := $(addprefix -L,$(LIBDIRS))
LDFLAGS := $(addprefix -L,$(LUA_LIBDIRS))
LDFLAGS += $(addprefix -l,$(LDLIBS))
LDFLAGS += -llua

# All the main object files go here. NOTE: Mainly for use by
#   the VORN_N template.
OBJ := main $(basename $(APPLIB_OBJS))
OBJ := $(OBJ:%=build/%.o)
OBJ += $(LUALIB_PATH)

# This will do nothing, only if the build succeeds.
.PHONY : all
all : | validate ;

build/test.exe : deploy/vorn.exe build/test.luac ; $(call BAKE_TO_APP,$^,$@)

build/test.luac : src/test.lua | extern/lua/luac.exe build ; $(call LUA_TO_LUAC,$<,$@)

# This is vorn.exe. COPY/B your scripts to it.
deploy/vorn.exe : $(LUAINCS) $(OBJ) build/vorn_$(lastword $(VORN_NN))_size.o | deploy ; $(call LINK,$@,$^)

# These are the preliminary builds of vorn.exe .
$(foreach N,$(VORN_NN),$(eval $(call VORN_N,$(N))))

build/vorn_0_size.cpp : src/vorn_0_size.cpp ; $(call COPY_FILE,$<,$@)

build/vorn_%_size.o : build/vorn_%_size.cpp | build ; $(call COMPILE,$@,$^)
build/%utils.o : src/%utils.cpp src/%utils.hpp | build ; $(call COMPILE,$@,$^)
build/%.o : src/%.cpp | build ; $(call COMPILE,$@,$^)

extern/lua/luac.exe : extern/lua-$(LUA_VERSION)/src/luac.exe | extern/lua ; $(call COPY_FILE,$<,$@)

extern/lua-$(LUA_VERSION)/src/luac.exe : | extern/lua-$(LUA_VERSION)/src/liblua.a

extern/lua/include/% : extern/lua-$(LUA_VERSION)/Makefile | extern/lua/include ; $(call COPY_FILE,extern/lua-$(LUA_VERSION)/src/$(notdir $@),$@)

extern/lua/liblua.a : extern/lua-$(LUA_VERSION)/src/liblua.a | extern/lua ;
	$(call COPY_FILE,$<,$@)

extern/lua-$(LUA_VERSION)/src/liblua.a : extern/lua-$(LUA_VERSION)/Makefile ; $(MAKE) mingw -C $(dir $<)

extern/lua-$(LUA_VERSION)/Makefile : extern/lua-$(LUA_VERSION).tar ; $(call UNPACK,extern,$<)

extern/lua-$(LUA_VERSION).tar : dependencies/lua-$(LUA_VERSION).tar.gz | extern ; $(call UNPACK,extern,$<)

build deploy extern extern/lua extern/lua/include : ; $(call MAKE_DIR,$@)

.PHONY : validate
.PHONY : print_sizes subtract_sizes
.PHONY : run clean reset

validate : deploy/vorn.exe ; python src/validate_exe_size.py $<

print_sizes : ; python src/print_sizes.py build

# Depends on `luac.exe` being in the PATH (since it builds `test.exe`).
subtract_sizes : build/test.exe deploy/vorn.exe build/test.luac ; python src/subtract_sizes.py $^

# Depends on `luac.exe` being in the PATH (since it builds `test.exe`).
run : build/test.exe | validate ; @$<

clean : ; $(call REMOVE_DIR,build)

reset : | clean
	$(call REMOVE_DIR,deploy)
	$(call REMOVE_DIR,extern)

.DELETE_ON_ERROR : ;
.NOTPARALLEL : ;
