wifi.setmode(wifi.NULLMODE) -- disable wifi

local i2cId = 0 -- must be 0 for bme280
local scl = 1 -- D1, GPIO5
local sda = 2 -- D2, GPIO4

local pressureLow = nil
local pressureHigh = nil
local pressureStart = nil

local displayValues = nil

local function draw(display)
  display:drawStr(0, 00, "Temperature: " .. displayValues.Temperature .. string.char(176) .. "C")
  display:drawStr(0, 10, "Humidity: " .. displayValues.Humidity .. " %")
  display:drawStr(0, 20, "Airp.:" .. displayValues.Airpressure .. " kPa")
  display:drawStr(0, 30, "L " .. displayValues.PressureLowPeak .. " H " .. displayValues.PressureHighPeak)
  display:drawStr(0, 40, "Uptime: " .. displayValues.Uptime)
  display:drawStr(0, 50, " " .. displayValues.PressureDifference .. " kPa")
end

local bme280sensor = dofile("bme280sensor.lua")

function getUptimeString()
  local uptime = tmr.time()

  local seconds = uptime % 60
  local uptimeString = seconds .. "s"
  uptime = (uptime - seconds) / 60
  if uptime < 1 then return uptimeString end

  local minutes = uptime % 60
  uptimeString = minutes .. "m " .. uptimeString
  uptime = (uptime - minutes) / 60
  if uptime < 1 then return uptimeString end

  local hours = uptime % 24
  uptimeString = hours .. "h " .. uptimeString
  uptime = (uptime - hours) / 24
  if uptime < 1 then return uptimeString end

  uptimeString = uptime .. "d " .. uptimeString

  return uptimeString
end

function formatPressure(pressure)
  return string.format("%.3f", pressure)
end


local function updateDisplayValues()
  local bme280values = bme280sensor.GetValues()

  if bme280values == nil then return end

  local humidity = string.format("%d", bme280values.Humidity)
  local pressure = bme280values.Airpressure
  local airpressure = formatPressure(bme280values.Airpressure)

  if pressureStart == nil then pressureStart = bme280values.Airpressure end

  if pressureLow == nil then pressureLow = pressure end
  if pressureHigh == nil then pressureHigh = pressure end
  if pressure < pressureLow then pressureLow = pressure end
  if pressure > pressureHigh then pressureHigh = pressure end

  local pressureLowPeak = formatPressure(pressureLow)
  local pressureHighPeak = formatPressure(pressureHigh)

  local uptime = getUptimeString()

  local pressureDifference = formatPressure(pressureStart - pressure)

  displayValues = {
    Temperature = bme280values.Temperature,
    Humidity = humidity,
    Airpressure = airpressure,
    PressureLowPeak = pressureLowPeak,
    PressureHighPeak = pressureHighPeak,
    Uptime = uptime,
    PressureDifference = pressureDifference
  }
end

function printValues()
  print("Uptime: " .. displayValues.Uptime)
  print("Temperature: " .. displayValues.Temperature .. " C")
  print("Humidity: " .. displayValues.Humidity .. " %")
  print("Air pressure: " .. displayValues.Airpressure .. " kPa")
  print("L " .. displayValues.PressureLowPeak .. " kPa, H " .. displayValues.PressureHighPeak .. " kPa")
  print("Pressure difference: " .. displayValues.PressureDifference .. "kPa")
  print()
end


i2c.setup(i2cId, sda, scl, i2c.SLOW)
bme280sensor.Setup()

local ssd1360 = dofile("ssd1306.lua")
ssd1360.Init(i2cId, draw)

local function updateDisplay()
  updateDisplayValues()
  ssd1360.DrawDisplay()
  printValues()
end

local mytimer = tmr.create()
mytimer:register(500, tmr.ALARM_AUTO, function (t) updateDisplay();  end)
mytimer:start()
