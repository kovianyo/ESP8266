require("ina219")

ina_1_adr = 0x40
ina_1 = ina219:new()
ina_1:init(ina_1_adr)

function getVoltage()
  log("Reading voltage...")
  local time = tmr.now()

  local voltage = ina_1:read_voltage() / 1000
  voltage = round(voltage, 2)

  log("Elapsed us: ", tmr.now() - time)

  return voltage
end

function getCurrent()
  log("Reading current...")
  local time = tmr.now()

  local current = ina_1:read_current()
  current = round(current, 1)

  log("Elapsed us: ", tmr.now() - time)

  return current
end

actions = {
  { "voltage", getVoltage },
  { "current", getCurrent }
}
