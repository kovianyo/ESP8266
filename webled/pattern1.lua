i = 0

-- Two colors rounding simple with restat
function pattern1()
  local colors = green:rep(i) .. red:rep(LEDCOUNT - i)
  writeColors(colors)
  i=i+1
  if i>LEDCOUNT then i=0 end
  tmr.alarm(LEDTIMER, 20, 0, pattern1)
end
