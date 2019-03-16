-- D5, GPIO14, IO Index 5
pin = 5
gpio.mode(pin, gpio.INT, gpio.PULLUP)

first = nil

registerTrigger = function()
    gpio.trig(pin, "down", onPush)
end

suspendTrigger = function()
  gpio.trig(pin) -- remove callback
  local mytimer = tmr.create()
  mytimer:register(200, tmr.ALARM_SINGLE, registerTrigger)
  mytimer:start()
end

onPush = function(level, when, eventcount)
  if (first == nil) then first = when end
  print(when - first)
  print("pressed ".. level .. " " .. when .. " " .. eventcount)
  suspendTrigger()
end

registerTrigger()
