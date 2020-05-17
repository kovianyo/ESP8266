print("Connecting to AccessPoint...")
local station_cfg = {}
station_cfg.ssid = "Kovi OnePlus2"
station_cfg.pwd = "87654321"
wifi.sta.config(station_cfg)
wifi.sta.sethostname("KoviAirSensor")
wifi.sta.connect()

local blinker = dofile("blinker.lua")
blinker.setLevel(0)


wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
 print("wifi event: Station - CONNECTED. SSID: "..T.SSID..", BSSID: ".. T.BSSID..", Channel: "..T.channel)
 blinker.setLevel(1)
end)

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
 print("wifi event: Station - GOT IP. Station IP: "..T.IP..", Subnet mask: ".. T.netmask..", Gateway IP: "..T.gateway)
 blinker.setLevel(3)
end)

wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
 print("wifi event: Station - DISCONNECTED, SSID: "..T.SSID..", BSSID: ".. T.BSSID..", reason: "..T.reason)
 blinker.setLevel(0)
end)
