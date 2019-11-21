BROKER_IP = ""
CLIENT_ID = "KoviAirSensor"
RECONNECT_INTERVAL = 2000

wifi.setphymode(wifi.PHYMODE_N)
wifi.setmode(wifi.STATION)

station_cfg={}
station_cfg.ssid = ""
station_cfg.pwd = ""
wifi.sta.config(station_cfg)
station_cfg = nil
wifi.sta.sethostname("KoviAirSensor")

client = nil

blinker = dofile("blinker.lua")
blinker.setLevel(0)

function runAfter(milliseconds, action)
  local mytimer = tmr.create()
  mytimer:register(milliseconds, tmr.ALARM_SINGLE, function (t) action(); t:unregister() end)
  mytimer:start()
end

function handleMqqtConnectFailure(client, reason)
  print("[" .. tmr.now() .. "] connect to mqtt broker failed, reason: " .. reason .. ". retrying...")
  runAfter(RECONNECT_INTERVAL, function() mqttConnect(client) end)
end

function doMeasurement(client)
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


function handleMqqtConnectSuccess(client)
  print("Connected to mqtt broker")
  blinker.setLevel(3)

  doMeasurement(client)
end

function mqttConnect(client)
  client:connect(BROKER_IP, 1883, false, handleMqqtConnectSuccess, handleMqqtConnectFailure)
end


function handleBrokerOffline(client)
  blinker.setLevel(2)
  print("mqtt broker went offline, reconnecting...")
  runAfter(RECONNECT_INTERVAL, function() mqttConnect(client) end)
end

function setupMqtt()
  print("Setting up MQTT...")

  client = mqtt.Client(CLIENT_ID, 120)

  -- client:on("message", handleMessage)
  client:on("offline", function() handleBrokerOffline(client) end)

  mqttConnect(client)
end

blinker.setLevel(0)

wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
 print("wifi event: Station - CONNECTED. SSID: "..T.SSID..", BSSID: ".. T.BSSID..", Channel: "..T.channel)
 blinker.setLevel(1)
end)

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
 print("wifi event: Station - GOT IP. Station IP: "..T.IP..", Subnet mask: ".. T.netmask..", Gateway IP: "..T.gateway)
 print(" dns server: " .. net.dns.getdnsserver(0))
 blinker.setLevel(2)
 setupMqtt()
end)

wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
 print("wifi event: Station - DISCONNECTED, SSID: "..T.SSID..", BSSID: ".. T.BSSID..", reason: "..T.reason)
 blinker.setLevel(0)
 if client ~= nil then
   client:close()
   client = nil
 end
end)
