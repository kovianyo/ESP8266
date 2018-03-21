-- SDA: D2, GPIO4, IO index 2; SCL: D1, GPIO5, IO index 1
sda, scl = 2, 1
i2c.setup(0, sda, scl, i2c.SLOW)
print(bme280.setup()) -- "2" is BME280


H, T = bme280.humi()

Tsgn = (T < 0 and -1 or 1); T = Tsgn*T
print(string.format("T=%s%d.%02d", Tsgn<0 and "-" or "", T/100, T%100))
print(string.format("humidity=%d.%03d%%", H/1000, H%1000))
