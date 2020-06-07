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
  return postData
end

local _gconn = nil

local function closeConnection(connection)
  --print("clsoing connection")
  connection:close()
  _gconn = nil
  --print("sent.")
  --print()
end

local function finish()
  print(" ")
  if (_gconn ~= nil) then
    _gconn:on("sent", closeConnection)
    _gconn = nil
    -- print("finish finished")
  end
end


local timer1 = tmr.create()

-- no print() in this method!
local function s_output(str)
  if (_gconn ~= nil) then
    timer1:stop()
    _gconn:send(str)
    timer1:start()
  end
end

local function handle(connection, payload, header)
  if (header.path == "/terminal") then
    if header.verb == "POST" then
      local command = getCommand(payload)
      print("command: '" .. command .. "'")
      connection:on("sent", nil)
      node.output(s_output, 1)

      timer1:register(1000, tmr.ALARM_SINGLE, function (t) finish();  end)
      _gconn = connection
      node.input(command)
      return true
    end
  end
end

return {
  Handle = handle
}
