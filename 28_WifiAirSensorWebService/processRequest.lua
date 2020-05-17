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

local function getIndex()
  local html = '<!DOCTYPE html>\n<head>\n<title>Kovi AirSensor</title>\n<link rel="icon" href="data:;base64,iVBORw0KGgo=">\n</head>'
  html = html .. '\n<body>\n<h1>Kovi AirSensor</h1>\n<ul>\n'
  for index, action in ipairs(_actions) do
    local actionName = action[1]
    html = html .. "<li><a href='/" .. actionName .."'>" .. actionName .. "</li>\n"
  end
  html = html .. "</ul>\n</body>\n</html>"
  return html
end

local function process(request)
  if (request.path == "/") then
    local html = getIndex()
    return html
  end

  local currentAction = getAction(request.path)

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
