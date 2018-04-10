wifiStatus = wifi.sta.status()

print(wifiStatus)

if wifiStatus == wifi.STA_IDLE then print("IDLE")
elseif wifiStatus == wifi.STA_CONNECTING then print("CONNECTING")
elseif wifiStatus == wifi.STA_WRONGPWD then print("WRONGPWD")
elseif wifiStatus == wifi.STA_APNOTFOUND then print("APNOTFOUND")
elseif wifiStatus == wifi.STA_FAIL then print("FAIL")
elseif wifiStatus == wifi.STA_GOTIP then print("GOTIP")
else print("none")
end


wifi.sta.sethostname("humi")
print("Current hostname is: \""..wifi.sta.gethostname().."\"")

udpSocket = net.createUDPSocket()
udpSocket:listen(5000)
udpSocket:on("receive", function(s, data, port, ip)
    print(string.format("received '%s' from %s:%d", data, ip, port))
    s:send(port, ip, "echo: " .. data)
end)
port, ip = udpSocket:getaddr()
print(string.format("local UDP socket address / port: %s:%d", ip, port))
