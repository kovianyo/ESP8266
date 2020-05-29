
local currentDraw = nil

local display = nil

-- Set up the u8glib lib. ic2 must be initialized at this point
function init(i2cId, draw)
  currentDraw = draw
  local sla = 0x3C
  display = u8g2.ssd1306_i2c_128x64_noname(i2cId, sla)
  display:setFont(u8g2.font_6x10_tf)
  display:setFontRefHeightExtendedText()
  display:setDrawColor(1)
  display:setFontPosTop()
  display:setFontDirection(0)
  display:setFlipMode(1)
end

function drawDisplay()
  if currentDraw ~= nil then
    display:clearBuffer()
    currentDraw(display)
    display:sendBuffer()
  end
end

return {
  Init = init,
  DrawDisplay = drawDisplay
}
