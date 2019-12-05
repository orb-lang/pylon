#!/bin/sh

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

# Subdirectories in /deps contain code written by others that is not
# governed by this license.  Look in the respective directories for
# information on their copyright / license.
# Same for `/nano`, `/hammer` (which still have to move…)

# abort on error
set -e


# slightly more readable paths (no more cd ../../..(/..?) )
basedir="$PWD"
enter() {
  cd "$1"
}
leave() {
  cd "$basedir"
}


# platform identification (using same names as luajit, lpeg, … Makefile)
case "$(uname)" in
  Linux|linux)  PLAT="linux" ;;
  Darwin|macos|macosx) PLAT="macosx" ;;
esac
[ -n "$PLAT" ] # bail out if unknown

## 0. environment variables
if [ "$PLAT" = "macosx" ] ; then
  export MACOSX_DEPLOYMENT_TARGET=10.14
fi
# clear Lua environment variables that may break the build
unset LUA_INIT LUA_INIT_5_1 LUA_PATH LUA_PATH_5_1

## 1. fetch submodules, check out correct versions
git submodule update --init --recursive

enter deps/luajit/ # symlink into luv's deps
  git checkout v2.1
leave


## 1. build luv
enter deps/luv
  # updates submodules & resets tree
  make reset
  # builds static library
  BUILD_MODULE=OFF make
leave
# move our artifacts over to pylon/build
cp deps/luv/build/libluv.a build/
cp deps/luv/build/deps/libuv/libuv_a.a build/libuv.a


## 2. (re)compile LuaJIT in amalgam (all-in-one-file) mode
enter deps/luajit
  make amalg XCFLAGS=-DLUAJIT_ENABLE_LUA52COMPAT XCFLAGS+=-DLUA_USE_ASSERT
  # Note: turn off the USE_ASSERT once we either figure out what's crashing,
  # Or determine that it isn't helping.
leave
# move our artifacts over to pylon/build
lj=deps/luajit/src
cp $lj/lua.h $lj/lualib.h $lj/luajit.h $lj/luaconf.h $lj/lauxlib.h build/
cp $lj/libluajit.a $lj/luajit build/
unset lj


## 3. build sqlite
enter deps/sqlite
  mkdir -p build
  cd build
  ../configure
  make
leave
# move our artifacts over to pylon/build
cp deps/sqlite/build/sqlite3.o build/
cp deps/sqlite/sqlite3.h build/ # NOTE sqlite3.h went to lib initially


## 4. build lpeg
enter deps/lpeg
  make "LUADIR=../luajit/src" "$PLAT" liblpeg.a
leave
# move our artifacts over to pylon/build
cp deps/lpeg/liblpeg.a build/


## 5. lfs_ffi is a single file
cp deps/luafilesystem_ffi/lfs_ffi.lua build/lfs.lua


## 6. luautf8
enter deps/luautf8
  gcc -O2 -I../../build -I../luajit/src -c lutf8lib.c -o lutf8lib.o
  ar rcs lua-utf8.a lutf8lib.o
leave
# move our artifacts over to pylon/build
# (mv not cp here because lua-utf8.a is not in luautf8's .gitignore and we
# neither want to edit that nor get the warning that there are changes…)
mv deps/luautf8/lua-utf8.a build/


## N. finally, build `br`
make "$PLAT"

