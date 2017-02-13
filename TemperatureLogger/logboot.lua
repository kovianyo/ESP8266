function writeBootCount(fileName, count)
  file.open(fileName,"w+")
  local countStr = tostring(count)
  file.write(countStr)
  file.close()
end

function logboot()
  fileName = "bootcount.txt"

  if file.open(fileName,"r") == nil then
      writeBootCount(fileName, 0)
  end

  file.open(fileName,"r")
  count = tonumber(file.read())
  file.close()

  print("Increasing boot count to " .. count .. "...")

  writeBootCount(fileName, count + 1)
end

function printBootCount()
  fileName = "bootcount.txt"

  file.open(fileName,"r")
  count = tonumber(file.read())
  file.close()

  print(count)
end

logboot()
