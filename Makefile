BRLIBS = build/libfemto.o   \
         build/libluv.a   \
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

br: build/boot.o build/libfemto.o build/libluv.a
	$(CC) -o br $(CWARNS) build/boot.o $(BRLIBS) -Ibuild/ -Ilib/ -lm -pagezero_size 10000 -image_base 100000000

build/boot.o: src/boot.lua src/boot.c src/libfemto.o \
              src/femto_instance.h src/femto_struct.h \
              src/boot_string.h src/load_string.h
	$(CC) -c -Ibuild/ -Ilib/ -Isrc/ $(CWARNS) src/boot.c -o build/boot.o -Wall -Wextra -pedantic -std=c99

src/boot_string.h: src/boot.lua src/femto_struct.h src/interpol.lua
	lua src/interpol.lua src/boot.lua LUA_BOOT > build/~boot_string.h
	- colordiff build/boot_string.h build/~boot_string.h
	mv build/~boot_string.h build/boot_string.h

src/load_string.h: src/load.lua
	lua src/interpol.lua src/load.lua LUA_LOAD > build/~load_string.h
	- colordiff build/load_string.h build/~load_string.h
	mv build/~load_string.h build/load_string.h

#  This step should be pre-baked in an install so we - the call in case orb
#  is not installed

src/boot.lua: orb/boot.orb
	- orb

src/load.lua: orb/load.orb
	- orb

#  I am not currently using any of this.

#  It will serve as a template for static binding SQLite.

#  It might not be this repo though.  Harmless for now.

build/libfemto.o: src/femto.c src/femto_class.h
	$(CC) -c src/femto.c -o build/libfemto.o -Ilib/ -Ibuild/ -Wall -Wextra -pedantic -std=c99

src/femto.h: src/femto.c
	mv src/femto.h src/~femto.h
	makeheaders src/femto.c
	tail -n +2 < src/femto.h | uniq | sed '/extern/d' | sed '$d' | sed 's/()/(void)/' > src/femto.h_strip
	- colordiff src/~femto.h src/femto.h_strip
	rm src/~femto.h
	mv src/femto.h_strip src/femto.h

src/femto_instance.h: src/femto.h src/pop.awk
	awk -f src/pop.awk -v class=femto_struct -v Instance=Femto src/femto.h > build/~femto_instance.h
	- colordiff build/femto_instance.h build/~femto_instance.h
	mv build/~femto_instance.h build/femto_instance.h

src/femto_struct.h: src/femto.h src/decl.awk
	sed -e "s/(/ (/" < src/femto.h | awk -f src/decl.awk -v name=femto_struct > build/~femto_struct.h
	- colordiff build/femto_struct.h build/~femto_struct.h
	mv build/~femto_struct.h build/femto_struct.h
