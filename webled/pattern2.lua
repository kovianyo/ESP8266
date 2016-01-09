i = 0

-- Two colors rotating
pattern = function()
  local color1 = red
  local color2 = green

  local colors
  if i<LEDCOUNT/2 then
    colors = color1:rep(i) .. color2:rep(LEDCOUNT/2) .. color1:rep(LEDCOUNT/2 - i)
  else
    colors = color2:rep(i - LEDCOUNT/2) .. color1:rep(LEDCOUNT/2) .. color2:rep(LEDCOUNT - i)
  end
  writeColors(colors)
  i=i+1
  if i>LEDCOUNT then i=0 end

  tmr.alarm(LEDTIMER, 100, 0, pattern)
end

pattern()
