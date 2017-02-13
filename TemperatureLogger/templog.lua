t = require("ds18b20")

pin = 1

t.setup(pin)

t.read()

function readTemperature()
  local temp = 85
  local retry = 100
  while temp == 85 and retry > 0 do
    temp = t.read()
    retry = retry - 1
  end

  --print("temp:", temp)
  --print(temp == 85)

  --print("retry:", retry)

  return temp
end

function measure()
    local total, used, remaining = file.fsinfo()

    if remaining > 50000 then
        local temp = readTemperature()

        -- uptime in seconds
        local time = tmr.time()

        print(time, temp)

        file.open("temp.log","a")
        file.write(time .. ", " .. temp .. "\n")
        file.close()
    else
        print("Low free space")
    end

    tmr.alarm(0, 1000*60, tmr.ALARM_SINGLE, measure)
end

measure()

--tmr.stop(0)
