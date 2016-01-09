i = 0
colorindex = 0

-- Three colors rotating
pattern = function()
  local color
  if colorindex == 0 then color = green
  elseif colorindex == 1 then color = red
  elseif colorindex == 2 then color = blue
  end

  local colors = color:rep(i)
  writeColors(colors)
  i=i+1
  if i>LEDCOUNT then
    i=0
    colorindex = colorindex + 1
    if colorindex > 2 then colorindex = 0 end
  end
  tmr.alarm(LEDTIMER, 100, 1, pattern)
end

pattern()
