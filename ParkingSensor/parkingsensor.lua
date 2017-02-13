outpin = 5
inpin = 6

gpio.mode(outpin, gpio.OUTPUT)
gpio.write(outpin, gpio.HIGH)

function trigger()
    gpio.write(outpin, gpio.LOW)
    tmr.delay(10)
    gpio.write(outpin, gpio.HIGH)
end

distance = 1000

function change(level)
    --print("change " .. level)
    if level == 1 then start = tmr.now()
    else
        distance = (tmr.now() - start) * 340 / 2 / 1000
        print(distance .. " mm")
    end
    --print(tmr.now())
end

gpio.mode(inpin, gpio.INT)
gpio.trig(inpin, "both", change)

trigger()

tmr.alarm(0, 1000, tmr.ALARM_AUTO, trigger)
tmr.stop(0)

buzzpin = 1

gpio.mode(buzzpin, gpio.OUTPUT)
--gpio.write(buzzpin, gpio.HIGH)
gpio.write(buzzpin, gpio.LOW)

sound = 0

function beep()
    if sound == 0 then
        gpio.write(buzzpin, gpio.HIGH)
        sound = 1
    else
        gpio.write(buzzpin, gpio.LOW)
        sound = 0
    end
    tmr.alarm(1, distance, tmr.ALARM_AUTO, beep)
end

beep()

tmr.stop(1)
gpio.write(buzzpin, gpio.LOW)
