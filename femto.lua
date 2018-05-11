-- Femto

local femto = assert(femto)

femto.enableRawMode()
femto.initFm()

femto.fmSetStatusMessage("HELP: Ctrl-S = save | Ctrl-Q = quit | Ctrl-F = find")

local key = 0

while true do
   femto.fmRefreshScreen()
   key = femto.fmReadKey()
   femto.fmProcessKeypress(key)
end

return 0