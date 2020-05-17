local function getHumidity()
  log("Reading humidity...")

  local time = tmr.now()
  local H, T = bme280.humi()

  local H2 = bme280.humi()

  log("Humidity reading elapsed us: " .. tmr.now() - time)

  local filteredHumidity = math.max(H, H2) -- filter out negative errors (zeros)
  return filteredHumidity / 1000 
end

local function getTemperature()
  local H, T = bme280.humi()
  return T / 100
end

local function getAirPressure()
  local P, T = bme280.baro()
  return P / 10
end

actions = {
  { "humidity", getHumidity },
  { "temperature", getTemperature },
  { "airpressure", getAirPressure },
}
