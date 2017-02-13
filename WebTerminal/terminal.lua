function sendFile(connection, fileName)
  file.open(fileName, "r")
  repeat
    local line = file.readline()
    if line ~= nil then connection:send(line) end
  until (line == nil)
  file.close()
end

function getFirstLine(text)
  local start, stop = string.find(text, "\n")
  --print(start)
  local firstLine = string.sub(text, 0, start)
  --print(firstLine)
  return firstLine
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

function url_decode(str)
  str = string.gsub (str, "+", " ")
  str = string.gsub (str, "%%(%x%x)",
      function(h) return string.char(tonumber(h,16)) end)
  str = string.gsub (str, "\r\n", "\n")
  return str
end

-- Wifi accesspoint
wifi.setmode(wifi.SOFTAP)

-- set SSID
cfg={}
cfg.ssid="ESP8266"
wifi.ap.config(cfg)




print("Initilaizing webserver...")

srv=net.createServer(net.TCP)
srv:listen(80, function(conn)
 conn:on("receive", function(conn,payload)
  function s_output(str)
      if(conn~=nil)
         then conn:send(str)
      end
   end
  --print(getFirstLine(payload))
  print(payload)
  local command = url_decode(getCommand(payload))
  print("command :")
  print(command)
  node.output(s_output, 0)   -- re-direct output to function s_ouput.
  node.input(command)
  node.output(nil)        -- un-register the redirect output function, output goes to serial
--tmr.stop(LEDTIMER)
  --processPost(payload)
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
 conn:on("disconnection", function(c)
   node.output(nil)        -- un-register the redirect output function, output goes to serial
 end)
end)

print("Listening...")
print("")
