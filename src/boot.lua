













--sql = require "src/sqlite"

_BRIDGE = true

-- For now let's stay clear of LUA_PATH and friends.
-- update: how dumb can I fucking be
--[[
--package.path = "./?.lua;./?/?.lua;./src/?.lua;./src/?/?.lua;"
--               .. "./lib/?.lua;./lib/?/?.lua;"
--               .. "./lib/?/src/?.lua;./lib/?/src/?/?.lua"
--]]

ffi = require "ffi"













ffi.cdef[[
   typedef uint64_t time_t;
]]















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
--INTERPOLATE<build/femto_struct.h>--
]]

femto = ""

function __mkfemto(fm_struct_pt)
   femto = ffi.cast("struct femto_struct *", fm_struct_pt)
end
