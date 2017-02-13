t = require("ds18b20")

-- ESP-01 GPIO Mapping
gpio0 = 3
--gpio2 = 4

t.setup(gpio0)
addrs = t.addrs()
if (addrs ~= nil) then
  print("Total DS18B20 sensors: "..table.getn(addrs))
end

-- Just read temperature
print("Temperature: "..t.read().."'C")

-- Don't forget to release it after use
t = nil
ds18b20 = nil
package.loaded["ds18b20"]=nil


----------------------------------------------------------------

print(type(addrs[1]))
print(addrs[1])

addr = addrs[1]

for i = 1, #addr do
    c = addr:sub(i,i)
    print(string.byte(c))
end
