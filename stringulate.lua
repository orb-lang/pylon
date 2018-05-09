-- Stringulation

--  May God,
--  If there is a God,
--  Have mercy on my soul,
--  If I have a soul.

local L = require "lpeg"

local file = io.open(arg[1])

local phrase = file:read("*a")

-- Fearfully anointing himself, he opened the crypt, intoning the
-- ancient evocation:

phrase = phrase:gsub("\\", "\\\\"):gsub("\"", "\\\""):gsub("\n","\\n")

io.write(phrase .. "\n")

-- ΑΠΟ ΠΑΝΤΟΣ ΚΑΚΟΔΑΙΜΟΝΟΣ!

-- one may not exit cleanly from such a deed.

os.exit(-666)