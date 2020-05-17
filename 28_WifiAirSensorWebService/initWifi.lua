local onConnected, onGotIP, onDisconneted = ...

wifi.setphymode(wifi.PHYMODE_N)
wifi.setmode(wifi.STATION)

wifi.sta.sethostname("KoviAirSensor")

wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
 print("wifi event: Station - CONNECTED. SSID: "..T.SSID..", BSSID: ".. T.BSSID..", Channel: "..T.channel)
 if onConnected ~= nil then onConnected() end
end)

wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
 print("wifi event: Station - GOT IP. Station IP: "..T.IP..", Subnet mask: ".. T.netmask..", Gateway IP: "..T.gateway)
 print(" dns server: " .. net.dns.getdnsserver(0))
 if onGotIP ~= nil then onGotIP() end
end)

wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
 print("wifi event: Station - DISCONNECTED, SSID: "..T.SSID..", BSSID: ".. T.BSSID..", reason: "..T.reason)
 if onDisconneted ~= nil then onDisconneted() end
end)
