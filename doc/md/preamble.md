# Preamble

This adds the package loader, and will eventually contain the ``core`` standard
library.


#### do block

Since we're loading it straight from the binary, wrap it in a ``do`` block.

```lua
do
```
### SQL statements

```lua
   local get_project_id = [[
SELECT CAST (project.project_id AS REAL) FROM project
WHERE project.name = %s;
]]

   local get_code_id_by_hash = [[
SELECT CAST (code.code_id AS REAL) FROM code
WHERE code.hash = %s;
]]

   local get_latest_module_code = [[
SELECT CAST (module.code AS REAL) FROM module
WHERE module.project = %d
   AND module.name = %s
ORDER BY module.time DESC LIMIT 1;
]]

   local get_all_module_ids = [[
SELECT CAST (module.code AS REAL),
       CAST (module.project AS REAL)
FROM module
WHERE module.name = %s
ORDER BY module.time DESC;
]]

local get_latest_module_code_id = [[
SELECT CAST (module.code AS REAL)
FROM module
WHERE module.name = %s
ORDER BY module.time DESC LIMIT 1;
]]

local get_latest_module_bytecode = [[
SELECT code.binary FROM code
WHERE code.code_id = %d ;
]]
```
### _openBridgeModules()

This either opens ``bridge.modules``, returning a ``conn``, or failing that
returns ``nil``.


If we get a conn, we append a ``package.loaders`` with it, otherwise we do
nothing.  Creating ``bridge.modules`` in the event it doesn't exist is the
responsibility of ``orb``, which contains the compiler.


First, let's get a plausible filename:

```lua
   local home_dir = os.getenv "HOME"
   local bridge_modules = os.getenv "BRIDGE_MODULES"

   if not bridge_modules then
      local xdg_data_home = os.getenv "XDG_DATA_HOME"
      if xdg_data_home then
         bridge_modules = xdg_data_home .. "/bridge/bridge.modules"
      else
         bridge_modules = home_dir .. "/.local/share/bridge/bridge.modules"
      end
   end
```

Then, since SQL will happily make something that doesn't exist, let's check:

```lua
   local br_mod = io.open(bridge_modules)
   if br_mod then
      -- close it
      br_mod:close()
      -- do the following dirty hack:
      br_mod = true
   end
```
### _loadModule(conn, mod_name)

Load a module given its name and a given database conn.

#NB Bug in logic of _loadModule causing failure to load in#Todo [ ] find edge case.
names look like ``orb/src/Orbit/handleline.orb`` instead of
``Orbit/handleline``

```lua
   local function _unwrapForeignKey(result)
      if result and result[1] and result[1][1] then
         return result[1][1]
      else
         return nil
      end
   end

   local function _loadModule(mod_name)
      assert(type(mod_name) == "string", "mod_name must be a string")
      print ("attempting to load " .. mod_name)
      local conn = sql.open(bridge_modules)
      if not conn then print "conn fail" ; return nil end
      package.bridge_loaded = package.bridge_loaded or {}
      -- split the module into project and modname
      local project, mod = string.match(mod_name, "(.*):(.*)")
      if not mod then
         mod = mod_name
      end
      local proj_name = project or ""
      --print ("loading " .. proj_name .. " " .. mod)
      -- might be "module/module":
      local mod_double = mod .. "/" .. mod
      -- might be "project:module" -> "project/module"
      local proj_double = ""
      if project then
         proj_double = project .. "/" .. mod
      end
      local code_id = nil
      if project then
         -- retrieve module name by project
         local project_id = _unwrapForeignKey(
                               conn:exec(
                               sql.format(get_project_id, project)))
         if not project_id then
            --print "no project id"
            return nil
         end
         code_id = _unwrapForeignKey(
                            conn:exec(
                            sql.format(get_latest_module_code,
                                       project_id, mod)))
         if code_id then
            --print "project id + mod worked"
         end
         if not code_id then
            -- try mod_double
            --print ("trying mod_double " .. mod_double)
            code_id = _unwrapForeignKey(
                            conn:exec(
                            sql.format(get_latest_module_code,
                                       project_id, mod_double)))
            if code_id then
               --print "mod_double succeeded"
            end
         end
         if not code_id then
            -- try proj_double
            code_id = _unwrapForeignKey(
                            conn:exec(
                            sql.format(get_latest_module_bytecode,
                                       project_id, proj_double)))
         end
      else
         -- retrieve by bare module name
         code_id = _unwrapForeignKey(
                                 conn:exec(
                                 sql.format(get_latest_module_id,
                                            mod)))
         if code_id then
            print "code_id acquired"
         end
         -- Think this logic is dodgy...
         --[[
         local foreign_keys = conn:exec(sql.format(get_all_module_ids, mod))
         if foreign_keys == nil then
            foreign_keys = conn:exec(sql.format(get_all_module_ids,
                                                mod_double))
            if foreign_keys == nil then
               --print ('no foreign key')
               return nil
            end
         else
            -- iterate through project_ids to check if we have more than one
            -- project with the same module name
            local p_id = foreign_keys[2][1]
            local same_project = true
            for i = 2, #foreign_keys[2] do
               same_project = same_project and p_id == foreign_keys[2][i]
            end
            if not same_project then
               package.warning = package.warning or {}
               table.insert(package.warning,
                  "warning: multiple projects contain a module called " .. mod)
            end
            code_id = foreign_keys[1][1]
         end
         --]]
      end
      if not code_id then
         print "no code_id"
         conn:close()
         return nil
      end
      local bytecode = _unwrapForeignKey(
                              conn:exec(
                              sql.format(get_latest_module_bytecode, code_id)))
      if bytecode then
         package.bridge_loaded[#package.bridge_loaded + 1] = "@" .. mod_name
         print ("loaded " .. mod_name .. " from bridge.modules")
         conn:close()
         return load(bytecode, "@" .. mod_name)
      else
         print ("unable to load: " .. mod_name)
         conn:close()
         return nil
      end
   end
```
### Add to package.loaders

If ``bridge.modules`` exists!

```lua
   if br_mod then
      print "loading bridge.modules"
      local insert = assert(table.insert)
      _G.packload = _loadModule
      insert(package.loaders, 1, _G.packload)
   else
      print "no bridge.modules"
   end
```
#### end do block

This makes everything in the block into garbage if a loader isn't generated.

```lua
end
```
