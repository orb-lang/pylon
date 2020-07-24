# Use


`use` is our replacement for `require`\.

It starts life as [lua-procure](https://github.com/hoelzro/lua-procure), a
pure\-lua reimplementation of the existing `require`\.

We'll then modify it, thus:

- [ ]  \#Todo:

  - [ ]  Uniqueness in `require` is determined by the require string\.  This is
      not in keeping with how `bridge` loads programs, because we have
      several equivalent ways to load a module, e\.g\. "helm:repr",
      "helm/repr", "helm:helm/repr" all currently point to the same module,
      but Lua will interpret them as different\.  This has bitten me several
      times\.

      Since we store hashes, we can use those to deduplicate modules if
      they're fetched from the database\.

  - [ ]  `use` will behave like `require` when passed a string\.  If passed a
      table, the \[1\] position must be a require string, with the rest of
      the table key\-value pairs expressing constraints of the module\.

  - [ ]  Eventually, constraints for a project will normally be expressed in a
      manifest document in the root directory of the project\.  Making this
      work correctly will be somewhat tricky, and the logic to enable this
      will need to involve `use`\.

      We need some insight into which project something is being required
      from in order for these constraints to work\.


### Original License

Copyright \(c\) 2012 Rob Hoelz <rob@hoelz\.ro>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files \(the "Software"\), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software\.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT\. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE\.

```lua
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
```