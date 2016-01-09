dofileifexists("HSL.lua")

function getColors(count)
    local array = {}
    local r
    local g
    local b

    for i = 0, count, 1 do
        r, g, b = HSL(i/count*360, 1, 0.1)
        local color = string.char(r,g,b)
        array[i] = color;
    end

    return array
end

start = 0
pattern6array = getColors(LEDCOUNT)

-- Hue rotation with array
pattern = function()
  local j = 0
  local colors = ""
  for j = 0, LEDCOUNT, 1 do
    colors = colors .. pattern6array[(start + j) % #pattern6array]
  end

  writeColors(colors)

  start = start + 1
  if start > LEDCOUNT then start = 0 end
  tmr.alarm(LEDTIMER, 100, 0, pattern)
end

pattern()
