ffi = require "ffi"

conn = sql.open "/Users/atman/.local/share/bridge/helm/helm.sqlite"

uv = require "luv"

local idler, yeller = uv.new_idle(), uv.new_idle()

yeller:start(function()
   print "YELLING"
end)

local first = true
idler:start(function()
   local thread = coroutine.create(function()
      local stmt = conn:prepare "select * from input"
      print "stmt prepared"
      ffi.C.sleep(3)
      print "stepping prepared statement"
      for i = 1, 1000 do
         stmt:step()
      end
      print "test concluded"
      idler:stop()
      yeller:stop()
   end)
   if first then
      first = false
      coroutine.resume(thread)
   end
end)


uv.run 'default'


