local BROKER_HOST, CLIENT_ID, RECONNECT_INTERVAL, onConnect = ...

client = nil

local blinker = dofile("blinker.lua")
blinker.setLevel(0)

local utils = require("utils")

local function handleMqqtConnectFailure(client, reason)
  print("[" .. tmr.now() .. "] connect to mqtt broker failed, reason: " .. reason .. ". retrying...")
  utils.runAfter(RECONNECT_INTERVAL, function() mqttConnect(client) end)
end

local function handleMqqtConnectSuccess(client)
  print("Connected to mqtt broker")
  blinker.setLevel(3)

  onConnect(client)
end

local function mqttConnect(client)
  client:connect(BROKER_HOST, 1883, false, handleMqqtConnectSuccess, handleMqqtConnectFailure)
end

local function handleBrokerOffline(client)
  blinker.setLevel(2)
  print("mqtt broker went offline, reconnecting...")
  runAfter(RECONNECT_INTERVAL, function() mqttConnect(client) end)
end

local function setupMqtt()
  print("Setting up MQTT...")

  client = mqtt.Client(CLIENT_ID, 120)

  -- client:on("message", handleMessage)
  client:on("offline", function() handleBrokerOffline(client) end)

  mqttConnect(client)
end

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
