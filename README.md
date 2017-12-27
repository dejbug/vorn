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

1. Download the latest release (e.g. `vorn-3.7z`).
2. Unpack somewhere (*sweet irony*!). You now have `vorn.exe`.
3. Choose some `test.lua` and run `luac test.lua`. You now have `luac.out`.
4. Run `COPY /B vorn.exe+luac.out > app.exe`. You now have `app.exe`.
5. Run `app.exe`. Enjoy (for now) the hex dump of the attached `luac.out`.

--

	> md vorn
	> cd vorn
	> wget https://github.com/dejbug/vorn/releases/vorn-3.7z              (1)
	> 7z x vorn-3.7z                                                      (2)
	> edit test.lua

```lua
-- test.lua
print("Hello World")
```

	> luac test.lua                                                       (3)
	> copy /B vorn.exe+luac.out > app.exe                                 (4)
	> app.exe                                                             (5)
	 00000000 | 1B 4C 75 61 : 51 00 01 04 : 04 04 08 00 : 0E 00 00 00 |
	 00000010 | 40 73 72 63 : 2F 74 65 73 : 74 2E 6C 75 : 61 00 00 00 |
	 00000020 | 00 00 00 00 : 00 00 00 00 : 02 02 04 00 : 00 00 05 00 |
	 00000030 | 00 00 41 40 : 00 00 1C 40 : 00 01 1E 00 : 80 00 02 00 |
	 00000040 | 00 00 04 06 : 00 00 00 70 : 72 69 6E 74 : 00 04 0C 00 |
	 00000050 | 00 00 48 65 : 6C 6C 6F 20 : 57 6F 72 6C : 64 00 00 00 |
	 00000060 | 00 00 04 00 : 00 00 01 00 : 00 00 01 00 : 00 00 01 00 |
	 00000070 | 00 00 01 00 : 00 00 00 00 : 00 00 00 00 : 00 00       |
