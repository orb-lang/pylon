











local bridge = require "bridge"





if bridge.modules_conn then
   bridge.modules_conn:pclose()

end










if bridge.status_on then
   require "status:status" :close()
end






os.exit(bridge.retcode)

