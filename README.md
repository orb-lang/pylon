# Pylon


`pylon` is a LuaJIT binary distribution, serving as the core binary for `bridge`
tools.

In addition to LuaJIT itself, `pylon` builds and loads:

#### SQLite

#### libuv (luv)

#### lpeg

#### luautf8

#### luafilesystem


## Dependencies

`pylon` itself requires the following tools: `sh`, `make`, and `cc`.  Some 
effort has been made to keep this Posix compliant, if you run into an issue with
a variation of one of these tools, please file an issue.

Building the submodules requires these additional tools:

    automake autotools-dev cmake libtool
    
The pylon Makefile also uses `colordiff`, but the absence of this shouldn't 
throw any errors, it's just a convenience to print when Lua bytecode has
changed between revisions.


## Building the br binary

To build it, run

```sh
./clean
./mkpylon.sh
```

Which will put a `br` executable in the `build/` directory.

Subsequent builds should simply require

    make <platform>

Unless one is updating of the submodules.  Supported platforms, currently, are
`macosx` and `linux`.

To do anything with it, you'll need modules, to be found in the
[bridge.modules][0] repo.

[0]: https://gitlab.special-circumstanc.es/bridge-tools/bridge.modules