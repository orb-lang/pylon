sql = require "src/sqlite"

ffi = require "ffi"

--  LuaJIT can't read header files, so we need to paste in
--  a few snippets.
--
--  Change this to uint32_t if you're on a system that expires
--  in a couple decades.

ffi.cdef[[
   typedef uint64_t time_t;
]]

--  The termios struct might well be different for your OS.
--
--  To figure out approximately where your system keeps its headers,
--  run `gcc --version`.  This path will be overly specific, get off
--  the train at `include`.
--
--  Please submit a patch for your OS! Our build process will
--  introduce the necessary metadata eventually.
--
--  After some rummaging around, I found this for Darwin.
--  The magic number 20 is #defined under NCCS in termios.h.

ffi.cdef [[
   typedef unsigned long   tcflag_t;
   typedef unsigned char   cc_t;
   typedef unsigned long   speed_t;

   struct termios {
      tcflag_t c_iflag; /* input flags */
      tcflag_t c_oflag; /* output flags */
      tcflag_t c_cflag; /* control flags */
      tcflag_t c_lflag; /* local flags */
      cc_t     c_cc[20]; /* control chars */
      speed_t     c_ispeed;   /* input speed */
      speed_t     c_ospeed;   /* output speed */
   };
]]

--  The rest we straight up copy-paste from the header:

ffi.cdef [[
   typedef struct frow {
     int size;
     int rsize;
     char *chars;
     char *render;
     unsigned char *hl;
   } frow;

   struct fmConfig {
     int cx, cy;
     int rx;
     int rowoff;
     int coloff;
     int screenrows;
     int screencols;
     int numrows;
     frow *row;
     int dirty;
     char *filename;
     char statusmsg[80];
     time_t statusmsg_time;
     struct termios orig_termios;
   };

   struct fmConfig F;

   struct abuf {
     char *b;
     int len;
   };
]]

--  Including our all-important collection of function pointers:

ffi.cdef [[
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
]]

femto = ""

function __mkfemto(fm_struct_pt)
   femto = ffi.cast("struct femto_cell *", fm_struct_pt)
end