local _actions = nil

local function getAction(payload)
  local firstLine = Utils.GetFirstLine(payload)

  Utils.Log("Processing '" .. string.gsub(firstLine, '^%s*(.-)%s*$', '%1') .. "'") -- trim starting and trailing spaces and newlines

  local parts = Utils.Split(firstLine, "%S+")

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

-- retunrs the processed result and true, if could be processed, or the fileName and false, if could not be processed
local function getResult(currentAction)
  for index, action in ipairs(_actions) do
    if action[1] == currentAction then
      --print("action[2]")
      --print(action[2])
      local result = action[2]()
      return result
    end
  end

  return nil
end

local function processRequest(payload)
  local currentAction = getAction(payload)

  if (currentAction == nil) then
    return nil
  end

  local result = getResult(currentAction)

  return result
end


local function setActions(actions)
  _actions = actions
end

return {
  process = processRequest,
  setActions = setActions
}
