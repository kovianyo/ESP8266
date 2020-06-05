-- IC maximum voltage: 26 V

local ina219 = {}
ina219.i2cId = 0
ina219.device_address = 0x40   -- 1000000 (A0+A1=GND)

ina219.configuration_reg = 0x00
ina219.shunt_reg = 0x01
ina219.voltage_reg = 0x02
ina219.power_reg = 0x03
ina219.current_reg = 0x04
ina219.calibration_reg = 0x05

ina219.currentLsb = 0 -- mA per bit
ina219.powerLsb = 0 -- mW per bit

ina219.shuntResistance = 0.1 -- Ohm (R100 resistor)

function ina219.init(i2cId)
  ina219.i2cId = i2cId
  ina219.setCurrentResolution(0.1)
  local registerValue = ina219.read_reg_str(ina219.configuration_reg)
  print("Configuration register: " .. stringToBin(registerValue) .. " (" .. ina219.stringToHex(registerValue) .. ")")
end

-- user defined function: read from reg_addr content of dev_addr
function ina219.read_reg_str(reg_addr)
  i2c.start(ina219.i2cId)
  i2c.address(ina219.i2cId, ina219.device_address, i2c.TRANSMITTER)
  i2c.write(ina219.i2cId,reg_addr)
  i2c.stop(ina219.i2cId)
  tmr.delay(1)
  i2c.start(ina219.i2cId)
  i2c.address(ina219.i2cId, ina219.device_address, i2c.RECEIVER)
  local c = i2c.read(ina219.i2cId, 2) -- read 16bit val
  i2c.stop(ina219.i2cId)
  return c
end

-- returns 16 bit int
function ina219.read_reg_int(reg_addr)
  local c = ina219.read_reg_str(reg_addr)
  -- convert to 16 bit int
  local val = bit.lshift(string.byte(c, 1), 8)
  local val2 = bit.bor(val, string.byte(c, 2))
  return val2
end

function ina219.write_reg(reg_addr, reg_val)
  print("writing register: " .. reg_addr .. " with value " .. reg_val)
  i2c.start(ina219.i2cId)
  i2c.address(ina219.i2cId, ina219.device_address, i2c.TRANSMITTER)
  local bw = i2c.write(ina219.i2cId, reg_addr)
  --print("Bytes written: " .. bw)
  -- upper 8 bits
  local bw2 = i2c.write(ina219.i2cId, bit.rshift(reg_val, 8))
  --print("Bytes written: " .. bw2)
  -- lower 8 bits
  local bw3 = i2c.write(ina219.i2cId, bit.band(reg_val, 0xFF))
  --print("Bytes written: " .. bw3)
  i2c.stop(ina219.i2cId)
end

function ina219.initi2c(sda, scl)
  i2c.setup(ina219.i2cId, sda, scl, i2c.SLOW)
end

function ina219.reset()
  ina219.write_reg(ina219.configuration_reg, 0xFFFF)
end

function ina219.setCurrentResolution(currentLsb)
  ina219.currentLsb = currentLsb -- mA per bit
  local calibrationValue = 40.96 / (ina219.currentLsb * ina219.shuntResistance)
  ina219.write_reg(ina219.calibration_reg, calibrationValue)
  ina219.powerLsb = 20 * ina219.currentLsb -- mW per bit
end

function decodeTwosComplement(valueInt)
  if valueInt > 32767 then valueInt = valueInt - 65537 end
  return valueInt
end

function ina219.getCurrent_mA()
  -- Gets the raw current value (16-bit signed integer, 2's complement)
  local valueInt = ina219.read_reg_int(ina219.current_reg)
  local value = decodeTwosComplement(valueInt)
  return value * ina219.currentLsb
end

function ina219.getBusVoltage_V()
  -- Gets the raw bus voltage (16-bit signed integer, so +-32767)
  local valueInt = ina219.read_reg_int(ina219.voltage_reg)
  -- Shift to the right 3 to drop CNVR and OVF and multiply by LSB
  local voltageIn_mV = bit.rshift(valueInt, 3) * 4 -- Bus Voltage Register resolution is 4 mV
  local voltageIn_V = voltageIn_mV / 1000
  return voltageIn_V
end

function ina219.getShuntVoltage_mV()
  -- Gets the raw shunt voltage (16-bit signed integer, so +-32767)
  local valueInt = ina219.read_reg_int(ina219.shunt_reg)
  local value = decodeTwosComplement(valueInt)
  local voltageIn_mV = value / 100 -- shunt voltage resolution is 0.01 mV
  return voltageIn_mV
end

function ina219.getBusPower_mW()
  local valueInt = ina219.read_reg_int(ina219.power_reg)
  -- print("raw power: " .. valueInt)
  return valueInt * ina219.powerLsb
end

function ina219.checkVals()
  local registerValue = ina219.read_reg_str(ina219.configuration_reg)
  print("Config: " .. ina219.stringToHex(registerValue))
  print("Shunt Voltage: " .. ina219.getShuntVoltage_mV() .. " mV")
  print("Bus Voltage: " .. ina219.getBusVoltage_V() .. " V")
  print("Power: " .. ina219.getBusPower_mW() .. " mW")
  print("Current: " .. ina219.getCurrent_mA() .. " mA")
  print("")
end

function ina219.getVals()
  local val = {}
  val.voltageV = ina219.getBusVoltage_V()
  val.shuntmV = ina219.getShuntVoltage_mV()
  val.powermW = ina219.getBusPower_mW()
  val.currentmA = ina219.getCurrent_mA()
  return val
end

function ina219.stringToHex(val)
  --print("len of val:" .. string.len(val))
  local parts = {}

  for i = 1, string.len(val) do
    if string.byte(val, i) then
      parts[i] = string.format("%2X", string.byte(val, i))
    end
  end
  --print(s)
  local result = "0x " .. table.concat(parts, " ")
  return result
end

function byteToBin(value)
  local result = ""

  for i = 7, 0, -1 do
    if bit.isset(value, i) then
        result = result .. "1"
    else
        result = result .. "0"
    end
  end

  return result
end

function stringToBin(value)
  local parts = {}
  for i = 0, string.len(value) - 1 do
    parts[i + 1] = byteToBin(string.byte(value, i + 1))
  end

  local result = "0b " .. table.concat(parts, " ")
  return result
end

--ina219.init()
return ina219
