
local firstFunction = nil

local function first(...)
  if firstFunction == nil then firstFunction = loadfile("separateUtils.lua")("first") end
  firstFunction(...)
end


local secondFunction = nil

local function second(...)
  if secondFunction == nil then secondFunction = loadfile("separateUtils.lua")("second") end
  secondFunction(...)
end

Utils = {
  First = first,
  Second = second
}
