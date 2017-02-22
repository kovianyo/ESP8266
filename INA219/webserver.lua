wifi_SSID = "KoviNet"
wifi_password = ""

-- Connect to the wifi network
wifi.setmode(wifi.STATION)
--wifi.setphymode(wifi_signal_mode)
wifi.sta.config(wifi_SSID, wifi_password)
wifi.sta.connect()

--ip = wifi.sta.getip()
--print("Got IP:", ip)

function Sendfile(conn, filename)
    if file.open(filename, "r") then
        repeat
            local line=file.read(128)
            if line then conn:send(line) end
        until not line
        file.close()
    end
end

print("Initilaizing webserver...")

function onsent(conn)
  conn:close()
  print("sent.")
end

function onreceive(conn, payload)
  if string.sub(payload, 0, 16) ~= "GET /favicon.ico"
  then
    local response = processRequest(payload)
    if response == nil then
      print("Sending index.html")
      Sendfile(conn, "index.html")
    else
      print("Sending", response)
      conn:send(response)
      print("after send")
    end
  else
    conn:send("HTTP/1.1 404 file not found")
  end

 conn:on("sent", onsent)
end

function listener(conn)
 conn:on("receive", onreceive)
end

srv=net.createServer(net.TCP)
srv:listen(80, listener)

print("Listening...")
print("")
