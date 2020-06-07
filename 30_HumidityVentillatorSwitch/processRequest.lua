local function getPrefix()
  local html = '<!DOCTYPE html>\n<head>\n<title>Kovi AirSensor</title>\n<link rel="icon" href="data:;base64,iVBORw0KGgo=">\n</head>'
  html = html .. '\n<body>\n<h1>KoviHumiWeb</h1>\n'
  html = html .. '<form method="post">'
  html = html .. '  <div><textarea name="command" rows="4" cols="50">'
  return html
end

local function getPostfix1()
  local html = '</textarea></div>'
  html = html .. '  <div><input type="submit"></div>'
  html = html .. '</form>'
  html = html .. '<div style="white-space: pre;">\n'
  return html
end

local function getPostfix2()
  local html = '\n</div>'
  html = html .. "</body>\n</html>"
  return html
end

local function unescape(text)
  local output = ""
  local index = 1
  while index <= string.len(text)
  do
    local char = string.sub(text, index, index)
    if char ~= "%" then
      if char == "+" then char = " " end
      output = output .. char
    else
      local num = string.sub(text, index + 1, index + 2)
      output = output .. string.char(tonumber("0x" .. num))
      index = index + 2
    end
    index = index + 1
  end

  return output
end

local function printTable(t)
  for k, v in pairs(t) do
     print(k, v)
  end
end

local function getCommand(payload)
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

local gconn = nil

local function closeConnection(connection)
  --print("clsoing connection")
  connection:close()
  gconn = nil
  --print("sent.")
  --print()
end

local function finish()
  --print("finish")
  local html = getPostfix2()
  if (gconn ~= nil) then
    gconn:on("sent", closeConnection)
    gconn:send(html)
    gconn = nil
    --print("finish finished")
  end
end


local timer1 = tmr.create()
--timer1:register(1000, tmr.ALARM_SINGLE, function (t) finish();  end)

-- no print() in this method!
local function s_output(str)
  --print("str1: " .. str)
  if (gconn ~= nil) then
    timer1:stop()
    gconn:send(str)
    timer1:start()
    --gconn:on("sent", closeConnection)
    --print("str: " .. str)
    --gconn = nil
  end
end


local function process(connection, payload, header)
  if (header.path == "/") then
    if header.verb == "POST" then
      local command = unescape(getCommand(payload))
      print("command: '" .. command .. "'")
      connection:on("sent", nil)
      local html = getPrefix() .. command
      connection:send(html)
      html = getPostfix1()
      connection:send(html)
      node.output(s_output, 1)

      timer1:register(1000, tmr.ALARM_SINGLE, function (t) finish();  end)
       gconn = connection
       node.input(command)
       return
       --[[
       connection:on("sent", function (conn)
         node.output(nil)
         conn:close()
       end)
       ]]

      --local parts = Utils.Split(payload, "[^=]+")
      --printTable(parts)
      --[[
      if parts[1] == "command" then
        print(unescape(parts[2]))
      end
      ]]
      --local html = getIndex()
      --connection:send(html)
    else
      local html = getPrefix()
      connection:send(html)
      connection:send('print(node.heap())')
      html = getPostfix1()
      connection:send(html)
      html = getPostfix2()
      connection:send(html)
    end
  end
end

return {
  Process = process
}
