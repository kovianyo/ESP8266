print("Starting up...")
print("")

collectgarbage()
dofile("utils.lua")
dofile("bme280init.lua")
dofile("actions.lua")
dofile("processRequest.lua")
dofile("wifiFileConnect.lua")
dofile("webserver.lua")
