function init(sda,scl) --Set up the u8glib lib
     local sla = 0x3C
     i2c.setup(0, sda, scl, i2c.SLOW)
     local disp = u8g.ssd1306_128x64_i2c(sla)
     disp:setFont(u8g.font_6x10)
     disp:setFontRefHeightExtendedText()
     disp:setDefaultForegroundColor()
     disp:setFontPosTop()
     disp:setRot180()           -- Rotate Display if needed
     return disp
end

function drawPages(disp, draw)
   local startTime = tmr.now()
   disp:firstPage()
   local i = 0
   repeat
     draw(disp)
     --disp:drawStr(x, y, str)
     --print(i)
     i = i + 1
   until disp:nextPage() == false
   local endTime = tmr.now()
   print("elapsed: " .. (endTime - startTime))
end

sda = 2
scl = 1
disp = init(sda,scl)

function draw(disp)
    --disp:drawStr(0, 0, "ABCDE")
    for i=1,64 do
        disp:drawPixel(i, i)
        disp:drawPixel(128-i, i)
    end
end

drawPages(disp, draw)
