local MQTT_BROKER_HOST = ""
local MQTT_CLIENT_ID = "KoviAirSensor"
local MQTT_RECONNECT_INTERVAL = 2000

local utils = require("utils")

local measure = dofile("measure.lua")

local function doMeasurement(client)
  measure(client)
  utils.runAfter(3000, function() doMeasurement(client) end)
end

loadfile("mqttClient.lua")(MQTT_BROKER_HOST, MQTT_CLIENT_ID, MQTT_RECONNECT_INTERVAL, doMeasurement)
