--  * Interpol
--
--
--  LuaJIT provides a facility for turning bytecode into an object file,
--  which may be linked against a binary with the right flags.
--
--  This won't work for us, because normally the ffi is filled out dynamically,
--  with ffi.load().  Our pointers are only available at runtime.
--
--  =interpol= takes two arguments: the first is the template to load, the second
--  the name of the constant pointer.
--
--  To achieve this, we resort to the hoary old trick of embedding the boot sequence
--  as an ordinary C string.
--
--  Since this contains the cdef as its primary payload, this means we will have C strings
--  that are Lua code with Lua strings that are C code.
--
--  Some effort is made to remove comments, blank lines, and leading whitespace.
--
--  - [ ] #todo  Add a flag to output without stringulation.
--
--               This implies suppressing the C wrapper entirely, and a bit of arg juggling.
--
--  #NB this has been deprecated in favor of compileToHeader.lua


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

-- Making this work correctly in all cases would require parsing, since --[[
-- could show up inside a string.
-- in any case, we're only going to handle long comments on their own line,
-- consistent with not removing end-of-line line comments.

local function start_long_comment(line)
   local match = line:find "%-%-%[%["
   if match and match == 1 then
      return true
   end
   return false
end

local function end_long_comment(line)
   local _, match = line:find "%]%]"
   if _ then
      return line:sub(match + 1)
   end
end

local INTERPOL = "--INTERPOLATE<"

local var_name = arg[2] or ""

io.write("const char * const " .. var_name .. " = ")

local contd = false
local long_comment = false
while true do
   line = trim(file:read())
   if line == nil then
      -- end of write
      io.write(";")
      break
   end
   if not long_comment then
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
      elseif start_long_comment(line) then
         long_comment = true
         contd = false
      elseif not (string.sub(line, 1, 2) == "--")
         and not (#line == 0) then
           sane_pr(line)
      else
         contd = false
      end
   else
       local rem = end_long_comment(line)
       if rem then
         long_comment = false
        if rem ~= "" then
            sane_pr(rem)
        end
         contd = false
      end
   end
end
io.write("\n")
os.exit(0)