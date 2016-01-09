start = 0

dofileifexists("HSL.lua")

-- Hue rotation with array
pattern = function()
  local colors = ""
  local i = 0
  repeat
    local r
    local g
    local b
    r, g, b = HSL((start + i)/LEDCOUNT*360, 1, 0.1)
    local color = string.char(r,g,b)
    colors = colors .. color
    i=i+1
  until(i>LEDCOUNT)

  writeColors(colors)
  start = start + 1
  if start > LEDCOUNT then start = 0 end

  tmr.alarm(LEDTIMER, 100, 0, pattern)
end

pattern()
