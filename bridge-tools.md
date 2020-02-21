# Bridge


Bridge tools is a [LuaJIT](luajit.org) runtime with a focus on interactive parser development.

Other than the executable, which is a C99 program, it is written in [Orb](https://gitlab.special-circumstanc.es/bridge-tools/orb), a literate markup dialect with a family resemblance to [org-mode](orgmode.orb).


## Installation

A minimal `bridge` installation consists of the binary, `br`, and a SQLite database containing the compiled
module code.

To install bridge, follow the instructions in the [pylon repository](https://gitlab.special-circumstanc.es/bridge-tools/pylon/blob/master/README.md), then install the [bridge.modules](https://gitlab.special-circumstanc.es/bridge-tools/bridge.modules) database in the indicated location.


### Acceptance

Ensure that the `br` binary is in your shell's path.

To run [helm](https://gitlab.special-circumstanc.es/bridge-tools/helm), the interactive repl, invoke bridge with `br helm` or `br i`.  The command history is stored on a per-directory basis (based on the `pwd`), and
may be searched from the helm with `/`.  Helm supports a few Readline editing commands, with more to be added.  If using a [CSI u](http://www.leonerd.org.uk/hacks/fixterms/) compatible terminal†, `^-Return` will always add a newline, and `Shift-Return` will always enter a command; otherwise helm tries to do the right thing based on cursor position.

† This includes at least iTerm2 and xterm, although it must be turned on in settings in at least the former case.

Orb may be invoked with `br orb` or `br o`, which should be called from the root directory of any bridge tools repository.  This will generate Lua source code, Markdown documentation, and compile bytecode, committing it to the `bridge.modules` database.  A commit may be removed from the database by invoking `br orb revert`.

[GGG](https://gitlab.special-circumstanc.es/bridge-tools/ggg) and [espalier](https://gitlab.special-circumstanc.es/bridge-tools/espalier) may be explored by calling up helm and typing `ggg = require "ggg:ggg"` or `espalier = require "espalier:espalier"`, respectively.

Bridge is also capable of running Lua source in command-line mode with `br -f path/to/source.lua`.  Orb is not directly supported at this time; the Lua equivalent of an Orb file can generally be found by substituting `/src/` for `/orb/` in the path.  The same is true for Markdown by substituting `/doc/md/`.