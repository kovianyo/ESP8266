-- SDA: D2, GPIO4, IO index 2; SCL: D1, GPIO5, IO index 1
local sda, scl = 2, 1
i2c.setup(0, sda, scl, i2c.SLOW)
if (bme280.setup() == 2)
then
  print("BME280 initialized")
else
  print("BME280 initialization failed")
end
