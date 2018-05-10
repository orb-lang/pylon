#include <stdio.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include "luajit.h"
#include "sqlite3.h"
#include "src/femto.h"

// Set up a struct to hold the femto library

#include "femto_struct.h"

// Populate the instance

#include "femto_instance.h"


// big ol' static string.

#include "boot_string.h"


int main(int argc, char *argv[])
{
  int status;

  lua_State *L = luaL_newstate(); // open Lua
  if (!L) {
    printf("No Lua\n");
    return -1; // Checks that Lua started up
  }

  luaL_openlibs(L); // load Lua libraries
  printf("Lua\n");
  if (argc > 1) {
    status = luaL_loadstring(L, LUA_BOOT);  // load Lua script
    int ret = lua_pcall(L, 0, 0, 0); // tell Lua to run the script
    if (ret != 0) {
      fprintf(stderr, "%s\n", lua_tostring(L, -1)); // tell us what mistake we made
      return 1;
    }
    lua_getfield(L, LUA_GLOBALSINDEX, "__mkfemto");
    // load pointer to femto_cell into namespace
    lua_pushlightuserdata(L, (void *) &Femto);
    lua_call(L, 1, 0);
    status = luaL_loadfile(L, "femto.lua");
    ret = lua_pcall(L, 0, 0, 0);
    if (ret != 0) {
        fprintf(stderr, "%s\n", lua_tostring(L, -1));
        return 2;
    }
  }

  lua_close(L); // Close Lua
  return 0;
}
