


















pack = table.pack
















require "table.clear"
require "table.new"
require "table.isempty"
require "table.isarray"
require "table.nkeys"















do
















local bridge = {}

-- using rawset here to express intention
rawset(_G, "_Bridge", bridge)










bridge.retcode = 0






bridge.bridge_modules = { }
bridge.loaded = { }
bridge.load_hashes = { }









bridge.is_tty = require "luv" . guess_handle(1) == 'tty'
















local home_dir = os.getenv "HOME"
local bridge_modules = os.getenv "BRIDGE_MODULES"
local bridge_home = os.getenv "BRIDGE_HOME"

   -- use BRIDGE_HOME if we have it
if not bridge_home then
   local xdg_data_home = os.getenv "XDG_DATA_HOME"
   if xdg_data_home then
      bridge_home = xdg_data_home .. "/bridge"
   else
      bridge_home = home_dir .. "/.local/share/bridge"
   end
end

if not bridge_modules then
   bridge_modules = bridge_home.. "/bridge.modules"
end

bridge.bridge_home = bridge_home
bridge.bridge_modules_home = bridge_modules





local ok, bridge_conn = pcall(sql.open, bridge_modules, "rw")
if ok then
   bridge.modules_conn = bridge_conn
else
   print "no bridge.modules"
end






















local base = nil





local No = newproxy()



local function _nil(state)
   if state == nil or
      state == true or
      state == false then
      return state
   elseif state == 1 then
      base = nil
      return 1
   else
      return No, "illegal transition nil -> " .. tostring(state)
   end
end










local function _true(state)
   if state == nil or
      state == true or
      state == false then
      return state
   elseif state == 1 then
      base = true
      return 1
   else
      return No, "illegal transition true -> " .. tostring(state)
   end
end








local function _false(state)
   if state == true or
      state == false then
      return state
   else
      return No, "illegal transition false -> " .. tostring(state)
   end
end























local function _integer(n, state)
   if state == 1 then
      return n + 1
   elseif state == - 1 then
      if n > 1 then
         return n - 1
      elseif n == 1 then
         return base
      else
         return No, "illegal n" .. tostring(n)
      end
   elseif state == true then
      base = true
      return n
   elseif state == nil then
      base = nil
      return n
   elseif state == false then
      return false
   else
      return No, "illegal transition integer<n> -> " .. tostring(n)
   end
end











package.preload.bridge = function() return bridge end






end

