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

function sendFile(conn, fileName)
  if notFound then
    conn:close()
    notFound = nil
    return
  end

  if fileOpen == nil then
    if file.open(fileName, "r") then
      fileOpen = true
    else
      notFound = true
      conn:send("Not found!")
      return
    end
  end

  local line = file.read(128)
  if line then conn:send(line)
  else
    conn:close()
    file.close()
    fileOpen = nil
  end
end

function onsent(conn)
  conn:close()
  print("sent.")
end

function onreceive(conn, payload)
  if string.sub(payload, 0, 16) == "GET /favicon.ico"
  then
    conn:on("sent", onsent)
    conn:send("HTTP/1.1 404 file not found")
  else
    local response, processed = processRequest(payload)
    if not processed then
      conn:on("sent", sendFile)
      print("Sending file " .. response)
      sendFile(conn, "html/" .. response)
    else
      print("Sending", response)
      conn:on("sent", onsent)
      conn:send(response)
      print("after send")
    end
  end

end

function listener(conn)
 conn:on("receive", onreceive)
end

srv=net.createServer(net.TCP)
srv:listen(80, listener)

print("Listening...")
print("")
