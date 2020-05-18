local blinker = dofile("blinker.lua")
blinker.setLevel(0)

local MQTT_CLIENT_ID = "KoviAirSensor"
local MQTT_RECONNECT_INTERVAL = 2000

local utils = require("utils")

local measure = dofile("measure.lua")

local function doMeasurement(client)
  measure(client)
  utils.runAfter(3000, function() doMeasurement(client) end)
end

local myClient = loadfile("mqttClient.lua")(MQTT_BROKER_HOST, MQTT_CLIENT_ID, MQTT_RECONNECT_INTERVAL, doMeasurement, blinker)


local function onConnected()
  blinker.setLevel(1)
end

local function onGotIP()
  blinker.setLevel(2)
  myClient.setupMqtt()
end

local function onDisconneted()
  blinker.setLevel(0)
  myClient.closeClient()
end

dofile('bme280init.lua')

loadfile("initWifi.lua")(onConnected, onGotIP, onDisconneted)
