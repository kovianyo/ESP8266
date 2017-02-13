function processRequest(payload)
  local currentAction = getAction(payload)

  local result = getResult(currentAction)

  if result == nil then
    result = getResult("")
  end

  if result == nil then
    result = "No method to proces '" .. currentAction .. "'"
  end

  return result
end

function getResult(currentAction)
  for index, action in ipairs(actions) do
    if action[1] == currentAction then
      --print("action[2]")
      --print(action[2])
      local result = action[2]()
      return result
    end
  end

  return nil
end

function getAction(payload)
  local firstLine = getFirstLine(payload)

   print("Processing", firstLine)

  local parts = split(firstLine, "%S+")

  if (table.getn(parts) > 0) then
    local request = parts[1]

    if string.len(request) > 1 then
      local fileName = string.sub(request, 2)
      return fileName
    else
      return ""
    end
  end

  return nil
end
