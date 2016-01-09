start = 0

-- tricolor
pattern = function()
  local triplets = {}
  triplets[0] = red .. green .. blue
  triplets[1] = green .. blue .. red
  triplets[2] = blue .. red .. green

  local color = triplets[start % #triplets]:rep(LEDCOUNT / 3)
  writeColors(color)

  start = start + 1
  if start > #triplets then start = 0 end
  tmr.alarm(LEDTIMER, 200, 0, pattern)
end

pattern()
