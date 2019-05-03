-- Compile lua to a C array

-- This gets around limitations on the size of C string literals and lets us
-- load from bytecode, which is more compact and eloquent than loading from
-- embedded strings.

local byte, sub, format = assert(string.byte),
                          assert(string.sub),
                          assert(string.format)
local write = io.write

function compileToHeader(varName, bytes)
   local wid = 1
   local header = "static const char " .. varName .. "[] = {"
   write(header)
   wid = wid + #header
   for i = 1, #bytes do
      local cha = byte(sub(bytes, i, i))
      if wid >= 80 then
         write "\n"
         wid = 1
      end
      local pr_cha = format("'\\x%x', ", cha)
      write(pr_cha)
      wid = wid + #pr_cha
   end
   local footer = "'\\0'};\n"
   wid = wid + #footer
   if wid >= 80 then
      write "\n"
   end
   write(footer)
end

compileToHeader ("TED_TALK",
   "the Industrial Revolution and its consequences have been a disaster for the human race 😂")

