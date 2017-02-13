print("WIFI control")
wifi.setmode(wifi.SOFTAP)
print("ESP8266 mode is: " .. wifi.getmode())
cfg={}
cfg.ssid="ESP_STATION"
cfg.pwd="the_ESP8266_WIFI_password"
if ssid and password then
print("ESP8266 SSID is: " .. cfg.ssid .. " and PASSWORD is: " .. cfg.password)
end
wifi.ap.config(cfg)
ap_mac = wifi.ap.getmac()
sv=net.createServer(net.TCP,30)
sv:listen(80,function(c)
c:on("receive", function(c, pl)
print(pl)
print(string.len(pl))
print(string.match(pl,"GET"))
ssid_start,ssid_end=string.find(pl,"SSID=")
if ssid_start and ssid_end then
amper1_start, amper1_end =string.find(pl,"&", ssid_end+1)
if amper1_start and amper1_end then
http_start, http_end =string.find(pl,"HTTP/1.1", ssid_end+1)
if http_start and http_end then
if http_start and http_end then
ssid=string.sub(pl,ssid_end+1, amper1_start-1)
password=string.sub(pl,amper1_end+10, http_start-2)
print("ESP8266 connecting to SSID: " .. ssid .. " with PASSWORD: " .. password)
if ssid and password then
sv:close()
wifi.setmode(wifi.STATIONAP)
print("ESP8266 mode now is: " .. wifi.getmode())
wifi.sta.config(ssid,password)
print("Setting up ESP8266 for station mode…Please wait.")
tmr.delay(10000000)
print("ESP8266 STATION IP now is: " .. wifi.sta.getip())
print("ESP8266 AP IP now is: " .. wifi.ap.getip())
gpio.mode(8,gpio.OUTPUT)
gpio.mode(9,gpio.OUTPUT)
tmr.delay(10)
gpio.write(8,gpio.HIGH)
tmr.delay(10)
gpio.write(8,gpio.LOW)
sv=net.createServer(net.TCP, 30)
sv:listen(9999,function(c)
c:on("receive", function(c, pl)
if tonumber(pl) ~= nil then
if tonumber(pl) >= 1 and tonumber(pl) <= 16 then
print(tonumber(pl))
tmr.delay(10)
gpio.write(8,gpio.HIGH)
tmr.delay(10)
gpio.write(8,gpio.LOW)
for count =1,tonumber(pl) do
 print(count)
tmr.delay(10)
 gpio.write(9,gpio.LOW)
tmr.delay(10)
gpio.write(9,gpio.HIGH)
c:send("Sequence finished")
end
end
end
print("ESP8266 STATION IP now is: " .. new_ip)
c:send("ESP8266 STATION IP now is: " .. new_ip)
c:send("Action completed")
end)
end)
end
end
end
end
c:send(" ")print("WIFI control")
wifi.setmode(wifi.SOFTAP)
print("ESP8266 mode is: " .. wifi.getmode())
cfg={}
cfg.ssid="ESP_STATION"
cfg.pwd="the_ESP8266_WIFI_password"
if ssid and password then
  print("ESP8266 SSID is: " .. cfg.ssid .. " and PASSWORD is: " .. cfg.password)
end
wifi.ap.config(cfg)
ap_mac = wifi.ap.getmac()
sv=net.createServer(net.TCP,30)
sv:listen(80,function(c)
    c:on("receive", function(c, pl)
        print(pl)
        print(string.len(pl))
        print(string.match(pl,"GET"))
        ssid_start,ssid_end=string.find(pl,"SSID=")
        if ssid_start and ssid_end then
          amper1_start, amper1_end =string.find(pl,"&", ssid_end+1)
          if amper1_start and amper1_end then
            http_start, http_end =string.find(pl,"HTTP/1.1", ssid_end+1)
            if http_start and http_end then
              if http_start and http_end then
                ssid=string.sub(pl,ssid_end+1, amper1_start-1)
                password=string.sub(pl,amper1_end+10, http_start-2)
                print("ESP8266 connecting to SSID: " .. ssid .. " with PASSWORD: " .. password)
                if ssid and password then
                  sv:close()
                  wifi.setmode(wifi.STATIONAP)
                  print("ESP8266 mode now is: " .. wifi.getmode())
                  wifi.sta.config(ssid,password)
                  print("Setting up ESP8266 for station mode…Please wait.")
                  tmr.delay(10000000)
                  print("ESP8266 STATION IP now is: " .. wifi.sta.getip())
                  print("ESP8266 AP IP now is: " .. wifi.ap.getip())
                  gpio.mode(8,gpio.OUTPUT)
                  gpio.mode(9,gpio.OUTPUT)
                  tmr.delay(10)
                  gpio.write(8,gpio.HIGH)
                  tmr.delay(10)
                  gpio.write(8,gpio.LOW)
                  sv=net.createServer(net.TCP, 30)
                  sv:listen(9999,function(c)
                      c:on("receive", function(c, pl)
                          if tonumber(pl) ~= nil then
                            if tonumber(pl) >= 1 and tonumber(pl) <= 16 then
                              print(tonumber(pl))
                              tmr.delay(10)
                              gpio.write(8,gpio.HIGH)
                              tmr.delay(10)
                              gpio.write(8,gpio.LOW)
                              for count =1,tonumber(pl) do
                                print(count)
                                tmr.delay(10)
                                gpio.write(9,gpio.LOW)
                                tmr.delay(10)
                                gpio.write(9,gpio.HIGH)
                                c:send("Sequence finished")
                              end
                            end
                          end
                          print("ESP8266 STATION IP now is: " .. new_ip)
                          c:send("ESP8266 STATION IP now is: " .. new_ip)
                          c:send("Action completed")
                        end)
                    end)
                end
              end
            end
          end
          c:send(" ")
          c:send(" ")
          c:send(" ")
          c:send("ESP8266 Wireless control setup")
          mac_mess1 = "The module MAC address is: " .. ap_mac
          mac_mess2 = "You will need this MAC address to find the IP address of the module, please take note of it."
          c:send("" .. mac_mess1 .. "")
          c:send("" .. mac_mess2 .. "")
          c:send("Enter SSID and Password for your WIFI router")
          c:send("
            ")
          c:send("
            ")
          c:send("SSID:")
          c:send("")
          c:send("
            ")
          c:send("Password:")
          c:send("")
          c:send("")
        end)
    end)

c:send(" ")
c:send(" ")
c:send("ESP8266 Wireless control setup")
mac_mess1 = "The module MAC address is: " .. ap_mac
mac_mess2 = "You will need this MAC address to find the IP address of the module, please take note of it."
c:send("" .. mac_mess1 .. "")
c:send("" .. mac_mess2 .. "")
c:send("Enter SSID and Password for your WIFI router")
c:send("
")
c:send("
")
c:send("SSID:")
c:send("")
c:send("
")
c:send("Password:")
c:send("")
c:send("")
end)
end)
