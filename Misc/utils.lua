function printTable(table)
    for k, v in pairs(table) do
        print(k, v)
    end
    print()
end

printTable(_G)

function myPrint(value)
    if type(value) == "table" then
        printTable(value)
    else
        print(value)
    end
end

function a(...)
    for i,v in ipairs(arg) do
        print(v)
    end
end

function measure(method, methodName)
  local start = tmr.now()
  method()
  local stop = tmr.now()
  print(methodName .. " elapsed: " .. (stop - start) .. " us")
end
