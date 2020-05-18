local blinker = dofile("blinker.lua")
blinker.setLevel(blinker.LEVEL_VERYSLOW)

local MQTT_CLIENT_ID = "KoviAirSensor"
local MQTT_RECONNECT_INTERVAL = 2000

local utils = require("utils")

local measure = dofile("measure.lua")

local koviMqttClient

local function doMeasurement(client)
  local measurement = measure()

  koviMqttClient.publish("temperature", measurement.temperature)
  koviMqttClient.publish("airpressure", measurement.airPressure)
  koviMqttClient.publish("humidity", measurement.humidity)

  utils.runAfter(3000, function() doMeasurement(client) end)
end

koviMqttClient = loadfile("koviMqttClient.lua")(MQTT_BROKER_HOST, MQTT_CLIENT_ID, MQTT_RECONNECT_INTERVAL, doMeasurement, blinker)

local function onConnected()
  blinker.setLevel(blinker.LEVEL_SLOW)
end

local function onGotIP()
  blinker.setLevel(blinker.LEVEL_MEDIUM)
  koviMqttClient.setup()
end

local function onDisconneted()
  blinker.setLevel(blinker.LEVEL_VERYSLOW)
  koviMqttClient.close()
end

dofile('bme280init.lua')

loadfile("initWifi.lua")(onConnected, onGotIP, onDisconneted)
