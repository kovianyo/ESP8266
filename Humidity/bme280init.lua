-- SDA: D2, GPIO4, IO index 2; SCL: D1, GPIO5, IO index 1
sda, scl = 2, 1
i2c.setup(0, sda, scl, i2c.SLOW)
print(bme280.setup()) -- "2" is BME280
