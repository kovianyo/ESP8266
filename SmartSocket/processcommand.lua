x = true
gpio.mode(4, gpio.OUTPUT)
gpio.write(4, gpio.LOW)

function processCommand(command)
  local level = gpio.LOW

  if x then level = gpio.HIGH
  else level = gpio.LOW
  end

  if command == "On" then level = gpio.HIGH
  elseif command == "Off" then level = gpio.LOW
  else level = gpio.LOW end

  gpio.write(4, level)
end
