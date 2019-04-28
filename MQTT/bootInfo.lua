local printBootReason = function()
  local prefix = "Boot reason: "
  local _, reason = node.bootreason()

  if reason == 0 then print(prefix .. "power-on")
  elseif reason == 1 then print(prefix .. "hardware watchdog reset")
  elseif reason == 2 then print(prefix .. "exception reset")
  elseif reason == 3 then print(prefix .. "software watchdog reset")
  elseif reason == 4 then print(prefix .. "software restart")
  elseif reason == 5 then print(prefix .. "wake from deep sleep")
  elseif reason == 6 then print(prefix .. "external reset")
  end
end

local printWifInfo = function()
  local modePrefix = "Wifi mode: "

  local mode = wifi.getmode()
  if mode == wifi.STATION then print(modePrefix .. "Station")
  elseif mode == wifi.SOFTAP then print(modePrefix .. "Access Point")
  elseif mode == wifi.STATIONAP then print(modePrefix .. "Station and Acccess Point")
  elseif mode == wifi.NULLMODE then print(modePrefix .. "Nullmode")
  end

  local phyModePrefix = "Physical mode: "

  local phyMode = wifi.getphymode()
  if phyMode == wifi.PHYMODE_B then print(phyModePrefix .. "b")
  elseif phyMode == wifi.PHYMODE_G then print(phyModePrefix .. "g")
  elseif phyMode == wifi.PHYMODE_N then print(phyModePrefix .. "n")
  end

  print("MAC address: " .. wifi.sta.getmac())
  print("Hostname: " .. wifi.sta.gethostname())

  local statusPrefix = "Wifi status: "
  local status = wifi.sta.status()
  if status == wifi.STA_IDLE then print(statusPrefix .. "Idle")
  elseif status == wifi.STA_CONNECTING then print(statusPrefix .. "Connecting")
  elseif status == wifi.STA_WRONGPWD then print(statusPrefix .. "WrongPwd")
  elseif status == wifi.STA_APNOTFOUND then print(statusPrefix .. "APNotFound")
  elseif status == wifi.STA_FAIL then print(statusPrefix .. "Fail")
  elseif status == wifi.STA_GOTIP then print(statusPrefix .. "GotIp")
  end
end

local function printFileSystemInfo()
  local remaining, used, total = file.fsinfo()
  print("File system: used: " .. used .. " out of " .. total .. " bytes")
end

printBootReason()

print("Chipid: " .. node.chipid() .. ", flashid: " .. node.flashid())
print("Falsh size: " .. node.flashsize() .. " bytes")
print("CPU at " .. node.getcpufreq() .. "MHz")
print()
printFileSystemInfo()
print()
printWifInfo()
print()
print("Boot time: " .. tmr.now() .. " ms")
print()
print("Heap size: " .. node.heap() .. " bytes")
print()
