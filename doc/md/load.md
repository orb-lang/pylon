# load

The responsibilities of ``load``:


- Parse arguments


- If interactive and scripts:
   - Clone the global namespace
   - Run scripts into namespace clone
   - Launch REPL.

### Check for lua-utf8

```lua
-- local utf8 = require "lua-utf8"
-- assert(utf8, "no utf8")
```
## Bridge Path

``bridge`` uses its own path, distinct from the ``LUA_PATH`` environment variable.


This is, predictably enough, ``BRIDGE_PATH``.

```lua


```
## Stricture

Lifted straight from [[penlight]
[https://stevedonovan.github.io/Penlight/api/index.html].

```lua
do
    local getinfo, error, rawset, rawget = debug.getinfo, error, rawset, rawget
    local strict = {}

    local function what ()
        local d = getinfo(3, "S")
        return d and d.what or "C"
    end

    --- make an existing table strict.
    -- @string name name of table (optional)
    -- @tab[opt] mod table - if `nil` then we'll return a new table
    -- @tab[opt] predeclared - table of variables that are to be considered predeclared.
    -- @return the given table, or a new table
    local function stricture(name,mod,predeclared)
        local mt, old_newindex, old_index, old_index_type, global, closed
        if predeclared then
            global = predeclared.__global
            closed = predeclared.__closed
        end
        if type(mod) == 'table' then
            mt = getmetatable(mod)
            if mt and rawget(mt,'__declared') then return end -- already patched...
        else
            mod = {}
        end
        if mt == nil then
            mt = {}
            setmetatable(mod, mt)
        else
            old_newindex = mt.__newindex
            old_index = mt.__index
            old_index_type = type(old_index)
        end
        mt.__declared = predeclared or {}
        mt.__newindex = function(t, n, v)
            if old_newindex then
                old_newindex(t, n, v)
                if rawget(t,n)~=nil then return end
            end
            if not mt.__declared[n] then
                if global then
                    local w = what()
                    if w ~= "main" and w ~= "C" then
                        error("assign to undeclared global '"..n.."'", 2)
                    end
                end
                mt.__declared[n] = true
            end
            rawset(t, n, v)
        end
        mt.__index = function(t,n)
            if not mt.__declared[n] and what() ~= "C" then
                if old_index then
                    if old_index_type == "table" then
                        local fallback = old_index[n]
                        if fallback ~= nil then
                            return fallback
                        end
                    else
                        local res = old_index(t, n)
                        if res ~= nil then
                            return res
                        end
                    end
                end
                local msg = "variable '"..n.."' is not declared"
                if name then
                    msg = msg .. " in '"..name.."'"
                end
                error(msg, 2)
            end
            return rawget(t, n)
        end
        return mod
    end

    stricture(nil,_G,{_PROMPT=true,__global=true})
end
```
#### gc

All of these ``do`` blocks are to emulate the per-module behavior of Lua,
creating closures so that all ``local`` variables become garbage.  So let's
collect them.

```lua
collectgarbage()
```
## Parse

Currently we are doing the dumbest possible thing to parse ``br`` invocations.


Now that we have ``argparse`` it's time to do it right.

```lua
-- we're going to run in parallel while we build the parser:

rawset(_G, "brParse", package.argparse())

brParse
   : require_command (false)
   : name "bridge"
   : description "An lua, howth castle & environs."
   : epilog "For more info, see https://specialcircumstanc.es"

local orb_c = brParse : command ("orb o")

local helm_c = brParse
                  : command ("helm i")
                  : description "launch helm, the 'i'nteractive REPL."

orb_c
   : require_command (false)
   : description "Literate compiler for Orb format."

orb_c
   : command "serve"
   : description "Launch the Orb server."

orb_c
   : command "knit"
   : description "Knit the codex."

orb_c
   : command "weave"
   : description "Weave the codex."

orb_c
   : command "compile"
   : description "Knits the codex and compiles the resulting sorcery files."

helm_c
   : option "-s --session"
     : description "Start the repl with a given, named session."
     : args(1)

helm_c
   : option "-n --new-session"
     : description "Begin a new, named session."
     : args(1)

-- this will fetch us our REPL using the usual frippery,
-- we've put a stub block around it as deprecation
---[[
local function _strip(argument)
   -- a dimwitted thing which removes a magic argument
   for i = 0, #argument do
      if i == 0 then
         argument[i] = nil
      else
         argument[i-1] = argument[i]
      end
   end
   argument[#argument] = nil
   return argument
end

local function _makeParsyHappen()
   -- stop trying to make Parsy happen.
   --
   -- it will never happen.
   --
   -- hack to get around the fact that argparse was written assuming a
   -- script name as the first argument
   table.insert(arg, 0, "")
   _Bridge.args = brParse:parse()

end

if rawget(_G, "arg") ~= nil then
    -- time for an ugly hack:
    for i = 0, #arg do
      print(arg[i])
    end
    if arg[0] == "OLD" then
        _strip(arg)
        -- do old boot sequence
        if string.sub(arg[0], -4) == ".lua" then
            loadfile(arg[0])()
        elseif string.sub(arg[0], -4) == ".raw" then
           loadfile(arg[0])()
        else
           loadfile(arg[0] .. ".lua")()
        end
    else
        _makeParsyHappen()
        if _Bridge.args["orb"] == true then
          print "orb"
          local orb = require "orb"
          local uv = require "luv"
          orb.run(uv.cwd())
        elseif _Bridge.args["helm"] == true then
          print "helm"
          local helm = require "helm"
          helm()
        end
    end
end
--]]
```
