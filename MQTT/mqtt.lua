BROKER_IP = "192.168.1.148"
CLIENT_ID = "clientid"
TOPIC = "switch"
RECONNECT_INTERVAL = 2000

switchPin = 5 -- D5, GPIO14
gpio.mode(switchPin, gpio.OUTPUT)
gpio.write(switchPin, gpio.LOW)
--gpio.write(switchPin, gpio.HIGH)

station_cfg={}
station_cfg.ssid="KoviNet"
wifi.sta.config(station_cfg)
station_cfg = nil

client = nil

blinker = dofile("blinker.lua")
blinker.setup(4) -- D4, GPIO2
blinker.set(0)

function setSwitch(on)
  if (on) then
    gpio.write(switchPin, gpio.HIGH)
  else
    gpio.write(switchPin, gpio.LOW)
  end
end

function runAfter(milliseconds, action)
  local mytimer = tmr.create()
  mytimer:register(milliseconds, tmr.ALARM_SINGLE, function (t) action(); t:unregister() end)
  mytimer:start()
end

function handleMqqtConnectFailure(client, reason)
  print("[" .. tmr.now() .. "] connect to mqtt broker failed, reason: " .. reason .. ". retrying...")
  runAfter(RECONNECT_INTERVAL, function() mqttConnect(client) end)
end

function handleMqqtConnectSuccess(client)
  print("connected to mqtt broker")

  -- subscribe topic with qos = 0
  local success = client:subscribe(TOPIC, 2,
   function(client)
    print("successfully subscribed to topic '" .. TOPIC .. "'")
    blinker.set(3)
  end)
  if (not success) then print("subscribe unsuccessful") end
  -- publish a message with data = hello, QoS = 0, retain = 0
  --client:publish("/topic", "hello", 0, 0, function(client) print("sent") end)
end

function mqttConnect(client)
  client:connect(BROKER_IP, 1883, 0, handleMqqtConnectSuccess, handleMqqtConnectFailure)
end


function handleMessage(client, topic, data)
  print(topic .. ":" )
  if data ~= nil then
    print(data)
    if (topic == TOPIC) then
      if (data == "on") then
        setSwitch(true)
      else
        setSwitch(false)
     end
   end
  end
end

function handleBrokerOffline(client)
  blinker.set(2)
  print("mqtt broker went offline, reconnecting...")
  runAfter(RECONNECT_INTERVAL, function() mqttConnect(client) end)
end

function setupMqtt()
  print("setting up MQTT...")

  client = mqtt.Client(CLIENT_ID, 120)

  client:on("message", handleMessage)
  client:on("offline", function() handleBrokerOffline(client) end)

  mqttConnect(client)
end

print("wifi status:" .. wifi.sta.status())

blinker.set(0)

wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
 print("wifi event: Station - CONNECTED. SSID: "..T.SSID..", BSSID: ".. T.BSSID..", Channel: "..T.channel)
 blinker.set(1)
end)

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
 print("wifi event: Station - GOT IP. Station IP: "..T.IP..", Subnet mask: ".. T.netmask..", Gateway IP: "..T.gateway)
 blinker.set(2)
 setupMqtt()
end)

wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
 print("wifi event: Station - DISCONNECTED, SSID: "..T.SSID..", BSSID: ".. T.BSSID..", reason: "..T.reason)
 blinker.set(0)
 if client ~= nil then
   client:close()
   client = nil
 end
end)
