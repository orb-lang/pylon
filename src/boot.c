#include <stdio.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include "luajit.h"
#include "sqlite3.h"

#include "femto_class.h"
#include "femto.h"

// declaration for luv registry
LUALIB_API int luaopen_luv (lua_State *L);
LUALIB_API int luaopen_lpeg (lua_State *L);

// Set up a struct to hold the femto library

#include "femto_struct.h"

// Populate the instance

#include "femto_instance.h"

// Big ol' static string.

#include "boot_string.h"

// And another. This we can make into bytecode, it's pure Lua.



#include "load_string.h"

// Print an error.
static int lua_die(lua_State *L, int errno) {
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
            lua_pushnumber(L, i - 1);
            lua_pushstring(L, argv[i]);
            lua_settable(L, 1);  // args[i - 1] = argv[i]
        }
        lua_setglobal(L, "arg");
    }
    lua_getglobal(L, "package");
    lua_getfield(L, -1, "preload"); /* get 'package.preload' */
    lua_pushcfunction(L, luaopen_luv);
    lua_setfield(L, -2, "luv"); /* package.preload[luv] = luaopen_luv */
    lua_pushcfunction(L, luaopen_lpeg);
    lua_setfield(L, -2, "lpeg");
    lua_pop(L, 2); /* pop 'package' and 'preload' tables */
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
    if (argc > 1) {
        // load.lua is interned here
        // This one can probably be bytecode

        status = luaL_loadstring(L, LUA_LOAD);
        if (status != 0) {
            return lua_die(L, status);
        }
        ret = lua_pcall(L, 0, 0, 0);
        if (ret != 0) {
            return lua_die(L, ret);
        }
    }

    lua_close(L); // Close Lua
    return 0;
}
