--  *  Femto
--
--  **  includes


local sql = require "sqlite"


local lfs = require "lfs"
local ffi = require "ffi"

local femto = assert(femto)

local uv = require "luv"

local L = require "lpeg"

--  **** utils
--
--  Copypasta from luvland from here down

local usecolors
local stdout

if uv.guess_handle(1) == "tty" then
  stdout = uv.new_tty(1, false)
  usecolors = true
else
  utils.stdout = uv.new_pipe(false)
  uv.pipe_open(utils.stdout, 1)
  usecolors = false
end

-- Print replacement that goes through libuv.  This is useful on windows
-- to use libuv's code to translate ansi escape codes to windows API calls.
local function print(...)
  local n = select('#', ...)
  local arguments = {...}
  for i = 1, n do
    arguments[i] = tostring(arguments[i])
  end
  uv.write(utils.stdout, table.concat(arguments, "\t") .. "\n")
end


--  *** tty setup

if uv.guess_handle(0) ~= "tty" or
   uv.guess_handle(1) ~= "tty" then
  -- Entry point for other consumers!
  error "stdio must be a tty"
end

local stdin = uv.new_tty(0, true)

local debug = require('debug')

-- **** colorizer

-- This will be the first thing to go

local colors = {
  black   = "0;30",
  red     = "0;31",
  green   = "0;32",
  yellow  = "0;33",
  blue    = "0;34",
  magenta = "0;35",
  cyan    = "0;36",
  white   = "0;37",
  B        = "1;",
  Bblack   = "1;30",
  Bred     = "1;31",
  Bgreen   = "1;32",
  Byellow  = "1;33",
  Bblue    = "1;34",
  Bmagenta = "1;35",
  Bcyan    = "1;36",
  Bwhite   = "1;37"
}

local function color(color_name)
  if usecolors then
    return "\27[" .. (colors[color_name] or "0") .. "m"
  else
    return ""
  end
end

local c = color


--  *** utilities

local function gatherResults(success, ...)
  local n = select('#', ...)
  return success, { n = n, ... }
end

local function printResults(results)
  for i = 1, results.n do
    results[i] = utils.dump(results[i])
  end
  print(table.concat(results, '\t'))
end

local buffer = ''

local function evaluateLine(line)
  if line == "<3\n" then
    print("I " .. c("Bred") .. "♥" .. c() .. " you too!")
    return '>'
  end
  local chunk  = buffer .. line
  local f, err = loadstring('return ' .. chunk, 'REPL') -- first we prefix return

  if not f then
    f, err = loadstring(chunk, 'REPL') -- try again without return
  end

  if f then
    buffer = ''
    local success, results = gatherResults(xpcall(f, debug.traceback))

    if success then
      -- successful call
      if results.n > 0 then
        printResults(results)
      end
    else
      -- error
      print(results[1])
    end
  else

    if err:match "'<eof>'$" then
      -- Lua expects some more input; stow it away for next time
      buffer = chunk .. '\n'
      return '>>'
    else
      print(err)
      buffer = ''
    end
  end

  return '>'
end

local function displayPrompt(prompt)
  uv.write(stdout, prompt .. ' ')
end

local function onread(err, line)
  if err then error(err) end
  if line then
    local prompt = evaluateLine(line)
    displayPrompt(prompt)
  else
    uv.close(stdin)
  end
end

coroutine.wrap(function()
  displayPrompt '>'
  uv.read_start(stdin, onread)
end)()

uv.run()

print("\nkthxbye")
return 0