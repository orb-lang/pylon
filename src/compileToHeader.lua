-- Compile lua to a C array

-- This gets around limitations on the size of C string literals and lets us
-- load from bytecode, which is more compact and eloquent than loading from
-- embedded strings.

local byte, sub, format = assert(string.byte),
                          assert(string.sub),
                          assert(string.format)

function compileToHeader(varName, bytes, out)
   out = out or io.stdout
   local wid = 1
   local header = "const char " .. varName .. "[] = {"
   out:write(header)
   wid = wid + #header
   for i = 1, #bytes do
      local cha = byte(sub(bytes, i, i))
      local pr_cha = format("'\\x%x'", cha)
      if i ~= #bytes then
         pr_cha = pr_cha .. ", "
      end
      wid = wid + #pr_cha
      if wid >= 80 then
         out:write "\n"
         wid = 1 + #pr_cha
      end
     out:write(pr_cha)
   end
   local footer = "};\n\n"
   wid = wid + #footer
   if wid >= 80 then
      out:write "\n"
   end
   out:write(footer)
end

local infile = arg[2] and io.open(arg[2]) or io.stdin
local infile_name = arg[2] and string.sub(arg[2], 1, -4) or "STDIN"
local outfile = arg[3] and io.open(arg[3], "w+") or io.stdout

local bytes, err = loadstring(infile:read("*a"), infile_name)
if not bytes then
   print(err)
   os.exit(1)
else
   compileToHeader(arg[1], string.dump(bytes, ""), outfile)
   os.exit(0)
end

