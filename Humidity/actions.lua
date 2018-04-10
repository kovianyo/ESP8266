function getHumidity()
  log("Reading humidity...")

  local time = tmr.now()
  local H, T = bme280.humi()

  local H2 = bme280.humi()
  -- local voltage = ina219:read_voltage() / 1000
  -- voltage = round(voltage, 2)

  log("Elapsed us: ", tmr.now() - time)

  return math.max(H, H2)
end

actions = {
  { "humidity", getHumidity }
}
