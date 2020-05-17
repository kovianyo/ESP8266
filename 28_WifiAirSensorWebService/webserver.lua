-- http://stackoverflow.com/questions/36079145/how-to-send-multiple-data-connsend-with-the-new-sdk-nodemcu
-- https://github.com/marcoskirsch/nodemcu-httpserver/blob/master/httpserver.lua

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

local function onsent(conn)
  conn:close()
  --print("sent.")
  print()
end

local function getRequest(payload)
  local firstLine = Utils.GetFirstLine(payload)
  local trimmedFirstLine = string.gsub(firstLine, '^%s*(.-)%s*$', '%1') -- trim starting and trailing spaces and newlines

  Utils.Log("Processing '" .. trimmedFirstLine .. "'")

  local parts = Utils.Split(firstLine, "%S+")

  if (table.getn(parts) < 2) then
    Utils.Log("HTTP header malformed")
    return nil
  end

  local request = {
    verb = parts[0],
    path = parts[1],
    protocol = parts[2]
  }

  return request
end

local function process() end

local function onreceive(conn, payload)
  conn:on("sent", onsent)
  local request = getRequest(payload)

  if (request == nil) then
    return
  end

  if request.verb == "GET" and path == "/favicon.ico"
  then
    conn:send("HTTP/1.1 404 file not found")
  else
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

end

local function listener(conn)
 conn:on("receive", onreceive)
end

local function setupWebServer(requestProcessor)
  process = requestProcessor
  print("Initilaizing webserver...")

  srv = net.createServer(net.TCP)
  srv:listen(80, listener)

  print("Listening...")
  print("")
end

return {
  setup = setupWebServer
}
