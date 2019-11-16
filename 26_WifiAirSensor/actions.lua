function getHumidity()
  log("Reading humidity...")

  local time = tmr.now()
  local H, T = bme280.humi()

  local H2 = bme280.humi()

  log("Humidity reading elapsed us: " .. tmr.now() - time)

  return math.max(H, H2) -- filter out negative errors (zeros)
end

actions = {
  { "humidity", getHumidity }
}
