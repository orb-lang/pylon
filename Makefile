BRLIBS = build/libluv.a   \
         build/libuv.a    \
         build/liblpeg.a  \
         build/libluajit.a \
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
$(BR): build/core.o build/libluv.a build/lfs.a build/sqlite3.o
	$(CC) -o $@ $(CWARNS) build/core.o $(BRLIBS) -Ibuild/ -Ilib/  $(OS_BUILDOPTS)

linux:
	$(MAKE) OS_BUILDOPTS="-lm -ldl -lpthread -Wl,-E"
macosx:
	$(MAKE) OS_BUILDOPTS="-pagezero_size 10000 -image_base 100000000 -funwind-tables"

build/core.o: src/core.c build/load_char.h build/sql.h build/preamble.h build/afterward.h build/argparse.h build/modules.h
	$(CC) -c -O3 -Ibuild/ -Ilib/ -Isrc/ $(CWARNS) src/core.c -o build/core.o -Wall -Wextra -pedantic -std=c99

build/load_char.h: src/load.lua src/compileToHeader.lua
	build/luajit src/compileToHeader.lua LUA_LOAD src/load.lua build/~load_char.h
	- diff build/load_char.h build/~load_char.h
	mv build/~load_char.h build/load_char.h

build/sql.h: src/sql.lua src/compileToHeader.lua
	build/luajit src/compileToHeader.lua LUA_SQL src/sql.lua build/~sql.h
	- diff build/sql.h build/~sql.h
	mv build/~sql.h build/sql.h

build/preamble.h: src/preamble.lua src/compileToHeader.lua
	build/luajit src/compileToHeader.lua LUA_PREAMBLE src/preamble.lua build/~preamble.h
	- diff build/preamble.h build/~preamble.h
	mv build/~preamble.h build/preamble.h

build/modules.h: src/modules.lua src/compileToHeader.lua
	build/luajit src/compileToHeader.lua LUA_MODULES src/modules.lua build/~modules.h
	- diff build/modules.h build/~modules.h
	mv build/~modules.h build/modules.h

build/argparse.h: src/argparse.lua src/compileToHeader.lua
	build/luajit src/compileToHeader.lua LUA_ARGPARSE src/argparse.lua build/~argparse.h
	- diff build/argparse.h build/~argparse.h
	mv build/~argparse.h build/argparse.h

build/afterward.h: src/afterward.lua src/compileToHeader.lua
	build/luajit src/compileToHeader.lua LUA_AFTERWARD src/afterward.lua build/~afterward.h
	- diff build/afterward.h build/~afterward.h
	mv build/~afterward.h build/afterward.h

#  These steps should be pre-baked in an install so we - the call in case orb
#  is not installed

scr/core.c: orb/core.orb
	- br o
src/sql.lua: orb/sql.orb
	- br o
src/load.lua: orb/load.orb
	- br o
src/preamble.lua: orb/preamble.orb
	- br o
src/modules.lua: orb/modules.orb
	- br o
src/afterward.lua: orb/afterward.orb
	- br o
src/argparse.lua: orb/argparse.orb
	- br o
