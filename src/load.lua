




























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

_Bridge.parse_version = parse_version




local brParse = require "argparse" ()

_Bridge.brParse = brParse

brParse
   : require_command (false)
   : name "br"
   : description ("An lua, howth castle & environs.\n\n"
               .. "To view help for each command, type br <command> -h.")
   : epilog "For more info, see https://special-circumstanc.es"
   : help_description_margin(25)
   : option "-f" "--file"
      : description "load and run a file. Lua only, for now"
      : args(1)

brParse
   : flag "--show-arguments"
      : description "display the args table. For development purposes."

local orb_c = brParse : command "orb o"
                         : description "Literate compiler for Orb format."

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

local grym_c = brParse : command "grym"
                       : description ("Backup compiler for Orb format.\n"
                                    .."Not intended for long-term use.")
local helm_c = brParse
                  : command "helm i"
                     : description "launch helm, the 'i'nteractive REPL."
                     : help_description_margin(35)

helm_c
   : option "-s --session"
      : description "Start the repl with a given, named session."
      : args(1)

helm_c
   : option "-n --new-session"
      : description "Begin a new, named session."
      : args(1)

local export_c = brParse
                    : command "export"
                    : description "Export a project from the database"

export_c
   : argument "project"
     : description "Project or projects to export"
     : args(1)

export_c
  : option "-o" "--outfile"
     : description ("A file to export projects to."
                 .. "Defaults to ./<project>.bundle")
     : args(1)

export_c
   : option "-v" "--version"
      : description "Version of the project to export"
      : convert(parse_version)
      : args(1)

local import_c = brParse
                    : command "import"
                    : description "import a project from a bundle file"

import_c
   : argument "file"
   : description "a bundled project file or files"
   : args "+"






end










collectgarbage()








if rawget(_G, "arg") ~= nil then
   -- shim the arg array to emulate the "lua <scriptname>" calling
   -- convention which argparse expects
   table.insert(arg, 0, "")
   _Bridge.args = _Bridge.brParse:parse()
   local args = _Bridge.args
   if args.show_arguments then
      args.show_arguments = nil -- no reason to include this
      local ts = require "helm:helm/repr".ts
      print(ts(args))
   end
   if args.file then
      if args.file:sub(-4, -1) == ".lua" then
         dofile(args.file)
      end
      -- handle .orb files here
   end
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
   elseif args.export then
      local bundle = require "bundle:export".export(args.project,
                                                    args.version)
      if args.outfile then
         local file = io.open(args.outfile, "w+")
         if not file then
            error("unable to open " .. args.outfile)
         end
         file:write(bundle)
         file:close()
      else
         local outfilepath = "./" .. args.project .. ".bundle"
         local file = io.open(outfilepath, "w+")
         if not file then
            error("unable to open " .. outfilepath)
         end
         file:write(bundle)
         file:close()
      end
   elseif args.import then
      local import = require "bundle:import"
      for _, file in ipairs(args.file) do
         import(file)
      end
   end
end
