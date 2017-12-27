# ([`vorn`](https://github.com/dejbug/vorn)) [![Build status](https://ci.appveyor.com/api/projects/status/22e4nrf6qkn16unf?svg=true&passingText=ok)](https://ci.appveyor.com/project/dejbug/vorn)

1. [Motivation](#Motivation)
2. [Vision](#Vision)
3. [Status](#Status)
4. [Example](#Example)

## <a name="Motivation"></a>Motivation

Have you ever [packaged up a LÖVE game binary for Windows](https://love2d.org/wiki/Game_Distribution#Creating_a_Windows_Executable) yet? Pleasant, wasn't it? Imagine having to ship a single-EXE ("portable") application instead of a ZIP (which the user would first need to un-*yuck*), or an installer (which the user would have to *meh* through).

## <a name="Vision">Vision

Usually, we write a bunch of DLLs and then a client EXE that would glue their functionality together into something coherent that we then call "app". What [LÖVE](https://love2d.org/) does is to put its "library" in the front (german: [vorn](https://en.wiktionary.org/wiki/vorne)), and you will be gluing your client code to that.

**vorn** does nothing else. Instead of `love.exe` you have `vorn.exe`. Instead of [SDL](http://www.libsdl.org/) you get, well, we'll [figure that out later](#Status).

## <a name="Status">Status

This is a **proof-of-concept** project. I've decided to use [Lua](http://www.lua.org/) for the scripting. What this means is that `vorn.exe` will run as a (lua stand-alone) interpreter, providing your payload lua script the services it needs.

The first major milestone will have been achieved when `vorn.exe` itself (i.e. its services) will be the product of a user-defined compilation step.

The bottom-line idea is to have user design her own one-size-fits-all library that can be scripted to customize it to a specific task (and then get packed into a single EXE distributable).

## <a name="Example">Example

1. Download the latest release (e.g. `vorn-7.7z`).
2. Unpack somewhere (*sweet irony*!). You now have `vorn.exe`.
3. Choose some `test.lua` and run `luac test.lua`. You now have `luac.out`.
4. Run `COPY /B vorn.exe+luac.out > app.exe`. You now have `app.exe`.
5. Run `app.exe`. Enjoy.

--

	> md vorn
	> cd vorn
	> curl -kLO http://github.com/dejbug/vorn/releases/download/vorn-7/vorn-7.7z    (1)
	> 7z x vorn-7.7z 1>NUL                                                          (2)
	> echo print('Hello World!') > app.lua
	> type app.lua

```lua
print('Hello World!')
```

	> luac app.lua                                                                 (3)
	> copy /B vorn.exe+luac.out app.exe                                            (4)
	...
	> app.exe                                                                      (5)
	Hello World!
	> app.exe --test-lua-repl
	lua> print "hi"
	hi
	lua> os.exit()
	> app.exe --dump-payload
	 00000000 | 1B 4C 75 61 : 53 00 19 93 : 0D 0A 1A 0A : 04 04 04 08 |
	 00000010 | 08 78 56 00 : 00 00 00 00 : 00 00 00 00 : 00 00 28 77 |
	 00000020 | 40 01 09 40 : 61 70 70 2E : 6C 75 61 00 : 00 00 00 00 |
	 00000030 | 00 00 00 00 : 01 02 04 00 : 00 00 06 00 : 40 00 41 40 |
	 00000040 | 00 00 24 40 : 00 01 26 00 : 80 00 02 00 : 00 00 04 06 |
	 00000050 | 70 72 69 6E : 74 04 0D 48 : 65 6C 6C 6F : 20 57 6F 72 |
	 00000060 | 6C 64 21 01 : 00 00 00 01 : 00 00 00 00 : 00 04 00 00 |
	 00000070 | 00 01 00 00 : 00 01 00 00 : 00 01 00 00 : 00 01 00 00 |
	 00000080 | 00 00 00 00 : 00 01 00 00 : 00 05 5F 45 : 4E 56       |
