print("Connecting to AccessPoint...")
station_cfg={}
station_cfg.ssid = ""
station_cfg.pwd = ""
wifi.sta.config(station_cfg)
wifi.sta.connect()
