# boot


We have both a ``boot.lua`` and a ``boot.c``.


Happily, ``orb`` will not currently clobber the latter. Nor will it write to it,
yet.


``orb`` semantics dictate that a ``boot.c.orb`` file will be knit after a
``boot.orb`` file, overwriting any ``boot.c`` from ``boot.orb`` in the process. All
of this may of course be configured, we will have a ``boot.c.orb`` and should
have no need for an ``#!c`` block in this file.

```lua
--sql = require "src/sqlite"

_BRIDGE = true

-- For now let's stay clear of LUA_PATH and friends.

package.path = "./?.lua;./?/?.lua;./src/?.lua;./src/?/?.lua;"
               .. "./lib/?.lua;./lib/?/?.lua;"
               .. "./lib/?/src/?.lua;./lib/?/src/?/?.lua"

ffi = require "ffi"
```
#NB I am officially using femto.c for nothing.### configs (system-dependent!)

LuaJIT can't read header files, so we need to paste in
a few snippets.


Change this to uint32_t if you're on a system that expires
in a couple decades.

```lua
ffi.cdef[[
   typedef uint64_t time_t;
]]
```

The termios struct might well be different for your OS.


To figure out approximately where your system keeps its headers,
run ``gcc --version``.  This path will be overly specific, get off
the train at ``include``.


Please submit a patch for your OS! Our build process will
introduce the necessary metadata eventually.


After some rummaging around, I found this for Darwin.
The magic number 20 is #defined under NCCS in termios.h.

```lua
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
```
