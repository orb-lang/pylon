#!/usr/bin/sh

cd luv
make clean
cd deps/luajit/
make clean
cd ../../..

cd sqlite
make clean

cd ..
cd nano
rm -rf build
mkdir build

cd ..

rm -rf lib/*

rm hello