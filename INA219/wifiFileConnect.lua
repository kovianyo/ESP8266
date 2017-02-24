function readFiles()
  local ssid = nil

  if file.open("ssid.txt", "r") then
    ssid = file.read()
    --printString(ssid, "SSID")
    file.close()
  else
    print("Could not open ssid.txt.")
  end

  local password = nil

  if file.open("password.txt", "r") then
    password = file.read()
    --printString(password, "password")
    file.close()
  else
    print("Could not open password.txt.")
  end

  if ssid ~= nil and password ~= nil then
    print("Connecting to AccessPoint " .. ssid .. "...")
    wifi.sta.config(ssid, password)
    wifi.sta.connect()
  end
end

print("Checking files for SSID and password...")
readFiles()

readFiles = nil
