LEDCOUNT = 60

LEDTIMER = 0

green = string.char(0,255,0)
red = string.char(255,0,0)
blue = string.char(0,0,255)
white = string.char(255,255,255)
black = string.char(0,0,0)

function writeColors(colors)
  ws2812.writergb(4, colors)
end

writeColors(black:rep(LEDCOUNT))
