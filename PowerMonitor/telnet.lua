wifi.setmode(wifi.STATION)
wifi.sta.config("KoviNet", "")
wifi.sta.connect()
--print(wifi.sta.getip())

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

    adress = string.char(0xC0) .. string.char(0xA8) .. string.char(0x01) .. string.char(0x01)


    function sum(a)
        local sum = 0
        for i=1,string.len(a) do
            local char = string.sub(a,i,i)
            local num = string.byte(char)
            sum = sum + num
        end
        return sum
    end

    function getcommand(commandType)
        local command = string.char(commandType) .. adress .. string.char(0x00)
        local checksum = sum(command) % 256
        command = command .. string.char(checksum)
        return command
    end


    function gethex(text)
        local plain = ""
        for i=1,string.len(text) do
            char = string.sub(text,i,i)
            num = string.byte(char)
            plain = plain .. string.format("%X",num) .. " "
        end

        return plain
    end


    function getnum(text)
        local plain = ""
        for i=1,string.len(text) do
            char = string.sub(text,i,i)
            num = string.byte(char)
            plain = plain .. num .. " "
        end

        return plain
    end



    gpio.mode(1, gpio.OUTPUT)
    gpio.write(1, gpio.HIGH)

    ----------------------------------------------------------------------

    gpio.mode(2, gpio.OUTPUT)
    gpio.write(2, gpio.HIGH)

    state = false
    function blink()
      if state then gpio.write(2, gpio.HIGH)
      else gpio.write(2, gpio.LOW) end
      state = not state
      tmr.alarm(0, 1000, 0, blink)
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
      process(payload)
      --conn:send("abc")
      --tmr.stop(LEDTIMER)
      --processPost(payload)
      --if string.sub(payload, 0, 16) ~= "GET /favicon.ico"
      --then
      --  sendFile(conn, "index.html")
      --else
      --  conn:send("HTTP/1.1 404 file not found")
      --end
     end)
     conn:on("sent", function(conn)
      connection = nil
      conn:close()
     end)
    end)


    function process(text)
        if startsWith(text, "GET /voltage")
        then uart.write(0, getcommand(0xB0)) end
    end


    function startsWith(String,Start)
       return string.sub(String,1,string.len(Start))==Start
    end

    function getvoltage(data)
      return (numat(data, 1) * 256 + numat(data, 2)) * 10 + numat(data, 3)
    end

    function numat(text, i)
        local char = string.sub(text,i+1,i+1)
        local num = string.byte(char)
        return num
    end

    uart.on("data", 7, function(data) if connection ~= nil then connection:send(getvoltage(data)) end end, 0)




-- setup adress
uart.write(0, getcommand(0xB4))
