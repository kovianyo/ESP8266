wifi.setmode(wifi.SOFTAP)
--wifi.sta.config("KoviNet", "")

html1 =
[[
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="icon" href="data:;base64,=">
    <title>TrainControl</title>
  </head>
  <body>
    <h1>TrainControl</h1>
]]

html2 =
[[
    <form method="post">
       <div>
	     channel:
		 <select id="channel">
			<option value="1">1</option>
			<option value="2">2</option>
		 </select>
	   </div>
	   speed (+/- 1023): <input type="text" name="speed" id="speed" value="0" size="5">
        <input type="submit" name="command" value="set" onclick="document.forms[0].action = 'speed=' + document.getElementById('speed').value + '&channel=' +  document.getElementById('channel').options[document.getElementById('channel').selectedIndex].value;">
    </form>
  </body>
</html>]]

function split(text, pattern)
  array = {}
  local index = 0
  for i in string.gmatch(text, pattern) do
    array[index] = i
    index = index + 1
  end
  return array
end

function splitChar(text, separatorChar)
  return split(text, "[^" .. separatorChar .. "]+")
end


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
  --print(payload)
  local start, stop = string.find(payload,"\n\r")
  --print(start)
  local postData = string.sub(payload, start + 3)
  print(postData)
  start, stop = string.find(postData,"command=")
  print(stop)
  local command = string.sub(postData, stop + 1)
  --print(command)
  return command
end

function processPost(payload)
  if string.sub(payload, 0, 4) ~= "POST" then return end
  local fileName = getFileName(payload)
  print("filename")
  print(fileName)
  --if fileName ~= "/" then return end
  local command = string.sub(fileName, 2)
  print("Command:")
  print(command)
  --local speed = tonumber(command)
  --setSpeed(speed)
  processCommand(command)
end

function processCommand(command)
  local speed, channel
  local parts = splitChar(command, "&")
  if (table.getn(parts) > 0) then
    local subparts = splitChar(parts[0], "=")
	if subparts[0] == "speed" then speed = subparts[1] end
	if subparts[0] == "channel" then channel = subparts[1] end

    subparts = splitChar(parts[1], "=")
	if subparts[0] == "speed" then speed = subparts[1] end
	if subparts[0] == "channel" then channel = subparts[1] end

--	print("channel, speed:")
--	print(channel)
--	print(speed)
    setSpeed(tonumber(channel), tonumber(speed))
  end
end

-- channel: 1, 2; speed: -1023 +1023
function setSpeed(channel, speed)
  local baseAddress = 1
  if speed==0 then
    pwm.setduty(baseAddress, 0)
    pwm.setduty(baseAddress + 1, 0)
  elseif speed > 0 then
    pwm.setduty(baseAddress + 1, 0)
    pwm.setduty(baseAddress, speed)
  elseif speed < 0 then
    pwm.setduty(baseAddress, 0)
    pwm.setduty(baseAddress + 1, speed * -1)
  end
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
  ----print(getFirstLine(payload))
  --print("payload:")
  --print(payload)
  --print("payload end")
  processPost(payload)
  if string.sub(payload, 0, 16) ~= "GET /favicon.ico"
  then
    conn:send(html1)
    --if state then conn:send("State: on")
    --else conn:send("State: off")
    --end
    conn:send(html2)
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

--pwm.setup(1, 500, 0)
--pwm.setup(2, 500, 0)

pwm.setup(1, 1000, 0)
pwm.setup(2, 1000, 0)

pwm.start(1)
pwm.start(2)
