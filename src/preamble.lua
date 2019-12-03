










_Bridge = {}








do








_Bridge.bridge_modules = { }





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





local function _checkPath(path)
   local maybe_file = io.open(path)
   if maybe_file then
      -- close it
      maybe_file:close()
      return true
   end
end

if _checkPath(bridge_modules) then
   _Bridge.modules_conn = sql.open(bridge_modules)
else
   print "no bridge.modules"
end











local bridge_strap = home_dir .. "/.local/share/bridge/~bridge.modules"
if _checkPath(bridge_strap) then
   _Bridge.bootstrap_conn = sql.open(bridge_strap)
end







local function _unwrapForeignKey(result)
   if result and result[1] and result[1][1] then
      return result[1][1]
   else
      return nil
   end
end

local function loaderGen(conn)
   return function (mod_name)
      assert(type(mod_name) == "string", "mod_name must be a string")
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

            return nil , "no project id for " .. mod_name
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
                                 sql.format(get_latest_module_code_id,
                                            mod)))
         -- Think this logic is dodgy...
         ---[[
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
         return nil, "no code_id for " .. mod_name
      end
      local bytecode = _unwrapForeignKey(
                              conn:exec(
                              sql.format(get_latest_module_bytecode, code_id)))
      if bytecode then
         _Bridge.bridge_modules["@" .. mod_name] = true
         local loadFn, errmsg = load(bytecode, "@" .. mod_name)
         if loadFn then
            return loadFn
         else
             error(errmsg)
         end
      else
         return nil, ("unable to load: " .. mod_name)
      end
   end
end









if _Bridge.bootstrap_conn then
   table.insert(package.loaders, 1, loaderGen(_Bridge.bootstrap_conn))
end
if _Bridge.modules_conn then
   table.insert(package.loaders, 1, loaderGen(_Bridge.modules_conn))
end









end
