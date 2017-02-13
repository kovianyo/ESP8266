frequency = 1000

pwm.setup(1, frequency, 0)
pwm.setup(2, frequency, 0)

pwm.start(1)
pwm.start(2)

irpin1 = 5
irstop1 = false

function setSpeed(speed)
  speed = getLimitedSpeed(speed)

  if speed==0 then
    pwm.setduty(1, 0)
    pwm.setduty(2, 0)
  elseif speed > 0 and not irstop1 then
    pwm.setduty(2, 0)
    pwm.setduty(1, speed)
  elseif speed < 0 then
    pwm.setduty(1, 0)
    pwm.setduty(2, speed * -1)
  end
end

function getLimitedSpeed(speed)
  if speed > 1023 then
    return 1023
  elseif speed < -1023 then
    return -1023
  end

  return speed
end

function setSpeedString(speedStr)
  --collectgarbage()
  --print(tmr.now(), node.heap(), speedStr)
  local speed = tonumber(speedStr)
  if not (speed == nil) then setSpeed(speed) end
end
