This branch exists so I remember to add [libclipboard](https://github.com/jtanx/libclipboard) 

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

The pylon Makefile also uses `colordiff`, but the absence of this won't stop the build, it's just a convenience to print when Lua bytecode has
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

To do anything with it, you'll need modules.

There's an included `.bundle` file.  After making the binary, create
a directory for the modules:

```sh
mkdir -p ~/.local/share/bridge/
```
Or any directory you would like, pointed to by the environment variable
`$BRIDGE_HOME`.

Then run

```sh
build/br
```

And the database should populate.

At that point, you're free to move `br` anywhere on your path.


### Manifests

Orb uses manifest files for configuration, these contain TOML blocks which
are interpreted by Orb in various ways.

A sample manifest is included at `pylon/etc/manifest.orb`, which you can copy
to the Orb home directory at `~/.local/share/bridge/orb`.

