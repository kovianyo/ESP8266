--wifi.setmode(wifi.NULLMODE) -- disable wifi

dofile('wifiCredentials.lua')
wifi.sta.sethostname("KoviHumiWeb")

dofile('utils.lua')

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

local blinker = dofile("blinker.lua")
blinker.setLevel(0)

local function onConnected()
  blinker.setLevel(1)
end

local function onGotIP()
  blinker.setLevel(3)

  local webserver = dofile("webserver.lua")
  local staticFileHandler = dofile("staticFileHandler.lua")
  webserver.AddHandler(staticFileHandler)
  local terminalHandler = dofile("terminalHandler.lua")
  webserver.AddHandler(terminalHandler)
  webserver.Setup()
end

local function onDisconneted()
  blinker.setLevel(0)
end

loadfile("initWifi.lua")(onConnected, onGotIP, onDisconneted)
