wifi.setmode(wifi.SOFTAP)

html = 
[[
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RGB LED control</title>
    <script>
      function postCommand(command){
        document.getElementById('hiddenCommand').value = command;
        document.getElementById('mainForm').submit();
      }
    </script>
  </head>
  <body>
    <h1>RGB LED control</h1>
    <form method="post" id="mainForm">
        <input type="button" value="Red" onclick="postCommand('Red');">
        <input type="button" value="Green" onclick="postCommand('Green');">
        <input type="button" value="Blue" onclick="postCommand('Blue');">
        <input type="button" value="White" onclick="postCommand('White');">
        <input type="button" value="Black" onclick="postCommand('Black');">
        <input type="hidden" name="command" value="" id="hiddenCommand">
    </form>
    <table style="width: 100%; height: 50px; margin-top: 10px;">
      <tr>
        <td style="background-color: red;" onclick="postCommand('Red');">&nbsp;</td>
        <td style="background-color: green;" onclick="postCommand('Green');">&nbsp;</td>
        <td style="background-color: blue;" onclick="postCommand('Blue');">&nbsp;</td>
      </tr>
    </table>
  </body>
</html>
]]

function split(text, pattern)
    array = {}
    local index = 0
    for i in string.gmatch(text, pattern) do
      array[index] = i
      index = index + 1
    end
    return array
end

function getFileName(payload)
    local start
    local stop
    start, stop = string.find(payload,"\n")
    --print(start)
    local firstLine = string.sub(payload, 0, start)
    --print(firstLine)
    local fileName = split(firstLine, "%S+")[1]
    --print(fileName)
    return fileName
end

function getCommand(payload)
    local start
    local stop
    --print("d1")
    start, stop = string.find(payload,"\n\r")
    --print(start)
    local postData = string.sub(payload, start + 3)
    --print(postData)
    start, stop = string.find(postData,"command=")
    --print(stop)
    local command = string.sub(postData, stop + 1)
    --print(command)
    return command
end

function processCommand(command)
    local green = string.char(0,255,0)
    local red = string.char(255,0,0)
    local blue = string.char(0,0,255)
    local white = string.char(255,255,255)
    local black = string.char(0,0,0)

    local LEDCOUNT = 60

    local color

    if command == "Red" then color = red
    elseif command == "Green" then color = green
    elseif command == "Blue" then color = blue
    elseif command == "White" then color = white
    elseif command == "Black" then color = black
    else color = black end
    
    local colors = color:rep(LEDCOUNT)
    ws2812.writergb(4, colors)
end

function processPost(payload)
    if string.sub(payload, 0, 4) ~= "POST" then return end
    local fileName = getFileName(payload)
    --print("filename")
    --print(fileName)
    if fileName ~= "/" then return end
    local command = getCommand(payload)
    print(command)
    processCommand(command)
end

srv=net.createServer(net.TCP)
srv:listen(80, function(conn)
   conn:on("receive", function(conn,payload)
     --print(payload)
     processPost(payload)
     conn:send(html)
   end)
   conn:on("sent", function(conn) conn:close() end)
end)


