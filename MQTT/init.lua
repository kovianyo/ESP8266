function checkAbort()
  local pin = 0 -- GPIO16, D0
  gpio.mode(pin, gpio.INPUT)
  if (gpio.read(pin) == 0) then
    print('aborting startup')
    return
  else
    print('(pull pin ' .. pin .. ' to ground to abort startup)\n')
    dofile('startup.lua')
  end
end

checkAbort()
