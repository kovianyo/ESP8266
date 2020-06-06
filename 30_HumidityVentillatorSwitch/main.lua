wifi.setmode(wifi.NULLMODE) -- disable wifi

local i2cId = 0 -- must be 0 for bme280
local scl = 1 -- D1, GPIO5
local sda = 2 -- D2, GPIO4

local beepPin = 5

gpio.mode(beepPin, gpio.OUTPUT)
gpio.write(beepPin, gpio.HIGH)
gpio.write(beepPin, gpio.LOW)

local bme280sensor = dofile("bme280sensor.lua")


i2c.setup(i2cId, sda, scl, i2c.SLOW)
bme280sensor.Setup()

local function measure()
  local values = bme280sensor.GetValues()
    if values.Humidity >= 80 then
      gpio.write(beepPin, gpio.HIGH)
    else
      gpio.write(beepPin, gpio.LOW)
    end
end

local mytimer = tmr.create()
mytimer:register(500, tmr.ALARM_AUTO, function (t) measure();  end)
mytimer:start()

local blinker = dofile("blinker.lua")
blinker.setLevel(3)
