-- defautl led pin
local defaultLedPin = 4 -- D4, GPIO2

local ledPin = nil

local timer = nil

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

local function setup(pin, defaultState)
  if pin == nil then pin = defaultLedPin end
  if defaultState == nil then defaultState = gpio.LOW end
  ledPin = pin
  gpio.mode(ledPin, gpio.OUTPUT)
  gpio.write(ledPin, defaultState)
  timer = tmr.create()
end

-- level: 0..2: getting faster, 3: continuous with small breaks
local function setLevel(level)
  if timer == nil then setup() end
  if level == 0 then setInterval(1000)
  elseif level == 1 then setInterval(500)
  elseif level == 2 then setInterval(300)
  else setInterval(2000, 1)
  end
end

return {
  setup = setup,
  setLevel = setLevel
}
