x = true
gpio.mode(4, gpio.OUTPUT)
gpio.write(4, gpio.LOW)


function set()
  local level = gpio.LOW

  if x then level = gpio.HIGH
  else level = gpio.LOW
  end

  x = not x
  gpio.write(4, level)
  tmr.alarm(0, 1000, 0, set)
end

set()
