local BROKER_HOST, CLIENT_ID, RECONNECT_INTERVAL, onConnect, blinker = ...

local client = nil

local utils = require("utils")

local function handleMqqtConnectFailure(client, reason)
  print("[" .. tmr.now() .. "] connect to mqtt broker failed, reason: " .. reason .. ". retrying...")
  utils.runAfter(RECONNECT_INTERVAL, function() mqttConnect(client) end)
end

local function handleMqqtConnectSuccess(client)
  print("Connected to mqtt broker")
  blinker.setLevel(blinker.LEVEL_FAST)

  onConnect(client)
end

local function mqttConnect(client)
  client:connect(BROKER_HOST, 1883, false, handleMqqtConnectSuccess, handleMqqtConnectFailure)
end

local function handleBrokerOffline(client)
  blinker.setLevel(blinker.LEVEL_MEDIUM)
  print("mqtt broker went offline, reconnecting...")
  runAfter(RECONNECT_INTERVAL, function() mqttConnect(client) end)
end

local function setupMqtt()
  print("Setting up MQTT with CLIENT_ID " .. CLIENT_ID)

  client = mqtt.Client(CLIENT_ID, 120)

  client:on("offline", function() handleBrokerOffline(client) end)
  -- on publish overflow receive event
  client:on("overflow", function(client, topic, data)
    print(topic .. " partial overflowed message: " .. data )
  end)

  mqttConnect(client)
end

local function closeClient()
  if client ~= nil then
    client:close()
    client = nil
  end
end

return {
  setupMqtt = setupMqtt,
  closeClient = closeClient
}
