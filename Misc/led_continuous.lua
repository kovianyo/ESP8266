sat = 255
green = string.char(0,sat,0)
red = string.char(sat,0,0)
blue = string.char(0,0,sat)

LEDCOUNT = 60
i = 0
function setcolor()
if i<LEDCOUNT/2 then 
color = red:rep(i) .. green:rep(LEDCOUNT/2) .. red:rep(LEDCOUNT/2 - i)
else
color = green:rep(i - LEDCOUNT/2) .. red:rep(LEDCOUNT/2) .. green:rep(LEDCOUNT - i)
end
ws2812.writergb(4, color)
i=i+1
if i>LEDCOUNT then i=0 end
end

tmr.alarm(0, 100, 1, setcolor)


