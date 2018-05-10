-- Stringulation

--  May God,
--  If there is a God,
--  Have mercy on my soul,
--  If I have a soul.

local L = require "lpeg"

local file = io.open(arg[1])

local line = nil

io.write("const char * const LUA_BOOT = ")

local contd = false
while true do
   line = file:read()
   if line == nil then
      -- end of write
      io.write(";")
      break
   end
   if contd then
      io.write("\n")
   else
      contd = true
   end
   line = line:gsub("\\", "\\\\"):gsub("'","\\'"):gsub("\"", "\\\"")
   io.write("\"" .. line .. "\"")
end

io.write("\n")

-- ΑΠΟ ΠΑΝΤΟΣ ΚΑΚΟΔΑΙΜΟΝΟΣ!

-- one may not exit cleanly from such a deed.

os.exit(-666)