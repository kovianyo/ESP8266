require('pca9685')

SDA = 2
SCL = 3

i2c.setup(0, SDA, SCL, i2c.SLOW)

pca9685.init(0, 0x40, 0)

pca9685.set_chan_byte(0, 64)

-- https://github.com/lexszero/esp8266-pwm
