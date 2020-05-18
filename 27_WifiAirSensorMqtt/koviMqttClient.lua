local BROKER_HOST, CLIENT_ID, RECONNECT_INTERVAL, onConnect, blinker = ...

local client = nil

local utils = require("utils")

local function handleMqqtConnectFailure(client, reason)
  print("[" .. tmr.now() .. "] connect to mqtt broker failed, reason: " .. reason .. ". retrying...")
  utils.runAfter(RECONNECT_INTERVAL, function() mqttConnect(client) end)
end

local function handleMqqtConnectSuccess(client)
  print("Connected to MQTT broker")
  blinker.setLevel(blinker.LEVEL_FAST)

  onConnect(client)
end

local function mqttConnect(client)
  print("Connecting to MQTT broker " .. BROKER_HOST)
  client:connect(BROKER_HOST, handleMqqtConnectSuccess, handleMqqtConnectFailure)
end

local function handleBrokerOffline(client)
  blinker.setLevel(blinker.LEVEL_MEDIUM)
  print("MQTT broker went offline, reconnecting...")
  runAfter(RECONNECT_INTERVAL, function() mqttConnect(client) end)
end

local function setup()
  print("Setting up MQTT with CLIENT_ID " .. CLIENT_ID)

  client = mqtt.Client(CLIENT_ID, 120)

  client:on("offline", function() handleBrokerOffline(client) end)
  -- on publish overflow receive event
  client:on("overflow", function(client, topic, data)
    print("MQTT overflow, topic: " .. topic ..", data: " ..  data)
  end)

  mqttConnect(client)
end

local function close()
  if client ~= nil then
    client:close()
    client = nil
  end
end

return {
  setup = setup,
  close = close
}
