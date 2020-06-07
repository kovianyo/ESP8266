-- http://stackoverflow.com/questions/36079145/how-to-send-multiple-data-connsend-with-the-new-sdk-nodemcu
-- https://github.com/marcoskirsch/nodemcu-httpserver/blob/master/httpserver.lua

--[[

local function sendFile(conn, fileName)
  if notFound then
    conn:close()
    notFound = nil
    return
  end

  if fileOpen == nil and fileName ~= nil then
    print("Opening file '" .. fileName .. "'")
    if file.open(fileName, "r") then
      fileOpen = true
    else
      notFound = true
      conn:send("File '" .. fileName .. "' not found!")
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
]]--

local function closeConnection(connection)
  connection:close()
  --print("sent.")
  --print()
end

local function getHeader(payload)
  local firstLine = Utils.GetFirstLine(payload)
  local trimmedFirstLine = string.gsub(firstLine, '^%s*(.-)%s*$', '%1') -- trim starting and trailing spaces and newlines

  Utils.Log("Processing '" .. trimmedFirstLine .. "'")

  local parts = Utils.Split(firstLine, "%S+")

  if (table.getn(parts) < 2) then
    Utils.Log("HTTP header malformed")
    return nil
  end

  local header = {
    verb = parts[0],
    path = parts[1],
    protocol = parts[2]
  }

  return header
end

local function process() end

local function onreceive(connection, payload)
  connection:on("sent", closeConnection)
  local header = getHeader(payload)

  if (header == nil) then
    return
  end

  if header.verb == "GET" and header.path == "/favicon.ico"
  then
    connection:send("HTTP/1.1 404 file not found")
    return
  end

  process(connection, payload, header)

--[[
    if (request.verb == "POST") then
      conn:on("sent", sendFile)
      local processPost = dofile("wifiConfig.lua")
      processPost(payload)
      sendFile(conn, "html/" .. "wificonfig.html") -- TODO
      return
    end
    local response = process(request)
    if response == nil then
      conn:on("sent", sendFile)
      local fileName = request.path
      if fileName == "/" then fileName = "/index.html" end
      print("Sending file '" .. request.path .. "'")
      sendFile(conn, "html" .. request.path)
    else
      print("Sending HTTP response body '" .. response .. "'")
      conn:send(response)
    end
  end
]]--
end

local function listener(conn)
 conn:on("receive", onreceive)
 conn:on("connection", function(sck, c)
   local port, ip = sck:getpeer()
   if ip ~= nil and port ~= nil then
     print("cleint connected: " .. ip .. ":" .. port)
   end
 end)
end


local function setupWebServer(requestProcessor)
  process = requestProcessor
  print("Initilaizing webserver...")

  local srv = net.createServer(net.TCP)
  srv:listen(80, listener)

  print("Listening...")
  print("")
end

return {
  Setup = setupWebServer
}
