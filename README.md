# Pylon

`pylon` is a LuaJIT binary distribution, serving as the core binary for `bridge` tools.

In addition to LuaJIT itself, `pylon` builds and loads:

#### SQLite (currently a dylib)

#### libuv (luv)

#### lpeg

#### luautf8

As well as bundling a pure-Lua `lfs` replacement, which is deprecated, but still used by Orb.

To build it, be on macOS, and run

```
sh mkpylon.sh
```

Which will put a `br` executable in the `~/scripture/` directory you probably don't have.  

You'll need a SQLite3 somewhere in the path, and I expect you'll have one. This requirement will be eliminated on the road to alpha release. 