require("ina219")

ina_1_adr = 0x40
ina_1 = ina219:new()
ina_1:init(ina_1_adr)

function getIndex()
  return "index"
end

function getVoltage()
  local voltage = ina_1:read_voltage()
  return voltage
end

function getCurrent()
  local current = ina_1:read_current()
  current = round(current, 1)
  return current
end

actions = {
  { "", getIndex },
  { "voltage", getVoltage },
  { "current", getCurrent }
}
