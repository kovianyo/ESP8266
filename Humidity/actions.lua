function getHumidity()
  log("Reading humidity...")

  local time = tmr.now()
  local H, T = bme280.humi()

  -- local voltage = ina219:read_voltage() / 1000
  -- voltage = round(voltage, 2)

  log("Elapsed us: ", tmr.now() - time)

  return H
end

actions = {
  { "humidity", getHumidity }
}
