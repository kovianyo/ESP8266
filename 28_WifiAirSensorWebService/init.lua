local checkAbort = function()
  local pin = 0 -- GPIO16, D0
  local pinDescription = 'pin 0 (GPIO16, D0)'
  gpio.mode(pin, gpio.INPUT)
  print()
  if (gpio.read(pin) == 0) then
    print('Startup aborted (' .. pinDescription .. ' is low).')
    return
  else
    local nextLuaFileName = 'startup.lua'
    print('Starting up... (pull ' .. pinDescription .. ' to ground to abort startup)')
    print()
    if (file.exists(nextLuaFileName)) then
      node.task.post(function() dofile(nextLuaFileName) end)
    else
      print(nextLuaFileName + ' does not exist')
    end
  end
end

checkAbort()
