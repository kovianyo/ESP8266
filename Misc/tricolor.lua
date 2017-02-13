green = string.char(0,255,0)
red = string.char(255,0,0)
blue = string.char(0,0,255)
white = string.char(255,255,255)
black = string.char(0,0,0)

LEDCOUNT = 60

triplets = {}
triplets[0] = red .. green .. blue
triplets[1] = green .. blue .. red
triplets[2] = blue .. red .. green

start = 0

tmr.stop(0)

function setcolor()
    local color = triplets[start]:rep(LEDCOUNT / 3)
    ws2812.writergb(4, color)
    
    start = start + 1
    if start > #triplets then start = 0 end
    tmr.alarm(0, 200, 0, setcolor)
end

setcolor()

