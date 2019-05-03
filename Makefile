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

build/boot.o: src/boot.c src/load_char.h
	$(CC) -c -Ibuild/ -Ilib/ -Isrc/ $(CWARNS) src/boot.c -o build/boot.o -Wall -Wextra -pedantic -std=c99

src/load_char.h: src/load.lua src/compileToHeader.lua
	build/luajit src/compileToHeader.lua LUA_LOAD src/load.lua build/~load_char.h
	- colordiff build/load_char.h build/~load_string.h
	mv build/~load_char.h build/load_char.h

#  This step should be pre-baked in an install so we - the call in case orb
#  is not installed

src/load.lua: orb/load.orb
	- orb
