-- PZEM-004

wifi.setmode(wifi.STATION)
wifi.sta.config("KoviNet", "")
wifi.sta.connect()
wifi.sta.sethostname("KoviPowerMonitor")
--print(wifi.sta.getip())

-- 192.168.1.1
adress = string.char(0xC0) .. string.char(0xA8) .. string.char(0x01) .. string.char(0x01)

-- calculate checksum for the command
function sum(a)
    local sum = 0
    for i=1,string.len(a) do
        local char = string.sub(a,i,i)
        local num = string.byte(char)
        sum = sum + num
    end
    return sum
end

-- append the address and checksum to the commandType
function getcommand(commandType)
    local command = string.char(commandType) .. adress .. string.char(0x00)
    local checksum = sum(command) % 256
    command = command .. string.char(checksum)
    return command
end

-- get hexadecimal representation of the string
function gethex(text)
    local plain = ""
    for i=1,string.len(text) do
        char = string.sub(text,i,i)
        num = string.byte(char)
        plain = plain .. string.format("%X",num) .. " "
    end

    return plain
end

-- gent numeric reperesentation of the string
function getnum(text)
    local plain = ""
    for i=1,string.len(text) do
        char = string.sub(text,i,i)
        num = string.byte(char)
        plain = plain .. num .. " "
    end

    return plain
end

-- turn on led at GPIO5
gpio.mode(1, gpio.OUTPUT)
gpio.write(1, gpio.HIGH)

----------------------------------------------------------------------

-- blink led at GPIO4
gpio.mode(2, gpio.OUTPUT)
gpio.write(2, gpio.HIGH)

state = false
function blink()
  if state then gpio.write(2, gpio.HIGH)
  else gpio.write(2, gpio.LOW) end
  state = not state
  tmr.alarm(0, 500, 0, blink)
end

blink()

----------------------------------------------------------------------

connection = nil

srv=net.createServer(net.TCP)
srv:listen(80, function(conn)
 conn:on("receive", function(conn,payload)
  --print(getFirstLine(payload))
  --print(payload)
  connection = conn
  processHttpRequest(payload)
 end)
 conn:on("sent", function(conn)
  connection = nil
  conn:close()
 end)
end)

--[[
s=net.createServer(net.TCP,180)
s:listen(2323,function(c)
   function s_output(str)
      if(c~=nil)
         then c:send(str)
      end
   end
   node.output(s_output, 0)   -- re-direct output to function s_ouput.
   c:on("receive",function(c,l)
      node.input(l)           -- works like pcall(loadstring(l)) but support multiple separate line
   end)
   c:on("disconnection",function(c)
      node.output(nil)        -- un-regist the redirect output function, output goes to serial
   end)
   print("Welcome to NodeMcu world.")
end)
--]]

function sendFile(connection, fileName)
  file.open(fileName, "r")
  repeat
    local line = file.readline()
    if line ~= nil then connection:send(line) end
  until (line == nil)
  file.close()
end

-- PZEM-004 connected
isConnected = false

-- what is requested (voltage, current, power, energy)
requested = nil

function processHttpRequest(text)
    if startsWith(text, "GET / ")
    then
      sendFile(connection, "index.html")
      return
    end
    if startsWith(text, "GET /status")
    then
      if isConnected then connection:send("connected") else connection:send("not connected") end
      return
    end

    if not isConnected then
      connection:send("not connected")
      return
    end

    if startsWith(text, "GET /voltage")
    then
      requested = 1
      uart.write(0, getcommand(0xB0))
    end

    if startsWith(text, "GET /current")
    then
      requested = 2
      uart.write(0, getcommand(0xB1))
    end

    if startsWith(text, "GET /power")
    then
      requested = 3
      uart.write(0, getcommand(0xB2))
    end

    if startsWith(text, "GET /energy")
    then
      requested = 4
      uart.write(0, getcommand(0xB3))
    end
end


function startsWith(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

-- numeric value of the char from the given string at given position
function numat(text, i)
    local char = string.sub(text,i+1,i+1)
    local num = string.byte(char)
    return num
end

function getvoltage(data)
  return (numat(data, 1) * 256 + numat(data, 2)) * 10 + numat(data, 3)
end

function getcurrent(data)
  return (numat(data, 1) * 256 + numat(data, 2))*100 + numat(data, 3)
end

function getpower(data)
  return numat(data, 1) * 256 + numat(data, 2)
end

function getenergy(data)
  return numat(data, 1) * 256 * 256 + numat(data, 2) * 256  + numat(data, 3)
end

function processMeasurement(data)
  if requested == 1 then connection:send(getvoltage(data)) end
  if requested == 2 then connection:send(getcurrent(data)) end
  if requested == 3 then connection:send(getpower(data)) end
  if requested == 4 then connection:send(getenergy(data)) end
end

function processUartResponse(data)
  if not isConnected and data == string.char(0xA4) .. string.char(0x00) .. string.char(0x00) .. string.char(0x00) .. string.char(0x00) .. string.char(0x00) .. string.char(0xA4) then
    isConnected = true
  elseif connection ~= nil then processMeasurement(data) end
end

uart.on("data", 7, processUartResponse, 0)


-- setup adress
uart.write(0, getcommand(0xB4))
