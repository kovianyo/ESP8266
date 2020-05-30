
local currentDraw = nil

local display = nil

local rowIndex = 0

local _blink = false
local blinkColor = true
-- Set up the u8glib lib. ic2 must be initialized at this point
local function init(i2cId, draw, blink)
  currentDraw = draw
  if blink ~= nil then _blink = blink end
  local sla = 0x3C
  display = u8g2.ssd1306_i2c_128x64_noname(i2cId, sla)
  display:setFont(u8g2.font_6x10_tf)
  display:setFontRefHeightExtendedText()
  display:setDrawColor(1)
  display:setFontPosTop()
  display:setFontDirection(0)
  display:setFlipMode(1)
end

local function drawDisplay()
  if currentDraw ~= nil then
    display:clearBuffer()
    currentDraw(display)
    if _blink then
      if blinkColor then display:setDrawColor(1) else display:setDrawColor(0) end
      display:drawPixel(127,63)
      display:setDrawColor(1)
      blinkColor = not blinkColor
    end
    display:sendBuffer()
    rowIndex = 0
  end
end

local function writeLine(text)
  display:drawStr(0, rowIndex * 10, text)
  rowIndex = rowIndex + 1
end

return {
  Init = init,
  DrawDisplay = drawDisplay,
  WriteLine = writeLine
}
