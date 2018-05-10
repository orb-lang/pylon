--  Stringulation

--  LuaJIT provides a facility for turning bytecode into an object file,
--  which may be linked against a binary with the right flags.
--
--  This won't work for us, because normally the ffi is filled out dynamically,
--  with ffi.load().  Our pointers are only available at runtime.
--
--  To achieve this, we resort to the hoary old trick of embedding the boot sequence
--  as an ordinary C string.
--
--  Since this contains the cdef as its primary payload, this means we will have C strings
--  that are Lua code with Lua strings that are C code.
--
--  Some effort is made to remove comments, blank lines, and leading whitespace.
--
--  I draw the line at replacing newlines with semicolons.

local file = io.open(arg[1])

local line = nil

local find, sub = string.find, string.sub

local function trim(s)
   if s then
      local _,i1 = find(s,'^%s*')
      local i2 = find(s,'%s*$')
      return sub(s,i1+1,i2-1)
   end
end

local function sane_pr(line)
   line = line:gsub("\\", "\\\\"):gsub("'","\\'"):gsub("\"", "\\\"")
   io.write("\"" .. line .. "\\n\"")
end

--
io.write("const char * const LUA_BOOT = ")

local contd = false
while true do
   line = trim(file:read())
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
   --  Handle our interpolation point
   if line == "--INTERPOLATE--" then
      local f_struct = io.open(arg[2])
      local reading = true
      while reading do
         f_line = trim(f_struct:read())
         if f_line == nil then
            reading = false
         else
            sane_pr(f_line)
            io.write("\n")
         end
      end
   elseif not (string.sub(line, 1, 2) == "--") -- Strip comment lines and blank lines
      and not (#line == 0) then
      line = sane_pr(line)
   else
      contd = false
   end
end

io.write("\n")
os.exit(0)