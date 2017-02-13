green = string.char(0,255,0)
red = string.char(255,0,0)
blue = string.char(0,0,255)
white = string.char(255,255,255)
black = string.char(0,0,0)

LEDCOUNT = 60
i = 0
repeat
    color = green:rep(i) .. red:rep(LEDCOUNT - i)
    ws2812.writergb(4, color)
    i=i+1
    if i>LEDCOUNT then i=0 end
    tmr.delay(1000*10)
until(false)
