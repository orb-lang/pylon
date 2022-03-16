# Afterward


Performs cleanup\.


### get bridge

In the near future we'll remove \_Bridge from the global environment, and we'll
do it in load, so we'll need to get it back\.

```lua
local bridge = require "bridge"
```

### Close bridge\.modules\_conn

```lua
if bridge.modules_conn then
   bridge.modules_conn:pclose()
end
```


### Close status

We only need to do this if we've loaded status in the first place\.

Which, we usually have, but no reason to `require` it if we haven't\.

```lua
if bridge.status_on then
   require "status:status" :close()
end
```


### Return code

```lua
os.exit(bridge.retcode)
```
