local blinker = dofile("blinker.lua")
blinker.setLevel(0)

local function onConnected()
  blinker.setLevel(1)
end

local function onGotIP()
  blinker.setLevel(3)
  local webserver = dofile("webserver.lua")
  webserver.setup()
end

local function onDisconneted()
  blinker.setLevel(0)
end

loadfile("initWifi.lua")(onConnected, onGotIP, onDisconneted)
