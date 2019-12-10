# Pylon

`pylon` is a LuaJIT binary distribution, serving as the core binary for `bridge` tools.

In addition to LuaJIT itself, `pylon` builds and loads:

#### SQLite (currently a dylib)

#### libuv (luv)

#### lpeg

#### luautf8

#### luafilesystem

To build it, run

```
./clean
./mkpylon.sh
```

Which will put a `br` executable in the `build/` directory.

To do anything with it, you'll need modules, to be found in the
[bridge.modules](https://gitlab.com/special-circumstance/bridge.modules) repo.