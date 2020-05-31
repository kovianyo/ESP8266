-- http://chilipeppr2.blogspot.com/2016/01/detect-current-and-voltage-from-nodemcu.html

-- ChiliPeppr INA219 Module ina219.lua v4
local ina219 = {}
ina219.i2cId = 0
ina219.scl = 1
ina219.sda = 2
ina219.devaddr = 0x40   -- 1000000 (A0+A1=GND)

ina219.configuration_reg = 0x00
ina219.shunt_reg = 0x01
ina219.voltage_reg = 0x02
ina219.power_reg = 0x03
ina219.current_reg = 0x04
ina219.calibration_reg = 0x05

-- Set multipliers to convert raw current/power values
ina219.maxVoltage = 0 -- configured for max 32volts by default after init
ina219.maxCurrentmA = 0 -- configured for max 2A by default after init
ina219.currentDivider_mA = 0 -- e.g. Current LSB = 50uA per bit (1000/50 = 20)
ina219.powerDivider_mW = 0  -- e.g. Power LSB = 1mW per bit
ina219.currentLsb = 0 -- uA per bit
ina219.powerLsb = 1 -- mW per bit

function ina219.init(i2cId, scl, sda)
  ina219.i2cId = i2cId
  ina219.scl = scl
  ina219.sda = sda
  ina219.begin()
  ina219.setCalibration_32V_2A()
  local registerValue = ina219.read_reg_str(ina219.configuration_reg)
  print("Configuration register: " .. stringToBin(registerValue) .. " (" .. ina219.stringToHex(registerValue) .. ")")
end

-- user defined function: read from reg_addr content of dev_addr
function ina219.read_reg_str(reg_addr)
  i2c.start(ina219.i2cId)
  i2c.address(ina219.i2cId, ina219.devaddr, i2c.TRANSMITTER)
  i2c.write(ina219.i2cId,reg_addr)
  i2c.stop(ina219.i2cId)
  tmr.delay(1)
  i2c.start(ina219.i2cId)
  i2c.address(ina219.i2cId, ina219.devaddr, i2c.RECEIVER)
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
  i2c.address(ina219.i2cId, ina219.devaddr, i2c.TRANSMITTER)
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

function ina219.begin()
  i2c.setup(ina219.i2cId, ina219.sda, ina219.scl, i2c.SLOW)
end

function ina219.reset()
  ina219.write_reg(ina219.configuration_reg, 0xFFFF)
end

function ina219.setCalibration_16V_400mA()
  ina219.maxVoltage = 16
  ina219.maxCurrentmA = 400
  ina219.currentDivider_mA = 20 -- Current LSB = 50uA per bit (1000/50 = 20)
  ina219.powerDivider_mW = 1  -- Power LSB = 1mW per bit
  ina219.currentLsb = 50 -- uA per bit
  ina219.powerLsb = 1 -- mW per bit
  ina219.write_reg(ina219.calibration_reg, 8192)
  -- INA219_CONFIG_BVOLTAGERANGE_16V |
  --                  INA219_CONFIG_GAIN_1_40MV |
  --                  INA219_CONFIG_BADCRES_12BIT |
  --                  INA219_CONFIG_SADCRES_12BIT_1S_532US |
  --                  INA219_CONFIG_MODE_SANDBVOLT_CONTINUOUS;
  -- write_reg(0x05, 0x0000 | 0x0000 | 0x0400 | 0x0018 | 0x0007)
  ina219.write_reg(ina219.configuration_reg, 0x41F)
end

function ina219.setCalibration_32V_1A()
  ina219.maxVoltage = 32
  ina219.maxCurrentmA = 1000
  -- Compute the calibration register
  -- Cal = trunc (0.04096 / (Current_LSB * RSHUNT))
  -- Cal = 10240 (0x2800)
  ina219.write_reg(ina219.calibration_reg, 10240)
  -- Set multipliers to convert raw current/power values
  ina219.currentDivider_mA = 25   -- Current LSB = 40uA per bit (1000/40 = 25)
  ina219.powerDivider_mW = 1      -- Power LSB = 800uW per bit
  ina219.currentLsb = 40 -- uA per bit
  ina219.powerLsb = 0.8 -- mW per bit
  -- INA219_CONFIG_BVOLTAGERANGE_32V |
  --                  INA219_CONFIG_GAIN_8_320MV |
  --                  INA219_CONFIG_BADCRES_12BIT |
  --                  INA219_CONFIG_SADCRES_12BIT_1S_532US |
  --                  INA219_CONFIG_MODE_SANDBVOLT_CONTINUOUS;
  local config = bit.bor(0x2000, 0x1800, 0x0400, 0x0018, 0x0007)
  ina219.write_reg(ina219.configuration_reg, config)
end

function ina219.setCalibration_32V_2A()
  ina219.maxVoltage = 32
  ina219.maxCurrentmA = 2000
  -- Compute the calibration register
  -- Cal = trunc (0.04096 / (Current_LSB * RSHUNT))
  -- Cal = 4096 (0x1000)
  ina219.write_reg(ina219.calibration_reg, 4096)
  -- Set multipliers to convert raw current/power values
  ina219.currentDivider_mA = 10 -- Current LSB = 100uA per bit (1000/100 = 10)
  ina219.powerDivider_mW = 1      --Power LSB = 1mW per bit (2/1)
  ina219.currentLsb = 100 -- uA per bit
  ina219.powerLsb = 1 -- mW per bit
  -- INA219_CONFIG_BVOLTAGERANGE_32V |
  --                  INA219_CONFIG_GAIN_8_320MV |
  --                  INA219_CONFIG_BADCRES_12BIT |
  --                  INA219_CONFIG_SADCRES_12BIT_1S_532US |
  --                  INA219_CONFIG_MODE_SANDBVOLT_CONTINUOUS;
  local config = bit.bor(0x2000, 0x1800, 0x0400, 0x0018, 0x0007)
  ina219.write_reg(ina219.configuration_reg, config)
end

function ina219.getCurrent_mA()
  -- Gets the raw current value (16-bit signed integer, so +-32767)
  local valueInt = ina219.read_reg_int(ina219.current_reg)
  if valueInt > 32767 then valueInt = valueInt - 65537 end
  return valueInt / ina219.currentDivider_mA
end

function ina219.getBusVoltage_V()
  -- Gets the raw bus voltage (16-bit signed integer, so +-32767)
  local valueInt = ina219.read_reg_int(ina219.voltage_reg)
  -- Shift to the right 3 to drop CNVR and OVF and multiply by LSB
  local val2 = bit.rshift(valueInt, 3) * 4
  return val2 * 0.001
end

function ina219.getShuntVoltage_mV()
  -- Gets the raw shunt voltage (16-bit signed integer, so +-32767)
  local valueInt = ina219.read_reg_int(ina219.shunt_reg)
  return valueInt * 0.01
end

-- returns the bus power in watts
-- actually, i don't think i have the calculation correct yet
-- cuz this ain't watts or milliwatts. TODO
function ina219.getBusPowerWatts()
  local valueInt = ina219.read_reg_int(ina219.power_reg)
  -- print("raw power: " .. valueInt)
  return valueInt * ina219.powerLsb
end

function ina219.checkVals()
  local registerValue = ina219.read_reg_str(ina219.configuration_reg)
  print("Config: " .. ina219.stringToHex(registerValue))
  print("Shunt Voltage: " .. ina219.getShuntVoltage_mV() .. " mV")
  print("Bus Voltage: " .. ina219.getBusVoltage_V() .. " V")
  print("Power: " .. ina219.getBusPowerWatts() .. " mW")
  print("Current: " .. ina219.getCurrent_mA() .. " mA")
  print("")
end

function ina219.getVals()
  local val = {}
  val.voltageV = ina219.getBusVoltage_V()
  val.shuntmV = ina219.getShuntVoltage_mV()
  val.powerW = ina219.getBusPowerWatts()
  -- sometimes the ina219 returns false current data
  -- where the value is pegged at max so toss it if the
  -- powerW is at 0 because that is usually when it happens
  if val.powerW == 0 then
    val.currentmA = 0
  else
    val.currentmA = ina219.getCurrent_mA()
  end
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
