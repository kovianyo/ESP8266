print("Wificonfig")

--[[
-- to save an other AccessPoint:

wifi.sta.config("KoviNet2", "")
wifi.sta.connect()

-- to check connection:
print(wifi.sta.status())
print(wifi.sta.getip())
--]]

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

ip = wifi.ap.getip()
print("AccessPoint IP:", ip)

pl = ""

function connectToAccessPoint(ssid, password)
  print("Connecting to AccessPoint...")
  wifi.sta.config(ssid, password)
  wifi.sta.connect()
end

function printString(text, name)
  if text == nil then
    return
  end

  if name ~= nil then
    print(name .. ": '" .. text .. "'")
  else
    print("'" .. text .. "'")
  end
end

function processPost(pl)
  if (string.match(pl,"POST") ~= nil) then

    print("Parsing HTTP response")

    ssid_start, ssid_end = string.find(pl,"ssid=")

    --print(ssid_start, ssid_end)

    amper1_start, amper1_end = string.find(pl,"&", ssid_end+1)

    --print(amper1_start, amper1_end)

    ssid = string.sub(pl, ssid_end+1, amper1_start-1)
    password = string.sub(pl, amper1_end+10)

    --print("ssid: '" .. ssid .. "'")
    --print("password: '" .. password .. "'")
    printString(ssid, "SSID")
    printString(password, "password")

    ---
    connectToAccessPoint(ssid, password)
    --print("Connecting to AccessPoint...")
    --wifi.sta.config(ssid, password)
    --wifi.sta.connect()

    print("Writing SSID and password to files")

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

function readFiles()
  local ssid = nil

  if file.open("ssid.txt", "r") then
    ssid = file.read()
    printString(ssid, "SSID")
    file.close()
  else
    print("Could not open ssid.txt.")
  end

  local password = nil

  if file.open("password.txt", "r") then
    password = file.read()
    printString(password, "password")
    file.close()
  else
    print("Could not open password.txt.")
  end

  if ssid ~= nil and password ~= nil then
    connectToAccessPoint(ssid, password)
    --print("Connecting to AccessPoint...")
    --wifi.sta.config(ssid, password)
    --wifi.sta.connect()
  end
end

print("Checking files for SSID and password...")
readFiles()

print("Initilaizing webserver...")

srv=net.createServer(net.TCP)
srv:listen(80, function(conn)
 conn:on("receive", function(conn,payload)
  --print(getFirstLine(payload))
  --print("payload:")
  --print(payload)
  pl = payload
  --print("payload end")
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
