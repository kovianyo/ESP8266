local _actions = nil

local function getRequest(payload)
  local firstLine = Utils.GetFirstLine(payload)
  local trimmedFirstLine = string.gsub(firstLine, '^%s*(.-)%s*$', '%1') -- trim starting and trailing spaces and newlines

  Utils.Log("Processing '" .. trimmedFirstLine .. "'")

  local parts = Utils.Split(firstLine, "%S+")

  if (table.getn(parts) < 2) then
    Utils.Log("HTTP header malformed")
    return nil
  end

  local request = {
    verb = parts[0],
    path = parts[1],
    protocol = parts[2]
  }

  return request
end

local function getAction(payload)
  local request = getRequest(payload)

  if (request == nil) then
    return nil
  end

  local path = request.path

  if (string.len(path) < 2) then
    return nil
  end

  local actionName =  string.sub(path, 2) -- trim first character, the "/"

  return actionName
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

local function process(payload)
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
  process = process,
  setActions = setActions
}
