











_Bridge = {}








do






_Bridge.bridge_modules = { }









local bytecode_by_module = [[
SELECT code.binary
FROM code
INNER JOIN module
ON module.code = code.code_id
WHERE module.name = :name
ORDER BY module.time desc limit 1
;
]]

local bytecode_by_module_and_project = [[
SELECT code.binary
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





local ok, bridge_conn = pcall(sql.open, bridge_modules, "rw")
if ok then
   _Bridge.modules_conn = bridge_conn
else
   print "no bridge.modules"
end











local bridge_strap = home_dir .. "/.local/share/bridge/~bridge.modules"
local ok, strap_conn = pcall(sql.open, bridge_strap, "rw")
if ok then
   _Bridge.bootstrap_conn = strap_conn
end







local function _unwrapOneResult(result)
   if result and result[1] and result[1][1] then
      return result[1][1]
   else
      return nil
   end
end

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
      local project, mod = string.match(mod_name, "(.*):(.*)")
      if not mod then
         mod = mod_name
      end
      local proj_name = project or ""
      -- might be "module/module":
      local mod_double = mod .. "/" .. mod
      -- might be "project:module" -> "project/module"
      local proj_double = ""
      if project then
         proj_double = project .. "/" .. mod
      end
      if project then
         -- retrieve bytecode by project and module
         bytecode = _unwrapOneResult(
                      project_stmt:bindkv ({ project_name = project,
                                            module_name  = mod })
                      : resultset())
         if not bytecode then
            -- try mod_double
            project_stmt:reset()
            bytecode = _unwrapOneResult(
                      project_stmt:bindkv ({ project_name = project,
                                            module_name  = mod_double })
                      : resultset())
         end
         if not bytecode then
            -- try proj_double
            project_stmt:reset()
            bytecode = _unwrapOneResult(
                      project_stmt:bindkv ({ project_name = project,
                                             module_name  = proj_double })
                      : resultset())
         end
         project_stmt:reset()
      else
         -- retrieve by bare module name
         bytecode = _unwrapOneResult(
                      module_stmt:bindkv ({ name  = mod })
                      : resultset())
         if not bytecode then
            module_stmt:reset()
            bytecode =_unwrapOneResult(
                      module_stmt:bindkv ({ name  = mod })

                      : resultset())
         end
         module_stmt:reset()
      end
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
   table.insert(package.loaders, 2, loaderGen(_Bridge.bootstrap_conn))
end
if _Bridge.modules_conn then
   table.insert(package.loaders, 2, loaderGen(_Bridge.modules_conn))
end









end
