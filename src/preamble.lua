











_Bridge = {}








do






_Bridge.bridge_modules = { }









local bytecode_by_module = [[
SELECT code.binary
FROM code
INNER JOIN module
ON module.code = code.code_id
WHERE module.name = %s
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
WHERE project.name = %s
AND module.name = %s
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







local function _unwrapOneResult(result)
   if result and result[1] and result[1][1] then
      return result[1][1]
   else
      return nil
   end
end

local function loaderGen(conn)
   return function (mod_name)
      if not conn then error("sql connection failed") end
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
      local code_id = nil
      if project then
         -- retrieve bytecode by project and module
         bytecode = _unwrapOneResult(
                           conn:exec(
                           sql.format(bytecode_by_module_and_project,
                                      project, mod)))
         if not bytecode then
            -- try mod_double
            bytecode = _unwrapOneResult(
                            conn:exec(
                            sql.format(bytecode_by_module_and_project,
                                      project, mod_double)))
         end
         if not bytecode then
            -- try proj_double
            code_id = _unwrapOneResult(
                            conn:exec(
                            sql.format(bytecode_by_module_and_project,
                                      project, proj_double)))
         end
      else
         -- retrieve by bare module name
         bytecode = _unwrapOneResult(
                                 conn:exec(
                                 sql.format(bytecode_by_module,
                                            mod)))
         if not bytecode then
            bytecode = _unwrapOneResult(
                                 conn:exec(
                                 sql.format(bytecode_by_module,
                                            mod_double)))
         end
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
   table.insert(package.loaders, 1, loaderGen(_Bridge.bootstrap_conn))
end
if _Bridge.modules_conn then
   table.insert(package.loaders, 1, loaderGen(_Bridge.modules_conn))
end









end
