SWITCHPIN = 4

state = false
gpio.mode(SWITCHPIN, gpio.OUTPUT)
gpio.write(SWITCHPIN, gpio.LOW)

function processCommand(command)

  if command == "on" then state = true
  elseif command == "off" then state = false
  else state = false end

  setLevel(state)
end

function setLevel(state)
  local level = gpio.LOW

  if not state then level = gpio.HIGH
  else level = gpio.LOW
  end

  gpio.write(SWITCHPIN, level)
end

setLevel(false)
