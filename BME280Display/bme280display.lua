wifi.setmode(wifi.NULLMODE) -- disable wifi

scl = 1 -- D1, GPIO5
sda = 2 -- D2, GPIO4

pressureLow = nil
pressureHigh = nil

function init(sda,scl) --Set up the u8glib lib
     local sla = 0x3C
     i2c.setup(0, sda, scl, i2c.SLOW)
     local display = u8g.ssd1306_128x64_i2c(sla)
     display:setFont(u8g.font_6x10)
     display:setFontRefHeightExtendedText()
     display:setDefaultForegroundColor()
     display:setFontPosTop()
     display:setRot180()           -- Rotate Display if needed
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

function getBatteryPercent(adcValue)
  local minimumVoltage = 5.5
  local maximumVoltage = 8.0

  local adcFactor = 0.00272093
  local voltageDividerFactor = 5.7

  local percent = (adcValue * adcFactor * voltageDividerFactor - minimumVoltage)/(maximumVoltage - minimumVoltage) * 100;
  return percent
end

function formatPressure(pressure)
  return string.format("%.3f", pressure)
end

function getDisplayValues()
  local H, T = bme280.humi()
  local P, T = bme280.baro()

  local temperature = "Temperature: " .. T/100 .. string.char(176) .. "C"
  local humidity = "Humidity: " .. string.format("%d", H/1000) .. "%"
  local pressure = P/10000
  local airpressure = " " .. formatPressure(pressure) .. " kPa"

  if pressureLow == nil then pressureLow = pressure end
  if pressureHigh == nil then pressureHigh = pressure end
  if pressure < pressureLow then pressureLow = pressure end
  if pressure > pressureHigh then pressureHigh = pressure end

  local pressurePeaks = "L " .. formatPressure(pressureLow) .. " H " .. formatPressure(pressureHigh)

  local uptime = getUptimeString()
  local battery = string.format("%d", getBatteryPercent(adc.read(0))) .."%"

  return temperature, humidity, airpressure, pressurePeaks, uptime, battery
end

function drawPages(display, draw)
  local temperature, humidity, airpressure, pressurePeaks, uptime, battery = getDisplayValues()
  local startTime = tmr.now()

  display:firstPage()

  repeat
   draw(display, temperature, humidity, airpressure, pressurePeaks, uptime, battery)
  until display:nextPage() == false

  local endTime = tmr.now()
  print("Uptime: " .. uptime)
  print(temperature)
  print(humidity)
  print("Air pressure: " .. airpressure)
  print(pressurePeaks)
  print("Battery: " .. battery)
  print("Display update took " .. (endTime - startTime) .. " ms")
  print()
end

function draw(display, temperature, humidity, airpressure, pressurePeaks, uptime, battery)
  display:drawStr(0, 00, temperature)
  display:drawStr(0, 10, humidity)
  display:drawStr(0, 20, "Airp.:" .. airpressure)
  display:drawStr(0, 30, pressurePeaks)
  display:drawStr(0, 40, "Uptime: " .. uptime)
  display:drawStr(0, 50, "Battery: " .. battery)
end


display = init(sda,scl)
bme280result = bme280.setup() -- "2" is BME280
if bme280result ~= 2 then print("BME280 setup failed.") end
bme280result = nil

mytimer = tmr.create()

mytimer:register(1000, tmr.ALARM_AUTO, function (t) drawPages(display, draw);  end)
mytimer:start()
