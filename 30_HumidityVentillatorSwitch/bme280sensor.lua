local function setup()
  local result = bme280.setup() -- "2" is BME280
  return result == 2
end

local function getValues()
  local T, P, H = bme280.read()

  if H == nil or P == nil or T == nil then return nil end

  local temperature = T/100
  local humidity = H/1000
  local airpressure = P/10000

  return {
    Temperature = temperature,
    Humidity = humidity,
    Airpressure = airpressure
  }
end

return {
  Setup = setup,
  GetValues = getValues
}
