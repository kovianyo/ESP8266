wifi.setmode(wifi.STATION)
wifi.sta.config("KoviNet", "")
wifi.sta.connect()
--print(wifi.sta.getip())

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


-- setup adress
--uart.write(0, getcommand(0xB4))
