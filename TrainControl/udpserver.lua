--[[
wifi.setmode(wifi.STATION)
wifi.sta.config("KoviNet","")
wifi.sta.connect();
--]]

cfg = {}
cfg.ssid = "TrainControl"
cfg.pwd = "TrainRulez"
wifi.ap.config(cfg)

wifi.setmode(wifi.SOFTAP)

frequency = 1000

pwm.setup(1, frequency, 0)
pwm.setup(2, frequency, 0)

pwm.start(1)
pwm.start(2)

irpin1 = 5
irstop1 = false

function setSpeed(speed)
  if speed > 1023 then
    speed = 1023
  elseif speed < -1023 then
    speed = -1023
  end

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

function setSpeedString(speedStr)
  print(speedStr)
  local speed = tonumber(speedStr)
  if not (speed == nil) then setSpeed(speed) end
end

if not (s == nil) then s:close() end
s=net.createServer(net.UDP)
s:on("receive",function(s,c) setSpeedString(c) end)
s:listen(8888)

-- echo "2" | nc -w1 -u 192.168.1.112 8888
