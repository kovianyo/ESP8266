local function getHumidity()
  log("Reading humidity...")

  local time = tmr.now()
  local H, T = bme280.humi()

  local H2 = bme280.humi()

  log("Humidity reading elapsed us: " .. tmr.now() - time)

  return math.max(H, H2) -- filter out negative errors (zeros)
end

local function getTemperature()
  local H, T = bme280.humi()
  return T
end

local function getAirPressure()
  local P, T = bme280.baro()
  return P
end

actions = {
  { "humidity", getHumidity },
  { "temperature", getTemperature },
  { "airpressure", getAirPressure },
}
