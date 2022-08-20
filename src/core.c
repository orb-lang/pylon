

















#include <stdio.h>
#include <string.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include "luajit.h"
#include "sqlite3.h"










// declaration for registries of static object libraries
LUALIB_API int luaopen_luv (lua_State *L);
LUALIB_API int luaopen_lpeglabel (lua_State *L);
LUALIB_API int luaopen_lfs (lua_State *L);
LUALIB_API int luaopen_utf8(lua_State *L);














// Constant arrays of compiled bytecode
#include "sql.h"
#include "bridge.h"
#include "preamble.h"
#include "modules.h"
#include "load_char.h"
#include "argparse.h"
#include "afterward.h"

const char * SQL_NAME = "@sql";
const char * BRIDGE_NAME = "@bridge";
const char * PREAMBLE_NAME = "@preamble";
const char * MODULES_NAME = "@modules";
const char * ARGPARSE_NAME = "@argparse";
const char * LOAD_NAME = "@load";
const char * AFTERWARD_NAME = "@afterward";










// dummy pointer to statically link in SQLite
int (* sqlite3_dummy_ptr) (sqlite3*, int) = &sqlite3_busy_timeout;








// Print an error.
static int lua_die(lua_State *L, int errno) {
    fprintf(stderr, "err #%d: %s\n", errno, lua_tostring(L, -1));
    return errno;
}









// debug-load a string (or bytecode)
static int debug_load(lua_State *L,
                      const char bytecode[],
                      int byte_len,
                      const char * name) {
    lua_getglobal(L, "debug");
    lua_getfield(L, -1, "traceback");
    lua_replace(L, -2);
    int status = luaL_loadbuffer(L, bytecode, byte_len, name);
    if (status != 0) {
       return lua_die(L, status);
    }
    int ret = lua_pcall(L, 0, 0, -2);
    if (ret != 0) {
        return lua_die(L, ret);
    }
    lua_pop(L, 1);
    return ret;
}










//  main()
//
//  We do the minimum necessary and hand control to Lua.

int main(int argc, char *argv[]) {
    //  Start a VM
    lua_State *L = luaL_newstate();

    if (!L) {
        return 1;
    }

    // load core Lua libraries
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

    // place old-school FFI libs into package.preload
    lua_getglobal(L, "package");
    lua_getfield(L, -1, "preload"); /* get 'package.preload' */
    lua_pushcfunction(L, luaopen_luv);
    lua_setfield(L, -2, "luv"); /* package.preload[luv] = luaopen_luv */
    lua_pushcfunction(L, luaopen_lpeglabel);
    lua_setfield(L, -2, "lpeg");
    lua_pushcfunction(L, luaopen_lfs);
    lua_setfield(L, -2, "lfs");
    lua_pushcfunction(L, luaopen_utf8);
    lua_setfield(L, -2, "lua-utf8");

    // set up runtime
    // LUA_LOAD aka load.orb handles all application code
    debug_load(L, LUA_SQL, sizeof LUA_SQL, SQL_NAME);
    debug_load(L, LUA_BRIDGE, sizeof LUA_BRIDGE, BRIDGE_NAME);
    debug_load(L, LUA_PREAMBLE, sizeof LUA_PREAMBLE, PREAMBLE_NAME);
    debug_load(L, LUA_MODULES, sizeof LUA_MODULES, MODULES_NAME);
    debug_load(L, LUA_ARGPARSE, sizeof LUA_ARGPARSE, ARGPARSE_NAME);
    debug_load(L, LUA_LOAD, sizeof LUA_LOAD, LOAD_NAME);

    // tear down and close lua_State
    debug_load(L, LUA_AFTERWARD, sizeof LUA_AFTERWARD, AFTERWARD_NAME);
    lua_close(L); // Close Lua
    return 0;
}

