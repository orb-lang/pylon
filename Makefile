SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

BRLIBS = build/libluv.a   \
         build/libuv.a    \
         build/liblpeg.a  \
         build/libluajit.a \
         build/libtcc.a \
         build/lfs.a \
         build/lua-utf8.a \
         build/sqlite3.o

CWARNS = -Wall -Wextra -pedantic \
			-Waggregate-return \
			-Wcast-align \
			-Wcast-qual \
			-Wdisabled-optimization \
			-Wpointer-arith \
			-Wshadow \
			-Wsign-compare \
			-Wundef \
			-Wwrite-strings \
			-Wbad-function-cast \
			-Wmissing-prototypes \
			-Wnested-externs \
			-Wstrict-prototypes \

BR = build/br

all: $(BR)

install: $(BR)
	cp $(BR) ~/scripture/

uninstall:
	rm ~/scripture/br

OS_BUILDOPTS ?= $(error "either make $$PLAT or manually set OS_BUILDOPTS")
$(BR): build/core.o build/libluv.a build/sqlite3.o
	$(CC) -o $@ $(CWARNS) build/core.o $(BRLIBS) -Ibuild/ -Ilib/  $(OS_BUILDOPTS)

linux:
	$(MAKE) OS_BUILDOPTS="-lm -ldl -lpthread -Wl,-E"
macosx:
	$(MAKE) OS_BUILDOPTS=""

build/core.o: src/core.c build/load_char.h build/sql.h build/tcc.h build/bridge.h build/preamble.h build/afterward.h build/argparse.h build/modules.h
	$(CC) -c -O3 -Ibuild/ -Ilib/ -Isrc/ $(CWARNS) src/core.c -o build/core.o -Wall -Wextra -pedantic -std=c99

build/load_char.h: src/load.lua src/compileToHeader.lua
	build/luajit src/compileToHeader.lua LUA_LOAD src/load.lua build/~load_char.h
	mv build/~load_char.h build/load_char.h

build/sql.h: src/sql.lua src/compileToHeader.lua
	build/luajit src/compileToHeader.lua LUA_SQL src/sql.lua build/~sql.h
	mv build/~sql.h build/sql.h

build/tcc.h: src/tcc.lua src/compileToHeader.lua
	build/luajit src/compileToHeader.lua LUA_TCC src/tcc.lua build/~tcc.h
	mv build/~tcc.h build/tcc.h

build/bridge.h: src/bridge.lua src/compileToHeader.lua
	build/luajit src/compileToHeader.lua LUA_BRIDGE src/bridge.lua build/~bridge.h
	mv build/~bridge.h build/bridge.h

build/preamble.h: src/preamble.lua src/compileToHeader.lua
	build/luajit src/compileToHeader.lua LUA_PREAMBLE src/preamble.lua build/~preamble.h
	mv build/~preamble.h build/preamble.h

build/modules.h: src/modules.lua src/compileToHeader.lua
	build/luajit src/compileToHeader.lua LUA_MODULES src/modules.lua build/~modules.h
	mv build/~modules.h build/modules.h

build/argparse.h: src/argparse.lua src/compileToHeader.lua
	build/luajit src/compileToHeader.lua LUA_ARGPARSE src/argparse.lua build/~argparse.h
	mv build/~argparse.h build/argparse.h

build/afterward.h: src/afterward.lua src/compileToHeader.lua
	build/luajit src/compileToHeader.lua LUA_AFTERWARD src/afterward.lua build/~afterward.h
	mv build/~afterward.h build/afterward.h

#  These steps should be pre-baked in an install so we - the call in case orb
#  is not installed

src/core.c: orb/core.orb
	echo "core"
	- br o
src/sql.lua: orb/sql.orb
	echo "sql"
	- br o
src/tcc.lua: orb/tcc.orb
	echo "tcc"
	- br o
src/bridge.lua: orb/bridge.orb
	echo "bridge"
	- br o
src/load.lua: orb/load.orb
	echo "load"
	- br o
src/preamble.lua: orb/preamble.orb
	echo "preamble"
	- br o
src/modules.lua: orb/modules.orb
	echo "modules"
	- br o
src/afterward.lua: orb/afterward.orb
	echo "afterward"
	- br o
src/argparse.lua: orb/argparse.orb
	echo "argparse"
	- br o
