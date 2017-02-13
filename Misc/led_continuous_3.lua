sat = 255
green = string.char(0,sat,0)
red = string.char(sat,0,0)
blue = string.char(0,0,sat)

tmr.stop(0)

LEDCOUNT = 60
i = 0
colorindex = 0

function setcolor()
    if colorindex == 0 then color = green 
    elseif colorindex == 1 then color = red 
    elseif colorindex == 2 then color = blue 
    end
    
    colors = color:rep(i)
    ws2812.writergb(4, colors)
    i=i+1
    if i>LEDCOUNT then 
        i=0 
        colorindex = colorindex + 1
        if colorindex>2 then 
        colorindex = 0
        end
    end
end

tmr.alarm(0, 100, 1, setcolor)


