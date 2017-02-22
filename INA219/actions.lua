ina219 = require("ina219")

ina219:init(0x40)

function getVoltage()
  log("Reading voltage...")
  local time = tmr.now()

  local voltage = ina219:read_voltage() / 1000
  voltage = round(voltage, 2)

  log("Elapsed us: ", tmr.now() - time)

  return voltage
end

function getCurrent()
  log("Reading current...")
  local time = tmr.now()

  local current = ina219:read_current()
  current = round(current, 1)

  log("Elapsed us: ", tmr.now() - time)

  return current
end

actions = {
  { "voltage", getVoltage },
  { "current", getCurrent }
}
