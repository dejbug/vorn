# To be used with the $(eval) command. This will generate goals like these:
# vorn_1_size.cpp : vorn_1.exe ; @python exe_size_patcher.py $< $@
# vorn_1.exe : $(OBJ) vorn_0_size.o ; $(CMP) -o $@ $^
define VORN_N
vorn_$(1)_size.cpp : vorn_$(1).exe ; @python exe_size_patcher.py $$< $$@
vorn_$(1).exe : $$(OBJ) vorn_$(shell python -c "print($1-1)")_size.o ; $$(call LINK,$$@,$$^)
endef

# FIXME: Switch to python.
define DELETE_VORN_NN
FOR %%n IN ($(VORN_NN)) DO @(IF EXIST vorn_%%n_size.cpp DEL vorn_%%n_size.cpp)
endef

# FIXME: Switch to python.
define DELETE_FILES
IF EXIST $1 DEL $1
endef

# FIXME: Switch to python.
define COPYB
COPY /B $(firstword $2)+$(lastword $2) $1
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
OBJ := main.o fileutils.o textutils.o

# We will build 5 preliminary versions, so a correct EXE_SIZE
#   may "settle in". To avoid this HACK, we need to find a way
#   to patch the exe's EXE_SIZE DWORD after it is built. This
#   is what a linker/loader is designed to do, so we may find
#   something in the g++ (or the ld) options if we look. Were
#   we writing this in assembly (NASM, e.g.) we could probably
#   use the $ operator (if my memory serves).
VORN_NN := 1 2 3 4 5

# This is vorn.exe. COPY/B your scripts to it.
vorn.exe : $(OBJ) vorn_$(lastword $(VORN_NN))_size.o ; $(call LINK,$@,$^)

# This is a test.exe. It will COPY/B 'test.lua' to it (compiled).
test.exe : vorn.exe test.luac ; $(call COPYB,$@,$^)
test.luac : test.lua ; luac -o $@ $<

# These are the preliminary builds of vorn.exe .
$(foreach N,$(VORN_NN),$(eval $(call VORN_N,$(N))))

vorn_%_size.o : vorn_%_size.cpp ; $(call COMPILE,$@,$^)
%utils.o : %utils.cpp %utils.hpp ; $(call COMPILE,$@,$^)
%.o : %.cpp ; $(call COMPILE,$@,$^)

.PHONY : run test clean

run : test.exe ; @$<

test : test.exe vorn.exe test.luac ; python subtract_sizes.py $^

clean :
	$(call DELETE_VORN_NN)
	$(call DELETE_FILES,*.exe)
	$(call DELETE_FILES,*.o)
	$(call DELETE_FILES,*.luac)

.DELETE_ON_ERROR : ;
