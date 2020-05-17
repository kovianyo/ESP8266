-- http://stackoverflow.com/questions/36079145/how-to-send-multiple-data-connsend-with-the-new-sdk-nodemcu
-- https://github.com/marcoskirsch/nodemcu-httpserver/blob/master/httpserver.lua

print("Initilaizing webserver...")

local blinker = dofile("blinker.lua")
blinker.setLevel(0)

function sendFile(conn, fileName)
  if notFound then
    conn:close()
    notFound = nil
    return
  end

  if fileOpen == nil and fileName ~= nil then
    print("Opening file " .. fileName)
    if file.open(fileName, "r") then
      fileOpen = true
    else
      notFound = true
      conn:send("Not found!")
      return
    end
  end

  local line = file.read(128)
  if line then conn:send(line) --print(line)
  else
    conn:close()
    file.close()
    fileOpen = nil
    print("file sending finished")
    print()
  end
end

function onsent(conn)
  conn:close()
  --print("sent.")
  print()
end

function onreceive(conn, payload)
  -- print("receiving '" .. payload .. "'")
  if string.sub(payload, 0, 16) == "GET /favicon.ico"
  then
    conn:on("sent", onsent)
    conn:send("HTTP/1.1 404 file not found")
  else
    if (string.match(payload,"POST") ~= nil) then
      conn:on("sent", sendFile)
      local processPost = dofile("wifiConfig.lua")
      processPost(payload)
      sendFile(conn, "html/" .. "wificonfig.html") -- TODO
      return
    end
    local response, processed = processRequest(payload)
    if not processed then
      conn:on("sent", sendFile)
      if response == "" then response = "index.html" end
      print("Sending file " .. response)
      sendFile(conn, "html/" .. response)
    else
      print("Sending HTTP response body '" .. response .. "'")
      conn:on("sent", onsent)
      conn:send(response)
      --print("after send")
    end
  end

end

function listener(conn)
 conn:on("receive", onreceive)
end

local function setupWebServer()
  srv = net.createServer(net.TCP)
  srv:listen(80, listener)

  print("Listening...")
  print("")
end

local function onConnected()
  blinker.setLevel(1)
end

local function onGotIP()
  blinker.setLevel(3)
  setupWebServer()
end

local function onDisconneted()
  blinker.setLevel(0)
end

loadfile("initWifi.lua")(onConnected, onGotIP, onDisconneted)
