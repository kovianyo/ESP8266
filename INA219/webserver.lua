wifi_SSID = "KoviNet"
wifi_password = ""

-- Connect to the wifi network
wifi.setmode(wifi.STATION)
--wifi.setphymode(wifi_signal_mode)
wifi.sta.config(wifi_SSID, wifi_password)
wifi.sta.connect()

--ip = wifi.sta.getip()
--print("Got IP:", ip)

print("Initilaizing webserver...")

srv=net.createServer(net.TCP)
srv:listen(80, function(conn)
 conn:on("receive", function(conn,payload)
  --print("payload:")
  --print(payload)
  --print("payload end")
  --pl = payload
  --print(getFirstLine(payload))
  --local firstLine = getFirstLine(payload)
  if string.sub(payload, 0, 16) ~= "GET /favicon.ico"
  then
    local response = processRequest(payload)
    print("Sending", response)
    conn:send(response)
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
