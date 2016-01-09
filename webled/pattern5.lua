i = 0

dofileifexists("HSL.lua")

-- Hue transition constant
pattern = function()
  local r
  local g
  local b
  r, g, b = HSL(i/LEDCOUNT*360, 1, 0.1)

  local color = string.char(r,g,b)

  local colors = color:rep(60)
  writeColors(colors)
  i=i+1
  if i>LEDCOUNT then i=0 end
  tmr.alarm(LEDTIMER, 100, 0, pattern)
end

pattern()
