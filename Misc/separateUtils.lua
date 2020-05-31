local methodName = ...

if methodName == "first" then
  return function()
    print("first1")
  end
end

if methodName == "second" then
  return function()
    print("second1")
  end
end
