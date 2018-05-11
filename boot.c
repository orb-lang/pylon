#include <stdio.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include "luajit.h"
#include "sqlite3.h"

#include "src/femto_class.h"
#include "src/femto.h"

// Set up a struct to hold the femto library

#include "femto_struct.h"

// Populate the instance

#include "femto_instance.h"


//  Big ol' static string.

#include "boot_string.h"

// Print an error.
//
// Passes errno through to keep invocation to
// one line.
int lua_die(lua_State *L, int errno) {
    fprintf(stderr, "%d: %s\n", errno, lua_tostring(L, -1));
    return errno;
}

//  main()
//
//  We do the minimum necessary and hand control to Lua.

int main(int argc, char *argv[]) {
    int status;

    //  Start a VM
    lua_State *L = luaL_newstate();

    if (!L) {
        return 1;
    }

    // load Lua libraries
    luaL_openlibs(L);
    // place arguments, if any, in a table
    if (argc > 1) {
        lua_newtable(L); // args
        for (int i = 1; i < argc; i++) {
            lua_pushnumber(L, i);
            lua_pushstring(L, argv[i]);
            lua_settable(L, 1);  // args[i] = argv[i]
        }
        lua_setglobal(L, "arg");
    }
    // constant strings, the poor man's bytecode!
    status = luaL_loadstring(L, LUA_BOOT);
    if (status != 0) {
        return lua_die(L, status);
    }
    int ret = lua_pcall(L, 0, 0, 0);
    if (ret != 0) {
        return lua_die(L, ret);
    }
    // This prelude draws the FFI into memory, now to
    // pass in our jump table
    lua_getfield(L, LUA_GLOBALSINDEX, "__mkfemto");
    lua_pushlightuserdata(L, (void *) &Femto);
    ret = lua_pcall(L, 1, 0, 0);
    if (ret != 0) {
        return lua_die(L, ret);
    }
    //  Remove __mkfemto from the namespace, freeing it
    lua_pushnil(L);
    lua_setglobal(L, "__mkfemto");
    printf("femto\n");

    // Now we've got the pointers on the Lua side and
    // can just fire it up:
    status = luaL_loadfile(L, "femto.lua");
    ret = lua_pcall(L, 0, 0, 0);
    if (ret != 0) {
        return lua_die(L, ret);
    }

    lua_close(L); // Close Lua
    return 0;
}
