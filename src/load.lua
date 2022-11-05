





















do






local bridge = require "bridge"



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
      return nil, "Version numbers cannot exceed 2^53 - 1, "
             .. str_val .. " is invalid"
   end
   return num
end

local function parse_version(str)
   local major  = Cg(R"09"^1, "major")
   local minor  = Cg(R"09"^1, "minor")
   local patch  = Cg(R"09"^1, "patch")
   local kelvin = P"[" * Cg(R"09"^1, "kelvin") * P"]"
   local knuth  = Cg(R"09"^1, "knuth") * P".."
   local patt = Ct( major
                  * (P"." * minor)
                  * (P"." * (kelvin + knuth + patch) + P(-1)) )
                  * P(-1)
   local ver = match(patt, str)
   if not ver then
      if match(R"09"^1 * P"."^-1 * P(-1), str) then
         return nil, "Must provide at least major and minor version numbers"
      else
         return nil, "Invalid --version format: " .. str
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

bridge.parse_version = parse_version











local function dataload(lua_tab)
   local f, err = loadstring("return " .. lua_tab)
   if not f then
      return f, err
   end
   setfenv(f, {})
   local ok, maybe_tab = pcall(f)
   if not ok then
      return ok, maybe_tab
   elseif type(maybe_tab) == 'table' then
      return maybe_tab
   else
      return nil, "bad lua data of type " .. type(maybe_tab)
   end
end












local function open_range_fn(open)
   return { tonumber(open:sub(1, -3)), "#" }
end

local num = C(R"09"^1) / tonumber
local range = Ct((num * ".." * num))
local open_range = C(num * "..") / open_range_fn
local entry = range + num

local list_p = Ct(P"[" * (P" "^0 * (range + num) * P" "^0 * P",")^0
               * (P" "^0 * (range + open_range + num) * P" "^0)^-1 * P"]")

local function parse_list(str)
   local list = match(list_p, str)
   if not list then
      list = tonumber(str)
      if list then return list end
      return str
   end

   return list
end

bridge.parse_list = parse_list













local function parse_session_identifier(name)
   return name:find("^%s*%d+%s*$") and tonumber(name) or name
end

local function validate_session_name(name)
   -- check if the string is only integers with possible whitespace padding
   if name:find("^%s*%d+%s*$") then
      return nil, "Can't give a session an integer name such as " .. name .. "."
   end
   return name
end







local floor = assert(math.floor)

local function isint(arg)
   local num = tonumber(arg)
   if num then
      return floor(num)
   else
      return nil, arg .. " isn't a number from Lua's perspective."
   end
end







local brParse = require "argparse" ()

bridge.brParse = brParse

brParse
   : require_command (false)
   : name "br"
   : description ("The bridge tools suite for repl-driven "
                  .. "literate programming.\n\n"
                  .. "To view help for each command, type br <command> -h.")
   : epilog ("To run user-installed projects, type br <project> with "
             .. "any arguments.\n\n"
             .. "For more info, see https://special-circumstanc.es")
   : command_target "verb"
   : help_description_margin(25)
   : help_max_width(80)

brParse
   : option "-f" "--file"
      : description "Run a file. Lua only, for now."
      : args(1)
      : overwrite(false)

brParse : flag "--no-jit" : description "Turn off the JIT."


brParse
   : flag "--show-args"
      : description "Display the args table. For development purposes."

brParse
   : option "--inject-args"
   : description ("Take a valid Lua table and add the contents to the parsed"
              .. " arguments. Will print results as above.")
   : convert(dataload)
   : args(1)
   : overwrite(false)

brParse
  : flag "-v --verbose"
    : description "Verbose output (vv for very verbose)."
    : count "0-2"

brParse
  : flag "-t --terse"
  : description "Terse output."






local orb_c = brParse : command "orb o"
                         : description "Literate compiler for Orb format."

orb_c
   : require_command (false)

orb_c
  : flag "-P --pedantic"
    : description "Perform all filters, linting, crash on errors, etc."

orb_c
   : command "serve"
      : description "Launch the Orb server."

orb_c
   : command "revert"
   : description "Revert the latest compiled changes in project."
   : option "-p --project"
      : description "Project to revert."
      : args(1)

orb_c
   : command "scry"
   : description "Performs analysis on knit Lua documents. Experimental!"






local helm_c = brParse
                  : command "helm i"
                     : description "Launch helm, the 'i'nteractive REPL."
                     : help_description_margin(35)

helm_c
   : option "-s --session"
      : description "Start the repl with a given, named session."
      : convert(parse_session_identifier)
      : args(1)

helm_c
   : option "-n --new-session"
      : description "Begin a new, named session."
      : convert(validate_session_name)
      : args(1)

helm_c
   : flag "-r --restart"
   : description "Restart helm and execute all lines from the last run."

helm_c
   : flag "-R --run"
   : description "Edit the last run then restart."

helm_c
   : option "-b --back"
   : description "Replay the last <number> lines."
   : convert(isint)
   : args(1)

helm_c
   : flag "-l --listen"
   : description ( "Open with a listener, which compiles files on save and "
                .. "restarts the session." )






local export_c = brParse
                    : command "export"
                    : description "Export a project from the database."

export_c
   : argument "project"
     : description "Project or projects to export"
     : args "?"

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

export_c
   : flag "-a" "--all"
      : description ( "Export all projects."
                   .. "Latest bundles if no version is specified." )


local import_c = brParse
                    : command "import"
                    : description "Import a project from a bundle file."

import_c
   : argument "file"
   : description "a bundled project file or files"
   : args "+"






local session_c = brParse
                    : command "session s"
                    : description ("Session runner. Provides unit tests"
                        .. " derived from helm sessions. With no arguments,"
                        .. " runs all accepted sessions for the project"
                        .. " at pwd.")
                    : require_command(false)

session_c
   : flag "--all"
   : description("Run all accepted sessions in the database,"
                 .. " for every project.")

session_c
   : flag "--total"
   : description("Run every session in the database, no exceptions.")

session_c
   : flag "-E" "--every"
   : description "Run every session for a given project."

session_c
   : option "-s" "--some"
   : description "Run only the indicated sessions, by name, number, or list."
   : convert(parse_list)
   : args(1)

session_c
   : flag "-S" "--show-results"
   : description "Print all results for premises."

local session_list_c = session_c
                          : command "list l"
                          : description ("List (accepted) sessions. "
                             .. "Defaults to current project.")

session_list_c
    : option "-l --latest"
    : description "List the n most recent accepted sessions, default 5."
    : args "?"
    : argname "<n>"

session_list_c
    : flag "-a --all"
    : description "List all sessions including deprecated sessions."
    : action(function(args) args.list_all = true end)

local function add_range_arg(cmd, arg_name)
   cmd
      : argument(arg_name)
      : description ("A session title, session number, or list of session "
         .. "numbers/ranges e.g. [1,3,5..6,8..].")
      : convert(parse_list)
      : args(1)
end

local session_update_c = session_c
         : command "update u"
         : description ("Update session(s) premises to accept latest "
                        .. "results.")
add_range_arg(session_update_c, "to_update")

local session_delete_c = session_c
         : command "delete d"
         : description ("Delete listed sessions. "
                     .. "Will only delete a deprecated session.")
add_range_arg(session_delete_c, "to_delete")

local session_force_delete_c = session_c
                                  : command "force-delete D"
                                  : description
                                     ("Delete listed sessions, including "
                                      .. "accepted sessions.")
add_range_arg(session_force_delete_c, "to_delete")

local session_accept_c = session_c
         : command "accept a"
         : description "Mark a session or list as accepted."
add_range_arg(session_accept_c, "to_accept")

local session_deprecate_c = session_c
         : command "deprecate p"
         : description("dePrecate a session, or list of sessions, which will "
                     .."no longer be run with `br session`.")
add_range_arg(session_deprecate_c, "to_deprecate")

local session_rename_c = session_c
         : command "rename r"
         : description "Give a session a new title."

session_rename_c
  : argument "old_name"
  : description "The title or number of an existing session to rename."
  : convert(parse_session_identifier)

session_rename_c
  : argument "new_name"
  : description "The new title for the session."
  : convert(validate_session_name)

local session_export_c = session_c
         : command "export e"
         : description "Export a session or list of sessions."
add_range_arg(session_export_c, "to_export")

session_export_c
   : option "-o" "--outfile"
   : description "A file path. Defaults to stdout if not provided."
   : args(1)

local session_import_c = session_c
         : command "import i"
         : description ("Import sessions from a bundle file, into the project "
                     .. "named in the bundle.")

session_import_c
   : argument "infile"
   : description "A session bundle file. Defaults to stdin if not provided."
   : args "?"






local codex_c = brParse
                   : command "codex c"
                   : description "Tools for working with a codex."

local codex_freeze_c = codex_c
   : command "freeze f"
   : description "Freeze the verb. Pins dependencies, loads faster."

codex_freeze_c
   : argument "verb"
   : name "module-name"
   : args(1)

codex_freeze_c
   : option "-m" "--module"
   : description "Use if the module string isn't \"verb:verb\"."
   : args(1)

local codex_thaw_c = codex_c
   : command "thaw t"
   : description "Thaws a verb.  Will load latest modules individually."

codex_thaw_c
   : argument "verb"
   : name "module-name"
   : args(1)

local codex_activate_c = codex_c
   : command "activate a"
   : description "Activate the last frozen version of the verb."

codex_activate_c
   : argument "verb"
   : name "module-name"
   : args(1)






end










collectgarbage()
























local uv  = require "luv"

local verbs = { s = true, o = true, i = true, c = true}

function verbs.orb(args)
   if args.revert then
      local revert = require "bundle:revert"
      revert()
   else
       local orb = require "orb"
       local lume = orb.lume(uv.cwd())
       lume:run()
       if args.serve then
          lume:serve()
       end
   end
end

function verbs.session(args)
   local session = assert(require "valiant:session" . session)
   session(args)
end

function verbs.helm(args)
   bridge.helm = true
   local helm = require "helm:helm"
   helm()
end

function verbs.export(args)
   if (not args.project) and (not args.all) then
      error "at least one project required without --all flag"
   end
   local bundle
   if not args.all then
      bundle = require "bundle:export".export(args.project,
                                                 args.version)
   else
      bundle = require "bundle:export".exportAll(args.version)
   end
   if args.outfile then
      local file = io.open(args.outfile, "w+")
      if not file then
         error("unable to open " .. args.outfile)
      end
      file:write(bundle)
      file:close()
   else
      local bundle_name = args.project or "all_modules"
      local outfilepath = "./" .. bundle_name .. ".bundle"
      local file = io.open(outfilepath, "w+")
      if not file then
         error("unable to open " .. outfilepath)
      end
      file:write(bundle)
      file:close()
   end
end


local import = assert(bridge.import)

function verbs.import(args)
   for _, file in ipairs(args.file) do
      import(file)
   end
end








local thaw_voltron = [[
UPDATE voltron SET active = 0 WHERE name = :name;
]]

local activate_voltron = [[
UPDATE voltron SET active = 1 WHERE name = :name;
]]

local get_voltron = [[
SELECT voltron FROM voltron WHERE name = :name
ORDER BY TIME DESC LIMIT 1;
]]

local count_voltron = [[
SELECT count(voltron) FROM voltron WHERE name = :name;
]]


function verbs.codex(args)
   local mod = args['module-name']
   if args.freeze then
      print("Assembling modules of " .. args.verb)
      local voltron = require "voltron:voltron"
      voltron(mod, args.module):voltron()
      print "ok"
   elseif args.thaw then
      local count = bridge.modules_conn
          :prepare(count_voltron) :bind(mod) :value()
      if count < 1 then
         print("No frozen " .. mod .. " to thaw")
      else
         bridge.modules_conn
             :prepare(thaw_voltron) :bind(mod) :value()
         print "ok"
      end
   elseif args.activate then
      local count = bridge.modules_conn
          :prepare(count_voltron) :bind(mod) :value()
      if count < 1 then
         print("No frozen " .. mod .. " to activate")
      else
         bridge.modules_conn
            :prepare(activate_voltron) :bind(mod) :value()
         print "ok"
      end
   end
end











if rawget(_G, "arg") ~= nil then
   -- shim the arg array to emulate the "lua <scriptname>" calling
   -- convention which argparse expects
   table.insert(arg, 0, "")

   -- check for custom command
   local first_verb, lead_char = nil, string.sub(arg[1], 1, 1)
   first_verb = lead_char ~= '-' and arg[1] or nil

   if first_verb and not(verbs[first_verb]) then
      -- needs a rewrite
      -- annoying, because "arg" is magic in argparse
      -- so:
      -- first get everything after the verb out of arg
      -- allow brParse code to run
      -- if we have a first_verb, then at the end of the
      -- decision tree, replace the contents of arg with
      -- the saved contents from before
      -- summon custom arg parse if it exists, call it
      -- run custom project, again, if it exists
      -- question our life choices
      local verb, args = table.remove(arg, 1), nil
      local ok, argP = pcall(require, verb .. ":argparse")
      if ok then
         args = argP:parse()
      end
      local ok, mod = pcall(require, verb .. ":" .. verb)
      if ok then
         mod(args)
      else
         print("Can't find a project " .. first_verb .. ".")
      end
   else
      bridge.args = bridge.brParse:parse()
      local args = bridge.args

      -- no JIT? kill it and make it stay dead, like this:
      if args.no_jit then
         local jit = require "jit"
         -- kill it
         jit.off()
         -- so it /stays dead/
         jit.on = function() end
      end

      -- inject any arguments
      if args.inject_args then
         local inject = args.inject_args
         args.inject_args = nil
         for k, v in pairs(inject) do
            args[k] = v
         end
      end

      -- show arguments if so requested
      if args.show_args then
         args.show_args = nil -- no reason to include this
         local ts = require "repr:repr" . ts
         print(ts(args))
      end

      -- check for and dispatch verbosity flags
      if args.terse or (args.verbose > 0) then
         local S = require "status:status"
         if args.verbose == 1 then
            S.Verbose = true
         elseif args.verbose == 2 then
            S.Boring = true
         elseif args.terse then
            S.Chatty = false
            S.Verbose = false
         end
      end

      -- load bridge verbs
      if verbs[args.verb] then
         if bridge.volts[args.verb] then
            local voltstr = bridge.modules_conn :prepare(get_voltron)
                              :bind(args.verb) :value()
            local voltload = require "voltron:load"
            voltload(voltstr)
         end
         verbs[args.verb](args)
      elseif args.file then
         if args.file:sub(-4, -1) == ".lua" then
            dofile(args.file)
         end
         -- #todo handle .orb files here
      else
         -- no further arguments, just exit
      end
   end
   :: bottom ::
end








if uv.loop_alive() and (not uv.loop_mode()) then
   uv.run 'default'
end







end

