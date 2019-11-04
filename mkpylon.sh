#!/bin/bash

# Copyright 2019 Sam Putman.

# MIT LICENSE:

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# The subdirectories luv, sqlite, and nano contain code not governed by this
# copyright and included by license as indicated.

# They also come with their own build systems, which we use:

cd luv || exit
make reset

# For the static binary use this:

BUILD_MODULE=OFF make

# make

# Move our artifact over to pylon/build

cd build || exit
cp libluv.a ../../build/

cd ../..

# Somehow we're losing libuv.a after a luv update, so build that:

cd luv/deps/libuv
if [[ "$OSTYPE" == "darwin"* ]]; then
  ./gyp_uv.py -f xcode
  xcodebuild -ARCHS="x86_64" -project out/uv.xcodeproj -configuration Release -alltargets
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
   ./gyp_uv.py -f make
   BUILDTYPE=Release make -C out
fi
# elif [[ "$OSTYPE" == "cygwin" ]]; then
        # POSIX compatibility layer and Linux environment emulation for Windows
# elif [[ "$OSTYPE" == "msys" ]]; then
        # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
# elif [[ "$OSTYPE" == "win32" ]]; then
        # I'm not sure this can happen.
# elif [[ "$OSTYPE" == "freebsd"* ]]; then
        # ...
# else
        # Unknown.
cp build/Release/libuv.a ../../../build/
cd ../../../

# This builds luajit and uv and a luv binary to call from the Lua side.
# luv's build process doesn't use the amalgamated LuaJIT build, which we
# want, so we make this separately:

cd luv/deps/luajit || exit
git checkout v2.1
if [[ "$OSTYPE" == "darwin"* ]]; then
  export MACOSX_DEPLOYMENT_TARGET=10.14
fi
make amalg XCFLAGS=-DLUAJIT_ENABLE_LUA52COMPAT

# Copy headers and objects to own the libs

cp src/lua.h ../../../build/
cp src/lualib.h ../../../build/
cp src/luajit.h ../../../build/
cp src/luaconf.h ../../../build/
cp src/lauxlib.h ../../../build/
cp src/libluajit.a ../../../build/
cp src/luajit ../../../build/
cd ../../..

# Next we make sqlite, which has the amalgamated build as the short path:

cd sqlite || exit
./configure
make
cp sqlite3.h ../lib/
cp sqlite3.o ../build/
cd ..

# "nano" is going to jump from nanomsg to nng when the latter is fully baked.
#
# This require cmake.

#cd nano/build
#cmake -DCMAKE_INSTALL_PREFIX=../../lib/ -DNN_STATIC_LIB=ON ..
#make install
#cd ../..

# Annnnd lpeg

cd lpeg-1.0.1 || exit
if [[ "$OSTYPE" == "darwin"* ]]; then
  make macosx
else
  make linux
fi
cp liblpeg.a ../build/
cd ..

# Toss in lfs, this is a no-op and we're going to use luv eventually so

cp luafilesystem/lfs-ffi.lua lib/lfs.lua

# Now lua-utf8
# Note that this is full-on macOS only right now and we need to fix that ASAP


cd luautf8 || exit
echo "BUILDING lua-utf8"
gcc -O2 -I../lib/ -I ../build -I../luv/deps/luajit  -c lutf8lib.c -o lutf8lib.o
ar rcs lua-utf8.a lutf8lib.o
mv lua-utf8.a ../build/
cd ..


# Make br and install.

make
