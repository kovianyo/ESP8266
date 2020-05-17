local checkAbort = function()
  local pin = 0 -- GPIO16, D0
  gpio.mode(pin, gpio.INPUT)
  print()
  if (gpio.read(pin) == 0) then
    print('Startup aborted (pin 0 (GPIO16, D0) is low).')
    return
  else
    print('Starting up... (pull pin 0 (GPIO16, D0) to ground to abort startup)')
    print()
    if (file.exists('startup.lua')) then
      node.task.post(function() dofile('startup.lua') end)
    else
      print('startup.lua does not exist')
    end
  end
end

checkAbort()
