local MQTT_BROKER_HOST = ""
local MQTT_CLIENT_ID = "KoviAirSensor"
local MQTT_RECONNECT_INTERVAL = 2000

client = nil

blinker = dofile("blinker.lua")
blinker.setLevel(0)

local function runAfter(milliseconds, action)
  local mytimer = tmr.create()
  mytimer:register(milliseconds, tmr.ALARM_SINGLE, function (t) action(); t:unregister() end)
  mytimer:start()
end

local function handleMqqtConnectFailure(client, reason)
  print("[" .. tmr.now() .. "] connect to mqtt broker failed, reason: " .. reason .. ". retrying...")
  runAfter(MQTT_RECONNECT_INTERVAL, function() mqttConnect(client) end)
end

local function doMeasurement(client)
  local H, T = bme280.humi()
  local P, T = bme280.baro()

  local temperature = T / 100
  local airPressure = P / 10000
  local humidity = H / 1000

  print("Temperature: " .. temperature .. " C, air pressure: " .. airPressure .. " kPa, humidity: " .. humidity .. " %")

  client:publish("temperature", temperature, 0, 0--[[, function(client) print("sent") end--]])
  client:publish("airpressure", airPressure, 0, 0)
  client:publish("humidity", humidity, 0, 0)

  runAfter(3000, function() doMeasurement(client) end)
end

local function handleMqqtConnectSuccess(client)
  print("Connected to mqtt broker")
  blinker.setLevel(3)

  doMeasurement(client)
end

local function mqttConnect(client)
  client:connect(MQTT_BROKER_HOST, 1883, false, handleMqqtConnectSuccess, handleMqqtConnectFailure)
end

local function handleBrokerOffline(client)
  blinker.setLevel(2)
  print("mqtt broker went offline, reconnecting...")
  runAfter(MQTT_RECONNECT_INTERVAL, function() mqttConnect(client) end)
end

local function setupMqtt()
  print("Setting up MQTT...")

  client = mqtt.Client(MQTT_CLIENT_ID, 120)

  -- client:on("message", handleMessage)
  client:on("offline", function() handleBrokerOffline(client) end)

  mqttConnect(client)
end

blinker.setLevel(0)

local function onConnected()
  blinker.setLevel(1)
end

local function onGotIP()
  blinker.setLevel(2)
  setupMqtt()
end

local function onDisconneted()
  blinker.setLevel(0)
  if client ~= nil then
    client:close()
    client = nil
  end
end

loadfile("initWifi.lua")(onConnected, onGotIP, onDisconneted)
