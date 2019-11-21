local function measure(client)
  local H, T = bme280.humi()
  local P, T = bme280.baro()

  local temperature = T / 100
  local airPressure = P / 10000
  local humidity = H / 1000

  print("Temperature: " .. temperature .. " C, air pressure: " .. airPressure .. " kPa, humidity: " .. humidity .. " %")

  client:publish("temperature", temperature, 0, 0--[[, function(client) print("sent") end--]])
  client:publish("airpressure", airPressure, 0, 0)
  client:publish("humidity", humidity, 0, 0)
end

return measure
