-- make ist fast :)
--uart.setup(0,115200,8,0,1,1,PERMANENT)
-- mcp starts here
mcp = require("mcp23017")
mcp.init(2,3)
mcp.setUpPin(9,1,1)
-- set pin to input and pullup
print('Okay')
function showButtons()
  -- negate the output
  local state = mcp.getPin(9)
  mcp.setPin(1,state)
  collectgarbage()
  tmr.wdclr()
end
tmr.alarm(0,150,1,showButtons) -- run showButtons() every 2 seconds
