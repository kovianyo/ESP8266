-- LED

pin = 1
gpio.mode(pin, gpio.OUTPUT)
gpio.write(pin, gpio.HIGH)
gpio.write(pin, gpio.LOW)

-- ADC1

repeat
 value = adc.read(0)
 print(value)
 tmr.delay(100000)
until (false)

-- ADC2

function measure()
    value = adc.read(0)
    print(value)
    tmr.alarm(0, 100, 0, measure)
end

measure()

tmr.stop(0)

-- ADC3

function measure()
    local count = 100
    local i
    local values = {}
    local times = {}
    local start = tmr.now()
    for i=1,count do
        values[i] = adc.read(0)
        times[i] = tmr.now() - start
    end
    for i=1,count do
        print(times[i]/1000, values[i])
    end
end

measure()

-- DS18B20

t = require("ds18b20")
t.setup(5)

addrs = t.addrs()
if (addrs ~= nil) then
  print("Total DS18B20 sensors: "..table.getn(addrs))
end

print("Temperature: "..t.read().."'C")

-- WS2812

color = string.char(255,0,0)
colors = color:rep(10)
ws2812.writergb(2, colors)


-- Deep sleep
node.dsleep(10000000)

-- Wifi accesspoint
wifi.setmode(wifi.SOFTAP)

-- set SSID
cfg={}
cfg.ssid="ESP8266"
wifi.ap.config(cfg)

-- get DHCP client list
for mac,ip in pairs(wifi.ap.getclient()) do
    print(mac,ip)
end

-- print current ip, netmask, gateway
print(wifi.ap.getip())

-- simple web server
srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(client, payload)
        print(payload)
        client:send("hello");
        client:close();
    end)
end)

-- web server with counter
count = 0

srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(client, payload)

        count = count + 1
        print(count)

        client:send(count);
        client:close();
    end)
end)

-- webled

-- Power monitor
-- --> Fritzing
