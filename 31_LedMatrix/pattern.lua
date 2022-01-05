ws2812.init()

LEDCOUNT = 64

start = 0

array = {}

for i = 0, LEDCOUNT, 1 do
    local r, g, b = HSL(i/LEDCOUNT*360, 1, 0.1)
    local color = string.char(r,g,b)
    array[i] = color;
end


writePattern = function()

    local j = 0
    local colors = ""

    for j = 0, LEDCOUNT, 1 do
        colors = colors .. array[(start + j) % #array]
    end

    ws2812.write(colors)

    start = start + 1

    if start > LEDCOUNT then start = 0 end

end


mytimer = tmr.create()
mytimer:register(100, tmr.ALARM_AUTO, writePattern)
mytimer:start()
