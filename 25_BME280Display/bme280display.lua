wifi.setmode(wifi.NULLMODE) -- disable wifi

local scl = 1 -- D1, GPIO5
local sda = 2 -- D2, GPIO4

local pressureLow = nil
local pressureHigh = nil
local pressureStart = nil

function init(sda,scl) --Set up the u8glib lib
     local sla = 0x3C
     i2c.setup(0, sda, scl, i2c.SLOW)
     local display = u8g2.ssd1306_i2c_128x64_noname(0, sla)
     display:setFont(u8g2.font_6x10_tf)
     display:setFontRefHeightExtendedText()
     display:setDrawColor(1)
     display:setFontPosTop()
     display:setFontDirection(0)
     display:setFlipMode(1)
     return display
end

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

function getDisplayValues()
  local H, T = bme280.humi()
  local P, T = bme280.baro()

  if H == nil or P == nil or T == nil then return nil end

  local temperature = "Temperature: " .. T/100 .. " C"
  local humidity = "Humidity: " .. string.format("%d", H/1000) .. "%"
  local pressure = P/10000
  local airpressure = " " .. formatPressure(pressure) .. " kPa"

  if pressureStart == nil then pressureStart = pressure end

  if pressureLow == nil then pressureLow = pressure end
  if pressureHigh == nil then pressureHigh = pressure end
  if pressure < pressureLow then pressureLow = pressure end
  if pressure > pressureHigh then pressureHigh = pressure end

  local pressurePeaks = "L " .. formatPressure(pressureLow) .. " H " .. formatPressure(pressureHigh)

  local uptime = getUptimeString()

  local pressureDifference = formatPressure(pressureStart - pressure)

  return {
    Temperature = temperature,
    Humidity = humidity,
    Airpressure = airpressure,
    PressurePeaks = pressurePeaks,
    Uptime = uptime,
    PressureDifference = pressureDifference
  }
end

function drawPages(display, draw)
  local displayValues = getDisplayValues()

  if displayValues == nil then
    print("nil value read")
    return value
  end

  local startTime = tmr.now()

  display:clearBuffer() -- 327 us
  draw(display, displayValues) -- 26483
  display:sendBuffer() -- 261 756 us

  local endTime = tmr.now()

  local displayUpdateHurationInMs = endTime - startTime

  printValues(displayValues, displayUpdateHurationInMs)
end

function printValues(displayValues, displayUpdateHurationInMs)
  print("Uptime: " .. displayValues.Uptime)
  print(displayValues.Temperature)
  print(displayValues.Humidity)
  print("Air pressure: " .. displayValues.Airpressure)
  print(displayValues.PressurePeaks)
  print("Display update took " .. displayUpdateHurationInMs .. " ms")
  print()
end

function draw(display, displayValues)
  display:drawStr(0, 00, displayValues.Temperature)
  display:drawStr(0, 10, displayValues.Humidity)
  display:drawStr(0, 20, "Airp.:" .. displayValues.Airpressure)
  display:drawStr(0, 30, displayValues.PressurePeaks)
  display:drawStr(0, 40, "Uptime: " .. displayValues.Uptime)
  display:drawStr(0, 50, " " .. displayValues.PressureDifference)
end


local display = init(sda,scl)
local bme280result = bme280.setup() -- "2" is BME280
if bme280result ~= 2 then print("BME280 setup failed.") end
bme280result = nil

local mytimer = tmr.create()

mytimer:register(500, tmr.ALARM_AUTO, function (t) drawPages(display, draw);  end)
mytimer:start()
