















-- local utf8 = require "lua-utf8"
-- assert(utf8, "no utf8")







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

-- So `strict.make_all_strict(_G)` prevents monkey-patching
-- of any global table
-- @tab T
local function make_all_strict (T)
    for k,v in pairs(T) do
        if type(v) == 'table' and v ~= T then
            stricture(k,v)
        end
    end
end

stricture(nil,_G,{_PROMPT=true,__global=true})
-- make_all_strict(_G)




if string.sub(arg[0], -4) == ".lua" then
    loadfile(arg[0])()
elseif string.sub(arg[0], -4) == ".raw" then
   loadfile(arg[0])()
else
   loadfile(arg[0] .. ".lua")()
end
