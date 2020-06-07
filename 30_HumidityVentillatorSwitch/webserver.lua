-- http://stackoverflow.com/questions/36079145/how-to-send-multiple-data-connsend-with-the-new-sdk-nodemcu
-- https://github.com/marcoskirsch/nodemcu-httpserver/blob/master/httpserver.lua

local _handlers = {}

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

  local index = 1
  while index <= #_handlers do
    local handled = _handlers[index].Handle(connection, payload, header)
    if handled then return end
    index = index + 1
  end

  print("no handler found to handle " .. header.verb .. " " .. header.path)

  connection:send("No handler found to handle this request.")
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


local function setupWebServer()
  print("Initilaizing webserver...")

  local srv = net.createServer(net.TCP)
  srv:listen(80, listener)

  print("Listening...")
  print("")
end

local function addHandler(handler)
  table.insert(_handlers, handler)
end

return {
  Setup = setupWebServer,
  AddHandler = addHandler
}
