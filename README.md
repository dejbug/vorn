# ([`vorn`](https://github.com/dejbug/vorn)) [![Build status](https://ci.appveyor.com/api/projects/status/22e4nrf6qkn16unf?svg=true&passingText=ok)](https://ci.appveyor.com/project/dejbug/vorn)

1. [Motivation](#Motivation)
2. [Vision](#Vision)
3. [Status](#Status)
4. [Example](#Example)

## <a name="Motivation"></a>Motivation

Have you ever [packaged up a LÖVE game binary for Windows](https://love2d.org/wiki/Game_Distribution#Creating_a_Windows_Executable)? Pleasant, wasn't it? Imagine having only to ship a single-EXE ("portable") application instead of a ZIP (which the user would first need to un-*yuck*), or an installer (which the user would have to *meh* through).

## <a name="Vision">Vision

Usually, we write a bunch of DLLs and then a client EXE that would glue their functionality together into something coherent that we then call "app". What [LÖVE](https://love2d.org/) does is to put its "library" in the front (german: [vorn](https://en.wiktionary.org/wiki/vorne)), and you will be gluing your client code to that.

*vorn* does nothing else. Instead of `love.exe` you have `vorn.exe`. Instead of [SDL](http://www.libsdl.org/) you get, well, we'll [figure that out later](#Status).

## <a name="Status">Status

This is a **proof-of-concept** project. I've decided to use [Lua](http://www.lua.org/) for the scripting.

## <a name="Example">Example

1. Download the latest release (`vorn-*.7z`).
2. Unpack somwehere (sweet irony!). You know have `vorn.exe`.
3. Choose some `anyfile.lua` and run `luac anyfile.lua`. You now have `luac.out`.
4. Run `COPY /B vorn.exe+luac.out > app.exe`. You now have `app.exe`.
5. Run `app.exe`. Enjoy (for now) the hex dump of the attached `luac.out`.
