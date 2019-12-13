












-- local utf8 = require "lua-utf8"
-- assert(utf8, "no utf8")





















do




stricture(nil,_G,{_PROMPT=true,__global=true})
stricture = nil
















local L = require "lpeg"
local P, C, Cg, Ct, R, match = L.P, L.C, L.Cg, L.Ct, L.R, L.match
local format = assert(string.format)
local MAX_INT = 9007199254740991

local function cast_to_int(str_val)
   local num = tonumber(str_val)
   if num > MAX_INT then
      error ("version numbers cannot exceed 2^53 - 1, "
             .. str_val .. " is invalid")
   end
   return num
end

local function parse_version(str)
   local major  = Cg(R"09"^1, "major")
   local minor  = Cg(R"09"^1, "minor")
   local patch  = Cg(R"09"^1, "patch")
   local kelvin = P"[" * Cg(R"09"^1, "kelvin") * P"]"
   local knuth  = Cg(R"09"^1, "knuth") * P".."
   local patt = Ct(major
                  * (P"." * minor)
                  * (P"." * (kelvin + knuth + patch) + P(-1)))
                  * P(-1)
   local ver = match(patt, str)
   if not ver then
      if match(R"09"^1 * P"."^-1 * P(-1), str) then
         error("Must provide at least major and minor version numbers")
      else
         error("invalid --version format: " .. str)
      end
   end
   -- Cast to number
   for k,v in pairs(ver) do
      ver[k] = cast_to_int(v)
   end
   -- make alternate patch forms into flags
   if ver.kelvin then
      ver.patch = ver.kelvin
      ver.kelvin = true
   elseif ver.knuth then
      ver.patch = ver.knuth
      ver.knuth = true
   end

   return ver
end





_Bridge.brParse = require "argparse" ()
local brParse = _Bridge.brParse

brParse
   : require_command (false)
   : name "br"
   : description ("An lua, howth castle & environs.\n\n"
               .. "To view help for each command, type br <command> -h.")
   : epilog "For more info, see https://special-circumstanc.es"
   : help_description_margin(35)

local orb_c = brParse : command ("orb o")
                      : description "Literate compiler for Orb format."

local grym_c = brParse : command "grym"
                       : description ("Backup compiler for Orb format.\n"
                                    .."Not intended for long-term use.")
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
   : help_vertical_space(1)

orb_command_c
  : option "-v --version"
    : description "A (semantic) version string."
    : convert(parse_version)
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

orb_c
   : command "revert"
   : description "Revert the latest compiled changes in project."
   : option "-p --project"
     : description "Project to revert."
     : args(1)

helm_c
   : option "-s --session"
     : description "Start the repl with a given, named session."
     : args(1)

helm_c
   : option "-n --new-session"
     : description "Begin a new, named session."
     : args(1)






end










collectgarbage()








if rawget(_G, "arg") ~= nil then
   local ts = require "helm:helm/repr".ts
   table.insert(arg, 0, "")
   _Bridge.args = _Bridge.brParse:parse()
   local args = _Bridge.args
   print(ts(args))
   if args.orb then
     if args.revert then
        local revert = require "bundle:revert"
        revert()
     else
        local orb = require "orb"
        local uv = require "luv"
        orb.run(uv.cwd())
     end
   elseif args.grym == true then
      local grym = require "grym:orb"
      local uv = require "luv"
      grym.run(uv.cwd())
   elseif args.helm then
      print "helm"
      local helm = require "helm:helm"
      setfenv(0, __G)
      helm(__G)
      setfenv(0, _G)
   end
end
