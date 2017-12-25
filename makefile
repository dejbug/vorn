CXXFLAGS := -std=c++11 -Wpedantic -Wall -Wextra -O3
CXX := g++
CMP := $(CXX) $(CXXFLAGS)

app.exe : vorn.exe app.luac ; COPY /B vorn.exe+app.luac $@
vorn.exe : main.o fileutils.o textutils.o vorn_patched_size.o ; $(CMP) -o $@ $^

vorn_patched_size.cpp : vorn_patched.exe ; @python exe_size_patcher.py $< $@
vorn_patched.exe : main.o fileutils.o textutils.o vorn_unpatched_size.o ; $(CMP) -o $@ $^

vorn_unpatched_size.cpp : vorn_unpatched.exe ; @python exe_size_patcher.py $< $@
vorn_unpatched.exe : main.o fileutils.o textutils.o vorn_preliminary_size.o ; $(CMP) -o $@ $^

vorn_%_size.o : vorn_%_size.cpp ; $(CMP) -o $@ -c $<
%utils.o : %utils.cpp %utils.hpp ; $(CMP) -o $@ -c $<
%.o : %.cpp ; $(CMP) -o $@ -c $<

app.luac : app.lua ; luac -o $@ $<

.PHONY : run clean test

run : app.exe ; @$<

clean :
	IF EXIST vorn_unpatched_size.cpp DEL vorn_unpatched_size.cpp
	IF EXIST vorn_patched_size.cpp DEL vorn_patched_size.cpp
	IF EXIST *.exe DEL *.exe
	IF EXIST *.o DEL *.o
	IF EXIST *.luac DEL *.luac

.DELETE_ON_ERROR : ;
