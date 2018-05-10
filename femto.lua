-- femto main loop

-- derived from this C code:

--[[
int main(int argc, char *argv[]) {
  enableRawMode();
  initFm();
  if (argc >= 2) {
    fmOpen(argv[1]);
  }

  fmSetStatusMessage("HELP: Ctrl-S = save | Ctrl-Q = quit | Ctrl-F = find");

  while (1) {
    fmRefreshScreen();
    fmProcessKeypress();
  }

  return 0;
}
--]]

-- This presumes `femto` is loaded into the global namespace.

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