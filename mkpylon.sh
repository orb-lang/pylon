   #!/usr/bin/sh

# Copyright 2018 Sam Putman.

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

cd luv
make reset

# For the static binary use this:

BUILD_MODULE=OFF make

# make

# Move our artifacts over to pylon/lib

cd build
cp libuv.a ../../build/
cp libluv.a ../../build/

cd ../..

# This builds luajit and uv and a luv binary to call from the Lua side.
# luv's build process doesn't use the amalgamated LuaJIT build, which we
# want, so we make this separately:

cd luv/deps/luajit
make amalg

# Copy headers and objects to own the libs

cp src/lua.h ../../../lib/
cp src/lualib.h ../../../lib/
cp src/luajit.h ../../../lib/
cp src/luaconf.h ../../../lib/
cp src/lauxlib.h ../../../lib/
cp src/libluajit.a ../../../build/
cd ../../..

# Next we make sqlite, which has the amalgamated build as the short path:

cd sqlite
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

cd lpeg-1.0.1
make macosx
cp liblpeg.a ../build/
cd ..

# Toss in lfs

cp luafilesystem/lfs-ffi.lua lib/lfs.lua

make install

