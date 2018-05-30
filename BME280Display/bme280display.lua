wifi.setmode(wifi.NULLMODE) -- disable wifi

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

print(bme280.setup()) -- "2" is BME280

function draw(disp)
    local H, T = bme280.humi()
    local P, T = bme280.baro()

    local temperature = "Temperature: " .. T/100 .. string.char(176) .. "C"
    local humidity = "Humidity: " .. string.format("%d", H/1000) .. "%"
    local airpressure = " ".. string.format("%.3f", P/10000) .. " kPa"

    local battery = "Battery: " .. string.format("%d",(adc.read(0) * 0.00288 * 5.6 - 2.5)/5.9*100) .."%"

   disp:drawStr(0, 00, temperature)
   disp:drawStr(0, 10, humidity)
   disp:drawStr(0, 20, "Air pressure:")
   disp:drawStr(0, 30, airpressure)
   disp:drawStr(0, 40, "Uptime: " .. tmr.time() .. "s")
   disp:drawStr(0, 50, battery)
end


-- drawPages(disp, draw)

mytimer = tmr.create()

mytimer:register(1000, tmr.ALARM_AUTO, function (t) drawPages(disp, draw);  end)
mytimer:start()
