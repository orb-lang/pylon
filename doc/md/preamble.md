# Preamble

This adds the package loader, and will eventually contain the `core` standard
library\.


## Globals

Anything we want to put in the global namespace goes here\.


### \_Bridge table

This is what we test for to see if we're inside `bridge`, and where we put
things that we'll need later\.

\#Deprecated

```lua
local _Bridge = {}
-- remove this to vanish _Bridge from _G
-- using rawset here to express intention
rawset(_G, "_Bridge", _Bridge)
```


### package\.preload\["bridge"\]

A closure to return the `_Bridge` table, which will no longer be global\.

```lua
package.preload.bridge = function() return _Bridge end
```


### 5\.2 compatibility

  Provides the function `pack` to the global namespace, for handling variadic
arguments\.


#### pack\(\.\.\.\)

```lua
pack = table.pack
```


### Table Extensions

  `table.clear` and `table.new` are a stock part of LuaJIT, which is not
namespaced by default for compatibility reasons\.

`table.clear(tab)` sets all values to `nil`, while `table.new(narr, nrec)`
preallocates the given amount of slots in the array and record portions of the
table\.

The openresty fork of LuaJIT provides additional functions, [documented here](https://github.com/openresty/luajit2#new-lua-apis)\.

```lua
require "table.clear"
require "table.new"
require "table.isempty"
require "table.isarray"
require "table.nkeys"
-- require "table.clone" -- we provide a more general, but slower, version
```

## Loader

  `bridge` loads most of its code from a SQLite database containing module
bytecode and associated metadata\.

Here we provide the loader, used by `require`\.


#### do block

Since we're loading it straight from the binary, wrap it in a `do` block\.

```lua
do
```


#### bridge\_modules

```lua
_Bridge.bridge_modules = { }
_Bridge.loaded = { }
_Bridge.load_hashes = { }
```


#### bridge\.is\_tty

Tells us if we're living in TTY land, so we can decide things like whether to
colorize\.

```lua
_Bridge.is_tty = require "luv" . guess_handle(1) == 'tty'
```


### SQL statements

For now, we're just going to load the latest compiled version of a given
module\.

```lua
local bytecode_by_module = [[
SELECT code.binary, code.hash
FROM code
INNER JOIN module
ON module.code = code.code_id
WHERE module.name = :name
ORDER BY module.time desc limit 1
;
]]

local bytecode_by_module_and_project = [[
SELECT code.binary, code.hash
FROM code
INNER JOIN module
ON module.code = code.code_id
INNER JOIN project
ON project.project_id = module.project
WHERE project.name = :project_name
AND module.name = :module_name
ORDER BY module.time desc limit 1
;
]]
```


### \_openBridgeModules\(\)

This either opens `bridge.modules`, returning a `conn`, or failing that
returns `nil`\.

If we get a conn, we append a `package.loaders` with it, otherwise we do
nothing\.  Creating `bridge.modules` in the event it doesn't exist is the
responsibility of `orb`, which contains the compiler\.

First, let's get a plausible filename:

```lua
local home_dir = os.getenv "HOME"
local bridge_modules = os.getenv "BRIDGE_MODULES"
local bridge_home = os.getenv "BRIDGE_HOME"

   -- use BRIDGE_HOME if we have it
if not bridge_home then
   local xdg_data_home = os.getenv "XDG_DATA_HOME"
   if xdg_data_home then
      bridge_home = xdg_data_home .. "/bridge"
   else
      bridge_home = home_dir .. "/.local/share/bridge"
   end
end

if not bridge_modules then
   bridge_modules = bridge_home.. "/bridge.modules"
end

_Bridge.bridge_home = bridge_home
_Bridge.bridge_modules_home = bridge_modules
```

Add the conn to \_Bridge:

```lua
local ok, bridge_conn = pcall(sql.open, bridge_modules, "rw")
if ok then
   _Bridge.modules_conn = bridge_conn
else
   print "no bridge.modules"
end
```


#### bootstrap

Sometimes we need to regenerate a database, since SQLite migration techniques
are quite limited\.

For now, hard\-coded:

```lua
local bridge_strap = home_dir .. "/.local/share/bridge/~bridge.modules"
local ok, strap_conn = pcall(sql.open, bridge_strap, "rw")
if ok then
   _Bridge.bootstrap_conn = strap_conn
end
```


### loaderGen\(conn\)

Returns a function which loads modules from a given database connection\.

```lua
local toRow = assert(sql.toRow)

local function resultMap(result)
   if result == nil then return nil end
   return toRow(result)
end

local function modNames(mod_name)
   local project, mod = string.match(mod_name, "(.*):(.*)")
   if not mod then
      mod = mod_name
   end
   -- might be "module/module":
   local mod_double = mod .. "/" .. mod
   -- might be "project:module" -> "project/module"
   local proj_double = ""
   if project then
      proj_double = project .. "/" .. mod
   end
   return project, mod, proj_double, mod_double
end

_Bridge.modNames = modNames

local function loaderGen(conn)
   -- check that we have a database conn
   if not conn then error("sql connection failed") end
   -- make prepared statements
   local module_stmt = conn:prepare(bytecode_by_module)
   local project_stmt = conn:prepare(bytecode_by_module_and_project)
   -- return loader

   return function (mod_name)
      package.bridge_loaded = package.bridge_loaded or {}
      -- split the module into project and modname
      local bytecode = nil
      local project, mod, proj_double, mod_double = modNames(mod_name)
      if project then
         -- retrieve bytecode by project and module
         bytecode = resultMap(project_stmt :bind(project, mod) :resultset())
         if not bytecode then
            -- try mod_double
            project_stmt:reset()
            bytecode = resultMap(project_stmt :bind(project, mod_double)
                                    :resultset())
         end
         if not bytecode then
            -- try proj_double
            project_stmt:reset()
            bytecode = resultMap(project_stmt :bind(project, proj_double)
                                    :resultset())
         end
         project_stmt:reset()
      else
         -- retrieve by bare module name
         bytecode = resultMap(module_stmt :bind(mod) :resultset())
         if not bytecode then
            module_stmt:reset()
            bytecode = resultMap(module_stmt :bind(mod_double) :resultset())
         end
         module_stmt:reset()
      end
      if bytecode then
         local binary, hash = bytecode.binary, bytecode.hash
         -- return a module-loading closure if already in scope
         if _Bridge.loaded[hash] then
            return function()
               return package.loaded[_Bridge.loaded[hash]]
            end
         end
         _Bridge.bridge_modules["@" .. mod_name] = true
         local loadFn, errmsg = load(binary, "@" .. mod_name)
         if loadFn then
            _Bridge.loaded[hash] = mod_name
            _Bridge.load_hashes[mod_name] = hash
            return loadFn
         else
             error(errmsg)
         end
      else
         return nil, ("unable to load: " .. mod_name)
      end
   end
end
```


### Add to package\.loaders

If we've loaded either database, add them, such that if we have both, the
`modules_conn` default is checked before the `bootstrap_conn`\.

We want the loaders after the `package.preload` loader, so we put them in
index 2:

```lua
if _Bridge.bootstrap_conn then
   table.insert(package.loaders, 2, loaderGen(_Bridge.bootstrap_conn))
end
if _Bridge.modules_conn then
   table.insert(package.loaders, 2, loaderGen(_Bridge.modules_conn))
end
```



#### end do block

This makes everything in the block into garbage if a loader isn't generated\.

```lua
end
```


## Strict mode

This, we make into a global, and nil out once we've used it, while
keeping all its helper upvalues in a `do` block, so losing the stricture
reference will collect them\.


### Stricture

Lifted straight from [penlight](link line not found for obelus: \.

[https://stevedonovan.github.io/Penlight/api/index.html on line 328)
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
   stricture = function (name,mod,predeclared)
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
end
```
