








local bridge = require "bridge"





if bridge.modules_conn then
   bridge.modules_conn:pclose()

end










if bridge.status_on then
   S = require "status:status"
   -- this is defensive behavior
   if S and type(S) == 'table' then
      S():close()
   end
end






os.exit(bridge.retcode)

