-- Wifi accesspoint
wifi.setmode(wifi.SOFTAP)

-- set SSID
cfg={}
cfg.ssid="ESP8266"
wifi.ap.config(cfg)

-- print current ip, netmask, gateway
print(wifi.ap.getip())

-- web server with counter
count = 0

srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(client, payload)
        client:send("uptime: " .. tmr.now()/1000000 .. " sec");
        client:close();
    end)
end)

