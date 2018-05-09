#include <stdio.h>
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include "luajit.h"
#include "sqlite3.h"
#include "src/femto.h"

// To make this work I'm going to need:

// https://www.freelists.org/post/luajit/How-to-call-functions-from-a-static-library-in-Luajit,8


// Set up a struct to hold the femto library

struct femto_cell {
    void (*initFm)();
    void (*fmProcessKeypress)();
    void (*fmMoveCursor)(int key);
    void (*fmDrawMessageBar)(struct abuf *ab);
    void (*fmDrawStatusBar)(struct abuf *ab);
    void (*fmDrawRows)(struct abuf *ab);
    void (*fmScroll)();
    void (*abFree)(struct abuf *ab);
    void (*abAppend)(struct abuf *ab,const char *s,int len);
    void (*fmFind)();
    void (*fmFindCallback)(char *query,int key);
    void (*fmSave)();
    void (*fmOpen)(char *filename);
    void *(*fmRowsToString)(int *buflen);
    void (*fmDelChar)();
    void (*fmInsertNewline)();
    void (*fmInsertChar)(int c);
    void (*fmRowDelChar)(frow *row,int at);
    void (*fmRowAppendString)(frow *row,char *s,size_t len);
    void (*fmRowInsertChar)(frow *row,int at,int c);
    void (*fmDelRow)(int at);
    void (*fmFreeRow)(frow *row);
    void (*fmInsertRow)(int at,char *s,size_t len);
    void (*fmUpdateRow)(frow *row);
    int (*fmRowRxToCx)(frow *row,int rx);
    int (*fmRowCxToRx)(frow *row,int cx);
    int (*fmSyntaxToColor)(int hl);
    void (*fmUpdateSyntax)(frow *row);
    int (*getWindowSize)(int *rows,int *cols);
    int (*getCursorPosition)(int *rows,int *cols);
    int (*fmReadKey)();
    void (*enableRawMode)();
    void (*disableRawMode)();
    void (*die)(const char *s);
    char *(*fmPrompt)(char *prompt,void(*callback)(char *,int));
    void (*fmRefreshScreen)();
    void (*fmSetStatusMessage)(const char *fmt,...);
};

// Populate the instance

struct femto_cell Femto = {
    .initFm = &initFm,
    .fmProcessKeypress = &fmProcessKeypress,
    .fmMoveCursor = &fmMoveCursor,
    .fmDrawMessageBar = &fmDrawMessageBar,
    .fmDrawStatusBar = &fmDrawStatusBar,
    .fmDrawRows = &fmDrawRows,
    .fmScroll = &fmScroll,
    .abFree = &abFree,
    .abAppend = &abAppend,
    .fmFind = &fmFind,
    .fmFindCallback = &fmFindCallback,
    .fmSave = &fmSave,
    .fmOpen = &fmOpen,
    .fmRowsToString = &fmRowsToString,
    .fmDelChar = &fmDelChar,
    .fmInsertNewline = &fmInsertNewline,
    .fmInsertChar = &fmInsertChar,
    .fmRowDelChar = &fmRowDelChar,
    .fmRowAppendString = &fmRowAppendString,
    .fmRowInsertChar = &fmRowInsertChar,
    .fmDelRow = &fmDelRow,
    .fmFreeRow = &fmFreeRow,
    .fmInsertRow = &fmInsertRow,
    .fmUpdateRow = &fmUpdateRow,
    .fmRowRxToCx = &fmRowRxToCx,
    .fmRowCxToRx = &fmRowCxToRx,
    .fmSyntaxToColor = &fmSyntaxToColor,
    .fmUpdateSyntax = &fmUpdateSyntax,
    .getWindowSize = &getWindowSize,
    .getCursorPosition = &getCursorPosition,
    .fmReadKey = &fmReadKey,
    .enableRawMode = &enableRawMode,
    .disableRawMode = &disableRawMode,
    .die = &die,
    .fmPrompt = &fmPrompt,
    .fmRefreshScreen = &fmRefreshScreen,
    .fmSetStatusMessage = &fmSetStatusMessage
};



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
    status = luaL_loadfile(L, "hello.lua");  // load Lua script
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
