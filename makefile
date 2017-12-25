# To be used with the $(eval) command. This will generate goals like these:
# vorn_1_size.cpp : vorn_1.exe ; @python exe_size_patcher.py $< $@
# vorn_1.exe : $(OBJ) vorn_0_size.o ; $(CMP) -o $@ $^
define VORN_N
build/vorn_$(1)_size.cpp : build/vorn_$(1).exe ; @python src/exe_size_patcher.py $$< $$@
build/vorn_$(1).exe : $$(OBJ) build/vorn_$(shell python -c "print($1-1)")_size.o ; $$(call LINK,$$@,$$^)
endef

# FIXME: Switch to python.
define DELETE_VORN_NN
FOR %%n IN ($(VORN_NN)) DO @(IF EXIST build/vorn_%%n_size.cpp DEL build/vorn_%%n_size.cpp)
endef

# FIXME: Switch to python.
define DELETE_FILES
IF EXIST $1 DEL $1
endef

define REMOVE_DIR
IF EXIST $1 RMDIR /S /Q $1
endef

define MAKE_DIR
IF NOT EXIST $1 MKDIR $1
endef

define WINPATH
$(subst /,\,$1)
endef

# FIXME: Switch to python.
define COPYB
COPY /B $(call WINPATH,$(firstword $2))+$(call WINPATH,$(lastword $2)) $(call WINPATH,$1)
endef

define COMPILE
$(CXX) $(CXXFLAGS) -o $1 -c $(filter %.cpp,$2)
endef

define LINK
$(CXX) $(CXXFLAGS) -o $1 $(filter %.o %.a,$2)
endef

# FIXME: The 'clear' goal uses CMD.EXE commands for now. Need to switch
#   this to python -c "..." for better portability. Also: the COPYB macro.
SHELL := cmd.exe

CXX := g++
CXXFLAGS := -std=c++11 -Wpedantic -Wall -Wextra -O3

# All the main object files go here.
OBJ := main fileutils textutils
OBJ := $(OBJ:%=build/%.o)

# We will build 5 preliminary versions, so a correct EXE_SIZE
#   may "settle in". To avoid this HACK, we need to find a way
#   to patch the exe's EXE_SIZE DWORD after it is built. This
#   is what a linker/loader is designed to do, so we may find
#   something in the g++ (or the ld) options if we look. Were
#   we writing this in assembly (NASM, e.g.) we could probably
#   use the $ operator (if my memory serves).
VORN_NN := 1 2 3 4 5

.PHONY : all
all : | test ;

# This is vorn.exe. COPY/B your scripts to it.
deploy/vorn.exe : $(OBJ) build/vorn_$(lastword $(VORN_NN))_size.o | deploy ; $(call LINK,$@,$^)

# This is a test.exe. It will COPY/B 'test.lua' to it (compiled).
build/test.exe : deploy/vorn.exe build/test.luac ; $(call COPYB,$@,$^)
build/test.luac : src/test.lua ; luac -o $@ $<

# These are the preliminary builds of vorn.exe .
$(foreach N,$(VORN_NN),$(eval $(call VORN_N,$(N))))

build/vorn_0_size.cpp : src/vorn_0_size.cpp ; @COPY $(subst /,\,$<) build

build/vorn_%_size.o : build/vorn_%_size.cpp | build ; $(call COMPILE,$@,$^)
build/%utils.o : src/%utils.cpp src/%utils.hpp | build ; $(call COMPILE,$@,$^)
build/%.o : src/%.cpp | build ; $(call COMPILE,$@,$^)

build deploy : ; $(call MAKE_DIR,$@)

.PHONY : run test clean reset

run : build/test.exe ; @$<

test : build/test.exe deploy/vorn.exe build/test.luac ; python src/subtract_sizes.py $^

clean : ; $(call REMOVE_DIR,build)
reset : | clean ; $(call REMOVE_DIR,deploy)

.DELETE_ON_ERROR : ;
