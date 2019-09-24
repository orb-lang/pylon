BRLIBS = build/libluv.a   \
         build/libuv.a    \
         build/liblpeg.a  \
         build/libluajit.a \
         build/lua-utf8.a

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
			-Wdeclaration-after-statement \
			-Wmissing-prototypes \
			-Wnested-externs \
			-Wstrict-prototypes \


all: br

install: br
	cp br ~/scripture/

uninstall:
	rm ~/scripture/br

br: build/boot.o build/libluv.a
	$(CC) -o br $(CWARNS) build/boot.o $(BRLIBS) -Ibuild/ -Ilib/ -lm -pagezero_size 10000 -image_base 100000000

build/boot.o: src/boot.c build/load_char.h build/lfs.h build/sql.h build/preamble.h build/afterward.h build/argparse.h
	$(CC) -c -Ibuild/ -Ilib/ -Isrc/ $(CWARNS) src/boot.c -o build/boot.o -Wall -Wextra -pedantic -std=c99

build/load_char.h: src/load.lua src/compileToHeader.lua
	build/luajit src/compileToHeader.lua LUA_LOAD src/load.lua build/~load_char.h
	- colordiff build/load_char.h build/~load_char.h
	mv build/~load_char.h build/load_char.h

build/lfs.h: src/lfs.lua src/compileToHeader.lua
	build/luajit src/compileToHeader.lua LUA_LFS src/lfs.lua build/~lfs.h
	- colordiff build/lfs.h build/~lfs.h
	mv build/~lfs.h build/lfs.h

build/sql.h: src/sql.lua src/compileToHeader.lua
	build/luajit src/compileToHeader.lua LUA_SQL src/sql.lua build/~sql.h
	- colordiff build/sql.h build/~sql.h
	mv build/~sql.h build/sql.h

build/preamble.h: src/preamble.lua src/compileToHeader.lua
	build/luajit src/compileToHeader.lua LUA_PREAMBLE src/preamble.lua build/~preamble.h
	- colordiff build/preamble.h build/~preamble.h
	mv build/~preamble.h build/preamble.h

build/argparse.h: src/argparse.lua src/compileToHeader.lua
	build/luajit src/compileToHeader.lua LUA_ARGPARSE src/argparse.lua build/~argparse.h
	- colordiff build/argparse.h build/~argparse.h
	mv build/~argparse.h build/argparse.h

build/afterward.h: src/afterward.lua src/compileToHeader.lua
	build/luajit src/compileToHeader.lua LUA_AFTERWARD src/afterward.lua build/~afterward.h
	- colordiff build/afterward.h build/~afterward.h
	mv build/~afterward.h build/afterward.h

#  These steps should be pre-baked in an install so we - the call in case orb
#  is not installed

src/sql.lua: orb/sql.orb
	grym
src/lfs.lua: orb/lfs.orb
	grym
src/load.lua: orb/load.orb
	grym
src/preamble.lua: orb/preamble.orb
	grym
src/afterward.lua: orb/afterward.orb
	grym
src/argparse.lua: orb/argparse.orb
	grym