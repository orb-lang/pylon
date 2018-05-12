
all: br

br: boot.o src/libfemto.o lib/libluv.a
	gcc -o br -Ilib/ boot.o src/libfemto.o lib/libluv.a lib/libuv.a lib/libluajit.a -lm -pagezero_size 10000 -image_base 100000000

src/libfemto.o: src/femto.c src/femto_class.h
	$(CC) -c src/femto.c -o src/libfemto.o -Ilib/ -Wall -Wextra -pedantic -std=c99

src/femto.h: src/femto.c
	mv src/femto.h src/~femto.h
	makeheaders src/femto.c
	tail -n +2 < src/femto.h | uniq | sed '/extern/d' | sed '$d' > src/femto.h_strip
	- colordiff src/~femto.h src/femto.h_strip
	rm src/~femto.h
	mv src/femto.h_strip src/femto.h

boot_string.h: boot.lua femto_struct.h interpol.lua
	lua interpol.lua boot.lua LUA_BOOT > ~boot_string.h
	- colordiff boot_string.h ~boot_string.h
	mv ~boot_string.h boot_string.h

boot.o: boot.lua boot.c src/libfemto.o femto_instance.h femto_struct.h boot_string.h
	gcc -c -Ilib/ -I/src boot.c -Wall -Wextra -pedantic -std=c99

femto_instance.h: src/femto.h pop.awk
	awk -f pop.awk -v class=femto_struct -v Instance=Femto src/femto.h > ~femto_instance.h
	- colordiff femto_instance.h ~femto_instance.h
	mv ~femto_instance.h femto_instance.h

femto_struct.h: src/femto.h decl.awk
	sed -e "s/(/ (/" < src/femto.h | awk -f decl.awk -v name=femto_struct > ~femto_struct.h
	- colordiff femto_struct.h ~femto_struct.h
	mv ~femto_struct.h femto_struct.h
