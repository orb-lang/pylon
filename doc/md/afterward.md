# Afterward

Performs cleanup\.

### Close \_Bridge\.modules\_conn

```lua
if _Bridge.modules_conn then
   _Bridge.modules_conn:pclose()
end

if _Bridge.bootstrap_conn then
   _Bridge.bootstrap_conn:pclose()
end
```


### Close status

We only need to do this if we've loaded status in the first place\.

Which, we usually have, but no reason to `require` it if we haven't\.

```lua
if _Bridge.status_on then
   require "status:status" :close()
end
```

