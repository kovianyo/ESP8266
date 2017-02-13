wifi.setmode(wifi.SOFTAP)

html = 
[[<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>RGB LED control</title>
  </head>
  <body>
    <h1>RGB LED control</h1>
    <form method="post">
        <input type="submit" name="command" value="Red">
        <input type="submit" name="command" value="Green">
        <input type="submit" name="command" value="Blue">
        <input type="submit" name="command" value="White">
        <input type="submit" name="command" value="Black">
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


