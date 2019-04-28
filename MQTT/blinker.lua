-- defautl led pin
local ledPin = 5 -- D5, GPIO14

local timer = tmr.create()

local onInterval = 1000
local offInterval = 1000
local ledState = false


local function blink()
  ledState = not ledState
  if ledState then
    gpio.write(ledPin, gpio.HIGH)
    timer:register(onInterval, tmr.ALARM_SINGLE, function() blink() end)
    timer:start()
  else
    gpio.write(ledPin, gpio.LOW)
    timer:register(offInterval, tmr.ALARM_SINGLE, function() blink() end)
    timer:start()
  end
end

local function setInterval(on, off)
  if off == nil then off = on end
  timer:stop()
  ledState = false
  onInterval = on
  offInterval = off
  blink()
end

-- level: 0..2: getting faster, 3: continuous with small breaks
local function setBlinkLevel(level)
  if level == 0 then setInterval(1000)
  elseif level == 1 then setInterval(500)
  elseif level == 2 then setInterval(300)
  else setInterval(1000, 50)
  end
end

local function setup(pin, defaultState)
  if defaultState == nil then defaultState = gpio.LOW end
  ledPin = pin
  gpio.mode(ledPin, gpio.OUTPUT)
  gpio.write(ledPin, defaultState)
end

return {
  set = setBlinkLevel,
  setup = setup
}
