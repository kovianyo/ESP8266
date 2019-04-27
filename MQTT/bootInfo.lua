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

printBootReason()

print("Chipid: " .. node.chipid() .. ", flashid: " .. node.flashid())
print("Falsh size: " .. node.flashsize() .. " bytes")
print("CPU at " .. node.getcpufreq() .. "MHz")
print()
print("Heap size: " .. node.heap() .. " bytes")
print()
