sql = require "src/sqlite"

ffi = require "ffi"

conn = sql.open("")

conn:exec[[
CREATE TABLE t(id TEXT, num REAL);
INSERT INTO t VALUES('myid1', 200);
]]

-- Prepared statements are supported:
local stmt = conn:prepare("INSERT INTO t VALUES(?, ?)")
for i=2,4 do
  stmt:reset():bind('myid'..i, 200*i):step()
end

-- Command-line shell feature which here prints all records:
conn "SELECT * FROM t"


print "hello"

for k, v in pairs(ffi.C) do
   io.write(k .. " " .. tostring(v) .. "\n")
end