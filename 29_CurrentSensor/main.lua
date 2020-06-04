wifi.setmode(wifi.NULLMODE) -- disable wifi

local i2cId = 0 -- must be 0 for bme280
local scl = 1 -- D1, GPIO5
local sda = 2 -- D2, GPIO4

local function draw(display, ssd1360, displayValues)
  -- ssd1360.WriteLine("Voltage: " .. string.format("%6.3f", displayValues.BusVoltageInVolt) .. " V")
  -- ssd1360.WriteLine("Current: " .. string.format("%7.1f", displayValues.CurrentInmA) .. " mA")
  ssd1360.WriteLine("Voltage: " .. string.format("%6.3f", displayValues.BusVoltageInVolt) .. " V")
  ssd1360.WriteLine("Current: " .. string.format("%6.1f", displayValues.CurrentInmA) .. " mA")
  ssd1360.WriteLine()
  ssd1360.WriteLine("Power: " .. displayValues.PowerInmW .. " mW")
  ssd1360.WriteLine("V_shunt: " .. displayValues.ShuntVoltageInmV .. " mV")
  ssd1360.WriteLine("Uptime: " .. displayValues.Uptime)
end

local function getUptimeString()
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


local function getDisplayValues(vals)
  local uptime = getUptimeString()

  local displayValues = {
    BusVoltageInVolt = vals.voltageV,
    ShuntVoltageInmV = vals.shuntmV,
    CurrentInmA = vals.currentmA,
    PowerInmW = vals.powermW,
    Uptime = uptime
  }

  return displayValues
end

local function printValues(displayValues)
  print("Uptime: " .. displayValues.Uptime)
  print("Bus voltage: " .. displayValues.BusVoltageInVolt .. " V")
  print("Shunt voltage: " .. displayValues.ShuntVoltageInmV .. " mV")
  print("Current: " .. displayValues.CurrentInmA .. " mA")
  print("Power: " .. displayValues.PowerInmW .. " mW")
  print()
end

local speed = i2c.setup(i2cId, sda, scl, i2c.SLOW)
if speed == 0 then
  print("Could not initialze IIC bus")
  return
end
speed = nil

local ina219 = require("ina219")
ina219.init(i2cId, scl, sda)

local ssd1360 = dofile("ssd1306.lua")
ssd1360.Init(i2cId, function (display, displayValues) draw(display, ssd1360, displayValues) end)

local function updateDisplay()
  local vals = ina219.getVals()
  local displayValues = getDisplayValues(vals)
  ssd1360.DrawDisplay(displayValues)
  printValues(displayValues)
end

local mytimer = tmr.create()
mytimer:register(500, tmr.ALARM_AUTO, function (t) updateDisplay();  end)
mytimer:start()
