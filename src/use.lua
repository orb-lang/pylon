

























































local sformat      = string.format
local sgmatch      = string.gmatch
local sgsub        = string.gsub
local smatch       = string.match
local tconcat      = table.concat
local tinsert      = table.insert
local setmetatable = setmetatable
local ploadlib     = package.loadlib

local meta = {}
local _M   = setmetatable({}, meta)

_M.VERSION = '0.01'

local function preload_loader(name)
  if package.preload[name] then
    return package.preload[name]
  else
    return sformat("no field package.preload['%s']\n", name)
  end
end

local function path_loader(name, paths, loader_func)
  local errors = {}
  local loader

  name = sgsub(name, '%.', '/')

  for path in sgmatch(paths, '[^;]+') do
    path = sgsub(path, '%?', name)

    local errmsg

    loader, errmsg = loader_func(path)

    if loader then
      break
    else
      -- XXX error for when file isn't readable?
      -- XXX error for when file isn't valid Lua (or loadable?)
      tinsert(errors, sformat("no file '%s'", path))
    end
  end

  if loader then
    return loader
  else
    return tconcat(errors, '\n') .. '\n'
  end
end

local function lua_loader(name)
  return path_loader(name, package.path, loadfile)
end

local function get_init_function_name(name)
  name = sgsub(name, '^.*%-', '', 1)
  name = sgsub(name, '%.', '_')

  return 'luaopen_' .. name
end

local function c_loader(name)
  local init_func_name = get_init_function_name(name)

  return path_loader(name, package.cpath, function(path)
    return ploadlib(path, init_func_name)
  end)
end

local function all_in_one_loader(name)
  local init_func_name = get_init_function_name(name)
  local base_name      = smatch(name, '^[^.]+')

  return path_loader(base_name, package.cpath, function(path)
    return ploadlib(path, init_func_name)
  end)
end

local function findchunk(name)
  local errors = { string.format("module '%s' not found\n", name) }
  local found

  for _, loader in ipairs(_M.loaders) do
    local chunk = loader(name)

    if type(chunk) == 'function' then
      return chunk
    elseif type(chunk) == 'string' then
      errors[#errors + 1] = chunk
    end
  end

  return nil, table.concat(errors, '')
end

local function require(name)
  if package.loaded[name] == nil then
    getfenv(1).
    local chunk, errors = findchunk(name)

    if not chunk then
      error(errors, 2)
    end

    local result = chunk(name)

    if result ~= nil then
      package.loaded[name] = result
    elseif package.loaded[name] == nil then
      package.loaded[name] = true
    end
  end

  return package.loaded[name]
end

local loadermeta = {}

function loadermeta:__call(...)
  return self.impl(...)
end

local function makeloader(loader_func, name)
  return setmetatable({ impl = loader_func, name = name }, loadermeta)
end

-- XXX make sure that any added loaders are preserved (esp. luarocks)
_M.loaders = {
  makeloader(preload_loader, 'preload'),
  makeloader(lua_loader, 'lua'),
  makeloader(c_loader, 'c'),
  makeloader(all_in_one_loader, 'all_in_one'),
}

if package.loaded['luarocks.require'] then
  local luarocks_loader = require('luarocks.require').luarocks_loader

  table.insert(_M.loaders, 1, makeloader(luarocks_loader, 'luarocks'))
end

-- XXX sugar for adding/removing loaders

function meta:__call(name)
  return require(name)
end

_M.findchunk = findchunk

return _M

