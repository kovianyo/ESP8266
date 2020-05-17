local blinker = dofile("blinker.lua")
blinker.setLevel(0)

local function onConnected()
  blinker.setLevel(1)
end

local function onGotIP()
  blinker.setLevel(3)

  local actions = dofile("actions.lua")
  local requestProcessor = dofile("processRequest.lua")
  requestProcessor.setActions(actions)
  local webserver = dofile("webserver.lua")
  webserver.setup(requestProcessor.process)
end

local function onDisconneted()
  blinker.setLevel(0)
end

loadfile("initWifi.lua")(onConnected, onGotIP, onDisconneted)
