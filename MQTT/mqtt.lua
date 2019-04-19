BROKER_IP = "192.168.1.148"
CLIENT_ID = "clientid"
TOPIC = "switch"

ledPin = 5 -- D5, GPIO14
gpio.mode(ledPin, gpio.OUTPUT)
gpio.write(ledPin, gpio.LOW)
--gpio.write(ledPin, gpio.HIGH)

station_cfg={}
station_cfg.ssid="KoviNet"
wifi.sta.config(station_cfg)
station_cfg = nil

function setLed(on)
  if (on) then
    gpio.write(ledPin, gpio.HIGH)
  else
    gpio.write(ledPin, gpio.LOW)
  end
end

function setupMqtt()
  print("setting up MQTT")

  m = mqtt.Client(CLIENT_ID, 120)

  m:on("message", function(client, topic, data)
    print(topic .. ":" )
    if data ~= nil then
      print(data)
      if (topic == TOPIC) then
        if (data == "on") then
          setLed(true)
        else
          setLed(false)
       end
     end
    end
  end)

  m:connect(BROKER_IP, 1883, 0, function(client)
    print("connected to mqtt broker")

    -- subscribe topic with qos = 0
    local success = client:subscribe(TOPIC, 2, function(client) print("subscribe success") end)
    if (not success) then print("subscribe unsuccess ful") end
    -- publish a message with data = hello, QoS = 0, retain = 0
    --client:publish("/topic", "hello", 0, 0, function(client) print("sent") end)
  end,
  function(client, reason)
    print("mqtt broker failed, reason: " .. reason)
  end)

end

print("wifi status:" .. wifi.sta.status())

wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
 print("\n\tSTA - CONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: ".. T.BSSID.."\n\tChannel: "..T.channel)
 --tmr.create():alarm(4000, tmr.ALARM_SINGLE, function() setupMqtt() end)
 end)

 wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
 print("\n\tSTA - GOT IP".."\n\tStation IP: "..T.IP.."\n\tSubnet mask: ".. T.netmask.."\n\tGateway IP: "..T.gateway)
 setupMqtt()
 end)

wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
 print("\n\tSTA - DISCONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: ".. T.BSSID.."\n\treason: "..T.reason)
 end)
