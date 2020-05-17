local _actions = nil


local function getAction(path)
  local actionName =  string.sub(path, 2) -- trim first character, the "/"

  return actionName
end

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

local function process(path)
  local currentAction = getAction(path)

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
