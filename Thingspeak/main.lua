--- Thingspeak ---
thingspeak_channel_api_write_key = "ZBQUP8AAIC6LQ0RF"
thingspeak_temperature_field_name = "field1"
--thingspeak_humidity_field_name = "field2"

--- WIFI ---
wifi_SSID = "KoviNet"
wifi_password = ""

-- Connect to the wifi network
wifi.setmode(wifi.STATION)
--wifi.setphymode(wifi_signal_mode)
wifi.sta.config(wifi_SSID, wifi_password)
wifi.sta.connect()

t = require("ds18b20")

pin = 1

t.setup(pin)

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

function loop()
    if wifi.sta.status() == 5 then
        -- Stop the loop
        --tmr.stop(0)

        con = nil
        con = net.createConnection(net.TCP, 0)

        con:on("receive", function(con, payloadout)
          print(payloadout)
            if (string.find(payloadout, "Status: 200 OK") ~= nil) then
                print("Posted OK to ThingSpeak");
            end
        end)

        con:on("connection", function(con, payloadout)

        -- Get sensor data
        local temperature = readTemperature()

        print("Sending temperature:", temperature)

        -- Post data to Thingspeak
        con:send(
            "GET /update?api_key=" .. thingspeak_channel_api_write_key ..
            "&field1=" .. temperature ..
            "\r\n")
        end)

        con:on("disconnection", function(con, payloadout)
            con:close();
            collectgarbage();
        end)

        -- Connect to Thingspeak
        con:connect(80,'api.thingspeak.com')
    else
        print("Connecting...")
    end

    tmr.alarm(0, 1000*60, tmr.ALARM_SINGLE, loop)
end

loop()

--tmr.stop(0)
