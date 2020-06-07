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

local function handle(connection, payload, header)
  if header.verb ~= "GET" then return end
  print("StaticFileHandler checking " .. header.path)

  local fileName = header.path
  if fileName == "/" then fileName = "/index.html" end
  fileName = string.sub(fileName, 2) -- remove first character ("/")
  if not file.exists(fileName) then return false end
  print("Sending file '" .. fileName .. "'")
  conn = connection
  conn:on("sent", sendFile)
  sendFile(conn, fileName)

  return true
end

local handler = {
  Handle = handle
}

return handler
