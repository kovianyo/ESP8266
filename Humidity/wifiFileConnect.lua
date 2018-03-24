function readFiles()
  local ssid = nil

  file.open("ssid.txt", "r") -- without this the file.read() returned empty string
  file.close()
  if file.open("ssid.txt", "r") then
    ssid = file.read()
    --printString(ssid, "SSID")
    file.close()
    print("ssid", ssid)
  else
    print("Could not open ssid.txt.")
  end

  local password = nil

  file.open("password.txt", "r")
  file.close()
  if file.open("password.txt", "r") then
    password = file.read()
    --printString(password, "password")
    file.close()
  else
    print("Could not open password.txt.")
  end

  if password == nil then password = "" end

  if ssid ~= nil then
    print("Connecting to AccessPoint '" .. ssid .. "'...")
    station_cfg={}
    station_cfg.ssid = ssid
    station_cfg.pwd = password
    wifi.sta.config(station_cfg)
    wifi.sta.connect()
  end
end

print("Checking files for SSID and password...")
readFiles()

readFiles = nil
