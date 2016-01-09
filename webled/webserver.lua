print("Setting wifi mode to AccessPoint...")
wifi.setmode(wifi.SOFTAP)

function getFirstLine(text)
  local start, stop = string.find(text, "\n")
  --print(start)
  local firstLine = string.sub(text, 0, start)
  --print(firstLine)
  return firstLine
end

function getFileName(payload)
  local firstLine = getFirstLine(payload)
  --print(firstLine)
  local fileName = split(firstLine, "%S+")[1]
  --print(fileName)
  return fileName
end

function getCommand(payload)
  --print("d1")
  local start, stop = string.find(payload,"\n\r")
  --print(start)
  local postData = string.sub(payload, start + 3)
  --print(postData)
  start, stop = string.find(postData,"command=")
  --print(stop)
  local command = string.sub(postData, stop + 1)
  --print(command)
  return command
end

function processPost(payload)
  if string.sub(payload, 0, 4) ~= "POST" then return end
  local fileName = getFileName(payload)
  --print("filename")
  --print(fileName)
  if fileName ~= "/" then return end
  local command = getCommand(payload)
  print("Command:", command)
  processCommand(command)
end

function sendFile(connection, fileName)
  file.open(fileName, "r")
  repeat
    local line = file.readline()
    if line ~= nil then connection:send(line) end
  until (line == nil)
  file.close()
end

print("Initilaizing webserver...")

srv=net.createServer(net.TCP)
srv:listen(80, function(conn)
 conn:on("receive", function(conn,payload)
  print(getFirstLine(payload))
  --print(payload)
  tmr.stop(LEDTIMER)
  processPost(payload)
  if string.sub(payload, 0, 16) ~= "GET /favicon.ico"
  then
    sendFile(conn, "index.html")
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
