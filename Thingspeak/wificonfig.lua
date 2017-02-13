print("wificonfig")

wifi.setmode(wifi.STATIONAP)

cfg={}
cfg.ssid="ESP8266"
--cfg.pwd=""
wifi.ap.config(cfg)

html1 =
[[
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="icon" href="data:;base64,=">
    <title>WifiConfig</title>
  </head>
  <body>
    <h1>WifiConfig</h1>
]]

html2 =
[[
    <form method="post">
        SSID: <input type="text" name="ssid"><br />
        Password: <input type="text" name="password"><br />
        <input type="submit">
    </form>
  </body>
</html>]]


print("Initilaizing webserver...")

pl = ""

function processPost(pl)
  if (not (string.match(pl,"POST") == nil)) then
    ssid_start, ssid_end = string.find(pl,"ssid=")

    print(ssid_start, ssid_end)

    amper1_start, amper1_end = string.find(pl,"&", ssid_end+1)

    print(amper1_start, amper1_end)

    ssid = string.sub(pl, ssid_end+1, amper1_start-1)
    password = string.sub(pl, amper1_end+10)

    print("ssid: '" .. ssid .. "'")
    print("password: '" .. password .. "'")

    ---
    wifi.sta.config(ssid, password)
    wifi.sta.connect()

    if file.open("ssid.txt", "w+") then
      file.write(ssid)
      file.close()
      else
      print("Cannot open ssid.txt.")
    end

    if file.open("password.txt", "w+") then
      file.write(password)
      file.close()
      else
      print("Cannot open password.txt.")
    end
  end
end

srv=net.createServer(net.TCP)
srv:listen(80, function(conn)
 conn:on("receive", function(conn,payload)
  --print(getFirstLine(payload))
  print("payload:")
  print(payload)
  pl = payload
  print("payload end")
  processPost(payload)
  if string.sub(payload, 0, 16) ~= "GET /favicon.ico"
  then
    conn:send(html1)
    --if state then conn:send("State: on")
    --else conn:send("State: off")
    --end
    conn:send(html2)
  else
    conn:send("HTTP/1.1 404 file not found")
  end
 end)
 conn:on("sent", function(conn)
  conn:close()
 end)
end)

print("Listening...")
print("")

ssid = nil

if file.open("ssid.txt", "r") then
  ssid = file.read()
  file.close()
end

password = nil

if file.open("password.txt", "r") then
  password = file.read()
  file.close()
end

if ssid ~= nil and password ~= nil then
  wifi.sta.config(ssid, password)
  wifi.sta.connect()
end

--- Thingspeak ---
thingspeak_channel_api_write_key = "ZBQUP8AAIC6LQ0RF"
--[[
--- WIFI ---
wifi_SSID = "KoviNet"
wifi_password = ""

-- Connect to the wifi network
wifi.setmode(wifi.STATION)
--wifi.setphymode(wifi_signal_mode)
wifi.sta.config(wifi_SSID, wifi_password)
wifi.sta.connect()
]]--

t = require("ds18b20")

pin = 1

t.setup(pin)

function readTemperature()
  local temp = 85
  local retry = 100
  while temp == 85 and retry > 0 do
    temp = t.read()
    retry = retry - 1
  end

  --print("temp:", temp)
  --print(temp == 85)

  --print("retry:", retry)

  return temp
end

function loop()
    if wifi.sta.status() == 5 then
        -- Stop the loop
        --tmr.stop(0)

        con = nil
        con = net.createConnection(net.TCP, 0)

        con:on("receive", function(con, payloadout)
          print(payloadout)
            if (string.find(payloadout, "Status: 200 OK") ~= nil) then
                print("Posted OK to ThingSpeak");
            end
        end)

        con:on("connection", function(con, payloadout)

        -- Get sensor data
        local temperature = readTemperature()

        print("Sending temperature:", temperature)

        -- Post data to Thingspeak
        con:send(
            "GET /update?api_key=" .. thingspeak_channel_api_write_key ..
            "&field3=" .. temperature ..
            "\r\n")
        end)

        con:on("disconnection", function(con, payloadout)
            con:close();
            collectgarbage();
        end)

        -- Connect to Thingspeak
        con:connect(80,'api.thingspeak.com')
    else
        print("Connecting...")
    end

    tmr.alarm(0, 1000*60, tmr.ALARM_SINGLE, loop)
end

loop()

--tmr.stop(0)
