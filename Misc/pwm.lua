gpio.mode(1, gpio.OUTPUT)
gpio.mode(2, gpio.OUTPUT)

gpio.write(1, gpio.HIGH)
gpio.write(1, gpio.LOW)

gpio.write(2, gpio.HIGH)
gpio.write(2, gpio.LOW)

pwm.setup(1, 500, 512)
pwm.setup(2, 500, 512)

pwm.start(1)
pwm.start(2)

pwm.setduty(1, 0)
pwm.setduty(2, 0)

pwm.setduty(1, 1023)
pwm.setduty(2, 1023)

duty = 0

function step()
    if duty == 1024 then duty = 0 end
    pwm.setduty(1, duty)
    duty = duty + 1
    tmr.alarm(0, 10, tmr.ALARM_SINGLE, step)
end

step()

pwm.stop(1)
pwm.stop(2)
