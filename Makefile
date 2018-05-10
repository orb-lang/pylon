
# We want this later:

# sed -e "s/(/ (/" < src/femto.h | awk -f decl.awk -v name=femto_struct

# awk -f pop.awk -v class=femto_struct -v Instance=Femto femto_struct.txt

all: br

br: boot.o src/libfemto.o femto_instance.h femto_struct.h boot_string.h src/femto.h
	gcc -o br -Ilib/ boot.o src/libfemto.o lib/libluajit.a -lm -pagezero_size 10000 -image_base 100000000

src/libfemto.o: src/femto.c
	$(CC) -c src/femto.c -o src/libfemto.o -Ilib/ -Wall -Wextra -pedantic -std=c99

src/femto.h: src/femto.c
	rm src/femto.h
	makeheaders src/femto.c
	# The below is brittle, depending on the last line drop
	tail -n +2 < src/femto.h | uniq | sed '/extern/d' | sed '$d' > src/femto.h_strip
	rm src/femto.h
	mv src/femto.h_strip src/femto.h

boot_string.h: boot.lua femto_struct.h
	lua stringulate.lua boot.lua femto_struct.h > boot_string.h

boot.o: boot.lua src/femto.h
	gcc -c -Ilib/ -I/src boot.c

femto_instance.h: src/femto.h
	awk -f pop.awk -v class=femto_struct -v Instance=Femto src/femto.h > femto_instance.h

femto_struct.h: src/femto.h
	sed -e "s/(/ (/" < src/femto.h | awk -f decl.awk -v name=femto_struct > femto_struct.h
