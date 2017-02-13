require("ina219")

ina_1_adr = 0x40
ina_1 = ina219:new()
ina_1:init(ina_1_adr)

print( "Voltage: ".. ina_1:read_voltage())
print( "Current: ".. ina_1:read_current()/2)
print( "Power: ".. ina_1:read_power())
