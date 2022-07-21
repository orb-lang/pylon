


























do



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







assert(require "bridge" . bridge_home)








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












assert(_Bridge.modules_conn, "missing bridge modules conn!")
table.insert(package.loaders, 2, loaderGen(_Bridge.modules_conn))








end
















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

