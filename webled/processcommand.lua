function processCommand(command)
  tmr.stop(LEDTIMER)
  pattern = nil
  HSL = nil
  collectgarbage()

  if command == "Red" then setallcolors(red)
  elseif command == "Green" then setallcolors(green)
  elseif command == "Blue" then setallcolors(blue)
  elseif command == "White" then setallcolors(white)
  elseif command == "Black" then setallcolors(black)
  elseif command == "Pattern2" then dofileifexists("pattern2.lua")
  elseif command == "Pattern3" then dofileifexists("pattern3.lua")
  elseif command == "Pattern4" then dofileifexists("pattern4.lua")
  elseif command == "Pattern5" then dofileifexists("pattern5.lua")
  elseif command == "Pattern7" then dofileifexists("pattern7.lua")
  else setallcolors(black) end
end

function setallcolors(color)
  local colors = color:rep(LEDCOUNT)
  writeColors(colors)
end
