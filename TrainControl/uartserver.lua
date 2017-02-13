function dumpString(s)
  return string.byte(s, 1, string.len(s))
end

-- remove first two character if CRLF
function trimStart(s)
  if string.byte(s, 1, 1) == 13 and string.byte(s, 2, 2) == 10 then
   return string.sub(s, 3)
  end

  return s
end

-- remove last character
function trimEnd(s)
  return string.sub(s, 1, -2)
end

-- receive speed on uart, like 200t or -200t
uart.on("data", "t",
  function(data)
    --print("receive from uart:")
    data = trimStart(data)
    local speedString = trimEnd(data)
    setSpeedString(speedString)
    if data=="quit" then
      uart.on("data") -- unregister callback function
    end
end, 0)
