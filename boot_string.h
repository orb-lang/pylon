const char * const LUA_BOOT = "ffi = require \"ffi\"\n"
"ffi.cdef[[\n"
"typedef uint64_t time_t;\n"
"]]\n"
"ffi.cdef [[\n"
"typedef unsigned long   tcflag_t;\n"
"typedef unsigned char   cc_t;\n"
"typedef unsigned long   speed_t;\n"
"struct termios {\n"
"tcflag_t c_iflag; /* input flags */\n"
"tcflag_t c_oflag; /* output flags */\n"
"tcflag_t c_cflag; /* control flags */\n"
"tcflag_t c_lflag; /* local flags */\n"
"cc_t     c_cc[20]; /* control chars */\n"
"speed_t     c_ispeed;   /* input speed */\n"
"speed_t     c_ospeed;   /* output speed */\n"
"};\n"
"]]\n"
"ffi.cdef [[\n"
"typedef struct frow {\n"
"int size;\n"
"int rsize;\n"
"char *chars;\n"
"char *render;\n"
"unsigned char *hl;\n"
"} frow;\n"
"struct fmConfig {\n"
"int cx, cy;\n"
"int rx;\n"
"int rowoff;\n"
"int coloff;\n"
"int screenrows;\n"
"int screencols;\n"
"int numrows;\n"
"frow *row;\n"
"int dirty;\n"
"char *filename;\n"
"char statusmsg[80];\n"
"time_t statusmsg_time;\n"
"struct termios orig_termios;\n"
"};\n"
"struct fmConfig F;\n"
"struct abuf {\n"
"char *b;\n"
"int len;\n"
"};\n"
"]]\n"
"ffi.cdef [[\n"
"struct femto_cell {\n"
"void (*initFm)();\n"
"void (*fmProcessKeypress)();\n"
"void (*fmMoveCursor)(int key);\n"
"void (*fmDrawMessageBar)(struct abuf *ab);\n"
"void (*fmDrawStatusBar)(struct abuf *ab);\n"
"void (*fmDrawRows)(struct abuf *ab);\n"
"void (*fmScroll)();\n"
"void (*abFree)(struct abuf *ab);\n"
"void (*abAppend)(struct abuf *ab,const char *s,int len);\n"
"void (*fmFind)();\n"
"void (*fmFindCallback)(char *query,int key);\n"
"void (*fmSave)();\n"
"void (*fmOpen)(char *filename);\n"
"void *(*fmRowsToString)(int *buflen);\n"
"void (*fmDelChar)();\n"
"void (*fmInsertNewline)();\n"
"void (*fmInsertChar)(int c);\n"
"void (*fmRowDelChar)(frow *row,int at);\n"
"void (*fmRowAppendString)(frow *row,char *s,size_t len);\n"
"void (*fmRowInsertChar)(frow *row,int at,int c);\n"
"void (*fmDelRow)(int at);\n"
"void (*fmFreeRow)(frow *row);\n"
"void (*fmInsertRow)(int at,char *s,size_t len);\n"
"void (*fmUpdateRow)(frow *row);\n"
"int (*fmRowRxToCx)(frow *row,int rx);\n"
"int (*fmRowCxToRx)(frow *row,int cx);\n"
"int (*fmSyntaxToColor)(int hl);\n"
"void (*fmUpdateSyntax)(frow *row);\n"
"int (*getWindowSize)(int *rows,int *cols);\n"
"int (*getCursorPosition)(int *rows,int *cols);\n"
"int (*fmReadKey)();\n"
"void (*enableRawMode)();\n"
"void (*disableRawMode)();\n"
"void (*die)(const char *s);\n"
"char *(*fmPrompt)(char *prompt,void(*callback)(char *,int));\n"
"void (*fmRefreshScreen)();\n"
"void (*fmSetStatusMessage)(const char *fmt,...);\n"
"};\n"
"]]\n"
"femto = \"\"\n"
"function __mkfemto(fm_struct_pt)\n"
"femto = ffi.cast(\"struct femto_cell *\", fm_struct_pt)\n"
"end\n";
