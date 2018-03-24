local function processPost(pl)
  if (string.match(pl,"POST") ~= nil) then

    print("Parsing HTTP response")
    --print("'" .. pl .. "'")

    ssid_start, ssid_end = string.find(pl,"ssid=")
    --print("ssid_start, ssid_end", ssid_start, ssid_end)

    if ssid_start == nil or ssid_end == nil then return end

    amper1_start, amper1_end = string.find(pl,"&", ssid_end+1)
    --print(amper1_start, amper1_end)

    if amper1_start == nil or amper1_end == nil then return end

    ssid = string.sub(pl, ssid_end+1, amper1_start-1)
    password = string.sub(pl, amper1_end+10)

    print("ssid: '" .. ssid .. "'")
    print("password: '" .. password .. "'")

    print("Connecting to AccessPoint...")
    station_cfg={}
    station_cfg.ssid = ssid
    station_cfg.pwd = password
    wifi.sta.config(station_cfg)
    wifi.sta.connect()

    print("Writing SSID and password to files")

    if file.open("ssid.txt", "w+") then
      file.write(ssid)
      file.close()
      else
      print("Cannot open ssid.txt.")
    end

    if file.open("password.txt", "w+") then
      file.write(password)
      file.close()
      else
      print("Cannot open password.txt.")
    end
  end
end

return processPost
