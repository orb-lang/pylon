#include <stdio.h>
#include <string.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include "luajit.h"
#include "sqlite3.h"

// declaration for registries of static object libraries
LUALIB_API int luaopen_luv (lua_State *L);
LUALIB_API int luaopen_lpeg (lua_State *L);
LUALIB_API int luaopen_utf8(lua_State *L);

// And another. This we can make into bytecode, it's pure Lua.

//#include "load_string.h"
//int LUA_LOAD_L = strlen(LUA_LOAD);
#include "load_char.h"
int LUA_LOAD_L = sizeof LUA_LOAD;
// Print an error.
static int lua_die(lua_State *L, int errno) {
    fprintf(stderr, "err #%d: %s\n", errno, lua_tostring(L, -1));
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
    lua_pushcfunction(L, luaopen_utf8);
    lua_setfield(L, -2, "lua-utf8");
    printf("femto\n");
    if (argc > 1) {
        // load.lua is interned here
        // This one can probably be bytecode
        lua_getglobal(L, "debug");
        lua_getfield(L, -1, "traceback");
        lua_replace(L, -2);
        status = luaL_loadbuffer(L, LUA_LOAD, LUA_LOAD_L, "load_string");
        if (status != 0) {
            return lua_die(L, status);
        }
        int ret = lua_pcall(L, 0, 0, -2);
        if (ret != 0) {
            return lua_die(L, ret);
        }
        lua_pop(L, 1);
    }

    lua_close(L); // Close Lua
    return 0;
}
