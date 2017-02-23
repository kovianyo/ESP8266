function processRequest(payload)
  local currentAction = getAction(payload)

  local result, processed = getResult(currentAction)

  return result, processed
end

-- retunrs the processed result and true, if could be processed, or the fileName and false, if could not be processed
function getResult(currentAction)
  for index, action in ipairs(actions) do
    if action[1] == currentAction then
      --print("action[2]")
      --print(action[2])
      local result = action[2]()
      return result, true
    end
  end

  return currentAction, false
end

function getAction(payload)
  local firstLine = getFirstLine(payload)

   log("")
   log("Processing", firstLine)

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
