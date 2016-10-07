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
    <script type="text/javascript">
    function send(url) {
        var xmlhttp = new XMLHttpRequest();
        xmlhttp.open("post", url, true);
        xmlhttp.send();
    }
    </script>
  </head>
  <body>
    <h1>TrainControl</h1>
]]

html2 =
[[
    <form>
       speed (+/- 1023): <input type="text" name="speed" id="speed" value="0" size="5">
        <input type="button" value="set" onclick="send(document.getElementById('speed').value);">
        <br />
        <input type="button" value="stop" onclick="send(0);">
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
  if string.sub(payload, 0, 4) ~= "POST" then return false end
  local fileName = getFileName(payload)
  print("filename")
  print(fileName)
  --if fileName ~= "/" then return end
  local command = string.sub(fileName, 2)
  print("Command:")
  print(command)
  local speed = tonumber(command)
  setSpeed(speed)
  --processCommand(command)
  return true
end

function setSpeed(speed)
  if speed==0 then
    pwm.setduty(1, 0)
    pwm.setduty(2, 0)
  elseif speed > 0 then
    pwm.setduty(2, 0)
    pwm.setduty(1, speed)
  elseif speed < 0 then
    pwm.setduty(1, 0)
    pwm.setduty(2, speed * -1)
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
  if not processPost(payload) then
    conn:send(html1)
    conn:send(html2)
  end
 end)
 conn:on("sent", function(conn)
  conn:close()
 end)
end)

print("Listening...")
print("")

pwm.setup(1, 500, 0)
pwm.setup(2, 500, 0)

pwm.start(1)
pwm.start(2)
