# Afterward


Performs cleanup\.


### get bridge

```lua
local bridge = require "bridge"
```


### Close status

We only need to do this if we've loaded status in the first place\.

Which, we usually have, but no reason to `require` it if we haven't\.

```lua
if bridge.status_on then
   S = require "status:status"
   -- this is defensive behavior
   if S and type(S) == 'table' then
      S():close()
   end
end
```

### Close bridge\.modules\_conn


```lua
if bridge.modules_conn then
   bridge.modules_conn:pclose()

end
```



### Return code

```lua
os.exit(bridge.retcode)
```
