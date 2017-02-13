function test()
 local start = tmr.now()
 local stop = tmr.now()
 local elapsed = stop - start
 print(elapsed)
end

test()

--------------------------------------------------------------------
local function start(self)
  self.startTime = tmr.now()
end

local function stop(self)
  self.stopTime = tmr.now()
end

local function elapsed(self)
  return self.stopTime - self.startTime
end


function createStopWatch()
  local self = {
  startTime = 0,
  stopTime = 0
  }

  self.start = start
  self.stop = stop
  self.elapsed = elapsed

  return self
end

function test()
    local stopWatch = createStopWatch()
    stopWatch:start()

    --local color = string.char(255,0,0)
    --local colors = color:rep(60)
    --ws2812.writergb(4, colors)

    stopWatch:stop()
    local elapsed = stopWatch:elapsed()
    print(elapsed)
end

--------------------------------------------------------------------------

i = 0

LEDCOUNT = 60

targethue = 60
targetlightness = 0.5

repeat

 r, g, b = HSL(i/LEDCOUNT*targethue, 1, i/LEDCOUNT*targetlightness)
 tmr.delay(100000)
 color = string.char(r,g,b)
 colors = color:rep(LEDCOUNT)
 ws2812.writergb(4, colors)
 i = i + 1
until (i>LEDCOUNT)

-------------------------------------------------------------------------

i = 0

LEDCOUNT = 30

red = string.char(255,255,0)
black = string.char(0,0,0)

colors = black:rep(LEDCOUNT)
ws2812.writergb(4, colors)

repeat
 tmr.delay(100000)
 colors = red:rep(i) .. black:rep(LEDCOUNT-i)
 ws2812.writergb(4, colors)
 i = i + 1
until (i>LEDCOUNT)

----------------------------------------------------------------------

gpio.mode(3, gpio.OUTPUT)
gpio.write(3, gpio.HIGH)

----------------------------------------------------------------------

print(adc.readvdd33())
print(adc.read(0))

----------------------------------------------------------------------

function measure()
    start = tmr.now()
    value = adc.read(0)
    stop = tmr.now()

    diff = stop - start

    print("Value: " .. value)

    print("Microsec: " .. diff)
end

measure()

----------------------------------------------------------------------
function measure()
    local count = 100
    local array = {}
    for i=1,count do
        array[i] = adc.read(0)
    end
    for i=1,count do
        print(array[i])
    end
end

measure()

----------------------------------------------------------------------

function measure()
    local count = 100
    local i
    local start = tmr.now()
    for i=1,count do
        value = adc.read(0)
        time = tmr.now() - start
        print(time, value)
    end
end

measure()

----------------------------------------------------------------------

function measure()
    local count = 100
    local i
    local values = {}
    local times = {}
    local start = tmr.now()
    for i=1,count do
        values[i] = adc.read(0)
        times[i] = tmr.now() - start
    end
    for i=1,count do
        print(times[i]/1000, values[i])
    end
end

measure()

----------------------------------------------------------------------

gpio.mode(2, gpio.OUTPUT)
gpio.write(2, gpio.HIGH)

state = false
function blink()
  if state then gpio.write(2, gpio.HIGH)
  else gpio.write(2, gpio.LOW) end
  state = not state
  tmr.alarm(0, 1000, 0, blink)
end

blink()

----------------------------------------------------------------------


uart.write(0, string.char(65) .. string.char(66).. "\n")
uart.on("data", 1, function(data) print("r:", data, string.byte(data)) end, 0)
uart.on("data", 1, function(data) print("r:", string.byte(data)) end, 0)
uart.on("data", 7, function(data) print("r: ", getnum(data)) end, 0)



uart.write(0, string.char(65) .. string.char(66))
uart.write(0, string.char(0xB4) .. string.char(0xC0) .. string.char(0xA8) .. string.char(0x01) .. string.char(0x01).. string.char(0x00).. string.char(0x1E))
B4 C0 A8 01 01 00 1E
uart.write(0, string.char(0xB3) .. string.char(0xC0) .. string.char(0xA8) .. string.char(0x01) .. string.char(0x01).. string.char(0x00).. string.char(0x1D))
uart.write(0, string.char(0xB0) .. string.char(0xC0) .. string.char(0xA8) .. string.char(0x01) .. string.char(0x01).. string.char(0x00).. string.char(0x1A))

adress = string.char(0xC0) .. string.char(0xA8) .. string.char(0x01) .. string.char(0x01)
command = string.char(0xB0) .. adress .. string.char(0x00)

setup: uart.write(0, getcommand(0xB4))
read voltage: uart.write(0, getcommand(0xB0))

----------------------------------------------------------------------
wifi.setmode(wifi.STATION)
wifi.sta.config("KoviNet", "")
wifi.sta.connect()

----------------------------------------------------------------------
node.dsleep(3000000)

----------------------------------------------------------------------

value = adc.read(0)
print(value / 0.157 / 1000)

function measure()
   value = adc.read(0)
   print(value / 1000)
   tmr.alarm(0, 200, 0, measure)
end

measure()

tmr.stop(0)

print(tmr.now()/1000000)
