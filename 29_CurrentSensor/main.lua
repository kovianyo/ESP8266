wifi.setmode(wifi.NULLMODE) -- disable wifi

local i2cId = 0 -- must be 0 for bme280
local scl = 1 -- D1, GPIO5
local sda = 2 -- D2, GPIO4

local displayValues = nil

local function draw(display, ssd1360)
  ssd1360.WriteLine("Bus voltage: " .. displayValues.BusVoltageInVolt .. " V")
  ssd1360.WriteLine("Shunt voltage:")
  ssd1360.WriteLine(" " .. displayValues.ShuntVoltageInmV .. " mV")
  ssd1360.WriteLine("Current: " .. displayValues.CurrentInmA .. " mA")
  ssd1360.WriteLine("Power: " .. displayValues.PowerInW .. " W")
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


local function updateDisplayValues()
  local vals = ina219.getVals()

  local uptime = getUptimeString()

  displayValues = {
    BusVoltageInVolt = vals.voltageV,
    ShuntVoltageInmV = vals.shuntmV,
    CurrentInmA = vals.currentmA,
    PowerInW = vals.powerW,
    Uptime = uptime
  }
end

local function printValues()
  print("Uptime: " .. displayValues.Uptime)
  print("Bus voltage: " .. displayValues.BusVoltageInVolt .. " V")
  print("Shunt voltage: " .. displayValues.ShuntVoltageInmV .. " mV")
  print("Current: " .. displayValues.CurrentInmA .. " mA")
  print("Power: " .. displayValues.PowerInW .. " W")
  print()
end

i2c.setup(i2cId, sda, scl, i2c.SLOW)

local ina219 = require("ina219")
ina219.init()

local ssd1360 = dofile("ssd1306.lua")
ssd1360.Init(i2cId, function (display) draw(display, ssd1360) end)

local function updateDisplay()
  updateDisplayValues()
  ssd1360.DrawDisplay()
  printValues()
end

local mytimer = tmr.create()
mytimer:register(500, tmr.ALARM_AUTO, function (t) updateDisplay();  end)
mytimer:start()
