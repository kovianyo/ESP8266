dolog = true

function getFirstLine(text)
  local start, stop = string.find(text, "\n")
  --print(start)
  local firstLine = string.sub(text, 0, start)
  --print(firstLine)
  return firstLine
end

-- "%S+"
function split(text, pattern)
  local array = {}
  local index = 0
  for i in string.gmatch(text, pattern) do
    array[index] = i
    index = index + 1
  end
  return array
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function log(...)
  if dolog then print(...) end
end
