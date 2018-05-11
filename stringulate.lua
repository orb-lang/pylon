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

local file = io.open(arg[1])

local line = nil

local find, sub, gsub = string.find, string.sub, string.gsub

local function trim(s)
   if s then
      local _,i1 = find(s,'^%s*')
      local i2 = find(s,'%s*$')
      return sub(s,i1+1,i2-1)
   end
end

local function sane_pr(line)
   line = gsub(line, "\\", "\\\\"):gsub("'","\\'"):gsub("\"", "\\\"")
   io.write("\"" .. line .. "\\n\"")
end

-- Interpolation string

local INTERPOL = "--INTERPOLATE<"

local var_name = arg[2] or ""

io.write("const char * const " .. var_name .. " = ")

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
   if sub(line, 1, #INTERPOL) == INTERPOL then
      -- extract filename and open
      local line_trim = sub(line, #INTERPOL + 1)
      local l_off = find(line_trim, ">")
      local f_handle = sub(line_trim, 1, l_off-1)
      local f_struct = io.open(f_handle)
      local reading = true
      while reading do
         f_line = trim(f_struct:read())
         if f_line == nil then
            reading, contd = false, false
         else
            sane_pr(f_line)
            io.write("\n")
         end
      end
   -- Strip comment lines and blank lines
   elseif not (string.sub(line, 1, 2) == "--")
      and not (#line == 0) then
      line = sane_pr(line)
   else
      contd = false
   end
end

io.write("\n")
os.exit(0)