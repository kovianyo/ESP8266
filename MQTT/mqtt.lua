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

function mqttConnect(m)
  m:connect(BROKER_IP, 1883, 0, function(client)
    print("connected to mqtt broker")

    -- subscribe topic with qos = 0
    local success = client:subscribe(TOPIC, 2,
     function(client)
      print("subscribe success")
      setBlinkLevel(3)
    end)
    if (not success) then print("subscribe unsuccess ful") end
    -- publish a message with data = hello, QoS = 0, retain = 0
    --client:publish("/topic", "hello", 0, 0, function(client) print("sent") end)
  end,
  function(client, reason)
    print("mqtt broker failed, reason: " .. reason)
  end)
end


function handleMessage(client, topic, data)
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
end

function setupMqtt()
  print("setting up MQTT...")

  m = mqtt.Client(CLIENT_ID, 120)

  m:on("message", handleMessage)
  m:on("offline", function() print("mqtt offline") end)

  mqttConnect(m)
end

print("wifi status:" .. wifi.sta.status())


timer = tmr.create()

onInterval = 1000
offInterval = 1000

function blink()
  ledState = not ledState
  if ledState then
    gpio.write(ledPin, gpio.HIGH)
    timer:register(onInterval, tmr.ALARM_SINGLE, function() blink() end)
    timer:start()
  else
    gpio.write(ledPin, gpio.LOW)
    timer:register(offInterval, tmr.ALARM_SINGLE, function() blink() end)
    timer:start()
  end
end

function setInterval(on, off)
  if off == nil then off = on end
  timer:stop()
  ledState = false
  onInterval = on
  offInterval = off
  blink()
end

-- level: 0..2: getting faster, 3: continuous with small breaks
function setBlinkLevel(level)
  if level == 0 then setInterval(1000)
  elseif level == 1 then setInterval(500)
  elseif level == 2 then setInterval(300)
  else setInterval(1000, 50)
  end
end

setBlinkLevel(0)

wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
 print("wifi event: Station - CONNECTED. SSID: "..T.SSID..", BSSID: ".. T.BSSID..", Channel: "..T.channel)
 setBlinkLevel(1)
end)

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
 print("wifi event: Station - GOT IP. Station IP: "..T.IP..", Subnet mask: ".. T.netmask..", Gateway IP: "..T.gateway)
 setBlinkLevel(2)
 setupMqtt()
end)

wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
 print("wifi event: Station - DISCONNECTED, SSID: "..T.SSID..", BSSID: ".. T.BSSID..", reason: "..T.reason)
end)
