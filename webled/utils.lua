function split(text, pattern)
  array = {}
  local index = 0
  for i in string.gmatch(text, pattern) do
    array[index] = i
    index = index + 1
  end
  return array
end

function exists(fileName)
  list = file.list();
    for name, size in pairs(list) do
      if name == fileName then return true end
    end
  return false
end

function dofileifexists(fileName)
  if (exists(fileName)) then dofile(fileName)
  else print(fileName .. " does not exist.")
  end
end
