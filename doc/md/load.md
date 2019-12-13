# load

The responsibilities of ``load``:


- Parse arguments


- Run the resulting behaviors

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
#### do block

Once again, we're not going to waste a level of indentation on this, but
we want to collect all local variables, so we wrap in a do block:

```lua
do
```
## Stricture

Lifted straight from [[penlight]
[https://stevedonovan.github.io/Penlight/api/index.html].

```lua
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
```
## Parse

Parse the arguments passed to ``br``.


### parseVersion(str)

Let's validate the version string on parse.


This function will be moved to ``load`` once I'm satisfied with how it works.

```lua
local L = require "lpeg"
local P, C, Cg, Ct, R, match = L.P, L.C, L.Cg, L.Ct, L.R, L.match
local format = assert(string.format)
local MAX_INT = 9007199254740991

local function cast_to_int(str_val)
   local num = tonumber(str_val)
   if num > MAX_INT then
      error ("version numbers cannot exceed 2^53 - 1, "
             .. str_val .. " is invalid")
   end
   return num
end

local function parse_version(str)
   local major  = Cg(R"09"^1, "major")
   local minor  = Cg(R"09"^1, "minor")
   local patch  = Cg(R"09"^1, "patch")
   local kelvin = P"[" * Cg(R"09"^1, "kelvin") * P"]"
   local knuth  = Cg(R"09"^1, "knuth") * P".."
   local patt = Ct(major
                  * (P"." * minor)
                  * (P"." * (kelvin + knuth + patch) + P(-1)))
                  * P(-1)
   local ver = match(patt, str)
   if not ver then
      if match(R"09"^1 * P"."^-1 * P(-1), str) then
         error("Must provide at least major and minor version numbers")
      else
         error("invalid --version format: " .. str)
      end
   end
   -- Cast to number
   for k,v in pairs(ver) do
      ver[k] = cast_to_int(v)
   end
   -- make alternate patch forms into flags
   if ver.kelvin then
      ver.patch = ver.kelvin
      ver.kelvin = true
   elseif ver.knuth then
      ver.patch = ver.knuth
      ver.knuth = true
   end

   return ver
end
```
```lua

_Bridge.brParse = package.argparse()
local brParse = _Bridge.brParse

brParse
   : require_command (false)
   : name "br"
   : description ("An lua, howth castle & environs.\n\n"
               .. "To view help for each command, type br <command> -h.")
   : epilog "For more info, see https://special-circumstanc.es"
   : help_description_margin(35)

local orb_c = brParse : command ("orb o")
                      : description "Literate compiler for Orb format."

local grym_c = brParse : command "grym"
                       : description ("Backup compiler for Orb format.\n"
                                    .."Not intended for long-term use.")
local helm_c = brParse
                  : command ("helm i")
                  : description "launch helm, the 'i'nteractive REPL."

orb_c
   : require_command (false)

orb_c
   : command "serve"
   : description "Launch the Orb server."

orb_c
   : command "knit"
   : description "Knit the codex."

orb_c
   : command "weave"
   : description "Weave the codex."

local orb_command_c = orb_c
   : command "compile"
   : description "Knits the codex and compiles the resulting sorcery files."
   : help_vertical_space(1)

orb_command_c
  : option "-v --version"
    : description "A (semantic) version string."
    : convert(parse_version)
    : args(1)

orb_command_c
  : option "-e --edition"
    : description ( "A named edition:\n  special meaning applies to "
                    .. "SESSION, CANDIDATE, and RELEASE.")
    : args(1)

orb_command_c
  : option "-H --home"
    : description ("URL to fetch versions of the project.")
    : args(1)

orb_command_c
  : option "-R --repo"
    : description ( "URL for the project's source repository.\n"
                  .. "  Defaults to git remote 'origin'.")
    : args(1)

orb_command_c
  : option "-W --website"
    : description ("URL for the project's user-facing website:\n"
                   .. "  documentation, tutorials, examples, etc.")
    : args(1)

orb_command_c
  : option "-p --project"
    : description "Name of project.  Defaults to name of home directory."

orb_c
   : command "revert"
   : description "Revert the latest compiled changes in project."
   : option "-p --project"
     : description "Project to revert."
     : args(1)

helm_c
   : option "-s --session"
     : description "Start the repl with a given, named session."
     : args(1)

helm_c
   : option "-n --new-session"
     : description "Begin a new, named session."
     : args(1)
```
#### end do block

```lua
end
```
#### gc

All of these ``do`` blocks are to emulate the per-module behavior of Lua,
creating closures so that all ``local`` variables become garbage.  So let's
collect them.

```lua
collectgarbage()
```
### Execute

Run the commands requested.

```lua
if rawget(_G, "arg") ~= nil then
   local ts = require "helm:helm/repr".ts
   table.insert(arg, 0, "")
   _Bridge.args = _Bridge.brParse:parse()
   local args = _Bridge.args
   print(ts(args))
   if args.orb then
     if args.revert then
        local revert = require "bundle:revert"
        revert()
     else
        local orb = require "orb"
        local uv = require "luv"
        orb.run(uv.cwd())
     end
   elseif args.grym == true then
      local grym = require "grym:orb"
      local uv = require "luv"
      grym.run(uv.cwd())
   elseif args.helm then
      print "helm"
      local helm = require "helm:helm"
      setfenv(0, __G)
      helm(__G)
      setfenv(0, _G)
   end
end
```
