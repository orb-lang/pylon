












-- local utf8 = require "lua-utf8"
-- assert(utf8, "no utf8")





















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
end










collectgarbage()









rawset(_G, "brParse", package.argparse())

brParse
   : require_command (false)
   : name "bridge"
   : description "An lua, howth castle & environs."
   : epilog "For more info, see https://special-circumstanc.es"

local orb_c = brParse : command ("orb o")
                      : description "Literate compiler for Orb format."

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

orb_command_c
  : option "-v --version"
    : description "A (semantic) version string."
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

helm_c
   : option "-s --session"
     : description "Start the repl with a given, named session."
     : args(1)

helm_c
   : option "-n --new-session"
     : description "Begin a new, named session."
     : args(1)








if rawget(_G, "arg") ~= nil then
   table.insert(arg, 0, "")
   _Bridge.args = brParse:parse()
   if _Bridge.args["orb"] == true then
     print "orb"
     local orb = require "orb"
     local uv = require "luv"
     orb.run(uv.cwd())
   elseif _Bridge.args["helm"] == true then
      print "helm"
      local helm = require "helm:helm"
      setfenv(0, __G)
      helm(__G)
      setfenv(0, _G)
   end
end
